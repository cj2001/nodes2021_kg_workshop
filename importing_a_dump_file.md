## Importing data from a .dump file

The instructions in this file are _optional._  You are welcome to run the workshop code and create your own graph.  However, if you would rather import the exact graph that we are using the graph, you can do this with the `.dump` files in `data/`, which contain a backup of the complete SVO and Wikidata graphs from the workshop.

To import the data into the Neo4j database, you will need to go into the Neo4j portion of the Docker container via the command line:

```
docker exec -it neo-gds /bin/bash
```

You can confirm the two files, `svo.dump` and `wiki.dump` are in `var/lib/neo4j/import/`.  From here, we will need to stop the default database (typically called `neo4j`).  We will do this via:

```
cypher-shell -u neo4j -p kgDemo -d system "SHOW DATABASES;"
cypher-shell -u neo4j -p kgDemo -d system "STOP DATABASE neo4j;"
```

(Note that `cypher-shell` and `neo4j-admin` should be recognized at the CLI of the container.  However, if they are not, you will find them in `/var/lib/neo4j/bin/`.)

Now we will populate the default database and restart it using:

```
neo4j-admin load --from=/var/lib/neo4j/import/svo.dump --database=neo4j --force
cypher-shell -u neo4j -p kgDemo -d system "START DATABASE neo4j;"
```

You might see an error on the status of the `neo4j` database initially.  That is OK.  From here we need to stop the container and restart it.  After you do that, the database should be online and you should see the starting graph we used for the workshop.  You can do the repeat the same steps to bring in the Wikidata graph.

For additional informaton on restoring a database from a `.dump` file, please consult [these docs](https://neo4j.com/docs/operations-manual/current/backup-restore/restore-dump/).

### Note on folder/file permissions

Since Neo4j will claim ownership and permissions of `data/`, you will need to use `sudo` to access the files in there after running the container for the first time.

**If you have a problem accessing the files from this repo, you can also download them from [this Google drive](https://drive.google.com/drive/folders/1qiyJxRNkBRpxWLuqKX8tqTxmnzqDqLaY?usp=sharing).**