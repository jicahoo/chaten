-- Script worked well on Hive 1.2.2
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

SELECT * FROM bcfmcidi_hive;

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


SELECT b.cust_isn, b.cust_name, b.phone_no, 
CASE WHEN b.sex =1 THEN 'male' ELSE 'female' END, 
concat(substr(cast(b.birthday AS STRING),1,4),'-',substr(cast(b.birthday AS STRING),5,2), '-', substr(cast(b.birthday AS STRING),7,2)), 
c.post,c.address
FROM bcfmcidi_hive b LEFT JOIN cust_ecif_hive c ON b.cust_isn = c.cust_isn;