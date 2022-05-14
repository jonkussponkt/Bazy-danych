


CREATE TABLE rozliczenia.wynagrodzenie (id_wynagrodzenia INTEGER NOT NULL PRIMARY KEY, data_wyplaty DATE, id_pracownika INTEGER NOT NULL, 
							id_godziny INTEGER NOT NULL, id_pensji INTEGER NOT NULL, id_premii INTEGER);

ALTER TABLE rozliczenia.wynagrodzenie
ADD FOREIGN KEY (id_pracownika) REFERENCES rozliczenia.pracownicy(id_pracownika) ON DELETE CASCADE;

ALTER TABLE rozliczenia.wynagrodzenie
ADD FOREIGN KEY (id_godziny) REFERENCES rozliczenia.godziny(id_godziny) ON DELETE CASCADE;

ALTER TABLE rozliczenia.wynagrodzenie
ADD FOREIGN KEY (id_pensji) REFERENCES rozliczenia.pensje(id_pensji) ON DELETE CASCADE;

ALTER TABLE rozliczenia.wynagrodzenie
ADD FOREIGN KEY (id_premii) REFERENCES rozliczenia.premie(id_premii) ON DELETE CASCADE;


-- 4.Dodaj opisy/komentarze dla ka¿dej tabeli – u¿yj polecenia COMMENT

EXEC sp_addextendedproperty @name = N'comment', @value = 'Przepracowane godziny',
							@level0type = N'Schema', @level0name = 'rozliczenia',
							@level1type = N'Table', @level1name = 'godziny'

EXEC sp_addextendedproperty @name = N'Comment', @value = 'Wyp³acone pensje',
							@level0type = N'Schema', @level0name = 'rozliczenia',
							@level1type = N'Table', @level1name = 'pensje'

EXEC sp_addextendedproperty @name = N'comment', @value='Zatrudnieni pracownicy',
							@level0type = N'Schema', @level0name = 'rozliczenia',
							@level1type = N'Table', @level1name = 'pracownicy'

EXEC sp_addextendedproperty @name = N'comment', @value = 'Wyp³acone premie',
							@level0type = N'Schema', @level0name = 'rozliczenia',
							@level1type = N'Table', @level1name = 'premie'							

EXEC sp_addextendedproperty @name=N'comment', @value='Wyp³acone wynagrodzenia',
							@level0type = N'schema', @level0name='rozliczenia',
							@level1type = N'table', @level1name='wynagrodzenie'

SELECT * FROM sys.extended_properties;
SELECT * FROM sys.fn_listextendedproperty ('comment', 'schema', 'rozliczenia', 'table', 'godziny', NULL, NULL);
--argumenty: @name, @level0type, @level0name, @level1type, @level1name, @level2type, @level2name

--https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-listextendedproperty-transact-sql?view=sql-server-ver15

--https://www.mssqltips.com/sqlservertip/5384/working-with-sql-server-extended-properties/
--https://www.mssqltips.com/sqlservertip/5384/working-with-sql-server-extended-properties/
-----------
--a) Wyœwietl tylko id pracownika oraz jego nazwisko.

SELECT id_pracownika, nazwisko FROM rozliczenia.pracownicy;

--b) Wyœwietl id pracowników, których p³aca jest wiêksza ni¿ 10000.

SELECT id_pracownika FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pracownika = id_pensji
WHERE kwota_netto > 10000

--INNER JOIN 

--c) Wyœwietl id pracowników nieposiadaj¹cych premii, których p³aca jest wiêksza ni¿ 3000.

SELECT * FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pracownika = id_pensji
WHERE id_premii IS NULL AND kwota_netto > 3000

--https://towardsdatascience.com/how-to-solve-the-ambiguous-name-column-error-in-sql-d4c256f3d14c

--d) Wyœwietl pracowników, których pierwsza litera imienia zaczyna siê na literê ‘J’.

SELECT * FROM rozliczenia.pracownicy
WHERE imie LIKE 'J%'
--https://www.sqlservertutorial.net/sql-server-basics/sql-server-like/

SELECT * FROM rozliczenia.pracownicy
WHERE imie LIKE '[A-J]%'

