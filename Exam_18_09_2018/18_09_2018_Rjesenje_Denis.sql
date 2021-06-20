--1) Zadatak


create database ispit_18_09_2018
go

use ispit_18_09_2018
go



--2) Zadatak


--a)
create table Autori
(
	AutorID nvarchar(11) constraint PK_AutorID primary key,
	Prezime nvarchar(25) not null,
	Ime nvarchar(25) not null,
	ZipKod nvarchar(5) constraint DF_ZipKod default(null),
	DatumKreiranjaZapisa datetime constraint DF_DatumKreiranjaZapisa default(getdate()) not null,
	DatumModifikovanjaZapisa datetime constraint DF_DatumModifikovanjaZapisa default(null)
)


create table Izdavaci
(
	IzdavacID nvarchar(4) constraint PK_IzdavacID primary key,
	Naziv nvarchar(100) constraint UQ_Naziv unique not null,
	Biljeske nvarchar(1000) constraint DF_Biljeske default('Lorem Ipsum'),
	DatumKreiranjaZapisa datetime constraint DF_DatumKreiranjaIzdavaci default(getdate()) not null,
	DatumModifikovanjaZapisa datetime constraint DF_DatumModZapisa default(null)
)




create table Naslovi
(
	NaslovID nvarchar(6) constraint PK_NaslovID primary key,
	IzdavacID nvarchar(4) constraint FK_IzdavacID foreign key(IzdavacID) references Izdavaci(IzdavacID),
	Naslov nvarchar(100) not null,
	Cijena money,
	Biljeske nvarchar(200) constraint DF_BiljeskeNaslovi default('The quick brown fox jumps over the lazy dog'), 
	DatumIzdavanja datetime constraint DF_DatumIzdavanja default(getdate()) not null,
	DatumKreiranjaZapisa datetime constraint DF_DatumKreir default(getdate()) not null,
	DatumModifikovanjaZapisa datetime constraint DF_DatuModif default(null)
)




create table NasloviAutori
(
	AutorID nvarchar(11),
	NaslovID nvarchar(6), 
	DatumKreiranjaZapisa datetime constraint DF_DatumKreirNasAut default(getdate()) not null, 
	DatumModifikovanjaZapisa datetime constraint DF_DatumModNasAut default(null)
	constraint PK_NasloviAutori primary key(AutorID,NaslovID),
	constraint FK_NasloviAutori_AutorID foreign key(AutorID) references Autori(AutorID),
	constraint FK_NasloviAutori_NaslovID foreign key(NaslovID) references Naslovi(NaslovID)
)








--b)

--kad insertujemo putem podupita podatke a pritom ne popunjavamo sve kolone  u tabeli
--potrebno je prilikom navodjenja tabele navesti i kolone u koje insertujemo
--da soritramo podatke nasumicno koristimo order by newid()
insert into Autori(AutorID,Prezime,Ime,ZipKod)
select tab.au_id,
	   tab.au_lname,
	   tab.au_fname,
	   tab.zip
from (select au_id,au_lname,au_fname,zip 
	  from pubs.dbo.authors) as tab
order by NEWID()





--kada uzimamo podatke preko podupita u podupitu moramo izvuci tacno kolone koje nam trebaju 
-- i zatim iz podtabele izvucemo te iste podatke koje insertujemo u glavnu tabelu
insert into Izdavaci(IzdavacID,Naziv,Biljeske)
select a.pub_id,
	   a.pub_name,
	   CONVERT(nvarchar(100),a.pr_info)
from (select p.pub_id,p.pub_name,pubi.pr_info 
	  from pubs.dbo.publishers as p
	  inner join pubs.dbo.pub_info as pubi on p.pub_id = pubi.pub_id) as a




insert into Naslovi(NaslovID,IzdavacID,Naslov,Cijena,Biljeske,DatumIzdavanja)
select a.title_id,
	   a.pub_id,
	   a.title,
	   a.price,
	   a.notes,
	   a.pubdate
from (select title_id,pub_id,title,price,notes,pubdate 
	  from pubs.dbo.titles) as a
where a.notes is not null





insert into NasloviAutori(AutorID,NaslovID)
select a.au_id,
	   a.title_id
from (select au_id,title_id from pubs.dbo.titleauthor) as a








--c)
--kreiranje
create table Gradovi
(
	GradID int constraint PK_GradID primary key identity(1,2),
	Naziv nvarchar(100) constraint UQ_NazivGrad unique not null,
	DatumKreiranjaZapisa datetime constraint DF_DatumKreirGrad default(getdate()) not null,
	DatumModifikovanjaZapisa datetime constraint DF_DatumModZap default(null)
)


--dodavanje
insert into Gradovi(Naziv)
select tab.city
from (select distinct city from pubs.dbo.authors) as tab


