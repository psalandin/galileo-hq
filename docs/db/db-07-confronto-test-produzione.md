# Galileo HQ — DB 07: confronto della struttura tra database di test e di produzione

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-23

**Fonte:** `[WinMtSqlDB]` (test) e `[WinMtSqlDBProd]` (produzione, Central Park Rimini, copia del 14/07/2026), entrambi sull'istanza di analisi `ThinkCentre-2\SQLEXPRESS` · **Collegati:** `db-query-04-struttura.sql`, `sql/risultati/db-query-04-confronto-test-prod.txt`, `db-01-schema.md`, `db-06-produzione-02.md`

Il confronto riguarda la **struttura**: tabelle, colonne, indici, vincoli, trigger, codice di procedure, funzioni e viste, configurazione di Sync Framework, utenti. I dati sono stati letti solo per verificare quattro ipotesi nate dal confronto (§ 6.2, § 4.3, § 8).

**Metodo.** Il kit `db-query-04-struttura.sql` estrae da ciascun database un catalogo completo; uno script lo confronta voce per voce.
- I vincoli con nome generato dal sistema (`PK__Tickets__60C2…`) sono confrontati per definizione, non per nome, perché il suffisso cambia a ogni creazione.
- Il codice dei moduli è confrontato prima con un hash che ignora spazi e a capo, poi, dove l'hash differisce, ignorando anche commenti e maiuscole. Così si separano le differenze di formattazione da quelle di logica.
- Il codice estratto è in `sql/codice-db/`, con il codice applicativo separato da quello generato da Sync Framework. Si può confrontare direttamente con `git diff --no-index sql/codice-db/test/applicativo sql/codice-db/prod/applicativo`.

---

## 1. Sintesi

1. **Lo schema di base è lo stesso.** Delle 73 tabelle applicative comuni, solo 5 hanno colonne diverse. Le 14 viste coincidono, chiavi esterne e vincoli CHECK sono equivalenti. Le differenze di logica si concentrano in 9 moduli (§ 6).
2. **Nessuno dei due database contiene l'altro.** Il test ha codice e colonne più recenti (antifrode card, adattamenti per il motore B4J). La produzione ha 21 tabelle sincronizzate in più, quattro chiavi primarie che il test non ha e due decodifiche che il test non ha più. **Sono due rami divergenti** dello stesso schema.
3. **La produzione è stata ricostruita in blocco il 03/06/2026.** Tutti i 1.382 oggetti hanno quella data di creazione e nessuno è stato modificato dopo. Il codice è stato applicato con una codifica sbagliata: le lettere accentate sono corrotte (§ 6.3).
4. **Il codice dipende dal nome del database.** Quattro moduli in test e cinque in produzione usano nomi fissi `WinMtSqlDB.dbo.…` (§ 7).
5. **Le modifiche di schema non vengono propagate a Sync Framework.** Nel test le procedure di sincronizzazione di `Premi` troncherebbero a 10 caratteri colonne che ne ammettono 100 (§ 4.2).

> **Conseguenza principale.** Non esiste oggi uno "schema di riferimento" da cui partire per la migrazione: c'è uno schema per installazione, allineato a mano. Prima di usare uno dei due come base per la mappatura dei dati, il team deve dire quale ramo è quello rilasciato e come gli aggiornamenti arrivano nelle sale.

---

## 2. Profilo dei due database

| | Test | Produzione |
|---|---|---|
| Nome sull'istanza di analisi | `WinMtSqlDB` | `WinMtSqlDBProd` |
| Nome logico del file dati | `WinMtSqlDBNuo` | `WinMtSqlDBNuovo` |
| File dati (allocati / usati) | 839 / 610 MB | 6.984 / 6.781 MB |
| Creazione degli oggetti | dal 12/12/2024, in date diverse | **tutti il 03/06/2026**, tra le 10:30 e le 11:19 |
| Ultima modifica di un oggetto applicativo | 12/10/2026 (`fn_decode_mt_bitmask`) | 03/06/2026 |
| Utenti del database | `WinMt` (db_owner), `claude` (lettura e scrittura) | `WinMt` (db_owner) |

