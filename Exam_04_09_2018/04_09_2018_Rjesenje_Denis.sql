--1) Zadatak

create database ispit_04_09_2018
go

use ispit_04_09_2018
go









--2) Zadatak


--a)
create table Autori
(
	AutorID nvarchar(11) constraint PK_AutorID primary key,
	Prezime nvarchar(25) not null,
	Ime nvarchar(25) not null,
	Telefon nvarchar(20) constraint DF_Telefon default(null),
	DatumKreiranjaZapisa date constraint DF_DatumKreirAutori default(getdate()) not null,
	DatumModifikovanjaZapisa date constraint DF_DatumModAutori default(null)
)


create table Izdavaci
(
	IzdavacID nvarchar(4) constraint PK_IzdavacID primary key,
	Naziv nvarchar(100) constraint UQ_Naziv unique not null,
	Biljeske nvarchar(1000) constraint DF_Biljeske default('Lorem ipsum'),
	DatumKreiranjaZapisa date constraint DF_DatumKreirIzdavaci default(getdate()) not null,
	DatumModifikovanjaZapisa date constraint DF_DatumModIzdavaci default(null)
)



create table Naslovi
(
	NaslovID nvarchar(6) constraint PK_NaslovID primary key,
	IzdavacID nvarchar(4) constraint FK_IzdavacID foreign key(IzdavacID) references Izdavaci(IzdavacID),
	Naslov nvarchar(100) not null,
	Cijena money,
	DatumIzdavanja date constraint DF_DatumIzdavanja default(getdate()) not null,
	DatumKreiranjaZapisa date constraint DF_DatumKreirNaslovi default(getdate()) not null,
	DatumModifikovanjaZapisa date constraint DF_DatumModNaslovi default(null)
)




create table NasloviAutori
(
	AutorID nvarchar(11),
	NaslovID nvarchar(6),
	DatumKreiranjaZapisa date constraint DF_DatumKreirNasAut default(getdate()) not null,
	DatumModifikovanjaZapisa date constraint DF_DatumModNasAut default(null),
	constraint PK_AutoriNaslovi primary key(AutorID,NaslovID),
	constraint FK_AutoriNaslovi_AutorID foreign key(AutorID) references Autori(AutorID),
	constraint FK_AutoriNaslovi_NaslovID foreign key(NaslovID) references Naslovi(NaslovID)
)




















--b)
insert into Autori(AutorID,Prezime,Ime,Telefon)
select a.au_id,a.au_lname,a.au_fname,a.phone
from (select au_id,au_lname,au_fname,phone
	  from pubs.dbo.authors) as a
order by NEWID()

select * from Autori






insert into Izdavaci(IzdavacID,Naziv,Biljeske)
select a.pub_id,
	   a.pub_name,
	   a.biljeske
from (select p.pub_id,
			 p.pub_name,
			 convert(nvarchar(100),pinf.pr_info) as biljeske
	  from pubs.dbo.publishers as p
	  inner join pubs.dbo.pub_info as pinf on p.pub_id = pinf.pub_id) as a
order by NEWID()


select * from Izdavaci








insert into Naslovi(NaslovID,IzdavacID,Naslov,Cijena)
select a.title_id,a.pub_id,a.title,a.price
from (select t.title_id,p.pub_id,t.title,t.price
	  from pubs.dbo.titles as t
	  inner join pubs.dbo.publishers as p on t.pub_id = p.pub_id) as a

select * from Naslovi






insert into NasloviAutori(NaslovID,AutorID)
select a.title_id,a.au_id
from (select title_id,au_id
	  from pubs.dbo.titleauthor) as a










--c)
create table Gradovi
(
	GradID int constraint PK_GradID primary key identity(5,5) ,
	Naziv nvarchar(100) constraint UQ_NazivGrad unique not null,
	DatumKreiranjaZapisa date constraint DF_DatumKreirGradovi default(getdate()) not null,
	DatumModifikovanjaZapisa date constraint DF_DatumModGradovi default(null)
)



