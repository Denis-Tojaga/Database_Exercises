/*
Napomena:

1. Prilikom bodovanja rješenja prioritet ima razultat koji treba upit da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, jer ni ta rješenja ne mogu vratiti tačan rezultat 
(broj zapisa, vrijednosti agregatnih funkcija...).

2. Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
Shodno navedenom na uvidu se ne prihvata prigovor da je neki dio koda posljedica previda ("nisam vidio", "slučajno sam to napisao"...) 
*/


/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/

create database ispit_05_09_2019_GrupaA
go

use ispit_05_09_2019_GrupaA
go




/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID, cjelobrojna varijabla, primarni ključ
	dtm_narudzbe, datumska varijabla za unos samo datuma
	dtm_isporuke, datumska varijabla za unos samo datuma
	prevoz, novčana varijabla
	klijentID, 5 unicode karaktera
	klijent_naziv, 40 unicode karaktera
	prevoznik_naziv, 40 unicode karaktera
*/

create table narudzba
(
	narudzbaID int constraint PK_narudzbaID primary key,
	dtm_narudzbe date,
	dtm_isporuke date,
	prevoz money,
	klijentID nvarchar(5),
	klijent_naziv nvarchar(40),
	prevoznik_naziv nvarchar(40)
)


/*
II. Kreirati tabelu proizvod sljedeće strukture:
	- proizvodID, cjelobrojna varijabla, primarni ključ
	- mj_jedinica, 20 unicode karaktera
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_web, tekstualna varijabla
*/

create table proizvod
(
	proizvodID int constraint PK_proizvodID primary key,
	mj_jedinica nvarchar(20),
	jed_cijena money,
	kateg_naziv nvarchar(15),
	dobavljac_naziv nvarchar(40),
	dobavljac_web text
)


/*
III. Kreirati tabelu narudzba_proizvod sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- proizvodID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/

create table narudzba_proizvod
(
	narudzbaID int,
	proizvodID int,
	uk_cijena money,
	constraint PK_narudzba_proizvod_id primary key(narudzbaID,proizvodID),
	constraint FK_narudzba_proizvod_narudzbaID foreign key(narudzbaID) references narudzba(narudzbaID),
	constraint FK_narudzba_proizvod_proizvodID foreign key(proizvodID) references proizvod(proizvodID),
)




-------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Customers, Orders i Shipers baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- Freight -> prevoz
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/

insert into narudzba
select o.OrderID,
	   o.OrderDate,
	   o.ShippedDate,
	   o.Freight,
	   c.CustomerID,
	   c.CompanyName,
	   s.CompanyName as prevoznik
from Northwind.dbo.Customers as c
inner join Northwind.dbo.Orders as o on c.CustomerID = o.CustomerID
inner join Northwind.dbo.Shippers as s on o.ShipVia = s.ShipperID

/*
b) Iz tabela Categories, Product i Suppliers baze Northwind importovati podatke prema pravilu:
	- ProductID -> proizvodID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- HomePage -> dobavljac_web
*/


insert into proizvod
select p.ProductID,
	   p.QuantityPerUnit,
	   p.UnitPrice,
	   c.CategoryName,
	   s.CompanyName,
	   s.HomePage
from Northwind.dbo.Products as p 
inner join Northwind.dbo.Categories as c on p.CategoryID = c.CategoryID
inner join Northwind.dbo.Suppliers as s on p.SupplierID = s.SupplierID


/*
c) Iz tabele Order Details baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> proizvodID
	- uk_cijena <- proizvod jedinične cijene i količine
uz uslov da nije odobren popust na proizvod.
*/

insert into narudzba_proizvod
select OrderID,
	   ProductID,
	   Quantity * UnitPrice as uk_cijena
from Northwind.dbo.[Order Details] 
where Discount = 0



--10 bodova


-------------------------------------------------------------------
/*
3. 
Koristeći tabele proizvod i narudzba_proizvod kreirati pogled view_kolicina koji će imati strukturu:
	- proizvodID
	- kateg_naziv
	- jed_cijena
	- uk_cijena
	- kolicina - količnik ukupne i jedinične cijene
U pogledu trebaju biti samo oni zapisi kod kojih količina ima smisao (nije moguće da je na stanju 1,23 proizvoda).
Obavezno pregledati sadržaj pogleda.
*/


go
create view view_kolicina
as
select p.proizvodID,
	   p.kateg_naziv,
	   p.jed_cijena,
	   np.uk_cijena,
	   uk_cijena / jed_cijena as kolicina
from proizvod as p
inner join narudzba_proizvod as np on p.proizvodID = np.proizvodID
where uk_cijena / jed_cijena % 10 = 0

select * from view_kolicina


--7 bodova


-------------------------------------------------------------------
/*
4. 
Koristeći pogled kreiran u 3. zadatku kreirati proceduru
 tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće nazive kategorija:
1. Produce
2. Beverages
*/