Le impostazioni coincidono: livello di compatibilità 160 (SQL Server 2022), collation `Latin1_General_CI_AS`, recovery `SIMPLE`, `AUTO_CLOSE ON`, snapshot isolation attivo, `ANSI_NULLS` e `QUOTED_IDENTIFIER` disattivati a livello di database.

---

## 3. Oggetti a confronto

| Tipo | Test | Produzione | di cui Sync Framework (test / prod) |
|------|-----:|-----------:|------------------------------------:|
| Tabelle | 124 | 138 | 43 / 64 |
| Procedure | 466 | 692 | 440 / 671 |
| Trigger | 125 | 188 | 120 / 183 |
| Funzioni (scalari, inline, tabellari) | 25 | 25 | — |
| Viste | 14 | 14 | — |
| Tipi tabella | 40 | 61 | 40 / 61 |
| Chiavi esterne | 3 | 3 | — |
| Vincoli CHECK | 5 | 5 | — |

Le differenze nei numeri vengono quasi tutte dal perimetro di sincronizzazione (§ 4). Al netto di Sync Framework: 81 tabelle applicative nel test, 74 in produzione; 26 procedure applicative nel test, 21 in produzione.

---

## 4. Sincronizzazione

### 4.1 Perimetro

I due scope `LocalSync` e `WinMtSync` hanno in entrambi i database lo stesso contenuto e nessun filtro. In produzione comprendono **21 tabelle in più** (61 contro 40):

AuditLog, BEConfig, CoinlessImages, CoinlessLogEventiBlacklist, Coinless_sbuilder_page_provisioning, coinless_sbuilder_pages, coinless_sbuilder_templates_svg, Compleanni, cache_dati_grafico_giornaliero, ecl_DeviceProvisioning, GruMagazzino, GruMagazzinoDettaglio, GruMovimenti, LogTransazioniPos, Ospiti, PartiteOspiti, promozioni, promozioni_cards, RedeemCodes, Setup2, TipoRicaricheCompleanni.

Quattro di queste tabelle in produzione hanno una **chiave primaria che nel test non hanno**:

| Tabella | Chiave primaria in produzione |
|---------|-------------------------------|
| `AuditLog` | `id` |
| `PartiteOspiti` | `id`, colonna `bigint` aggiunta apposta |
| `cache_dati_grafico_giornaliero` | `CodMac, DataRil` (le due colonne diventano NOT NULL) |
| `ecl_DeviceProvisioning` | `macaddress` |

> **Ipotesi.** Sync Framework richiede una chiave primaria su ogni tabella sincronizzata. Le chiavi sono state aggiunte per poter includere queste tabelle nella sincronizzazione, durante la ricostruzione del 03/06/2026. In produzione restano senza chiave primaria solo cinque tabelle, nessuna sincronizzata: `CoinlessDataBuffer`, `CoinlessDecodedData`, `Logs`, `debug_log` e `save_ciapett`.

### 4.2 Procedure di sincronizzazione non riallineate

Sync Framework genera, per ogni tabella, procedure con un parametro per colonna. Se la colonna cambia dopo il provisioning, la procedura resta com'era.

- **`Premi.PDis1…8`** sono `varchar(100)` nel test e `varchar(255)` in produzione. Le procedure di sincronizzazione del test (`Premi_insert`, `Premi_update`) le dichiarano ancora `varchar(10)`: una modifica ricevuta dall'altro peer verrebbe **troncata a 10 caratteri senza errore**. In produzione procedure e colonne sono allineate a 255.
  Oggi l'effetto è nullo: `PDis1…8` sono vuote in entrambi i database.
- **`UID_Ammessi`**: nel test lo scope sincronizza 2 colonne (`UID`, `CodBar`), in produzione 4 (anche `DataCreazione` e `DataEmissione`). Nel test 115 card hanno una data di creazione che non viene propagata.

