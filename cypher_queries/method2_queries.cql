///////////////////
// 
// Method 2 queries:
// NLP Lite
//
///////////////////


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

// ***PROBLEM: WHERE WAS BARACK OBAMA BORN?***

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
SET n.is_place=1;

// Set is_place property for all other nodes
MATCH (n) WHERE n.is_place IS NULL SET n.is_place=0

// Count how many have is_place = 1
// It should be around 413 with about 906 for is_place = 0
MATCH (n {is_place: 1}) RETURN COUNT(n)

MATCH (n {is_place: 0}) RETURN COUNT(n)

// Create in-memory graph of model data
CALL gds.graph.create(
	'all_nodes',
    'Node',
    {
        RELS: {
            type: '*',
            orientation: 'UNDIRECTED'
        }
    }
)

// Create n2v embeddings
CALL gds.beta.node2vec.write('all_nodes', 
    { 
        embeddingDimension: 10, 
        writeProperty: 'n2v_all_nodes'
    } 
)

// Create FastRP embeddings
CALL gds.fastRP.write(
	'all_nodes',
    {embeddingDimension: 10, writeProperty: 'frp_all_nodes'}
)
