# Galileo HQ — ecl2mqtt 08: matrice di accesso ai dati

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-26

**Fonte:** sorgente di `ecl2mqtt` 2.39.55 (`legacy/ecl2mqtt/`) e di WinMT (`legacy/WinMTsql/`), codice SQL in `sql/codice-db/`, documenti WinMT 01–10 e Analisi 01 · **Collegati:** [`ecl2mqtt-00-mappa.md`](ecl2mqtt-00-mappa.md) (§ 3 e § 5), `docs/db/db-08-dizionario-dati.md`, `docs/db/db-09-clitest-clienti-multisala.md`

Chi legge e chi scrive ogni tabella del DB di sala: il motore `ecl2mqtt`, WinMT e il codice del database (procedure e trigger). Serve a individuare le tabelle con più scrittori, che sono i punti di doppione, e i **campi jolly** (`F0`, `T0`, `N0`, `D0` e simili) a cui i diversi programmi danno significati diversi (§ 3).

---

## 1. Come è costruita

| Colonna | Origine | Affidabilità |
|---|---|---|
| **ecl2mqtt** | Ricerca nel sorgente B4J delle istruzioni SQL sulla tabella: `L` = `FROM`/`JOIN`, `I` = `INSERT`, `U` = `UPDATE`, `D` = `DELETE`, `M` = `MERGE`, `DDL` = `CREATE`/`ALTER` | Buona. Non vede le query con nome di tabella composto a runtime: per questo `Machines`, `Manuf` e `Type`, scritte sul cloud, sono state aggiunte a mano |
| **WinMT** | `scrive` = la tabella compare tra le tabelle scritte di almeno un flusso attivo (Analisi 01, esclusi i flussi esterni e morti, e righe "Dati" di WinMT 01–10); `cita` = compare nel codice VB6 ma in nessun flusso come scritta, quindi presumibilmente è solo letta | Media. WinMT scrive tramite recordset e i documenti di zona sono la fonte migliore disponibile |
| **Codice del DB che scrive** | Procedure, funzioni e trigger applicativi di test e produzione (`sql/codice-db/*/applicativo/`) con `INSERT`, `UPDATE`, `DELETE` o `MERGE` sulla tabella | Buona |
| **Sync** | La tabella è sincronizzata con il cloud dal Sync Framework nel DB di produzione (copia del 14/07/2026) | Buona |

Sono elencate le tabelle che almeno un programma usa. Quelle di Sync Framework e quelle mai usate sono escluse.

## 2. Matrice per area

### Clienti e card

| Tabella | ecl2mqtt | WinMT | Codice del DB che scrive | Sync | Note |
|---|---|---|---|:-:|---|
| `Clienti` | L I U | scrive | `decodifica_record`, `scriviTicketsAutomatici`, `scriviTicketsDaCoinless`, `sp_eliminacliente`, `sp_rimuovidabl`, `sp_ripristinacard` | sì | Saldi, token app (`UserName`), PIN (`Password`), `Abilita`, `N0`; 3 formule di saldo nel motore (02 § 5.1) |
| `CoinlessCards` | L M | scrive | `decodifica_record`, `sp_eliminacliente`, `sp_rimuovidabl`, `sp_ripristinacard` | no | La scrittura del motore (blacklist) è disattivata (01 E01-16) |
| `CoinlessClonedCards` | L | scrive | `decodifica_record`, `sp_eliminacliente`, `sp_rimuovidabl`, `sp_ripristinacard` | sì |  |
| `CoinlessLogEventiBlacklist` | L | scrive | `decodifica_record`, `sp_eliminacliente`, `sp_rimuovidabl`, `sp_ripristinacard` | sì |  |
| `UID_Ammessi` | L | scrive | `FinalizeUidCodbar` | sì | Regola di verifica diversa da WinMT (04 § 5.3) |
| `uid_reservations` | — | scrive | `FinalizeUidCodbar`, `GetFreeUidCodbar` | no |  |
| `Compleanni` | L | scrive | `sp_eliminacliente`, `sp_ripristinacard` | sì |  |
| `Ospiti` | L I | scrive | `sp_eliminacliente`, `sp_ripristinacard` | sì |  |
| `PartiteOspiti` | L U M | cita | — | sì | Scritta solo dal motore (03 § 4b) |
| `Figli` | — | scrive | `sp_eliminacliente` | sì |  |
| `promozioni` | L | scrive | — | sì |  |
| `promozioni_cards` | L I D | scrive | `sp_eliminacliente`, `sp_ripristinacard` | sì | Promozione Gold in `create-user` e redeem |
| `Scocard` | — | scrive | — | sì |  |
| `TipoRicaricheCompleanni` | — | scrive | — | sì |  |

