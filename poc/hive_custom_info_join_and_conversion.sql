-- Script worked well on Hive 1.2.2

--Prepare table and data.
DROP TABLE bcfmcidi_hive;
CREATE TABLE bcfmcidi_hive (
cust_isn STRING,
bel_org STRING,
phone_no STRING,
cust_name STRING,
sex INT,
birthday DECIMAL(8,0)
);

INSERT INTO TABLE bcfmcidi_hive VALUES
('cust_1', 'org_1', '18910001000', 'Alice', 2, 19901220.0),
('cust_2', 'org_2', '18910001001', 'Bob', 1, 19801012.0),
('cust_3', 'org_3', '18910001002', 'Robert', 1, 19881012.0)
;

DROP TABLE cust_ecif_hive;
CREATE TABLE cust_ecif_hive (
cust_isn STRING,
bel_org STRING,
post STRING,
office_tel STRING,
address STRING
);

INSERT INTO cust_ecif_hive VALUES
('cust_1', 'org_1', 'Engineer', '010-88213326', 'Beijing City, Haidian'),
('cust_2', 'org_2', 'Manager', '020-99202203', 'Shanghai Citi, Yangpu');


-- Query based on requirements
SELECT b.cust_isn, b.cust_name, b.phone_no, 
CASE WHEN b.sex =1 THEN 'male' ELSE 'female' END, 
concat(substr(cast(b.birthday AS STRING),1,4),'-',substr(cast(b.birthday AS STRING),5,2), '-', substr(cast(b.birthday AS STRING),7,2)), 
c.post,c.address
FROM bcfmcidi_hive b LEFT JOIN cust_ecif_hive c ON b.cust_isn = c.cust_isn;

--The ouput will be like below:
--cust_1  Alice   18910001000     female  1990-12-20      Engineer        Beijing City, Haidian
--cust_2  Bob     18910001001     male    1980-10-12      Manager Shanghai Citi, Yangpu
--cust_3  Robert  18910001002     male    1988-10-12      NULL    NULL

-- Send queried data into ElasticSearch
-- Step 1: Create a EXTERNAL TABLE for elasticsearch
CREATE EXTERNAL TABLE custom_info_es (
cust_isn STRING,
cust_name STRING,
phone_no STRING,
sex STRING,
birthday STRING,
position STRING,
address STRING
)
STORED BY 'org.elasticsearch.hadoop.hive.EsStorageHandler'
TBLPROPERTIES('es.resource'='custom/cust_info',
'es.mapping.names'='cust_isn:custIsn,cust_name:custName,phone_no:phoneNumber,sex:gender,birthday:birthday,position:position,address:address');

-- Step 2: Insert the quiered data into that external table.
INSERT INTO TABLE custom_info_es 
SELECT b.cust_isn, b.cust_name, b.phone_no, 
CASE WHEN b.sex =1 THEN 'male' ELSE 'female' END, 
concat(substr(cast(b.birthday AS STRING),1,4),'-',substr(cast(b.birthday AS STRING),5,2), '-', substr(cast(b.birthday AS STRING),7,2)), 
c.post,c.address
FROM bcfmcidi_hive b LEFT JOIN cust_ecif_hive c ON b.cust_isn = c.cust_isn;

-- Step 3: Then you can query these data using ElasticSearch very easily. And you can leverage all query capbility of ElasticSearch.
-- curl -XGET 'http://localhost:9200/custom/cust_info'
-- curl -XGET 'http://localhost:9200/custom/_search?pretty=true'
-- curl -XGET 'http://localhost:9200/custom/cust_info/_search?q=custIsn:cust_1'
-- curl -XGET 'http://localhost:9200/custom/cust_info/_search?q=custName:Robert'