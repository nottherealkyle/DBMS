
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS emission_metrics;
DROP TABLE IF EXISTS generation_records;
DROP TABLE IF EXISTS power_plants;
DROP TABLE IF EXISTS fuel_types;
DROP TABLE IF EXISTS operators;
DROP TABLE IF EXISTS countries;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE countries (
    CountryCode CHAR(3)      NOT NULL,
    CountryName VARCHAR(100) NOT NULL,
    Continent   VARCHAR(50)  NOT NULL,
    PRIMARY KEY (CountryCode)
);

CREATE TABLE operators (
    OperatorID          INT          NOT NULL,
    OperatorName        VARCHAR(100) NOT NULL,
    HeadquartersCountry CHAR(3)      NOT NULL,
    PRIMARY KEY (OperatorID),
    FOREIGN KEY (HeadquartersCountry) REFERENCES countries (CountryCode)
);

CREATE TABLE fuel_types (
    FuelID       INT         NOT NULL,
    FuelCategory VARCHAR(50) NOT NULL,
    FuelName     VARCHAR(50) NOT NULL,
    PRIMARY KEY (FuelID)
);

CREATE TABLE power_plants (
    PlantID        INT          NOT NULL,
    PlantName      VARCHAR(100) NOT NULL,
    CountryCode    CHAR(3)      NOT NULL,
    OperatorID     INT          NOT NULL,
    FuelID         INT          NOT NULL,
    CapacityMW     INT          NOT NULL,
    CommissionYear INT          NOT NULL,
    PRIMARY KEY (PlantID),
    FOREIGN KEY (CountryCode) REFERENCES countries (CountryCode),
    FOREIGN KEY (OperatorID)  REFERENCES operators (OperatorID),
    FOREIGN KEY (FuelID)      REFERENCES fuel_types (FuelID)
);

CREATE TABLE generation_records (
    PlantID       INT           NOT NULL,
    `year`        INT           NOT NULL,
    GenerationGWh DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (PlantID, `year`),
    FOREIGN KEY (PlantID) REFERENCES power_plants (PlantID)
);

CREATE TABLE emission_metrics (
    PlantID           INT           NOT NULL,
    `year`            INT           NOT NULL,
    CO2EmissionsTonnes DECIMAL(14,2) NOT NULL,
    PRIMARY KEY (PlantID, `year`),
    FOREIGN KEY (PlantID) REFERENCES power_plants (PlantID)
);

INSERT INTO countries VALUES
('USA','United States','North America'),
('CAN','Canada','North America'),
('DEU','Germany','Europe'),
('IND','India','Asia'),
('BRA','Brazil','South America'),
('JPN','Japan','Asia'),
('AUS','Australia','Oceania'),
('ZAF','South Africa','Africa'),
('GBR','United Kingdom','Europe'),
('CHN','China','Asia');

INSERT INTO operators VALUES
(101,'Global Hydro Inc','USA'),
(102,'Rhein Power AG','DEU'),
(103,'NTPC Limited','IND'),
(104,'Electrobras','BRA'),
(105,'Tepco Energy','JPN'),
(106,'Snowy Hydro','AUS'),
(107,'Eskom Holdings','ZAF'),
(108,'China Yangtze Power','CHN');

INSERT INTO fuel_types VALUES
(1,'Renewable','Hydro'),
(2,'Fossil','Coal'),
(3,'Nuclear','Uranium'),
(4,'Fossil','Gas'),
(5,'Renewable','Solar');

INSERT INTO power_plants VALUES
(1,'Grand Coulee','USA',101,1,6809,1942),
(2,'Janschwalde','DEU',102,2,3000,1981),
(3,'Vindhyachal','IND',103,2,4760,1987),
(4,'Itaipu','BRA',104,1,14000,1984),
(5,'Kashiwazaki-Kariwa','JPN',105,3,8212,1985),
(6,'Loy Yang','AUS',106,2,2210,1984),
(7,'Three Gorges','CHN',108,1,22500,2003),
(8,'Tuoketuo','CHN',108,2,13200,1995);

