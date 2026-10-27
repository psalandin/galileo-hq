# Galileo HQ — Indice dei documenti di lavoro

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

**Fase:** 0 (pre-analisi), in chiusura

## Analisi

| File | Contenuto | Stato |
|------|-----------|-------|
| [`analisi/analisi-00-prima-lettura.md`](analisi/analisi-00-prima-lettura.md) | Prima lettura di manuale e riunioni del 07/10 e 12/10: zone, architettura attuale, glossario, problemi, domande | Da aggiornare con la riunione del 19/10 |
| [`analisi/analisi-01-catalogo-flussi-winmt.md`](analisi/analisi-01-catalogo-flussi-winmt.md) | **Censimento dei flussi** di WinMT: 191 flussi attivi pesati S/M/L, ricondotti alle zone concettuali | In corso |

## Database

| File | Contenuto | Stato |
|------|-----------|-------|
| [`db/db-01-schema.md`](db/db-01-schema.md) | Analisi dello schema del DB di sala | Basato su DB di **test** |
| [`db/db-02-catalogo.md`](db/db-02-catalogo.md) | Catalogo di tabelle e colonne | Basato su DB di **test** |
| [`db/db-03-risultati-01.md`](db/db-03-risultati-01.md) | Risultati delle query Q01–Q10 | Basato su DB di **test** |
| [`db/db-04-risultati-02.md`](db/db-04-risultati-02.md) | Risultati delle query Q11–Q20 | Basato su DB di **test** |
| [`db/db-05-produzione-01.md`](db/db-05-produzione-01.md) | DB di **produzione** (copia del 14/07/2026): Q01–Q10, volumi e crescita | In corso |
| [`db/db-06-produzione-02.md`](db/db-06-produzione-02.md) | DB di **produzione**: Q11–Q17, postazioni della sala (Central Park, Rimini), identificativi card, livelli; correzioni a DB 04 | In corso |
| [`db/db-07-confronto-test-produzione.md`](db/db-07-confronto-test-produzione.md) | Confronto della **struttura** tra test e produzione: perimetro di sync, codice divergente, nomi di DB fissi nel codice, indici, dizionario `Setup_Descriptions` | In corso |
| [`db/db-08-dizionario-dati.md`](db/db-08-dizionario-dati.md) | **Significato delle colonne** ricavato dal codice di WinMT (circa 580 colonne); risposte alle domande aperte di DB 01–07 | In corso |
| [`db/db-09-clitest-clienti-multisala.md`](db/db-09-clitest-clienti-multisala.md) | `CliTest`, **DB clienti centrale di un gruppo multisala** (test, dal cloud): procedure `sp_last_trans` e `sp_preleva_punti`, come funziona oggi la multisala, doppio significato di `Clienti.N0` | Ricostruito sull'istanza di analisi |

## Codice di WinMT

Analisi del sorgente VB6 (copia del 24/07/2026, in `legacy/`, escluso dal repository), divisa in dieci zone. Ogni documento contiene flussi, significato delle colonne, regole e domande aperte.

| File | Zona |
|------|------|
| [`winmt/winmt-00-mappa.md`](winmt/winmt-00-mappa.md) | Mappa del progetto, tecnologie, accesso ai dati, **sintesi trasversale** |
| [`winmt/winmt-01-cassa-form1.md`](winmt/winmt-01-cassa-form1.md) | La form principale (cassa e banco) |
| [`winmt/winmt-02-moduli-comuni.md`](winmt/winmt-02-moduli-comuni.md) | Moduli comuni e accesso ai dati |
| [`winmt/winmt-03-clienti-card.md`](winmt/winmt-03-clienti-card.md) | Clienti, card, livelli, compleanni e promozioni |
| [`winmt/winmt-04-ecl-pagamenti.md`](winmt/winmt-04-ecl-pagamenti.md) | Card elettroniche (ECL), cassa ECL e pagamenti |
| [`winmt/winmt-05-ticket-scontrini.md`](winmt/winmt-05-ticket-scontrini.md) | Ticket, card tradizionali, scontrini, resi e archivi |
| [`winmt/winmt-06-premi-magazzino.md`](winmt/winmt-06-premi-magazzino.md) | Premi, magazzino, ordini e prenotazioni |
| [`winmt/winmt-07-inventario-prizehub-gru.md`](winmt/winmt-07-inventario-prizehub-gru.md) | Inventario, PrizeHub e gru |
| [`winmt/winmt-08-macchine-contatori-incassi.md`](winmt/winmt-08-macchine-contatori-incassi.md) | Macchine, contatori e incassi |
| [`winmt/winmt-09-report.md`](winmt/winmt-09-report.md) | Rapporti e statistiche |
| [`winmt/winmt-10-setup-operatori-periferiche.md`](winmt/winmt-10-setup-operatori-periferiche.md) | Configurazione, operatori, licenza e periferiche |

