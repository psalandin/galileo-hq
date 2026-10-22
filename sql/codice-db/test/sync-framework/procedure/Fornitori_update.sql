CREATE PROCEDURE [Fornitori_update]
	@P_1 VarChar(100),
	@P_2 VarChar(255),
	@P_3 VarChar(15),
	@P_4 VarChar(50),
	@P_5 VarChar(50),
	@P_6 VarChar(50),
	@P_7 VarChar(50),
	@P_8 VarChar(50),
	@P_9 VarChar(50),
	@P_10 VarChar(50),
	@P_11 VarChar(50),
	@P_12 VarChar(50),
	@P_13 Bit,
	@P_14 VarChar(100),
	@P_15 Int,
	@P_16 DateTime,
	@sync_force_write Int,
	@sync_min_timestamp BigInt,
	@sync_row_count Int OUTPUT
AS
BEGIN
SET @sync_row_count = 0; UPDATE [Fornitori] SET [Indir] = @P_2, [CAP] = @P_3, [Citta] = @P_4, [Prov] = @P_5, [Tel] = @P_6, [Fax] = @P_7, [email] = @P_8, [Cell] = @P_9, [Stato] = @P_10, [Web_Site] = @P_11, [Contact_Name] = @P_12, [F0] = @P_13, [T0] = @P_14, [N0] = @P_15, [D0] = @P_16 FROM [Fornitori] [base] JOIN [Fornitori_tracking] [side] ON [base].[Nome] = [side].[Nome] WHERE ([side].[local_update_peer_timestamp] <= @sync_min_timestamp OR @sync_force_write = 1) AND ([base].[Nome] = @P_1); SET @sync_row_count = @@ROWCOUNT;
END
