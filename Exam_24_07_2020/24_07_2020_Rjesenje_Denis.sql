--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.
*/

create database privremena
go

use privremena
go





/*
--Prilikom kreiranja tabela voditi racuna o medjusobnom odnosu izmedju tabela.

a) Kreirati tabelu radnik koja ce imati sljedecu strukturu:
	-radnikID, cjelobrojna varijabla, primarni kljuc
	-drzavaID, 15 unicode karaktera
	-loginID, 256 unicode karaktera
	-god_rod, cjelobrojna varijabla
	-spol, 1 unicode karakter
*/
	
create table radnik
(
	radnikID int constraint PK_radnikID primary key,
	drzavaID nvarchar(15),
	loginID nvarchar(256),
	god_rod int,
	spol nvarchar(1)
)




/*
b) Kreirati tabelu nabavka koja ce imati sljedecu strukturu:
	-nabavkaID, cjelobrojna varijabla, primarni kljuc
	-status, cjelobrojna varijabla
	-radnikID, cjelobrojna varijabla
	-br_racuna, 15 unicode karaktera
	-naziv_dobavljaca, 50 unicode karaktera
	-kred_rejting, cjelobrojna varijabla
*/

create table nabavka
(
	nabavkaID int constraint PK_nabavkaID primary key,
	status int,
	radnikID int constraint FK_radnikID foreign key(radnikID) references radnik(radnikID),
	br_racuna nvarchar(15),
	naziv_dobavljaca nvarchar(50),
	kred_rejting int
)




/*
c) Kreirati tabelu prodaja koja ce imati sljedecu strukturu:
	-prodajaID, cjelobrojna varijabla, primarni kljuc, inkrementalno punjenje sa pocetnom vrijednoscu 1, samo neparni brojevi
	-prodavacID, cjelobrojna varijabla
	-dtm_isporuke, datumsko-vremenska varijabla
	-vrij_poreza, novcana varijabla
	-ukup_vrij, novcana varijabla
	-online_narudzba, bit varijabla sa ogranicenjem kojim se mogu unijeti samo cifre 0 i 1

*/

create table prodaja
(
	prodajaID int constraint PK_prodajaID primary key identity(1,2),
	prodavacID int constraint FK_prodavacID foreign key(prodavacID) references radnik(radnikID),
	dtm_isporuke datetime,
	vrij_poreza money,
	ukup_vrij money,
	online_narudzba bit
)






/*
--2
Import podataka

a) Iz tabele Employee iz šeme HumanResources baze AdventureWorks2017 u tabelu radnik importovati podatke
 po sljedecem pravilu:
	-BusinessEntityID -> radnikID
	-NationalIDNumber -> drzavaID
	-LoginID -> loginID
	-godina iz kolone BirthDate -> god_rod
	-Gender -> spol
*/

insert into radnik
select BusinessEntityID,
	   NationalIDNumber,
	   LoginID,
	   YEAR(BirthDate) as god_rod,
	   Gender
from AdventureWorks2017.HumanResources.Employee






/*
b) Iz tabela PurchaseOrderHeader i Vendor šeme Purchasing baze AdventureWorks2017 u tabelu nabavka
	importovati podatke po sljedecem pravilu:
	-PurchaseOrderID -> dobavljanjeID
	-Status -> status
	-EmployeeID -> radnikID
	-AccountNumber -> br_racuna
	-Name -> naziv_dobavljaca
	-CreditRating -> kred_rejting
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
c) Iz tabele SalesOrderHeader šeme Sales baze AdventureWorks2017 u tabelu prodaja
	importovati podatke po sljedecem pravilu:
	-SalesPersonID -> prodavacID
	-ShipDate -> dtm_isporuke
	-TaxAmt -> vrij_poreza
	-TotalDue -> ukup_vrij
	-OnlineOrderFlag -> online_narudzba
*/

insert into prodaja
select SalesPersonID,
	   ShipDate,
	   TaxAmt,
	   TotalDue,
	   OnlineOrderFlag
from AdventureWorks2017.Sales.SalesOrderHeader






/*
--3
a) U tabelu radnik dodati kolonu st_kat (starosna kategorija), tipa 3 karaktera.
*/