### Valore a circuito chiuso

| Tabella | ecl2mqtt | WinMT | Codice del DB che scrive | Sync | Note |
|---|---|---|---|:-:|---|
| `TransCard` | L I D | scrive | `aggiornaCard`, `decodifica_record`, `sp_consolida_transcard_sessioni_cash`, `sp_eliminacliente` | sì | `NImp` 0/2/6/8/12 dal motore con `T0`, `F0`, `CodMac` diversi da WinMT (00 § 5.2); `DELETE` totale in Armageddon |
| `Tickets` | L I U | scrive | `scriviTicketsAutomatici`, `scriviTicketsDaCoinless`, `sp_eliminacliente` | sì | Lotti `MangiaT` 1/64/8256, `NRep 8`, `Oper 10000`; ticket automatici anche da procedura (02 § 5.3) |
| `CoinlessDataBuffer` | L I U | cita | — | no | Ticket vinti in attesa di accredito, per card |
| `CoinlessTransazioniCards` | — | cita | `decodifica_record`, `scriviTransazioneCard`, `sp_eliminacliente`, `sp_rimuovidabl`, `sp_ripristinacard` | no |  |
| `RedeemCodes` | L | scrive | `sp_redeem_cancel`, `sp_redeem_check_and_reserve_no_pin`, `sp_redeem_confirm`, `sp_redeem_create` | sì | Il motore scrive tramite `sp_redeem_*` (versioni B4X) |
| `LogTransazioniTotem` | I U | scrive | — | sì | Anche il totem attuale scrive direttamente (05 § 3c) |
| `LogTransazioniPos` | I U | scrive | — | sì | Colonne EMV usate per altri dati (00 § 5.2) |
| `Abbuoni` | — | scrive | — | sì |  |
| `TicketsCan` | — | scrive | — | sì |  |
| `Incassi` | L | scrive | — | sì |  |
| `TransCard_Consolidamento_Backup` | — | — | `sp_consolida_transcard_sessioni_cash` | no |  |
| `TransCard_Consolidamento_Log` | — | — | `sp_consolida_transcard_sessioni_cash` | no |  |
| `TransCard_Consolidamento_Map` | — | — | `sp_consolida_transcard_sessioni_cash` | no |  |

### Macchine e telemetria

| Tabella | ecl2mqtt | WinMT | Codice del DB che scrive | Sync | Note |
|---|---|---|---|:-:|---|
| `EcsMacchine` | L I U | scrive | `sp_crane_sync_ecsmacchine_values` | sì | `T0` JSON di stato, `F0` pending, `device_status`; costi per livello dal backoffice (06 § 5) |
| `EcsDati` | L I U D | scrive | `inseriscesuECS`, `insertrecordWINMT`, `scriviTicketsAutomatici` | sì | Il motore cancella letture (test mode, assegnazione, Armageddon) |
| `EcsModuli` | L U D M | scrive | — | sì | `ShortAd` = device, `T0` = JSON IP, `NImp` = flag (contraddicono db-08) |
| `CoinlessDati` | I | cita | — | no | Record grezzo della scheda; il trigger `decodifica_flusso` lo elabora |
| `CoinlessDecodedData` | L I | cita | `decodifica_record`, `insertrecordWINMT` | no | Snapshot contatori dal trigger; il motore lo legge |
| `CoinlessTestataHappyHour` | L | scrive | — | sì | Configurate da WinMT, applicate dal motore |
| `CoinlessMacchineHappyHour` | L | scrive | — | sì | come sopra |
| `Machines` | I (cloud) | scrive | — | sì | Il motore scrive il catalogo nel DB di servizio **cloud** (`elmaccloud.<svc>`), non in sala |
| `Manuf` | I (cloud) | scrive | — | sì | come `Machines` |
| `Type` | L I (cloud) | scrive | — | sì | come `Machines` |
| `cache_dati_grafico_giornaliero` | — | scrive | `sp_generacache`, `sp_generacache_old` | sì | Chi lancia `sp_generacache` è da chiarire (07 § 6) |

