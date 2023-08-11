-- desc literacy_census11;
-- +-----------+-------------+------+-----+---------+----------------+
-- | Field     | Type        | Null | Key | Default | Extra          |
-- +-----------+-------------+------+-----+---------+----------------+
-- | id        | int         | NO   | PRI | NULL    | auto_increment |
-- | District  | varchar(40) | YES  |     | NULL    |                |
-- | State     | varchar(40) | YES  |     | NULL    |                |
-- | Growth    | float(5,4)  | YES  |     | NULL    |                |
-- | Sex_Ratio | int         | YES  |     | NULL    |                |
-- | Literacy  | float(5,4)  | YES  |     | NULL    |                |
-- +-----------+-------------+------+-----+---------+----------------+

-- desc population_census11;
-- +------------+-------------+------+-----+---------+----------------+
-- | Field      | Type        | Null | Key | Default | Extra          |
-- +------------+-------------+------+-----+---------+----------------+
-- | id         | int         | NO   | PRI | NULL    | auto_increment |
-- | District   | varchar(40) | YES  |     | NULL    |                |
-- | State      | varchar(40) | YES  |     | NULL    |                |
-- | Area_km2   | int         | YES  |     | NULL    |                |
-- | Population | int         | YES  |     | NULL    |                |
-- +------------+-------------+------+-----+---------+----------------+


-- Literacy data for MH and GJ
select * from literacy_census11 where State in ("Maharashtra", "Gujarat");

-- Total population of india
select sum(population) from population_census11;

-- Average growth of the nation
select avg(growth)*100 from literacy_census11; 

-- statewise average growth
select state, avg(growth)*100 Average_Growth 
from literacy_census11 
group by state 
order by Average_Growth desc;

-- statewise average sex ratio
select state, round(avg(Sex_Ratio), 0) Average_sex_ratio 
from literacy_census11 
group by state;

-- statewise average literacy
select state, avg(Literacy) Average_Literacy 
from literacy_census11 
group by state;

-- states with average literacy greater thean 90%
select state, avg(Literacy) Average_Literacy 
from literacy_census11 
group by state 
having Average_Literacy > .90 
order by Average_Literacy desc;

-- Top 3 states with highest growth ration
select state, avg(growth)*100 Average_Growth 
from literacy_census11 
group by state 
order by Average_Growth desc 
limit 3;

-- Bottom 3 states with highest growth ration
select state, avg(growth)*100 Average_Growth 
from literacy_census11 
group by state 
order by Average_Growth asc 
limit 3;

-- Getting top 3 and bottom 3 states in literacy rate in a single output 
-- using temporary tables, subqueries and union

-- creating topstates temp table
drop table if exists topstates;
create temporary table topstates (
    state varchar(40),
    topstates float
);

insert into topstates
select state, avg(Literacy) Average_Literacy 
from literacy_census11 
group by state 
order by Average_Literacy desc; 

select * from topstates limit 3;

-- creating bottomstates temp table
drop table if exists bottomstates;
create temporary table bottomstates (
    state varchar(40),
    bottomstates float
);

insert into bottomstates
select state, avg(Literacy) Average_Literacy 
from literacy_census11 
group by state 
order by Average_Literacy asc; 

select * from bottomstates limit 3;


-- getting their union
select * from (
select * from topstates order by topstates desc limit 3) a
union
select * from (
select * from bottomstates order by bottomstates asc limit 3) b;

-- output:
-- +-------------------+-----------+
-- | state             | topstates |
-- +-------------------+-----------+
-- | Kerala            |   0.93695 |
-- | Lakshadweep       |    0.9185 |
-- | Mizoram           |  0.893613 |
-- | Bihar             |  0.617563 |
-- | Arunachal Pradesh |  0.638619 |
-- | Rajasthan         |  0.646006 |
-- +-------------------+-----------+


-- states starting with letter 'A'
select distinct state 
from literacy_census11 
where upper(state) like "A%";

-- states starting with letter 'A' and ending with letter 'M'
select distinct state 
from literacy_census11 
where upper(state) like "A%M";
