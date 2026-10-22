CREATE PROCEDURE [Setup2_selectrow]
	@P_1 Int,
	@P_2 NVarChar(255),
	@sync_scope_local_id Int,
	@sync_scope_restore_count Int
AS
BEGIN
SELECT [side].[IdPost], [side].[Chiave], [base].[Valore], [side].[sync_row_is_tombstone], [side].[local_update_peer_timestamp] as sync_row_timestamp, case when ([side].[update_scope_local_id] is null or [side].[update_scope_local_id] <> @sync_scope_local_id) then COALESCE([side].[restore_timestamp], [side].[local_update_peer_timestamp]) else [side].[scope_update_peer_timestamp] end as sync_update_peer_timestamp, case when ([side].[update_scope_local_id] is null or [side].[update_scope_local_id] <> @sync_scope_local_id) then case when ([side].[local_update_peer_key] > @sync_scope_restore_count) then @sync_scope_restore_count else [side].[local_update_peer_key] end else [side].[scope_update_peer_key] end as sync_update_peer_key, case when ([side].[create_scope_local_id] is null or [side].[create_scope_local_id] <> @sync_scope_local_id) then [side].[local_create_peer_timestamp] else [side].[scope_create_peer_timestamp] end as sync_create_peer_timestamp, case when ([side].[create_scope_local_id] is null or [side].[create_scope_local_id] <> @sync_scope_local_id) then case when ([side].[local_create_peer_key] > @sync_scope_restore_count) then @sync_scope_restore_count else [side].[local_create_peer_key] end else [side].[scope_create_peer_key] end as sync_create_peer_key from [Setup2] [base] right join [Setup2_tracking] [side] on [base].[IdPost] = [side].[IdPost] and [base].[Chiave] = [side].[Chiave] WHERE [side].[IdPost] = @P_1 AND [side].[Chiave] = @P_2
END
