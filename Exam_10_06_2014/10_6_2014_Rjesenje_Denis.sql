--1) Zadatak

create database ispit_10_06_2014
go


use ispit_10_06_2014
go


--a)
create table Klijenti
(
	KlijentID int constraint PK_KlijentID primary key identity(1,1),
	Ime nvarchar(50) not null,
	Prezime nvarchar(50) not null,
	Grad nvarchar(50) not null,
	Email nvarchar(50) not null,
	Telefon nvarchar(50) not null
)


--b) 
create table Racuni
(
	RacunID int constraint PK_RacunID primary key identity(1,1),
	KlijentID int constraint FK_KlijentID foreign key(KlijentID) references Klijenti(KlijentID),
	DatumOtvaranja date not null,
	TipRacuna nvarchar(50) not null,
	BrojRacuna nvarchar(16) not null,
	Stanje decimal(8,2) not null
)



--c)
create table Transakcije
(
	TransakcijaID int constraint PK_TransakcijaID primary key identity(1,1),
	RacunID int constraint FK_RacunID foreign key(RacunID) references Racuni(RacunID),
	Datum datetime not null,
	Primatelj nvarchar(50) not null,
	BrojRacunaPrimatelja nvarchar(16) not null,
	MjestoPrimatelja nvarchar(50) not null,
	AdresaPrimatelja nvarchar(50),
	Svrha nvarchar(200),
	Iznos decimal(8,2) not null
)
















--2) Zadatak

--INDEKSI NISU RADJENI

















--3) Zadatak
go
create procedure usp_dodajRacun
(
	@KlijentID int,
	@DatumOtvaranja date,
	@TipRacuna nvarchar(50),
	@BrojRacuna nvarchar(16),
	@Stanje decimal(8,2)
)
as
begin
	insert into Racuni
	values (@KlijentID,@DatumOtvaranja,@TipRacuna,@BrojRacuna,@Stanje)
end






















--4) Zadatak
--a)
insert into Klijenti
select LEFT(c.ContactName,CHARINDEX(' ',c.ContactName)) as Ime,
	   SUBSTRING(c.ContactName,CHARINDEX(' ',c.ContactName),LEN(c.ContactName)) as Prezime,
	   c.City,
	   REPLACE(c.ContactName,' ','.') + '@northwind.ba' as Email,
	   c.Phone
from Northwind.dbo.Customers as c
inner join Northwind.dbo.Orders as o on c.CustomerID = o.CustomerID
where YEAR(o.OrderDate) = 1996







--b)
exec usp_dodajRacun @KlijentID =1,@DatumOtvaranja = '2021-5-1',@TipRacuna ='tekuci',@BrojRacuna='111222333444',@Stanje = 250.00;
exec usp_dodajRacun @KlijentID =5,@DatumOtvaranja = '2018-5-1',@TipRacuna ='devizni',@BrojRacuna='111555333444',@Stanje = 50.00;
exec usp_dodajRacun @KlijentID =3,@DatumOtvaranja = '2016-5-1',@TipRacuna ='devizni',@BrojRacuna='111777333444',@Stanje = 30.00;
exec usp_dodajRacun @KlijentID =6,@DatumOtvaranja = '2020-5-1',@TipRacuna ='tekuci',@BrojRacuna='111222888444',@Stanje = 2220.00;
exec usp_dodajRacun @KlijentID =77,@DatumOtvaranja = '2018-5-1',@TipRacuna ='devizni',@BrojRacuna='444222333444',@Stanje = 210.00;
exec usp_dodajRacun @KlijentID =123,@DatumOtvaranja = '2021-5-1',@TipRacuna ='studentski',@BrojRacuna='123222333444',@Stanje = 1250.00;
exec usp_dodajRacun @KlijentID =26,@DatumOtvaranja = '2016-5-1',@TipRacuna ='tekuci',@BrojRacuna='5323222333444',@Stanje = 10250.00;
exec usp_dodajRacun @KlijentID =54,@DatumOtvaranja = '2021-5-1',@TipRacuna ='studentski',@BrojRacuna='111226443444',@Stanje = 10.00;
exec usp_dodajRacun @KlijentID =45,@DatumOtvaranja = '2016-5-1',@TipRacuna ='studentski',@BrojRacuna='175522333444',@Stanje = 2000.00;
exec usp_dodajRacun @KlijentID =71,@DatumOtvaranja = '2020-5-1',@TipRacuna ='devizni',@BrojRacuna='111112333444',@Stanje = 5000.00;

