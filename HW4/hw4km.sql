
set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

drop table if exists payloads;
drop table if exists missions;
drop table if exists rockets;
drop table if exists launch_sites;
drop table if exists organizations;
drop table if exists countries;

create table countries (
	CountryCode char(3) not null,
	CountryName varchar(100) not null,
	Continent varchar(50) not null,
	primary key (CountryCode)
);

create table organizations (
	OrgID int not null,
	OrgName varchar(150) not null,
	HeadquartersCountry char(3) not null,
	OrgType varchar(50) not null,
	primary key (OrgID),
	foreign key (HeadquartersCountry) references countries (CountryCode)
);

create table launch_sites (
	SiteID int not null,
	SiteName varchar(150) not null,
	CountryCode char(3) not null,
	Status varchar(50) not null,
	primary key (SiteID),
	foreign key (CountryCode) references countries (CountryCode)
);

create table rockets (
	RocketID int not null,
	RocketName varchar(100) not null,
	OrgID int not null,
	PayloadCapacityKg int not null,
	OperationalStatus varchar(50) not null,
	primary key (RocketID),
	foreign key (OrgID) references organizations (OrgID)
);

create table missions (
	MissionID int not null,
	MissionName varchar(100) not null,
	RocketID int not null,
	SiteID int not null,
	Destination varchar(50) not null,
	LaunchYear int not null,
	Outcome varchar(50) not null,
	primary key (MissionID),
	foreign key (RocketID) references rockets (RocketID),
	foreign key (SiteID) references launch_sites (SiteID)
);

create table payloads (
	PayloadID int not null,
	MissionID int not null,
	PayloadName varchar(150) not null,
	PayloadType varchar(50) not null,
	MassKg decimal(10,2) not null,
	primary key (PayloadID),
	foreign key (MissionID) references missions (MissionID)
);
#1

use hw4;
select missions.MissionName, missions.Destination, missions.LaunchYear,
missions.outcome, launch_sites.SiteName, organizations.Orgname, rockets.RocketName
from missions
join rockets
	on missions.RocketID = rockets.RocketID
join organizations
	on rockets.OrgID = organizations.OrgID
join launch_sites
	on launch_sites.SiteID = missions.SiteID
order by LaunchYear desc, MissionName asc;

#2

select missions.MissionName, rockets.RocketName, payloads.PayloadName,
payloads.PayloadType, payloads.MassKg
from payloads
join missions
	on payloads.MissionID = missions.MissionID
join rockets
	on missions.RocketID = rockets.RocketID
where missions.LaunchYear = 2024
order by payloads.MassKg desc;

#3 

select launch_sites.SiteName, missions.MissionName, rockets.RocketName,
missions.LaunchYear
from launch_sites
left join missions
	on launch_sites.SiteID = missions.SiteID
	and missions.LaunchYear = 2024
left join rockets
	on missions.RocketID = rockets.RocketID
order by launch_sites.SiteName asc;

#4

with org_payload_totals as (
	select rockets.OrgID, sum(payloads.MassKg) as TotalPayloadMassKg
	from payloads
	join missions
		on payloads.MissionID = missions.MissionID
	join rockets
		on missions.RocketID = rockets.RocketID
	group by rockets.OrgID
)
select organizations.OrgName, organizations.HeadquartersCountry,
organizations.OrgType, org_payload_totals.TotalPayloadMassKg
from organizations
join org_payload_totals
	on organizations.OrgID = org_payload_totals.OrgID
order by org_payload_totals.TotalPayloadMassKg desc;

#5

with country_missions as (
	select launch_sites.CountryCode, count(missions.MissionID) as TotalMissions
	from missions
	join launch_sites
		on missions.SiteID = launch_sites.SiteID
	group by launch_sites.CountryCode
),
country_payloads as (
	select launch_sites.CountryCode, sum(payloads.MassKg) as TotalPayloadMassKg
	from payloads
	join missions
		on payloads.MissionID = missions.MissionID
	join launch_sites
		on missions.SiteID = launch_sites.SiteID
	group by launch_sites.CountryCode
)
select countries.CountryName, country_missions.TotalMissions,
country_payloads.TotalPayloadMassKg
from countries
join country_missions
	on countries.CountryCode = country_missions.CountryCode
join country_payloads
	on countries.CountryCode = country_payloads.CountryCode
order by country_payloads.TotalPayloadMassKg desc;