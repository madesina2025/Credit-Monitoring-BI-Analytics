-- Pattern: dimension upsert. AccountCode must be unique in both tables.
CREATE OR ALTER PROCEDURE demo.LoadAccount @AuditKey int AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF EXISTS(SELECT AccountCode FROM demo.AccountStage GROUP BY AccountCode HAVING COUNT(*)>1) THROW 50001,'Duplicate account code',1;
 MERGE demo.AccountDimension WITH (HOLDLOCK) AS t
 USING demo.AccountStage AS s ON t.AccountCode=s.AccountCode
 WHEN MATCHED THEN UPDATE SET t.ProductCode=s.ProductCode,t.AuditKey=@AuditKey
 WHEN NOT MATCHED THEN INSERT(AccountCode,ProductCode,AuditKey) VALUES(s.AccountCode,s.ProductCode,@AuditKey);
END;
