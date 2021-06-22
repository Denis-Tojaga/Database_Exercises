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

------------------------------------------------
--1
/*
Kreirati bazu podataka pod vlastitim brojem indeksa.
*/

create database ispit_11_09_2020
go

use ispit_11_09_2020
go


/*Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
a) Kreirati tabelu radnik koja će imati sljedeću strukturu:
	- radnikID, cjelobrojna varijabla, primarni ključ
	- drzavaID, 15 unicode karaktera
	- loginID, 256 unicode karaktera
	- sati_god_odmora, cjelobrojna varijabla
	- sati_bolovanja, cjelobrojna varijabla
*/

create table radnik
(
	radnikID int constraint PK_radnik_ID primary key,
	drzavaID nvarchar(15),
	loginID nvarchar(256), 
	sati_god_odmora int,
	sati_bolovanja int
)



/*
b) Kreirati tabelu nabavka koja će imati sljedeću strukturu:
	- nabavkaID, cjelobrojna varijabla, primarni ključ
	- status, cjelobrojna varijabla
	- nabavaljacID, cjelobrojna varijabla
	- br_racuna, 15 unicode karaktera
	- naziv_nabavljaca, 50 unicode karaktera
	- kred_rejting, cjelobrojna varijabla
*/

create table nabavka
(
	nabavkaID int constraint PK_nabavka_ID primary key,
	status int,
	radnikID int constraint FK_radnik_ID foreign key(radnikID) references radnik(radnikID),
	br_racuna nvarchar(15),
	naziv_nabavljaca nvarchar(50),
	kred_rejting int
)

/*
c) Kreirati tabelu prodaja koja će imati sljedeću strukturu:
	- prodavacID, cjelobrojna varijabla, primarni ključ
	- prod_kvota, novčana varijabla
	- bonus, novčana varijabla
	- proslogod_prodaja, novčana varijabla
	- naziv_terit, 50 unicode karaktera
*/

--veza ove tabele i tabele radnik je ONE-ON-ONE(shema iz adventure works tabele Employee,SalesPerson)
create table prodaja
(
	prodavacID int,
	prod_kvota money,
	bonus money,
	proslogod_prodaja money,
	naziv_terit nvarchar(50),
	constraint PK_prodavacID primary key(prodavacID),
	constraint FK_prodavacID foreign key(prodavacID) references radnik(radnikID)
)




--10 bodova



--------------------------------------------
--2. Import podataka
/*
a) Iz tabele HumanResources.Employee AdventureWorks2017 u tabelu radnik importovati podatke po sljedećem pravilu:
	- BusinessEntityID -> radnikID
	- NationalIDNumber -> drzavaID
	- LoginID -> loginID
	- VacationHours -> sati_god_odmora
	- SickLeaveHours -> sati_bolovanja
*/

insert into radnik
select BusinessEntityID,
	   NationalIDNumber,
	   LoginID,
	   VacationHours,
	   SickLeaveHours
from AdventureWorks2017.HumanResources.Employee


/*
b) Iz tabela Purchasing.PurchaseOrderHeader i Purchasing.Vendor baze AdventureWorks2017 u 
tabelu nabavka importovati podatke po sljedećem pravilu:
	- PurchaseOrderID -> nabavkaID
	- Status -> status
	- EmployeeID -> radnikID
	- AccountNumber -> br_racuna
	- Name -> naziv_nabavljaca
	- CreditRating -> kred_rejting
*/

insert into nabavka
select poh.PurchaseOrderID,
	   poh.Status,
	   poh.EmployeeID,
	   v.AccountNumber,
	   v.Name,
	   v.CreditRating
from AdventureWorks2017.Purchasing.PurchaseOrderHeader as poh
inner join AdventureWorks2017.Purchasing.Vendor as v on poh.VendorID = v.BusinessEntityID


/*
c) Iz tabela Sales.SalesPerson i Sales.SalesTerritory baze AdventureWorks2017 u tabelu prodaja
 importovati podatke po sljedećem pravilu:
	- BusinessEntityID -> prodavacID
	- SalesQuota -> prod_kvota
	- Bonus -> bonus
	- SalesLastYear iz Sales.SalesPerson -> proslogod_prodaja
	- Name -> naziv_terit
*/