INSERT INTO generation_records VALUES
(1,2024,21500.50),
(2,2024,18400.20),
(3,2024,35600.80),
(4,2024,89000.10),
(5,2024,0.00),
(6,2024,14200.40),
(7,2024,98800.00),
(8,2024,71000.30);

INSERT INTO emission_metrics VALUES
(1,2024,0.00),
(2,2024,2450000.00),
(3,2024,3100000.00),
(4,2024,0.00),
(5,2024,0.00),
(6,2024,1950000.00),
(7,2024,0.00),
(8,2024,5200000.00);
set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

#1, Retrieve the plant name, country name, operator name, fuel category, fuel name,
#capacity (in MW), and commission year for all power plants without using table aliases.
#Sort the results in descending order by capacity.
select power_plants.PlantName,
power_plants.CapacityMW, power_plants.CommissionYear,
countries.CountryName, operators.OperatorName, 
fuel_types.FuelName, fuel_types.FuelCategory
from power_plants
inner join countries
	on power_plants.CountryCode = countries.CountryCode
inner join fuel_types
	on power_plants.FuelID = fuel_types.FuelID
inner join operators
	on power_plants.OperatorID = operators.OperatorID
order by CapacityMW desc;

#2, Retrieve the plant name, country code, calendar year, and annual generation
#(in GWh) for all power plants for the year 2024 without using table aliases.
#Sort the results in descending order by generation.
select power_plants.PlantName, 
countries.CountryCode, generation_records.year,
generation_records.generationgwh
from power_plants
inner join countries
	on power_plants.CountryCode = countries.CountryCode
inner join generation_records
	on power_plants.plantid = generation_records.plantid
where generation_records.year = 2024
order by generationgwh desc;

#3, Retrieve the plant name, country code, calendar year, annual generation (in GWh),
#and CO2 emissions (in tonnes) for all power plants for the year 2024 without using
#table aliases. Sort the results in ascending order by CO2 emissions.
select emission_metrics.co2emissionstonnes, 
countries.CountryCode, emission_metrics.year,
power_plants.PlantName, generation_records.generationgwh
from power_plants
inner join countries
	on power_plants.CountryCode = countries.CountryCode
inner join emission_metrics
	on power_plants.plantid = emission_metrics.plantid
inner join generation_records
	on power_plants.PlantID = emission_metrics.plantid
where emission_metrics.year = 2024
order by co2emissionstonnes asc;

#Write a SQL query using a Common Table Expression (CTE) to calculate the total cumulative power
 #generation (in GWh) for each operator across all available years without using table aliases. 
 #Retrieve the operator name, headquarters country, and their total generated power, and sort 
 #the results in descending order by total generation.
 
 with operator_generation as (
select power_plants.operatorid,
sum(generation_records.generationgwh) as totalgenerationgwh
from power_plants
join generation_records
	on power_plants.plantid = generation_records.plantid
group by power_plants.operatorid
)
select
operators.operatorname, operators.headquarterscountry,
operator_generation.totalgenerationgwh
from operator_generation
join operators
    on operator_generation.operatorid = operators.operatorid
order by operator_generation.totalgenerationgwh desc;

#5, Write a SQL query using two separate Common Table Expressions (CTEs)--one to calculate total power generation by
#country code and another to calculate total CO2 emissions by country code without using table aliases.
#Then, join these CTEs with the countries table to display the country name, total generation (in GWh),
#and total CO2 emissions (in tonnes). Sort the results in descending order by total generation.

 with power_country as
 (
	select power_plants.CountryCode, sum(generation_records.generationgwh) as gwhsum
    from power_plants
    inner join generation_records
		on power_plants.plantid = generation_records.plantid
	group by power_plants.CountryCode
),
emission_country as
(
	select power_plants.CountryCode, sum(emission_metrics.co2emissionstonnes) as emsum
    from power_plants
    inner join emission_metrics
		on power_plants.plantid = emission_metrics.plantid
	group by power_plants.CountryCode
)
select countries.CountryName, emission_country.emsum, 
power_country.gwhsum
from countries
inner join power_country
	on countries.CountryCode = power_country.CountryCode
inner join emission_country
	on countries.CountryCode = emission_country.CountryCode
order by power_country.gwhsum desc

 