select * from Racuni











--c)
--rucno treba mijenjati RacunID (za svaki odozgo dodati po 10)
insert into Transakcije
select top 10 (select RacunID from Racuni where RacunID = 10),
	   o.OrderDate,
	   o.ShipName,
	   o.OrderID + '00000123456' as BrojRacunaPrimatelja,
	   o.ShipCity,
	   o.ShipAddress,
	   null,
	   od.UnitPrice * od.Quantity as ukupan_iznos
from Northwind.dbo.Orders as o 
inner join Northwind.dbo.[Order Details] as od on o.OrderID = od.OrderID
order by newid()


select * from Transakcije



























--5) Zadatak
update Racuni
set Stanje = Stanje + 500
where KlijentID in (select KlijentID from Klijenti where Grad = 'London') and
	  MONTH(DatumOtvaranja) = 5 

select * from Racuni












--6) Zadatak
go
create view view_prikazRacuna
as
select k.Ime + '.' + k.Prezime as imePrezime,
	   k.Grad,
	   k.Email,
	   k.Telefon,
	   r.TipRacuna,
	   r.BrojRacuna,
	   r.Stanje,
	   t.Primatelj,
	   t.BrojRacunaPrimatelja,
	   t.Iznos
from Klijenti as k
inner join Racuni as r on k.KlijentID = r.KlijentID
inner join Transakcije as t on r.RacunID = t.RacunID

select * from view_prikazRacuna





















--7) Zadatak

go
create procedure usp_prikazVlasnikaRacuna
(
	@BrojRacuna nvarchar(16) = null
)
as
begin
	select isnull(imePrezime,'N/A') as vlasnik_racuna,
		   isnull(BrojRacuna,'N/A') as brojracuna,
		   Stanje,
		   SUM(Iznos) as ukupan_iznos_transakcija
	from view_prikazRacuna
	where BrojRacuna = @BrojRacuna or @BrojRacuna is null
	group by isnull(imePrezime,'N/A'),
		      isnull(BrojRacuna,'N/A'),
			  Stanje
end 		

--testiranje	
exec usp_prikazVlasnikaRacuna @BrojRacuna = '111777333444';
exec usp_prikazVlasnikaRacuna;





















--8) Zadatak
go
create procedure usp_brisanje
(
	@KlijentID int
)
as
begin
	delete from Transakcije
	where RacunID in (select RacunID from Racuni where KlijentID = @KlijentID)

	delete from Racuni
	where KlijentID = @KlijentID

	delete from Klijenti
	where KlijentID = @KlijentID
end

--testiranje
exec usp_brisanje @KlijentID = 77;
select * from Transakcije
select * from Racuni
select * from Klijenti




















--9) Zadatak
go
create procedure usp_updateStanja
(
	@Grad nvarchar(50),
	@Mjesec int,
	@Stanje decimal(8,2)
)
as
begin
	update Racuni
	set Stanje = Stanje + @Stanje
	where KlijentID in (select KlijentID from Klijenti where Grad =  @Grad) and
		  MONTH(DatumOtvaranja) = @Mjesec	
end

--testiranje
exec usp_updateStanja @Grad = 'Lulea',@Mjesec=5,@Stanje=10000;

select * from Racuni

select *
from Klijenti
where KlijentID = 5
























--10) Zadatak
--BACKUP NIJE RADJEN

