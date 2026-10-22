# Galileo HQ — DB 02: catalogo tabelle di [WinMtSqlDB]

Generato dallo script SSMS del 18/10/2026. Esclude le 40 tabelle `_tracking` di Sync Framework.
Legenda: **PK** chiave primaria (C = clustered), *ident* = IDENTITY, `?` = ammette NULL, **SYNC** = tabella sincronizzata.

### Abbuoni
10 colonne · PK(Keys) C · **SYNC**

`Id bigint` · `Valore decimal(6, 2)` · `Data date` · `Tickets int` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys int ident`

### AuditLog
8 colonne · nessuna PK

`id bigint ident` · `tipoaudit varchar(255)` · `data datetime` · `user_id int?` · `username varchar(255)?` · `action varchar(255)?` · `device_info varchar(255)?` · `extra_data varchar(max)`

### BEConfig
5 colonne · PK(Macaddress) C

`Macaddress varchar(17)` · `BeInfo nvarchar(max)?` · `BeConfig nvarchar(max)?` · `BiConfig nvarchar(max)?` · `DetectionDate datetime?`

### cache_dati_grafico_giornaliero
0 colonne · nessuna PK · indici: DataRil; DataRil/CodMac/tipo

``

### Clienti
50 colonne · PK(IdLong) C · **SYNC** · indici: U IdLong; Abilita/T0/T1; CodBar; CodBar/Abilita; Nome/Cognome; Nome/Cognome; T0; T0/D1; T0; T0/IdLong; T0

`IdContatto bigint` · `Nome varchar(100)?` · `Cognome varchar(100)?` · `Indirizzo varchar(100)?` · `Citta varchar(50)?` · `Provincia varchar(50)?` · `CAP varchar(50)?` · `Telefono varchar(30)?` · `Tickets int?` · `Data datetime?` · `Bonus decimal(6, 2)?` · `CodBar varchar(15)?` · `Abilita bit? =(-1)` · `email varchar(50)?` · `Cell varchar(50)?` · `Nascita date?` · `NascOk bit? =(0)` · `GiornOk bit? =(0)` · `DataUltVis datetime?` · `OptOut bit? =(0)` · `Password varchar(50)?` · `FirstLogin bit? =(0)` · `Note varchar(255)?` · `Foto varbinary(max)?` · `IdTel bigint?` · `LastOp bigint?` · `Credito money?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `F1 bit =(0)` · `T1 varchar(100)?` · `N1 int?` · `D1 datetime?` · `TimeMod datetime2(7)?` · `OperMod int?` · `IdMaster1 bigint?` · `IdMaster2 bigint?` · `TipoDoc tinyint?` · `Docum varchar(50)?` · `Sesso bit?` · `Modificato int?` · `IdLong bigint` · `IdLong2 bigint?` · `EMailIsCertified int =(0)` · `HasTelephoneNumberCorrect int =(0)` · `UserName varchar(128)?` · `TipoCard int =(0)`

### Coinless_sbuilder_page_provisioning
5 colonne · PK(id) C

`id bigint ident` · `macaddress varchar(17)` · `chiave varchar(255) =''` · `idImmagine bigint` · `pagina_su_be varchar(255)`

### coinless_sbuilder_pages
6 colonne · PK(id) C

`id int ident` · `ClienteImpianto varchar(255)` · `Codmac varchar(30)` · `NomeTemplate varchar(255)` · `pagina_generata varchar(255)` · `pagina_su_be varchar(255)`

### coinless_sbuilder_templates_svg
5 colonne · PK(id) C

`id int ident` · `ClienteImpianto varchar(255)` · `NomeTemplate varchar(255)` · `pagina_su_be varchar(255)` · `ImageBinaryData varbinary(max)?`

### CoinlessCards
11 colonne · PK(id) C · indici: U cardid

`id bigint ident` · `cardid varchar(16)?` · `IdContatto bigint?` · `DataUltimaRicarica datetime?` · `DataUltimaPresentazione datetime? =getdate()` · `SaldoUltimaRicarica bigint? =(0)` · `SaldoUltimaPresentazione bigint? =(0)` · `BlackList int? =(0)` · `N0 int?` · `TentativiNonConfermati int =(0)` · `UltimoN0NonConfermato int?`

### CoinlessClonedCards
10 colonne · PK(id_card_clonate) C · **SYNC**

`id_card_clonate bigint ident` · `cardid varchar(16)?` · `DataMovimento datetime =getdate()` · `TipoMovimento varchar(10)` · `SaldoCard bigint` · `CostoPartita bigint?` · `LivelloCard bigint?` · `device varchar(16)?` · `CodMac varchar(16)?` · `N0 int?`

### CoinlessDataBuffer
17 colonne · nessuna PK · indici: device; device/cardid

`device varchar(10)` · `datastore datetime2(7)` · `crediti bigint?` · `tickets bigint?` · `cnt3 bigint?` · `cnt4 bigint?` · `cnt5 bigint?` · `cnt6 bigint?` · `cnt7 bigint?` · `cnt8 bigint?` · `gettoni bigint?` · `tipocard int?` · `partite bigint?` · `carduid int?` · `saldocard bigint?` · `id bigint ident` · `cardid varchar(16)?`

### CoinlessDati
7 colonne · PK(id) C · indici: U cmd/cnt/hmac

`device varchar(10)?` · `cmd varchar(300)?` · `cnt bigint?` · `logdate datetime2(7) =getdate()` · `id bigint ident` · `hmac varchar(64)` · `FlagOpDaVerificare int?`

### CoinlessDecodedData
22 colonne · nessuna PK · indici: datastore; id; id

`device varchar(10)` · `datastore datetime2(7)` · `Header  int?` · `risposta int?` · `cmd_inviato int?` · `numbyte int?` · `dataril datetime?` · `crediti bigint?` · `tickets bigint?` · `cnt3 bigint?` · `cnt4 bigint?` · `cnt5 bigint?` · `cnt6 bigint?` · `cnt7 bigint?` · `cnt8 bigint?` · `gettoni bigint?` · `tipocard int?` · `datarec datetime? =getdate()` · `partite bigint?` · `carduid int?` · `saldocard bigint?` · `id bigint ident`

### CoinlessImages
4 colonne · PK(id) C

`id int ident` · `ImageName varchar(255)?` · `imageBinaryData varbinary(max)?` · `majorFirmware varchar(3)?`

