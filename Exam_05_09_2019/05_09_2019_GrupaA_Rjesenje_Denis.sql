
--1) Zadatak

--a)
create database ispit_05_09_2019_GrupaA
go

use ispit_05_09_2019_GrupaA
go


--b)
create table narudzba 
(
	narudzbaID int constraint PK_narudzbaID primary key,
	dtm_narudzbe date,
	dtm_isporuke date,
	prevoz money,
	klijentID nvarchar(5),
	klijent_naziv nvarchar(40),
	prevoznik_naziv nvarchar(40)
)


create table proizvod
(
	proizvodID int constraint PK_proizvodID primary key,
	mj_jedinica nvarchar(20),
	jed_cijena money,
	kateg_naziv nvarchar(15),
	dobavljac_naziv nvarchar(40),
	dobavljac_web text
)


create table narudzba_proizvod
(
	narudzbaID int not null,
	proizvodID int not null,
	uk_cijena money,
	constraint PK_narudzba_proizvodID primary key(narudzbaID,proizvodID),
	constraint FK_narudzbaID foreign key(narudzbaID) references narudzba(narudzbaID),
	constraint FK_proivodID foreign key(proizvodID) references proizvod(proizvodID)
)





--2) Zadatak

--a)
--strani kljuc u tabeli orders ShipVia je poveznik s tabelom Shippers
insert into narudzba
select o.OrderID,
	   o.OrderDate,
	   o.ShippedDate,
	   o.Freight,
	   c.CustomerID,
	   c.CompanyName,
	   s.CompanyName
from Northwind.dbo.Customers as c
inner join Northwind.dbo.Orders as o on c.CustomerID = o.CustomerID
inner join Northwind.dbo.Shippers as s on s.ShipperID = o.ShipVia



--b)
insert into proizvod
select p.ProductID,
	   p.QuantityPerUnit,
	   p.UnitPrice,
	   c.CategoryName,
	   s.CompanyName,
	   s.HomePage
from Northwind.dbo.Categories as c
inner join Northwind.dbo.Products as p on c.CategoryID = p.CategoryID
inner join Northwind.dbo.Suppliers as s on s.SupplierID = p.SupplierID


--c)
insert into narudzba_proizvod
select OrderID,
	   ProductID,
	   UnitPrice * Quantity as uk_cijena
from Northwind.dbo.[Order Details]
where Discount = 0






--3) Zadatak

--kod uslova provjerimo da li je najbliza zaokruzena cjelobrojna vrijednost ista kao i sam expression
--ako jest znaci da nema ostatka
go
create view view_kolicina 
as
select p.proizvodID,
	   p.kateg_naziv,
	   p.jed_cijena,
	   np.uk_cijena,
	   np.uk_cijena / p.jed_cijena as kolicina
from proizvod as p
inner join narudzba_proizvod as np on p.proizvodID = np.proizvodID
where FLOOR(np.uk_cijena / p.jed_cijena) = np.uk_cijena / p.jed_cijena

select * from view_kolicina






--4) Zadatak
go
create procedure usp_showCat
(
	@proizvod int = null,
	@kategorija nvarchar(15)= null,
	@cijena money = null,
	@ukupna_cijena money = null,
	@kolicina money = null
)
as
begin
	select * 
	from view_kolicina
	where @proizvod = proizvodID or
		  kateg_naziv = @kategorija or
		  jed_cijena = @cijena or
		  uk_cijena = @ukupna_cijena or
		  @kolicina = kolicina
end

exec usp_showCat @kategorija = 'Produce';
exec usp_showCat @kategorija = 'Beverages';














--5) Zadatak
go
create procedure usp_countByCateg
as
begin
	select kateg_naziv, COUNT(*) prebrojano_zapisa
	from view_kolicina
	group by kateg_naziv
end

exec usp_countByCateg;













--6) Zadatak

--a)
go
create view view_suma
as
select narudzbaID,SUM(uk_cijena) as suma_uk_cijene 
from narudzba_proizvod
group by narudzbaID

select  * from view_suma

--b)
select ROUND(AVG(suma_uk_cijene),2) as prosjecna_vrijednost_sume
from view_suma


--c)
select *,suma_uk_cijene - (select ROUND(AVG(suma_uk_cijene),2) from view_suma) as razlika_sumeIsrednje
from view_suma
where suma_uk_cijene > (select ROUND(AVG(suma_uk_cijene),2) from view_suma)












--7) Zadatak

--a)
alter table narudzba
add evid_br nvarchar(30)

select * from narudzba

--b)

go
create procedure usp_load_evidBr
as
begin
	update narudzba
	set evid_br = LEFT(newid(),30)
	where dtm_isporuke is null

	update narudzba
	set evid_br = convert(nvarchar,dtm_isporuke) + '_' + convert(nvarchar,dtm_narudzbe)
	where dtm_isporuke is not null
end

exec usp_load_evidBr;


select * from narudzba














--8) Zadatak

go
create procedure proc_pregled
as
begin
	select n.narudzbaID,
		   n.klijent_naziv,
		   p.proizvodID,
		   p.kateg_naziv,
		   p.dobavljac_naziv
	from proizvod as p
	inner join narudzba_proizvod as np on p.proizvodID = np.proizvodID
	inner join narudzba as n on n.narudzbaID = np.narudzbaID
	where CHARINDEX(' ',p.kateg_naziv) = 0 and CHARINDEX('/',p.kateg_naziv) = 0
end

exec proc_pregled;










--9) Zadatak

--jedna riječ
UPDATE proizvod
SET dobavljac_web = 'www.'+ dobavljac_naziv +'.com'
WHERE CHARINDEX (' ', dobavljac_naziv) = 0


--više riječi
UPDATE proizvod
SET dobavljac_web = 'www.'+ LEFT (dobavljac_naziv, (CHARINDEX (' ', dobavljac_naziv)-1))+'.com'

select * from proizvod
WHERE CHARINDEX (' ', dobavljac_naziv) >=0


select * from proizvod







--10) Zadatak 

--NIJE RADJENO!!