> **Indicazione.** È un difetto strutturale del modello attuale: lo schema si modifica a mano e il framework di sincronizzazione non se ne accorge. Nel nuovo sistema schema e contratto dei messaggi devono avere una versione, e le migrazioni devono essere script versionati applicati in modo uniforme a sala e cloud.

### 4.3 Altre differenze di vincoli e indici legate ai dati

- **`CoinlessDati`, indice univoco `idx1`.** Nel test la chiave è `cmd, cnt, hmac`, in produzione `device, cmd, cnt, hmac`. Nel test, due dispositivi che inviano lo stesso comando con lo stesso contatore e lo stesso HMAC andrebbero in conflitto. Sui dati attuali non succede in nessuno dei due database.
- **`GruMovimenti`, vincolo CHECK sul tipo di movimento.** Stessi cinque valori (`LOAD`, `UNLOAD`, `WIN`, `ADJUST+`, `ADJUST-`) in ordine diverso: è equivalente.

---

## 5. Oggetti presenti in un solo database

### Solo nel test

| Oggetto | Tipo | Note |
|---------|------|------|
| `Nayax`, `pos_request`, `pos_transaction` | Tabelle | Pagamenti POS, non attivi in Central Park (DB 05, § 4) |
| `TransCard_Consolidamento_Backup`, `_Log`, `_Map` | Tabelle | Create il 01/04/2026, con `sp_consolida_transcard_sessioni_cash` |
| `Setup_Descriptions` | Tabella | **Dizionario dei campi di `Setup`**, 177 voci (vedi sotto) |
| `UltimoInventario` | Tabella | Vuota |
| `sp_consolida_transcard_sessioni_cash` | Procedura | Consolidamento delle sessioni di cassa su `TransCard` |
| `GetSetupAsTable` | Procedura | Lettura di `Setup` con le descrizioni |
| `PrizeHub_MoveToSlot` | Procedura | PrizeHub |
| `sp_redeem_verify_pin` | Procedura | Creata nel test il 23/02/2026, **assente** nella produzione ricostruita il 03/06 |
| `sp_generacache_old` | Procedura | Residuo |
| `CoinlessCards.TentativiNonConfermati`, `UltimoN0NonConfermato` | Colonne | Antifrode del 07/10/2026 (§ 6.1) |

**`Setup_Descriptions`** associa a ogni colonna di `Setup` un gruppo e una descrizione, per tipo di postazione (`101` per la configurazione generale, `>110` per le raccolte card). Copre anche i campi jolly di `Setup`: per esempio, per le raccolte card `T0` è il nome della raccolta, `T1` i valori delle serie, `T6` i nomi delle serie. È il primo dizionario dei dati trovato nel sistema. L'elenco completo è in `sql/risultati/Setup_Descriptions-test.tsv`.

### Solo in produzione

| Oggetto | Tipo | Note |
|---------|------|------|
| `SetupNew` | Tabella | Vuota, 8 colonne, creata il 03/06/2026 |
| Strutture di sincronizzazione per le 21 tabelle del § 4.1 | Tabelle `_tracking`, procedure, trigger, tipi | |

Il caso di `sp_redeem_verify_pin` mostra che la produzione **non è stata costruita a partire dal test**: una procedura presente nel test da febbraio non è entrata nella ricostruzione di giugno.

---

## 6. Codice divergente

Dei 65 moduli applicativi comuni ai due database (procedure, funzioni, viste, trigger), 41 sono identici e 24 hanno un hash diverso. Di questi 24:
- **15 differiscono solo nella forma**: spazi, commenti, maiuscole, `FOR` invece di `AFTER` nei trigger, il testo di un messaggio d'errore;
- **9 hanno una logica diversa**, elencati qui sotto.

