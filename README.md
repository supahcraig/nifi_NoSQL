# Sample flows for sending Twitter JSON data into various NoSQL databases via Apache Nifi.

## Docker Containers- 

### Nifi
`docker run -d --name nifi -p 8080:8080 apache/nifi`


#### Docker > 1.14 & Security

*NOTE* nifi version >= 1.14 included https & user authentication by default, and runs on port 8443 instead.

`docker run -d --name nifi -p 8443:8443 apache/nifi`

It will generate a username & password that you can see if you do a `docker logs -f nifi` but in case you miss it or forget it...

`docker exec nifi /bin/bash -c "grep Generated /opt/nifi/nifi-current/logs/nifi-app*log"`

You can also re-set it from within the container or via `docker exec`:

`docker exec nifi /opt/nifi/nifi-current/bin/nifi.sh set-single-user-credentials cnelson qwerty123456`

but note that you'll have to do a `docker restart nifi` for the changes to take effect.

---

#### MongoDB
`docker run -d --name mongo -p 27017:27101 mongo`

---

#### Couchbase
docker run -d --name couchbase -p 8091-8096:8091-8096 -p 11210-11211:11210-11211 couchbase

---

### Queries

---

#### MongoDB / CosmosDB with Mongo API
```javascript
db.twitter.aggregate( [
    {$unwind: '$entities.hashtags'},
    { $group: { _id: '$entities.hashtags.text',
    tagCount: {$sum: 1} }}, 
    { $sort: { tagCount: -1 }} 
 ]);
 ```

#### Couchbase
```javascript
SELECT count(*) as htag_count, x.hashtag_text
FROM (
SELECT twitter.id
     , htags.text as hashtag_text
FROM twitter
UNNEST twitter.entities.hashtags as htags
WHERE 1 = 1
  and twitter.entities.hashtags != []
) x
GROUP BY x.hashtag_text
HAVING count (*) > 1
ORDER BY htag_count desc;
```

#### Snowflake
```javascript
SELECT count(*)
     , htags.value:text
FROM twitter t
   , LATERAL FLATTEN(INPUT => t.tweet_payload:entities:hashtags) htags
WHERE 1 = 1
GROUP BY 2
ORDER BY 1 desc;
```
