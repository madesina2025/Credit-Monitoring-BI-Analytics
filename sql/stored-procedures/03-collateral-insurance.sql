-- Pattern: rebuild a relationship table without personal fields.
CREATE OR ALTER PROCEDURE demo.LoadCollateralInsurance AS
BEGIN
 SET XACT_ABORT ON;
 BEGIN TRAN;
 DELETE FROM demo.CollateralInsurance;
 INSERT demo.CollateralInsurance(CollateralKey,PolicyKey,ExpiryDate)
 SELECT c.CollateralKey,i.PolicyKey,i.ExpiryDate
 FROM demo.Collateral c JOIN demo.Insurance i ON c.CollateralKey=i.CollateralKey;
 COMMIT;
END;