## Codice del motore di sala B4J (`ecl2mqtt`, già `ecs2mqtt`)

Analisi del sorgente B4J del motore di sala (versione 2.39.55, in `legacy/ecl2mqtt/`, escluso dal repository), divisa in sei zone, più una sulla documentazione esistente e una matrice trasversale di accesso ai dati. Ogni documento di zona contiene flussi pesati, interlocutori, significato delle colonne, doppioni con WinMT, rischi e domande aperte.

| File | Zona |
|------|------|
| [`ecl2mqtt/ecl2mqtt-00-mappa.md`](ecl2mqtt/ecl2mqtt-00-mappa.md) | Mappa del progetto e **sintesi trasversale**: separazione da WinMT e doppioni, ecosistema, ciclo di vita e guasti, contributo al modello dati |
| [`ecl2mqtt/ecl2mqtt-01-nucleo-mqtt.md`](ecl2mqtt/ecl2mqtt-01-nucleo-mqtt.md) | Nucleo, MQTT e protocollo ECL: catalogo dei topic, autodiscover UDP, ridondanza, `dbsettings.txt` |
| [`ecl2mqtt/ecl2mqtt-02-db-winmt-1.md`](ecl2mqtt/ecl2mqtt-02-db-winmt-1.md) | Accesso al DB di WinMT, parte 1: macchine, happy hour, saldi, ticket, cassa mobile |
| [`ecl2mqtt/ecl2mqtt-03-db-winmt-2.md`](ecl2mqtt/ecl2mqtt-03-db-winmt-2.md) | Accesso al DB di WinMT, parte 2: clienti da app, premi e PrizeHub, redeem, multisala, log del totem |
| [`ecl2mqtt/ecl2mqtt-04-coinless-gru-config.md`](ecl2mqtt/ecl2mqtt-04-coinless-gru-config.md) | DB coinless ed ECL, gru e configurazione: tabelle che WinMT non usa, struttura del record ECL, linked server cloud |
| [`ecl2mqtt/ecl2mqtt-05-api-rest.md`](ecl2mqtt/ecl2mqtt-05-api-rest.md) | API REST per totem, PrizeHub, app, partner, gru e Baytech; autenticazione |
| [`ecl2mqtt/ecl2mqtt-06-backoffice-provisioning.md`](ecl2mqtt/ecl2mqtt-06-backoffice-provisioning.md) | Backoffice web, ciclo di vita delle schede, firmware, schermate |
| [`ecl2mqtt/ecl2mqtt-07-documentazione-esistente.md`](ecl2mqtt/ecl2mqtt-07-documentazione-esistente.md) | La documentazione di Fabrizio in `fonti/ecl2mqtt/`: inventario, decisioni in corso, glossario, affidabilità |
$1
## Sincronizzazione sala–cloud (`ExecuteSync`, `WinMtProv`)

Analisi dei programmi .NET che preparano ed eseguono la sincronizzazione Sync Framework fra la sala, il suo server secondario e il cloud (sorgenti ricevuti il 27/10, in `legacy/`, esclusi dal repository), e degli script SQL di riferimento distribuiti con WinMtProv.

| File | Contenuto |
|------|-----------|
| [`sync/sync-00-mappa.md`](sync/sync-00-mappa.md) | Mappa e **sintesi**: topologia degli scope `WinMtSync` e `LocalSync`, dove sta lo stato della sincronizzazione, rapporto con WinMT ed `ecl2mqtt`, catalogo dei flussi (11 attivi, 28 punti), rischi e domande |
| [`sync/sync-01-executesync.md`](sync/sync-01-executesync.md) | `ExecuteSync` ed `ExecuteSyncSSH`: la sessione di sincronizzazione sala–cloud, varianti e build |
| [`sync/sync-02-winmtprov.md`](sync/sync-02-winmtprov.md) | `WinMtProv`: provisioning, creazione dei DB cloud e secondario, perimetro delle 62 tabelle, conversione multisala degli identificativi |
| [`sync/sync-03-script-sql.md`](sync/sync-03-script-sql.md) | Gli **script SQL di riferimento** dei DB di sala, coinless e di gruppo: coincidono con la struttura della produzione; cosa manca (trigger) e cosa è superato (DB di gruppo) |

