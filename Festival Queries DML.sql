--Query te thjeshta me nje tabele
--1. Selektoni te gjitha ID-te e rezervimit me numrin 8 nga tabela Konfirmimi
select *
from Konfirmimi
where ID_Rezervimi = 8

--2. Selektoni te gjithe antaret e publikut qe jane meshkuj
select *
from Publiku
where Gjinia like 'M'

--3. Selektoni te gjitha qmimet e tiketave qe jane me te medha se 50.70 dhe shafqni moshat e tyre
select Cmimi, mosha
from Tiketa 
where Cmimi > 50.70


--4. Selektoni te gjithe ekipet ndertuese te cilat kane 80 deri ne 200 punetor dhe shfaqni emrin e kompanise   
select Emri, NrPuntoreve
from Ekipi_Ndertues
where NrPuntoreve >= 80 and NrPuntoreve <= 200 


--Qyery te thjeshta me dy tabela
--1. Selektoni numrin e leternjoftimit, gjinine, numrin kontaktues dhe datene rezervimit per te gjithe ata persona qe kane bere konfirmim
select p.Nr_Leternjoftimit, p.Gjinia, k.Nr_Kontaktues, r.DataRezervimit 
from Publiku p, Konfirmimi k, Rezervimi r
where p.Nr_Leternjoftimit = k.Nr_Leternjoftimit and r.ID_Rezervimi = k.ID_Rezervimi

--2. Selektoni ID e skenes, numrin e hyrjes dhe ID e ekipit ndertues pe te gjitha skenat
select s.ID_Skena, s.Nr_Hyrjeve, e.ID_EkipiNdertues 
from Skena s, Ndertimi n, Ekipi_Ndertues e
where s.ID_Skena = n.ID_EkipiNdertues and e.ID_EkipiNdertues = n.ID_EkipiNdertues

--3. Selektoni daten e rezervimit dhe kuponin fiskal per te gjitha pagesat
select r.DataRezervimit, p.Kuponi_Fiskal
from Rezervimi r, Pagesa p
where r.ID_Rezervimi = p.ID_Rezervimi

--4. Selektoni qytetin, hapesiren dhe ID e skenes per te gjitha lokacionet e skenave
select n.ID_Skena, l.Qyteti, l.Hapesira 
from Lokacioni l, Ndertimi n
where l.ID_Lokacioni = n.ID_Lokacioni


--Qyery te acancuara me dy e me shume tabela
--1. Shfaqni numrin e leternjoftimit te personave qe kane blere me shume se 2 
select b.Nr_Leternjoftimit, b.NrBlerjeve 
from Tiketa t inner join Blerja b
on t.QR_Code = b.QR_Code
where b.NrBlerjeve > 2



--2. Te shfaqen ID e Rezervimit per personat te cilat kane rezervuar dhe nuk kane rezervuar,
	-- te paraqiten me emer dhe numer te leternjoftimit
select p.Nr_Leternjoftimit, p.emri, k.ID_Rezervimi 
from Publiku p left outer join Konfirmimi k
on p.Nr_Leternjoftimit = k.Nr_Leternjoftimit

--3. Shaqni antarin e sigurimit me ID 4 dhe personat te cilet ai i ka kontrolluar 
select  s.S_ID, s.Emri, s.Mbiemri, s.Pozita, k.Nr_Leternjoftimit
from Sigurimi s right outer join Kontrolla k
on s.S_ID = k.S_ID
where s.S_ID = 4

--4. Te shfaqen te gjithe antare e publikut qe kane bere konfirmim dhe ata qe nuk kane bere konfirmim,
	-- dukemi perfshi edhe informatat e rezervimit
select *
from Publiku p full join Konfirmimi k
on p.Nr_Leternjoftimit = k.Nr_Leternjoftimit 
full join Rezervimi r 
on k.ID_Rezervimi = r.ID_Rezervimi


--Subquery te thjeshta
--1. Shfaqni moshat qe kane blere tiketat me te shtrejta
select t.mosha 
from Tiketa t
where t.Cmimi = (select max(t.Cmimi)
				from Tiketa t)


--2. Shfaqni Performuesit sipas emrit Artistik dhe numrit te kengeve te tyre
select p.EmriArtistik, (select k.Nr_Kengeve from Kengetari k
where k.ID_Performuesi = p.ID_Performuesi) as [numri i kengeve]
from Performuesi p 

--3. Shfaqni emrat e artisteve dhe ID e skenave se ku ata do te performojne
select p.EmriArtistik, p.ID_Skena
from Performuesi p
where p.ID_Skena in (select p.ID_Skena 
					      from Skena s
						  where p.ID_Skena = s.ID_Skena)


--4. Shfaqni emrin e ekipit ndertues me numerin me te vogel te puntorve
select e.Emri 
from Ekipi_Ndertues e
where e.NrPuntoreve = (select min(e.NrPuntoreve) as [Numri puntoreve]
						from Ekipi_Ndertues e) 


--Subquery te avancuara
--1. Shfaqni ID e personave te cilet kane bere blerje te biletave me te shtrejta se sa 80.50
select b.Nr_Leternjoftimit, b.NrBlerjeve
from Blerja b
where exists (select b.NrBlerjeve, t.Cmimi
			  from Tiketa t
			  where b.QR_Code = t.QR_Code and t.Cmimi > 80.50)