insert into prodaja
select sp.BusinessEntityID,
	   sp.SalesQuota,
	   sp.Bonus,
	   sp.SalesLastYear,
	   st.Name
from AdventureWorks2017.Sales.SalesPerson as sp 
inner join AdventureWorks2017.Sales.SalesTerritory as st on sp.TerritoryID = st.TerritoryID






--10 bodova

------------------------------------------
/*
3.
a) Iz tabela radnik i nabavka kreirati pogled view_drzavaID koji će imati sljedeću strukturu: 
	- nabavkaID,
	- loginID,
	- status
	- naziv nabavljača,
	- kreditni rejting
Uslov je da u pogledu budu zapisi u kojima je kreditni rejting veći od 1.
*/

go
create view view_drzava
as 
select n.nabavkaID,
	   r.loginID,
	   n.status,
	   n.naziv_nabavljaca,
	   n.kred_rejting
from radnik as r
inner join nabavka as n on r.radnikID = n.radnikID
where n.kred_rejting > 1


select * from view_drzava




/*
b) Koristeći prethodno kreirani pogled prebrojati broj obavljenih nabavki prema kreditnom rejtingu.
 Npr. kreditni rejting 8 se pojavljuje 20 puta.
 Pregled treba da sadrži oznaku kreditnog rejtinga i ukupan broj obavljenih nabavki.
*/

select kred_rejting, COUNT(nabavkaID) as prebrojano_nabavki
from view_drzava
group by kred_rejting








--10 bodova


-----------------------------------------------
/*
4.
Kreirati proceduru koja će imati istu strukturu kao pogled kreiran u prethodnom zadatku. 
Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti), 
uz uslov da je status veći od 2. Pokrenuti proceduru za kreditni rejting 3 i 5.
*/
--10 bodova

go
create procedure proc_kred_rejting
(
	@nabavkaID int = null,
	@loginID nvarchar(256) = null,
	@status int = null,
	@naziv_nabavljaca nvarchar(50) = null,
	@kred_rejting int = null
)
as
begin
	select *
	from view_drzava
	where (nabavkaID = @nabavkaID or loginID = @loginID or naziv_nabavljaca = @naziv_nabavljaca
		   or kred_rejting = @kred_rejting or status = @status) and status > 2
end

exec proc_kred_rejting @kred_rejting = 3;
exec proc_kred_rejting @kred_rejting = 5;




-------------------------------------------
/*
5.
a) Kreirati pogled nabavljaci_radnici koji će se sastojati od 
kolona naziv dobavljača i prebrojani_broj radnika. 
prebrojani_broj je podatak kojim se prebrojava broj radnika s kojima je dobavljač poslovao. 
Obavezno napisati kod kojim će se izvršiti pregled sadržaja pogleda sortiran po ukupnom broju.
*/
go
create view view_nabavljaci_radnici
as
select n.naziv_nabavljaca,COUNT(*) as prebrojani_broj_radnika
from radnik as r
inner join nabavka as n on r.radnikID = n.radnikID
group by n.naziv_nabavljaca

select * from view_nabavljaci_radnici




/*
b) Kreirati proceduru kojom će se iz pogleda kreiranog pod a) 
preuzeti zapisi u kojima je prebrojani_broj manji od 50.
 Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara
  (možemo ostaviti bilo koji parametar bez unijete vrijednosti). 
  Pokrenuti proceduru za vrijednosti prebrojani_broj = 1 i 2.	
*/
--15 bodova

go
create procedure proc_broj_radnika
(
	@naziv_nabavljaca nvarchar(50) = null,
	@prebrojani_broj_radnika int = null
)
as
begin
	select *
	from view_nabavljaci_radnici
	where prebrojani_broj_radnika < 50 and
		  (naziv_nabavljaca = @naziv_nabavljaca or prebrojani_broj_radnika = @prebrojani_broj_radnika)
