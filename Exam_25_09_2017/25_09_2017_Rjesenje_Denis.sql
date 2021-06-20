--1) Zadatak

create database ispit_24_09_2017
go

use ispit_24_09_2017
go




--b)
create table Klijenti
(
	KlijentID int constraint PK_KlijentID primary key identity(1,1),
	Ime nvarchar(50) not null, 
	Prezime nvarchar(50) not null,
	Drzava nvarchar(50) not null,
	Grad nvarchar(50) not null,
	Email nvarchar(50) not null,
	Telefon nvarchar(50) not null
)


create table Izleti
(
	IzletID int constraint PK_IzletID primary key identity(1,1),
	Sifra nvarchar(10),
	Naziv nvarchar(100) not null,
	DatumPolaska date not null,
	DatumPovratka date not null,
	Cijena decimal(8,2) not null,
	Opis text
)


create table Prijave
(
	KlijentID int,
	IzletID int,
	Datum datetime not null,
	BrojOdraslih  int not null,
	BrojDjece int not null,
	constraint PK_Prijave_Klijent_Izlet primary key(KlijentID,IzletID),
	constraint FK_Prijave_KlijentID foreign key(KlijentID) references Klijenti(KlijentID),
	constraint FK_Prijave_IzletID foreign key(IzletID) references Izleti(IzletID)
)
















--2) Zadatak

--a)
insert into Klijenti
select p.FirstName,
	   p.LastName,
	   cr.Name,
	   a.City,
	   p.FirstName + '.' + p.LastName + '@' + RIGHT(ea.EmailAddress,LEN(ea.EmailAddress) - CHARINDEX('@',ea.EmailAddress)) as Email,
	   pp.PhoneNumber
from AdventureWorks2017.HumanResources.Employee as e
inner join AdventureWorks2017.Person.Person as p on e.BusinessEntityID = p.BusinessEntityID
inner join AdventureWorks2017.Person.PersonPhone as pp on pp.BusinessEntityID = p.BusinessEntityID
inner join AdventureWorks2017.Person.BusinessEntity as be on p.BusinessEntityID = be.BusinessEntityID
inner join AdventureWorks2017.Person.BusinessEntityAddress as bea on be.BusinessEntityID = bea.BusinessEntityID
inner join AdventureWorks2017.Person.Address as a on bea.AddressID = a.AddressID
inner join AdventureWorks2017.Person.StateProvince as sp on a.StateProvinceID = sp.StateProvinceID
inner join AdventureWorks2017.Person.CountryRegion as cr on sp.CountryRegionCode = cr.CountryRegionCode
inner join AdventureWorks2017.Person.EmailAddress as ea on p.BusinessEntityID = ea.BusinessEntityID



--b)
insert into Izleti(Sifra,Naziv,DatumPolaska,DatumPovratka,Cijena)
values ('AB-100-10','Putovanje u Grad 1','20170925','20171025', 1000),
	   ('AB-100-20','Putovanje u Grad 2','20170925','20171025', 2000),
	   ('AB-100-30','Putovanje u Grad 3','20170925','20171025', 3000)





--3) Zadatak
go
create procedure proc_nova_prijava
(
	@KlijentID int,
	@IzletID int,
	@BrojOdraslih int,
	@BrojDjece int
)
as
begin
	insert into Prijave(KlijentID,IzletID,Datum,BrojOdraslih,BrojDjece)
	values (@KlijentID,@IzletID,GETDATE(),@BrojOdraslih,@BrojDjece)
end

	
exec proc_nova_prijava @KlijentID = 1,@IzletID=1,@BrojOdraslih=5,@BrojDjece=2;
exec proc_nova_prijava @KlijentID = 2,@IzletID=2,@BrojOdraslih=15,@BrojDjece=1;
exec proc_nova_prijava @KlijentID = 3,@IzletID=2,@BrojOdraslih=45,@BrojDjece=10;
exec proc_nova_prijava @KlijentID = 4,@IzletID=3,@BrojOdraslih=5,@BrojDjece=0;
exec proc_nova_prijava @KlijentID = 5,@IzletID=1,@BrojOdraslih=123,@BrojDjece=30;
exec proc_nova_prijava @KlijentID = 6,@IzletID=2,@BrojOdraslih=10,@BrojDjece=6;
exec proc_nova_prijava @KlijentID = 2,@IzletID=1,@BrojOdraslih=22,@BrojDjece=0;
exec proc_nova_prijava @KlijentID = 4,@IzletID=1,@BrojOdraslih=56,@BrojDjece=40;
exec proc_nova_prijava @KlijentID = 8,@IzletID=3,@BrojOdraslih=6,@BrojDjece=1;
exec proc_nova_prijava @KlijentID = 1,@IzletID=3,@BrojOdraslih=9,@BrojDjece=7;


