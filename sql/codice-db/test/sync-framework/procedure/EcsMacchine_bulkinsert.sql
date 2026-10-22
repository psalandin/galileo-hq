CREATE PROCEDURE [EcsMacchine_bulkinsert]
	@sync_min_timestamp BigInt,
	@sync_scope_local_id Int,
	@changeTable [EcsMacchine_BulkType] READONLY
AS
BEGIN
-- use a temp table to store the list of PKs that successfully got updated/inserted
DECLARE @changed TABLE ([CodMac] varchar(15), PRIMARY KEY ([CodMac]));

-- update/insert into the base table
MERGE [EcsMacchine] AS base USING
-- join done here against the side table to get the local timestamp for concurrency check
(SELECT p.*, t.local_update_peer_timestamp FROM @changeTable p LEFT JOIN [EcsMacchine_tracking] t ON p.[CodMac] = t.[CodMac]) AS changes ON changes.[CodMac] = base.[CodMac]
WHEN NOT MATCHED BY TARGET AND changes.local_update_peer_timestamp <= @sync_min_timestamp OR changes.local_update_peer_timestamp IS NULL THEN
INSERT ([Keys], [CodMac], [Modu], [NomMac], [Tipo], [ValIn1], [ValIn2], [ValIn3], [ValIn4], [ValIn5], [ValIn6], [ValIn7], [ValIn8], [ValIn9], [ValIn10], [ValIn11], [ValIn12], [ValIn13], [ValIn14], [ValIn15], [ValIn16], [TipoIn1], [TipoIn2], [TipoIn3], [TipoIn4], [TipoIn5], [TipoIn6], [TipoIn7], [TipoIn8], [TipoIn9], [TipoIn10], [TipoIn11], [TipoIn12], [TipoIn13], [TipoIn14], [TipoIn15], [TipoIn16], [CntrLet1], [CntrLet2], [CntrLet3], [CntrLet4], [CntrLet5], [CntrLet6], [CntrLet7], [CntrLet8], [CntrLet9], [CntrLet10], [CntrLet11], [CntrLet12], [CntrLet13], [CntrLet14], [CntrLet15], [CntrLet16], [CntrVal1], [CntrVal2], [CntrVal3], [CntrVal4], [CntrVal5], [CntrVal6], [CntrVal7], [CntrVal8], [CntrVal9], [CntrVal10], [CntrVal11], [CntrVal12], [CntrVal13], [CntrVal14], [CntrVal15], [CntrVal16], [InCnt1], [InCnt2], [InCnt3], [InCnt4], [InCnt5], [InCnt6], [InCnt7], [InCnt8], [InCnt9], [InCnt10], [InCnt11], [InCnt12], [InCnt13], [InCnt14], [InCnt15], [InCnt16], [RapCnt1], [RapCnt2], [RapCnt3], [RapCnt4], [RapCnt5], [RapCnt6], [RapCnt7], [RapCnt8], [RapCnt9], [RapCnt10], [RapCnt11], [RapCnt12], [RapCnt13], [RapCnt14], [RapCnt15], [RapCnt16], [Propr], [PerDiv], [DataInst], [DataDis], [ValPar], [NImp], [F0], [T0], [N0], [D0], [ValPiatto], [PzPiatto], [device], [IngressoCrediti], [IngressoGettoni], [IngressoTickets], [device_status], [lastseen], [offlinecount], [onlinecount], [cards_presentate], [val_platinum], [val_gold], [val_silver], [val_normal], [is_happyhour], [is_timeplay], [is_online]) VALUES (changes.[Keys], changes.[CodMac], changes.[Modu], changes.[NomMac], changes.[Tipo], changes.[ValIn1], changes.[ValIn2], changes.[ValIn3], changes.[ValIn4], changes.[ValIn5], changes.[ValIn6], changes.[ValIn7], changes.[ValIn8], changes.[ValIn9], changes.[ValIn10], changes.[ValIn11], changes.[ValIn12], changes.[ValIn13], changes.[ValIn14], changes.[ValIn15], changes.[ValIn16], changes.[TipoIn1], changes.[TipoIn2], changes.[TipoIn3], changes.[TipoIn4], changes.[TipoIn5], changes.[TipoIn6], changes.[TipoIn7], changes.[TipoIn8], changes.[TipoIn9], changes.[TipoIn10], changes.[TipoIn11], changes.[TipoIn12], changes.[TipoIn13], changes.[TipoIn14], changes.[TipoIn15], changes.[TipoIn16], changes.[CntrLet1], changes.[CntrLet2], changes.[CntrLet3], changes.[CntrLet4], changes.[CntrLet5], changes.[CntrLet6], changes.[CntrLet7], changes.[CntrLet8], changes.[CntrLet9], changes.[CntrLet10], changes.[CntrLet11], changes.[CntrLet12], changes.[CntrLet13], changes.[CntrLet14], changes.[CntrLet15], changes.[CntrLet16], changes.[CntrVal1], changes.[CntrVal2], changes.[CntrVal3], changes.[CntrVal4], changes.[CntrVal5], changes.[CntrVal6], changes.[CntrVal7], changes.[CntrVal8], changes.[CntrVal9], changes.[CntrVal10], changes.[CntrVal11], changes.[CntrVal12], changes.[CntrVal13], changes.[CntrVal14], changes.[CntrVal15], changes.[CntrVal16], changes.[InCnt1], changes.[InCnt2], changes.[InCnt3], changes.[InCnt4], changes.[InCnt5], changes.[InCnt6], changes.[InCnt7], changes.[InCnt8], changes.[InCnt9], changes.[InCnt10], changes.[InCnt11], changes.[InCnt12], changes.[InCnt13], changes.[InCnt14], changes.[InCnt15], changes.[InCnt16], changes.[RapCnt1], changes.[RapCnt2], changes.[RapCnt3], changes.[RapCnt4], changes.[RapCnt5], changes.[RapCnt6], changes.[RapCnt7], changes.[RapCnt8], changes.[RapCnt9], changes.[RapCnt10], changes.[RapCnt11], changes.[RapCnt12], changes.[RapCnt13], changes.[RapCnt14], changes.[RapCnt15], changes.[RapCnt16], changes.[Propr], changes.[PerDiv], changes.[DataInst], changes.[DataDis], changes.[ValPar], changes.[NImp], changes.[F0], changes.[T0], changes.[N0], changes.[D0], changes.[ValPiatto], changes.[PzPiatto], changes.[device], changes.[IngressoCrediti], changes.[IngressoGettoni], changes.[IngressoTickets], changes.[device_status], changes.[lastseen], changes.[offlinecount], changes.[onlinecount], changes.[cards_presentate], changes.[val_platinum], changes.[val_gold], changes.[val_silver], changes.[val_normal], changes.[is_happyhour], changes.[is_timeplay], changes.[is_online])
OUTPUT INSERTED.[CodMac] INTO @changed; -- populates the temp table with successful PKs

UPDATE side SET
update_scope_local_id = @sync_scope_local_id, 
scope_update_peer_key = changes.sync_update_peer_key, 
scope_update_peer_timestamp = changes.sync_update_peer_timestamp,
local_update_peer_key = 0,
create_scope_local_id = @sync_scope_local_id,
scope_create_peer_key = changes.sync_create_peer_key,
scope_create_peer_timestamp = changes.sync_create_peer_timestamp,
local_create_peer_key = 0
FROM 
[EcsMacchine_tracking] side JOIN 
(SELECT p.[CodMac], p.sync_update_peer_timestamp, p.sync_update_peer_key, p.sync_create_peer_key, p.sync_create_peer_timestamp FROM @changed t JOIN @changeTable p ON p.[CodMac] = t.[CodMac]) AS changes ON changes.[CodMac] = side.[CodMac]
SELECT [CodMac] FROM @changeTable t WHERE NOT EXISTS (SELECT [CodMac] from @changed i WHERE t.[CodMac] = i.[CodMac])
END
