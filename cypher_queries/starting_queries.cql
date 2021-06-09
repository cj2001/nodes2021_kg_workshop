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

// Import SVO graph from JSON on GitHub
CALL apoc.import.json("https://raw.githubusercontent.com/cj2001/nodes2021_kg_workshop/main/json_files/svo.json")

// Import Wikidata graph from JSON on GitHub
CALL apoc.import.json("https://raw.githubusercontent.com/cj2001/nodes2021_kg_workshop/main/json_files/wiki.json")