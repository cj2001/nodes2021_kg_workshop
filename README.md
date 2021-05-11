# Knowledge Graph Demo
### Written by: Dr. Clair J. Sullivan, Graph Data Science Advocate, Neo4j
#### email: clair.sullivan@neo4j.com
#### Twitter: @CJLovesData1
#### Last updated: 2021-05-11

## Introduction

This repository contains a demonstration for how to create and query a knowledge graph using Neo4j.  It is based off of a Docker container that establishes the Neo4j database as well as a Jupyter Lab instance.  There are two methods that will be in this demo of how to do this:

1. A version based on natural language processing (NLP) using Spacy to extract (subject, verb, object) triples from Wikipedia and the Google Knowledge Graph via their API.
2. A version that queries Wikidata given a series of items (based on the Wikidata Q-values) and their claims (using the Wikidata P-values).  The Q-values are used to create the subjects and objects of the triples while the P-values are used to create the verbs.

### General Comment

While either of these methods works, the benefit of the first approach is that you will have limitless numbers of verbs (since they are somewhat automatically detected from text), but you will have a problem with entity disambiguation.  The beneift of the second approach is that Wikidata is able to handle the entity disambiguation for you, but you have to supply the list of verbs (claims) that you care about.

Personally, I prefer the second approach.  The reason is that you don't have to do _too_ much NLP on the unstructured text.  You will still use named entity resolution on the input text, but Spacy handles that pretty easily.  The first approach, on the other hand, relies on the ability to accurately detect the verbs and attribute them to subjects and objects, which is very complicated.  The second approach is much cleaner.  Further, complicated NLP approaches like the first require much more tuning.  NLP is not a so-called "silver bullet."  It requires a lot of tuning and is very specific to the language and vocabulary.  If the vocabulary is particularly technical, it is likely that you will find Wikidata to provide you with superior results.

## A note on the use of the Google Knowledge Graph

(This is only used for the first approach above and just for demonstration purposes.  You can easily substitue any additional data source, including Wikidata.)

We will be working with the Google Knowledge Graph REST API in this example.  Users are permitted 100,000 calls per day for free to the API, but will require an API key for the API calls.  A link on how to create this API key is below.  Once the key is created, it is recommended that you store in in a file named `.api_key` at the root level of this repo.


## Useful links

- [Docker for Data Science -- A Step by Step Guide](https://towardsdatascience.com/docker-for-data-science-a-step-by-step-guide-1e5f7f3baf8e)
- [Google Knowledge Graph Search API](https://wikipedia.readthedocs.io/en/latest/)
  - [How to Create a Google Knowledge Graph Search API Key](https://developers.google.com/knowledge-graph/prereqs)
  - [Knowledge Graph Search API Authorize Requests](https://developers.google.com/knowledge-graph/how-tos/authorizing)
- [Neo4j](https://neo4j.com)
  - [Awesome Procedures on Cypher (APOC)](https://neo4j.com/labs/apoc/)
  - [Cypher Manual](https://neo4j.com/docs/cypher-manual/current/)
  - [Cypher Reference Card](https://neo4j.com/docs/pdf/neo4j-cypher-refcard-stable.pdf)
  - [Graph Data Science (GDS) Library](https://neo4j.com/developer/graph-data-science/)
  - [Python Driver API Docs](https://neo4j.com/docs/api/python-driver/current/)
- [spacy Documentation](https://spacy.io/)
- [Wikipedia package docs](https://wikipedia.readthedocs.io/en/latest/)


### Final Note

This notebook is heavily based off of a talk I gave at the 2021 Open Data Science Conference East, whose repository you can find [here](https://github.com/cj2001/odsc_east_kg_2021).
