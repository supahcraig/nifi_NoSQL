# Sample flows for sending Twitter JSON data into various NoSQL databases via Apache Nifi.

### Docker Containers- 

#### Nifi
`docker run -d --name nifi -p 8080:8080 apache/nifi`

#### MongoDB
`docker run -d --name mongo -p 27017:27101 mongo`


### Queries

#### MongoDB
```javascript
db.twitter.aggregate( [
    {$unwind: '$entities.hashtags'},
    { $group: { _id: '$entities.hashtags.text',
    tagCount: {$sum: 1} }}, 
    { $sort: { tagCount: -1 }} 
 ]);
 ```
