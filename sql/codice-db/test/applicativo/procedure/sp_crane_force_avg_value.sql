CREATE   PROCEDURE sp_crane_force_avg_value 
    @CodMac   VARCHAR(20),
    @SlotNo   TINYINT,
    @AvgValue DECIMAL(18,4),
    @Oper     INT = 0,
    @Note     VARCHAR(255) = NULL
AS 
BEGIN 
-- Ver. 1.0
    SET NOCOUNT ON;
    IF @SlotNo NOT IN (1,2,3)
    BEGIN
        RAISERROR('Slot non valido', 16, 1);
        RETURN;
    End
    IF @AvgValue < 0
    BEGIN
        RAISERROR('Valore medio non valido', 16, 1);
        RETURN;
    End
    EXEC dbo.sp_crane_ensure_records @CodMac;
    DECLARE @QtyBefore INT;
    DECLARE @AvgBefore DECIMAL(18,4);
    SELECT
        @QtyBefore = QtyCurrent,
        @AvgBefore = AvgValue
    From dbo.GruMagazzinoDettaglio
    WHERE CodMac = @CodMac
      AND SlotNo = @SlotNo;
    Update dbo.GruMagazzinoDettaglio
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
        OperatorId , Note
    )
    Values
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
