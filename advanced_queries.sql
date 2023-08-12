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


-- Getting the total number of males and females

-- Sex_Ratio = females*1000/males   (since sex ratio is no. of females against 1000 males)
-- Males:
--        s  = (population - males)*1000/males
--      s*m  = 1000*p - 1000*m
-- m(s+1000) = 1000*p
--         m = (1000*p)/(s+1000)

-- Females:
--       s*m = f*1000
--  s*(p-f)  = f*1000d
-- s*p - s*f = f*1000
-- f(s+1000) = s*p
--         f = s*p/(s+1000)

select p.district, p.state, Sex_Ratio,
round((1000*population)/(Sex_Ratio+1000),0) as males,
(round(Sex_Ratio*population/(Sex_Ratio + 1000),0)) as females,
population
from literacy_census11 l
join population_census11 p
on l.district = p.district
limit 5;

-- Previous query aggregated statewise (using subquery)
select state, sum(males), sum(females) from 
(select p.district district, p.state state, Sex_Ratio,
round((1000*population)/(Sex_Ratio+1000),0) as males,
(round(Sex_Ratio*population/(Sex_Ratio + 1000),0)) as females,
population
from literacy_census11 l
join population_census11 p
on l.district = p.district) q
group by state;

-- Total literate and illiterate people
select p.district, p.state, round(population*Literacy,0) literate_population,
round(population*(1-Literacy),0) illiterate_population
from literacy_census11 l
join population_census11 p
on l.district = p.district
limit 5;

-- Population in previous census
-- current_population = last_census_population + last_census_population * growth
-- last_census_population  = current_population / (1 + growth)
select p.district, p.state, l.growth, p.population,
round(p.population/(1 + l.growth),0) last_census_population
from literacy_census11 l
join population_census11 p
on l.district = p.district
limit 5;

-- Previous query aggregated statewise (using subquery)
select state, sum(current_population) state_current_population, sum(last_census_population) state_last_census_population from
(select p.district district, p.state state, l.growth, p.population current_population,
round(p.population/(1 + l.growth),0) last_census_population
from literacy_census11 l
join population_census11 p
on l.district = p.district) q
group by state;

-- Total population in last census vs current census
--  with Percentage growth in population on national level
select sum(current_population) pop2011, sum(last_census_population) pop2001,
concat(round((sum(current_population) - sum(last_census_population))*100/sum(last_census_population),2),' %') percentage_growth_national
from
(select p.district district, p.state state, l.growth, 
p.population current_population,
round(p.population/(1 + l.growth),0) last_census_population
from literacy_census11 l
join population_census11 p
on l.district = p.district) q;


-- Population density (population per square kilometer)
select sum(population)/sum(Area_km2) total_population_density 
from population_census11;

-- Population density compared with previous census
select a.pop2001/b.total_area pop_density_2001, a.pop2011/b.total_area pop_density_2011, total_area from
(select '1' as keyy, p.* from 
(select sum(last_census_population) pop2001, sum(current_population) pop2011
from
(select p.district district, p.state state, l.growth, 
p.population current_population,
round(p.population/(1 + l.growth),0) last_census_population
from literacy_census11 l
join population_census11 p
on l.district = p.district) q) p) a

inner join

(select '1' as keyy, n.* from
(select sum(Area_km2) total_area 
from population_census11) n ) b

on a.keyy = b.keyy;

-- Another approach for the previous query
select sum(last_census_population)/sum(area) pop_density_2001, sum(current_population)/sum(area) pop_density_2011, sum(area)
from
(select p.district district, p.state state, l.growth, 
p.population current_population, p.Area_km2 area,
round(p.population/(1 + l.growth),0) last_census_population
from literacy_census11 l
join population_census11 p
on l.district = p.district) q;

-- The results from these two queries are slightly different from each other. Need to investigate why.

-- Top 3 districts from each state with highest literacy rate (using window function)

select a.* from (
select district, state, literacy, rank() over (partition by state order by literacy) rank_literacy 
from literacy_census11) a
where rank_literacy <=3;

-- Bottom 3 districts from each state with highest literacy rate (using window function)

select a.* from (
select district, state, literacy, rank() over (partition by state order by literacy desc) rank_literacy 
from literacy_census11) a
where rank_literacy <=3;