### CoinlessLanguages
10 colonne · PK(id) C · **SYNC**

`id int ident` · `testo varchar(255)` · `lingua varchar(3)` · `nr_campo int` · `posx int?` · `posy int?` · `color int?` · `font varchar(10)?` · `note varchar(255)?` · `align char(1)? ='C'`

### CoinlessLogEventiBlacklist
4 colonne · PK(id) C

`id bigint ident` · `data_operazione datetime? =getdate()` · `testo varchar(512)?` · `cardid varchar(16)?`

### CoinlessMacchineHappyHour
8 colonne · PK(id_macchineHappyHour) C · **SYNC**

`id_macchineHappyHour bigint ident` · `fk_testata bigint` · `codmac varchar(15)` · `device varchar(8)` · `perc_platinum int` · `perc_gold int` · `perc_silver int` · `perc_normal int`

### CoinlessTestataHappyHour
16 colonne · PK(id_happyhour) C · **SYNC**

`id_happyhour bigint ident` · `giorno int` · `ampm char(1)` · `dalle varchar(5)?` · `alle varchar(5)?` · `attivo int =(1)` · `platinum int?` · `gold int?` · `silver int?` · `normal int?` · `dal datetime2(7)?` · `al datetime2(7)?` · `F0 bit?` · `T0 varchar(1000)?` · `D0 datetime2(7)?` · `N0 bigint?`

### CoinlessTransazioniCards
12 colonne · PK(id_transazione) C

`id_transazione bigint ident` · `cardid varchar(10)` · `DataMovimento datetime =getdate()` · `TipoMovimento varchar(10)` · `SaldoCard bigint =(0)` · `CostoPartita bigint?` · `LivelloCard int?` · `device varchar(16)?` · `CodMac varchar(16)?` · `N0 int?` · `Bonus bigint?` · `FlagOpDaVerificare int?`

### Compleanni
27 colonne · PK(IdCompleanno) C

`IdCompleanno bigint ident` · `Titolo varchar(255)` · `DallaData datetime` · `AllaData datetime` · `ModalitaTickets char(1)` · `MaxPartitePerCard int =(0)` · `PartiteConsecutive int =(0)` · `NrSecondiResetConsecutive int` · `Partecipanti int =(1)` · `PartecipantiExtra int? =(0)` · `ValorePrecaricatoCrediti int? =(0)` · `CardId varchar(16)?` · `IdContatto bigint?` · `ImportoCompleanno decimal(10, 2)?` · `ImportoExtra decimal(10, 2)?` · `AccontoVersato decimal(10, 2)?` · `EmailGenitore1 varchar(128)?` · `EmailGenitore2 varchar(128)?` · `CellulareGenitore1 varchar(15)?` · `CellulareGenitore2 varchar(15)?` · `Note nvarchar(max)?` · `CreatedBy bigint?` · `CreatedAt datetime2(7)?` · `UpdatedBy bigint?` · `UpdatedAt datetime2(7)?` · `ValorePrecaricatoBonus int? =(0)` · `IdRicarica bigint?`

### CraneCounterSyncLog
6 colonne · PK(CodMac, DataRil) C

`CodMac varchar(20)` · `DataRil datetime` · `DeltaIn6 int =(0)` · `DeltaIn7 int =(0)` · `DeltaIn8 int =(0)` · `ProcessedAt datetime =getdate()`

### debug_log
1 colonne · nessuna PK

`testo nvarchar(max)?`

### Differ
8 colonne · PK(Keys) C · **SYNC**

`Data datetime?` · `VarVal decimal(10, 2)?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### ecl_DeviceProvisioning
2 colonne · nessuna PK

`macaddress varchar(17)` · `updated datetime? =getdate()`

### ecl_firmware
9 colonne · PK(id) C · **SYNC** · indici: U version

`id int ident` · `filename varchar(255)` · `url varchar(255)` · `version varchar(15)` · `path varchar(255)?` · `tipoScheda varchar(3)?` · `tipoFirmware varchar(9)?` · `msgCount int? =(55)` · `firmwareBinaryData varbinary(max)?`

### ecl_log
5 colonne · PK(id) C

`id bigint ident` · `logdate datetime` · `type varchar(30)` · `data nvarchar(1024)?` · `group varchar(512)?`

### ecl_Provisioning
3 colonne · PK(id) C · **SYNC**

`macaddress varchar(17)` · `idImmagine int` · `id bigint ident`

### ecl_SchedeFirmware
10 colonne · PK(macaddress) C · **SYNC**

`macaddress varchar(17)` · `tipoScheda varchar(3)` · `tipoFirmware varchar(15)` · `dataAggiornamento datetime?` · `device varchar(30)?` · `requestedVersion varchar(30)?` · `detectedVersion varchar(30)?` · `dataVerifica datetime?` · `bidetectedVersion varchar(30)?` · `status varchar(10)?`

### EcsDati
26 colonne · PK(Keys) C · **SYNC** · indici: CodMac; CodMac; CodMac/DataRil; CodMac/DataRil; DataRil

`CodMac varchar(100)?` · `Stato tinyint?` · `DataRil datetime?` · `In1 bigint =(0)` · `In2 bigint =(0)` · `In3 bigint =(0)` · `In4 bigint =(0)` · `In5 bigint =(0)` · `In6 bigint =(0)` · `In7 bigint =(0)` · `In8 bigint =(0)` · `In9 bigint =(0)` · `In10 bigint =(0)` · `In11 bigint =(0)` · `In12 bigint =(0)` · `In13 bigint =(0)` · `In14 bigint =(0)` · `In15 bigint =(0)` · `In16 bigint =(0)` · `NImp int?` · `ValoreUscita money?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### EcsErr
9 colonne · PK(Keys) C · **SYNC**

