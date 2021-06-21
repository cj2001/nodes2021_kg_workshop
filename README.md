# NODES 2021 Workshop: Creating a Knowledge Graph with Neo4j: A Simple Machine Learning Approach
### Written by: Dr. Clair J. Sullivan, Data Science Advocate, Neo4j
#### email: clair.sullivan@neo4j.com
#### Twitter: @CJLovesData1
#### Last updated: 2021-06-11

## Introduction

This repository contains the information needed for the NODES 2021 workshop entitled "Creating a Knowledge Graph with Neo4j: A Simple Machine Learning Approach."  It is based off of a Docker container that establishes the Neo4j database as well as a Jupyter Lab instance.  In order to get the most out of this workshop you should be comfortable with Python 3.  We will assume a minimal understanding of Cypher. 

## Instructions for pre-workshop preparation

Below you will find information on how to created both an API key for the Google Knowledge Graph as well as the API token for Wikidata.  You will need to create these before the workshop.

Additionally, note that this repository will be updated regularly between now and the workshop.  You are encouraged to pull the latest version of it just before the workshop to make sure you have the most up-to-date code.

## The two methods we will use for the workshop

There are two methods that will be in this workshop of how to create a knowledge graph are as follows:

1. A version based on natural language processing (NLP) using Spacy to extract (subject, verb, object) triples from Wikipedia and the Google Knowledge Graph via their API.
2. A version that queries Wikidata given a series of items (based on the Wikidata Q-values) and their claims (using the Wikidata P-values).  The Q-values are used to create the subjects and objects of the triples while the P-values are used to create the verbs.


While either of these methods works, the benefit of the first approach is that you will have limitless numbers of verbs (since they are somewhat automatically detected from text), but you will have a problem with entity disambiguation.  The benefit of the second approach is that Wikidata is able to handle the entity disambiguation for you, but you have to supply the list of verbs (claims) that you care about.

Personally, I prefer the second approach.  The reason is that you don't have to do _too_ much NLP on the unstructured text.  You will still use named entity resolution on the input text, but Spacy handles that pretty easily.  The first approach, on the other hand, relies on the ability to accurately detect the verbs and attribute them to subjects and objects, which is very complicated.  The second approach is much cleaner.  Further, complicated NLP approaches like the first require much more tuning.  NLP is not a so-called "silver bullet."  It requires a lot of tuning and is very specific to the language and vocabulary.  If the vocabulary is particularly technical, it is likely that you will find Wikidata to provide you with superior results.

### A note on the use of the Google Knowledge Graph

(This is only used for the first approach above and just for demonstration purposes.  You can easily substitue any additional data source, including Wikidata.)

We will be working with the Google Knowledge Graph REST API in this example.  Users are permitted 100,000 calls per day for free to the API, but will require an API key for the API calls.  You can read more on how to get this API key [here](https://developers.google.com/knowledge-graph/prereqs).  Once the key is created, it is recommended that you store in in a file named `.api_key` at the root level of this repo.  This should go in the `notebooks/` subdirectory.

### A note on scraping Wikidata with a bot

We will be using [Pywikibot](https://www.mediawiki.org/wiki/Manual:Pywikibot) to scrape entries from Wikidata.  In order to do this, you will need to create a token for this bot.  Directions on how to do so can be found [here](https://heardlibrary.github.io/digital-scholarship/host/wikidata/bot/).  Once you have that token, save it into a file named `.wiki_api_token` in the `notebooks/` subdirectory.

## How to run the code

With Docker and docker-compose installed, from the CLI:

```
docker-compose build
docker-compose up
```

(Note: if you have already built the container and run it once, Neo4j assumes ownership of `data/` as group and user `7474:7474`, which means the only way to access it is via `sudo`.  Therefore, you might need to run the above two commands via `sudo`.)

Take the link for Jupyter Lab from the terminal (it has the notebook token with it) and copy and paste that into your web browser.  To open the Neo4j browser, navigate to `localhost:7474`.  The login is `neo4j` and the password is `kgDemo`.  These are set on line 15 in `docker-compose.yml` and you can change them to anything you like.  

When you are done, you can shut down the container by hitting `CTRL-C` in the terminal and then at the prompt:

```
docker-compose down
```

### A note regarding the memory configuration in the `docker-compose.yml` file

There are some variables in the file such as `NEO4J_dbms_memory_pagecache_size` that have been set to some somewhat arbitrary values.  This should be set for values corresponding to the available memory on your computer.  If these values, say, exceed the available memory on your machine, you can either edit them or comment them out entirely.


### Note on using multiple databases (like are shown in this repo)

You might find it convenient to have two different databases, one for each method.  In order to achieve this, edit lines 8 and 9 in `docker-compose.yml` to reflect that (i.e. make a different directory for each graph).  You might find this helpful if, like me, you screw up one and don't want to recreate the other.  :)

### Another note on the location of the database files

The first time you run this container from the repo, the permissions on `data/` will be changed to root.  This means that all subsequent runnings of `docker-compose` will need to be executed by `sudo`.  However, this also will change the directory forwarding in the `.yml` file at line 8 since `$HOME` will change from your personal login to `root`.  To adjust for this, you can explicitly change `$HOME` to a hard-coded path or you can leave it and find your database backups at `/root/graph_data/`.

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
