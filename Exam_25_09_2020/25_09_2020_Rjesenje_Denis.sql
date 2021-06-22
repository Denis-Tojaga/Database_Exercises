-------------------------------------------------------------
/*
Napomena:

A.
Prilikom  bodovanja rješenja prioritet ima rezultat koji upit treba da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, 
jer ni ta rješenja ne mogu vratiti tačan rezultat (broj zapisa, vrijednosti agregatnih funkcija...).

B.
Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i 
sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
*/


--1.
/*
Kreirati bazu podataka pod vlastitim brojem indeksa.
*/

create database ispit_25_09_2020
go

use ispit_25_09_2020
go



/*Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
a) Kreirati tabelu osoba sljedeće strukture:
	- osoba_id		cjelobrojna varijabla, primarni ključ
	- ime			50 UNICODE karaktera
	- prezime		50 UNICODE karaktera
	- tip_osobe		2 UNICODE karaktera
	- kreditna_id	cjelobrojna varijabla
	- tip_kreditne	50 UNICODE karaktera
	- broj_kartice	50 UNICODE karaktera
	- dtm_izdav		datumska varijabla
*/
create table osoba
(
	osoba_id int constraint PK_osoba_id primary key,
	ime nvarchar(50),
	prezime nvarchar(50),
	tip_osobe	nvarchar(2),
	kreditna_id	int, 
	tip_kreditne nvarchar(50),
	broj_kartice nvarchar(50),
	dtm_izdav	date
)






/*
c) Kreirati tabelu kupac sljedeće strukture:
	- kupac_id		cjelobrojna varijabla, primarni ključ
	- osoba_id		cjelobrojna varijabla
	- prodavnica_id cjelobrojna varijabla
	- br_racuna		10 unicode karaktera 
*/


create table kupac
(
	kupac_id int constraint PK_kupac_id primary key,
	osoba_id int constraint FK_osoba_id foreign key(osoba_id) references osoba(osoba_id),
	prodavnica_id int,
	br_racuna nvarchar(10)
)






/*
c) Kreirati tabelu kupovina sljedeće strukture:
	- kupovina_id	cjelobrojna varijabla, primarni ključ
	- detalj_id		cjelobrojna varijabla, primarni ključ
	- narudzba_id	25 UNICODE karaktera
	- kreditna_id	cjelobrojna varijabla
	- teritorija_id cjelobrojna varijabla
	- kupac_id		cjelobrojna varijabla
	- kolicina		cjelobrojna varijabla
	- cijena		novčana varijabla
*/


create table kupovina
(
	kupovina_id int,
	detalj_id	int,
	narudzba_id	nvarchar(25),
	kreditna_id	int,
	teritorija_id int,
	kupac_id int constraint FK_kupac_id foreign key(kupac_id) references kupac(kupac_id),
	kolicina int,
	cijena	money,
	constraint PK_kupovina primary key(kupovina_id,detalj_id)
)





--10 bodova

-----------------------------------------------------------------------
--2.
/*
a) Koristeći tabele Person.Person, Sales.PersonCreditCard i Sales.CreditCard baze AdventureWorks2017 izvršiti
 insert podataka prema sljedećem pravilu:
	- BusinessEntityID	-> osoba_id
	- FirstName			-> ime
	- LastName			-> prezime
	- CardType			-> tip_kreditne 
	- PersonType		-> tip_osobe
	- CardNumber		-> broj_kartice
	- CreditCardID		-> kreditna_id
	- ModifiedDate		-> dtm_izdav
*/



insert into osoba
select p.BusinessEntityID,
	   p.FirstName,
	   p.LastName,
	   p.PersonType,
	   cc.CreditCardID,
	   cc.CardType,
	   cc.CardNumber,
	   cc.ModifiedDate
from AdventureWorks2017.Person.Person as p
inner join AdventureWorks2017.Sales.PersonCreditCard as pcc on p.BusinessEntityID = pcc.BusinessEntityID
inner join AdventureWorks2017.Sales.CreditCard as cc on pcc.CreditCardID = cc.CreditCardID





/*
b) Koristeći tabelu Sales.Customer baze AdventureWorks2017 izvršiti insert podataka prema sljedećem pravilu:
	- CustomerID	-> kupac_id
	- PersonID		-> osoba_id
	- StoreID		-> prodavnica_id
	- AccountNumber -> br_racuna
uz uslov da PersonID bude veći od 300.
*/

insert into kupac
select CustomerID,
	   PersonID,
	   StoreID,
	   AccountNumber
from AdventureWorks2017.Sales.Customer
where PersonID>300




/*
c) Koristeći tabele Sales.SalesOrderHeader i Sales.SalesOrderDetail baze AdventureWorks2017
 izvršiti insert podataka u tabelu kupovina prema sljedećem pravilu:
	- SalesOrderID			-> kupovina_id
	- SalesOrderDetailID	-> detalj_id
	- PurchaseOrderNumber	-> narudzba_id
	- CreditCardID			-> kreditna_id
	- TerritoryID			-> teritorija_id
	- CustomerID			-> kupac_id
	- OrderQty				-> kolicina
	- UnitPrice				-> cijena
uz uslov da CustomerID bude manji od 29000.
*/

