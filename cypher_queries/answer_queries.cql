// Can we figure out the nationality of 'oh bah mə'
MATCH (n:Node {name: 'oh bah mə'})-[*1..5]->(p) 
WHERE p:Country OR p:AdministrativeArea OR p:Continent OR p:Place
RETURN n, p

MATCH (n:Node {name: 'oh bah mə'})-[:be|:bear]->(p) 
WHERE p:Country OR p:AdministrativeArea OR p:Continent OR p:Place 
RETURN n, p

// Check for duplicates in Method 1
MATCH (n:Node)
WITH n.name AS name, n.node_labels AS labels, COLLECT(n) AS nodes
WHERE SIZE(nodes) > 1
RETURN [n in nodes | n.name] AS names, [n in nodes | n.node_labels] as labels, SIZE(nodes)
ORDER BY SIZE(nodes) DESC

// Check for duplicates in Method 2
// Find duplicates
MATCH (n:Node) 
WITH n.name AS name, n.node_labels AS labels, COLLECT(n) AS nodes 
WHERE SIZE(nodes) > 1 
RETURN [n in nodes | n.name] AS names, [n in nodes | n.node_labels] as labels, SIZE(nodes) 
ORDER BY SIZE(nodes) DESC

// Method 2: Where was Barack Obama born?
MATCH (n:Node {name: 'Barack Obama'})-[:place_of_birth]->(place:Node) RETURN place.name