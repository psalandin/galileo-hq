

CREATE INDEX [idx_EcsDati_codmac] ON [dbo].[EcsDati] ([CodMac]) INCLUDE ([In15])
CREATE INDEX [idx_Clienti_t0_d1] ON [dbo].[Clienti] ([T0], [D1])
CREATE INDEX [idx_Clienti_t0_idcontatto] ON [dbo].[Clienti] ([T0]) INCLUDE ([IdContatto])
CREATE INDEX [idx_Clienti_t0] ON [dbo].[Clienti] ([T0])
CREATE INDEX [idx_clienti_codbar] ON [dbo].[Clienti] (codbar)

CREATE INDEX [idx_TransCard_N0_idcli_data_valorefinale] ON [dbo].[TransCard] ([N0]) INCLUDE ([IdCli], [Data], [ValoreFinale])
CREATE INDEX [idx_Tickets_TPagati_T0] ON [dbo].[Tickets] ([TPagati], [T0])
CREATE INDEX [idx_Tickets_TPagati] ON [dbo].[Tickets] ([TPagati]) INCLUDE ([IdContatto], [NumTickets], [Data], [MangiaT], [NumTrans], [DataOut], [Oper], [OperOut], [NonCont], [Id], [Aux], [NRep], [NImp], [F0], [T0], [N0], [D0], [F1], [T1], [N1], [D1])
CREATE INDEX [idx_CoinlessDecodedData_datastore] ON [dbo].[CoinlessDecodedData] ([datastore]) INCLUDE ([device], [partite])
CREATE INDEX [idx_TransCard_N0_IdCli] ON [dbo].[TransCard] ([N0]) INCLUDE ([IdCli])
CREATE INDEX [idx_TransCard_N0_FlagOpDaVerificare] ON [dbo].[TransCard] ([N0], [FlagOpDaVerificare]) INCLUDE ([IdCli])
CREATE INDEX [idx_TransCard_NImp_Operatore_WinMt_Data_ValoreOperazione] ON [dbo].[TransCard] ([NImp], [Operatore], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli], [CodMac], [ValoreFinale], [ValoreCassa])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_ValoreOperazione] ON [dbo].[TransCard] ([NImp], [WinMt], [Data], [ValoreOperazione])
CREATE INDEX [idx_Clienti_Abilita_T0_T1] ON [dbo].[Clienti] ([Abilita], [T0], [T1]) INCLUDE ([IdContatto], [Tickets], [Data], [Bonus], [CodBar], [DataUltVis])
CREATE INDEX [idx_Clienti_T0_IdLong] ON [dbo].[Clienti] ([T0], [IdLong])
CREATE INDEX [idx_Clienti_Nome_Cognome] ON [dbo].[Clienti] ([Nome], [Cognome]) INCLUDE ([IdContatto])
CREATE INDEX [idx_Clienti_Nome_Cognome_2] ON [dbo].[Clienti] ([Nome], [Cognome])
CREATE INDEX [idx_Premi_Attivo_Gru] ON [dbo].[Premi] ([Attivo], [Gru]) INCLUDE ([Descrizione], [Costo], [N_Tickets], [Fornitore], [Quantita], [Riserva], [CodOr], [QPren], [Id], [Locked], [N0])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_ValoreOperazione_ValoreCassa] ON [dbo].[TransCard] ([NImp], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([ValoreCassa])
CREATE INDEX [idx_TransCard_NImp_D0_WinMt] ON [dbo].[TransCard] ([NImp], [D0], [WinMt]) INCLUDE ([IdCli], [CodMac], [ValoreCassa])
CREATE INDEX [idx_CoinlessDecodedData_id] ON [dbo].[CoinlessDecodedData] ([id]) INCLUDE ([device], [tickets], [cnt3], [cnt4], [cnt5], [cnt6], [cnt7], [gettoni], [partite])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_ValoreOperazione_IdCli_ValoreCassa] ON [dbo].[TransCard] ([NImp], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli], [ValoreCassa])
CREATE INDEX [idx_TransCard_NImp_Operatore_WinMt_Data_ValoreOperazione_2] ON [dbo].[TransCard] ([NImp], [Operatore], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli])
CREATE INDEX [idx_Tickets_TPagati_T0_IdContatto_MangiaT] ON [dbo].[Tickets] ([TPagati], [T0]) INCLUDE ([IdContatto], [MangiaT])

