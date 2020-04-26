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

alter user cnelson set rsa_public_key  = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyFn1jbULNi93misGhqhv
h9QVXV498fTi9sIegi19pbVt+EjLnmI85pw1rMvOURj+nyWWUDriNGudJzzjIeVU
LqLrFCl4Yn5vujE0QHVoKWlrEtITj4eo8Mtt+ewW9qzR8LRCnB6UoZ4cNISK5D2O
AIplZu5WyvqJ/6PiOscS9vmPCULb5WHuCIzzWTCZgSBMmMCDYhRDPKdHX+qw5Hxt
bmKaFpQlmVmM6GiBf1vsJBZUKArJad5S4PrKWw8PDmsU+Tq5i1TjqFwm1k47tu+W
Ee3Vpco95r8FSj5KANvVonWVj1EqgM3vf0EZfN2o0NIQORhVhGG08IGhbYZf4AW6
2wIDAQAB';

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