insert into kupovina
select soh.SalesOrderID,
	   sod.SalesOrderDetailID,
	   soh.PurchaseOrderNumber,
	   soh.CreditCardID,
	   soh.TerritoryID,
	   soh.CustomerID,
	   sod.OrderQty,
	   sod.UnitPrice
from AdventureWorks2017.Sales.SalesOrderHeader as soh
inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on soh.SalesOrderID = sod.SalesOrderID
where CustomerID < 29000





--10 bodova

-----------------------------------------------------------------------
--3.
/*
a)
Kreirati pogled view_ukupno kojim će se dati ukupna vrijednost svih kupovina koje je osoba ostvarila.
Pogled treba sadržavati kolone:
	- osoba_id
	- ukupno - ukupna svota svih kupovina 
Napomena: 
Vrijednost jedne kupovine predstavlja umnožak količine i cijene.
*/

go
create view view_ukupno
as
select o.osoba_id,
	   SUM(kup.kolicina * kup.cijena) as ukupno
from osoba as o 
inner join kupac as k on o.osoba_id = k.osoba_id
inner join kupovina as kup on k.kupac_id = kup.kupac_id
group by o.osoba_id

select * from view_ukupno


/*
b)
Odrediti koliko je zapisa veće, koliko jednako, a koliko manje od srednje vrijednosti kolone ukupno iz view_ukupno.
Rezultat upita treba da vrati prebrojane brojeve sa pripadajućim oznakama (veće, jednako, manje).
Ne prihvata se rješenje koje ne vraća oznake.
*/

select 'vece' as oznaka,COUNT(*) as broj_vecih
from view_ukupno
where ukupno > (select AVG(ukupno) from view_ukupno)
union
select 'jednako' as oznaka,COUNT(*) as broj_vecih
from view_ukupno
where ukupno = (select AVG(ukupno) from view_ukupno)
union
select 'manje' as oznaka,COUNT(*) as broj_vecih
from view_ukupno
where ukupno < (select AVG(ukupno) from view_ukupno)






--10 bodova


-----------------------------------------------------------------------
--4.
/*
a)
U tabeli osoba dodati izračunatu kolonu lozinka. 
Podatak u koloni lozinka će se sastojati od sljedećih dijelova:
	-	2 znaka slučajno generisani karakteri
	-	bilo koja 3 karaktera iz kolona ime u obrnutom redoslijedu
	-	bilo koja 3 karaktera iz kolone prezime u obrnutom redoslijedu
	-	godina iz datuma izdavanja
	-	dan iz datuma izdavanja
	-	mjesec iz datuma izdavanja
Između svih dijelova lozinke OBAVEZNO treba biti donja crta.
*/
alter table osoba
add lozinka as left(newid(),2) + '_' + reverse(left(ime,3)) + '_' + reverse(left(prezime,3)) + '_' + convert(nvarchar,YEAR(dtm_izdav))
	           + '_' + convert(nvarchar,day(dtm_izdav)) + '_' + convert(nvarchar,month(dtm_izdav))

select * from osoba



/*
b)
U tabeli kupac u koloni prodavnica_id umjesto NULL vrijednosti ubaciti vrijednost podatka iz kolone osoba_id uvećan za 1.
*/

update kupac
set prodavnica_id = osoba_id + 1
where prodavnica_id is null

select * from kupac


--10 bodova




-----------------------------------------------------------------------
--5.
/*
a)
Kreirati proceduru proc_narudzba kojom će se smještati podaci u kolonu narudzba_id tabele kupovina.
Podatak u koloni narudzba_id će se sastoji od sljedećih dijelova:
	- 1. karakter je slovo n
	- kupovina_id
	- detalj_id
Između svih dijelova narudzba_id OBAVEZNO treba biti srednja crta.
OBAVEZNO pokrenuti proceduru.
*/

go
create  procedure proc_narudzba
as
begin
	update kupovina
	set narudzba_id = 'n-' + CONVERT(nvarchar,kupovina_id) + '-' + CONVERT(nvarchar,detalj_id)
end

exec proc_narudzba;
select * from kupovina




/*
b)
Nad kolonom narudzba_id kreirati ograničenje kojim će biti moguće unijeti podatak koji ima najviše 20 karaktera.
*/

alter table kupovina
add constraint CK_narudzba_id check (len(narudzba_id) <= 20)



--10 bodova



-----------------------------------------------------------------------
--6.
/*
Neka su za cijene definirane sljedeće 4 klase:
	- 0-999,99		=> klasa 1 
	- 1000-1999,99	=> klasa 2
	- 2000-2999,99	=> klasa 3
	- 3000-3999,99	=> klasa 4
Kreirati proceduru proc_klasa kojom će se izvršiti klasificiranje cijena prema navedenim klasama.
Procedura treba da vrati cijenu (njenu vrijednost) i oznaku klase kojoj pripada,
uz uslov da procedura ne vraća duplikate cijena.
*/

