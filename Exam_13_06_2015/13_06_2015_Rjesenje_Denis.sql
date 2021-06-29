--1) Zadatak

create database ispit_13_06_2015
go


use ispit_13_06_2015
go






--2) Zadatak

--a)
create table Kandidati
(
	KandidatID int constraint PK_KandidatID primary key identity(1,1),
	Ime nvarchar(30) not null,
	Prezime nvarchar(30) not null,
	JMBG nvarchar(13) constraint UQ_JMBG unique not null,
	DatumRodjenja date not null,
	MjestoRodjenja nvarchar(30),
	Telefon nvarchar(20),
	Email nvarchar(50) constraint UQ_Email unique
)


--b)
create table Testovi
(
	TestID int constraint PK_TestID primary key identity(1,1),
	Datum datetime not null,
	Naziv nvarchar(50) not null,
	Oznaka nvarchar(10) constraint UQ_Oznaka unique not null,
	Oblast nvarchar(50) not null,
	MaxBrojBodova int not null,
	Opis nvarchar(250)
)



-- iz napomene u zadatku dolazimo do zakljucka da je potrebna treca spojna tabela
create table RezultatiTesta
(
	KandidatID int,
	TestID int,
	Polozio nvarchar(2) not null,
	OsvojeniBodovi decimal(8,2) not null,
	Napomena text,
	constraint PK_KandidatiTestovi primary key(KandidatID,TestID),
	constraint FK_KandidatiTestovi_KandidatID foreign key(KandidatID) references Kandidati(KandidatID),
	constraint FK_KandidatiTestovi_TestID foreign key(TestID) references Testovi(TestID)
)

















--3) Zadatak
insert into Kandidati
select top 10 p.FirstName,
	   p.LastName,
	   REPLACE(RIGHT(c.rowguid,13),'-','0') as JMBG,
	   c.ModifiedDate as datumrodjenja,
	   a.City,
	   pp.PhoneNumber,
	   ea.EmailAddress
from AdventureWorks2017.Person.Person as p 
inner join AdventureWorks2017.Sales.Customer as c on p.BusinessEntityID = c.PersonID
inner join AdventureWorks2017.Person.BusinessEntity as be on p.BusinessEntityID = be.BusinessEntityID
inner join AdventureWorks2017.Person.BusinessEntityAddress as bea on be.BusinessEntityID = bea.BusinessEntityID
inner join AdventureWorks2017.Person.Address as a on bea.AddressID = a.AddressID
inner join AdventureWorks2017.Person.PersonPhone as pp on p.BusinessEntityID = pp.BusinessEntityID
inner join AdventureWorks2017.Person.EmailAddress as ea on p.BusinessEntityID = ea.BusinessEntityID






insert into Testovi
values ('2021-06-10','Test1','T10','Matematika',100,'Ovo je opis testa'),
	   ('2021-05-16','Test2','T20','Fizika',80,'Ovo je opis testa'),
	   ('2021-12-20','Test3','T30','Vozacki',120,'Ovo je opis testa')


















--4) Zadatak
go
create procedure usp_RezultatiTesta_Insert 
(
	@KandidatID int,
	@TestID int,
	@Polozio nvarchar(20),
	@OsvojeniBodovi decimal(8,2),
	@Napomena text
)
as
begin
	insert into RezultatiTesta
	values (@KandidatID,@TestID,@Polozio,@OsvojeniBodovi,@Napomena)
end

