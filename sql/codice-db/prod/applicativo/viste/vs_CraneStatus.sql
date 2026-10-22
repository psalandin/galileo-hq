CREATE VIEW dbo.vs_CraneStatus
AS
SELECT
    m.CodMac,
    m.NomMac,
    m.Device,
    g.Enabled,

    s1.QtyCurrent  AS Slot1Qty,
    s1.AvgValue    AS Slot1AvgValue,
    s1.LastLoadDate AS Slot1LastLoadDate,
    s1.LastWinDate  AS Slot1LastWinDate,

    s2.QtyCurrent  AS Slot2Qty,
    s2.AvgValue    AS Slot2AvgValue,
    s2.LastLoadDate AS Slot2LastLoadDate,
    s2.LastWinDate  AS Slot2LastWinDate,

    s3.QtyCurrent  AS Slot3Qty,
    s3.AvgValue    AS Slot3AvgValue,
    s3.LastLoadDate AS Slot3LastLoadDate,
    s3.LastWinDate  AS Slot3LastWinDate,

    m.ValIn6,
    m.ValIn7,
    m.ValIn8

FROM dbo.EcsMacchine m
LEFT JOIN dbo.GruMagazzino g
    ON g.CodMac = m.CodMac
LEFT JOIN dbo.GruMagazzinoDettaglio s1
    ON s1.CodMac = m.CodMac AND s1.SlotNo = 1
LEFT JOIN dbo.GruMagazzinoDettaglio s2
    ON s2.CodMac = m.CodMac AND s2.SlotNo = 2
LEFT JOIN dbo.GruMagazzinoDettaglio s3
    ON s3.CodMac = m.CodMac AND s3.SlotNo = 3
WHERE m.Tipo = 3;
