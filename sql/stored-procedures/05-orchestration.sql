-- Pattern: explicit sequential dependencies; child procedures must exist.
CREATE OR ALTER PROCEDURE demo.RefreshWarehouse @RunDate date,@AuditKey int AS
BEGIN
 SET NOCOUNT ON;
 BEGIN TRY
 EXEC demo.ReloadFacility @RunDate;
 EXEC demo.LoadAccount @AuditKey;
 -- Additional validated fact/dimension loads belong here.
 END TRY
 BEGIN CATCH
 THROW;
 END CATCH;
END;