`IdMod tinyint?` · `Data datetime?` · `CodErr tinyint?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### EcsMacchine
129 colonne · PK(CodMac) C · **SYNC**

`Keys int?` · `CodMac varchar(15)` · `Modu tinyint?` · `NomMac varchar(100)?` · `Tipo tinyint?` · `ValIn1 smallmoney?` · `ValIn2 smallmoney?` · `ValIn3 smallmoney?` · `ValIn4 smallmoney?` · `ValIn5 smallmoney?` · `ValIn6 smallmoney?` · `ValIn7 smallmoney?` · `ValIn8 smallmoney?` · `ValIn9 smallmoney?` · `ValIn10 smallmoney?` · `ValIn11 smallmoney?` · `ValIn12 smallmoney?` · `ValIn13 smallmoney?` · `ValIn14 smallmoney?` · `ValIn15 smallmoney?` · `ValIn16 smallmoney?` · `TipoIn1 tinyint?` · `TipoIn2 tinyint?` · `TipoIn3 tinyint?` · `TipoIn4 tinyint?` · `TipoIn5 tinyint?` · `TipoIn6 tinyint?` · `TipoIn7 tinyint?` · `TipoIn8 tinyint?` · `TipoIn9 tinyint?` · `TipoIn10 tinyint?` · `TipoIn11 tinyint?` · `TipoIn12 tinyint?` · `TipoIn13 tinyint?` · `TipoIn14 tinyint?` · `TipoIn15 tinyint?` · `TipoIn16 tinyint?` · `CntrLet1 int?` · `CntrLet2 int?` · `CntrLet3 int?` · `CntrLet4 int?` · `CntrLet5 int?` · `CntrLet6 int?` · `CntrLet7 int?` · `CntrLet8 int?` · `CntrLet9 int?` · `CntrLet10 int?` · `CntrLet11 int?` · `CntrLet12 int?` · `CntrLet13 int?` · `CntrLet14 int?` · `CntrLet15 int?` · `CntrLet16 int?` · `CntrVal1 smallmoney?` · `CntrVal2 smallmoney?` · `CntrVal3 smallmoney?` · `CntrVal4 smallmoney?` · `CntrVal5 smallmoney?` · `CntrVal6 smallmoney?` · `CntrVal7 smallmoney?` · `CntrVal8 smallmoney?` · `CntrVal9 smallmoney?` · `CntrVal10 smallmoney?` · `CntrVal11 smallmoney?` · `CntrVal12 smallmoney?` · `CntrVal13 smallmoney?` · `CntrVal14 smallmoney?` · `CntrVal15 smallmoney?` · `CntrVal16 smallmoney?` · `InCnt1 tinyint?` · `InCnt2 tinyint?` · `InCnt3 tinyint?` · `InCnt4 tinyint?` · `InCnt5 tinyint?` · `InCnt6 tinyint?` · `InCnt7 tinyint?` · `InCnt8 tinyint?` · `InCnt9 tinyint?` · `InCnt10 tinyint?` · `InCnt11 tinyint?` · `InCnt12 tinyint?` · `InCnt13 tinyint?` · `InCnt14 tinyint?` · `InCnt15 tinyint?` · `InCnt16 tinyint?` · `RapCnt1 decimal(4, 1)?` · `RapCnt2 decimal(4, 1)?` · `RapCnt3 decimal(4, 1)?` · `RapCnt4 decimal(4, 1)?` · `RapCnt5 decimal(4, 1)?` · `RapCnt6 decimal(4, 1)?` · `RapCnt7 decimal(4, 1)?` · `RapCnt8 decimal(4, 1)?` · `RapCnt9 decimal(4, 1)?` · `RapCnt10 decimal(4, 1)?` · `RapCnt11 decimal(4, 1)?` · `RapCnt12 decimal(4, 1)?` · `RapCnt13 decimal(4, 1)?` · `RapCnt14 decimal(4, 1)?` · `RapCnt15 decimal(4, 1)?` · `RapCnt16 decimal(4, 1)?` · `Propr varchar(100)?` · `PerDiv decimal(4, 1)?` · `DataInst datetime?` · `DataDis datetime?` · `ValPar decimal(3, 2)?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `ValPiatto smallmoney? =(0)` · `PzPiatto int? =(0)` · `device varchar(16)?` · `IngressoCrediti varchar(5)? ='In3'` · `IngressoGettoni varchar(5)? ='In1'` · `IngressoTickets varchar(5)? ='In2'` · `device_status varchar(10)?` · `lastseen datetime?` · `offlinecount bigint?` · `onlinecount bigint?` · `cards_presentate bigint?` · `val_platinum int? =(0)` · `val_gold int? =(0)` · `val_silver int? =(0)` · `val_normal int? =(0)` · `is_happyhour int? =(0)` · `is_timeplay int? =(0)` · `is_online int? =(0)`

### EcsModuli
9 colonne · PK(Id) C · **SYNC**

`Id int` · `MacAd varchar(50)?` · `ShortAd varchar(15)?` · `Abil bit?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?`

### Figli
23 colonne · PK(Id) C · **SYNC**

`Id bigint` · `IdContatto bigint` · `Nome varchar(100)?` · `Cognome varchar(100)?` · `Sesso varchar(1)?` · `DDN date?` · `Tickets int?` · `Bnus decimal(6, 2)?` · `CodBar varchar(15)?` · `Abilita bit? =(-1)` · `email varchar(50)?` · `Cell varchar(50)?` · `GiornOk bit? =(0)` · `DataUltVis datetime?` · `OptOut bit? =(0)` · `Password varchar(50)?` · `FirstLogin bit? =(0)` · `Note varchar(255)?` · `Foto varbinary(max)?` · `IdTel bigint?` · `LastOp bigint?` · `Credito money?` · `NImp int?`

### Fornitori
16 colonne · PK(Nome) C · **SYNC**

`Nome varchar(100)` · `Indir varchar(255)?` · `CAP varchar(15)?` · `Citta varchar(50)?` · `Prov varchar(50)?` · `Tel varchar(50)?` · `Fax varchar(50)?` · `email varchar(50)?` · `Cell varchar(50)?` · `Stato varchar(50)?` · `Web_Site varchar(50)?` · `Contact_Name varchar(50)?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?`

### GruMagazzino
4 colonne · PK(CodMac) C

`CodMac varchar(20)` · `Enabled bit =(1)` · `CreatedAt datetime =getdate()` · `UpdatedAt datetime =getdate()`

### GruMagazzinoDettaglio
7 colonne · PK(CodMac, SlotNo) C

`CodMac varchar(20)` · `SlotNo tinyint` · `QtyCurrent int =(0)` · `AvgValue decimal(18, 4) =(0)` · `LastLoadDate datetime?` · `LastWinDate datetime?` · `UpdatedAt datetime =getdate()`

### GruMovimenti
15 colonne · PK(IdMovGru) C · indici: CodMac/DataMov; CodMac/SlotNo/DataMov; MovementType/DataMov

