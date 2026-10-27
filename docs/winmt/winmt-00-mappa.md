# Galileo HQ — WinMT 00: mappa del codice sorgente

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

**Fonte:** sorgente VB6 di WinMT, copia del 24/07/2026 da `TOBY-DEV-VM` (`legacy/WinMTsql/`, escluso dal repository) · **Collegati:** `winmt-01` … `winmt-10` (analisi per zona), `docs/db/db-07-confronto-test-produzione.md`

Il codice di WinMT è la fonte più affidabile per capire cosa fa il sistema e cosa significano i dati. Questo documento ne dà la mappa: cosa contiene il progetto, con quali tecnologie, come accede al database, e come è stato suddiviso per l'analisi. I flussi e il significato delle colonne sono nei documenti di zona.

---

## 1. Il progetto

| Voce | Valore |
|------|--------|
| Progetto | `WinMtsql.vbp`, eseguibile `WinMtSql 1.2.166.exe`, avvio da `Sub Main` in `Module1.bas` |
| Produttore dichiarato | ELMAC II srl, "Galileo System", copyright 2005–2020 |
| Branch | `MQTT` (secondo `doc/frmInfoPOS_analisi.md`) |
| File sorgente | 211: 138 form (`.frm`), 45 classi (`.cls`), 27 moduli (`.bas`), 1 user control (`.ctl`) |
| Righe totali | 290.091, di cui **131.966 di codice** (il resto è layout delle form, commenti e righe vuote) |
| Procedure | 4.408 |
| File più grande | `Form1.frm`, la form principale: 11.273 righe di codice, 297 procedure |

Il backup elenca 331 file, compresi i `.frx` (risorse binarie delle form) e un documento di analisi già esistente su `frmInfoPOS` (`doc/frmInfoPOS_analisi.md`, del 29/09/2026).

### Varianti di compilazione

Il progetto prevede sei costanti di compilazione condizionale, tutte a 0 in questa copia:

| Costante | Occorrenze | File | Significato probabile |
|----------|-----------:|-----:|-----------------------|
| `demo` | 79 | 19 | Versione dimostrativa |
| `Easy` | 31 | 9 | Versione semplificata per le sale "Easy" (citate il 19/10) |
| `NoKey` | 5 | 2 | Senza chiave hardware HASP |
| `admin` | 2 | 2 | ? |
| `Ceschina` | 2 | 1 | Variante per un cliente |
| `kevin` | 1 | 1 | Variante per un cliente o uno sviluppatore |

> **Ipotesi.** Le costanti con nomi di persona o di cliente sono la traccia, nel codice, delle personalizzazioni per installazione di cui si è parlato il 19/10 (circa 200 fork). Altre personalizzazioni possono vivere in impostazioni di `Setup` e in condizioni a runtime: i documenti di zona le segnalano quando le trovano.

---

## 2. Tecnologie e componenti esterni

Ricavati dai riferimenti del progetto (`WinMtsql.vbp`).

| Area | Componenti |
|------|------------|
| Accesso ai dati | ADO 6.0 (`msado60_Backcompat`), controlli dati ADODC (`MSAdoDc.ocx`), Data Environment, **DAO 3.6** (file Access `.mdb`) |
| Griglie e report | ComponentOne VSFlexGrid 8, VSPrint 8, VSReport 8, MSFlexGrid, MSHFlexGrid, DataGrid, DBGrid, MSChart |
| Periferiche e rete | `SerComm` e `SComm32.ocx` (porte seriali), `MSWINSCK.ocx` (socket TCP), **`MqttCom`** (client MQTT), Windows Media Player |
| Licenza | **HASP SRM** (Aladdin/Thales): chiave hardware |
| Varie | Microsoft XML 6, VBScript RegExp, Scripting Runtime, controlli comuni di Windows, `MyCommandButton.ocx`, `anigif.ocx`, `todg8.ocx` |

Tutti i componenti sono a 32 bit e diversi non sono più supportati. È il rischio di *hard stop* tecnologico citato nella riunione del 07/10.

---

## 3. Come il codice accede al database

Il database si raggiunge in quattro modi, spesso mescolati nella stessa form:

1. **Controlli dati ADODC** (199 nel progetto). Molti portano il nome della tabella o un nome derivato (`Giocatori` per `Clienti`, `Inc` per `Incassi`, `VinciteAdo`, `TicCan`). La query si imposta a runtime (`RecordSource = "select * from …"`, 1.071 assegnazioni). Le scritture avvengono modificando il recordset del controllo: `Giocatori.Recordset!Tickets = …`, poi `.Update`.
2. **Recordset ADO** creati nel codice (371 `New ADODB.Recordset`), aggiornati allo stesso modo con `.AddNew` e `.Update`.
3. **Comandi SQL** eseguiti direttamente (`.Execute`, 434 occorrenze), soprattutto per `UPDATE` e `DELETE`.
4. **Stored procedure**, poche, soprattutto nei moduli recenti (Redeem, gru, consolidamento).

