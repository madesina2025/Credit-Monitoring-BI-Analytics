-- Portfolio demonstration: read-only checks for 01-Nov-2026
USE CreditDemoDW;
GO

SELECT
    ProcessingDateKey,
    ExposureTypeKey,
    COUNT(*) AS TotalRecords,
    CAST(SUM(TotalExposureLCY) AS DECIMAL(20,2)) AS TotalExposure
FROM dbo.FactFacilityDetails
WHERE ProcessingDateKey = 20261101
GROUP BY ProcessingDateKey, ExposureTypeKey
ORDER BY ExposureTypeKey;

SELECT
    p.ProductName,
    f.ProcessingDateKey,
    COUNT(*) AS TotalRecords,
    CAST(SUM(f.TotalExposureLCY) AS DECIMAL(20,2)) AS DigitalLoanExposure
FROM dbo.FactFacilityDetails AS f
INNER JOIN dbo.DimProduct AS p ON f.ProductKey = p.ProductKey
WHERE f.ProcessingDateKey = 20261101
  AND p.ProductName = 'PAY DAY LOAN'
GROUP BY p.ProductName, f.ProcessingDateKey;
