


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


-- 4.Dodaj opisy/komentarze dla ka�dej tabeli � u�yj polecenia COMMENT

EXEC sp_addextendedproperty @name = N'comment', @value = 'Przepracowane godziny',
							@level0type = N'Schema', @level0name = 'rozliczenia',
							@level1type = N'Table', @level1name = 'godziny'

EXEC sp_addextendedproperty @name = N'Comment', @value = 'Wyp�acone pensje',
							@level0type = N'Schema', @level0name = 'rozliczenia',
							@level1type = N'Table', @level1name = 'pensje'

EXEC sp_addextendedproperty @name = N'comment', @value='Zatrudnieni pracownicy',
							@level0type = N'Schema', @level0name = 'rozliczenia',
							@level1type = N'Table', @level1name = 'pracownicy'

EXEC sp_addextendedproperty @name = N'comment', @value = 'Wyp�acone premie',
							@level0type = N'Schema', @level0name = 'rozliczenia',
							@level1type = N'Table', @level1name = 'premie'							

EXEC sp_addextendedproperty @name=N'comment', @value='Wyp�acone wynagrodzenia',
							@level0type = N'schema', @level0name='rozliczenia',
							@level1type = N'table', @level1name='wynagrodzenie'

SELECT * FROM sys.extended_properties;
SELECT * FROM sys.fn_listextendedproperty ('comment', 'schema', 'rozliczenia', 'table', 'godziny', NULL, NULL);
--argumenty: @name, @level0type, @level0name, @level1type, @level1name, @level2type, @level2name

--https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-listextendedproperty-transact-sql?view=sql-server-ver15

--https://www.mssqltips.com/sqlservertip/5384/working-with-sql-server-extended-properties/
--https://www.mssqltips.com/sqlservertip/5384/working-with-sql-server-extended-properties/
-----------
--a) Wy�wietl tylko id pracownika oraz jego nazwisko.

SELECT id_pracownika, nazwisko FROM rozliczenia.pracownicy;

--b) Wy�wietl id pracownik�w, kt�rych p�aca jest wi�ksza ni� 10000.

SELECT id_pracownika FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pracownika = id_pensji
WHERE kwota_netto > 10000

--INNER JOIN 

--c) Wy�wietl id pracownik�w nieposiadaj�cych premii, kt�rych p�aca jest wi�ksza ni� 3000.

SELECT * FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pracownika = id_pensji
WHERE id_premii IS NULL AND kwota_netto > 3000

--https://towardsdatascience.com/how-to-solve-the-ambiguous-name-column-error-in-sql-d4c256f3d14c

--d) Wy�wietl pracownik�w, kt�rych pierwsza litera imienia zaczyna si� na liter� �J�.

SELECT * FROM rozliczenia.pracownicy
WHERE imie LIKE 'J%'
--https://www.sqlservertutorial.net/sql-server-basics/sql-server-like/

SELECT * FROM rozliczenia.pracownicy
WHERE imie LIKE '[A-J]%'

--e) Wy�wietl pracownik�w, kt�rych nazwisko zawiera liter� �n� oraz imi� ko�czy si� na liter� �a�.
USE firma;
INSERT INTO rozliczenia.pracownicy VALUES (8, 'Jadwiga', 'Muszyna', 'Krynica-Zdr�j','123-654-938');
SELECT * FROM rozliczenia.pracownicy
WHERE nazwisko LIKE '%n%a' --AND imie LIKE '%a'
--https://www.sqlshack.com/t-sql-regex-commands-in-sql-server/

--f) Wy�wietl imi� i nazwisko pracownik�w oraz liczb� ich nadgodzin, przyjmuj�c, i� standardowy czas pracy to 8

SELECT imie, nazwisko, liczba_godzin - 8 AS nadgodziny FROM rozliczenia.pracownicy a
INNER JOIN rozliczenia.godziny b ON a.id_pracownika = b.id_pracownika
WHERE liczba_godzin > 8

--g) Wy�wietl imi� i nazwisko pracownik�w, kt�rych pensja zawiera si� w przedziale 4500 � 12000 PLN.

SELECT * FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pracownika = id_pensji
WHERE kwota_netto BETWEEN 4500 AND 12000

--i) Uszereguj pracownik�w wed�ug pensji.

SELECT * FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pracownika = id_pensji
ORDER BY kwota_netto DESC

--by default: ascending - domy�lnie order by porz�dkuje rosn�co od najmniejszej do najwi�kszej

--j) Uszereguj pracownik�w wed�ug pensji i premii malej�co.

SELECT rozliczenia.pracownicy.*, kwota_netto FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje p1 ON id_pracownika = id_pensji
INNER JOIN rozliczenia.premie p2 ON p1.id_premii = p2.id_premii
ORDER BY kwota_netto DESC

--k) Zlicz i pogrupuj pracownik�w wed�ug pola �stanowisko�.

SELECT COUNT(*) AS ilo��,stanowisko FROM rozliczenia.pensje GROUP BY stanowisko ORDER BY ilo�� DESC;

--l) Policz �redni�, minimaln� i maksymaln� p�ac� dla stanowiska �kierownik� (je�eli takiego nie masz, to przyjmij dowolne inne).

SELECT * FROM rozliczenia.pensje;

SELECT AVG(kwota_netto) AS �rednia, MIN(kwota_netto) AS minimum, MAX(kwota_netto) AS maximum, stanowisko
FROM rozliczenia.pensje 
--WHERE stanowisko = 'Pracownik produkcji' 
GROUP BY stanowisko
HAVING stanowisko = 'Pracownik produkcji'

--Najpierw WHERE a potem GROUP BY

--m) Policz sum� wszystkich wynagrodze�.

SELECT SUM(kwota_netto) AS suma FROM rozliczenia.pensje;

--n) Policz sum� wynagrodze� w ramach danego stanowiska.

SELECT SUM(kwota_netto) AS suma, stanowisko FROM rozliczenia.pensje GROUP BY stanowisko;

--o) Wyznacz liczb� premii przyznanych dla pracownik�w danego stanowiska.

SELECT * FROM rozliczenia.pensje;
SELECT * FROM rozliczenia.premie;

SELECT COUNT(*),stanowisko FROM rozliczenia.pensje p1
INNER JOIN rozliczenia.premie p2 ON p1.id_pensji = p2.id_premii
GROUP BY stanowisko

--p) Usu� wszystkich pracownik�w maj�cych pensj� mniejsz� ni� 3000 z�.
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