| Modulo | Più recente in | Differenza |
|--------|----------------|------------|
| `decodifica_record` | Test (07/10/2026) | Antifrode "RFID non scrivibile" (§ 6.1). In produzione usa nomi fissi `WinMtSqlDB.dbo.…` (§ 7) |
| `bannaUtente` (trigger) | ? | Nel test mette in blacklist anche la card coinless; in produzione marca solo il cliente (§ 6.2) |
| `inseriscesuECS` (trigger) | ? | Nel test il contatore 15 di partenza vale 0 se la macchina non ha ancora rilevazioni; in produzione resta NULL |
| `fn_dati_grafico_giornaliero` | ? | Nel test monete, gettoni e premi sono **valori** (`quantità × valore unitario`); in produzione sono **quantità** |
| `fn_decode_mt_bitmask` | ? | La produzione decodifica anche i bit 13 ("Punti da App") e 14 ("Silver in Gold"); il test, modificato il 12/10/2026, no |
| `sp_redeem_check_and_reserve_no_pin`, `sp_redeem_confirm`, `sp_redeem_cancel` | Test (10/09/2026) | Firme diverse (§ 6.4) |
| `fn_dettaglio_incassi` | ? | Nel test i parametri hanno default `NULL`, in produzione no |

Il punto interrogativo indica che le date non bastano a stabilirlo: in produzione tutti gli oggetti hanno la data della ricostruzione.

### 6.1 Antifrode "RFID non scrivibile" (solo test)

Nel test, `decodifica_record` contiene un blocco commentato come "emergenza 2026-10-07".
- **Il problema:** una card manomessa in modo che la scheda non riesca a scrivere l'esito ripresenta all'infinito la stessa giocata come "non confermata". La procedura la accettava ogni volta come un nuovo tentativo legittimo e rilanciava `scriviTicketsAutomatici`.
- **La correzione:** si contano le ripresentazioni consecutive dello stesso progressivo (`CoinlessCards.TentativiNonConfermati`, `UltimoN0NonConfermato`). Oltre una soglia la card va in blacklist e l'evento finisce in `CoinlessLogEventiBlacklist`. La soglia si configura in `setup2` (`IdPost = 101`, chiave `MaxTentativiNonConfermati`) e vale 3 se la chiave manca.
- **Due conferme utili all'analisi:**
  - `TransCard.N0` e `CoinlessTransazioniCards.N0` sono il **progressivo di transazione della card**, come ipotizzato in DB 03, § 7;
  - il commento cita `DBwinmt.getBlackList` e il "push MQTT alle BE": la blacklist viene inviata alle schede a ogni transazione.

> **Domanda per il team.** La correzione è già in produzione nelle sale? Nella copia di Central Park del 14/07 non c'è, ma è successiva.

### 6.2 `bannaUtente` e l'identificativo della card

In entrambi i database il trigger collega la card clonata al cliente con `Clienti.T0 = CoinlessCards.cardid + '00000000'`.

> **Conferma di DB 06, § 3.** È la stessa regola ricavata dai dati con Q18 e Q21 (UID a 8 caratteri più 8 caratteri di riempimento), e ora si sa che **il sistema stesso la usa**. Applicata alla lettera sui dati di produzione:
> - 23.664 card coinless su 23.716 trovano un cliente in `Clienti.T0`;
> - 23.710 trovano la card fisica in `UID_Ammessi.UID`.
>
> **C'è però una conseguenza nuova.** Nei circa 1.800 casi in cui `T0` non coincide con la card coinless del cliente (DB 06, § 3), il trigger marca come "clonato" il cliente trovato tramite `T0`, non quello di `CoinlessCards.IdContatto`. Se `T0` conserva una card sostituita, la segnalazione può finire sul cliente sbagliato o andare persa.

Il trigger decodifica anche tre campi jolly di `Clienti`, valorizzati quando viene rilevata una clonazione:
- `F1 = 1`;
- `T1` = macchina, costo partita, saldo e identificativo della clonazione;
- `D1` = data della rilevazione.

