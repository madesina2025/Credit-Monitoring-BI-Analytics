-- Pattern: date-scoped reload and cleansing. Fictional tables.
CREATE OR ALTER PROCEDURE demo.ReloadFacility @RunDate date AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRAN;
 DELETE FROM demo.FacilityStage WHERE RunDate=@RunDate;
 INSERT demo.FacilityStage(RunDate,FacilityCode,Principal)
 SELECT @RunDate, NULLIF(TRIM(REPLACE(REPLACE(REPLACE(FacilityCode,CHAR(9),''),CHAR(10),''),CHAR(13),'')),''), TRY_CONVERT(decimal(19,2),PrincipalText)
 FROM demo.FacilityInput WHERE RunDate=@RunDate;
 COMMIT;
END;
