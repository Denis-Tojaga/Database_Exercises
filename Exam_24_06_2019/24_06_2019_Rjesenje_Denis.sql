--1) Zadatak


--a)
create database ispit_24_06_2019
go
use ispit_24_06_2019
go


--b)

create table narudzba 
(
	NarudzbaID int constraint PK_NarudzbaID primary key,
	Kupac nvarchar(40),
	PunaAdresa nvarchar(80),
	DatumNarudzbe date,
	Prevoz money,
	Uposlenik nvarchar(40), 
	GradUposlenika nvarchar(30), 
	DatumZaposlenja date, 
	BrGodStaza int
)



create table proizvod
(
	ProizvodID int constraint PK_ProizvodID primary key,
	NazivProizvoda nvarchar(40),
	NazivDobavljaca nvarchar(40),
	StanjeNaSklad int,
	NarucenaKol int
)




create table detalji_narudzbe
(
	NarudzbaID int not null,
	ProizvodID int not null,
	CijenaProizvoda money,
	Kolicina int not null,
	Popust real
	constraint PK_narudzba_proizvod primary key(NarudzbaID,ProizvodID),
	constraint FK_narudzbaID foreign key(NarudzbaID) references narudzba(NarudzbaID),
	constraint FK_proizvodID foreign key(ProizvodID) references proizvod(ProizvodID)
)












--2) Zadatak

--a)
insert into narudzba
select o.OrderID,
	   c.CompanyName,
	   c.Address + '_' + c.PostalCode + '_' + c.City as PunaAdresa,
	   o.OrderDate,
	   o.Freight,
	   e.FirstName + ' ' + e.LastName as Uposlenik,
	   e.City,
	   e.HireDate,
	   DATEDIFF(YEAR,e.HireDate,GETDATE()) as BrGodStaza
from Northwind.dbo.Employees as e
inner join Northwind.dbo.Orders as o on e.EmployeeID = o.EmployeeID
inner join Northwind.dbo.Customers as c on c.CustomerID = o.CustomerID




--b)
insert into proizvod
select p.ProductID,
	   p.ProductName,
	   (select s.CompanyName
	   from Northwind.dbo.Suppliers as s
	   where s.SupplierID = p.SupplierID) as Companyname,
	   p.UnitsInStock,
	   p.UnitsOnOrder
from Northwind.dbo.Products as p
where p.SupplierID in (select SupplierID from Northwind.dbo.Suppliers)






--c)
insert into detalji_narudzbe
select OrderID,
       ProductID,
	   FLOOR(UnitPrice) as CijenaProizvoda,
	   Quantity,
	   Discount
from Northwind.dbo.[Order Details]














--3) Zadatak

--a)
--kod dodavanja kolone i ujedno neke provjere samo se nastavi poslije tipa podatka constraint i koje je ogranicenje
--ogranicenje mora obavezno stajati u zagradi
alter table narudzba
add SifraUposlenika nvarchar(20) constraint CK_SifraUposlenika check (len(SifraUposlenika) = 15)


select * from narudzba




--b)

update narudzba
set SifraUposlenika = REVERSE(LEFT(GradUposlenika,4) + ' ' + LEFT(DatumZaposlenja,10))

select * from narudzba




--c) 
update narudzba
set SifraUposlenika = LEFT(newid(),15)
where RIGHT(GradUposlenika,1) = 'd'

select * from narudzba





