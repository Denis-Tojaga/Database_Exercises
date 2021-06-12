--1) Zadatak
create database ispit_11_09_2020
go

use ispit_11_09_2020
go


--2)

create table radnik
(
	radnikID int constraint PK_radnikID primary key,
	drzavaID nvarchar(15),
	loginID nvarchar(256),
	sati_god_odmora int,
	sati_bolovanja int
)


create table nabavka
(
   nabavkaID int constraint PK_nabavkaID primary key,
   status int,
   nabavljacID int constraint FK_nabavljacID foreign key(nabavljacID) references radnik(radnikID),
   br_racuna nvarchar(15),
   naziv_nabavljaca nvarchar(50),
   kred_rejting int
)


create table prodaja
(
	prodavacID int constraint PK_prodavacID primary key,
	prod_kvota money,
	bonus money,
	proslogod_prodaja money,
	naziv_terit nvarchar(50)
)




--3) Zadatak

--a)
insert into radnik
select BusinessEntityID,NationalIDNumber,LoginID,VacationHours,SickLeaveHours
from AdventureWorks2017.HumanResources.Employee 

select * from radnik

--b)
insert into nabavka
select poh.PurchaseOrderID,
	   poh.Status,
	   poh.EmployeeID,
	   v.AccountNumber,
	   v.Name,
	   v.CreditRating
from AdventureWorks2017.Purchasing.PurchaseOrderHeader as poh 
inner join AdventureWorks2017.Purchasing.Vendor as v on poh.VendorID = v.BusinessEntityID


select * from nabavka



--c)

insert into prodaja
select distinct sp.BusinessEntityID,
	   sp.SalesQuota,
	   sp.Bonus,
	   sp.SalesLastYear,
	   st.Name
from AdventureWorks2017.Sales.SalesPerson as sp
inner join AdventureWorks2017.Sales.SalesTerritoryHistory as sth on sp.BusinessEntityID = sth.BusinessEntityID
inner join AdventureWorks2017.Sales.SalesTerritory as st on sth.TerritoryID = st.TerritoryID
where sp.BusinessEntityID != 277 and sp.BusinessEntityID != 275 and sp.BusinessEntityID != 282
order by sp.BusinessEntityID





--4) Zadatak

--a)
go
create view view_drzavaID
as
select n.nabavkaID,
	   r.loginID,
	   n.status,
	   n.naziv_nabavljaca,
	   n.kred_rejting
from radnik as r
inner join nabavka as n on r.radnikID = n.nabavljacID


select * from view_drzavaID

--b)

go
create view v_broj_nabavki
as
select kred_rejting,COUNT(*) as broj_obavljenih_nabavki
from view_drzavaID
group by kred_rejting


select * from v_broj_nabavki







--5) Zadatak

go
create procedure usp_proc
(
	@rejting int  = null
)
as
begin
	select n.kred_rejting,COUNT(*) as broj_obavljenih_nabavki
	from radnik as r
	inner join nabavka as n on r.radnikID = n.nabavljacID
	where n.kred_rejting = @rejting and n.status > 2
	group by kred_rejting
end

exec usp_proc @rejting = 3;
exec usp_proc @rejting = 5;



--6) Zadatak

--a)
go
create view nabavljaci_radnici
as
select n.naziv_nabavljaca,COUNT(*) as broj_radnika
from nabavka as n
inner join radnik as r on n.nabavljacID = r.radnikID
group by n.naziv_nabavljaca


select * from nabavljaci_radnici

--b)
go
create procedure usp_proc_broj_radnika
(
	@broj_radnika int = null
)
as
begin
	select * 
	from nabavljaci_radnici
	where broj_radnika = @broj_radnika and broj_radnika <50
end


exec usp_proc_broj_radnika @broj_radnika = 1;
exec usp_proc_broj_radnika @broj_radnika = 2;





--7) Zadatak

--a)
alter table radnik
add razlika_sati int
constraint DF_razlika default(0)


--b)

update radnik
set razlika_sati = sati_bolovanja - sati_god_odmora
where sati_bolovanja<sati_god_odmora

select * from radnik



--c)
go
create view view_sati
as
select radnikID, 'vise godisnjeg odmora' as poruka
from radnik
where sati_god_odmora > sati_bolovanja
union
select radnikID, 'vise bolovanja' as poruka
from radnik
where sati_god_odmora < sati_bolovanja


select * from view_sati










--8) Zadatak

--prvo prosirimo polje kolone drzavaID da moze stati generisani niz
alter table radnik
alter column drzavaID nvarchar(50)


--nakon toga ide update svih cija je duzina podatka neparan broj 
update radnik
set drzavaID = NEWID()
where len(drzavaID) % 2 != 0

select * from radnik



--9) Zadatak
go
create view view_sifra_transakc
as
select distinct n.naziv_nabavljaca,
	   SUBSTRING(loginID,CHARINDEX('\',loginID) + 1, LEN(loginID) - CHARINDEX('\',loginID) -1) + '_' + left(br_racuna,LEN(br_racuna) - 4) as sifra_transakc
from radnik as r
inner join nabavka as n on r.radnikID = n.nabavljacID


select * from view_sifra_transakc



--10) Zadatak

--NIJE RADJENO


