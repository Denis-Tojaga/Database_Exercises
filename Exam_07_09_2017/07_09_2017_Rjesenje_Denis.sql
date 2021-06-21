--1) Zadatak

create database ispit_07_09_2017
go


use ispit_07_09_2017
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
create procedure proc_noviRacun
(
	@KlijentID int,
	@TipRacuna nvarchar(50),
	@BrojRacuna nvarchar(16),
	@Stanje decimal(8,2)
)
as
begin
	insert into Racuni(KlijentID,DatumOtvaranja,TipRacuna,BrojRacuna,Stanje)
	values (@KlijentID,GETDATE(),@TipRacuna,@BrojRacuna,@Stanje)
end














--4) Zadatak

--a)
insert into Klijenti
select LEFT(c.ContactName,CHARINDEX(' ',c.ContactName)) as ime,
	   RIGHT(c.ContactName,LEN(c.ContactName) - CHARINDEX(' ',c.ContactName)) as prezime,
	   c.City as grad,
	   REPLACE(c.ContactName,' ','.') + '@northwind.ba' as email,
	   c.Phone
from Northwind.dbo.Customers as c
inner join Northwind.dbo.Orders as o on c.CustomerID = o.CustomerID
where YEAR(o.OrderDate) = 1996



--b)
exec proc_noviRacun @KlijentID = 1,@TipRacuna ='Tekuci',@BrojRacuna = '133312211112222',@Stanje=50.00;
exec proc_noviRacun @KlijentID = 1,@TipRacuna ='Kreditni',@BrojRacuna = '1333777711112222',@Stanje=110.00;
exec proc_noviRacun @KlijentID = 2,@TipRacuna ='Tekuci',@BrojRacuna = '1333444444442222',@Stanje=500.00;
exec proc_noviRacun @KlijentID = 3,@TipRacuna ='Kreditni',@BrojRacuna = '1333444411119999',@Stanje=1990.00;
exec proc_noviRacun @KlijentID = 4,@TipRacuna ='Kreditni',@BrojRacuna = '1333444418888222',@Stanje=20000.00;
exec proc_noviRacun @KlijentID = 5,@TipRacuna ='Kreditni',@BrojRacuna = '1337777411112222',@Stanje=40.00;
exec proc_noviRacun @KlijentID = 6,@TipRacuna ='Kreditni',@BrojRacuna = '1333444411112222',@Stanje=310.00;
exec proc_noviRacun @KlijentID = 2,@TipRacuna ='Tekuci',@BrojRacuna = '1312344411112222',@Stanje=650.00;
exec proc_noviRacun @KlijentID = 5,@TipRacuna ='Tekuci',@BrojRacuna = '13354444411112222',@Stanje=580.00;
exec proc_noviRacun @KlijentID = 8,@TipRacuna ='Tekuci',@BrojRacuna = '4333444411112222',@Stanje=5900.00;
exec proc_noviRacun @KlijentID = 10,@TipRacuna ='Tekuci',@BrojRacuna = '1335555411112222',@Stanje=610.00;

select * from Racuni









--c)
--kao prvu kolonu cemo rucno izabrati RacunID i pokrenuti insert za svaki racunID (11 puta) tako da u Transakcijama treba biti 110 zapisa
--ako neku kolonu izostavljamo prilikom importa podataka onda je potrebno u zaglavlju specificirati tacno koje dodajemo
--random odabir se vrsi preko order by newid()
insert into Transakcije(RacunID,Datum,Primatelj,BrojRacunaPrimatelja,MjestoPrimatelja,AdresaPrimatelja,Iznos)
select top 10 (select RacunID from Racuni where RacunID = 11) as RacunID,
			  o.OrderDate,
			  o.ShipName,
			  o.OrderID + '00000123456' as brojRacunaPrimatelja,
			  o.ShipCity,
			  o.ShipAddress,
			  od.UnitPrice * od.Quantity as iznos
from Northwind.dbo.Orders as o
inner join Northwind.dbo.[Order Details] as od on o.OrderID = od.OrderID
order by NEWID()


select * from Transakcije






















--5) Zadatak
--Da bi uspostavili uslov da su klijenti iz Londona potrebno je da se KlijentID trenutnog zapisa Racuna nalazi u listi klijenata
--koje vrati podupit koji vraca listu KlijentID-jeva koji su iz Londona

update Racuni
set Stanje = Stanje + 500
where KlijentID in (select KlijentID from Klijenti where Grad = 'London') and MONTH(DatumOtvaranja) = 6

select * from Racuni

















--6) Zadatak
go
create view view_klijenti
as
select k.Ime +'.' + k.Prezime as imePrezime,
	   k.Grad as grad,
	   k.Email as email,
	   k.Telefon as telefon,
	   r.TipRacuna as tipRacuna,
	   r.BrojRacuna as brojRacuna,
	   r.Stanje as stanje,
	   tr.BrojRacunaPrimatelja as primatelj,
	   tr.Iznos as vrijednostTransakcije
from Klijenti as k
inner join Racuni as r on k.KlijentID = r.KlijentID
inner join Transakcije as tr on r.RacunID = tr.RacunID

select * from view_klijenti


















--7) Zadatak
go
create procedure proc_vlasnikRacuna
(
	@BrojRacuna nvarchar(16) = null
)
as
begin
	select	isnull(imePrezime,'N/A') as vlasnikRacuna,
		    isnull(grad,'N/A') as grad,
			isnull(telefon,'N/A') as telefon,
			isnull(brojRacuna,'N/A')as brojRacuna,
			isnull(convert(nvarchar,stanje),'N/A') as stanje,
			isnull(convert(nvarchar,SUM(vrijednostTransakcije)),'N/A') as suma_transakcija
	from view_klijenti
	where brojRacuna = @BrojRacuna 
	group by imePrezime,
		    grad,
			telefon,
			brojRacuna,
			stanje
end

exec proc_vlasnikRacuna @BrojRacuna = '133312211112222';




















--8) Zadatak
go
create  procedure proc_brisanje
(
	@KlijentID int
)
as
begin
	--prvo se brise strani kljuc u transakcijama
	delete from Transakcije
	where RacunID in (select RacunID from Racuni where KlijentID = @KlijentID)

	--zatim se obrise strani kljuc u racunima
	delete from Racuni
	where KlijentID in (select KlijentID from Klijenti where KlijentID = @KlijentID)

	--na kraju se direktno brise iz tabele
	delete from Klijenti
	where KlijentID = @KlijentID
end


--treba obrisati 20 zapisa iz transakcije(gdje se nalaze racuniID koje drzi klijent sa ID =2), 2 zapisa iz racuna, i 1 zapis iz Klijenata
exec proc_brisanje @KlijentID = 2;

select * from Klijenti
select * from Racuni
select * from Transakcije












--9) Zadatak

--poveca Stanje svim klijentima ciji grad i mjesec odgovaraju parametrima
go
create procedure proc_updateStanja
(
	@Grad nvarchar(50),
	@Mjesec int,
	@Uplata decimal(8,2)
)
as
begin
	update Racuni
	set Stanje = Stanje + @Uplata
	where KlijentID in (select KlijentID from Klijenti where Grad = @Grad and MONTH(DatumOtvaranja) = @Mjesec)
end

exec proc_updateStanja @Grad ='Lulea',@Mjesec = 6, @Uplata = 500;



















