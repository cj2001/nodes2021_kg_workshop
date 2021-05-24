///////////////////
// 
// General queries:
//
///////////////////

// View all nodes
MATCH (n) RETURN n

// Delete all nodes and edges in graph
MATCH (n) DETACH DELETE n

// Remove a property from all nodes
MATCH (n:Node) 
REMOVE n.property_name 
RETURN n LIMIT 1

// Get history of previous querys (limit: 30 with default setup)
:history


///////////////////
// 
// Method 1 queries:
// Full NLP method
//
///////////////////

// See complete graph
MATCH (n) RETURN n

// Convert string labels to list(string)

MATCH (n:Node) 
SET n.type_ls = apoc.convert.toStringList(n.type)

// Update node labels based on type_ls list
MATCH (n:Node) 
CALL apoc.create.addLabels(n, n.type_ls) 
YIELD node 
RETURN node

// How many Obama's are in the graph?
MATCH (n:Node)
WHERE n.name CONTAINS 'obama'
RETURN DISTINCT n.name

// Can we figure out the nationality of 'oh bah mə'
MATCH (n:Node {name: 'oh bah mə'})-[*1..5]->(p) 
WHERE p:Country OR p:AdministrativeArea OR p:Continent OR p:Place
RETURN n, p

MATCH (n:Node {name: 'oh bah mə'})-[:be|:bear]->(p) 
WHERE p:Country OR p:AdministrativeArea OR p:Continent OR p:Place 
RETURN n, p

// Check for duplicates
MATCH (n:Node)
WITH n.name AS name, n.node_labels AS labels, COLLECT(n) AS nodes
WHERE SIZE(nodes) > 1
RETURN [n in nodes | n.name] AS names, [n in nodes | n.node_labels] as labels, SIZE(nodes)
ORDER BY SIZE(nodes) DESC

// Drop duplicates
MATCH (n:Node) 
WITH n.name AS name, COLLECT(n) AS nodes 
WHERE SIZE(nodes)>1 
FOREACH (el in nodes | DETACH DELETE el)

// Get the cosine similarity between two nodes
MATCH (n1:Node {name: 'barack obama'}) 
MATCH (n2:Node {name: 'mitch mcconnell'}) 
RETURN gds.alpha.similarity.cosine(n1.word_vec, n2.word_vec) AS similarity

// Compute Levenshtein distance on related nodes
// (how many characters have to change between n1 and n2)
// (smaller values are better)
MATCH (n1:Node {name: 'barack obama'}) 
MATCH (n2:Node) WHERE n2.name CONTAINS 'obama' 
RETURN n2.name, apoc.text.distance(n1.name, n2.name) AS distance

// Create person, place, thing properties (integer value of 0 or 1)

MATCH (n) WHERE ANY (x in n.node_labels WHERE x IN ['Person', 'Organization', 'EducationalOrganization', 'Corporation', 'SportsTeam', 'SportsOrganization', 'GovernmentOrganization']) 
SET n.pptu_person = 1;

MATCH (n)
WHERE ANY (x in n.node_labels WHERE x IN ['Place', 'AdministrativeArea', 'Country', 'Museum', 'TouristAttraction', 'CivicStructure', 'City', 'CollegeOrUniversity',
                'MovieTheater', 'Continent', 'MusicVenue', 'LandmarksOrHistoricalBuildings', 'Cemetery', 'BodyOfWater',
                'PlaceOfWorship', 'Restaurant', 'LakeBodyOfWater'])
SET n.pptu_place = 1;

MATCH (n)
WHERE ANY (x in n.node_labels WHERE x IN ['Thing', 'Periodical', 'Book', 'Movie', 'Event', 'MusicComposition', 'SoftwareApplication', 'ProductMode', 'DefenceEstablishment',
                'MusicRecording', 'LocalBusiness', 'CreativeWork', 'Article', 'TVEpisode', 'ItemList', 'TVSeries', 'Airline',
                'Product', 'VisualArtwork', 'VideoGame', 'Brand'])
SET n.pptu_thing = 1;

MATCH (n)
WHERE n.pptu_person IS NULL
AND n.pptu_place IS NULL
AND n.pptu_thing IS NULL
SET n.pptu_unknown = 1;

// Create new node label 'Unknown' based on .pptu_unknown
MATCH (n) 
WHERE n.pptu_unknown IS NOT NULL 
CALL apoc.create.addLabels(n, ['Unknown']) 
YIELD node 
RETURN node

// Which nodes have been labeled as Unknown?
MATCH (u:Unknown) RETURN u.name, u.node_labels

