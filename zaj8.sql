--1. Przygotuj blok anonimowy, który:
-- -znajdzie średnią stawkę wynagrodzenia pracowników, 
-- -wyświetli szczegóły pracowników, których stawka wynagrodzenia jest niższa niż średnia.

BEGIN
	DECLARE @avgRate MONEY
	SELECT @avgRate = AVG(Rate) FROM HumanResources.EmployeePayHistory
	SELECT Employee.* FROM HumanResources.Employee
	JOIN HumanResources.EmployeePayHistory ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID
	WHERE Rate > @avgRate
END;

--2. Utwórz funkcję, która zwróci datę wysyłki określonego zamówienia.

CREATE OR ALTER FUNCTION Purchasing.Get_Date(@OrderNo INTEGER)
RETURNS DATETIME
AS
BEGIN
	RETURN (SELECT DueDate FROM Purchasing.PurchaseOrderDetail WHERE PurchaseOrderDetailID = @OrderNo)
END

SELECT Purchasing.Get_Date(6)

SELECT * FROM Purchasing.PurchaseOrderDetail

--3. Utwórz procedurę składowaną, która jako parametr przyjmuję nazwę produktu, 
--   a jako rezultat wyświetla jego identyfikator, numer i dostępność.

CREATE OR ALTER PROCEDURE Production.Get_Data(@PrName VARCHAR(100))
AS
	SELECT Pr.ProductID, Pr.Name, SUM(Inv.Quantity) AS Accesibility FROM Production.Product Pr
	JOIN Production.ProductInventory Inv ON Pr.ProductID = Inv.ProductID
	WHERE Pr.Name = @PrName
	GROUP BY Pr.ProductID, Pr.Name

--Column 'Production.Product.ProductID' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

EXEC Production.Get_Data 'Crown Race'

--4. Utwórz funkcję, która zwraca numer karty kredytowej dla konkretnego zamówienia.

CREATE OR ALTER FUNCTION Sales.CreditCardNo(@OrderID INTEGER)
RETURNS NVARCHAR(20)
AS
BEGIN
	RETURN (SELECT c.CardNumber FROM Sales.SalesOrderHeader h
	INNER JOIN Sales.CreditCard c
	ON h.CreditCardID = c.CreditCardID AND h.SalesOrderID = @OrderID)
END;

SELECT Sales.CreditCardNo(43659) AS Card_Number

--EXEC sp_help 'Sales.CreditCard'

--5. Utwórz procedurę składowaną, która jako parametry wejściowe przyjmuje dwie liczby, num1 i num2, a zwraca wynik ich dzielenia. 
--	 Ponadto wartość num1 powinna zawsze być większa niż wartość num2. Jeżeli wartość num1 jest mniejsza niż num2, 
--	 wygeneruj komunikat o błędzie „Niewłaściwie zdefiniowałeś dane wejściowe”.

CREATE OR ALTER PROCEDURE Sales.Division(@num1 FLOAT, @num2 FLOAT)
AS
	IF (@num1 < @num2)
	BEGIN
		RAISERROR('Niewłaściwie zdefiniowałeś dane wejściowe',10,1)
	END
	ELSE IF (@num2 = 0)
	BEGIN
		RAISERROR('Nie można dzielić przez 0!',10,1)
	END
	ELSE
	BEGIN
		DECLARE @iloraz FLOAT = @num1/@num2
		SELECT CONCAT(CONVERT(VARCHAR(10), @num1), ' / ', @num2, ' = ', ROUND(@iloraz, 2)) AS Wynik
	END

EXEC Sales.Division 20, 6

--6. Napisz procedurę, która jako parametr przyjmie NationalIDNumber danej osoby, a zwróci stanowisko oraz liczbę dni urlopowych i chorobowych.

CREATE OR ALTER PROCEDURE HumanResources.Get_NID_No(@Number NVARCHAR(15))
AS
	SELECT JobTitle, VacationHours, SickLeavehours FROM HumanResources.Employee WHERE NationalIDNumber = @Number

EXEC HumanResources.Get_NID_No '112457891'

--7. Napisz procedurę będącą kalkulatorem walutowym. Wykorzystaj dwie tabele: Sales.Currency oraz Sales.CurrencyRate. 
--   Parametrami wejściowymi mają być: kwota, waluty oraz data (CurrencyRateDate). Przyjmij, iż zawsze jedną ze stron 
--   jest dolar amerykański (USD). Zaimplementuj kalkulację obustronną, tj:
--   1400 USD → PLN lub PLN → USD

CREATE OR ALTER PROCEDURE Sales.Currency_Calculator(@Quantity MONEY, @Currency1 VARCHAR(3), @Currency2 VARCHAR(3), @RateDate DATETIME)
AS
	DECLARE @Rate MONEY
	
	IF @Currency1 = 'USD'
	BEGIN
		SELECT @Rate = EndOfDayRate FROM Sales.CurrencyRate WHERE CurrencyRateDate = @RateDate AND ToCurrencyCode = @Currency2
		PRINT @Quantity * @Rate
	END
	ELSE
	BEGIN	
		SELECT @Rate = EndOfDayRate FROM Sales.CurrencyRate WHERE CurrencyRateDate = @RateDate AND ToCurrencyCode = @Currency1
		PRINT @Quantity / @Rate
	END

EXEC Sales.Currency_Calculator 200, 'EUR', 'USD', '2011-05-31'

SELECT * FROM Sales.CurrencyRate