`F1` però non ha solo questo significato. In produzione vale 1 per 1.227 clienti, ma solo 56 hanno in `T1` il testo della clonazione.

### 6.3 Codifica dei caratteri in produzione

In produzione le lettere accentate nel codice sono corrotte: `già` diventa `giÃ `, `è` diventa `Ã¨`. È la firma di uno script salvato in UTF-8 e applicato come se fosse in un'altra codifica durante la ricostruzione del 03/06/2026. Quasi sempre riguarda commenti. In `sp_generacache` riguarda invece un **messaggio d'errore** che l'utente vede.

### 6.4 Due versioni incompatibili della stessa API

Le procedure `sp_redeem_*` esistono in due versioni:

| Versione | Dove | Come restituisce l'esito |
|----------|------|--------------------------|
| Originale | Produzione | Parametro `OUTPUT @ErrKey`, usato da VB6/ADODB |
| "Adattata per B4X/JDBC" | Test | Una riga di risultato, perché il motore B4J (`ecl2mqtt`, già `ecs2mqtt`, modulo `DBwinmt`) non gestisce i parametri OUTPUT |

Cambiano anche alcuni dettagli: il default di `@IdContatto`, `UsedBy = 0` trattato come NULL, i campi restituiti. Un client scritto per una versione non funziona con l'altra.

> **Indicazione.** È un esempio concreto del motivo per cui la logica deve stare **una sola volta, lato server, dietro un'API**: oggi la stessa operazione ha due contratti diversi a seconda del client che la chiama.

---

## 7. Riferimenti fissi al nome del database

Questi moduli usano nomi a tre parti con il database `WinMtSqlDB` scritto nel codice:

| Modulo | Test | Produzione |
|--------|:----:|:----------:|
| `fn_DecodeCardTrans` | ✓ | ✓ |
| `sp_eliminacliente` | ✓ | ✓ |
| `sp_rimuovidabl` | ✓ | ✓ |
| `sp_ripristinacard` | ✓ | ✓ |
| `decodifica_record` | — | ✓ (`Clienti`, `TransCard`, `EcsMacchine`, compresi `UPDATE` e `DELETE`) |

Conseguenze:
- **Il database di sala deve chiamarsi `WinMtSqlDB`.** Altrimenti questi moduli leggono e scrivono un altro database, o falliscono. In produzione il database si chiama quindi verosimilmente `WinMtSqlDB`, anche se il nome logico dei file è `WinMtSqlDBNuovo` (ipotesi).
- **Due database di sala non possono stare sulla stessa istanza.** Il parametro `@DbName` delle procedure `sp_redeem_*` lascia intendere il contrario: il codice più recente è pensato per più database, quello più vecchio no.
- **Sull'istanza di analisi, la copia di produzione punta al database di test.** Un `INSERT` in `CoinlessDati` sulla copia di produzione farebbe partire i trigger, e `decodifica_record` scriverebbe nel database di test. **Sulle copie si eseguono solo letture.**

### 7.1 Chiave di autenticazione dei messaggi nel codice

`fn_calcHMAC`, usata dal trigger `decodifica_flusso` per verificare i messaggi delle schede in `CoinlessDati`, calcola `SHA2_256(device + cmd + cnt + chiave)`. La chiave è una costante scritta nel codice, ed è **la stessa nel test e in produzione**.
- Chi legge il database, o un qualunque backup, può firmare messaggi validi per le schede di tutte le sale che condividono la chiave.
- Concatenare una chiave al messaggio e farne l'hash non equivale a un HMAC vero e proprio.

Nella copia versionata in `sql/codice-db/` la chiave è sostituita da un segnaposto.

> **Indicazione.** Nel nuovo sistema le chiavi devono essere per dispositivo, o almeno per sala, conservate fuori dal database applicativo e ruotabili. L'autenticazione va fatta con HMAC standard o con TLS e certificati client sul broker MQTT. Il tema tocca il protocollo della BE, che è fuori perimetro, ma la verifica lato server è nel perimetro.

