/* Credit Monitoring BI Analytics — read-only case-study checks
   SQL Server 2019 | Demo warehouse CreditDemoDW | Snapshot 2026-11-01
   No PII fields returned. No DML. Results reflect synthetic data.
*/
USE CreditDemoDW;
GO
DECLARE @AsOfDateKey INT = 20261101;

-- 1. Snapshot exposure by type
SELECT ExposureTypeKey, COUNT(*) AS FacilityRows,
       COUNT(DISTINCT AccountKey) AS DistinctAccounts,
       SUM(TotalExposureLCY) AS ExposureLCY,
       SUM(PrincipalOutstandingBalLCY) AS PrincipalLCY
FROM dbo.FactFacilityDetails
WHERE ProcessingDateKey = @AsOfDateKey
GROUP BY ExposureTypeKey ORDER BY ExposureTypeKey;

-- 2. Customer concentration without names or surrogate IDs in output
WITH C AS (
 SELECT CustomerALTKey, COUNT(*) AS FacilityRows,
        SUM(TotalExposureLCY) AS ExposureLCY
 FROM dbo.FactFacilityDetails
 WHERE ProcessingDateKey = @AsOfDateKey AND CustomerALTKey <> -1
 GROUP BY CustomerALTKey
), R AS (
 SELECT ROW_NUMBER() OVER (ORDER BY ExposureLCY DESC, CustomerALTKey) AS ExposureRank,
        FacilityRows, ExposureLCY FROM C
)
SELECT TOP (10) ExposureRank, FacilityRows, ExposureLCY,
       CAST(100.0 * ExposureLCY / NULLIF((SELECT SUM(TotalExposureLCY)
       FROM dbo.FactFacilityDetails WHERE ProcessingDateKey = @AsOfDateKey),0)
       AS DECIMAL(10,2)) AS PortfolioPct
FROM R ORDER BY ExposureRank;

-- 3. Direct-exposure overdue distribution
SELECT CASE WHEN UnpoDaysOverdue IS NULL THEN 'Unknown'
            WHEN UnpoDaysOverdue = 0 THEN 'Current'
            WHEN UnpoDaysOverdue BETWEEN 1 AND 30 THEN '1-30'
            WHEN UnpoDaysOverdue BETWEEN 31 AND 60 THEN '31-60'
            WHEN UnpoDaysOverdue BETWEEN 61 AND 90 THEN '61-90'
            WHEN UnpoDaysOverdue > 90 THEN 'Over 90'
            ELSE 'Invalid' END AS OverdueBand,
       COUNT(*) AS FacilityRows, SUM(TotalExposureLCY) AS ExposureLCY
FROM dbo.FactFacilityDetails
WHERE ProcessingDateKey = @AsOfDateKey AND ExposureTypeKey = 1
GROUP BY CASE WHEN UnpoDaysOverdue IS NULL THEN 'Unknown'
            WHEN UnpoDaysOverdue = 0 THEN 'Current'
            WHEN UnpoDaysOverdue BETWEEN 1 AND 30 THEN '1-30'
            WHEN UnpoDaysOverdue BETWEEN 31 AND 60 THEN '31-60'
            WHEN UnpoDaysOverdue BETWEEN 61 AND 90 THEN '61-90'
            WHEN UnpoDaysOverdue > 90 THEN 'Over 90' ELSE 'Invalid' END;

-- 4. IFRS Stage 1 / >90 day exceptions (candidate join; confirm SSAS/ETL mapping)
SELECT COUNT(*) AS ExceptionRows, SUM(f.TotalExposureLCY) AS ExceptionExposureLCY
FROM dbo.FactFacilityDetails f
JOIN dbo.DimFacility d ON f.FacilityDetailKey = d.FacilityKey
WHERE f.ProcessingDateKey = @AsOfDateKey AND f.ExposureTypeKey = 1
  AND UPPER(LTRIM(RTRIM(d.IFRSClassification))) = 'STAGE 1'
  AND f.UnpoDaysOverdue > 90;

-- 5. Above-limit / unsettled difference association
WITH X AS (
 SELECT ExposureTypeKey,
        CASE WHEN PrincipalOutstandingBalLCY > [Limit] THEN 1 ELSE 0 END AS AboveLimit,
        TotalUnsettledAmountLCY - UnsettledPrincipalAmount
            - UnsettledInterestAmount AS Difference
 FROM dbo.FactFacilityDetails WHERE ProcessingDateKey = @AsOfDateKey
)
SELECT ExposureTypeKey, AboveLimit, COUNT(*) AS FacilityRows,
       SUM(CASE WHEN ABS(Difference) > 0.01 THEN 1 ELSE 0 END) AS DifferenceRows,
       SUM(Difference) AS UnsettledDifferenceLCY
FROM X GROUP BY ExposureTypeKey, AboveLimit ORDER BY ExposureTypeKey, AboveLimit;

-- 6. Maturity profile
SELECT ExposureTypeKey,
 CASE WHEN DaysToMaturity IS NULL THEN 'Unknown'
      WHEN DaysToMaturity < 0 THEN 'Past maturity'
      WHEN DaysToMaturity <= 30 THEN '0-30 days'
      WHEN DaysToMaturity <= 90 THEN '31-90 days'
      WHEN DaysToMaturity <= 180 THEN '91-180 days'
      WHEN DaysToMaturity <= 365 THEN '181-365 days'
      ELSE '>365 days' END AS MaturityBand,
 COUNT(*) AS FacilityRows, SUM(TotalExposureLCY) AS ExposureLCY
FROM dbo.FactFacilityDetails WHERE ProcessingDateKey = @AsOfDateKey
GROUP BY ExposureTypeKey,
 CASE WHEN DaysToMaturity IS NULL THEN 'Unknown'
      WHEN DaysToMaturity < 0 THEN 'Past maturity'
      WHEN DaysToMaturity <= 30 THEN '0-30 days'
      WHEN DaysToMaturity <= 90 THEN '31-90 days'
      WHEN DaysToMaturity <= 180 THEN '91-180 days'
      WHEN DaysToMaturity <= 365 THEN '181-365 days'
      ELSE '>365 days' END;

-- 7. Collection fixed-rate hypothesis
SELECT COUNT(*) AS CollectionRows,
 SUM(PrincipalOutstandingBalLCY) AS PrincipalLCY,
 SUM(TotalCollection3MLCY) AS Stored3M,
 SUM(TotalCollection3MLCY - PrincipalOutstandingBalLCY * 0.06) AS DiffFrom6Pct,
 SUM(TotalCollection6MLCY) AS Stored6M,
 SUM(TotalCollection6MLCY - PrincipalOutstandingBalLCY * 0.12) AS DiffFrom12Pct,
 SUM(TotalCollection12MLCY) AS Stored12M,
 SUM(TotalCollection12MLCY - PrincipalOutstandingBalLCY * 0.24) AS DiffFrom24Pct
FROM dbo.FactCollections WHERE ProcessingDateKey = @AsOfDateKey;