Ne derivano due conseguenze per l'analisi:
- **le scritture non si trovano cercando `INSERT` e `UPDATE`**: la maggior parte passa dai recordset, quindi va seguito il codice;
- **le regole di business sono distribuite nelle form**: lo stesso dato, per esempio il saldo ticket del cliente, viene aggiornato da più punti, ciascuno con la sua logica.

Le stringhe di connessione e alcune **credenziali sono scritte nel codice**, nel designer di diverse form e nei moduli. Non sono riportate nei documenti di analisi.

---

## 4. Tabelle che WinMT non usa

Un indice costruito automaticamente sulle stringhe SQL e sui riferimenti ai campi (approssimato: non vede tutto) indica che **35 delle tabelle e viste del database non compaiono mai nel codice di WinMT**. Tra queste:

| Gruppo | Oggetti | Chi li usa, presumibilmente |
|--------|---------|------------------------------|
| Telemetria e provisioning ECL | `ecl_log`, `ecl_Provisioning`, `ecl_DeviceProvisioning`, `ecl_firmware`, `ecl_SchedeFirmware`, `BEConfig`, `rawdata` | Motore di sala (B4J) e servizio .NET |
| Flusso coinless | `CoinlessDecodedData`, `CoinlessImages`, `CoinlessLanguages` | Trigger del DB e motore di sala |
| Gru | `GruMagazzino`, `GruMovimenti` | Stored procedure `sp_crane_*` e motore di sala |
| Consolidamento | `TransCard_Consolidamento_*` | Procedura `sp_consolida_transcard_sessioni_cash` |
| Viste su contatori e macchine | `vs_*` (13 viste) | Report esterni, HQ o motore di sala |
| Sincronizzazione | `scope_info`, `scope_config`, `schema_info` | Sync Framework |
| Residui | `save_ciapett`, `debug_log`, `SetupNew` | — |

> **Conseguenza.** Il perimetro dei dati di WinMT è solo una parte del database. Il resto è scritto e letto da componenti di cui non abbiamo ancora analizzato il sorgente: motore B4J, servizio .NET, HQ. Per un dizionario dei dati completo serve anche quel codice.

---

## 5. Suddivisione per l'analisi

Il codice è stato diviso in dieci zone funzionali, analizzate separatamente. Ogni file appartiene a una sola zona.

| Doc | Zona | File | Righe di codice | File principali |
|-----|------|-----:|----------------:|-----------------|
| WinMT 01 | La form principale (cassa e banco) | 1 | 11.273 | `Form1` |
| WinMT 02 | Moduli comuni e accesso ai dati | 43 | 12.885 | `Module1`, `Module6`, `ModAddNew` |
| WinMT 03 | Clienti, card, livelli, compleanni e promozioni | 33 | 22.019 | `frmAstoria`, `FrmDeCli`, `frmCardFamily`, `frmCompleanni` |
| WinMT 04 | Card elettroniche (ECL), cassa ECL e pagamenti | 31 | 16.909 | `ECL_database`, `FrmSetECL`, `frmCassa`, `frmInfoPOS` |
| WinMT 05 | Ticket, card tradizionali, scontrini, resi e archivi | 22 | 11.268 | `FrmCCard`, `Frm4Usr`, `FrmCanArc` |
| WinMT 06 | Premi, magazzino, ordini e prenotazioni | 17 | 12.688 | `frmpremi`, `FrmMovmag`, `FrmLismovN` |
| WinMT 07 | Inventario, PrizeHub e gru | 9 | 9.887 | `FrmInventario`, `frmEditPrizeHub` |
| WinMT 08 | Macchine, contatori e incassi | 18 | 14.132 | `FrmCont`, `frmConfMacc`, `FrmEcs` |
| WinMT 09 | Rapporti e statistiche | 8 | 8.789 | `frmrapp`, `FrmRappUs`, `frmWrapp` |
| WinMT 10 | Configurazione, operatori, licenza e periferiche | 29 | 12.116 | `frmsetSys`, `frmsetGen`, `frmLogin1` |
| | **Totale** | **211** | **131.966** | |

Ogni documento di zona contiene i flussi, ciascuno con un peso (S, M, L), e il significato delle colonne usate, con il riferimento `file:riga` e l'indicazione di cosa è verificato nel codice e cosa è dedotto.

---

## 6. Sintesi trasversale

Ciò che emerge mettendo insieme le dieci zone. I punti segnati **[verificato]** sono stati ricontrollati sul sorgente durante la revisione dei documenti di zona. Gli altri vengono dalle zone, con le evidenze `file:riga` indicate lì.

**Numeri.** 228 flussi descritti, che diventano **191 flussi attivi** una volta tolti duplicati, codice morto e flussi eseguiti da altri componenti: 53 S, 98 M, 40 L (Analisi 01). Circa 580 colonne decodificate (DB 08).

1. **Il saldo del cliente non ha una sola fonte.**
   - I punti sono lotti in `Tickets`, consumati dal più vecchio aggiornando `TPagati`; `Clienti.Tickets` ne è una copia, sovrascritta da più punti del codice.
   - I crediti stanno sulla card, nell'ultimo `ValoreFinale` di `TransCard`, in `Clienti.Credito` e in `CoinlessCards`.
   - Solo la creazione del cliente usa una transazione. La cassa scrive prima la card e poi il database.

   È la conferma, dal codice, dell'indicazione di DB 01: i saldi del nuovo sistema devono derivare da un registro di movimenti.
