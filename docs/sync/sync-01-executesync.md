# Galileo HQ — Sync 01: `ExecuteSync` ed `ExecuteSyncSSH`, la sincronizzazione sala–cloud

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

**Fonte:** sorgenti in `legacy/ExecuteSync/` e `legacy/ExecuteSyncSSH/` (esclusi dal repository), compilati in `bin/` · **Collegati:** [`sync-00-mappa.md`](sync-00-mappa.md) (mappa e sintesi), [`sync-02-winmtprov.md`](sync-02-winmtprov.md)

Evidenze `file:riga`, relative a `legacy/`. **V** = verificato nel codice, **D** = dedotto. Le credenziali scritte nel codice non sono riportate: si indica solo dove si trovano.

---

## 1. Cosa sono

Due programmi console C# quasi identici, di circa 70 righe ciascuno, che eseguono **una** sincronizzazione Microsoft Sync Framework fra il DB di sala e la sua copia nel cloud, poi terminano. Non hanno pianificazione, interfaccia o configurazione esterna: server, database e credenziali sono scritti nel codice. **V**

| | `ExecuteSync` | `ExecuteSyncSSH` |
|---|---|---|
| Sorgente | `ExecuteSync/ExecuteSync/Program.cs` (77 righe) | `ExecuteSyncSSH/ExecuteSyncSSH/Program.cs` (76 righe) |
| Ultima modifica del sorgente | 06/09/2024 | 24/08/2023 |
| Copyright | 2013, senza autore | 2023, "ELMAC II" |
| Runtime | .NET Framework 4.0 Client Profile nel progetto, 4.5.1 nel `.config`; x64 | .NET Framework 4.6.1, AnyCPU |
| Libreria | Microsoft Sync Framework 2.1 (`Microsoft.Synchronization` 2.1, `…Data` e `…Data.SqlServer` 3.1, del 2010) | Stessa |
| Server cloud | `sql.galileouk.cloud` nel sorgente attuale; `winmt.elmaccloud.com` nelle build più vecchie e in una riga commentata | `127.0.0.1,4433`: un tunnel SSH locale verso il server cloud |

Il nome conferma quanto riferito: è il **programma .NET che esegue la sincronizzazione** fra sala e cloud. Le stesse operazioni sono disponibili anche a mano in WinMtProv (sync 02, SY02-07).

## 2. Come funziona

```
ExecuteSync.exe <DBnnnn> <server SQL locale>
```

1. **Parametri.** `args[0]` è il nome del DB cloud della sala (`DB` + `Setup.NImp` su quattro cifre, sync 02 § 3); `args[1]` è l'istanza SQL Server locale. Nessun controllo: senza argomenti il programma termina con un'eccezione. `Program.cs:15-16` **V**
2. **Connessioni.** **V**
   - Al cloud con l'utente `WinMtSync`, sul database indicato (`Program.cs:19`, credenziale nel codice). È l'utente che WinMtProv rende `db_owner` di ogni DB cloud (sync 02, SY02-03).
   - Alla sala con `sa` sul database fisso `WinMtSqlDB` (`Program.cs:22`, credenziale nel codice; una seconda password `sa` commentata alla riga 21).
3. **Scope.** Provider locale e remoto sullo scope `WinMtSync` (nel provider locale scritto `WInMtSync`: SQL Server lo confronta senza distinguere le maiuscole). `Program.cs:31-32` **V**
4. **Direzione** `UploadAndDownload`: prima le modifiche della sala salgono al cloud, poi quelle del cloud scendono in sala. `Program.cs:35` **V**
5. **Esito.** Al termine scrive una riga in `Sync.log`, nella cartella dell'eseguibile, **sovrascrivendo** il file: ora d'inizio, modifiche caricate, modifiche scaricate, ora di fine. `Program.cs:17, 49-56` **V**
6. **Conflitti.** Un gestore di `ApplyChangeFailed`, agganciato solo al provider **locale** (le modifiche che scendono in sala), scrive tipo di conflitto ed errore in `Sync.log`, ma nella cartella **Documenti** dell'utente che esegue il programma. Anche questo file è sovrascritto a ogni conflitto, quindi resta solo l'ultimo. Il gestore non sceglie un'azione: vale il comportamento predefinito di Sync Framework. I conflitti sul cloud (modifiche che salgono) non sono intercettati. `Program.cs:38-41, 63-75` **V** (comportamento predefinito **D**)

Due copie di `Sync.log` del 23/01/2015 e del 07/03/2024, rimaste nelle cartelle di build, registrano 0 modifiche in entrambe le direzioni, in circa 50 secondi.

## 3. Cosa non fa

