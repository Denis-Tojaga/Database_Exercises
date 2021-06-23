--1. Kreiranje baze i tabela
/*
a) Kreirati bazu pod vlastitim brojem indeksa.
*/

create database ispit_19_09_2019
go

use ispit_19_09_2019
go




--b) Kreiranje tabela.
/*
Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
I. Kreirati tabelu kreditna sljedeće strukture:
	- kreditnaID - cjelobrojna vrijednost, primarni ključ
	- br_kreditne - 25 unicode karatera, obavezan unos
	- dtm_evid - datumska varijabla za unos datuma
*/

create table kreditna
(
	kreditnaID int constraint PK_kreditnaID primary key,
	br_kreditne nvarchar(25) not null,
	dtm_evid date
)


/*
II. Kreirati tabelu osoba sljedeće strukture:
	osobaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost, obavezan unos
	mail_lozinka - 128 unicode karaktera
	lozinka - 10 unicode karaktera 
	br_tel - 25 unicode karaktera
*/

create table osoba
(
	osobaID int constraint PK_osobaID primary key,
	kreditnaID int constraint FK_kreditnaID foreign key(kreditnaID) references kreditna(kreditnaID),
	mail_lozinka nvarchar(128),
	lozinka nvarchar(10),
	br_tel nvarchar(25)
)


/*
III. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID - cjelobrojna vrijednost, primarni ključ
	kreditnaID - cjelobrojna vrijednost
	br_narudzbe - 25 unicode karaktera
	br_racuna - 15 unicode karaktera
	prodavnicaID - cjelobrojna varijabla
*/

create table narudzba
(
	narudzbaID int constraint PK_narudzbaID primary key,
	kreditnaID int constraint FK_narudzba_kreditnaID foreign key(kreditnaID) references kreditna(kreditnaID),
	br_narudzbe nvarchar(25),
	br_racuna  nvarchar(15),
	prodavnicaID int 
)




--10 bodova





-----------------------------------------------------------------------------------------------------------------------------
--2. Import podataka
/*
a) Iz tabele CreditCard baze AdventureWorks2017 importovati podatke u tabelu kreditna na sljedeći način:
	- CreditCardID -> kreditnaID
	- CardNUmber -> br_kreditne
	- ModifiedDate -> dtm_evid
*/

insert into kreditna
select CreditCardID,
	   CardNumber,
	   ModifiedDate
from AdventureWorks2017.Sales.CreditCard


/*
b) Iz tabela Person, Password, PersonCreditCard i PersonPhone baze AdventureWorks2017 koje se nalaze u šemama Sales i Person 
importovati podatke u tabelu osoba na sljedeći način:
	- BussinesEntityID -> osobaID
	- CreditCardID -> kreditnaID
	- PasswordHash -> mail_lozinka
	- PasswordSalt -> lozinka
	- PhoneNumber -> br_tel
*/

insert into osoba
select p.BusinessEntityID,
	   pcc.CreditCardID,
	   pass.PasswordHash,
	   pass.PasswordSalt,
	   pp.PhoneNumber
from AdventureWorks2017.Person.Person as p 
inner join AdventureWorks2017.Person.Password as pass on p.BusinessEntityID = pass.BusinessEntityID
inner join AdventureWorks2017.Sales.PersonCreditCard as pcc on p.BusinessEntityID = pcc.BusinessEntityID
inner join AdventureWorks2017.Person.PersonPhone as pp on p.BusinessEntityID = pp.BusinessEntityID



/*
c) Iz tabela Customer i SalesOrderHeader baze AdventureWorks2017 koje se nalaze u šemi Sales importovati podatke u tabelu 
narudzba na sljedeći način:
	- SalesOrderID -> narudzbaID
	- CreditCardID -> kreditnaID
	- PurchaseOrderNumber -> br_narudzbe
	- AccountNumber -> br_racuna
	- StoreID -> prodavnicaID
*/

insert into narudzba
select soh.SalesOrderID,
	   soh.CreditCardID,
	   soh.PurchaseOrderNumber,
	   c.AccountNumber,
	   c.StoreID
from AdventureWorks2017.Sales.Customer as c
inner join AdventureWorks2017.Sales.SalesOrderHeader as soh on c.CustomerID = soh.CustomerID

--10 bodova





-----------------------------------------------------------------------------------------------------------------------------
/*
3. Kreirati pogled view_kred_mail koji će se sastojati od kolona: 
	- br_kreditne, 
	- mail_lozinka, 
	- br_tel i 
	- br_cif_br_tel, 
	pri čemu će se kolone puniti na sljedeći način:
	- br_kreditne - odbaciti prve 4 cifre 
 	- mail_lozinka - preuzeti sve znakove od 10. znaka (uključiti i njega)
	 uz odbacivanje znaka jednakosti koji se nalazi na kraju lozinke
	- br_tel - prenijeti cijelu kolonu
	- br_cif_br_tel - broj cifara u koloni br_tel
*/


go
create view view_kred_mail
as
select RIGHT(k.br_kreditne,LEN(k.br_kreditne) - 4) as br_kreditne,
	   SUBSTRING(o.mail_lozinka,10,LEN(o.mail_lozinka) - 11) as mail_lozinka,
	   o.br_tel,
	   LEN(REPLACE(REPLACE(REPLACE(REPLACE(o.br_tel,'-',''),'(',''),')',''),' ','')) as br_cif_br_tel
from kreditna as k 
inner join osoba as o on k.kreditnaID = o.kreditnaID


select * from view_kred_mail




--10 bodova





