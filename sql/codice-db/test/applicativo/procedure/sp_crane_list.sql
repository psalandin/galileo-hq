CREATE PROCEDURE dbo.sp_crane_list
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.GruMagazzino (CodMac)
    SELECT m.CodMac
    FROM dbo.EcsMacchine m
    WHERE m.Tipo in (3,9,12,17)
      AND NOT EXISTS (
          SELECT 1 FROM dbo.GruMagazzino g WHERE g.CodMac = m.CodMac
      );

    INSERT INTO dbo.GruMagazzinoDettaglio (CodMac, SlotNo)
    SELECT m.CodMac, v.SlotNo
    FROM dbo.EcsMacchine m
    CROSS JOIN (VALUES (1),(2),(3)) v(SlotNo)
    WHERE m.Tipo = 3
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.GruMagazzinoDettaglio d
          WHERE d.CodMac = m.CodMac
            AND d.SlotNo = v.SlotNo
      );

    SELECT *
    FROM dbo.vs_CraneStatus
    ORDER BY CodMac;
END