### Schede, firmware e provisioning

| Tabella | ecl2mqtt | WinMT | Codice del DB che scrive | Sync | Note |
|---|---|---|---|:-:|---|
| `ecl_SchedeFirmware` | L I U D | — | — | sì |  |
| `ecl_firmware` | L I D | — | — | sì |  |
| `ecl_Provisioning` | L I D | — | — | sì |  |
| `ecl_DeviceProvisioning` | L I U D | — | — | sì |  |
| `BEConfig` | L M DDL | — | — | sì | Tabella creata e modificata dal motore all'avvio |
| `CoinlessImages` | L I U M | — | — | sì | Anche i firmware della BI (`.srec`) |
| `CoinlessLanguages` | L I U | — | — | sì |  |
| `coinless_sbuilder_pages` | L I U D DDL | cita | — | sì | Tabelle create dal motore (`ScreenBuilder`) |
| `coinless_sbuilder_templates_svg` | L I U DDL | cita | — | sì | come sopra |
| `Coinless_sbuilder_page_provisioning` | L I D DDL | cita | — | sì | come sopra |

### Premi, magazzino, PrizeHub e gru

| Tabella | ecl2mqtt | WinMT | Codice del DB che scrive | Sync | Note |
|---|---|---|---|:-:|---|
| `Premi` | L I U M | scrive | `PrizeHub_MoveToSlot` | sì | Articoli fittizi `SPINDLE…`; `PDis/QDis` ancora usati; due modelli di giacenza (03 § 5.4) |
| `Vincite` | I | scrive | `sp_eliminacliente` | sì | Una riga per richiesta (WinMT: una per pezzo) |
| `MovMag` | I | scrive | `PrizeHub_MoveToSlot` | sì | Causali `PRIZEHUB`, `CARICO` (rientro da gru) |
| `MovOut` | I U | scrive | `PrizeHub_MoveToSlot` | sì | Causali `PRIZEHUB`, `GRU` |
| `PrizeHubSlots` | L I U D | via API del motore | — | no | WinMT scrive solo tramite le API del motore (Opzione A) |
| `GruMagazzino` | via procedura | scrive | `sp_crane_ensure_records`, `sp_crane_list` | sì | Righe create da `sp_crane_ensure_records` |
| `GruMagazzinoDettaglio` | L U | cita | `sp_crane_ensure_records`, `sp_crane_force_avg_value`, `sp_crane_list` | sì | WinMT forza il valore medio con `sp_crane_force_avg_value` |
| `GruMovimenti` | L I | cita | `sp_crane_force_avg_value` | sì | LOAD, UNLOAD, WIN dal motore; ADJUST+ da WinMT via procedura |
| `CraneCounterSyncLog` | L I | cita | — | no | Scritta dal motore (db-08 la dava a un servizio esterno) |
| `Prenotaz` | — | scrive | `sp_eliminacliente` | sì |  |
| `Resi` | — | scrive | `sp_eliminacliente` | sì |  |
| `Ordini` | — | scrive | — | sì |  |
| `Fornitori` | — | scrive | — | sì |  |
| `Vincite25` | — | scrive | — | sì |  |
| `RiepInv` | — | scrive | — | sì |  |
| `UltimoInventario` | — | cita | — | no |  |

