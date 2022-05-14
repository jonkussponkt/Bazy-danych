-- 1. Napisz procedur� wypisuj�c� do konsoli ci�g Fibonacciego. Procedura musi przyjmowa� jako argument wej�ciowy liczb� n. 
--	  Generowanie ci�gu Fibonacciego musi zosta� zaimplementowane jako osobna funkcja, wywo�ywana przez procedur�.

USE AdventureWorks2019

CREATE OR ALTER FUNCTION dbo.COUNT_FIB(@N INTEGER)
RETURNS @NUMBERS TABLE (FIB_NR INTEGER)
AS
BEGIN
	DECLARE @A INTEGER = 0
	DECLARE @B INTEGER
	SET @B = 1
	DECLARE @C INTEGER
	INSERT INTO @NUMBERS VALUES (1)
	WHILE (@N>1)
		BEGIN
			SET @C = @A + @B;
			SET @A = @B;
			SET @B = @C;
			INSERT INTO @NUMBERS VALUES (@C);
			SET @N = @N - 1;
		END
	RETURN;
END

SELECT * FROM dbo.COUNT_FIB(10) AS Liczba

--SELECT * FROM.... tlyko wtedy gdy funkcja zwraca tablic�, inaczej SELECT dbo.COUNT_FIB(5)

CREATE OR ALTER PROCEDURE dbo.FIB(@N INTEGER)
AS 
	SELECT * FROM dbo.COUNT_FIB(@N)

EXEC FIB 10

--2. Napisz trigger DML, kt�ry po wprowadzeniu danych do tabeli Persons zmodyfikuje nazwisko tak, aby by�o napisane du�ymi literami.

CREATE OR ALTER TRIGGER Person.Person_Trigger
ON Person.PhoneNumberType
AFTER INSERT 
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE Person.PhoneNumberType SET Name=UPPER(Name) 
	WHERE PhoneNumberTypeID IN (SELECT PhoneNumberTypeID FROM INSERTED)
END

DECLARE @date DATETIME
SET @date = '2013-03-30 11:00AM'
INSERT INTO Person.PhoneNumberType VALUES ('free', @date)

SELECT * FROM Person.PhoneNumberType

DELETE FROM Person.PhoneNumberType WHERE Name='Freetime' OR Name='Luzik' OR Name='free'

--3. Przygotuj trigger �taxRateMonitoring�, kt�ry wy�wietli komunikat o b��dzie, je�eli nast�pi zmiana warto�ci w polu �TaxRate� o wi�cej ni� 30%.

CREATE OR ALTER TRIGGER Sales.taxRateMonitoring
ON Sales.SalesTaxRate
INSTEAD OF UPDATE
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE @oldRate SMALLMONEY
	SELECT @oldRate = TaxRate FROM DELETED
	DECLARE @newRate SMALLMONEY
	SELECT @newRate = TaxRate FROM INSERTED;
	IF (ABS(@oldRate - @newRate) > (@oldRate * 0.3))
	BEGIN
		RAISERROR(N'Wyst�pi� b��d! Zbyt wielka zmiana warto�ci!', 10, 1) --https://docs.microsoft.com/en-us/sql/t-sql/language-elements/raiserror-transact-sql?view=sql-server-ver15
	END
	ELSE
	BEGIN
		UPDATE Sales.SalesTaxRate SET TaxRate = @newRate WHERE SalesTaxRateID IN (SELECT SalesTaxRateID FROM inserted)
	END
END

UPDATE Sales.SalesTaxRate SET TaxRate = 7 WHERE SalesTaxRateID = 4

SELECT * FROM Sales.SalesTaxRate

--https://docs.microsoft.com/en-us/sql/relational-databases/triggers/use-the-inserted-and-deleted-tables?view=sql-server-ver15

--4. Deklaracja ciekawych zmiennych
--DECLARE @dem XML
--SELECT @dem = Demographics FROM AdventureWorks2019.Person.Person WHERE BusinessEntityID = 20777

--https://docs.microsoft.com/en-us/sql/t-sql/data-types/uniqueidentifier-transact-sql?view=sql-server-ver15
--DECLARE @row_guid2 UNIQUEIDENTIFIER = NEWID()
--SELECT CONVERT(CHAR(255), @row_guid2) as 'Char';

--DECLARE @date DATETIME
--SET @date = '2013-03-30 11:00AM'

