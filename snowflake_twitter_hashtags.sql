CREATE DATABASE twitter_db;
USE DATABASE twitter_db;
USE SCHEMA twitter_db.public;

create or replace table twitter
(tweet_payload variant);

create or replace file format tweet_payload_format type = JSON;

create or replace stage twitter_db.public.nifi_twitter_stage
file_format = tweet_payload_format;

create or replace pipe nifi_twitter_pipe as
copy into twitter
from @nifi_twitter_stage
file_format = (type=json);

describe pipe nifi_twitter_pipe;

alter user cnelson set rsa_public_key  = 'YOUR_PUBLIC_KEY_HERE';

create or replace warehouse compute_wh
warehouse_size = small
auto_suspend=600;

select count(*)
     , htags.value:text
from twitter t
   , lateral flatten(input => t.tweet_payload:entities:hashtags) htags
where 1 = 1
group by 2
order by 1 desc;
