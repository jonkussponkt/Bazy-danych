--1. Tworzenie bazy danych

CREATE DATABASE firma;

--2. Nowy schemat

USE firma;

CREATE SCHEMA rozliczenia;

--3.Nowe cztery tabele

CREATE TABLE rozliczenia.pracownicy(ID_pracownika integer PRIMARY KEY NOT NULL, imie VARCHAR(30), 
			 nazwisko VARCHAR(40) NOT NULL, adres VARCHAR (50), telefon VARCHAR(15));

CREATE TABLE rozliczenia.godziny(ID_godziny integer PRIMARY KEY NOT NULL, data_godziny date, liczba_godzin INTEGER,
								 ID_pracownika integer NOT NULL);

--3.1 dodajemy klucz obcy do tablicy

ALTER TABLE rozliczenia.godziny ADD FOREIGN KEY (ID_pracownika) REFERENCES rozliczenia.pracownicy(ID_pracownika)

CREATE TABLE rozliczenia.pensje(ID_pensji integer PRIMARY KEY NOT NULL, stanowisko VARCHAR(50), kwota FLOAT, ID_premii integer)
CREATE TABLE rozliczenia.premie(ID_premii integer PRIMARY KEY NOT NULL, rodzaj VARCHAR(30), kwota FLOAT)

ALTER TABLE rozliczenia.pensje ADD FOREIGN KEY (ID_premii) REFERENCES rozliczenia.premie(ID_premii)

--4. Nowe rekordy

INSERT INTO rozliczenia.pracownicy VALUES (1, 'Jan', 'Kowalski', 'Warszawa, Prusa 17a', '778-282-249');
INSERT INTO rozliczenia.pracownicy VALUES (2, 'Janina', 'Kowalska', 'Warszawa, Poniatowskiego 94/10', '487-355-829');
INSERT INTO rozliczenia.pracownicy VALUES (3, 'Katarzyna', 'Dworak', 'Kraków, Makowskiego 37/18', '249-545-288');
INSERT INTO rozliczenia.pracownicy VALUES (4, 'Lucjan', 'Janowiec', 'Warszawa, Mokotowska 87b', '398-280-197');
INSERT INTO rozliczenia.pracownicy VALUES (5, 'Stanis³awa', 'Obremska', 'Warszawa, Chmielowa 28b/19', '893-484-292');
INSERT INTO rozliczenia.pracownicy VALUES (6, 'Wies³aw', 'Oleœ', 'Miñsk Mazowiecki, Mickiewicza 8', '398-492-375');
INSERT INTO rozliczenia.pracownicy VALUES (7, 'Krzysztof', 'Malinowski', 'Warszawa, Wlotowa 18', '372-282-489');
INSERT INTO rozliczenia.pracownicy VALUES (8, 'Miros³aw', 'Borowiec', 'Lublin, Zamojska 92c/189', '382-299-385');
INSERT INTO rozliczenia.pracownicy VALUES (9, 'Aleksander', 'Zaborski', 'Szczecin, Gdañska 1', '193-284-382');
INSERT INTO rozliczenia.pracownicy VALUES (10, 'Ludmi³a', 'Wronecka', 'Warszawa, Krótka 39', '537-224-981');

INSERT INTO rozliczenia.godziny VALUES (1, '20200528', 2, 7);
INSERT INTO rozliczenia.godziny VALUES (2, '20200503', 8, 1);
INSERT INTO rozliczenia.godziny VALUES (3, '20200311', 4, 8);
INSERT INTO rozliczenia.godziny VALUES (4, '20200317', 4, 9);
INSERT INTO rozliczenia.godziny VALUES (5, '20200629', 8, 4);
INSERT INTO rozliczenia.godziny VALUES (6, '20200707', 5, 3);
INSERT INTO rozliczenia.godziny VALUES (7, '20200918', 6, 7);
INSERT INTO rozliczenia.godziny VALUES (8, '20200628', 8, 5);
INSERT INTO rozliczenia.godziny VALUES (9, '20200601', 3, 6);
INSERT INTO rozliczenia.godziny VALUES (10, '20200713', 6, 10);

INSERT INTO rozliczenia.pensje VALUES (1001, 'Prezes', 15000, 2001);
INSERT INTO rozliczenia.pensje VALUES (1002, 'Wiceprezes', 12500, 2002);
INSERT INTO rozliczenia.pensje VALUES (1003, 'Cz³onek zarz¹du', 10000, 2003);
INSERT INTO rozliczenia.pensje VALUES (1004, 'Ksiêgowy', 8000, 2004);
INSERT INTO rozliczenia.pensje VALUES (1005, 'Pracownik HR', 7500, 2005);
INSERT INTO rozliczenia.pensje VALUES (1006, 'Brygadzista', 5000, 2006);
INSERT INTO rozliczenia.pensje VALUES (1007, 'Pracownik produkcyjny', 3500, 2007);
INSERT INTO rozliczenia.pensje VALUES (1008, 'Pracownik produkcyjny', 3500, 2008);
INSERT INTO rozliczenia.pensje VALUES (1009, 'Pracownik produkcyjny', 3500, 2009);
INSERT INTO rozliczenia.pensje VALUES (1010, 'Pracownik produkcyjny', 3500, 2010);

INSERT INTO rozliczenia.premie VALUES (2001, 'Miesiêczna', 4000);
INSERT INTO rozliczenia.premie VALUES (2002, 'Miesiêczna', 3000);
INSERT INTO rozliczenia.premie VALUES (2003, 'Kwartalna', 2500);
INSERT INTO rozliczenia.premie VALUES (2004, 'Miesiêczna', 2000);
INSERT INTO rozliczenia.premie VALUES (2005, 'Dodatek motywacyjny', 2000);
INSERT INTO rozliczenia.premie VALUES (2006, 'Dodatek funkcyjny', 2000);
INSERT INTO rozliczenia.premie VALUES (2007, 'Za nadgodziny', 1000);
INSERT INTO rozliczenia.premie VALUES (2008, 'Za nadgodziny', 1000);
INSERT INTO rozliczenia.premie VALUES (2009, 'Za nadgodziny', 1000);
INSERT INTO rozliczenia.premie VALUES (2010, 'Za nadgodziny', 1000);

--5 Wybór rekordów 

SELECT nazwisko, adres FROM rozliczenia.pracownicy

--6 Konwersja daty

SELECT DATEPART(weekday, data_godziny), DATEPART(month, data_godziny) FROM rozliczenia.godziny

--7. Zmiana nazwy kolumny funkcj¹ która dzia³a w MS SQL SERVER

sp_rename 'rozliczenia.pensje.kwota', 'kwota_brutto', 'COLUMN';

--Dodanie nowej kolumny

ALTER TABLE rozliczenia.pensje ADD kwota_netto INTEGER;

--Przypisanie nowych wartosci do nowejh kolumny

UPDATE rozliczenia.pensje
SET 
	kwota_netto = kwota_brutto - (kwota_brutto * 0.19)