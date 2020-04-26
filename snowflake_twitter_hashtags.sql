CREATE DATABASE twitter_db;
USE DATABASE twitter_db;

create or replace warehouse compute_wh
warehouse_size = SMALL
auto_suspend=600;

create or replace table twitter
(tweet_payload variant);

create or replace file format tweet_payload_format type = 'json';

create or replace stage twitter_db.public.nifi_twitter_stage
file_format = tweet_payload_format;

create or replace pipe nifi_twitter_pipe as
copy into twitter
from @nifi_twitter_stage
file_format = (type=json);

alter user cnelson set rsa_public_key  = 'YOUR_PUBLIC_KEY_HERE';

select count(*)
     , htags.value:text
from twitter t
   , lateral flatten(input => t.tweet_payload:entities:hashtags) htags
where 1 = 1
group by 2
order by 1 desc;