end


exec proc_broj_radnika @prebrojani_broj_radnika = 1;
exec proc_broj_radnika @prebrojani_broj_radnika = 2;




--------------------------------------------
/*
6.
a) U tabeli radnik dodati kolonu razlika_sati kao cjelobrojnu varijablu sa obaveznom default vrijednošću 0.
*/

alter table radnik
add razlika_sati int constraint DF_razlika_sati default(0)

update radnik
set razlika_sati = 0

select * from radnik

/*
b) U koloni razlika_sati ostaviti 0 ako su sati bolovanja veći od godišnjeg odmora,
inače u kolonu smjestiti vrijednost razlike između sato_bolovanja i sati_god_odmora.
*/
update radnik
set razlika_sati = sati_bolovanja - sati_god_odmora
where sati_bolovanja < sati_god_odmora

select * from radnik



/*
c) Kreirati pogled view_sati u kojem će biti poruka 
da li radnik ima više sati godišnjeg odmora ili bolovanja. 
Ako je više bolovanja daje se poruka "bolovanje", inače "godisnji". 
Pogled treba da sadrži ID radnika i poruku.
*/
--10 bodova
go
create view view_sati
as
select radnikID,'bolovanje' as poruka
from radnik
where sati_bolovanja > sati_god_odmora
union
select radnikID,'godisnji' as poruka
from radnik
where sati_bolovanja < sati_god_odmora


select * from view_sati


-----------------------------------------------
/*
7.
Koristeći tabelu prodaja kreirati pogled view_prodaja sljedeće strukture:
	- prodavacID
	- naziv_terit
	- razlika prošlogodišnje prodaje i srednje vrijednosti prošlogodišnje prodaje.
Uslov je da se dohvate zapisi u kojima je bonus bar za 1000 veći od minimalne vrijednosti bonusa
*/
--10 bodova

go
create view view_prodaja
as
select prodavacID,
	   naziv_terit,
	   proslogod_prodaja - (select AVG(proslogod_prodaja) from prodaja) as razlika
from prodaja
where bonus - 1000 > (select MIN(bonus) from prodaja)

select * from view_prodaja


------------------------------------------
/*
8.
U koloni drzavaID tabele radnik 
izvršiti promjenu svih vrijednosti u kojima je broj cifara neparan broj. 
Promjenu izvršiti tako što će se u umjesto postojećih vrijednosti unijeti slučajno generisani niz znakova.
*/
--10 bodova

update radnik
set drzavaID = left(NEWID(),15)
where LEN(drzavaID) % 2 != 0

select * from radnik


---------------------------------------
/*
9.
Iz tabela nabavka i radnik kreirati pogled view_sifra_transakc koja će se sastojati od sljedećih kolona: 
	- naziv dobavljača,
	- sifra_transakc
Podaci u koloni sifra_transakc će se formirati
spajanjem karaktera imena iz kolone loginID tabele radnik (ime je npr. ken, NE ken0) i
 riječi iz kolone br_racuna (npr. u LITWARE0001 riječ je LITWARE) tabele nabavka, 
 između kojih je potrebno umetnuti donju crtu (_). 
Uslov je da se ne dohvataju duplikati (prikaz jedinstvenih vrijednosti) u koloni sifre_transaks.
Obavezno napisati kod za pregled sadržaja pogleda.
*/
--13 bodova

go
create view view_sifra_transakc
as
select distinct n.naziv_nabavljaca,
	   SUBSTRING(r.loginID,CHARINDEX('\',r.loginID) + 1,len(r.loginID) - CHARINDEX('\',r.loginID) - 1 ) 
	   + '_' 
	   + LEFT(n.br_racuna,LEN(n.br_racuna) - 4) as sifra_transakc
from radnik as r
inner join nabavka as n on r.radnikID = n.radnikID

select * from view_sifra_transakc


-----------------------------------------------
--10.
/*
Kreirati backup baze na default lokaciju, obrisati bazu, a zatim izvršiti restore baze. 
Uslov prihvatanja koda je da se može izvršiti.
*/
--2 boda