-----------------------------------------------------------------------------------------------------------------------------
/*
4. Koristeći tabelu osoba kreirati proceduru proc_kred_mail u kojoj će biti sve kolone iz tabele. 
Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji 
parametar bez unijete vrijednosti) uz uslov da se prenesu samo oni zapisi u kojima je unijet predbroj u koloni br_tel. 
Npr. (123) 456 789 je zapis u kojem je unijet predbroj. 
Nakon kreiranja pokrenuti proceduru za sljedeću vrijednost:
br_tel = 1 (11) 500 555-0132
*/

go
create procedure proc_kred_mail
(
	@osobaID int = null,
	@kreditnaID int = null,
	@mail_lozinka nvarchar(128) = null,
	@lozinka nvarchar(10) = null,
	@br_tel nvarchar(25)
)
as
begin
	select * 
	from osoba
	where (osobaID = @osobaID or kreditnaID = @kreditnaID or
		  mail_lozinka = @mail_lozinka or lozinka = @lozinka
		  or br_tel = @br_tel) and CHARINDEX('(',br_tel) != 0
end

exec proc_kred_mail @br_tel = '1 (11) 500 555-0132';
--10 bodova

-----------------------------------------------------------------------------------------------------------------------------
/*
5. 
a) Kopirati tabelu kreditna u kreditna1, 
b) U tabeli kreditna1 dodati novu kolonu dtm_izmjene
 čija je default vrijednost aktivni datum sa vremenom. Kolona je sa obaveznim unosom.
*/

select * into kreditna1
from kreditna


alter table kreditna1
add dtm_izmjene datetime constraint DF_dtm_izmjene default(getdate()) not null

select * from kreditna1


-----------------------------------------------------------------------------------------------------------------------------
/*
6.
a) U zapisima tabele kreditna1 kod kojih broj kreditne kartice počinje ciframa 1 ili 3 vrijednost broja 
kreditne kartice zamijeniti slučajno generisanim nizom znakova.
b) Dati ifnormaciju (prebrojati) broj zapisa u tabeli kreditna1
 kod kojih se datum evidencije nalazi u intevalu do najviše 6 godina u odnosu na datum izmjene.
c) Napisati naredbu za brisanje tabele kreditna1
*/

--a)
update kreditna1
set br_kreditne = LEFT(newid(),25)
where LEFT(br_kreditne,1) like '[13]%'

select * from kreditna1


--b)
select COUNT(*) as broj_zapisa
from kreditna1
where DATEDIFF(year,dtm_evid,dtm_izmjene) <=7


--c)
drop table kreditna1


-----------------------------------------------------------------------------------------------------------------------------
/*
7.
a) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni br_narudzbe slučajno generisanim nizom znakova.
b) U tabeli narudzba izvršiti izmjenu svih null vrijednosti u koloni prodavnicaID po sljedećem pravilu.
	- ako narudzbaID počinje ciframa 4 ili 5 u kolonu prodavnicaID preuzeti posljednje 3 cifre iz kolone narudzbaID  
	- ako narudzbaID počinje ciframa 6 ili 7 u kolonu prodavnicaID preuzeti posljednje 4 cifre iz kolone narudzbaID  
*/

--12 bodova

--a)
update narudzba
set br_narudzbe = left(NEWID(),25)
where br_narudzbe is null

--b)
update narudzba
set prodavnicaID = case 
						when LEFT(narudzbaID,1) like '[45]%' then RIGHT(narudzbaID,3)
						when LEFT(narudzbaID,1) like '[67]%' then RIGHT(narudzbaID,4)
				   end
where prodavnicaID is null


-----------------------------------------------------------------------------------------------------------------------------
/*
8.
Kreirati proceduru kojom će se u tabeli narudzba izvršiti izmjena svih vrijednosti u
 koloni br_narudzbe u kojima se ne nalazi slučajno generirani niz znakova
  tako da se iz podatka izvrši uklanjanje prva dva znaka. 
*/

go
create procedure proc_izmjena
as
begin
	update narudzba
	set br_narudzbe = RIGHT(br_narudzbe,LEN(br_narudzbe) - 2)
	where br_narudzbe like 'PO%'
end

exec proc_izmjena;

select * from narudzba

--8 bodova




-----------------------------------------------------------------------------------------------------------------------------
/*
9.
a) Iz tabele narudzba kreirati pogled koji će imati sljedeću strukturu:
	- duz_br_nar 
	- prebrojano - prebrojati broj zapisa prema dužini podatka u koloni br_narudzbe 
	  (npr. 1000 zapisa kod kojih je dužina podatka u koloni br_narudzbe 10)
Uslov je da se ne prebrojavaju zapisi u kojima je smješten slučajno generirani niz znakova. 
Provjeriti sadržaj pogleda.
b) Prikazati minimalnu i maksimalnu vrijednost kolone prebrojano
c) Dati pregled zapisa u kreiranom pogledu u kojima su vrijednosti u koloni prebrojano veće od srednje vrijednosti kolone prebrojano 
*/

--a)
go
create view view_prebrojano
as
select LEN(br_narudzbe) as duzina_podatka,
	   COUNT(*) as prebrojano
from narudzba
where br_narudzbe not like '%[A-Z]%'
group by LEN(br_narudzbe)

select * from view_prebrojano

--b)
select MIN(prebrojano) as minimalna,MAX(prebrojano) as maksimalna
from view_prebrojano

--c)
select * 
from view_prebrojano
where prebrojano > (select AVG(prebrojano) from view_prebrojano)


--13 bodova




-----------------------------------------------------------------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Obrisati bazu.
*/

--NIJE RADJENO

--2 boda



