--1) Zadatak

create database ispit_20_06_2017
go


use ispit_20_06_2017
go









--2) Zadatak

--a)
create table Proizvodi
(
	ProizvodID int constraint PK_ProizvodID primary key,
	Sifra nvarchar(25) constraint UQ_Sifra unique not null,
	Naziv nvarchar(50) not null,
	Kategorija nvarchar(50) not null,
	Cijena decimal(8,2) not null
)

--b)
create table Narudzbe
(
	NarudzbaID int constraint PK_NarudzbaID primary key,
	BrojNarudzbe nvarchar(25) constraint UQ_BrojNarudzbe unique not null,
	Datum date not null,
	Ukupno decimal(8,2) not null
)


--c)
create table StavkeNarudzbe
(
	ProizvodID int,
	NarudzbaID int,
	Kolicina int not null,
	Cijena decimal(8,2) not null,
	Popust decimal(8,2) not null,
	Iznos decimal(8,2) NOT NULL
	constraint PK_StavkeNarudzbe primary key(ProizvodID,NarudzbaID),
	constraint FK_StavkeNarudzbe_ProizvodID foreign key(ProizvodID) references Proizvodi(ProizvodID),
	constraint FK_StavkeNarudzbe_NarudzbaID foreign key(NarudzbaID) references Narudzbe(NarudzbaID)
)









--3) Zadatak

--a)
insert into Proizvodi(ProizvodID,Sifra,Naziv,Kategorija,Cijena)
select p.ProductID,
	   p.ProductNumber,
	   p.Name,
	   pc.Name,
	   CONVERT(decimal(8,2),p.ListPrice) as cijena
from AdventureWorks2017.Production.Product as p
inner join AdventureWorks2017.Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on ps.ProductCategoryID = pc.ProductCategoryID




--b)
insert into Narudzbe
select soh.SalesOrderID,
	   soh.SalesOrderNumber,
	   soh.OrderDate,
	   soh.TotalDue
from AdventureWorks2017.Sales.SalesOrderHeader as soh
where YEAR(OrderDate) = 2014




--c)
insert into StavkeNarudzbe
select sod.ProductID,
	   sod.SalesOrderID,
	   sod.OrderQty,
	   CONVERT(decimal(8,2),sod.UnitPrice),
	   CONVERT(decimal(8,2),sod.UnitPriceDiscount),
	   sod.UnitPrice * sod.OrderQty as LineTotal
from AdventureWorks2017.Sales.SalesOrderDetail as sod
inner join AdventureWorks2017.Sales.SalesOrderHeader as soh on sod.SalesOrderID = soh.SalesOrderID
where YEAR(soh.OrderDate) = 2014


















--4) Zadatak
create table Skladista
(
	SkladisteID int constraint PK_SkladisteID primary key identity(1,1),
	Naziv nvarchar(50)
)


create table SkladistaProizvodi
(
	SkladisteID int,
	ProizvodID int,
	Kolicina int,
	constraint PK_SkladistaProizvodi primary key(SkladisteID,ProizvodID),
	constraint FK_SkladistaProizvodi_SkladisteID foreign key(SkladisteID) references Skladista(SkladisteID),
	constraint FK_SkladistaProizvodi_ProizvodID foreign key(ProizvodID) references Proizvodi(ProizvodID),
)


















--5) Zadatak

insert into Skladista
values('Skladiste1'),('Skladiste2'),('Skladiste3')

insert into SkladistaProizvodi
select (select SkladisteID from Skladista where SkladisteID=3) as SkladisteID,
	   ProizvodID,
	   0 as Kolicina
from Proizvodi 

select * from SkladistaProizvodi






















--6) Zadatak
go
create procedure proc_izmjenaStanja
(
	@SkladisteID int,
	@ProizvodID int,
	@Kolicina int
)
as
begin
	update SkladistaProizvodi
	set Kolicina = Kolicina + @Kolicina
	where ProizvodID = @ProizvodID and SkladisteID=@SkladisteID
end

exec proc_izmjenaStanja @SkladisteID = 1,@ProizvodID=680,@Kolicina=20;

select * from SkladistaProizvodi


















--7) Zadatak
--INDEKSI NISU RADJENI

























--8) Zadatak
--nakon poruke je potrebno uraditi rollback da se zapisi ne obrisu
go
create trigger tr_brisanje
on Proizvodi
instead of delete
as
begin
	print('Nije moguce brisati zapise u ovoj tabeli, triger aktivan!')
	rollback
end

delete from Proizvodi

select * from Proizvodi















--9) Zadatak

go
create view view_prodaja
as
select p.Sifra,
	   p.Naziv,
	   p.Cijena,
	   SUM(sn.Kolicina) as ukupna_kolicina,
	   SUM((sn.Cijena - (sn.Cijena * sn.Popust)) * sn.Kolicina) as ukupna_zarada
from Proizvodi as p
inner join StavkeNarudzbe as sn on p.ProizvodID = sn.ProizvodID
inner join Narudzbe as n on n.NarudzbaID=sn.NarudzbaID
group by p.Sifra,
	   p.Naziv,
	   p.Cijena

select * from view_prodaja















--10) Zadatak
go
create procedure proc_prikaz
(
	@SifraProizvoda nvarchar(25) = null
)
as
begin
	select ukupna_kolicina as ukupno_prodana_kolicina,
		   ukupna_zarada
	from view_prodaja
	where Sifra = @SifraProizvoda or @SifraProizvoda is null
end


exec proc_prikaz @SifraProizvoda = 'HL-U509-R';
exec proc_prikaz;











--11) Zadatak

--NE ZNAM LOGINE jos..









--12) Zadatak
--NIJE RADJENO
