alter table radnik
add st_kat nvarchar(3)

select * from radnik



/*

b) Prethodno kreiranu kolonu popuniti po principu:
	starosna kategorija			uslov
	I							osobe do 30 godina starosti (ukljucuje se i 30)
	II							osobe od 31 do 49 godina starosti
	III							osobe preko 50 godina starosti
*/

update radnik
set st_kat = case when YEAR(getdate()) - god_rod <= 30 then 'I'
				  when YEAR(getdate()) - god_rod between 31 and 49 then 'II'
				  when YEAR(getdate()) - god_rod >= 50 then 'III'
				  end

select * from radnik




/*

c) Neka osoba sa navrsenih 65 godina odlazi u penziju.
Prebrojati koliko radnika ima 10 ili manje godina do penzije.
Rezultat upita iskljucivo treba biti poruka:
'Broj radnika koji imaju 10 ili manje godina do penzije je' nakon cega slijedi prebrojani broj.
Nece se priznati rjesenje koje kao rezultat upita vraca vise kolona.
*/

select 'Broj radnika koji imaju 10 ili manje godina do penzije je ' + CONVERT(nvarchar,COUNT(*)) as poruka
from (select *
	  from radnik
	  where 65 - (YEAR(getdate()) - god_rod) between 1 and 10) as podTab





/*
--4
a) U tabeli prodaja kreirati kolonu stopa_poreza (10 unicode karaktera)
*/

alter table prodaja
add stopa_poreza nvarchar(10)

select * from prodaja




/*
b) Prethodno kreiranu kolonu popuniti kao kolicnik vrij_poreza i ukup_vrij.
Stopu poreza izraziti kao cijeli broj s oznakom %,
 pri cemu je potrebno da izmedju brojcane vrijednosti i znaka % bude prazno mjesto.
(Npr: 14.00 %)
*/

update prodaja
set stopa_poreza = Convert(nvarchar,(vrij_poreza / ukup_vrij )* 100) + ' %'

select * from prodaja



/*
--5
a) Koristeci tabelu nabavka kreirati pogled view_slova sljedece strukture:
	-slova
	-prebrojano, prebrojani broj pojavljivanja slovnih dijelova podatka u koloni br_racuna.
*/

go
create view view_slova
as
select len(LEFT(br_racuna,len(br_racuna) - 4)) as slova,
	   COUNT(*) as prebrojano
from nabavka
group by len(LEFT(br_racuna,len(br_racuna) - 4))


select * from view_slova


/*
b) Koristeci pogled view_slova odrediti razliku vrijednosti izmedju prebrojanih i srednje vrijednosti kolone.
Rezultat treba da sadrzi kolone slova, prebrojano i razliku.
Sortirati u rastucem redoslijedu prema razlici.
*/

select *,prebrojano - (select AVG(prebrojano) from view_slova) as razlika
from view_slova
order by 3




/*
--6
a) Koristeci tabelu prodaja kreirati pogled view_stopa sljedece strukture:
	-prodajaID
	-stopa_poreza
	-stopa_num, u kojoj ce biti numericka vrijednost stope poreza
*/
go
create view view_stopa
as
select prodajaID,
	   stopa_poreza,
	   convert(real,left(stopa_poreza,len(stopa_poreza)-1)) as stopa_num
from prodaja





/*
b) Koristeci pogled view_stopa, 
a na osnovu razlike izmedju vrijednosti u koloni stopa_num i srednje vrijednosti stopa poreza
za svaki proizvodID navesti poruku 'manji', odnosno, 'veci'.
*/


--koristimo union all da se ukljuce i duplikati
select 'manji',ROUND(stopa_num - (select AVG(stopa_num) from view_stopa),2) as razlika
from view_stopa
where stopa_num - (select AVG(stopa_num) from view_stopa) < (select AVG(stopa_num) from view_stopa)
union all
select 'veci',ROUND(stopa_num - (select AVG(stopa_num) from view_stopa),2) as razlika
from view_stopa
where stopa_num - (select AVG(stopa_num) from view_stopa) > (select AVG(stopa_num) from view_stopa)