### Configurazione, operatori e log

| Tabella | ecl2mqtt | WinMT | Codice del DB che scrive | Sync | Note |
|---|---|---|---|:-:|---|
| `Setup` | L U M | scrive | — | sì | Riga di postazione `PRIZEHUB01\|` (MERGE); `AdmPass` riscritto dal backoffice |
| `setup2` | L D M | scrive | — | sì | Archivio chiave/valore di stato: `TestMode_*`, `ArmageddonEseguito`, `PrizeHub0n`, `typename_*`… |
| `Operatori` | L I | scrive | `sp_eliminacliente`, `sp_ripristinacard` | sì | Operatore virtuale `Prizehub1` (Id da 1001) |
| `AuditLog` | I | cita | — | sì | Scritta dal motore (eventi dei dispositivi) |
| `ecl_log` | I DDL | — | — | no | Circa 25.000 righe al giorno in produzione, nessuna pulizia |
| `debug_log` | I | cita | `insertrecordWINMT`, `scriviTicketsAutomatici` | no |  |
| `Logs` | — | scrive | — | no |  |

### Cosa si legge nella matrice

- **Tabelle con tre scrittori** (motore, WinMT, codice del DB): `Clienti`, `TransCard`, `Tickets`, `Vincite`, `Premi`, `MovMag`, `MovOut`, `EcsMacchine`, `EcsDati`, `Operatori`, `Ospiti`, `promozioni_cards`. A queste si aggiungerebbe `CoinlessCards`, dove però la scrittura del motore è disattivata. Sono le tabelle del valore (saldi, movimenti, lotti di punti, vincite), del magazzino premi e della configurazione delle macchine: qui stanno i doppioni descritti in ecl2mqtt 00 § 3.3.
- **Tabelle scritte solo dal motore**: schede, firmware, provisioning e schermate (`ecl_*`, `BEConfig`, `coinless_sbuilder_*`, `Coinless_sbuilder_page_provisioning`, `CoinlessImages`, `CoinlessLanguages`), telemetria grezza (`CoinlessDati`, `CoinlessDataBuffer`), `PrizeHubSlots`, `CraneCounterSyncLog`, `PartiteOspiti`, `AuditLog`, `ecl_log`. Nessuna è descritta in db-08: il significato delle colonne è in ecl2mqtt 04 § 4.3.
- **Tabelle scritte solo da WinMT**: magazzino e anagrafiche (`Ordini`, `Fornitori`, `RiepInv`, `Vincite25`, `Abbuoni`, `TicketsCan`, `Owners`, `Differ`, `Mistral`, `Scocard`, `TipoRicaricheCompleanni`, `Logs`, `EcsErr`). In sala anche `Machines`, `Manuf` e `Type`, che il motore scrive invece nel DB di servizio cloud.
- **Scritture fuori dalla sala**: oltre al catalogo dei modelli, il prelievo multisala scrive `Tickets` nelle copie cloud delle altre sale (DB 09 § 3).

## 3. Campi jolly e colonne riusate

Colonne generiche (`F*`, `T*`, `N*`, `D*`) o con nome fuorviante, il cui significato dipende da chi scrive. Per WinMT il significato è quello di db-08.