CREATE INDEX [idx_Vincite_IdContatto_D0] ON [dbo].[Vincite] ([IdContatto], [D0])
CREATE INDEX [idx_Clienti_CodBar_Abilita] ON [dbo].[Clienti] ([CodBar], [Abilita])
CREATE INDEX [idx_TransCard_D0_WinMt_NImp_ValoreCassa] ON [dbo].[TransCard] ([D0], [WinMt], [NImp], [ValoreCassa]) INCLUDE ([IdCli], [CodMac])
CREATE INDEX [idx_TransCard_NImp_Data] ON [dbo].[TransCard] ([NImp], [Data]) INCLUDE ([IdCli], [ValoreOperazione])
CREATE INDEX [idx_TransCard_NImp_Operatore_WinMt_Data_ValoreOperazione_ValoreCassa_2] ON [dbo].[TransCard] ([NImp], [Operatore], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli], [ValoreCassa])
CREATE INDEX [idx_TransCard_WinMt_NImp_Data_ValoreOperazione] ON [dbo].[TransCard] ([WinMt], [NImp], [Data], [ValoreOperazione]) INCLUDE ([CodMac])
CREATE INDEX [idx_TransCard_NImp_Operatore_WinMt_Data_ValoreOperazione_ValoreCassa_3] ON [dbo].[TransCard] ([NImp], [Operatore], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([ValoreCassa])
CREATE INDEX [idx_Clienti_T0_N0] ON [dbo].[Clienti] ([T0]) INCLUDE ([N0])
CREATE INDEX [idx_Tickets_IdContatto_NonCont_Aux] ON [dbo].[Tickets] ([IdContatto], [NonCont], [Aux])
CREATE INDEX [idx_Tickets_NonCont_Aux_IdContatto] ON [dbo].[Tickets] ([NonCont], [Aux], [IdContatto]) INCLUDE ([NumTickets], [TPagati])
CREATE INDEX [idx_TransCard_CodMac_WinMt_Data_ValoreOperazione] ON [dbo].[TransCard] ([CodMac], [WinMt], [Data], [ValoreOperazione])
CREATE INDEX [idx_TransCard_CodMac_D0_WinMt] ON [dbo].[TransCard] ([CodMac], [D0], [WinMt])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_ValoreOperazione_IdCli_CodMac_ValoreFinale_Operatore_ValoreCassa] ON [dbo].[TransCard] ([NImp], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli], [CodMac], [ValoreFinale], [Operatore], [ValoreCassa])
CREATE INDEX [idx_TransCard_WinMt_Data_ValoreOperazione_CodMac] ON [dbo].[TransCard] ([WinMt], [Data], [ValoreOperazione]) INCLUDE ([CodMac])
CREATE INDEX [idx_CoinlessDecodedData_id_device] ON [dbo].[CoinlessDecodedData] ([id]) INCLUDE ([device])
CREATE INDEX [idx_EcsDati_CodMac_DataRil] ON [dbo].[EcsDati] ([CodMac], [DataRil])
CREATE INDEX [idx_EcsDati_CodMac_DataRil_In1_In2_In3_In4_In5_In6_In7_In8_In9_In10_In11_In12_In13_In14_In15] ON [dbo].[EcsDati] ([CodMac], [DataRil]) INCLUDE ([In1], [In2], [In3], [In4], [In5], [In6], [In7], [In8], [In9], [In10], [In11], [In12], [In13], [In14], [In15])
CREATE INDEX [idx_Vincite_IdContatto_Data] ON [dbo].[Vincite] ([IdContatto], [Data])
CREATE INDEX [idx_TransCard_WinMt_CodMac_Data_ValoreOperazione_ValoreBonus] ON [dbo].[TransCard] ([WinMt], [CodMac]) INCLUDE ([Data], [ValoreOperazione], [ValoreBonus])
CREATE INDEX [idx_TransCard_WinMt_Data_ValoreOperazione_CodMac_ValoreBonus] ON [dbo].[TransCard] ([WinMt], [Data]) INCLUDE ([CodMac], [ValoreOperazione], [ValoreBonus])
CREATE INDEX [idx_Tickets_Data_NumTickets_MangiaT_TPagati_NonCont_Aux_NRep_F0_N0] ON [dbo].[Tickets] ([Data]) INCLUDE ([NumTickets], [MangiaT], [TPagati], [NonCont], [Aux], [NRep], [F0], [N0])
CREATE INDEX [idx_Tickets_NonCont_Aux_Data_NumTickets_Id] ON [dbo].[Tickets] ([NonCont], [Aux], [Data]) INCLUDE ([NumTickets], [Id])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_ValoreOperazione_IdCli_Operatore_ValoreCassa] ON [dbo].[TransCard] ([NImp], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli], [Operatore], [ValoreCassa])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_ValoreOperazione_Operatore_ValoreCassa] ON [dbo].[TransCard] ([NImp], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([Operatore], [ValoreCassa])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_ValoreOperazione_IdCli_Operatore] ON [dbo].[TransCard] ([NImp], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli], [Operatore])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_IdCli_ValoreOperazione] ON [dbo].[TransCard] ([NImp], [WinMt], [Data]) INCLUDE ([IdCli], [ValoreOperazione])
CREATE INDEX [idx_TransCard_NImp_WinMt_Data_ValoreOperazione_IdCli_CodMac_ValoreFinale_Operatore] ON [dbo].[TransCard] ([NImp], [WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli], [CodMac], [ValoreFinale], [Operatore])
CREATE INDEX [idx_TransCard_WinMt_NImp_Data_ValoreOperazione_IdCli] ON [dbo].[TransCard] ([WinMt], [NImp], [Data], [ValoreOperazione]) INCLUDE ([IdCli])
CREATE INDEX [idx_TransCard_WinMt_Data_ValoreOperazione_IdCli_CodMac] ON [dbo].[TransCard] ([WinMt], [Data], [ValoreOperazione]) INCLUDE ([IdCli], [CodMac])
--CREATE INDEX [idx_backupset_type] ON [msdb].[dbo].[backupset] ([type]) INCLUDE ([backup_finish_date], [database_name])
CREATE INDEX [idx_Resi_Data] ON [dbo].[Resi] ([Data]) INCLUDE ([IdContatto], [Codice], [Descrizione], [Costo], [N_Tickets], [Id])
GO
CREATE INDEX IX_GruMovimenti_CodMac_DataMov
ON dbo.GruMovimenti (CodMac, DataMov DESC);
GO

CREATE INDEX IX_GruMovimenti_CodMac_SlotNo_DataMov
ON dbo.GruMovimenti (CodMac, SlotNo, DataMov DESC);
GO

CREATE INDEX IX_GruMovimenti_MovementType_DataMov
ON dbo.GruMovimenti (MovementType, DataMov DESC);
GO