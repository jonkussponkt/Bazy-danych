--1. Utwórz now¹ bazê danych nazywaj¹c j¹ firma.

CREATE DATABASE firma;

--2. Dodaj nowy schemat o nazwie rozliczenia.

USE firma;  --ustawia bie¿¹c¹ bazê danych na firma
CREATE SCHEMA rozliczenia; 

--3. Dodawanie tabel

--typy danych: MONEY --https://docs.microsoft.com/en-us/sql/t-sql/data-types/money-and-smallmoney-transact-sql?view=sql-server-ver15

CREATE TABLE rozliczenia.pracownicy(id_pracownika INTEGER NOT NULL PRIMARY KEY, imie VARCHAR(50), nazwisko VARCHAR(50), adres VARCHAR(100), telefon VARCHAR(12));
CREATE TABLE rozliczenia.godziny(id_godziny INTEGER NOT NULL PRIMARY KEY, data_godziny DATE, liczba_godzin REAL, id_pracownika INTEGER NOT NULL);
CREATE TABLE rozliczenia.pensje(id_pensji INTEGER NOT NULL PRIMARY KEY, stanowisko VARCHAR(100), kwota MONEY, id_premii INTEGER);
CREATE TABLE rozliczenia.premie(id_premii INTEGER NOT NULL PRIMARY KEY, rodzaj VARCHAR(100), kwota MONEY);

--klucze - coœ co jednoznacznie odró¿nia krotkê w tabeli od innych:
-- * g³ówny - PRIMARY KEY
-- * obcy - FOREIGN KEY kolumna w tabeli, która pasuje do klucza w innej

ALTER TABLE rozliczenia.godziny 
ADD FOREIGN KEY (id_pracownika) REFERENCES rozliczenia.pracownicy(id_pracownika) ON DELETE CASCADE;

ALTER TABLE rozliczenia.pensje
ADD FOREIGN KEY (id_premii) REFERENCES rozliczenia.premie(id_premii) ON DELETE CASCADE;

--4. Wype³nianie tabel rekordami

INSERT INTO rozliczenia.pracownicy
VALUES
(1, 'Janusz', 'Kowalski', 'Warszawa, ul.Jaœminowa 22', '130-256-982'),
(2, 'Gra¿yna', 'Komornicka', 'Kraków, ul.D³uga 17', '984-882-918');

INSERT INTO rozliczenia.pracownicy
VALUES
(3, 'Mateusz', 'Nowak', 'Lublin, ul.Krakowska 9', '784-278-835'),
(4, 'Hubert', 'Maciejewski', 'Gdañsk, ul.Gdyñska 56a/19', '823-589-938'),
(5, 'Damian', 'S³owik', 'Berlin, ul.Warschaustrasse 1,', '873-452-882'),
(6, 'Jan', 'Migacz', 'Kraków, Rondo Mogilskie 8', '771-356-582'),
(7, 'Katarzyna', '¯ak', 'Kraków, ul.Nowohucka 199/40a', '123-456-789');

SELECT * FROM rozliczenia.pracownicy;

INSERT INTO rozliczenia.godziny
VALUES
--(1, '2022-03-29', 24.5, 1),
(2, '2022-03-04', 8, 2),
--(3, '2022-02-02', 10, 3),
(4, '2022-02-28', 9.79, 4),
(5, '2021-12-30', 3, 5),
(6, '2022-03-01', 7, 6),
(7, '2022-03-05', 9, 7);

SELECT * FROM rozliczenia.godziny;

--

INSERT INTO rozliczenia.premie
VALUES
(1, 'Za wszystko', 7000),
(3, 'Kwartalna', 3000),
(4, 'Kwartalna', 2600),
(5, 'Miesiêczna', 1400),
(6, 'Œwi¹teczna', 1000);
--najpierw musz¹ byæ dodane dane do tabeli rozliczenia.premie a dopiero potem do rolziczenia.pensje, 
--bo klucz obcy w 2 tabelu musi siê odnosiæ do istniej¹cego elementu z tabeli premie
INSERT INTO rozliczenia.pensje
VALUES
--(1, 'CEO', 19999.99, 1),
--(3, 'Pracownik produkcji', 5490.99, 3),
(4, 'Brygadzista', 3478.01, 4),
(5, 'Wiceprezes', 13459.34, 5),
(6, 'Mistrz', 10145.67, 6);

INSERT INTO rozliczenia.pensje
VALUES
(2, 'Pracownik produkcji', 2347.67, null),
(7, 'Pracownik produkcji', 5300, null);

--5. Za pomoc¹ zapytania SQL wyœwietl nazwiska pracowników i ich adresy.

SELECT nazwisko, adres FROM rozliczenia.pracownicy

--6. Napisz zapytanie, które przekonwertuje datê w tabeli godziny tak, aby wyœwietlana by³a informacja jaki 
--   to dzieñ tygodnia i jaki miesi¹c (funkcja DATEPART x2).

SELECT DATEPART(WEEKDAY, data_godziny) AS 'Dzieñ tygodnia', DATEPART(MONTH, data_godziny) AS Miesi¹c
FROM rozliczenia.godziny

--https://docs.microsoft.com/en-us/sql/t-sql/functions/datepart-transact-sql?view=sql-server-ver15

--7. W tabeli pensje zmieñ nazwê atrybutu kwota na kwota_brutto oraz dodaj nowy o nazwie kwota_netto. 

EXEC sp_rename 'rozliczenia.pensje.kwota', 'kwota_brutto', 'COLUMN';
--https://docs.microsoft.com/en-us/sql/relational-databases/tables/rename-columns-database-engine?view=sql-server-ver15
--https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-rename-transact-sql?view=sql-server-ver15

ALTER TABLE rozliczenia.pensje
ADD kwota_netto MONEY;

--   Oblicz kwotê netto i zaktualizuj wartoœci w tabeli.

UPDATE rozliczenia.pensje
SET kwota_netto =  kwota_brutto * 0.83;
SELECT * FROM rozliczenia.pensje;