- **Non si pianifica da solo.** Esegue una sincronizzazione e termina. Nel codice ricevuto nessuno lo lancia: né WinMT, né il motore `ecl2mqtt`, né WinMtProv (ricerca di `ExecuteSync` in tutti i sorgenti di `legacy/`). Chi lo avvia, e ogni quanto, va chiesto (sync 00 § 7). **V**
- **Non scrive l'esito nel database.** WinMT legge l'esito in `Setup.SyncRes` ("Success on: …" o "Failed on: …") e l'ora in `Setup.D1`, ma nessun programma ricevuto scrive quelle stringhe (sync 00 § 2.3). **V**
- **Non gestisce gli errori.** Non c'è `try`: se il cloud o il DB locale non rispondono, il processo termina con un'eccezione non gestita e `Sync.log` non viene aggiornato. Chi lo lancia vede solo il codice di uscita. **V**
- **Non usa una transazione propria né una ripresa.** Si affida a Sync Framework, che a ogni esecuzione riparte dalla conoscenza salvata nelle tabelle `scope_info` e `*_tracking`. **D**
- **Non gestisce lo scope `LocalSync`** verso il server secondario della sala: questo si sincronizza solo da WinMtProv (sync 02, SY02-08). **V**

## 4. Varianti e residui nel materiale ricevuto

| Elemento | Cosa contiene | Valutazione |
|---|---|---|
| `bin/x64/Release/ExecuteSync.exe` (06/09/2024) | Build verso `sql.galileouk.cloud` | Ultima build della variante diretta |
| `bin/Release/`, `bin/Debug/`, `bin/x64/Debug/` (2015–2024) | Build verso `winmt.elmaccloud.com` | Build precedenti |
| `bin/x64/Release/ExecuteSyncSSH.exe` dentro `ExecuteSync/` (24/08/2023) | Build della variante SSH | Copia dell'eseguibile di `ExecuteSyncSSH` |
| `ExecuteSecSync.sln` (27/12/2022) | Seconda soluzione sullo **stesso** progetto | Il commento "per il sync secondario: SecWinMtSync" (`Program.cs:29-30`) indica che si ricompilava cambiando il nome dello scope. Lo scope `SecWinMtSync` non esiste né nel DB di test né in quello di produzione: variante non più in uso **D** |
| `LocalSync.vcxproj` (15/07/2020) | Progetto C++ vuoto, senza sorgenti | Residuo |
| `publish/` (02/12/2014) | Installatore ClickOnce (`setup.exe`, `ExecuteSync.application`) | Distribuzione storica |

**Server e credenziali dipendono dalla build.** Per passare da un cloud all'altro, o dal collegamento diretto al tunnel, si ricompila (`Program.cs:19-22` contro `ExecuteSyncSSH/…/Program.cs:19-21`). Le due varianti usano anche password `sa` locali diverse, la stessa coppia che WinMtProv associa ai due server cloud (sync 02 § 2). **V**

## 5. Credenziali nel codice

| Dove | Cosa |
|---|---|
| `ExecuteSync/ExecuteSync/Program.cs:19` | Utente e password `WinMtSync` del cloud `sql.galileouk.cloud` |
| `ExecuteSync/ExecuteSync/Program.cs:20` (commentata) | Utente e password `WinMtSync` del cloud `winmt.elmaccloud.com` |
| `ExecuteSync/ExecuteSync/Program.cs:21-22` | Due password `sa` del DB di sala, una commentata |
| `ExecuteSyncSSH/ExecuteSyncSSH/Program.cs:19, 21` | Password `WinMtSync` del cloud (tunnel) e `sa` della sala |

Le stesse stringhe sono compilate negli eseguibili in `bin/`. Chi ha un eseguibile ha l'accesso `db_owner` al DB cloud della sala e `sa` alla sala (sync 00 § 6).

## 6. Flussi

| Id | Flusso | Descrizione | Trigger/attore | Peso | Tabelle | Evidenza | Equiv. WinMT | Rapporto |
|---|---|---|---|:-:|---|---|---|---|
| SY01-01 | Sincronizzazione sala–cloud | Una sessione Sync Framework `UploadAndDownload` sullo scope `WinMtSync` fra `WinMtSqlDB` e `DBnnnn` nel cloud | Riga di comando; chi la lancia non è nel codice | L | Le 61–62 tabelle dello scope (sync 02 § 4), in lettura e scrittura su entrambi i lati; `scope_info`, `*_tracking` | `Program.cs:15-49` | Nessuno: WinMT ne legge solo l'esito (`Setup.SyncRes`, `Form1.frm:16892`) | Unico; ripetuto a mano da WinMtProv (SY02-07) |
| SY01-02 | Sincronizzazione via tunnel SSH | Come SY01-01, verso `127.0.0.1:4433` | Come SY01-01 | — | Come SY01-01 | `ExecuteSyncSSH/…/Program.cs:19-31` | — | **Variante** di SY01-01, non contata |
| SY01-03 | Registrazione dell'esito | Statistiche in `Sync.log` (cartella del programma) e ultimo conflitto in `Documenti\Sync.log`, entrambi sovrascritti | Fine della sessione, conflitto | S | Nessuna (file) | `Program.cs:49-56, 63-75` | — | Unico |

**Peso.** Il codice è banale, ma il peso misura la funzione da rifare: la replica fra sala e cloud, con conflitti, cancellazioni e sala che lavora senza connessione, è il cuore dell'architettura sala–cloud del nuovo sistema (sync 00 § 5).
