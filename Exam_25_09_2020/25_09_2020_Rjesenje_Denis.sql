--1. Zadatak

create database ispit_25_09_2020
go

use ispit_25_09_2020
go



--2. Zadatak

create TABLE osoba
(
	osoba_id int constraint PK_osoba primary key,
	ime nvarchar(50),
	prezime nvarchar(50),
	tip_osobe nvarchar (2),
	kreditna_id int,
	tip_kreditne nvarchar(50),
	broj_kartice nvarchar(25),
	dtm_izdav date
) 



create TABLE kupac
(
	kupac_id int constraint PK_kupac primary key,
	osoba_id int,
	prodavnica_id int,
	br_racuna varchar(10)
	constraint FK_osoba_kupac foreign key (osoba_id) references osoba (osoba_id)
)


create TABLE kupovina
(
	kupovina_id int,
	detalj_id int,
	narudzba_id nvarchar(25),
	kreditna_id int,
	teritorija_id int,
	kupac_id int,
	kolicina int,
	cijena money,
	constraint PK_kupovina primary key (kupovina_id, detalj_id),
	constraint FK_prodaja_kupac foreign key (kupac_id) references kupac (kupac_id)
)








--3. Zadatak

--* paziti kod kreiranja tabela tacne podatke unijeti, kada insertujemo podatke moraju biti istog tipa kao u nasoj tabeli i ISTOG redoslijeda
insert INTO	osoba
select p.BusinessEntityID,
	   p.FirstName,
	   p.LastName,
	   p.PersonType,
	   cc.CreditCardID,
	   cc.CardType,
	   cc.CardNumber,
	   CONVERT(date,cc.ModifiedDate)
from AdventureWorks2017.Person.Person as p 
inner join AdventureWorks2017.Sales.PersonCreditCard as pcc on p.BusinessEntityID = pcc.BusinessEntityID
inner join AdventureWorks2017.Sales.CreditCard as cc on cc.CreditCardID = pcc.CreditCardID


--b)
insert into kupac
select c.CustomerID,
	   c.PersonID,
	   c.StoreID,
	   c.AccountNumber
from AdventureWorks2017.Sales.Customer as c
where c.PersonID > 300




--c)

insert into kupovina
select soh.SalesOrderID,
	   sod.SalesOrderDetailID,
	   soh.PurchaseOrderNumber,
	   soh.CreditCardID,
	   soh.TerritoryID,
	   soh.CustomerID,
	   sod.OrderQty,
	   sod.UnitPrice
from AdventureWorks2017.Sales.SalesOrderHeader as soh
inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
where soh.CustomerID < 29000








--4.Zadatak

--a)
go
create view view_ukupno
as
select k.osoba_id, SUM(kup.kolicina * kup.cijena) as ukupna_svota
from kupac as k 
inner join kupovina as kup on k.kupac_id = kup.kupac_id
group by k.osoba_id


select * from view_ukupno



--b)

--rjesimo svaki pojedinacno i onda ih spojimo u jedan rezultat uz pomoc union
select 'vece', COUNT(*)
from view_ukupno
where ukupna_svota > (select AVG(ukupna_svota) from view_ukupno)
union
select 'jednako', COUNT(*)
from view_ukupno
where ukupna_svota = (select AVG(ukupna_svota) from view_ukupno)
union
select 'manje', COUNT(*)
from view_ukupno
where ukupna_svota < (select AVG(ukupna_svota) from view_ukupno)






--5) Zadatak

--a)

--newid() funkcija kreira unikatnu generisanu vrijednost
--reverse funkcija koja obrne redoslijed svemu
--paziti na tip podatka koji zelimo, brojevi se moraju convertovati u nvarchar ako ih spajamo u string

alter table osoba
add lozinka as LEFT(newid(),2) + '_' + REVERSE(LEFT(ime,3)) + '_' +
	           REVERSE(LEFT(prezime,3)) + '_' +
			   CONVERT(nvarchar,YEAR(dtm_izdav)) + '_' + CONVERT(nvarchar,DAY(dtm_izdav)) + '_' + CONVERT(nvarchar,MONTH(dtm_izdav))
			   
select * from osoba



--b)
--kada se postavlja vrijednost onda ide update i set za kolonu koju zelimo
--ako nema uvjeta onda ce se primjeniti na svaki zapis
update kupac
set prodavnica_id = osoba_id + 1

select * from kupac








--6)

--a)
--ova procedura ce vrsiti update kolone narudzba_id
go
create procedure proc_narudzba
as
begin
	update kupovina
	set narudzba_id = 'n' + '_' + CONVERT(nvarchar,kupovina_id) + '_' + CONVERT(nvarchar,detalj_id)
end

exec proc_narudzba

select * from kupovina


--b)

--da bi dodali ogranicenje pisemo alter table i add constraint 
--ako je to ogranicenje provjera kolone onda pisemo check i uslov
alter table kupovina
add constraint CK_narudzba_id check (len(narudzba_id) <=20)








--7)


go
create procedure proc_klasa
as
begin
	select distinct 'klasa 1', cijena
	from kupovina
	where cijena between 0 and 999.99
	union
	select distinct 'klasa 2', cijena
	from kupovina
	where cijena between 1000 and 1999.99
	union
	select distinct 'klasa 3', cijena
	from kupovina
	where cijena between 2000 and 2999.99
	union
	select distinct 'klasa 4', cijena
	from kupovina
	where cijena between 3000 and 3999.99
end


exec proc_klasa









--8) Zadatak

--a)
go
create view view_tip
as
select o.tip_kreditne,
	   k.prodavnica_id,
	   COUNT(kup.kupovina_id) as prebrojano
from osoba as o
inner join kupac as k on o.osoba_id = k.osoba_id
inner join kupovina as kup on k.kupac_id = kup.kupac_id
group by o.tip_kreditne,k.prodavnica_id

select * from view_tip


--b)

--procedura treba da vrati koliko zapisa ima sa tom vrijednoscu "prebrojano"
go
create procedure proc_tip
(
	@prebrojano int
)
as
begin
	select prebrojano,COUNT(*)  as broj_zapisa
	from view_tip
	where prebrojano = @prebrojano
	group by prebrojano
end


exec proc_tip @prebrojano = 3
exec proc_tip @prebrojano = 30






--9) Zadatak

--podupit sluzi kao tabela samo jedinstvenih prezimena
--prebrojimo koliko tu ima zapisa
go
create procedure proc_prezime
as
begin
	select COUNT(podtab.prezime) as broj_jedinstvenih_prezimena 
	from (select distinct prezime from osoba) as podtab
end


exec proc_prezime




--10) Zadatak

--a)
select LEN(narudzba_id) as duzina_podatka,COUNT(*) as broj_pojavljivanja
from kupovina
group by LEN(narudzba_id)
having COUNT(*) >1000



--b)

--da bi promijenili vrijednost prvo moramo obrisati constraint koji smo prethodno kreirali jer ce duzina preci 20 karaktera
alter table kupovina
drop constraint CK_narudzba_id


--zatim promjeniti velicinu polja narudzba_id da moze sve stati
alter table kupovina
alter column narudzba_id nvarchar(50)


--kao zadnji korak update svih kolona cija je duzina 11(ima ispod 1000 ponavljanja dobijeno iz prethodnog upita)
update kupovina
set narudzba_id = narudzba_id + '_' + CONVERT(nvarchar,GETDATE())
where LEN(narudzba_id) = 11



select * from kupovina

