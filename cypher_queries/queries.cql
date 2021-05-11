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

// Update node labels based on node_labels list
MATCH (n:Node) 
CALL apoc.create.addLabels(n, n.node_labels) 
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