`IdMovGru bigint ident` · `CodMac varchar(20)` · `SlotNo tinyint` · `MovementType varchar(20)` · `PrizeCode varchar(50)?` · `PrizeDesc varchar(255)?` · `Qty int` · `UnitValue decimal(18, 4) =(0)` · `AvgValueBefore decimal(18, 4) =(0)` · `AvgValueAfter decimal(18, 4) =(0)` · `QtyBefore int =(0)` · `QtyAfter int =(0)` · `OperatorId int?` · `Note varchar(255)?` · `DataMov datetime =getdate()`

### Incassi
13 colonne · PK(Keys) C · **SYNC** · indici: Data

`Data datetime` · `Oper decimal(5, 0)?` · `Red money?` · `Gru money?` · `Alt money?` · `Push money?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Mdb varbinary(max)?` · `Keys uniqueidentifier =newid()`

### Logs
4 colonne · nessuna PK

`IDPost int` · `Data datetime` · `LFile varbinary(max)` · `Filename varchar(255)?`

### LogTransazioniPos
16 colonne · PK(id) C

`id bigint ident` · `IdCli bigint?` · `data datetime` · `idpost int` · `MName varchar(100)?` · `Status varchar(15)` · `uidPOS varchar(255)?` · `valore money` · `IDTerm varchar(255)?` · `Stan varchar(255)?` · `AId varchar(255)?` · `Appl varchar(255)?` · `IC varchar(255)?` · `PAN varchar(255)?` · `N0 int?` · `DataAck datetime?`

### LogTransazioniTotem
20 colonne · PK(id) C · **SYNC**

`id bigint ident` · `IdCli bigint?` · `data datetime` · `idpost int` · `MName varchar(100)?` · `tipo varchar(4)` · `valore money` · `IDTerm varchar(255)?` · `CAut varchar(255)?` · `TCC varchar(255)?` · `Stan varchar(255)?` · `AId varchar(255)?` · `Appl varchar(255)?` · `Cryptogram varchar(255)?` · `AC varchar(255)?` · `IAD varchar(255)?` · `IC varchar(255)?` · `PAN varchar(255)?` · `DataOraChiusura datetime?` · `IdOperatore bigint?`

### Machines
9 colonne · PK(Id) C · **SYNC** · indici: U Id

`Id bigint ident` · `MacName varchar(50)` · `Manufacturer bigint?` · `Type bigint?` · `CntrOut bit?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?`

### Manuf
6 colonne · PK(Id) C · **SYNC** · indici: U Id

`Id bigint ident` · `ManufName varchar(50)` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?`

### Mistral
8 colonne · PK(CodCard) C · **SYNC**

`CodCard varchar(15)` · `Sospeso bit? =(0)` · `Serie varchar(10)?` · `IDPost decimal(5, 0)?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?`

### MovMag
19 colonne · PK(Keys) C · **SYNC** · indici: Codice

`Codice varchar(50)` · `Quantita decimal(10, 0)?` · `Data datetime?` · `Oper decimal(5, 0)?` · `CodOr varchar(50)?` · `Fornitore varchar(255)?` · `Descrizione varchar(255)?` · `Costo money?` · `N_Tickets decimal(10, 0)?` · `NBolla varchar(100)?` · `Motivo varchar(255)?` · `Note varchar(255)?` · `NOrdine varchar(100)?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### MovOut
19 colonne · PK(Keys) C · **SYNC** · indici: Codice

`Codice varchar(50)` · `Quantita decimal(10, 0)?` · `Data datetime?` · `Oper decimal(5, 0)?` · `CodOr varchar(50)?` · `Fornitore varchar(255)?` · `Descrizione varchar(255)?` · `Costo money?` · `N_Tickets decimal(10, 0)?` · `NBolla varchar(100)?` · `Motivo varchar(255)?` · `Note varchar(255)?` · `NOrdine varchar(100)?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### Nayax
30 colonne · nessuna PK

`ID Server   nvarchar(255)?` · `ID Transazione   nvarchar(255)?` · `ID Metodo di pagamento   nvarchar(255)?` · `Valuta   nvarchar(255)?` · `Nome macchina nvarchar(255)?` · `Original Transaction ID   nvarchar(255)?` · `Valore autorizzazione   nvarchar(255)?` · `Valore saldo   nvarchar(255)?` · `Info selezione prodotto   nvarchar(255)?` · `Brand nvarchar(255)?` · `Numero carta nvarchar(255)?` · `RRN autorizzazione   nvarchar(255)?` · `Ora autorizzazione macchina   nvarchar(255)?` · `Machine Settlment Time   nvarchar(255)?` · `Aggiorna Data e Ora   nvarchar(255)?` · `Credit Card Type   nvarchar(255)?` · `Official Acquirer   nvarchar(255)?` · `Tipo carta nvarchar(255)?` · `Card BIN nvarchar(255)?` · `Payment Method (Source)   nvarchar(255)?` · `ID stato Transazione   nvarchar(255)?` · `Transaction Type ID   nvarchar(255)?` · `Provider fatturazione   nvarchar(255)?` · `Refund Request Date   nvarchar(255)?` · `ID Terminale   nvarchar(255)?` · `Actor Description   nvarchar(255)?` · `Batch Ref Number   nvarchar(255)?` · `Settlement Payment Service Transactions ID   nvarchar(255)?` · `Acquirer Transaction ID   nvarchar(255)?` · `Is Offline Payment   nvarchar(255)?`

### Operatori
19 colonne · PK(Id) C · **SYNC** · indici: U Id

`Id int` · `Nome varchar(100)?` · `Cognome varchar(100)?` · `Indirizzo varchar(100)?` · `CAP varchar(50)?` · `Password varchar(50)?` · `Citta varchar(50)?` · `Provincia varchar(50)?` · `Telefono varchar(30)?` · `Data datetime?` · `Livello decimal(2, 0)?` · `CodBar varchar(15)?` · `Attivo bit? =(1)` · `Foto varbinary(max)?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?`

### Ordini
20 colonne · PK(Keys) C · **SYNC** · indici: Codice

`Codice varchar(50)` · `QOrd decimal(10, 0)?` · `Data datetime?` · `Oper decimal(5, 0)?` · `CodOr varchar(50)?` · `Fornitore varchar(100)?` · `Descrizione varchar(255)?` · `Costo decimal(10, 2)?` · `N_Tickets decimal(10, 0)?` · `NBolla varchar(100)?` · `Motivo varchar(255)?` · `Note varchar(255)?` · `NOrdine varchar(100)?` · `QCons decimal(10, 0)?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### Ospiti
8 colonne · PK(IdOspite) C