--testiranje
exec usp_RezultatiTesta_Insert @KandidatID = 1,@TestID = 1,@Polozio = 'DA',@OsvojeniBodovi = 90.00,@Napomena='Dobro naucio nema sta';
exec usp_RezultatiTesta_Insert @KandidatID = 2,@TestID = 2,@Polozio = 'NE',@OsvojeniBodovi = 50.00,@Napomena='Nije naucio';
exec usp_RezultatiTesta_Insert @KandidatID = 3,@TestID = 2,@Polozio = 'NE',@OsvojeniBodovi = 30.00,@Napomena='Nije naucio';
exec usp_RezultatiTesta_Insert @KandidatID = 4,@TestID = 1,@Polozio = 'NE',@OsvojeniBodovi = 20.00,@Napomena='Nije naucio';
exec usp_RezultatiTesta_Insert @KandidatID = 5,@TestID = 3,@Polozio = 'NE',@OsvojeniBodovi = 50.00,@Napomena='Ucio je al se zbunio';
exec usp_RezultatiTesta_Insert @KandidatID = 2,@TestID = 3,@Polozio = 'DA',@OsvojeniBodovi = 55.00,@Napomena='Dobro naucio nema sta';
exec usp_RezultatiTesta_Insert @KandidatID = 7,@TestID = 3,@Polozio = 'DA',@OsvojeniBodovi = 57.00,@Napomena='Dobro naucio nema sta';
exec usp_RezultatiTesta_Insert @KandidatID = 1,@TestID = 2,@Polozio = 'DA',@OsvojeniBodovi = 87.00,@Napomena='Dobro naucio nema sta';
exec usp_RezultatiTesta_Insert @KandidatID = 5,@TestID = 1,@Polozio = 'DA',@OsvojeniBodovi = 95.00,@Napomena='Dobro naucio nema sta';
exec usp_RezultatiTesta_Insert @KandidatID = 8,@TestID = 1,@Polozio = 'DA',@OsvojeniBodovi = 100.00,@Napomena='Dobro naucio nema sta';


select * from RezultatiTesta





























--5) Zadatak
go
create view view_Rezultati_Testiranje
as
select k.Ime + ' ' + k.Prezime as ime_prezime,
	   k.JMBG,
	   k.Telefon,
	   k.Email,
	   t.Datum,
	   t.Naziv,
	   t.Oznaka,
	   t.Oblast,
	   t.MaxBrojBodova,
	   rt.Polozio,
	   rt.OsvojeniBodovi,
	   CONVERT(nvarchar,(rt.OsvojeniBodovi/t.MaxBrojBodova) * 100) + '%' as osvojeno_procenata
from Kandidati as k
inner join RezultatiTesta as rt on k.KandidatID = rt.KandidatID
inner join Testovi as t on t.TestID = rt.TestID


select * from view_Rezultati_Testiranje



















--6) Zadatak
go
create procedure usp_RezultatiTesta_SelectByOznaka
(
	@OznakaTesta nvarchar(10),
	@Polozio nvarchar(2)
)
as
begin
	select * 
	from view_Rezultati_Testiranje
	where Oznaka = @OznakaTesta and Polozio = @Polozio
end

--testiranje
exec usp_RezultatiTesta_SelectByOznaka @OznakaTesta = 'T10',@Polozio='DA';
exec usp_RezultatiTesta_SelectByOznaka @OznakaTesta = 'T10',@Polozio='NE';



































--7) Zadatak
go
create procedure usp_RezultatiTesta_Update
(
	@TestIDTrenutni int,
	@KandidatIDTrenutni int,
	@Polozio nvarchar(2),
	@OsvojeniBodovi decimal(8,2),
	@Napomena text
)
as
begin
	update RezultatiTesta
	set Polozio = @Polozio,OsvojeniBodovi = @OsvojeniBodovi,Napomena = @Napomena
	where TestID = @TestIDTrenutni and KandidatID = @KandidatIDTrenutni
end

--testiranje
exec usp_RezultatiTesta_Update @TestIDTrenutni = 1,@KandidatIDTrenutni=1,@Polozio = 'NE',@OsvojeniBodovi = 20.00,@Napomena ='Kandidat je slabo naucio!';
select * from RezultatiTesta



























--8) Zadatak
go
create  procedure usp_Testovi_Delete
(
	@TestID int
)
as
begin
	delete from RezultatiTesta
	where TestID = @TestID

	delete from Testovi
	where TestID = @TestID
end

--testiranje
exec usp_Testovi_Delete @TestID =2;
select * from RezultatiTesta


























--9) Zadatak
go
create trigger tr_StopDelete
on RezultatiTesta
instead of delete
as
begin
	print('Nije dozvoljeno brisati rezultate testa!')
	rollback
end

--testiranje
delete from RezultatiTesta
where TestID = 1









--10) Zadatak
--NIJE RADJEN BACKUP