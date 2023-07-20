--check the data in the housing sheet
select top 100 * from housing;

--changing the date from DateTime format to Date format
update housing
set 
	SaleDate = cast(SaleDate as date)

update housing
set 
	SaleDate = Convert(date,SaleDate )

--The above update queries didn't work so I tried this: create new column, insert values, delete the original one
select SaleDate, cast(SaleDate as date) as Sdate from housing;

alter table housing add Sdate date;

update housing
	set 
	Sdate=cast(SaleDate as date)

alter table housing drop column SaleDate ;
select * from housing;



--Populate Property Address (Put value where PropertyAddress is null)

create table #PropAdd (ParcelID nvarchar(50), PropertyAddress varchar(100) )

insert into #PropAdd 
	select ParcelID , PropertyAddress from housing
		where PropertyAddress is not null 

select * from #PropAdd

update housing 
	set 
		housing.PropertyAddress=#PropAdd.PropertyAddress
		from housing
		Join #PropAdd
		On housing.ParcelID=#PropAdd.ParcelID;

select * from housing
where PropertyAddress is null;

drop table #PropAdd

--breaking down the address into individual columns (address, city, state)		
select * from housing

alter table housing add address varchar(50), city varchar(30), state varchar(25)

--check the location of comma in property address --> charIndex(',', PropertyAddress), 
--if its location > 0,
--select left of property address from the  position
--of comma --> Left(PropertyAddress, <position of comma -1>)

--substring to  select location of comma+1 to the len of string

UPDATE housing
SET 
    address = CASE 
                    WHEN CHARINDEX(',', PropertyAddress) > 0 THEN LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1)
                    ELSE PropertyAddress
                END,
    city = CASE 
                    WHEN CHARINDEX(',', PropertyAddress) > 0 THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) )
                    ELSE NULL
                END;

select address, city from housing

--another way of doing this

--first replace comma with dot/period as parse works only on dot, then select the first or second section (backwards) according to the column


Update housing
	set address=parsename(Replace(PropertyAddress, ',', '.'),2)

Update housing
	set city=parsename(Replace(PropertyAddress, ',', '.'),1)
		
select address, city from housing


--Separating the owners address 

alter table housing add OwnerStreet varchar(50), OwnerCity varchar(50), OwnerState varchar(20)

update housing 
set 
	OwnerStreet= parsename(replace(OwnerAddress, ',','.'),3)

update housing 
set 
	OwnerCity= parsename(replace(OwnerAddress, ',','.'),2)

update housing 
set 
	OwnerState= parsename(replace(OwnerAddress, ',','.'),1)



select * from housing

--changing yes no with Y and N

select SoldAsVacant, count(SoldAsVacant)
from housing
group by SoldAsVacant
order by 2;

update housing
set  SoldAsVacant=
	case
		when SoldAsVacant like 'Y%' Then 'Y'
		else 'N'
	end;

select SoldAsVacant from housing


--removing the duplicate data

WITH RemDupCTE AS (
  SELECT 
    *, 

	--define row number over the partitions of id and ref
    ROW_NUMBER() OVER (PARTITION BY ParcelID, LegalReference ORDER BY (SELECT NULL)) AS RN
  FROM Housing
)
delete from RemDupCTE where RN>1;



select * from (
 select *,ROW_NUMBER() over (partition by ParcelID, LegalReference  order by (ParcelID)) RN from housing) as okie
where RN>1


--remove unused columns

select * from housing

alter table housing drop column TaxDistrict, OwnerAddress, HalfBath, PropertyAddress,OwnerCity,Acreage;

