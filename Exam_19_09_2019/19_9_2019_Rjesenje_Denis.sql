--1) Zadatak 

--a)
create database ispit_19_09_2019
go

use ispit_19_09_2019
go

--b)
create table kreditna
(
	kreditnaID int constraint PK_KreditnaID primary key,
	br_kreditne nvarchar(25) not null,
	dtm_evid date
)


create table osoba
(
	osobaID int constraint PK_osoba_ID primary key,
	kreditnaID int constraint FK_kreditnaID foreign key(kreditnaID) references kreditna(kreditnaID),
	mail_lozinka nvarchar(128),
	lozinka nvarchar(10), 
	br_tel nvarchar(25)
)


create table narudzba
(
	narudzbaID int constraint PK_narudzb
	kreditnaID - cjelobrojna vrijednost
	br_narudzbe - 25 unicode karaktera
	br_racuna - 15 unicode karaktera
	prodavnicaID - cjelobrojna varijabla
)












--2) 

--a)
insert into kreditna
select CreditCardID,
	   CardNumber,
	   ModifiedDate
from AdventureWorks2017.Sales.CreditCard


--b)
insert into osoba
select p.BusinessEntityID,
	   pcc.CreditCardID,
	   pas.PasswordHash,
	   pas.PasswordSalt,
	   pp.PhoneNumber
from AdventureWorks2017.Person.Person as p 
inner join AdventureWorks2017.Person.Password as pas on p.BusinessEntityID = pas.BusinessEntityID
inner join AdventureWorks2017.Person.PersonPhone as pp on p.BusinessEntityID = pp.BusinessEntityID
inner join AdventureWorks2017.Sales.PersonCreditCard as pcc on p.BusinessEntityID = pcc.BusinessEntityID


--c)
insert into narudzba
select soh.SalesOrderID,
       soh.CreditCardID,
	   soh.PurchaseOrderNumber,
	   c.AccountNumber,
	   c.StoreID
from AdventureWorks2017.Sales.Customer as c
inner join AdventureWorks2017.Sales.SalesOrderHeader as soh on c.CustomerID = soh.CustomerID










--3) Zadatak
go
create view view_kred_mail
as
select RIGHT(k.br_kreditne,LEN(k.br_kreditne) - 4) as br_kreditne,
	   SUBSTRING(o.mail_lozinka,10,LEN(o.mail_lozinka) - 10) as mail_lozinka,
	   o.br_tel,
	   LEN(o.br_tel) as broj_cifara
from kreditna as k
inner join osoba as o on k.kreditnaID = o.kreditnaID

select * from view_kred_mail









--4) Zadatak
go
create procedure proc_kred_mail
(
	@br_tel nvarchar(25)
)
as
begin
	select * 
	from osoba
	where br_tel = @br_tel and br_tel like '%(%'
end


exec proc_kred_mail @br_tel = '1 (11) 500 555-0132';












--5) Zadatak

--a)
select * into kreditna1
from kreditna

select * from kreditna1

--b)
alter table kreditna1
add dtm_izmjene datetime not null default(GETDATE())

select * from kreditna1











--6) Zadatak

--a)
update kreditna1
set br_kreditne =LEFT(NEWID(),LEN(br_kreditne))
where br_kreditne like '[13]%'

select *
from kreditna1

--b)
--zapis ne vraca nista ako se koristi granica 6(bila validna kad je ispit postavljan)
--izmjenjeno za jedan veci tj. 7
select COUNT(*)
from kreditna1
where DATEDIFF(YEAR,dtm_evid,dtm_izmjene) <=7



--c)
drop table kreditna1













--7) Zadatak

--a)
--update ne radi ako postavimo na LEFT(newid(),len(br_narudzbe))
--moramo odabrati najvecu duzinu od svih zapisa i postaviti da uzimamo toliko iz newid() 
update narudzba
set br_narudzbe = LEFT(newid(),(select max(len(br_narudzbe)) from narudzba))
where br_narudzbe is null

select * from narudzba


--b)
--zapis ne radi jer je prodavnicaID tipa int, prvo moramo izmjeniti tip podatka,
alter table narudzba
alter column prodavnicaID nvarchar(10)


--tek onda pokrenuti update
update narudzba
set prodavnicaID = case 
				   when br_narudzbe like '[45]%' then RIGHT(br_narudzbe,3)
				   when br_narudzbe like '[67]%' then RIGHT(br_narudzbe,4)
				   end
where prodavnicaID is null

select * from narudzba













--8) Zadatak 

--ovdje provjerimo da li je duzina manja od 25, jer smo u update iznad postavili sve one koji su null na 
--25 karaktera od niza newid(), tako da oni sto su generisani tim putem imaju duzinu 25
go
create procedure proc_update
as
begin
	update narudzba
	set br_narudzbe = RIGHT(br_narudzbe,LEN(br_narudzbe) - 2)
	where LEN(br_narudzbe) < 25
end

exec proc_update;


select * 
from narudzba








--9) Zadatak

--a)
go
create view view_pogled
as
select LEN(br_narudzbe) as duzina_br_nar,COUNT(*) as prebrojano
from narudzba
where LEN(br_narudzbe) < 25
group by LEN(br_narudzbe)


--b)
select MIN(prebrojano) as minimalna,MAX(prebrojano) as maksimalna
from view_pogled


--c)
--prosjecna vrijednost kolone prebrojano -> 7866
select * 
from view_pogled
where prebrojano > (select AVG(prebrojano) from view_pogled)












--10) Zadatak

--NIJE RADJENO