`IdOspite bigint ident` · `IdCompleanno bigint` · `CardId varchar(16)` · `IdContatto bigint` · `CreatedBy bigint?` · `CreatedAt datetime2(7)?` · `UpdatedBy bigint?` · `UpdatedAt datetime2(7)?`

### Owners
10 colonne · PK(Id) C · **SYNC** · indici: U Id

`Id int` · `OwnerName varchar(100)?` · `OwnerAddress varchar(255)?` · `OwnerPhone varchar(50)?` · `Perc decimal(4, 1)?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?`

### PartiteOspiti
10 colonne · nessuna PK

`IdContatto bigint` · `device varchar(16)` · `DataUltimaPartita datetime?` · `NrPartiteConsecutive int? =(0)` · `TotPartite int? =(0)` · `TotTickets int? =(0)` · `CreatedBy bigint?` · `CreatedAt datetime2(7)?` · `UpdatedBy bigint?` · `UpdatedAt datetime2(7)?`

### pos_request
7 colonne · nessuna PK

`id int?` · `request_transaction_id nvarchar(max)` · `client_id nvarchar(max)?` · `method nvarchar(max)?` · `dump nvarchar(max)?` · `created_at nvarchar(max)?` · `updated_at nvarchar(max)?`

### pos_transaction
21 colonne · nessuna PK

`id int?` · `pos_request_id int?` · `device_id nvarchar(max)?` · `response_status nvarchar(max)?` · `status nvarchar(max)?` · `status_message nvarchar(max)?` · `vuid nvarchar(max)?` · `amount int?` · `transaction_id nvarchar(max)?` · `server_result_message nvarchar(max)?` · `tran_type int?` · `dt_id nvarchar(max)?` · `rrn nvarchar(max)?` · `masked_pan nvarchar(max)?` · `currency_code nvarchar(max)?` · `currency_iso_code nvarchar(max)?` · `dump nvarchar(max)?` · `transaction_date nvarchar(max)?` · `delta int?` · `created_at nvarchar(max)?` · `updated_at nvarchar(max)?`

### Premi
45 colonne · PK(Codice) C · **SYNC** · indici: U Codice; U CodOr; Attivo/Gru; N_Tickets

`Codice varchar(50)` · `Descrizione varchar(255)?` · `Costo money?` · `N_Tickets decimal(10, 0)?` · `Fornitore varchar(255)?` · `Quantita decimal(10, 0)?` · `Riserva decimal(5, 0)?` · `CodOr varchar(50)` · `Foto varbinary(max)?` · `QPren decimal(5, 0)?` · `Id varchar(5)?` · `Ordinato decimal(5, 0)?` · `Conf decimal(5, 0)?` · `QDis1 int =(0)` · `PDis1 varchar(100)?` · `QDis2 int =(0)` · `PDis2 varchar(100)?` · `QDis3 int =(0)` · `PDis3 varchar(100)?` · `QDis4 int =(0)` · `PDis4 varchar(100)?` · `QDis5 int =(0)` · `PDis5 varchar(100)?` · `QDis6 int =(0)` · `PDis6 varchar(100)?` · `QDis7 int =(0)` · `PDis7 varchar(100)?` · `QDis8 int =(0)` · `PDis8 varchar(100)?` · `Attivo bit? =(1)` · `Gru bit? =(0)` · `Riord bit? =(0)` · `Locked int =(0)` · `Id2 int?` · `Icona varbinary(max)?` · `Prenotabile bit =(0)` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `F1 bit =(0)` · `T1 varchar(100)?` · `N1 int?` · `D1 datetime?`

### Prenotaz
30 colonne · PK(Keys) C · **SYNC** · indici: SerNum

`IdOp decimal(5, 0)?` · `IdCli bigint` · `Codice varchar(50)?` · `Descrizione varchar(255)?` · `Costo money?` · `N_Tickets decimal(10, 0)?` · `Fornitore varchar(255)?` · `NomeC varchar(100)?` · `CognomeC varchar(100)?` · `Tel varchar(50)?` · `Data datetime?` · `DataCon datetime?` · `Cons bit?` · `IdOpCo decimal(5, 0)?` · `Quantita decimal(10, 0)?` · `SerNum decimal(15, 0)` · `Conf bit =(0)` · `MsgInv bit =(0)` · `NImp int?` · `Annul bit =(0)` · `DataConf datetime?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `F1 bit =(0)` · `T1 varchar(100)?` · `N1 int?` · `D1 datetime?` · `Keys uniqueidentifier =newid()`

### PrizeHubSlots
12 colonne · PK(id) C · indici: hubId/unit/codArticolo; hubId/unit/slot

`id int ident` · `hubId int` · `tipo nvarchar(20)` · `unit int =(1)` · `slot nvarchar(10)` · `codArticolo nvarchar(50)` · `qtaDisp int =(0)` · `ticketsMedi int?` · `ticketsMediaForzata bit =(0)` · `attivo bit =(1)` · `updatedAt datetime2(7)?` · `updatedBy nvarchar(50)?`

### promozioni
7 colonne · PK(id) C

`id bigint ident` · `titolo varchar(255)` · `dalla_data datetime` · `alla_data datetime` · `flagConvertiOldSilver char(1)? ='N'` · `flagRipristinaGoldInSilver char(1)? ='N'` · `scadenzaPromozione datetime?`

### promozioni_cards
5 colonne · PK(id) C

`id bigint ident` · `idpromozione bigint` · `cardid varchar(16)` · `livelloPrecedente int?` · `CreatedAt datetime2(7)? =getdate()`

### RedeemCodes
28 colonne · PK(Id) C · indici: DbName/UsedAt/ReservedAt/CreatedAt; U DbName/Codice

`Id bigint ident` · `DbName varchar(6) =''` · `Codice varchar(15)` · `Azione varchar(20)` · `Valore money?` · `Bonus money?` · `Tickets int?` · `IdPromozione bigint?` · `IdCompleanno bigint?` · `IdContatto bigint?` · `MailDestinatario varchar(255)?` · `CardLevel int?` · `Pin varchar(4)` · `ValidFrom datetime?` · `ValidTo datetime?` · `CreatedBy bigint` · `CreatedAt datetime =getdate()` · `ReservedBy bigint?` · `ReservedAt datetime?` · `ReservedOnPost int?` · `ReservedOnDevice varchar(50)?` · `ReservationExpiresAt datetime?` · `UsedBy bigint?` · `UsedAt datetime?` · `UsedOnPost int?` · `UsedOnDevice varchar(50)?` · `Note varchar(200)?` · `QRCode varbinary(max)?`

### Resi
14 colonne · PK(Keys) C · **SYNC** · indici: Codice; Data

`IdContatto bigint` · `Codice varchar(50)` · `Descrizione varchar(255)?` · `Costo money?` · `N_Tickets decimal(10, 0)?` · `Fornitore varchar(255)?` · `Data datetime?` · `Id decimal(5, 0)?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### RiepInv
29 colonne · PK(Keys) C · **SYNC**

