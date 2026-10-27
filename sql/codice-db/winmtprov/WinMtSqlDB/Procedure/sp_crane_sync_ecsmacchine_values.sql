IF OBJECT_ID('dbo.sp_crane_sync_ecsmacchine_values', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_crane_sync_ecsmacchine_values;
GO

CREATE PROCEDURE dbo.sp_crane_sync_ecsmacchine_values
    @CodMac VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.EcsMacchine
    SET
        ValIn6 = ISNULL((SELECT AvgValue FROM dbo.GruMagazzinoDettaglio WHERE CodMac = @CodMac AND SlotNo = 1), 0),
        ValIn7 = ISNULL((SELECT AvgValue FROM dbo.GruMagazzinoDettaglio WHERE CodMac = @CodMac AND SlotNo = 2), 0),
        ValIn8 = ISNULL((SELECT AvgValue FROM dbo.GruMagazzinoDettaglio WHERE CodMac = @CodMac AND SlotNo = 3), 0)
    WHERE CodMac = @CodMac
      AND Tipo in (3,9,12,17);
END
GO