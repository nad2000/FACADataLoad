SELECT * FROM `cdrg_alpha`.`orgs`;

DELETE FROM orgs 
WHERE org_created > '2011-05-20';

select count(*), occupationoraffiliation from raw_faca
group by occupationoraffiliation
order by 1 desc;
/*
University of Michigan
University of Washington
*/

select agencyabbr, count(*) from (
select  distinct committeename, agencyabbr from raw_faca ) as d group by agencyabbr having count(*) >1;


select TRIM(SUBSTRING_INDEX( '1111 aaaa fdksfj dfksdfj',' ',1));