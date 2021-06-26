
--1) Zadatak

--a)
create database ispit_05_09_2019_GrupaB
go

use ispit_05_09_2019_GrupaB
go


--b)
create table produkt
(
	produktID int constraint PK_produktID primary key,
	jed_cijena money,
	kateg_naziv nvarchar(15),
	mj_jedinica nvarchar(20),
	dobavljac_naziv nvarchar(40),
	dobavljac_post_br nvarchar(10)
)

create table narudzba
(
	narudzbaID int constraint PK_narudzbaID primary key,
	dtm_narudzbe date,
	dtm_isporuke date,
	grad_isporuke nvarchar(15),
	klijentID nvarchar(5),
	klijent_naziv nvarchar(40),
	prevoznik_naziv nvarchar(40)
)


create table narudzba_produkt
(
	narudzbaID int not null,
	produktID int not null, 
	uk_cijena money,
	constraint PK_narudzba_produktID primary key(narudzbaID,produktID),
	constraint FK_narudzbaID foreign key(narudzbaID) references narudzba(narudzbaID),
	constraint FK_produktID foreign key(produktID) references produkt(produktID)
)



















--2) Zadatak

--a)
insert into produkt
select p.ProductID,
	   p.UnitPrice,
	   c.CategoryName,
	   p.QuantityPerUnit,
	   s.CompanyName,
	   s.PostalCode
from Northwind.dbo.Categories as c
inner join Northwind.dbo.Products as p on c.CategoryID = p.CategoryID
inner join Northwind.dbo.Suppliers as s on s.SupplierID = p.SupplierID


--b)
insert into narudzba
select o.OrderID,
	   o.OrderDate,
	   o.ShippedDate,
	   o.ShipCity,
	   c.CustomerID,
	   c.CompanyName,
	   s.CompanyName
from Northwind.dbo.Shippers as s
inner join Northwind.dbo.Orders as o on s.ShipperID = o.ShipVia
inner join Northwind.dbo.Customers as c on c.CustomerID = o.CustomerID



--c)
insert into narudzba_produkt
select OrderID,ProductID, UnitPrice * Quantity as uk_cijena 
from Northwind.dbo.[Order Details]
where Discount = 0.05















--3) Zadatak

--a)
go
create view view_uk_cijena
as
select n.narudzbaID,
	   n.klijentID,
	   FLOOR(np.uk_cijena) as uk_cijena_cijeli_dio,
	   convert(int,RIGHT(np.uk_cijena, LEN(np.uk_cijena) - CHARINDEX('.',np.uk_cijena))) as uk_cijena_feninzi
from narudzba as n
inner join narudzba_produkt as np on n.narudzbaID = np.narudzbaID

select * from view_uk_cijena



--b)
--na cijeli dio trenutne cijene dodamo 1 i to ce znaciti da su zaokruzene na vecu vrijednost
--jer se u tabeli nalaze sve one sa feninzima iznad 49
select *,
	   uk_cijena_cijeli_dio + 1 as uk_cijena_nova
into nova_uk_cijena
from view_uk_cijena
where uk_cijena_feninzi>49

select * from nova_uk_cijena













--4) Zadatak

go
create procedure usp_getAllBy
(
	@narudzbaID int = null,
	@klijentID nvarchar(5) = null
)
as
begin
	select * 
	from nova_uk_cijena
	where narudzbaID = @narudzbaID or klijentID = @klijentID
end

exec usp_getAllBy @narudzbaID = 10730;
exec usp_getAllBy @klijentID = 'ERNSH';













--5) Zadatak

go
create procedure proc_post_br
as
begin
	select dobavljac_post_br, COUNT(*) as prebrojano_zapisa
	from produkt
	where LEFT(dobavljac_post_br,1) like '[0-9]'
	group by dobavljac_post_br
end

exec proc_post_br;



















--6) Zadatak
--a)
go
create view view_prebrojano
as
select klijent_naziv,COUNT(*) as prebrojano
from narudzba
group by klijent_naziv


--b)
select MAX(prebrojano) as maksimalna_vr from view_prebrojano


--c)
select klijent_naziv,prebrojano, (select MAX(prebrojano) as maksimalna_vr from view_prebrojano) - prebrojano as razlika
from view_prebrojano
where prebrojano !=  (select MAX(prebrojano) as maksimalna_vr from view_prebrojano) - prebrojano 



















--7) Zadatak

--a)
alter table produkt
add lozinka nvarchar(20)


--b)
go
create procedure proc_puni_lozinku
as
begin
	update produkt
	set lozinka = case 
					  when dobavljac_post_br not like '[A-Z]%' and dobavljac_post_br not like '%[A-Z]%' and dobavljac_post_br not like '%[A-Z]%' 
					  then REVERSE(RIGHT(mj_jedinica,4) + RIGHT(dobavljac_post_br,4))
					  when dobavljac_post_br like '[A-Z]%' and dobavljac_post_br like '%[A-Z]%' and dobavljac_post_br like '%[A-Z]%' 
					  then REVERSE(LEFT(newid(),20))
				   end
end

exec proc_puni_lozinku;

select * from produkt















--8) Zadatak

--a)
go
create view view_narudzbe
as
select p.produktID,
	   p.dobavljac_naziv,
	   n.grad_isporuke,
	   DATEDIFF(DAY,n.dtm_narudzbe,n.dtm_isporuke) as period_do_isporuke
from produkt as p
inner join narudzba_produkt as np on p.produktID = np.produktID
inner join narudzba as n on n.narudzbaID = np.narudzbaID
where DATEDIFF(DAY,n.dtm_narudzbe,n.dtm_isporuke) < 29


--b)
select * into isporuka
from view_narudzbe

select * from isporuka


















--9) Zadatak

--a)
alter table isporuka
add red_br_sedmice nvarchar(10)

select * from isporuka



--b)
go
create procedure proc_upd_sedmice
as
begin
	update isporuka
	set red_br_sedmice = case 
				         when period_do_isporuke between 1 and 7 then 'prva'
						 when period_do_isporuke between 8 and 14 then 'druga'
						 when period_do_isporuke between 15 and 21 then 'treca'
						 when period_do_isporuke between 22 and 28 then 'cetvrta'
						 end
end

exec proc_upd_sedmice;
select * from isporuka




--c)
select red_br_sedmice,COUNT(*) as prebrojano
from isporuka
group by red_br_sedmice




