--10 bodova

go
create procedure proc_klasa
as
begin
	select distinct 'klasa 1' as oznaka,cijena
	from kupovina
	where cijena between 0 and 999.99
	union
	select distinct 'klasa 2' as oznaka,cijena
	from kupovina
	where cijena between 1000 and 1999.99
	union
	select distinct 'klasa 3' as oznaka,cijena
	from kupovina
	where cijena between 2000 and 2999.99
	union
	select distinct 'klasa 4' as oznaka,cijena
	from kupovina
	where cijena between 3000 and 3999.99
end

exec proc_klasa;

-----------------------------------------------------------------------
--7.
/*
a)
Koristeći tabele baze kreirati pogled view_tip sljedeće strukture:
	- tip kreditne kartice
	- ID prodavnice
	- prebrojano - prebrojani broj kupovina po tipu kreditne kartice i ID prodavnice
*/

go
create view view_tip
as
select o.tip_kreditne,
	   k.prodavnica_id,
	   COUNT(kup.kupovina_id) as prebrojano
from osoba as o 
inner join kupac as k on o.osoba_id = k.osoba_id
inner join kupovina as kup on k.kupac_id = kup.kupac_id
group by  o.tip_kreditne,
		  k.prodavnica_id

select * from view_tip



/*
b)
Koristeći pogled view_tip kreirati proceduru proc_tip koja će imati parametar za kolonu prebrojano. 
Pokrenuti proceduru za vrijednosti paramtera 3 i 30.
*/

go 
create procedure proc_tip
(
	@prebrojano int
)
as
begin
	select *
	from view_tip
	where prebrojano = @prebrojano
end

exec proc_tip @prebrojano = 3;
exec proc_tip @prebrojano = 30;



--10 bodova


-----------------------------------------------------------------------
--8.
/*
Na osnovu tabele osoba kreirati proceduru nakon čijeg pokretanja će se dobiti ukupan broj osoba čije prezime je 
jedinstveno.
*/
--podupit koristimo kao podtabelu iz koje prebrojimo zapise (jedinstvena prezimena)
go
create procedure proc_prezime
as
begin
	select COUNT(podtab.prezime) as broj_jedinstvenih_prezimena 
	from (select distinct prezime from osoba) as podtab
end
--10 bodova


-----------------------------------------------------------------------
--9.
/*
a)
Koristeći tabele baze kreirati globalnu privremenu tabelu temp sljedeće strukture:
	- ID osobe 
	- tip kreditne kartice
	- klasa - prve 4 cifre iz kolone broj_kartice
	- datum izdavanja
	- ID narudzbe
i u nju povući podatke iz odgovarajućih tabela.
*/

select o.osoba_id,
	   o.tip_kreditne,
	   LEFT(o.broj_kartice,4) as klasa,
	   o.dtm_izdav,
	   kup.narudzba_id
into #temp
from osoba as o
inner join kupac as k on o.osoba_id = k.osoba_id
inner join kupovina as kup on k.kupac_id = kup.kupac_id


select * from #temp



/*
b) 
Provjeriti da li je jednom tipu kreditne kartice u privremenoj tabeli pridružena jedna ili više klasa.
*/
select tip_kreditne,COUNT(klasa) as broj_pridruzenih_klasa
from #temp
group by tip_kreditne
order by 1




--10 bodova


-----------------------------------------------------------------------
--10.
/*
a)
Prebrojati broj pojavljivanja dužina podatka u koloni narudzba_id,  
uz uslov da se prikažu samo one vrijednosti dužina koja se pojavljaju više od 1000 puta.
*/

select LEN(narudzba_id) as vrijednost_duzine,COUNT(*) as broj_pojavljivanja
from kupovina
group by LEN(narudzba_id)
having COUNT(*) > 1000




/*
b) 
Svim zapisima čija dužina podatka se pojavljuje manje od 1000 puta promijeniti sadržaj 
kolone narudzba_id tako što će se na postojeći podatak dodati tekući datum.
*/

--prvo dropamo ogranicenje na duzinu 20
alter table kupovina
drop constraint CK_narudzba_id

--izmjenimo tip podatka u nvarchar
alter table kupovina
alter column narudzba_id nvarchar(40)



--ukoliko se ta duzina narudzba_id nalazi u listi duzina koje imaju prebrojanih zapisa manje od 1000 onda ce se desiti update
update kupovina
set narudzba_id = narudzba_id + '_' + convert(nvarchar,year(getdate())) + '_' + convert(nvarchar,month(getdate())) + '_' + convert(nvarchar,day(getdate()))
where len(narudzba_id) in (select LEN(narudzba_id) as vrijednost_duzine
						   from kupovina
						   group by LEN(narudzba_id)
						   having COUNT(*) < 1000)

--10 bodova
