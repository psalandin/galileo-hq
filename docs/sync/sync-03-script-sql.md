# Galileo HQ — Sync 03: gli script SQL di riferimento distribuiti con WinMtProv

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

**Fonte:** `legacy/WinMtProv/WinMtProv/bin/Release/SQLScripts/` (file fino al 03/06/2026), confrontati con i DB di test e produzione e con `CliTest` sull'istanza di analisi · **Copia versionata:** [`sql/codice-db/winmtprov/`](../../sql/codice-db/winmtprov/) · **Collegati:** [`sync-02-winmtprov.md`](sync-02-winmtprov.md), `docs/db/db-07-confronto-test-produzione.md`, `docs/db/db-09-clitest-clienti-multisala.md`

---

## 1. Cosa sono

Accanto all'eseguibile di WinMtProv c'è una cartella `SQLScripts\` con gli script per creare **tre database**: quello di sala, il vecchio DB coinless e il DB clienti di un gruppo multisala. Sono 176 file e circa 10.300 righe, un oggetto per file, scritti dal team (`sql/codice-db/README.md`).

| Database | Tabelle | Funzioni | Procedure | Viste | Trigger | Migrazioni | Date dei file |
|---|---:|---:|---:|---:|---:|---:|---|
| `WinMtSqlDB` (sala) | 73 | 25 | 23 | 14 | 0 | 6 | fino al 03/06/2026 |
| `CoinlessDB` | 10 | 8 | 4 | 4 | 6 (in un file) | — | 2022–2023 |
| `MultiLocaleDB` (clienti di gruppo) | 1 | 1 | 6 | — | — | — | 17/03/2022 e 10/01/2023 |

Le tre build di WinMtProv in `bin/` hanno ciascuna la propria copia: `Release` (la più recente, analizzata qui), `Debug` (aprile 2026, 72 tabelle) e `x64/Debug` (2023, 51 tabelle). La crescita da 51 a 73 tabelle riflette l'aggiunta di coinless, gru, PrizeHub e redeem nel DB di sala.

**WinMtProv esegue solo i quattro gruppi `Tabelle`, `Funzioni`, `Procedure` e `Viste` di `WinMtSqlDB`** (`EseguiGruppo`, `Form1.vb:667-692`). Le migrazioni, `CoinlessDB` e `MultiLocaleDB` viaggiano con lo strumento ma nessun codice ricevuto le esegue: si presume che vengano lanciate a mano. **V** (uso manuale **D**)

## 2. `WinMtSqlDB`: coincide con la produzione

Confronto automatico, colonna per colonna, fra gli script e il catalogo dei DB (`INFORMATION_SCHEMA`, tipi, lunghezze, nullabilità e chiavi primarie). Per il codice il confronto ignora maiuscole, spazi, commenti e intestazioni di deploy.

| Oggetti | Produzione (Central Park, 14/07/2026) | Test |
|---|---|---|
| Tabelle | **73 su 74 identiche.** In produzione in più c'è solo `SetupNew`. Due scarti minori: `Logs.FileName` esiste solo in produzione; in produzione la colonna `CoinlessDecodedData.Header` ha uno spazio finale nel nome | 81 tabelle: otto in più (`nayax`, `pos_request`, `pos_transaction`, `Setup_Descriptions`, `UltimoInventario`, tre `transcard_consolidamento_*`); senza le chiavi primarie di `AuditLog`, `cache_dati_grafico_giornaliero` ed `ecl_DeviceProvisioning`; `PartiteOspiti` senza `id`; `CoinlessCards` con due colonne in più; `Premi.PDis1..8` di 100 caratteri invece di 255 |
| Funzioni | 25 su 25 identiche | 21 su 25 identiche |
| Procedure | Le 21 della produzione ci sono tutte: 18 identiche, 3 diverse solo per l'intestazione di deploy e per la codifica degli accenti. Negli script in più: `sp_redeem_verify_pin` e `collegamentoserver` (§ 5) | 14 identiche, 9 diverse; quattro procedure del test non sono negli script (`GetSetupAsTable`, `PrizeHub_MoveToSlot`, `sp_consolida_transcard_sessioni_cash`, `sp_generacache_old`) |
| Viste | 14 su 14 identiche (`zvs_contatori_letti.sql` crea `vs_contatori_letti`) | 13 su 14 |
| Trigger | Nessuno negli script di sala; i 5 della produzione mancano | Come produzione |

**Conclusione.** Gli script `Release` descrivono la struttura con cui è stata **ricostruita la produzione il 03/06/2026** (DB 06 § 2, DB 07 § 4.1). La data dell'ultimo script, `PartiteOspiti.sql`, coincide con la ricostruzione. Le chiavi primarie aggiunte "per la sincronizzazione" che DB 07 aveva osservato in produzione (`AuditLog.id`, `PartiteOspiti.id`, `cache_dati_grafico_giornaliero`, `ecl_DeviceProvisioning`) sono già negli script. Il DB di test è una versione precedente, con oggetti sperimentali. **V** sul confronto; il legame con la ricostruzione è **D** (forte).

> **Ipotesi di DB 07 confermata.** Sync Framework richiede una chiave primaria su ogni tabella sincronizzata. Negli script tutte le tabelle sincronizzate hanno una chiave; ne sono prive solo le cinque, non sincronizzate, che ne sono prive anche in produzione (`CoinlessDataBuffer`, `CoinlessDecodedData`, `Logs`, `debug_log`, `save_ciapett`). La chiave è spesso una colonna `Keys` `uniqueidentifier` aggiunta apposta (`Tickets`, `TransCard`, `Vincite`, `MovMag`…): è una chiave tecnica di replica, non un identificativo di dominio.

### 2.1 Cosa non c'è negli script

- **I trigger applicativi** della sala: `decodifica_flusso`, `inseriscesuECS`, `insertrecordWINMT`, `aggiornaCard`, `bannaUtente`, che decodificano la telemetria delle schede e aggiornano saldi e blacklist (db-08, ecl2mqtt 04). Quattro sono in `CoinlessDB/Triggers`, in una versione più vecchia di quella della produzione. `insertrecordWINMT` non c'è. Nessun programma ricevuto crea trigger (ricerca di `CREATE TRIGGER` in WinMT ed `ecl2mqtt`). **V**
- **Le chiavi di `setup2`**, salvo quelle di `Migration/defaultpersetup2.sql` (§ 4), e la configurazione di sala in `Setup`.
- **Gli oggetti di Sync Framework**, creati dal provisioning.

**Conseguenza.** Un DB creato da WinMtProv, nel cloud o sul **server secondario**, non ha i trigger applicativi. Nel cloud è probabilmente voluto: i trigger, scattando sulle righe che arrivano dalla sincronizzazione, rifarebbero la decodifica una seconda volta. Sul secondario invece, dopo un failover (ecl2mqtt 00 § 4.4), la telemetria che arriva in `CoinlessDati` non verrebbe decodificata finché qualcuno non installa i trigger. **D**, da verificare su un secondario reale.

## 3. `MultiLocaleDB`: una versione più vecchia del DB clienti di gruppo

È lo schema del DB clienti centrale di un gruppo (`rdclienti` nelle sale, `CliTest` nel test, DB 09). Contiene la tabella `Clienti`, con le **stesse colonne** del `Clienti` di sala, la funzione `fn_decode_mt_bitmask` e sei procedure. **V**

| Oggetto | Rispetto a `CliTest` |
|---|---|
| `sp_last_trans`, `sp_leggiconfig`, `sp_verifica_syncro`, `fn_decode_mt_bitmask` | Identici |
| `sp_preleva_punti` | Più vecchia: non esclude i lotti con `D0` valorizzato; nel lotto clonato con la parte già pagata scrive `N0 = NULL` invece della sala; registro di debug (`t_log`) e tabella `cacca` commentati |
| `sp_punti_cliente` | Non ha i filtri `Tickets.D0 IS NULL` e `MangiaT <= 16384` |
| `sp_vincite_cliente` | Non separa i punti Silver e Gold (`t_silver`, `t_gold`) |
| `sp_*_gold`, tabelle `cacca` e `t_log` | Assenti |

Gli script sono del 10/01/2023. `CliTest` contiene una versione successiva, con la gestione Gold. Il DB di gruppo si è evoluto **fuori** dagli script di riferimento: una nuova installazione di gruppo partirebbe da una versione superata. **V** sul confronto; l'ordine delle versioni è **D** dalle date e dal contenuto.

## 4. `CoinlessDB` e migrazioni: tracce della fusione dei DB

`CoinlessDB` contiene dieci tabelle delle card e della telemetria ECL (`CoinlessCards`, `CoinlessDati`, `CoinlessDecodedData`, `CoinlessTransazioniCards`, `ecl_firmware`…), le procedure di decodifica e sei trigger. Rispetto alle stesse tabelle nel DB di sala di produzione sono più vecchie: mancano `FlagOpDaVerificare`, `Bonus`, `FirmwareBinaryData`, `MsgCount` e `Status`. Sono il DB coinless separato precedente alla fusione nel DB di sala. Il nome coincide con il `CoinlessDB` del cloud che il motore raggiunge con il linked server `elmaccloud` (ecl2mqtt 04). **V** sul confronto; il legame con il DB del cloud è **D**.

Le sei migrazioni di `WinMtSqlDB/Migration` confermano il passaggio:

| Script | Cosa fa |
|---|---|
| `importacoinlessfirmware`, `importacoinlessimages`, `importacoinlesslanguages` | Copiano firmware, immagini e testi delle schede da `[elmaccloud].[CoinlessDB]` nel DB di sala, saltando quelli già presenti |
| `migrate_prizehubslots` (25/05/2026) | Porta le giacenze dei PrizeHub in `PrizeHubSlots` e crea gli articoli fittizi `SPINDLE…` con `Attivo = 0` (ecl2mqtt 08 § 3) |
| `defaultpersetup2` | Valori iniziali di `setup2` se la tabella è vuota: dispositivi POS ammessi, configurazione TCP del POS, compleanni, abbonamento VIP, ritiro card |
| `OttimizzazioneIndici` | 54 indici, metà su `TransCard`, poi `Clienti`, `Tickets`, `EcsDati`, `CoinlessDecodedData`, `Vincite`, `Premi`, `Resi` |

## 5. Segreti

| File | Segreto | Nella copia versionata |
|---|---|---|
| `WinMtSqlDB/Procedure/collegamentoserver.sql` | Password `sa` del linked server `elmaccloud` verso `winmt.elmaccloud.com` | Sostituita da un segnaposto |
| `WinMtSqlDB/Funzioni/fn_calcHMAC.sql`, `CoinlessDB/Funzioni/fn_calcHMAC.sql` | Chiave HMAC dei comandi alle schede, la stessa già rimossa da `sql/codice-db/prod` | Sostituita da un segnaposto |

`collegamentoserver` non è una procedura, anche se sta nella cartella `Procedure`. È uno script che crea, **a livello di server**, il linked server `elmaccloud` verso `winmt.elmaccloud.com` con RPC abilitato. La mappatura del login non indica un login locale (`sp_addlinkedsrvlogin` senza `@locallogin`), quindi vale per **tutti** i login del server: chiunque si colleghi a quel SQL Server, compreso l'utente `WinMt` delle postazioni, opera sul cloud Elmac come `sa`. **V**

WinMtProv esegue tutti i file della cartella `Procedure`, quindi lancia lo script a ogni creazione di un DB, nel cloud o sul secondario (§ 1). Se il linked server esiste già, l'errore compare in un `MsgBox` e la creazione prosegue. La copia di produzione non dice se il linked server c'è, perché `sys.servers` non viaggia con il database. Il motore lo usa (ecl2mqtt 04), quindi esiste almeno sui server di sala dove il motore gira. **V** sul codice

La copia in `sql/codice-db/winmtprov/` ha fine riga LF, senza BOM, e un solo file rinominato (`uid_reservations .sql`, con uno spazio, è diventato `uid_reservations.sql`).

## 6. Cosa serve al progetto

1. **Esiste uno schema "com'è" scritto dal team e allineato alla produzione.** Per la migrazione verso il nuovo modello si può partire da qui invece che dal catalogo estratto di ogni sala, verificando su ogni sala solo le differenze. Lo schema resta una fonte di struttura, non di verità sui significati (CLAUDE.md).
2. **La versione del DB non è tracciata.** Gli script sono cartelle di file senza numero di versione. In WinMT `Setup(101).N1` è "versione del DB" (db-08), ma nessuno script la aggiorna. Le sale possono trovarsi su versioni diverse (test e produzione lo sono) senza che il sistema lo sappia. Nel nuovo sistema servono migrazioni versionate.
3. **Lo schema ha più proprietari.** All'avvio WinMT e il motore modificano tabelle e procedure (WinMT 00 § 6.5, ecl2mqtt 00 § 3.3). WinMtProv crea i DB da questi script, i trigger si installano a parte e il DB di gruppo evolve per conto suo. Sono quattro fonti di verità sulla struttura.
4. **Le chiavi `Keys` `uniqueidentifier` sono un artefatto della replica.** Nel nuovo modello gli identificativi dei movimenti vanno decisi per il dominio e per la sincronizzazione via MQTT, non ereditati.