--e) Wyœwietl pracowników, których nazwisko zawiera literê ‘n’ oraz imiê koñczy siê na literê ‘a’.
USE firma;
INSERT INTO rozliczenia.pracownicy VALUES (8, 'Jadwiga', 'Muszyna', 'Krynica-Zdrój','123-654-938');
SELECT * FROM rozliczenia.pracownicy
WHERE nazwisko LIKE '%n%a' --AND imie LIKE '%a'
--https://www.sqlshack.com/t-sql-regex-commands-in-sql-server/

--f) Wyœwietl imiê i nazwisko pracowników oraz liczbê ich nadgodzin, przyjmuj¹c, i¿ standardowy czas pracy to 8

SELECT imie, nazwisko, liczba_godzin - 8 AS nadgodziny FROM rozliczenia.pracownicy a
INNER JOIN rozliczenia.godziny b ON a.id_pracownika = b.id_pracownika
WHERE liczba_godzin > 8

--g) Wyœwietl imiê i nazwisko pracowników, których pensja zawiera siê w przedziale 4500 – 12000 PLN.

SELECT * FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pracownika = id_pensji
WHERE kwota_netto BETWEEN 4500 AND 12000

--i) Uszereguj pracowników wed³ug pensji.

SELECT * FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pracownika = id_pensji
ORDER BY kwota_netto DESC

--by default: ascending - domyœlnie order by porz¹dkuje rosn¹co od najmniejszej do najwiêkszej

--j) Uszereguj pracowników wed³ug pensji i premii malej¹co.

SELECT rozliczenia.pracownicy.*, kwota_netto FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje p1 ON id_pracownika = id_pensji
INNER JOIN rozliczenia.premie p2 ON p1.id_premii = p2.id_premii
ORDER BY kwota_netto DESC

--k) Zlicz i pogrupuj pracowników wed³ug pola ‘stanowisko’.

SELECT COUNT(*) AS iloœæ,stanowisko FROM rozliczenia.pensje GROUP BY stanowisko ORDER BY iloœæ DESC;

--l) Policz œredni¹, minimaln¹ i maksymaln¹ p³acê dla stanowiska ‘kierownik’ (je¿eli takiego nie masz, to przyjmij dowolne inne).

SELECT * FROM rozliczenia.pensje;

SELECT AVG(kwota_netto) AS œrednia, MIN(kwota_netto) AS minimum, MAX(kwota_netto) AS maximum, stanowisko
FROM rozliczenia.pensje 
--WHERE stanowisko = 'Pracownik produkcji' 
GROUP BY stanowisko
HAVING stanowisko = 'Pracownik produkcji'

--Najpierw WHERE a potem GROUP BY

--m) Policz sumê wszystkich wynagrodzeñ.

SELECT SUM(kwota_netto) AS suma FROM rozliczenia.pensje;

--n) Policz sumê wynagrodzeñ w ramach danego stanowiska.

SELECT SUM(kwota_netto) AS suma, stanowisko FROM rozliczenia.pensje GROUP BY stanowisko;

--o) Wyznacz liczbê premii przyznanych dla pracowników danego stanowiska.

SELECT * FROM rozliczenia.pensje;
SELECT * FROM rozliczenia.premie;

SELECT COUNT(*),stanowisko FROM rozliczenia.pensje p1
INNER JOIN rozliczenia.premie p2 ON p1.id_pensji = p2.id_premii
GROUP BY stanowisko

--p) Usuñ wszystkich pracowników maj¹cych pensjê mniejsz¹ ni¿ 3000 z³.
SELECT * FROM rozliczenia.pensje
DELETE t FROM rozliczenia.pracownicy 
AS t 
JOIN rozliczenia.pensje ON id_pracownika = id_pensji
WHERE kwota_netto < 3000

DELETE FROM rozliczenia.pensje
WHERE kwota_netto < 3000

--ON DELETE CASCADE: https://www.ibm.com/docs/en/informix-servers/14.10?topic=clause-using-delete-cascade-option

SELECT * FROM rozliczenia.godziny;
SELECT * FROM rozliczenia.pensje;
SELECT * FROM rozliczenia.pracownicy;
SELECT * FROM rozliczenia.premie;