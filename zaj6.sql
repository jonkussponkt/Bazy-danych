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

----------------------------------------------------------------

--6ba dodanie +48 zrobione

ALTER TABLE ksiegowosc.pracownicy
ALTER COLUMN telefon VARCHAR(20);

UPDATE ksiegowosc.pracownicy
SET telefon = '(+48) ' + telefon

--6bb wprowadzenie myœlników

--substring(expression, start, length)

UPDATE ksiegowosc.pracownicy
SET telefon = SUBSTRING(telefon, 1,9) + '-' + SUBSTRING(telefon,10,3) + '-' + SUBSTRING(telefon, 13,3)

--6bc najd³u¿sze nazwisko pracownika napisane wielkimi literami zrobione

SELECT TOP 1 UPPER(nazwisko) AS nazwisko
FROM ksiegowosc.pracownicy
ORDER BY datalength(nazwisko) DESC

--6bd dane pracowników i pensje przy pomocy algorytmu md5

SELECT hashbytes('MD5', imie) AS imie_hash, hashbytes('MD5', nazwisko) AS nazwisko_hash, 
	   hashbytes('MD5',CONVERT(VARCHAR(10),kwota_netto)) AS p³aca_hash
FROM ksiegowosc.pracownicy
	INNER JOIN ksiegowosc.wynagrodzenie ON ksiegowosc.pracownicy.ID_pracownika = ksiegowosc.wynagrodzenie.ID_pracownika
	INNER JOIN ksiegowosc.pensje ON ksiegowosc.pensje.ID_pensji = ksiegowosc.wynagrodzenie.ID_pensji

--6bf left-join zrobiony

SELECT imie, nazwisko, kwota_netto, kwota AS kwota_premii FROM ksiegowosc.pracownicy
	LEFT JOIN ksiegowosc.wynagrodzenie ON ksiegowosc.pracownicy.ID_pracownika = ksiegowosc.wynagrodzenie.ID_pracownika
	LEFT JOIN ksiegowosc.pensje ON ksiegowosc.pensje.ID_pensji = ksiegowosc.wynagrodzenie.ID_pensji
	LEFT JOIN ksiegowosc.premie ON ksiegowosc.premie.ID_premii = ksiegowosc.pensje.ID_pensji + 1000

--6bg raport

SELECT 'Pracownik ' + imie + ' ' + nazwisko + ' w dniu ' + CONVERT(VARCHAR(11), data_wyplaty) + ' otrzymal/a pensje calkowita na kwote ' + 
		CONVERT(VARCHAR(10),(kwota_netto + kwota)) + ' gdzie wynagrodzenie zasadnicze wynosilo: ' + CONVERT(VARCHAR(7), kwota_netto) 
		+ ', premia: ' + CONVERT(VARCHAR(7), kwota) + ', nadgodziny: ' + CONVERT(VARCHAR(7), kwota)
FROM ksiegowosc.pracownicy
	INNER JOIN ksiegowosc.wynagrodzenie ON ksiegowosc.wynagrodzenie.ID_pracownika = ksiegowosc.pracownicy.ID_pracownika
	INNER JOIN ksiegowosc.pensje ON ksiegowosc.wynagrodzenie.ID_pensji = ksiegowosc.pensje.ID_pensji
	INNER JOIN ksiegowosc.premie ON ksiegowosc.pensje.ID_premii = ksiegowosc.premie.ID_premii
