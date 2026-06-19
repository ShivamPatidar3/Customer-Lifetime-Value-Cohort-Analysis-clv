CREATE VIEW clean_transactions AS
SELECT *
FROM transactions
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
  AND Price > 0; 