`Data datetime?` · `VVend money?` · `VCons money?` · `VGru money?` · `VRott money?` · `VEvents money?` · `TVPre money?` · `IncRed money?` · `IncGru money?` · `IncAlt money?` · `IncPush money?` · `RedPer decimal(6, 2)?` · `GruPer decimal(6, 2)?` · `ConPer decimal(6, 2)?` · `RotPer decimal(6, 2)?` · `TotPer decimal(6, 2)?` · `QDiff int?` · `VarVal money?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Mdb varbinary(max)?` · `F1 bit =(0)` · `T1 varchar(100)?` · `N1 int?` · `D1 datetime?` · `Keys uniqueidentifier =newid()`

### save_ciapett
3 colonne · nessuna PK

`T0 varchar(100)?` · `TipoCard int?` · `checkcount bigint? =(0)`

### schema_info
3 colonne · PK(schema_major_version, schema_minor_version) C

`schema_major_version int` · `schema_minor_version int` · `schema_extended_info nvarchar(100)`

### Scocard
19 colonne · PK(Keys) C · **SYNC** · indici: Data; IdContatto; MangiaT; NumTrans; TPagati

`IdContatto bigint` · `NumTickets decimal(6, 0)?` · `Data datetime?` · `MangiaT decimal(5, 0)?` · `NumTrans decimal(10, 0)?` · `TPagati decimal(6, 0)?` · `DataOut datetime?` · `Oper decimal(5, 0)?` · `OperOut decimal(5, 0)?` · `NonCont bit? =(0)` · `Id decimal(5, 0)?` · `Aux bit? =(0)` · `NRep tinyint?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### scope_config
3 colonne · PK(config_id) C

`config_id uniqueidentifier` · `config_data xml` · `scope_status char(1)?`

### scope_info
9 colonne · PK(sync_scope_name) C

`scope_local_id int ident` · `scope_id uniqueidentifier =newid()` · `sync_scope_name nvarchar(100)` · `scope_sync_knowledge varbinary(max)?` · `scope_tombstone_cleanup_knowledge varbinary(max)?` · `scope_timestamp timestamp?` · `scope_config_id uniqueidentifier?` · `scope_restore_count int =(0)` · `scope_user_comment nvarchar(max)?`

### Setup
282 colonne · PK(IDPost) C · **SYNC**

`IDPost tinyint` · `MName varchar(100)?` · `NRep2 varchar(50)?` · `NRep3 varchar(50)?` · `NRep4 varchar(50)?` · `NRep5 varchar(50)?` · `NRep6 varchar(50)?` · `NRep7 varchar(50)?` · `NRep8 varchar(50)?` · `NRep9 varchar(50)?` · `ARep2 bit?` · `ARep3 bit?` · `ARep4 bit?` · `ARep5 bit?` · `ARep6 bit?` · `ARep7 bit?` · `ARep8 bit?` · `ARep9 bit?` · `VelDia int?` · `TSSNum0 varchar(5)?` · `TSSNum1 varchar(5)?` · `TSSNum2 varchar(5)?` · `TSSNum3 varchar(5)?` · `TSSNum4 varchar(5)?` · `TSSNum5 varchar(5)?` · `TSSNum6 varchar(5)?` · `TSSNum7 varchar(5)?` · `TSSNum8 varchar(5)?` · `TSSNum9 varchar(5)?` · `Passw varchar(50)?` · `TotTick int?` · `DataEnd datetime?` · `DataIni datetime?` · `NImp int?` · `PBonus int?` · `FPPremio bit?` · `FForza bit?` · `NomeLocale varchar(50)?` · `IndiLocale varchar(100)?` · `CittaLocale varchar(50)?` · `ProvLocale varchar(50)?` · `TelLocale varchar(50)?` · `numcommMT1 tinyint?` · `numcommMT2 tinyint?` · `numcommMT3 tinyint?` · `numcommMT4 tinyint?` · `numcommMT5 tinyint?` · `numcommCR tinyint?` · `numcommBR tinyint?` · `numcommPR tinyint?` · `NConc varchar(50)?` · `NTrack tinyint?` · `ScoMan bit?` · `Ric25 bit?` · `Pre25 smallmoney?` · `TypePrt tinyint?` · `SecMonX int?` · `SecMonY int?` · `OpRig bit?` · `Lang tinyint?` · `Log bit?` · `MultiUser bit?` · `CardReader tinyint?` · `CBarC bit?` · `NCogn bit?` · `OpResi bit?` · `VisP0 bit?` · `FT24H int?` · `NT24H int?` · `FTNew int?` · `PInter decimal(5, 2)?` · `FTBDay int?` · `FPrPr bit?` · `FPrCr bit?` · `ScPromo decimal(5, 2)?` · `ScLun bit?` · `ScMar bit?` · `ScMer bit?` · `ScGio bit?` · `ScVen bit?` · `ScSab bit?` · `ScDom bit?` · `OraPIni datetime?` · `OraPEnd datetime?` · `DataPIni datetime?` · `DataPEnd datetime?` · `AddSP bit?` · `PrNoSc bit?` · `TmOpen datetime?` · `TmClose datetime?` · `OpScoMan bit?` · `AutoNT bit?` · `NTMolt int?` · `OpCli bit?` · `MQPrem bit?` · `VisNome bit?` · `AutoConv bit?` · `TicStat bit?` · `BkDisk varchar(10)?` · `CRaw bit?` · `PercAbb decimal(5, 2)?` · `NTAbb int?` · `PasswSM bit?` · `MagPremLoc bit?` · `PTBon decimal(5, 2)?` · `BTLun bit?` · `BTMar bit?` · `BTMer bit?` · `BTGio bit?` · `BTVen bit?` · `BTSab bit?` · `BTDom bit?` · `OraBIni datetime?` · `OraBEnd datetime?` · `DataBIni datetime?` · `DataBEnd datetime?` · `AbPr bit?` · `AbBt bit?` · `InvPass bit?` · `ManAdd bit?` · `OpMPremi bit?` · `OpALOff bit?` · `HideList bit?` · `HideMov bit?` · `FndCod bit?` · `NoInatt bit?` · `OpRapp bit?` · `NoOAcq bit?` · `VinPrInatt bit?` · `Inv0 bit?` · `BkpOk bit?` · `Easys bit?` · `FornMan bit?` · `POMan bit?` · `MdbSaveInt int?` · `OpAppL bit?` · `NewConc bit?` · `IniConc datetime?` · `BandaMag bit?` · `RegInc bit?` · `IncDay tinyint?` · `LastInc datetime?` · `IncIva decimal(5, 2)?` · `CanPO bit?` · `NoAnnAPl bit?` · `ValGett decimal(6, 3)?` · `ValTick decimal(6, 4)?` · `NtickRic int?` · `OrInv varchar(8)?` · `AbOrInv bit?` · `ALAggTick bit?` · `ALAggCosto bit?` · `ALAggRis bit?` · `ALAggBarc bit?` · `SaveScan bit?` · `NoCanPr bit?` · `ModCode bit?` · `IdMT1 tinyint?` · `IdMT2 tinyint?` · `IdMT3 tinyint?` · `IdMT4 tinyint?` · `IdMT5 tinyint?` · `CIndir bit?` · `Ab4Usr bit?` · `AbBr0 bit?` · `AbBr1 bit?` · `AbBr2 bit?` · `AbBr3 bit?` · `PBRm0 tinyint?` · `PBRm1 tinyint?` · `PBRm2 tinyint?` · `PBRm3 tinyint?` · `AbMon3 bit?` · `Mon3H int?` · `Mon3V int?` · `VBase decimal(5, 2)?` · `ConnOk bit?` · `AdmPass varchar(100)?` · `HSMOp bit?` · `HSMMa bit?` · `Mistral bit?` · `MisCode varchar(10)?` · `MisVCard int?` · `MisVSerie int?` · `FtpPOrd bit?` · `MisData datetime?` · `MisCard int?` · `MisSerie int?` · `OpModCli bit?` · `MMCosto bit?` · `MMTick bit?` · `ALAggType bit?` · `MMMSco bit?` · `EndOk bit?` · `DataStop bit?` · `AbId2 bit?` · `NomeSped varchar(100)?` · `IndSped varchar(200)?` · `CittaSped varchar(100)?` · `ProvSped varchar(100)?` · `TelSped varchar(100)?` · `TRed decimal(5, 2)?` · `TGru decimal(5, 2)?` · `TPus decimal(5, 2)?` · `TAlt decimal(5, 2)?` · `NewSet bit?` · `Master bit?` · `CodEcs varchar(23)?` · `Modif int?` · `SyncRes varchar(100)?` · `SyncEn bit? =(0)` · `NRepMT1 tinyint =(0)` · `NRepMT2 tinyint =(0)` · `NRepMT3 tinyint =(0)` · `NRepMT4 tinyint =(0)` · `NRepMT5 tinyint =(0)` · `F0 bit?` · `F1 bit?` · `F2 bit?` · `F3 bit?` · `F4 bit?` · `F5 bit?` · `F6 bit?` · `F7 bit?` · `T0 varchar(100)?` · `T1 varchar(100)?` · `T2 varchar(100)?` · `T3 varchar(100)?` · `T4 varchar(100)?` · `T5 varchar(100)?` · `T6 varchar(1000)?` · `T7 varchar(1000)?` · `N0 int?` · `N1 int?` · `N2 int?` · `N3 int?` · `N4 int?` · `N5 int?` · `N6 int?` · `N7 int?` · `D0 datetime?` · `D1 datetime?` · `D2 datetime?` · `D3 datetime?` · `D4 datetime?` · `D5 datetime?` · `D6 datetime?` · `D7 datetime?` · `F8 bit?` · `F9 bit?` · `F10 bit?` · `F11 bit?` · `F12 bit?` · `F13 bit?` · `F14 bit?` · `F15 bit?` · `T8 varchar(100)?` · `T9 varchar(100)?` · `T10 varchar(100)?` · `T11 varchar(100)?` · `T12 varchar(100)?` · `T13 varchar(100)?` · `T14 varchar(1000)?` · `T15 varchar(1000)?` · `N8 int?` · `N9 int?` · `N10 int?` · `N11 int?` · `N12 int?` · `N13 int?` · `N14 int?` · `N15 int?` · `D8 datetime?` · `D9 datetime?` · `D10 datetime?` · `D11 datetime?` · `D12 datetime?` · `D13 datetime?` · `D14 datetime?` · `D15 datetime?` · `GCassa bit =(0)` · `VCassa money?`

### setup2
3 colonne · PK(IdPost, Chiave) C

`IdPost int` · `Chiave nvarchar(255)` · `Valore nvarchar(max)?`

### Setup_Descriptions
4 colonne · PK(Chiave, NomeCampo) C

`Chiave nvarchar(255)` · `NomeCampo nvarchar(255)` · `Gruppo nvarchar(255)?` · `Descrizione nvarchar(max)?`

### Tickets
23 colonne · PK(Keys) C · **SYNC** · indici: Data; IdContatto; Data; IdContatto/NonCont/Aux; NonCont/Aux/Data; NonCont/Aux/IdContatto; TPagati; TPagati/T0; TPagati/T0; MangiaT; NumTrans; TPagati

`IdContatto bigint` · `NumTickets decimal(6, 0)?` · `Data datetime?` · `MangiaT decimal(5, 0)?` · `NumTrans decimal(10, 0)?` · `TPagati decimal(6, 0)?` · `DataOut datetime?` · `Oper decimal(5, 0)?` · `OperOut decimal(5, 0)?` · `NonCont bit? =(0)` · `Id decimal(5, 0)?` · `Aux bit? =(0)` · `NRep tinyint?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `F1 bit =(0)` · `T1 varchar(100)?` · `N1 int?` · `D1 datetime?` · `Keys uniqueidentifier =newid()`