// Create an in-memory, undirected graph of all nodes
CALL gds.graph.create(
	'all_nodes',
    {
    	AllNodes: {label: 'Node', 
                   properties: {word_vec_embedding: {property: 'word_vec'}}}
    },
    {
    	AllRels: {type: '*', orientation: 'UNDIRECTED'}
    }
)
YIELD graphName, nodeCount, relationshipCount

// Run node2vec on this graph
CALL gds.alpha.node2vec.stream('all_nodes', {embeddingDimension: 10}) 
YIELD nodeId, embedding 
RETURN gds.util.asNode(nodeId).name as name, embedding

// Write node2vec as a property to main DB
CALL gds.alpha.node2vec.write('all_nodes', 
    { 
        embeddingDimension: 300, 
        writeProperty: 'n2v_all_nodes'
    } 
)

// Two similarities based on node2vec embeddings
MATCH (n1:Node {name: 'oh bah mə'}) 
MATCH (n2:Node {name: 'michelle lavaughn robinson obama'})
RETURN gds.alpha.similarity.cosine(n1.n2v_all_nodes, n2.n2v_all_nodes) AS similarity

MATCH (n1:Node {name: 'president barack obama'}) 
MATCH (n2:Node {name: 'mitch mcconnell'}) 
RETURN gds.alpha.similarity.cosine(n1.n2v_all_nodes, n2.n2v_all_nodes) AS similarity

MATCH (n1:Node {name: 'oh bah mə'}) 
MATCH (n2:Node {name: 'mitch mcconnell'}) 
RETURN gds.alpha.similarity.cosine(n1.n2v_all_nodes, n2.n2v_all_nodes) AS similarity


///////////////////
// 
// Method 2 queries:
// NLP Lite
//
///////////////////

// Find duplicates
MATCH (n:Node) 
WITH n.name AS name, n.node_labels AS labels, COLLECT(n) AS nodes 
WHERE SIZE(nodes) > 1 
RETURN [n in nodes | n.name] AS names, [n in nodes | n.node_labels] as labels, SIZE(nodes) 
ORDER BY SIZE(nodes) DESC

// Drop duplicates (there aren't many)
MATCH (n:Node) 
WITH n.name AS name, COLLECT(n) AS nodes 
WHERE SIZE(nodes)>1 
FOREACH (el in nodes | DETACH DELETE el)

// Convert string labels to list(string)
MATCH (n:Node) 
SET n.type_ls = apoc.convert.toStringList(n.type)

// Update node labels
MATCH (n:Node) 
CALL apoc.create.addLabels(n, n.type_ls) 
YIELD node RETURN node

// Find a lot of places
MATCH (n)
WHERE ANY (x in n.type WHERE x IN 
			['county of Illinois', 
            'state of the United States',
            'oblast of Russian',
            'province of Afghanistan',
            'province of Iran',
            'oblast of Ukraine',
            'district of Libya',
            'governorate of Iraq',
            'province of Cuba',
            'governorate of Syria',
            'sovereign state',
            'autonomous okrug of Russia',
            'city',
            'krai of Russia',
            'city of the United States',
            'territory of the United States',
            'capital',
            'geographic region',
            'continent',
            'county of Hawaii',
            'village',
            'historical country',
            'autonomous republic',
            'organized incorporated territory',
            'unincorporated territory',
            'census-designated place',
            'human settlement',
            'borough of New York City',
            'Commonwealth realm',
            'city of Pennyslvania',
            'neighborhood of Washington, D.C.',
            'country']
		  )
SET n.is_place=1, n:Model_Data

// Set is_place property for all other nodes
MATCH (n) WHERE n.is_place IS NULL SET n.is_place=0

// Get a random set of those non-place nodes to add to model data
MATCH (n {is_place: 0}) WHERE rand() < 0.48 SET n:Model_Data

// Set some holdout data
MATCH (n) 
WHERE NOT n:Model_Data 
SET n:Holdout_Data 
RETURN COUNT(n)

// Which of these have an unknown label?
MATCH (n:Holdout_Data {type: 'Unknown'}) RETURN n.name

// Create in-memory graph of model data
CALL gds.graph.create(
	'all_nodes',
    {
    	ModelNodes: {label: 'Model_Data'},
        HoldoutNodes: {label: 'Holdout_Data'}
    },
    {
    	AllRels: {type: '*', orientation: 'UNDIRECTED'}
    }
)
YIELD graphName, nodeCount, relationshipCount

// Create n2v embeddings
CALL gds.alpha.node2vec.write('all_nodes', 
    { 
        embeddingDimension: 300, 
        writeProperty: 'n2v_all_nodes'
    } 
)

// Create FastRP embeddings
CALL gds.fastRP.write(
	'all_nodes',
    {embeddingDimension: 300, writeProperty: 'frp_all_nodes'}
)