## Riunioni

| Data | File | Note |
|------|------|------|
| 07/10 | [`trascrizione`](riunioni/2026-10-07_riunione_trascrizione.txt), [`sommario`](riunioni/2026-10-07_riunione_sommario.md) | Riunione esplorativa; sommario Plaud |
| 12/10 | [`trascrizione`](riunioni/2026-10-12_riunione_trascrizione.txt) | Riunione operativa |
| 19/10 | [`traccia`](riunioni/2026-10-19_riunione_traccia.md), [`trascrizione`](riunioni/2026-10-19_riunione_trascrizione.txt), [`riassunto`](riunioni/2026-10-19_riunione_riassunto.md), [`riassunto originale`](riunioni/2026-10-19_riunione_riassunto.txt) | Traccia preparata per la riunione (copia del Claude Doc); riassunto Plaud, rivisto (`.md`) e così come esportato, senza nomi (`.txt`). Trascrizione Whisper C++ attesa |

## Fonti

| File | Contenuto | Stato |
|------|-----------|-------|
| [`fonti/winmt-manuale.md`](fonti/winmt-manuale.md) | Testo integrale del manuale WinMtSql | Stabile |
| [`fonti/ecl2mqtt/`](fonti/ecl2mqtt/) | Documentazione del motore B4J scritta da Fabrizio: API, flussi delle schede, PrizeHub, gru, manuale del backoffice (valutata in ecl2mqtt 07) | Ricevuta, non versionata: **contiene chiavi API in chiaro** (ecl2mqtt 00 § 9), da ripulire prima del commit |

## Kit di query (nel repository, non in KB)

In [`../sql/queries/`](../sql/queries/): `db-query-01.sql`, `-02.sql`, `-03.sql` e le versioni `-prod`, riutilizzabili anche sul DB di HQ. `db-query-04-struttura.sql` estrae il catalogo completo della struttura di un database, per confrontare sale diverse, test e produzione, sala e HQ. I risultati sono in [`../sql/risultati/`](../sql/risultati/).

$1 `winmtprov/` contiene gli script di riferimento distribuiti con WinMtProv (sync 03).

[`../sql/esegui-query.ps1`](../sql/esegui-query.ps1) esegue i kit da PowerShell senza SSMS. Legge server e credenziali dal file `.env` nella radice del repository, escluso da git.

## Materiale ricevuto il 19/10

- Codice sorgente di WinMT (VB6): **analizzato** (WinMT 00–10)
- Documentazione varia, non esaustiva: da analizzare. Quella del motore B4J (`fonti/ecl2mqtt/`) è **analizzata** (ecl2mqtt 07)
$1
## Materiale ricevuto il 27/10

- Sorgenti di `ExecuteSync`, `ExecuteSyncSSH` e `WinMtProv` (.NET), con gli script SQL di WinMtProv: **analizzati** (sync 00–03). Gli script sono versionati in `sql/codice-db/winmtprov/`, senza segreti

## Materiale atteso

- Il componente che pianifica la sincronizzazione e ne scrive l'esito in `Setup` (sync 00 § 7, domanda 1). `ExecuteSync` e `WinMtProv`, ricevuti il 27/10, non lo fanno
- DB di produzione di HQ (cloud). Il DB di produzione della sala (`WinMtSqlDBNuovo`, 6,9 GB) è stato ricevuto
- Trascrizione Whisper C++ della riunione del 19/10

## Fatti stabiliti

- Il primo DB analizzato (DB 01–04) è di **test**. Il DB di produzione (DB 05–06) è della salagiochi Central Park di Rimini, copia del 14/07/2026, usata in sola lettura come campione.
- I server di sala in produzione non sono SQL Server Express.
- Fase 1: modello dati logico, flussi censiti e pesati, architettura definita, stima della fase 2 con variabilità fino al ±30%, due riunioni di revisione.
- Fuori perimetro: firmware dei dispositivi. La comunicazione tra dispositivi e server di sala è affidata alla BE.
- Cassa e totem saranno riscritti, probabilmente in Flutter, su API Laravel.
$1- La sala si sincronizza con il cloud tramite Sync Framework: lo scope `WinMtSync` replica il DB di sala nella sua copia `DBnnnn`, lo scope `LocalSync` replica il server primario sul secondario. Perimetro di 61–62 tabelle senza filtri, scritto in WinMtProv (sync 00 § 2).