### TicketsCan
13 colonne · PK(Keys) C · **SYNC** · indici: NumTrans

`IdContatto bigint` · `NumTickets decimal(6, 0)?` · `Data datetime?` · `MangiaT decimal(5, 0)?` · `NumTrans decimal(10, 0)` · `TPagati decimal(6, 0)?` · `DataCan datetime?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### TickRep
11 colonne · PK(Keys) C · **SYNC** · indici: IdCliente

`IdOperatore decimal(5, 0)?` · `IdCliente bigint` · `NumTickets decimal(6, 0)?` · `NRep decimal(2, 0)?` · `Data datetime?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`

### TipoRicaricheCompleanni
9 colonne · PK(id) C

`id int ident` · `descrizione varchar(255)` · `ValorePrecaricatoCrediti int =(0)` · `ValorePrecaricatoBonus int =(0)` · `abilitato int =(1)` · `CreatedBy bigint?` · `CreatedAt datetime2(7)?` · `UpdatedBy bigint?` · `UpdatedAt datetime2(7)?`

### TransCard
16 colonne · PK(IDOperazione) C · **SYNC** · indici: IDOperazione; CodMac/D0/WinMt; CodMac/WinMt/Data/ValoreOperazione; D0/WinMt/NImp/ValoreCassa; N0/FlagOpDaVerificare; N0; N0; NImp/D0/WinMt; NImp/Data; NImp/Operatore/WinMt/Data/ValoreOperazione; NImp/Operatore/WinMt/Data/ValoreOperazione; NImp/Operatore/WinMt/Data/ValoreOperazione; NImp/Operatore/WinMt/Data/ValoreOperazione; NImp/WinMt/Data; NImp/WinMt/Data/ValoreOperazione; NImp/WinMt/Data/ValoreOperazione; WinMt/CodMac; WinMt/Data/ValoreOperazione; WinMt/Data; WinMt/Data/ValoreOperazione; WinMt/NImp/Data/ValoreOperazione; WinMt/NImp/Data/ValoreOperazione; IdCli/Data/N0; NImp/Data

`IdCli varchar(16)?` · `NImp int?` · `CodMac varchar(50)?` · `Data datetime?` · `ValoreOperazione money?` · `ValoreFinale money?` · `ValoreBonus money =(0)` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Operatore int?` · `ValoreCassa money?` · `WinMt bit? =(0)` · `IDOperazione uniqueidentifier =newid()` · `FlagOpDaVerificare int?`