--2. Te shfaqen tiketat te cilat kane qmim me te madh se mesatarja e blerjeve sipas numrit te blerjeve
select t.QR_Code, t.Cmimi
from Tiketa t
where t.Cmimi >any(select avg(t.Cmimi)
				   from Tiketa t, Blerja b
                   where t.QR_Code = b.QR_Code
                   group by b.NrBlerjeve)


--3. Mesataren e qmimit te tiketave me te vogla se mesatarja e blerjeve te pergjithshme
with AvgCmimi as (select avg(t.Cmimi) as [Qmimi mesatar]
				  from Tiketa t)
select avg(t.Cmimi) as [Qmimi mesatar]
from blerja b, Tiketa t
where b.QR_Code = t.QR_Code
group by b.Nr_Leternjoftimit
having avg(t.Cmimi) <= all(select a.[Qmimi mesatar] 
						   from AvgCmimi a)


--4. Te shfaqen tiketat te cilat kane qmim me te vogel se mesatarja e blerjeve sipas numrit te blerjeve
select t.QR_Code, t.Cmimi
from Tiketa t
where t.Cmimi <any(select avg(t.Cmimi)
				   from Tiketa t, Blerja b
                   where t.QR_Code = b.QR_Code
                   group by b.NrBlerjeve)



--Query me operacione te algjebres relacionare
--1. Shfaqni Kodin e Tiketave te personave qe jane mbi moshen vjecare
create view Mosha18 as
select t.QR_Code
from Tiketa t
where t.mosha > 18
select *
from Mosha18

--2. Listoni numrin e leternjoftimit te personave qe kane qmimin me te madh se 100, por jo edhe ata me 300
Create view QmimiShitje as
select s.Nr_Leternjoftimit
from Shitje s
where s.Cmimi >100
except
select s.Nr_Leternjoftimit
from Shitje s
where s.Cmimi = 300
select *
from QmimiShitje


--3. Te shfaqet ID e skenes dhe numri kontaktues per artistet me emrin "Beast" dhe "Moon" 
select p.ID_Skena, p.NumriKontaktues
from Performuesi p
where p.EmriArtistik = 'Beast'
union 
select p.ID_Skena, p.NumriKontaktues
from Performuesi p
where p.EmriArtistik = 'Moon'



--4. Shfaqni Qyetin dhe Rrugen e Lokacionit dhe Skenes qe kane perputhje te ID've te caktuara
select l.Qyteti, l.Rruga
from Lokacioni l INNER JOIN Skena s on
l.ID_Skena = s.ID_Skena and l.ID_Skena = 4
intersect
select l.Qyteti, l.Rruga
from Lokacioni l INNER JOIN Skena s on
l.ID_Skena = s.ID_Skena and s.ID_Skena = 4



--Procedura te ruajtura
--1. Krijoni një stored procedure qe shfaq detajet e kompanise ne baze te inputit qe eshte emri i CEO.
create procedure
getKompaniaByCEO(@CEO varchar(30))
as 
begin
select *
from Kompania_Biletave k
where k.CEO like @CEO
end

exec getKompaniaByCeo  'David Anderson'


--2. Stored Procedure me Input/Output qe kthen numrin e telefonit te performuesit, varesisht ID's te cilen i dergon
create procedure GetPerformerContact (@Id int, @Contact varchar(20) output)
as
begin
   select @Contact = NumriKontaktues
   from Performuesi
   where ID_Performuesi = @Id
end

declare @output_parameter varchar(20);
exec GetPerformerContact '5', @output_parameter output;
select @output_parameter as [Numri_Telefonit];



--3. Beni update statusin VIP bazuar ne CR_Code qe i jepni
CREATE PROCEDURE UpdateVIP (@QR_Code INT, @VIP CHAR(1))
AS
BEGIN
  IF (@VIP NOT IN ('T', 'F'))
    RAISERROR ('Invalid VIP status', 16, 1)

  UPDATE Tiketa
  SET VIP = @VIP
  WHERE QR_Code = @QR_Code
END;

EXEC UpdateVIP @QR_Code = 1000, @VIP = 'F'


--4. Shfaqni detajet e pageses varesisht ID te rezervimtit qe i jepni si input 
CREATE PROCEDURE GetPagesa (@RezervimiID INT)
AS
BEGIN
    IF EXISTS (SELECT * FROM Pagesa WHERE ID_Rezervimi = @RezervimiID)
    BEGIN
        SELECT *
        FROM Pagesa
        WHERE ID_Rezervimi = @RezervimiID
    END
    ELSE
    BEGIN
        PRINT 'Nuk u gjend Rezervim me kete ID: ' + CAST(@RezervimiID AS VARCHAR(10))
    END
END

EXEC GetPagesa @RezervimiID = 8






--Query gjat mbrojtjes
--1
select t.QR_Code, t.Rregullt, t.VIP 
from Tiketa t

--2
select t.QR_Code, p.Emri, p.Mbiemri
from Publiku p , Blerja b, Tiketa t
where p.Nr_Leternjoftimit = b.Nr_Leternjoftimit and b.QR_Code = t.QR_Code

--3
select s.ID_Skena, count(p.EmriArtistik) as [numri i performuesve]
from Skena s inner join Performuesi p
on  s.ID_Skena = p.ID_Skena
group by s.ID_Skena

select * from Skena
select * from Performuesi



