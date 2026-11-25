-- Pattern: synchronous SSIS catalog execution; requires deployed demo package and permissions.
CREATE OR ALTER PROCEDURE demo.RunPackage @Folder nvarchar(128), @Project nvarchar(128), @Package nvarchar(260) AS
BEGIN
 DECLARE @Id bigint;
 EXEC SSISDB.catalog.create_execution @folder_name=@Folder,@project_name=@Project,@package_name=@Package,@execution_id=@Id OUTPUT;
 EXEC SSISDB.catalog.set_execution_parameter_value @execution_id=@Id,@object_type=50,@parameter_name=N'SYNCHRONIZED',@parameter_value=1;
 EXEC SSISDB.catalog.start_execution @execution_id=@Id;
 IF NOT EXISTS(SELECT 1 FROM SSISDB.catalog.executions WHERE execution_id=@Id AND status=7) THROW 50002,'Package did not succeed',1;
END;
-- Production concurrency controls must be implemented separately.