### TransCard_Consolidamento_Backup
21 colonne · nessuna PK

`IdRun int?` · `BackupAt datetime?` · `BackupReason varchar(100)?` · `CategoriaSessione varchar(50)?` · `SessionId int?` · `IdCli varchar(16)?` · `NImp int?` · `CodMac varchar(50)?` · `Data datetime?` · `ValoreOperazione money?` · `ValoreFinale money?` · `ValoreBonus money` · `F0 bit` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Operatore int?` · `ValoreCassa money?` · `WinMt bit?` · `IDOperazione uniqueidentifier` · `FlagOpDaVerificare int?`

### TransCard_Consolidamento_Log
11 colonne · PK(IdRun) C

`IdRun int ident` · `StartedAt datetime =getdate()` · `EndedAt datetime?` · `DataMinRange datetime` · `DataMaxRange datetime` · `DryRun bit` · `Status varchar(30)` · `Note varchar(500)?` · `SessioniAnalizzate int?` · `SessioniConsolidate int?` · `SessioniScartate int?`

### TransCard_Consolidamento_Map
9 colonne · nessuna PK

`IdRun int` · `SessionId int` · `IdCli varchar(16)` · `CategoriaSessione varchar(50)` · `ActionType varchar(20)` · `OldIDOperazione uniqueidentifier?` · `NewIDOperazione uniqueidentifier?` · `Note varchar(200)?` · `CreatedAt datetime =getdate()`

### Type
7 colonne · PK(Id) C · **SYNC** · indici: U Id

`Id bigint` · `TypeName varchar(50)` · `Color bigint?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?`

### UID_Ammessi
4 colonne · PK(UID) C · **SYNC**

`UID varchar(16)` · `CodBar varchar(15)?` · `DataCreazione date? =getdate()` · `DataEmissione datetime?`

### uid_reservations
4 colonne · PK(CodBar) C · indici: ExpiresAt

`CodBar varchar(50)` · `ReservedAt datetime2(0) =sysdatetime()` · `ReservedBy varchar(64)` · `ExpiresAt datetime2(0)`

### UltimoInventario
31 colonne · nessuna PK

`codice nvarchar(50)?` · `data date?` · `key int?` · `oper int?` · `CodOr nvarchar(50)?` · `Fornitore nvarchar(100)?` · `Id nvarchar(50)?` · `Descrizione nvarchar(255)?` · `Costo decimal(18, 2)?` · `N_Tickets int?` · `NBolla nvarchar(50)?` · `foto nvarchar(255)?` · `qagg int?` · `qtrasin int?` · `qgrui int?` · `qconi int?` · `qevei int?` · `qpushi int?` · `qtrasout int?` · `qguasta int?` · `qgruo int?` · `qcono int?` · `qeveo int?` · `qvend int?` · `qpusho int?` · `qini int?` · `Gru nvarchar(50)?` · `qmacc int?` · `qpres int?` · `qreal int?` · `dos decimal(10, 2)?`

### Vincite
19 colonne · PK(Keys) C · **SYNC** · indici: Codice; IdContatto/D0; IdContatto/Data

`IdContatto bigint` · `Codice varchar(50)` · `Descrizione varchar(255)?` · `Costo money?` · `N_Tickets decimal(10, 0)?` · `Fornitore varchar(255)?` · `Data datetime?` · `Id decimal(5, 0)?` · `NImp int?` · `Cons bit =(0)` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `F1 bit =(0)` · `T1 varchar(100)?` · `N1 int?` · `D1 datetime?` · `Keys uniqueidentifier =newid()`

### Vincite25
15 colonne · PK(Keys) C · **SYNC** · indici: U Codice

`IdContatto bigint?` · `Codice varchar(50)` · `Descrizione varchar(255)?` · `N_Tickets decimal(10, 0)?` · `Data datetime?` · `Nome varchar(100)?` · `Cognome varchar(100)?` · `BarCode varchar(255)?` · `Costo money?` · `NImp int?` · `F0 bit =(0)` · `T0 varchar(100)?` · `N0 int?` · `D0 datetime?` · `Keys uniqueidentifier =newid()`