| Colonna | WinMT (db-08) | ecl2mqtt | Codice del DB | Conflitto | Doc |
|---|---|---|---|---|---|
| `EcsMacchine.T0` | Valore del piatto o hopper, lunghezza del contascatti | JSON di stato `{valorepiatto, statoBI, errBI, BISwap, BISwapStep, NoRec}` | — | **Sì**: formati incompatibili nella stessa colonna | 02 § 4b, 06 § 4.b |
| `EcsMacchine.F0` | 1 = configurazione da inviare alla scheda | La consuma e la azzera; scrive anche altri stati; le macchine create dal web nascono con 0 | — | Parziale | 01 § 4.b, 06 § 4.b |
| `EcsMacchine.CntrLet9`, `CntrLet16`, `ValIn3/4` | `CntrLet9` = erogatore 2 | Impulsi per tick di gettoniera e banconote, letti da colonne diverse in punti diversi | — | **Sì** | 02 § 4b |
| `EcsMacchine.ValIn6/7/8` | Valore dell'ingresso | Per le gru, valore medio del premio dello slot, riscritto a ogni record di gioco | `sp_crane_sync_ecsmacchine_values` | Sovraccarico per tipo di macchina | 04 § 4.4 |
| `EcsModuli.ShortAd`, `T0`, `NImp` | `ShortAd` = IP del modulo | `ShortAd` = codice del dispositivo, `T0` = JSON con l'IP, `NImp` = flag "riprogrammabile" | — | **Sì** | 02 § 4b, 06 § 4.b |
| `TransCard.NImp` | Tipo di operazione (0 cassa fissa, 1 totem, 13 compleanni, 14 online…) | 0 anche per accrediti da cloud, redeem e `create-user`; 12 = partita gratuita da card operatore; 15 = "bonus trasferiti" | `decodifica_record`: `NULL` per le partite | **Sì** sul significato di 0 e 15 | 04 § 4.4, 05 § 4b |
| `TransCard.T0`, `F0`, `N0`, `CodMac`, `ValoreCassa` | `T0` = sala su 4 cifre; `F0` = multisala; `N0` = progressivo anti-replay; `CodMac` = postazione; `ValoreCassa` = contante | `T0` senza zeri o `NULL`; `F0` sempre 0; `N0` copiato o `MAX+1`; `CodMac` = `CASSA-MOBILE`, `ECL-SERVICE`, `CLOUD`, `kioskId`; `ValoreCassa` anche sui bonus | — | **Sì** | 02 § 4b, 05 § 4b |
| `Tickets.MangiaT` | Bitmap dell'origine del lotto | 1 = e-ticket dal buffer; 64 = ticket manuali; 8256 = ticket automatici (il bit 8192 è "punti da app") | `scriviTicketsAutomatici`: 8256 | **Sì** sul bit 8192 | 02 § 4b |
| `Tickets.NonCont` | Escluso dai conteggi dei vinti, ma spendibile | Escluso anche dal saldo spendibile | `sp_preleva_punti` (cloud): 1 sui lotti "specchio" dei prelievi multisala | **Sì** | 03 § 4b, DB 09 § 3 |
| `Tickets.F1`, `T1`, `N0`, `NRep`, `Oper`, `NumTrans` | `F1`/`T1` = ticketless dal gioco, device; `NRep` = reparto | `F1 = 1`, `T1` = postazione o etichetta; `NRep 8` e `Oper 10000` come marcatori; `NumTrans` con un'altra formula | `sp_preleva_punti`: `N0` = sala d'origine o consumatrice | **Sì** | 02 § 4b, 05 § 4b |
| `Clienti.N0` | Flag ticketless (con due convenzioni) | 1 o 2 alla creazione da API | `sp_last_trans` (DB clienti di gruppo): codice dell'ultima sala | **Sì**: tre significati in una colonna sincronizzata | 05 § 4b, DB 09 § 4 |
| `Clienti.UserName`, `Password`, `Abilita`, `Foto` | `UserName` non usato; `Abilita` = lock di postazione; `Foto` = JSON di attributi | `UserName` = token dell'app; `Password` = PIN in chiaro; `Abilita` = card bloccata dal giocatore; in `Foto` la chiave `CardCreatedBy` | — | **Sì** su `Abilita` | 02 § 4b, 03 § 4b |
| `Clienti.D0` | — | — | `sp_last_trans`: ultimo uso nel gruppo | Da verificare in sala | DB 09 § 3 |
| `Vincite.N_Tickets`, `Cons`, `N0` | Prezzo per pezzo, una riga per pezzo | Totale della richiesta in una riga; `Cons = 1`; `N0` mai scritto | — | **Sì** | 03 § 4b |
| `LogTransazioniTotem.AC`, `CAut`, `TCC` | `AC` = codice di autorizzazione POS; stati `Pending`, `Completed`, `Recovered` | `AC` = UUID di sequenza anche per il POS; nuovo stato `Error`; `TCC` mai scritto | — | **Sì** | 05 § 4b |
| `LogTransazioniPos.IDTerm`, `AId`, `Appl`, `IC`, `Stan` | Campi EMV | Ricevute e identificativi della transazione al posto dei campi EMV | — | Nomi fuorvianti in entrambi | 03 § 5.9 |
| `Premi` (articoli `SPINDLE…`), `PDis/QDis` | `PDis/QDis` superati | Articoli fittizi per gli slot SPINDLE (`Attivo = 0`, `Prenotabile = 0`); `PDis/QDis` ancora usati dal PrizeHub vecchio | — | Sovraccarico della tabella | 03 § 4b |
| `RedeemCodes.DbName` | Codice della sala | `Nimp` o `"DB" + Nimp`, secondo la funzione | `sp_redeem_*` | **Sì** | 05 § 4b |
| `Setup.AdmPass`, `T6`, `T7`, `MName`, `IDPost` | Configurazione ECL in una stringa posizionale; `T6` = sale del gruppo; `T7` = credenziali cloud; una riga per postazione | Stessa stringa riscritta dal backoffice; riga `PRIZEHUB01\|` con `IDPost = MAX+1`; tre regole diverse per leggere `T6` | `sp_leggiconfig` e `sp_preleva_punti` leggono `T6` | **Sì** su `T6` e sulle righe di postazione | 01 § 4.b, 02 § 4b |
| `setup2` (chiave/valore) | Parametri vari | Archivio di stato operativo: `TestMode_<codmac>`, `ArmageddonEseguito`, `typename_<tipo>`, `PrizeHub0<n>`, `TickPerTok`, `DbClientiMultilocale`, chiavi del totem | — | Uso improprio come archivio di stato | 00 § 5.2 |
| `Operatori.Id`, `Livello`, `CodBar` | `Livello And 3` = ruolo; operatori `TotemPrizes` 1001–1010 | Superadmin = `Id 0`; operatori virtuali `Prizehub` da 1001; `CodBar` = login senza password | — | **Sì** | 01 E01-32, 06 § 4.b |

