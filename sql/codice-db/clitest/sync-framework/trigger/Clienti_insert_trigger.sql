
CREATE TRIGGER [dbo].[Clienti_insert_trigger]
ON [dbo].[Clienti]
WITH EXECUTE AS CALLER
FOR INSERT
AS
UPDATE [side] SET [sync_row_is_tombstone] = 0, [local_update_peer_key] = 0, [restore_timestamp] = NULL, [update_scope_local_id] = NULL, [last_change_datetime] = GETDATE() FROM [Clienti_tracking] [side] JOIN INSERTED AS [i] ON [side].[IdLong] = [i].[IdLong]
INSERT INTO [Clienti_tracking] ([i].[IdLong], [create_scope_local_id], [local_create_peer_key], [local_create_peer_timestamp], [update_scope_local_id], [local_update_peer_key], [sync_row_is_tombstone], [last_change_datetime], [restore_timestamp]) SELECT [i].[IdLong], NULL, 0, @@DBTS+1, NULL, 0, 0, GETDATE() , NULL FROM INSERTED AS [i] LEFT JOIN [Clienti_tracking] [side] ON [side].[IdLong] = [i].[IdLong] WHERE [side].[IdLong] IS NULL
