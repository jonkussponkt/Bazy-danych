
--Przypisujemy nowemu schematowi 'ksiegowosc' tabele z poprzedniego schematu 'rozliczenia'

USE firma;
CREATE SCHEMA ksiegowosc;

ALTER SCHEMA ksiegowosc TRANSFER rozliczenia.godziny;
ALTER SCHEMA ksiegowosc TRANSFER rozliczenia.pensje;
ALTER SCHEMA ksiegowosc TRANSFER rozliczenia.pracownicy;
ALTER SCHEMA ksiegowosc TRANSFER rozliczenia.premie;

-- Tworzenie tabeli

CREATE TABLE ksiegowosc.wynagrodzenie(ID_wynagrodzenia VARCHAR(3) PRIMARY KEY NOT NULL, data_wyplaty DATE, 
			ID_pracownika INTEGER NOT NULL, ID_godziny INTEGER, ID_pensji INTEGER NOT NULL, 
			ID_premii INTEGER);

ALTER TABLE ksiegowosc.godziny ADD FOREIGN KEY (ID_pracownika) REFERENCES rozliczenia.pracownicy(ID_pracownika)

-- Dodajemy klucze obce

ALTER TABLE ksiegowosc.wynagrodzenie
	ADD FOREIGN KEY (ID_pracownika) REFERENCES ksiegowosc.pracownicy(ID_pracownika);

ALTER TABLE ksiegowosc.wynagrodzenie
	ADD FOREIGN KEY (ID_godziny) REFERENCES ksiegowosc.godziny(ID_godziny);

ALTER TABLE ksiegowosc.wynagrodzenie
	ADD FOREIGN KEY (ID_pensji) REFERENCES ksiegowosc.pensje(ID_pensji);

ALTER TABLE ksiegowosc.wynagrodzenie
	ADD FOREIGN KEY (ID_premii) REFERENCES ksiegowosc.premie(ID_premii);

-- Dodawanie komentarzy do poszczegolnych tabel

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ilosc przepracowanych godzin przez poszczegolnych pracownikow',
		@level0type = N'SCHEMA', @level0name = N'ksiegowosc', @level1type = N'TABLE', @level1name = N'godziny';

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dane o poszczegolnych pracownikach',
		@level0type = N'SCHEMA', @level0name = N'ksiegowosc', @level1type = N'TABLE', @level1name = N'pracownicy';

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pensje poszczegolnych pracownikow',
		@level0type = N'SCHEMA', @level0name = N'ksiegowosc', @level1type = N'TABLE', @level1name = N'pensje';

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Premie poszczegolnych pracownikow',
		@level0type = N'SCHEMA', @level0name = N'ksiegowosc', @level1type = N'TABLE', @level1name = N'premie';

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Wynagrodzenia poszczegolnych pracownikow',
		@level0type = N'SCHEMA', @level0name = N'ksiegowosc', @level1type = N'TABLE', @level1name = N'wynagrodzenie';

--Dodawanie rekordow do tabeli 'wynagrodzenie'

INSERT INTO ksiegowosc.wynagrodzenie 
	(ID_wynagrodzenia, data_wyplaty, ID_pracownika, ID_godziny, ID_pensji, ID_premii) 
VALUES 
	('W01', '20200503', 1, 2, 1001, 2001),
	('W02', '20200918', 2, 7, 1002, 2002),
	('W03', '20200707', 3, 4, 1003, 2003),
	('W04', '20200629', 4, 5, 1004, 2004),
	('W05', '20200628', 5, 8, 1005, 2005),
	('W06', '20200601', 6, 9, 1006, 2006),
	('W07', '20200528', 7, 1, 1007, 2007),
	('W08', '20200311', 8, 3, 1008, 2008),
	('W09', '20200317', 9, 4, 1009, 2009),
	('W10', '20200713', 10, 10, 1010, 2010);

-- 6a ID pracownika oraz jego nazwisko ZROBIONE

SELECT ID_pracownika, Nazwisko FROM ksiegowosc.pracownicy

--6b ID pracowników, których p³aca jest wiêksza ni¿ 4000 ZROBIONE

SELECT ID_pracownika
	FROM ksiegowosc.wynagrodzenie
		INNER JOIN ksiegowosc.pensje
			ON ksiegowosc.pensje.ID_pensji = ksiegowosc.wynagrodzenie.ID_pensji AND ksiegowosc.pensje.kwota_netto > 4000