select * from Prijave










--4) Zadatak
--INDEKSI NISU RADJENI













--5) Zadatak

--updatetujemo samo gdje se IzletID iz tabele Izleti nalazi u listi izleta iz prijava koji se ponavljaju vise od 3 puta
update Izleti
set Cijena = Cijena - (Cijena*0.1)
where IzletID in 
(
	select p.IzletID
	from Prijave as p
	group by p.IzletID
	having COUNT(*) > 3
)

select * from Izleti
















--6) Zadatak
go
create view view_izlet
as
select i.Sifra,
	   i.Naziv,
	   convert(date,i.DatumPolaska) as datumPolaska,
	   convert(date,i.DatumPovratka) as datumDolaska,
	   i.Cijena,
	   COUNT(*) as brojPrijava,
	   SUM(p.BrojDjece + p.BrojOdraslih) as ukupno_putnika,
	   SUM(p.BrojOdraslih) as ukupan_broj_odraslih,
	   SUM(p.BrojDjece) as ukupan_broj_djece
from Izleti as i
inner join Prijave as p on i.IzletID = p.IzletID
group by i.Sifra,
	   i.Naziv,
	   i.DatumPolaska,
	   i.DatumPovratka,
	   i.Cijena

select * from view_izlet














--7) Zadatak

go
create procedure proc_prikazZarade
(
	@Sifra nvarchar(10)
)
as
begin
	select i.Naziv,
		   SUM(i.Cijena) as zaradaOdraslih,
		   SUM(i.Cijena * 0.5) as zaradaDjece,
		   SUM((i.Cijena + i.Cijena * 0.5)) as ukupnaZarada
	from Izleti as i
	inner join Prijave as p on i.IzletID = p.IzletID
	where Sifra = @Sifra
	group by i.Naziv
end


exec proc_prikazZarade @Sifra ='AB-100-10';
exec proc_prikazZarade @Sifra ='AB-100-20';















--8) Zadatak

--a)
create table IzletiHistorijaCijena
(
	IzletID int,
	DatumIzmjene date,
	StaraCijena decimal(8,2),
	NovaCijena decimal(8,2)
)




--b)

--uzimamo podatke iz delete jer tu prvo idu svi kad se radi update
--pravimo join sa inserted tabelom da bi mogli pristupiti novoj cijeni koja ce uci u tu tabelu poslije deleted-a
go
create trigger tr_IzmjenaCijene
on Izleti
after update
as
begin
	insert into IzletiHistorijaCijena
	select d.IzletID,GETDATE(),d.Cijena as staraCijena,i.Cijena as novaCijena
	from deleted as d
	inner join inserted as i on d.IzletID = i.IzletID
end


--testiranje
update Izleti
set Cijena = Cijena + 20
where IzletID = 1

select * from Izleti
select * from IzletiHistorijaCijena








--c)
select i.Naziv,
	   i.DatumPolaska,
	   i.DatumPovratka,
	   i.Cijena as trenutnaCijena,
	   izh.DatumIzmjene,
	   izh.StaraCijena,
	   izh.NovaCijena
from Izleti as i
inner join IzletiHistorijaCijena as izh on i.IzletID = izh.IzletID
where i.IzletID = 1












--9) Zadatak

--obrisi zapise iz tabele klijenti
--gdje se za svaki KlijentID ode i odradi podupit koji vrati listu klijenata koji nemaju narudzbe
--ako se taj vanjski KlijentID nalazi u toj listi treba se znaci obrisati
delete from Klijenti
where KlijentID not in (select k.KlijentID
						from Klijenti as k
						left join Prijave as p on k.KlijentID=p.KlijentID
						group by k.KlijentID
						having COUNT(p.KlijentID) = 0)






--10) Zadatak
--BACKUP NIJE RADJEN



