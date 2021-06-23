
--1) Zadatak
create database ispit_05_09_2016
go


use ispit_05_09_2016
go






--a)
create table Klijenti
(
	KlijentID int constraint PK_KlijentID primary key identity(1,1),
	Ime nvarchar(30) not null,
	Prezime nvarchar(30) not null,
	Telefon nvarchar(20) not null,
	Mail nvarchar(50) constraint UQ_Mail unique not null,
	BrojRacuna nvarchar(15) not null,
	KorisnickoIme nvarchar(20) not null,
	Lozinka nvarchar(20) not null
)


--b) 
create table Transakcije
(
	TransakcijaID int constraint PK_TransakcijaID primary key identity(1,1),
	Datum datetime not null,
	TipTransakcije nvarchar(30) not null,
	PosiljalacID int constraint FK_PosiljalacID foreign key(PosiljalacID) references Klijenti(KlijentID) not null,
	PrimalacID int constraint FK_PrimalacID foreign key(PrimalacID) references Klijenti(KlijentID) not null,
	Svrha nvarchar(50) not null, 
	Iznos decimal(8,2) not null
)















KlijentID int constraint PK_KlijentID primary key identity(1,1),
	Ime nvarchar(30) not null,
	Prezime nvarchar(30) not null,
	Telefon nvarchar(20) not null,
	Mail nvarchar(50) constraint UQ_Mail unique not null,
	BrojRacuna nvarchar(15) not null,
	KorisnickoIme nvarchar(20) not null,
	Lozinka nvarchar(20) not null

--2) 

--a)
--jer ima kolona koja ima vise karaktera nego sto je definisano u tabeli 
--potrebno je uraditi convert u taj tacan broj da bi se moglo pohraniti
--error.log ( String or binary data would be truncated )

insert into Klijenti(Ime,Prezime,Telefon,Mail,BrojRacuna,KorisnickoIme,Lozinka)
select p.FirstName,
	   p.LastName,
	   pp.PhoneNumber,
	   ea.EmailAddress,
	   c.AccountNumber,
	   CONVERT(nvarchar(20),p.FirstName + '.' + p.LastName) as korisnickoIme,
	   RIGHT(pas.PasswordHash,8) as password
from AdventureWorks2017.Sales.Customer as c
inner join AdventureWorks2017.Person.Person as p on c.PersonID = p.BusinessEntityID
inner join AdventureWorks2017.Person.PersonPhone as pp on p.BusinessEntityID = pp.BusinessEntityID
inner join AdventureWorks2017.Person.EmailAddress as ea on p.BusinessEntityID = ea.BusinessEntityID
inner join AdventureWorks2017.Person.Password as pas on p.BusinessEntityID = pas.BusinessEntityID


select * from Klijenti


--b)
insert into Transakcije
values (GETDATE(),'Uplata1',19570,19575,'Skolarina',800.00),
	   (GETDATE(),'Uplata2',19573,19585,'Putarina',50.00),
	   (GETDATE(),'Uplata3',19570,19650,'Hrana',150.00),
	   (GETDATE(),'Uplata4',19900,19572,'Stipendija',250.00),
	   (GETDATE(),'Uplata5',19866,19877,'Putarina',50.00),
	   (GETDATE(),'Uplata6',19911,19922,'Putarina',50.00),
	   (GETDATE(),'Uplata7',19578,19822,'Stipendija',250.00),
	   (GETDATE(),'Uplata8',19822,19914,'Skolarina',800.00),
	   (GETDATE(),'Uplata9',19914,19573,'Putarina',50.00),
	   (GETDATE(),'Uplata10',19585,23122,'Stipendija',250.00)

select * from Transakcije











--3) Zadatak
--INDEKSI NISU RADJENI

















select * from Klijenti

Ime nvarchar(30) not null,
	Prezime nvarchar(30) not null,
	Telefon nvarchar(20) not null,
	Mail nvarchar(50) constraint UQ_Mail unique not null,
	BrojRacuna nvarchar(15) not null,
	KorisnickoIme nvarchar(20) not null,
	Lozinka nvarchar(20) not null


--4) Zadatak
go
create procedure proc_dodajKlijenta
(
	@Ime nvarchar(30),
	@Prezime nvarchar(30),
	@Telefon nvarchar(20),
	@Mail nvarchar(50),
	@BrojRacuna nvarchar(15),
	@Lozinka nvarchar(20)
)
as
begin
	insert into Klijenti
	values (@Ime,@Prezime,@Telefon,@Mail,@BrojRacuna,@Ime + '.' + @Prezime, @Lozinka)
end


--testiranje
exec proc_dodajKlijenta @Ime ='Denis',@Prezime='Tojaga', @Telefon = '060 300 1111', @Mail = 'denis.tojaga@edu.fit.ba',
						@BrojRacuna= '1111 5555 12345',@Lozinka = 'admin123';

select * from Klijenti













--5) Zadatak
go
create view view_prikazTransakcije
as
select t.Datum,
	   t.TipTransakcije,
	   k.KorisnickoIme as posiljalac,
	   k.BrojRacuna as br_racun_posiljalac,
	   k2.KorisnickoIme as primalac,
	   k2.BrojRacuna as br_racun_primalac,
	   t.Svrha,
	   t.Iznos
from Transakcije as t
inner join Klijenti as k on k.KlijentID = t.PosiljalacID
inner join Klijenti as k2 on k2.KlijentID = t.PrimalacID


select * from view_prikazTransakcije















--6) Zadatak
go
create procedure proc_prikazTransakcija
(
	@BrojRacunaPosiljaoca nvarchar(15)
)
as
begin
	select * 
	from view_prikazTransakcije
	where br_racun_posiljalac = @BrojRacunaPosiljaoca
end

exec proc_prikazTransakcija @BrojRacunaPosiljaoca = 'AW00029484';












--7) Zadatak
select YEAR(Datum) as godina, SUM(Iznos) as iznos_svih_transakcija
from Transakcije
group by YEAR(Datum)
order by 1















--8) Zadatak
--prvo je potrebno obrisati njegove reference gdje je strani kljuc
--pa tek onda iz glavne tabele
go
create procedure proc_brisanje
(
	@KlijentID int
)
as
begin
	delete from Transakcije
	where PrimalacID = @KlijentID or PosiljalacID = @KlijentID

	delete from Klijenti
	where KlijentID = @KlijentID
end

--testiranje
exec proc_brisanje @KlijentID = 19573;

select * from Transakcije
select * from Klijenti



























--9) Zadatak
go
create procedure proc_pretraga
(
	@BrojRacuna nvarchar(15) = null,
	@Prezime nvarchar(30) = null
)
as
begin
	select *
	from view_prikazTransakcije
	where (br_racun_posiljalac = @BrojRacuna and RIGHT(posiljalac,LEN(posiljalac) - CHARINDEX('.',posiljalac)) = @Prezime)
		   or br_racun_posiljalac = @BrojRacuna or RIGHT(posiljalac,LEN(posiljalac) - CHARINDEX('.',posiljalac)) = @Prezime
		   or (@BrojRacuna is null and @Prezime is null)
end

--testiranje svakog uslova
exec proc_pretraga;
exec proc_pretraga @BrojRacuna = 'AW00029484';
exec proc_pretraga @Prezime = 'Adams';
exec proc_pretraga @BrojRacuna = 'AW00029484',@Prezime ='Achong';











--10) Zadatak
--NIJE RADJEN BACKUP