--6c ID pracowników bez premii z p³ac¹ > 2000 ZROBIONE

INSERT INTO ksiegowosc.pracownicy VALUES (11, 'Stanislaw', 'Olejnik', 'Warszawa, D³uga 92', '245-229-238');
INSERT INTO ksiegowosc.godziny VALUES (11, '2020-05-01', 161, 11);
INSERT INTO ksiegowosc.pensje VALUES (1011, 'Brygadzista', 3900, NULL, 3900 - 3900 * 0.19);
INSERT INTO ksiegowosc.wynagrodzenie VALUES ('W11', '2020-03-17', 11, 11, 1011, NULL);

SELECT ID_pracownika FROM ksiegowosc.wynagrodzenie 
	INNER JOIN ksiegowosc.pensje
			ON ksiegowosc.pensje.ID_pensji = ksiegowosc.wynagrodzenie.ID_pensji AND ksiegowosc.pensje.kwota_netto > 2000
					INNER JOIN ksiegowosc.premie
						ON NOT EXISTS (SELECT * FROM ksiegowosc.premie WHERE ksiegowosc.premie.ID_premii = ksiegowosc.pensje.ID_premii)
						GROUP BY ID_pracownika 

--6d Pracownicy z imieniem na 'J' ZROBIONE

SELECT * FROM ksiegowosc.pracownicy WHERE imie LIKE 'J%'

--6e Pracownicy z liter¹ 'n' oraz imieniem koñcz¹ce siê na 'a' ZROBIONE

SELECT * FROM ksiegowosc.pracownicy WHERE (nazwisko LIKE '%n%' OR nazwisko LIKE 'N%' OR nazwisko LIKE '%n' ) AND imie LIKE '%a'

--6f Pracownicy z wiêksza liczb¹ godzin ni¿ 160 ZROBIONE 

UPDATE ksiegowosc.godziny
SET 
	liczba_godzin = liczba_godzin + 153

SELECT imie, nazwisko, liczba_godzin - 160 AS nadgodziny
	FROM ksiegowosc.pracownicy
		INNER JOIN ksiegowosc.godziny ON ksiegowosc.pracownicy.ID_pracownika = ksiegowosc.godziny.ID_pracownika 
			WHERE ksiegowosc.godziny.liczba_godzin > 160 

--6g  Pracownicy z pensj¹ w przedziale 1500-3000 ZROBIONE

SELECT imie, nazwisko FROM ksiegowosc.pracownicy 
	INNER JOIN ksiegowosc.wynagrodzenie ON ksiegowosc.wynagrodzenie.ID_pracownika = ksiegowosc.pracownicy.ID_pracownika
	INNER JOIN ksiegowosc.pensje ON ksiegowosc.pensje.ID_pensji = ksiegowosc.wynagrodzenie.ID_pensji
	WHERE ksiegowosc.pensje.kwota_netto >= 1500 AND ksiegowosc.pensje.kwota_netto <= 3000

--6h Pracownicy z nadgodzinami bez premii ZROBIONE

SELECT imie, nazwisko FROM ksiegowosc.pracownicy
	INNER JOIN ksiegowosc.wynagrodzenie ON ksiegowosc.wynagrodzenie.ID_godziny = ksiegowosc.pracownicy.ID_pracownika
	INNER JOIN ksiegowosc.pensje ON ksiegowosc.pensje.ID_pensji = ksiegowosc.wynagrodzenie.ID_pensji
		INNER JOIN ksiegowosc.premie ON NOT EXISTS (SELECT ID_premii FROM ksiegowosc.premie WHERE ksiegowosc.premie.ID_premii = ksiegowosc.pensje.ID_premii)
			GROUP BY imie, nazwisko

--6i Pracownicy wg pensji ZROBIONE

SELECT imie, nazwisko, kwota_netto FROM ksiegowosc.pracownicy 
	INNER JOIN ksiegowosc.wynagrodzenie ON ksiegowosc.pracownicy.ID_pracownika = ksiegowosc.wynagrodzenie.ID_pracownika
	INNER JOIN ksiegowosc.pensje ON ksiegowosc.wynagrodzenie.ID_pensji = ksiegowosc.pensje.ID_pensji
	--SELECT ksiegowosc.pracownicy.ID_pracownika, imie, nazwisko
	ORDER BY ksiegowosc.pensje.kwota_netto  DESC

