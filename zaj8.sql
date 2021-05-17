--zad 1

BEGIN
	DECLARE @MEAN FLOAT 
	SET @MEAN = (SELECT AVG(Rate) FROM HumanResources.EmployeePayHistory) --KONIECZNIE TE NAWIASY
	SELECT * FROM HumanResources.Employee 
		INNER JOIN HumanResources.EmployeePayHistory ON HumanResources.Employee.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID
		WHERE HumanResources.EmployeePayHistory.Rate < @MEAN
END;

--zad 2

CREATE OR ALTER FUNCTION TIME_OF_SHIPMENT(@ID AS INTEGER)
RETURNS DATETIME
AS
BEGIN
	RETURN (SELECT ShipDate FROM Sales.SalesOrderHeader WHERE @ID = SalesOrderID)
END;

SELECT dbo.TIME_OF_SHIPMENT(43740) AS 'Czas wysy³ki'

--zad 3

CREATE OR ALTER PROCEDURE GET_DATA(@NAME AS VARCHAR(40))
AS
BEGIN
	SELECT Pr.ProductID, Pr.ProductNumber, Quantity FROM Production.Product as Pr
		   INNER JOIN Production.ProductInventory as Inv ON Pr.ProductID = Inv.ProductID
		   WHERE Pr.Name = @NAME
END;

EXEC AdventureWorks2017.dbo.GET_DATA 'Blade'

--zad 4

CREATE OR ALTER FUNCTION CARD_NUMBER(@ID AS INTEGER)
RETURNS NVARCHAR(14)
AS
BEGIN
	DECLARE @NR AS NVARCHAR(14)
	SET @NR = (SELECT CardNumber FROM Sales.CreditCard
			   INNER JOIN Sales.SalesOrderHeader ON Sales.CreditCard.CreditCardID = Sales.SalesOrderHeader.CreditCardID
			   WHERE SalesOrderID = @ID)
	RETURN @NR
END;

SELECT dbo.CARD_NUMBER(43667) AS numer_karty

--zad 5

--EXEC sp_addmessage @msgnum = 

CREATE OR ALTER PROCEDURE DIVISION   
@num1 AS FLOAT, @num2 AS FLOAT
OUTPUT
AS
BEGIN
	IF (@num1 < @num2 OR @num2 = 0)
		BEGIN
			RAISERROR('Niew³aœciwie zdefiniowa³eœ dane wejœciowe', 1, 1)
		END
	ELSE
		BEGIN
			SELECT @num1 / @num2 AS Quotient
		END
END;

BEGIN TRY
	DECLARE @quotient AS FLOAT
	EXEC @quotient = AdventureWorks2017.dbo.DIVISION 20, 6 --dlaczego dzielenie jest tylko ca³kowite?? Return zwraca tylko inty
	PRINT(@quotient)									   --jeœli chcemy floaty to select
END TRY
BEGIN CATCH
	DECLARE @msg AS VARCHAR(100)
	SET @msg = (SELECT ERROR_MESSAGE() AS ErrorMessage)		--nawiasy musz¹ byæ po =
	PRINT(@msg)
END CATCH

--zad 6
SELECT SQL_VARIANT_PROPERTY(NationalIDNumber, 'BaseType') FROM HumanResources.Employee --> sprawdzanie typu zmiennej

CREATE OR ALTER PROCEDURE POST_AND_DAYS(@ID AS NVARCHAR(9))
AS
BEGIN
	SELECT VacationHours, SickLeaveHours FROM HumanResources.Employee WHERE NationalIDNumber = @ID
END;

EXEC AdventureWorks2017.dbo.POST_AND_DAYS '998320692'

--zad 7

SELECT SQL_VARIANT_PROPERTY(CurrencyRateDate, 'BaseType') FROM Sales.CurrencyRate

CREATE OR ALTER FUNCTION CONV(@currency AS NCHAR(3), @date AS DATETIME)
RETURNS MONEY
AS
BEGIN
	DECLARE @var AS MONEY
	SET @var = (SELECT EndOfDayRate FROM Sales.CurrencyRate
		        LEFT JOIN Sales.Currency ON Sales.CurrencyRate.ToCurrencyCode = Sales.Currency.CurrencyCode
		        WHERE Sales.Currency.CurrencyCode = @currency AND CurrencyRateDate = @date)
	RETURN @var
END;

CREATE OR ALTER PROCEDURE CURRENCY_CALC @quantity AS INTEGER, @currency AS NCHAR(3), @date AS DATETIME
OUTPUT
AS
BEGIN
	DECLARE @rate AS MONEY
	IF (@currency = 'USD')
		BEGIN
			SELECT @rate = dbo.CONV('GBP', @date)
			SELECT @quantity * @rate
		END
	ELSE
		BEGIN
			SELECT @rate = dbo.CONV(@currency, @date)
			SELECT @quantity / @rate
		END
END;

EXEC AdventureWorks2017.dbo.CURRENCY_CALC 1400, 'GBP', '20110610'