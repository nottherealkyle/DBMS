use example_desktop;
select * from pastries;
select category, count(name),
    avg(price)
    from pastries
    group by category;
    
select * from baristas;
select experience_level, count(experience_level)
from baristas
group by experience_level;

    
select * from shops;
select city, count(city)
from shops
group by city;

select * from pastries;
select category, MAX(price) 
from pastries
group by category;

select * from offers;
select shopID, count(pastryID)
from offers
group by shopID;

select * from pastries;

select name, category, price
from pastries x
where price = (
    select MAX(price)
    from pastries
    where category = x.category
);

select * from offers;
select distinct x.shopID
from offers x
join pastries y
	on x.pastryID = y.pastryID
where y.price > (
	select AVG(price)
    from pastries
    );
    
select shopID, pastryID
from offers
where date_added = (
    select MIN(date_added)
    from offers
);

select shopID
from offers
group by shopID
having count(pastryID) = (
    select MAX(pastry_count)
    from (
        select count(pastryID) as pastry_count
        from offers
        group by shopID
    ) as shop_counts
);
   
select name
from baristas
where baristaID in (
    select baristaID
    from employs
    where shopID in (
        select shopID
        from shops
        where city = 'Seattle'
    )
);