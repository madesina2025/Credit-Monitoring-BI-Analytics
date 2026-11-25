-- Pattern: load validated Excel-derived staging data. Import into LimitStage separately.
CREATE OR ALTER PROCEDURE demo.LoadLimits AS
BEGIN
 SET XACT_ABORT ON;
 IF EXISTS(SELECT 1 FROM demo.LimitStage WHERE Threshold IS NULL OR Threshold<0) THROW 50003,'Invalid threshold',1;
 BEGIN TRAN;
 DELETE FROM demo.LimitDefinition;
 INSERT demo.LimitDefinition(Category,Threshold) SELECT Category,Threshold FROM demo.LimitStage;
 COMMIT;
END;
