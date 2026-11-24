-- Illustrative, sanitised pattern adapted from the supplied warehouse scripts.
-- This is NOT a verbatim production procedure or a runnable deployment script.
-- Demonstrates the dimension upsert pattern without customer identifiers.

MERGE dbo.DimProduct AS target
USING (
    SELECT ProductCode, ProductName
    FROM dbo.ProductStageDemo  -- illustrative staging object
) AS source
ON target.ProductCode = source.ProductCode
WHEN MATCHED THEN
    UPDATE SET target.ProductName = source.ProductName
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductCode, ProductName)
    VALUES (source.ProductCode, source.ProductName);

-- The supplied scripts also include audit-key tracking and
-- cleansing via TRIM/REPLACE/ISNULL in dimension load procedures.