insert into Gradovi(Naziv)
select a.city
from (select distinct city
	  from pubs.dbo.authors) as a


alter table Autori
add GradID int constraint FK_GradID foreign key(GradID) references Gradovi(GradID)


select * from Autori










--d)
go
create procedure proc_modify_1
as
begin
	update Autori
	set GradID = (select GradID from Gradovi where Naziv = 'San Francisco')
	where AutorID in (select top 10 AutorID from Autori) 

	update Autori
	set GradID = (select GradID from Gradovi where Naziv = 'Berkeley')
	where AutorID not in (select top 10 AutorID from Autori) 

end


exec proc_modify_1;

select * from Autori














--3) Zadatak

go
create view view_autori
as
select a.Prezime + ' ' + a.Ime as imePrezime,
	   g.Naziv as grad,
	   n.Naslov,
	   n.Cijena,
	   i.Naziv,
	   i.Biljeske
from Autori as a 
inner join NasloviAutori as na on a.AutorID = na.AutorID
inner join Naslovi as n on n.NaslovID = na.NaslovID
inner join Izdavaci as i on n.IzdavacID = i.IzdavacID
inner join Gradovi as g on g.GradID = a.GradID
where n.Cijena is not null and n.Cijena>10 and i.Naziv like '%&%' and g.Naziv = 'San Francisco'


select * from view_autori













--4) Zadatak
alter table Autori
add Email nvarchar(100) constraint DF_Email default(null)

















--5) Zadatak
go
create procedure proc_updAutori_1
as
begin
	update Autori
	set Email = Ime + '.' + Prezime + '@fit.ba'
	where GradID = (select GradID from Gradovi where Naziv = 'San Francisco')


	update Autori
	set Email = Prezime + '.' + Ime + '@fit.ba'
	where GradID = (select GradID from Gradovi where Naziv = 'Berkeley')
end


exec proc_updAutori_1;

select * from Autori









--6) Zadatak
select title,prezime,ime,email,brojtelefona,brojkartice,username,password
into #temp
from (select isnull(p.Title,'N/A') as title,
			 p.LastName as prezime,
			 p.FirstName as ime,
			 ea.EmailAddress as email,
			 pp.PhoneNumber as brojtelefona,
			 cc.CardNumber as brojkartice,
			 p.FirstName + '.' + p.LastName as username,
			 REPLACE(LOWER(LEFT(NEWID(),16)),'-','7') as password
	  from AdventureWorks2017.Person.Person as p 
	  inner join AdventureWorks2017.Person.EmailAddress as ea on p.BusinessEntityID = ea.BusinessEntityID
	  inner join AdventureWorks2017.Person.PersonPhone as pp on p.BusinessEntityID = pp.BusinessEntityID
	  left join AdventureWorks2017.Sales.PersonCreditCard as pcc on p.BusinessEntityID = pcc.BusinessEntityID
	  left join AdventureWorks2017.Sales.CreditCard as cc on cc.CreditCardID = pcc.CreditCardID) as a
order by 2,3



select * 
from #temp
















--7) Zadatak
--INDEKSI NISU RADJENI









--8) Zadatak
go
create procedure proc_delete
as
begin
	delete from #temp
	where brojkartice is null
end

exec proc_delete;














--9) Zadatak
--NIJE RADJENO
















--10) Zadatak

go
create procedure proc_deleteAll
as
begin
		ALTER TABLE NasloviAutori
	    DROP CONSTRAINT FK_AutoriNaslovi_AutorID

		ALTER TABLE NasloviAutori
		DROP CONSTRAINT FK_AutoriNaslovi_NaslovID

		ALTER TABLE Autori
		DROP CONSTRAINT FK_GradID

		ALTER TABLE Naslovi
		DROP CONSTRAINT FK_IzdavacID

		DELETE FROM NasloviAutori
		DELETE FROM Autori
		DELETE FROM Gradovi
		DELETE FROM Naslovi
		DELETE FROM Izdavaci
end


exec proc_deleteAll;












