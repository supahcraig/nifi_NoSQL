# Sample flows for sending Twitter JSON data into various NoSQL databases via Apache Nifi.

### Docker Containers- 

#### Nifi
`docker run -d --name nifi -p 8080:8080 apache/nifi`

#### MongoDB
`docker run -d --name mongo -p 27017:27101 mongo`

#### Couchbase
docker run -d --name couchbase -p 8091-8096:8091-8096 -p 11210-11211:11210-11211 couchbase

### Queries

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
