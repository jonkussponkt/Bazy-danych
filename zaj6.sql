--6a1 ZALE¯NOŒCI FUNKCYJNE

--ID_produktu -> nazwa_produktu, cena_produktu, VAT
--nazwa_produktu -> cena_produktu, VAT
--suma_netto, VAT -> suma_brutto
--VAT, suma_brutto -> suma_netto
--ID_klienta <-> nazwa_klienta
--data_zamowienia -> ID_produktu, ID_klienta, iloœæ
--cena_produktu, nazwa_produktu, iloœæ -> suma_brutto

--6a2 Klucze kandyduj¹ce

--data_zamowienia, nazwa_produktu, nazwa_klienta
--nazwa_produktu, iloœæ, data_zamowienia, nazwa_klienta

--6a3 Zale¿noœci funkcyjne dla tabeli pomieszczenia

--ID_pomieszczenia -> numer_pomieszczenia, powierzchnia, liczba okien, liczba_drzwi
--numer_pomieszczenia -> powierzchnia, liczba okien, liczba drzwi
--kod pocztowy -> miasto
--ID_budynku <-> ulica, miasto, kod pocztowy
--ID_budynku, ID_pomieszczenia -> numer_pomieszczenia, powierzchnia, liczba okien, liczba_drzwi

--Klucze kandyduj¹ce

--id_pomieszczenia
--id_pomieszczenia, numer_pomieszczenia
--id_budynku, id_pomieszczenia
--id_budynku, id_pomieszczenia, numer_pomieszczenia

-------------

--a) Zmodyfikuj numer telefonu w tabeli pracownicy, dodaj¹c do niego kierunkowy dla Polski w nawiasie (+48)

--zmiana typu danych w kolumnie
ALTER TABLE rozliczenia.pracownicy
ALTER COLUMN telefon VARCHAR(20);

UPDATE rozliczenia.pracownicy
SET telefon = '(+48)' + telefon

SELECT * FROM rozliczenia.pracownicy;

--b) Zmodyfikuj atrybut telefon w tabeli pracownicy tak, aby numer oddzielony by³ myœlnikami wg wzoru: ‘555-222-333’

UPDATE rozliczenia.pracownicy
SET telefon = SUBSTRING(telefon, 1, 8) + '-' + SUBSTRING(telefon, 9, 3) + '-' + SUBSTRING(telefon, 12, 3);

--SUBSTRING(expression, starting position INT, length INT);

--c) Wyœwietl dane pracownika, którego nazwisko jest najd³u¿sze, u¿ywaj¹c du¿ych liter

SELECT TOP 1 UPPER(imie) AS IMIE, UPPER(nazwisko) AS NAZWISKO FROM rozliczenia.pracownicy
ORDER BY LEN(nazwisko) DESC

--d) Wyœwietl dane pracowników i ich pensje zakodowane przy pomocy algorytmu md5

SELECT imie, HASHBYTES('md5', imie) AS zakodowane_imie, nazwisko, HASHBYTES('md5', nazwisko) AS zakodowane_nazwisko, 
	   kwota_netto, HASHBYTES('md5', CAST(kwota_netto AS VARCHAR(10))) AS zakodowana_kwota
FROM rozliczenia.pracownicy
INNER JOIN rozliczenia.pensje ON id_pensji = id_pracownika

--f) Wyœwietl pracowników, ich pensje oraz premie. Wykorzystaj z³¹czenie lewostronne.

SELECT * FROM rozliczenia.pracownicy
LEFT JOIN rozliczenia.pensje p1 ON pracownicy.id_pracownika = p1.id_pensji
LEFT JOIN rozliczenia.premie p2 ON p1.id_pensji = p2.id_premii
