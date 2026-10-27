

CREATE PROCEDURE dbo.sp_crane_ensure_records
    @CodMac VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.EcsMacchine
        WHERE CodMac = @CodMac
          AND Tipo in (3,9,12,17)
    )
    BEGIN
        RAISERROR('Gru non trovata o macchina non di tipo dispenser', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.GruMagazzino
        WHERE CodMac = @CodMac
    )
    BEGIN
        INSERT INTO dbo.GruMagazzino (CodMac)
        VALUES (@CodMac);
    END

    IF NOT EXISTS (
        SELECT 1 FROM dbo.GruMagazzinoDettaglio WHERE CodMac = @CodMac AND SlotNo = 1
    )
    BEGIN
        INSERT INTO dbo.GruMagazzinoDettaglio (CodMac, SlotNo)
        VALUES (@CodMac, 1);
    END

    IF NOT EXISTS (
        SELECT 1 FROM dbo.GruMagazzinoDettaglio WHERE CodMac = @CodMac AND SlotNo = 2
    )
    BEGIN
        INSERT INTO dbo.GruMagazzinoDettaglio (CodMac, SlotNo)
        VALUES (@CodMac, 2);
    END

    IF NOT EXISTS (
        SELECT 1 FROM dbo.GruMagazzinoDettaglio WHERE CodMac = @CodMac AND SlotNo = 3
    )
    BEGIN
        INSERT INTO dbo.GruMagazzinoDettaglio (CodMac, SlotNo)
        VALUES (@CodMac, 3);
    END

    UPDATE dbo.GruMagazzino
    SET UpdatedAt = GETDATE()
    WHERE CodMac = @CodMac;
END
GO