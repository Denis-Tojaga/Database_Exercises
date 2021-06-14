--1) Zadatak

create database ispit_23_06_2020
go

use ispit_23_06_2020
go





--2) Zadatak


create table dobavljac
(
	dobavljac_id int constraint PK_dobavljac_id primary key,
	dobavljac_br_rac nvarchar(50),
	naziv_dobavljaca nvarchar(50),
	kred_rejting int
)



create table narudzba
(
	narudzba_id int,
	narudzba_detalj_id int,
	dobavljac_id int constraint FK_dobavljac_id foreign key(dobavljac_id) references dobavljac(dobavljac_id),
	dtm_narudzbe date,
	naruc_kolicina int,
	cijena_proizvoda money,
	constraint PK_narudzba_narudzba_detalj primary key(narudzba_id,narudzba_detalj_id)
)



create table dobavljac_proizvod
(
	proizvod_id int,
	dobavljac_id int,
	proiz_naziv nvarchar(50),
	serij_oznaka_proiz nvarchar(50),
	razlika_min_max int,
	razlika_max_narudzba int,
	constraint PK_proizvod_dobavljac_id primary key(proizvod_id,dobavljac_id),
	constraint FK_dobavljac_proiz_id foreign key(dobavljac_id) references dobavljac(dobavljac_id)
)




--3) Zadatak

--a)
insert into dobavljac
select BusinessEntityID,
	   AccountNumber,
	   Name,
	   CreditRating
from AdventureWorks2017.Purchasing.Vendor



--b)
insert into narudzba
select poh.PurchaseOrderID,
	   pod.PurchaseOrderDetailID,
	   poh.VendorID,
	   poh.OrderDate,
	   pod.OrderQty,
	   pod.UnitPrice
from AdventureWorks2017.Purchasing.PurchaseOrderHeader as poh
inner join AdventureWorks2017.Purchasing.PurchaseOrderDetail as pod on poh.PurchaseOrderID = pod.PurchaseOrderID


--c)
insert into dobavljac_proizvod
select p.ProductID,
	   pv.BusinessEntityID,
	   p.Name,
	   p.ProductNumber,
	   pv.MaxOrderQty - pv.MinOrderQty as razlika_min_max,
	   pv.MaxOrderQty - pv.OnOrderQty as razlika_max_narudzba
from AdventureWorks2017.Production.Product as p
inner join AdventureWorks2017.Purchasing.ProductVendor as pv on p.ProductID = pv.ProductID
where p.ProductSubcategoryID is not null







--4) Zadatak
go
create view view_dob_god
as
select d.dobavljac_id,
	   dp.proizvod_id,
	   n.naruc_kolicina,
	   n.cijena_proizvoda,
	   n.naruc_kolicina * n.cijena_proizvoda as ukupno
from dobavljac as d
inner join narudzba as n on d.dobavljac_id = n.dobavljac_id
inner join dobavljac_proizvod as dp on d.dobavljac_id = dp.dobavljac_id
where (YEAR(n.dtm_narudzbe) = 2013 or YEAR(n.dtm_narudzbe) = 2014) and d.dobavljac_br_rac like  '%1'


select * from view_dob_god






--5) Zadatak
go
create procedure proc_dob_god
(
	@naruc_kolicina int
)
as
begin
	select dobavljac_id,
		   proizvod_id,
		   SUM(ukupno) as suma_ukupno
	from view_dob_god
	where @naruc_kolicina between 100 and 999 and naruc_kolicina = @naruc_kolicina
	group by dobavljac_id,proizvod_id
end


exec proc_dob_god @naruc_kolicina = 300;














--6) Zadatak

--a)
select * into dobavljac_proizvod_nova
from dobavljac_proizvod


--b)
alter table dobavljac_proizvod_nova
drop column razlika_min_max

select * from dobavljac_proizvod_nova


--c)
--prvo napraviti kolonu
alter table dobavljac_proizvod_nova
add razlika int


--zatim setovati vrijednost
--*NAPOMENA ne zaboraviti end na kraju case-a
update dobavljac_proizvod_nova
set razlika = case
				   when razlika_max_narudzba is null then 0
				   else razlika_max_narudzba - (select AVG(razlika_max_narudzba) from dobavljac_proizvod_nova)
				   end

select * from dobavljac_proizvod_nova







--7) Zadatak

--prvi nacin
select 'Razlicitih serijskih oznaka proizvoda koje zavrsavaju slovom engleskog alfabeta ima: ' as poruka,
		COUNT(*) as broj_zapisa
from dobavljac_proizvod
where RIGHT(serij_oznaka_proiz,1) not in ('0','1','2','3','4','5','6','7','8','9')
union
select 'Razlicitih serijskih oznaka proizvoda koje NE zavrsavaju slovom engleskog alfabeta ima: ' as poruka,
		COUNT(*) as broj_zapisa
from dobavljac_proizvod
where RIGHT(serij_oznaka_proiz,1) in ('0','1','2','3','4','5','6','7','8','9')



--drugi nacin preko podupita
select 'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima: ' + 
		CONVERT(NVARCHAR,(SELECT COUNT(*) FROM dobavljac_proizvod WHERE serij_oznaka_proiz LIKE '%[A-Za-z]'))
		AS Zavrsavaju,
	   'Različitih serijskih oznaka proizvoda koje NE završavaju slovom engleskog alfabeta ima: ' + 
		CONVERT(NVARCHAR,(SELECT COUNT(*) FROM dobavljac_proizvod WHERE serij_oznaka_proiz NOT LIKE '%[A-Za-z]')) AS Ne_Zavrsavaju










--8) Zadatak

--a)
select LEN(serij_oznaka_proiz)  as duzina_podatka
from dobavljac_proizvod


--b)
--kreiranje pomocnog upita za izlistavanje (nedupliranih) duzina podataka
go
create view v_pomocni
as
select distinct LEN(serij_oznaka_proiz)  as duzina_podatka
from dobavljac_proizvod

--prebrojavanje svih zapisa iz pomocnog pogleda i to je zapravo trazeni broj
select 'Kolona serij_oznaka_proiz ima ' + CONVERT(nvarchar,(select COUNT(*) from v_pomocni)) + ' razlicite duzine podataka.' as poruka






--9) Zadatak

--NIJE URADJEN

--select *
--from dobavljac

--SELECT dobavljac_br_rac,
--	   LEN(dobavljac_br_rac) as duzina_br_racun,
--	   REPLACE(naziv_dobavljaca, ' ', '') as zamjenjena_mjesta,
--	   LEFT(naziv_dobavljaca,CHARINDEX(' ',naziv_dobavljaca)) as prva_rijec,
--FROM dobavljac







--10)
go
create procedure proc_djeljivi
(
	@prebrojano int
)
as
begin
	select naruc_kolicina,COUNT(*)  as prebrojano_vrijednosti
	from view_dob_god
	where naruc_kolicina % 100 = 0
	group by naruc_kolicina
	having COUNT(*) = @prebrojano
	order by 2
end


exec proc_djeljivi @prebrojano =10;





--11) Zadatak

--NIJE RADJENO