--drugi nacin rjesenja
select *,
	  case
		  when stopa_num - (select AVG(stopa_num) from view_stopa) < (select AVG(stopa_num) from view_stopa) then 'manji'
		  when stopa_num - (select AVG(stopa_num) from view_stopa) > (select AVG(stopa_num) from view_stopa) then 'veci'
		  end
from view_stopa






/*
--7 
Koristeci pogled view_stopa_poreza kreirati proceduru proc_stopa_poreza tako da je
 prilikom izvrsavanja moguce unijeti bilo koji broj
parametara (mozemo ostaviti bilo koji parametar bez unijete vrijednosti), 
pri cemu ce se prebrojati broj zapisa po stopi poreza uz 
uslov da se dohvate samo oni zapisi u kojima je stopa poreza veca od 10%.
Proceduru pokrenuti za sljedece vrijednosti:
	-stopa poreza = 12, 15 i 21
*/


--postavka zadatka nema nekog prevelikog smisla :/
go
alter procedure pro_stopa_poreza
(
	@prodajaID int = null,
	@stopa_poreza nvarchar(10) = null,
	@stopa_num real = null
)
as
begin
	select stopa_poreza,COUNT(*) 
	from view_stopa
	where (prodajaID = @prodajaID or left(stopa_poreza,charindex('.',stopa_poreza) - 1) = @stopa_poreza or stopa_num = @stopa_num) 
		  and convert(int,left(stopa_poreza,charindex('.',stopa_poreza) - 1)) > 10
	group by stopa_poreza
end

exec pro_stopa_poreza @stopa_poreza = 12;
exec pro_stopa_poreza @stopa_poreza = 15;
exec pro_stopa_poreza @stopa_poreza = 21;









/*
--8
Kreirati proceduru proc_prodaja kojom ce se izvrsiti promjena vrijednosti u koloni online_narudzba tabele prodaja.
Promjena ce se vrsiti tako sto ce se 0 zamijeniti sa NO, a 1 sa YES.
Pokrenuti proceduru kako bi se izvrsile promjene, a nakon toga onemoguciti da se u koloni unosi bilo kakva druga vrijednost
 osim NO ili YES.
*/

go
create procedure proc_prodaja
as
begin
	
	alter table prodaja
	alter column online_narudzba nvarchar(3)

	update prodaja
	set online_narudzba = case 
							  when online_narudzba = 0 then 'NO'
							  when online_narudzba = 1 then 'YES'
							  end
end

exec proc_prodaja;
select * from prodaja

alter table prodaja
add constraint CK_online_narudzba check (online_narudzba = 'NO' or online_narudzba='YES')

--testiranje
update prodaja
set online_narudzba = 'eee'
where prodajaID = 1








/*

--9
a) Nad kolonom god_rod tabele radnik kreirati ogranicenje kojim ce se onemoguciti unos bilo koje godine iz buducnosti
 kao godina rodjenja.
Testirati funkcionalnost kreiranog ogranicenja navodjenjem koda za insert podataka kojim ce se kao godina rodjenja 
pokusati unijeti bilo koja godina iz buducnosti.
*/


alter table radnik
add constraint CK_god_rod check(god_rod<=YEAR(getdate()))

--testiranje
update radnik
set god_rod = 2025
where radnikID = 1


/*
b) Nad kolonom drzavaID tabele radnik kreirati ogranicenje kojim ce se ograniciti duzina podatka na 7 znakova.
Ako je prethodno potrebno, izvrsiti prilagodbu kolone, 
pri cemu nije dozvoljeno prilagodjavati podatke cija duzina iznosi 7 ili manje znakova.
Testirati funkcionalnost kreiranog ogranicenja 
navodjenjem koda za insert podataka kojim ce se u drzavaID pokusati unijeti podatak duzi 
od 7 znakova.
*/

update radnik
set drzavaID = LEFT(drzavaID,7)
where LEN(drzavaID) > 7

alter table radnik
add constraint CK_drzava_ID check (len(drzavaID) <= 7)

--testiranje
update radnik
set drzavaID = 29584720
where radnikID = 1


/*
--10
Kreirati backup baze na default lokaciju, obrisati bazu a zatim izvrsiti restore baze. 
Uslov prihvatanja koda je da se moze izvrsiti.
--NIJE RADJEN OVE GODINE