--modifikovanje
alter table Autori
add GradID int constraint FK_GradID foreign key(GradID) references Gradovi(GradID)

select * from Autori






--d)

--update tabele Autori
--postavi GradID na (uzmi gradID iz tabele gradovi gdje je naziv ...)
--gdje je AutorID unutar liste (uzmi top 5 AutorID iz tabele Autori)
go
create procedure proc_upd_1
as
begin
	update Autori
	set GradID = (select GradID from Gradovi where Naziv = 'Salt Lake City')
	where AutorID in (select top 5 AutorID from Autori)
end

exec proc_upd_1;
select * from Autori





--ista procedura samo sto ovaj put kao filter postavimo da AutorID nije u listi od 5 prvih
go
create procedure proc_upd_2
as
begin
	update Autori
	set GradID = (select GradID from Gradovi where Naziv = 'Oakland')
	where AutorID not in (select top 5 AutorID from Autori)
end

exec proc_upd_2;

select * from Autori












--3) Zadatak
go
create view view_autori
as
select a.Ime + ' ' + a.Prezime as ime_prezime,
	   g.Naziv as naziv_grada,
	   n.Naslov as naslov,
	   n.Cijena as cijena,
	   n.Biljeske as biljeske,
	   i.Naziv as izdavac
from Autori as a
inner join Gradovi as g on a.GradID = g.GradID
inner join NasloviAutori as na on a.AutorID = na.AutorID
inner join Naslovi as n on n.NaslovID = na.NaslovID
inner join Izdavaci as i on n.IzdavacID = i.IzdavacID
where n.Cijena is not null and n.Cijena > 5
	  and CHARINDEX('&',i.Naziv) = 0 and g.Naziv = 'Salt Lake City'


select * from view_autori





--4) Zadatak
alter table Autori
add Email nvarchar(100) constraint DF_Email default(null)

select * from Autori









--5) Zadatak

go
create procedure proc_email_1
as
begin
	update Autori
	set Email = Ime + '.' + Prezime + '@fit.ba'
	where GradID in (select GradID from Gradovi where Naziv = 'Salt Lake City')

	update Autori
	set Email = Prezime + '.' + Ime + '@fit.ba'
	where GradID in (select GradID from Gradovi where Naziv = 'Oakland')
end

exec proc_email_1;

select * from Autori









--6) Zadatak

--jer u uslovu stoji osobe koje imaju i nemaju karticu moramo staviti left join na obe veze koje se ticu kartica
--funkcija REPLACE(kolona, 'ono sto treba zamjeniti', 'onom cim mijenjamo')
select tab.title,
	   tab.lastname,
	   tab.firstname,
	   tab.emailaddress,
	   tab.phonenumber,
	   tab.cardnumber,
	   tab.UserName,
	   tab.Password
into #temp
from ( select isnull(p.Title,'N/A') as title,
	   p.LastName as lastname,
	   p.FirstName as firstname,
	   ea.EmailAddress as emailaddress,
	   pp.PhoneNumber as phonenumber,
	   cc.CardNumber as cardnumber,
	   p.FirstName + '.' + p.LastName as UserName,
	   LOWER(REPLACE(LEFT(newid(),24),'-','7')) as Password
	   from AdventureWorks2017.Person.Person as p
	   inner join AdventureWorks2017.Person.EmailAddress as ea on p.BusinessEntityID = ea.BusinessEntityID
	   inner join AdventureWorks2017.Person.PersonPhone as pp on p.BusinessEntityID = pp.BusinessEntityID
	   left join AdventureWorks2017.Sales.PersonCreditCard as pcc on p.BusinessEntityID = pcc.BusinessEntityID
	   left join AdventureWorks2017.Sales.CreditCard as cc on cc.CreditCardID = pcc.CreditCardID) as tab
order by 2,3

select * from #temp













--7) Zadatak
--INDEKSI NISU RADJENI










--8) Zadatak

go
create procedure proc_brisanje
as
begin
	delete from #temp
	where cardnumber is not null
end

exec proc_brisanje;

select * from #temp









--9) Zadatak
--NIJE RADJENO



--10) Zadatak


--da bi obrisali tabele potrebno je prvo obrisati sve foreign key constraintove,
--pocevci od medjutabela pa do stranih kljuceva kolona
go
create procedure proc_brisiSve
as
begin
	
	alter table NasloviAutori
	drop constraint FK_NasloviAutori_AutorID

	alter table NasloviAutori
	drop constraint FK_NasloviAutori_NaslovID

	alter table Autori
	drop constraint FK_GradID

	alter table Naslovi
	drop constraint FK_IzdavacID

	delete Autori
	delete Izdavaci
	delete Naslovi
	delete NasloviAutori
	delete Gradovi
	delete #temp
end