## 4. Accessi al cloud

| Oggetto | Database | Chi | Operazioni |
|---|---|---|---|
| `CoinlessImpianti`, `vs_definizione_nome_macchina`, `CoinlessDefaultTypeConfig`, `sp_CoinlessMacchine`, `sp_ConfigurazioneMacchina`, `sp_DettaglioIngressiMacchina` | `CoinlessDB` (cloud) | ecl2mqtt, tramite il linked server `elmaccloud` | Lettura, `EXEC` |
| `Type`, `Manuf`, `Machines` | DB di servizio del cliente (cloud) | ecl2mqtt (wizard dei modelli); WinMT (W08-01, con ripiego in sala) | Lettura, `INSERT` |
| `EcsMacchine` delle altre sale | `DBnnnn` (cloud) | ecl2mqtt (installazione) | Lettura |
| `CoinlessImages`, `ecl_firmware`, `bi_firmware`, `CoinlessLanguages` | `CoinlessDB` (cloud) | ecl2mqtt (replica manuale) | Lettura e scrittura |
| `sp_last_trans`, `sp_preleva_punti`, `Tickets` di altre sale | DB clienti di gruppo (`rdclienti`, `CliTest`) e `DBnnnn` | WinMT (`CServer`) ed ecl2mqtt | `EXEC`, lettura |

## 5. Limiti

- Il conteggio non distingue le scritture vive dal codice morto: per i rami disattivati valgono le note e i documenti di zona.
- Una tabella marcata `cita` può essere scritta da WinMT in un punto che non è stato censito come flusso.
- I significati nella colonna WinMT vengono da db-08, costruito sul DB di test: vanno verificati in produzione (CLAUDE.md).