2. **Le colonne cambiano significato secondo la tabella, la riga o la configurazione.**
   - `NImp` è la sala in `Clienti` e `Tickets`, ma il tipo di operazione in `TransCard` **[verificato]**.
   - Le tabelle figlie riferiscono `IdContatto` o `IdLong` (`IdContatto × 10000 + NImp`) a seconda che la sala sia in un gruppo **[verificato]**.
   - `Clienti.Foto` è un JSON di attributi **[verificato]**.
   - `Setup` mescola configurazione di sala, di postazione, servizio e raccolte card.
3. **Lo storico si perde per scelta del codice.**
   - Eliminare una macchina cancella i suoi `TransCard` ed `EcsDati` **[verificato]**.
   - "Cancella Archivi" offre l'opzione di spostare i dati nell'archivio storico, ma il codice non la usa: cancella e basta **[verificato]**.
   - Gli articoli si cancellano e i codici si cambiano senza aggiornare lo storico; gli operatori si cancellano.

   Questo spiega gli orfani visti in DB 03–06 e riguarda il requisito "non perdere le transazioni".
4. **File Access dentro e fuori dal database.**
   - Inventari e conteggi incasso sono file `.mdb` salvati nelle colonne `RiepInv.Mdb` e `Incassi.Mdb`.
   - Trasferimenti tra locali, ordini remoti e liste premi viaggiano come file `.mdb`.
5. **L'applicazione gestisce lo schema.** All'avvio WinMT modifica tabelle e riscrive stored procedure, comprese le `sp_redeem_*` nella versione con parametri OUTPUT **[verificato]**.
   > **Ipotesi.** Il motore B4J fa lo stesso con le proprie versioni, e i due componenti si sovrascrivono a vicenda. Spiegherebbe la divergenza tra test e produzione vista in DB 07.
   >
   > **Aggiornamento 25/10 (ecl2mqtt 00 § 3.3).** È confermata a metà. Il motore crea tabelle e ricrea una vista all'avvio, ma non crea procedure: le versioni "B4X" delle `sp_redeem_*` sono state installate a parte. Il rischio di sovrascrittura resta, nel verso WinMT → motore.
6. **Nessuna modalità offline della cassa.**
   - Senza database la cassa si blocca.
   - Ogni postazione si collega direttamente come db_owner.
   - Le credenziali sono scritte nel codice o offuscate con una codifica reversibile senza chiave.

   Il requisito di autonomia della sala oggi riguarda i giochi e le schede, non la cassa.
7. **Varianti per cliente dentro lo stesso codice.**
   - Costanti di compilazione (§ 1) e rami a runtime su `Setup.N14`: Astoria, Alba, Golden.
   - La variante **Astoria** tiene il saldo solo sul database, senza scriverlo sulla card: è il modello più vicino al nuovo disegno.
8. **I rapporti non sono una fonte affidabile delle misure.**
   - Il valore del ticket è fisso a 0,01 € nel codice e `Setup.ValTick` non viene usato **[verificato]**.
   - Il Rapporto Vendite modifica `Tickets.NumTickets` a ogni apertura **[verificato]**.
   - Le stesse misure sono calcolate in modo diverso da finestre diverse.
   - "Rapporti Vari" e "Rapporti Amministratori" sono definiti in un database cloud, fuori dal sorgente.
9. **Codice morto e funzioni non raggiungibili.**
   - Inventario v2 (`FrmInventario2`) **[verificato]**.
   - Gestione proprietari, alcune form delle macchine, unione card ECL.
   - `AuditLog` esiste ma WinMT non lo scrive.

## 7. Cosa manca

$1 Il 27/10 sono arrivati `ExecuteSync` e `WinMtProv`, gli strumenti della sincronizzazione sala–cloud (sync 00); manca ancora il componente che pianifica la sincronizzazione e ne scrive l'esito in `Setup`. Il motore B4J (`ecl2mqtt`, già `ecs2mqtt`) è stato analizzato il 25/10 (ecl2mqtt 00–07). Scrivono le tabelle che WinMT non tocca e una parte di quelle che tocca: partite, ticket ticketless, gru, PrizeHub, contatori. Diverse procedure chiamate da WinMT esistono solo nel cloud (`sp_preleva_punti`, `sp_last_trans`, `sp_unione_card`, `sp_punti_cliente*`). Tutte, salvo `sp_unione_card`, stanno nel DB clienti di gruppo raggiunto con `CServer` (`Setup(101).T7`): versione di test `CliTest`, analizzata in DB 09.
- **Conferme dal team** sulle voci **D** (dedotte) e sulle domande aperte di ciascun documento di zona.
- **Uso reale delle varianti** nelle sale: Golden, Easy, Albarella, Astoria, sistema 4 utenti, raccolte card. Serve a decidere cosa entra nel nuovo sistema.
