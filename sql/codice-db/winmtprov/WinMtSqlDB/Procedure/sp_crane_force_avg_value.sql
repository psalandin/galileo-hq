IF OBJECT_ID('dbo.sp_crane_force_avg_value', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_crane_force_avg_value;
GO

CREATE PROCEDURE dbo.sp_crane_force_avg_value
    @CodMac   VARCHAR(20),
    @SlotNo   TINYINT,
    @AvgValue DECIMAL(18,4),
    @Oper     INT = 0,
    @Note     VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @SlotNo NOT IN (1,2,3)
    BEGIN
        RAISERROR('Slot non valido', 16, 1);
        RETURN;
    END

    IF @AvgValue < 0
    BEGIN
        RAISERROR('Valore medio non valido', 16, 1);
        RETURN;
    END

    EXEC dbo.sp_crane_ensure_records @CodMac;

    DECLARE @QtyBefore INT;
    DECLARE @AvgBefore DECIMAL(18,4);

    SELECT 
        @QtyBefore = QtyCurrent,
        @AvgBefore = AvgValue
    FROM dbo.GruMagazzinoDettaglio
    WHERE CodMac = @CodMac
      AND SlotNo = @SlotNo;

    UPDATE dbo.GruMagazzinoDettaglio
    SET AvgValue = @AvgValue,
        UpdatedAt = GETDATE()
    WHERE CodMac = @CodMac
      AND SlotNo = @SlotNo;

    INSERT INTO dbo.GruMovimenti
    (
        CodMac, SlotNo, MovementType,
        PrizeCode, PrizeDesc,
        Qty, UnitValue,
        AvgValueBefore, AvgValueAfter,
        QtyBefore, QtyAfter,
        OperatorId, Note
    )
    VALUES
    (
        @CodMac, @SlotNo, 'ADJUST+',
        NULL, NULL,
        0, @AvgValue,
        @AvgBefore, @AvgValue,
        @QtyBefore, @QtyBefore,
        @Oper,
        ISNULL(@Note, 'Forzatura valore medio slot')
    );

    EXEC dbo.sp_crane_sync_ecsmacchine_values @CodMac;
END
GO
