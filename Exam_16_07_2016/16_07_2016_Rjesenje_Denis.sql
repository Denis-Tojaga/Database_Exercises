
--1) Zadatak

create database ispit_16_7_2016
go



use ispit_16_7_2016
go



--a) 
create table Proizvodi
(
	ProizvodID int constraint PK_ProizvodID primary key identity(1,1),
	Sifra nvarchar(10) constraint UQ_Sifra unique not null,
	Naziv nvarchar(50) not null,
	Cijena decimal(8,2) not null
)


--b)
create table Skladista
(
	SkladisteID int constraint PK_SkladisteID primary key identity(1,1),
	Naziv nvarchar(50) not null,
	Oznaka nvarchar(10) constraint UQ_Oznaka unique not null,
	Lokacija nvarchar(50) not null
)



--c)

--vezu uspostavljamo kao vise na prema vise
--onemoguciti pojavljivanje istog proizvoda na skladistu realizujemo tako sto primarni kljuc postavljamo kao par SkladisteID,ProizvodID
create table SkladistaProizvodi
(
	ProizvodID int constraint FK_SkladistaProizvodi_ProizvodID foreign key(ProizvodID) references Proizvodi(ProizvodID),
	SkladisteID int constraint FK_SkladistaProizvodi_SkladisteID foreign key(SkladisteID) references Skladista(SkladisteID),
	Stanje decimal(8,2) not null,
	constraint PK_SkladistaProizvodi primary key(ProizvodID,SkladisteID)
)









--2) Zadatak
--a) 
insert into Skladista
values ('Skladiste1','SKL10','Mostar'),
	   ('Skladiste2','SKL20','Sarajevo'),
	   ('Skladiste3','SKL30','Berlin')

select * from Skladista



--b)
insert into Proizvodi
select top 10 p.ProductNumber,
			  p.Name,
			  p.ListPrice
from AdventureWorks2017.Production.Product as p
inner join AdventureWorks2017.Production.ProductSubcategory as ps on p.ProductSubcategoryID = ps.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on pc.ProductCategoryID = ps.ProductCategoryID
where pc.Name = 'Bikes'
order by ListPrice desc

select * from Proizvodi







--c) 
insert into SkladistaProizvodi
select ProizvodID,
	   (select SkladisteID from Skladista where SkladisteID = 1) as skladisteID,
	   100 as stanje
from Proizvodi

insert into SkladistaProizvodi
select ProizvodID,
	   (select SkladisteID from Skladista where SkladisteID = 2) as skladisteID,
	   100 as stanje
from Proizvodi


insert into SkladistaProizvodi
select ProizvodID,
	   (select SkladisteID from Skladista where SkladisteID = 3) as skladisteID,
	   100 as stanje
from Proizvodi













--3) Zadatak
go
create procedure proc_updateStanja
(
	@ProizvodID int,
	@SkladisteID int,
	@NovoStanje decimal(8,2)
)
as 
begin
	update SkladistaProizvodi
	set Stanje = Stanje + @NovoStanje
	where ProizvodID = @ProizvodID and SkladisteID = @SkladisteID
end

--testiranje
exec proc_updateStanja @ProizvodID = 1,@SkladisteID = 1,@NovoStanje = 50.00;

select * from SkladistaProizvodi

















--4) Zadatak
--NISU RADJENI INDEKSI



















--5) Zadatak
go
create view view_prikaz
as
select p.Sifra,
	   p.Naziv,
	   p.Cijena,
	   s.Oznaka,
	   s.Naziv as naziv_skladista,
	   s.Lokacija,
	   sp.Stanje
from Proizvodi as p
inner join SkladistaProizvodi as sp on p.ProizvodID = sp.ProizvodID
inner join Skladista as s on s.SkladisteID = sp.SkladisteID


















--6) Zadatak
go
create procedure proc_prikaz_proizvoda
(
	@Sifra nvarchar(10)
)
as
begin
	select Sifra,
		  Naziv,
		  Cijena,
		  SUM(Stanje) as ukupno_stanje_zaliha
	from view_prikaz
	where Sifra = @Sifra
	group by Sifra,
		  Naziv,
		  Cijena
end


--testiranje 
exec proc_prikaz_proizvoda @Sifra = 'BK-R93R-56';












--7) Zadatak
go
create procedure proc_unosNovogProizvoda
(
	@Sifra nvarchar(10),
	@Naziv nvarchar(50),
	@Cijena decimal(8,2)
)
as
begin
	insert into Proizvodi
	values (@Sifra,@Naziv,@Cijena)

	insert into SkladistaProizvodi
	values ((select top 1 ProizvodID from Proizvodi order by 1 desc),1,0)

	insert into SkladistaProizvodi
	values ((select top 1 ProizvodID from Proizvodi order by 1 desc),2,0)

	insert into SkladistaProizvodi
	values ((select top 1 ProizvodID from Proizvodi order by 1 desc),3,0)
end

--testiranje
exec proc_unosNovogProizvoda @Sifra='Sifra10',@Naziv='Mlijeko',@Cijena=15.00;
select * from Proizvodi
select * from SkladistaProizvodi





















--8) Zadatak
go 
create procedure proc_brisanje
(
	@Sifra nvarchar(10)
)
as
begin
	delete from SkladistaProizvodi
	where ProizvodID = (select ProizvodID from Proizvodi where Sifra = @Sifra)

	delete from Proizvodi
	where Sifra = @Sifra
end

--testiranje
exec proc_brisanje @Sifra = 'Sifra10';
select * from SkladistaProizvodi
select * from Proizvodi
















--9) Zadatak
go 
create procedure proc_pretraga
(
	@Sifra nvarchar(10) = null,
	@Oznaka nvarchar(10) = null,
	@Lokacija nvarchar(50) = null
)
as
begin
	select *
	from view_prikaz
	where (@Sifra is null or Sifra = @Sifra) and
		  (@Oznaka is null or Oznaka = @Oznaka) and
		  (@Lokacija is null or Lokacija = @Lokacija)
end



--testiranje 
exec proc_pretraga;
exec proc_pretraga @Sifra='BK-R93R-56';
exec proc_pretraga @Sifra ='BK-R93R-56',@Oznaka='SKL20';
exec proc_pretraga @Sifra ='BK-R93R-56',@Lokacija='Mostar';
exec proc_pretraga @Sifra ='BK-R93R-56',@Oznaka='SKL30' ,@Lokacija='Berlin';














--10) Zadatak

--NIJE RADJEN BACKUP
