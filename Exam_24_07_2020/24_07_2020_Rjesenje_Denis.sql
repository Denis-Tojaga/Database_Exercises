--1) Zadatak
--a)
create database ispit_24_07_2020
go

use ispit_24_07_2020
go


--b)
create table radnik
(
	radnikID int constraint PK_radnikID primary key,
	drzavaID nvarchar(15),
	loginID nvarchar(256),
	god_rod int,
	spol nvarchar(1)
)


create table nabavka 
(
	nabavkaID int constraint PK_nabavkaID primary key,
	status int, 
	radnikID int constraint FK_radnikID foreign key(radnikID) references radnik(radnikID),
	br_racuna nvarchar(15),
	naziv_dobavljaca nvarchar(50),
	kred_rejting int
)



create table prodaja
(
	prodajaID int constraint PK_prodajaID primary key identity(1,2),
	prodavacID int constraint FK_prodavacID foreign key(prodavacID) references radnik(radnikID),
	dtm_isporuke datetime,
	vrij_poreza money,
	ukup_vrij money,
	online_narudzba bit
)





--2) Zadatak

--a)
insert into radnik
select BusinessEntityID,
	   NationalIDNumber,
	   LoginID,
	   YEAR(BirthDate),
	   Gender
from AdventureWorks2017.HumanResources.Employee

--b)
insert into nabavka
select poh.PurchaseOrderID,
	   poh.Status,
	   poh.EmployeeID,
	   v.AccountNumber,
	   v.Name,
	   v.CreditRating
from AdventureWorks2017.Purchasing.PurchaseOrderHeader as poh 
inner join AdventureWorks2017.Purchasing.Vendor as v on poh.VendorID = v.BusinessEntityID



--c)
insert into prodaja
select SalesPersonID,
	   ShipDate,
	   TaxAmt,
	   TotalDue,
	   OnlineOrderFlag
from AdventureWorks2017.Sales.SalesOrderHeader







--3) Zadatak

--a)
alter table radnik
add st_kat nvarchar(3)

--b)
update radnik
set st_kat = case
				 when YEAR(GETDATE()) - god_rod <=30 then 'I'
				 when YEAR(GETDATE()) - god_rod between 31 and 49 then 'II'
				 else 'III'
			 end

select * from radnik


--c)
select 'Broj radnika koji imaju 10 ili manje godina do penzije je ' + CONVERT(nvarchar,COUNT(*)) as poruka
from radnik
where 65 - (YEAR(GETDATE()) - god_rod) between 1 and 10











--4) Zadatak

--a)
alter table prodaja
add stopa_poreza nvarchar(10)

--b)
update prodaja
set stopa_poreza = convert(nvarchar,vrij_poreza/ukup_vrij) + '%'

select * from prodaja







--5) Zadatak

--a)
--grupisati po slovnom dijelu kolone i po tome prebrojati koliko se pojavljuje zapisa
go
create view view_slova
as
select LEFT(br_racuna, len(br_racuna) - 4) as broj_slova,
	   count(*) as prebrojano_zapisa
from nabavka
group by LEFT(br_racuna, len(br_racuna) - 4)


--b)
select broj_slova,prebrojano_zapisa, prebrojano_zapisa - (select AVG(prebrojano_zapisa) from view_slova) as razlika
from view_slova
order by 3









--6) Zadatak
--a)
go
create view view_stopa
as
select prodajaID,stopa_poreza,convert(float,left(stopa_poreza,len(stopa_poreza) - 1)) as stopa_num
from prodaja


--b)
select 'manji', stopa_num - (select AVG(stopa_num)  from view_stopa) as razlika
from view_stopa
where stopa_num - (select AVG(stopa_num)  from view_stopa) < (select AVG(stopa_num)  from view_stopa)
union
select 'veci', stopa_num - (select AVG(stopa_num)  from view_stopa) as razlika
from view_stopa
where stopa_num - (select AVG(stopa_num)  from view_stopa) > (select AVG(stopa_num)  from view_stopa)











--7)
go
create procedure proc_stopa_poreza
(
	@prodajaID int = null,
	@stopa_poreza nvarchar(10) = null,
	@stopa_num float = null
)
as
begin
	select stopa_poreza,COUNT(*)
	from view_stopa
	where prodajaID = @prodajaID or
		  stopa_poreza = @stopa_poreza or
		  (stopa_num = @stopa_num and stopa_num > 10)
	group by stopa_poreza
end



exec proc_stopa_poreza 1;
exec proc_stopa_poreza 15;
exec proc_stopa_poreza 21;










--8) Zadatak

--prvo izmjena tipa podatka kolone online_narudzba da bi mogli staviti YES ili NO
alter table prodaja
alter column online_narudzba nvarchar(3)


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


--svaki check expression mora biti u zagradama
alter table prodaja
add constraint CK_online_narudzba check (online_narudzba = 'YES' or online_narudzba = 'NO')


select * from prodaja























--9) Zadatak

--a)
--uslov je da je god_rod manja od godine trenutnog datuma
alter table radnik
add constraint CK_god_rod_2 check (god_rod < YEAR(GETDATE()))


--testiranje constrainta
insert into radnik
values (20000, 'A', 'A', 2500, 'M', 'I');







--b)

--prvo postaviti da svi podaci budu 7 karaktera ili manji
update radnik
set drzavaID = left(drzavaID,7)

--i nakon toga kreirati ogranicenje(ogranicenje provjeri i postojece i nove koje dodajemo podatke)
alter table radnik
add constraint CK_drzavaID check (len(drzavaID)  <= 7)


--testiranje constrainta
INSERT INTO radnik
VALUES (20000, '12345678', 'A', 1980, 'M', 'I');




--10) NIJE RADJEN OVE GODINE