go
create procedure proc_kategorije
(
	@proizvodID int=null,
	@kateg_naziv nvarchar(15) = null,
	@jed_cijena money = null,
	@uk_cijena money = null,
	@kolicina money = null
)
as
begin
	select *
	from view_kolicina
	where proizvodID = @proizvodID or kateg_naziv = @kateg_naziv
		  or jed_cijena = @jed_cijena or uk_cijena = @uk_cijena or
		  kolicina = @kolicina
end


exec proc_kategorije @kateg_naziv = 'Produce';
exec proc_kategorije @kateg_naziv = 'Beverages';





--8 bodova

------------------------------------------------
/*
5.
Koristeći pogled kreiran u 3. zadatku kreirati proceduru proc_br_kat_naziv koja će vršiti prebrojavanja po nazivu kategorije. 
Nakon kreiranja pokrenuti proceduru.
*/

go
create procedure proc_br_kat_naziv
as
begin
	select kateg_naziv,COUNT(*) as prebrojano
	from view_kolicina
	group by kateg_naziv
end

exec proc_br_kat_naziv;


-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba_proizvod kreirati pogled view_suma sljedeće strukture:
	- narudzbaID
	- suma - sume ukupne cijene po ID narudžbe
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati srednja vrijednost sume zaokružena na dvije decimale.
c) Iz pogleda kreiranog pod a) dati pregled zapisa čija je suma veća od prosječne sume. Osim kolona iz pogleda, 
potrebno je prikazati razliku sume i srednje vrijednosti. 
Razliku zaokružiti na dvije decimale.
*/

--a)
go
create view view_suma
as
select narudzbaID,
	   SUM(uk_cijena) as suma
from narudzba_proizvod
group by narudzbaID

select * from view_suma

--b)
select ROUND(AVG(suma),2) as srednja_vrijednost from view_suma


--c)
select *,ROUND(suma - (select AVG(suma) from view_suma),2) as razlika
from view_suma
where suma > (select AVG(suma) as srednja_vrijednost from view_suma)

--15 bodova


-------------------------------------------------------------------
/*
7.
a) U tabeli narudzba dodati kolonu evid_br, 30 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone evid_br na sljedeći način:
	- ako u datumu isporuke nije unijeta vrijednost, evid_br se dobija generisanjem slučajnog niza znakova
	- ako je u datumu isporuke unijeta vrijednost, evid_br se dobija spajanjem datum narudžbe i datuma isprouke uz umetanje donje crte između datuma
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/

--a)
alter table narudzba
add evid_br nvarchar(30)

--b)
go
create procedure proc_punjenje
as
begin
	update narudzba
	set evid_br = case 
						when dtm_isporuke is null then LEFT(newid(),30)
						when dtm_isporuke is not null then CONVERT(nvarchar,dtm_narudzbe) + '_' + CONVERT(nvarchar,dtm_isporuke)
				  end
end

exec proc_punjenje;
select * from narudzba


--15 bodova


-------------------------------------------------------------------
/*
8. Kreirati proceduru kojom će se dobiti pregled sljedećih kolona:
	- narudzbaID,
	- klijent_naziv,
	- proizvodID,
	- kateg_naziv,
	- dobavljac_naziv
Uslov je da se dohvate samo oni zapisi u kojima naziv kategorije sadrži samo 1 riječ.
Pokrenuti proceduru.
*/

go
create procedure proc_pregled
as
begin
	select n.narudzbaID,
		   n.klijent_naziv,
		   p.proizvodID,
		   p.kateg_naziv,
		   p.dobavljac_naziv
	from narudzba as n
	inner join narudzba_proizvod as np on n.narudzbaID = np.narudzbaID
	inner join proizvod as p on p.proizvodID = np.proizvodID
	where CHARINDEX(' ',p.kateg_naziv) = 0 and CHARINDEX('/',p.kateg_naziv) = 0
end

exec proc_pregled;


--10 bodova


-------------------------------------------------------------------
/*
9.
U tabeli proizvod izvršiti update kolone dobavljac_web tako da se iz kolone dobavljac_naziv uzme prva riječ, 
a zatim se formira web adresa u formi www.prva_rijec.com. 
Update izvršiti pomoću dva upita, vodeći računa o broju riječi u nazivu. 
*/

--prvi upit

--ako kolona ima vise od jedne rijeci uzmemo samo prvu
--ukoliko ima samo jednu rijec uzmemo tu citavu rijec
update proizvod
set dobavljac_web = case 
						when CHARINDEX(' ',dobavljac_naziv) != 0 then LEFT(dobavljac_naziv,CHARINDEX(' ',dobavljac_naziv) - 1)
						when CHARINDEX(' ',dobavljac_naziv) = 0 then dobavljac_naziv
					end

select * from proizvod


--drugi upit
update proizvod
set dobavljac_web = 'www.' + convert(nvarchar,dobavljac_web) + '.com'

select * from proizvod

-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/


--NIJE RADJENO