---

## 8. Indici

| Tabella | Test | Produzione | Differenza |
|---------|-----:|-----------:|------------|
| `TransCard` | 25 | 29 | Vedi sotto |
| `EcsDati` | 6 | 5 | Il test ha in più `IX_EcsDati_DataRil` |
| `cache_dati_grafico_giornaliero` | 2 | 1 | Il test ha due indici non clustered; la produzione ha la chiave primaria clustered (§ 4.1) |
| `AuditLog`, `PartiteOspiti`, `ecl_DeviceProvisioning` | 0 | 1 | Chiavi primarie (§ 4.1) |

**`TransCard`.**
- La produzione ha **sei indici con la stessa chiave** (`NImp, WinMt, Data, ValoreOperazione`), che differiscono solo per le colonne incluse. Occupano **417 MB**. Uno solo, con tutte le colonne incluse (`IdCli, Operatore, ValoreCassa`), coprirebbe le stesse query.
- Il test non ha nessuno di questi sei, ma ha `IX_TransCard_IdCli_Data_N0` e `IX_TransCard_NImp_Data`.
- `EcsDati`, `Tickets` e `TransCard` del test risultano modificate il **16/07/2026**, due giorni dopo la copia di produzione.

> **Ipotesi.** Il 16/07 qualcuno ha rivisto gli indici nel test e ha sostituito i sei indici ridondanti con due più snelli. Va chiesto al team se la revisione è stata portata anche nelle sale.

---

## 9. Conseguenze per l'analisi

1. **Schema di riferimento.** Va stabilito quale ramo rappresenta il prodotto e se altre sale hanno varianti ulteriori, considerando anche i circa 200 fork citati il 19/10. Per la mappatura della migrazione serve il catalogo (`db-query-04`) di più sale, non di una sola.
2. **Migrazioni versionate.** Lo schema oggi evolve per interventi manuali, con differenze di codifica e procedure di sincronizzazione non riallineate. Nel nuovo sistema ogni modifica di schema dev'essere uno script versionato, applicato in modo identico in sala e nel cloud.
3. **Nessun nome di database nel codice**, e un'unica API per operazione indipendentemente dal client (§ 6.4, § 7).
4. **Semantica dei report.** `fn_dati_grafico_giornaliero` restituisce valori nel test e quantità in produzione. Prima di riprodurre un report, va fissata la definizione di ogni misura.
5. **Decodifiche acquisite:**
   - `CoinlessCards.cardid` è l'UID della card senza gli 8 zeri finali, regola usata anche dal codice (`bannaUtente`);
   - `TransCard.N0` è il progressivo di transazione della card;
   - `Clienti.F1/T1/D1` registrano, tra l'altro, la rilevazione di card clonate;
   - `Setup_Descriptions` documenta i campi di `Setup`.

---

## 10. Domande per il team

1. Quale dei due rami è quello rilasciato alle sale? Come vengono distribuiti gli aggiornamenti di schema e di codice?
2. La produzione di Central Park è stata ricostruita da script il 03/06/2026: da quali script, e perché `sp_redeem_verify_pin` non c'è?
3. Le correzioni del test (antifrode RFID, versioni B4X di `sp_redeem_*`, indici di `TransCard`) sono già nelle sale?
4. In produzione il database si chiama `WinMtSqlDB`? Esistono installazioni con più database sulla stessa istanza?
5. `fn_dati_grafico_giornaliero`: il grafico deve mostrare valori o quantità?
6. Perché il test non decodifica più i bit 13 e 14 di `fn_decode_mt_bitmask`?
7. Quando un cliente cambia card, `Clienti.T0` viene aggiornato? Se no, `bannaUtente` può segnalare la clonazione sul cliente sbagliato (§ 6.2).
8. La chiave di `fn_calcHMAC` è la stessa in tutte le sale? È condivisa con il firmware delle schede?