--6j Pracownicy wg premii malej¹co ZROBIONE

SELECT imie, nazwisko FROM ksiegowosc.pracownicy 
	INNER JOIN ksiegowosc.wynagrodzenie ON ksiegowosc.pracownicy.ID_pracownika = ksiegowosc.wynagrodzenie.ID_pracownika
	INNER JOIN ksiegowosc.pensje ON ksiegowosc.wynagrodzenie.ID_pensji = ksiegowosc.pensje.ID_pensji
	INNER JOIN ksiegowosc.premie ON ksiegowosc.pensje.ID_premii = ksiegowosc.premie.ID_premii
	--SELECT ksiegowosc.pracownicy.ID_pracownika, imie, nazwisko
	ORDER BY ksiegowosc.premie.kwota, ksiegowosc.pensje.kwota_netto  DESC

--6k Zlicz i pogrupuj wg pola stanowisko ZROBIONE 

SELECT COUNT(stanowisko) AS LICZBA, stanowisko
FROM ksiegowosc.pensje
GROUP BY stanowisko

--6l Œrednia, minimalna i maksymalna p³aca dla stanowiska ZROBIONE

SELECT AVG(kwota_netto) AS ŒREDNIA, stanowisko
FROM ksiegowosc.pensje
WHERE stanowisko = 'Brygadzista'
GROUP BY stanowisko

SELECT MIN(kwota_netto) AS MINIMUM, stanowisko
FROM ksiegowosc.pensje
WHERE stanowisko = 'Brygadzista'
GROUP BY stanowisko

SELECT MAX(kwota_netto) AS MAXIMUM, stanowisko
FROM ksiegowosc.pensje
WHERE stanowisko = 'Brygadzista'
GROUP BY stanowisko

--6m Suma wszystkich wynagrodzeñ ZROBIONE

SELECT SUM(ksiegowosc.pensje.kwota_netto + ksiegowosc.premie.kwota) AS SUMA
FROM ksiegowosc.wynagrodzenie INNER JOIN ksiegowosc.pensje ON ksiegowosc.wynagrodzenie.ID_pensji=ksiegowosc.pensje.ID_pensji
INNER JOIN ksiegowosc.premie on ksiegowosc.wynagrodzenie.ID_premii = ksiegowosc.pensje.ID_premii

--6f Suma wynagrodzeñ w ramach danego stanowiska ZROBIONE 

SELECT SUM(kwota_netto) AS SUMA, stanowisko
FROM ksiegowosc.pensje
GROUP BY stanowisko

--6g Liczba premii przyznanych w ramach danego stanowiska ZROBIONE

SELECT COUNT(stanowisko) AS liczba_premii, stanowisko
FROM ksiegowosc.pensje
INNER JOIN ksiegowosc.premie ON ksiegowosc.pensje.ID_premii = ksiegowosc.premie.ID_premii AND ksiegowosc.premie.ID_premii IS NOT NULL
GROUP BY stanowisko

--6h Usuwanie pracowników z p³ac¹ < 1200 z³otych

--ALTER TABLE ksiegowosc.pracownicy 
INSERT INTO ksiegowosc.pracownicy VALUES (12, 'Jaroslawa', 'Madejska', 'Bia³ystok, ul.Graniczna 1', '890-249-438')
INSERT INTO ksiegowosc.godziny VALUES (12, '20200505', 167, 12)
INSERT INTO ksiegowosc.pensje VALUES(1012, 'Sekretarz', 1200, NULL, 1200 - 1200 * 0.19)
INSERT INTO ksiegowosc.wynagrodzenie VALUES('W12', '20200930', 12, 12, 1012, NULL)

--SELECT * FROM ksiegowosc.pracownicy

DELETE ksiegowosc.pracownicy FROM ksiegowosc.pracownicy
INNER JOIN ksiegowosc.wynagrodzenie ON ksiegowosc.wynagrodzenie.ID_pracownika = ksiegowosc.pracownicy.ID_pracownika
INNER JOIN ksiegowosc.pensje ON ksiegowosc.wynagrodzenie.ID_pensji = ksiegowosc.pensje.ID_pensji
WHERE ksiegowosc.pensje.kwota_netto < 1200

SELECT * from ksiegowosc.godziny
SELECT * from ksiegowosc.pensje
SELECT * from ksiegowosc.pracownicy
SELECT * from ksiegowosc.premie
SELECT * from ksiegowosc.wynagrodzenie