# Galileo HQ — DB 05: database di produzione, risultati Q01–Q10

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-22

**Fonte:** `[WinMtSqlDBNuovo]`, copia in sola lettura ripristinata da `.bak` su un'istanza Express locale (il server di produzione non è Express) · **Collegati:** DB 01–04, che riguardano il database di **test**

---

## 1. Profilo del database

- **Data della copia:** l'ultimo dato è del **14/07/2026 alle 11:01**. Il backup ha quindi circa tre mesi.
- **Impianto unico:** `NImp = 196` in tutte le anagrafiche e nei movimenti. Nel DB di test 9997 e 146 erano quindi valori di laboratorio.
- **Profondità storica:**
  - ticket, vincite e resi dal **2002**;
  - clienti dal **2004**;
  - movimenti card (`TransCard`) e contatori (`EcsDati`) dall'**agosto 2023**, data probabile di introduzione dell'ECL in questa sala.
- **Volumi:** circa 39.400 clienti, 23.700 card coinless, 98 macchine, 2,27 milioni di righe di contatori, 1,27 milioni di movimenti card, 841.000 ticket, 243.000 consegne di premi.
- **Dimensione:** 6.939 MB. Il server di produzione della sala **non è Express**: il limite di 10 GB non si applica.

**Evento del 03/06/2026.** Tutti i trigger, di sincronizzazione e applicativi, sono stati ricreati il 03/06/2026 tra le 10:30 e le 10:31. Dalle 11:35 dello stesso giorno partono i dati di `CoinlessDati`, `CoinlessDecodedData`, `CoinlessTransazioniCards`, `ecl_log`, `CraneCounterSyncLog` e del modulo gru. È un aggiornamento o una migrazione della sala, coerente con il nome `WinMtSqlDBNuovo`. Lo storico coinless precedente non è in questo database.

---

## 2. Dimensione e crescita

### Dove va lo spazio

| Tabella | Righe | MB totali | di cui indici | Indici |
|---------|------:|----------:|--------------:|-------:|
| TransCard | 1.272.353 | 2.567 | **2.312** | 29 |
| EcsDati | 2.273.972 | 1.609 | 814 | 5 |
| Tickets | 840.959 | 769 | 579 | 13 |
| EcsDati_tracking | 2.273.972 | 583 | 97 | 2 |
| TransCard_tracking | 1.273.167 | 325 | 55 | 2 |
| ecl_log | 1.020.638 | 228 | 0 | 1 |
| Tickets_tracking | 840.959 | 217 | 38 | 2 |

- **Gli indici di tre sole tabelle occupano circa 3,7 GB**, oltre metà del database. Per `TransCard` gli indici pesano **nove volte i dati**.
- **I metadati di Sync Framework** (`_tracking`) occupano circa 1,2 GB, il 17% del totale.

### Velocità di crescita (stima)

| Fonte | Base di calcolo | Crescita annua |
|-------|-----------------|---------------:|
| `ecl_log` | 228 MB in 41 giorni | ≈ 2,0 GB |
| `CoinlessDati` | 116 MB in 41 giorni | ≈ 1,0 GB |
| `TransCard` + tracking | 2,9 GB in 2,95 anni | ≈ 1,0 GB |
| `EcsDati` + tracking | 2,2 GB in 2,95 anni | ≈ 0,7 GB |
| `CoinlessDecodedData` | 44 MB in 41 giorni | ≈ 0,4 GB |
| **Totale principali** | | **≈ 5 GB/anno** |

La sala cresce quindi di circa 5 GB l'anno. Le tabelle coinless sono misurate solo sulle sei settimane successive al 03/06/2026, e il ritmo potrebbe includere un picco iniziale. Poiché il server non è Express, questo non è un rischio di blocco. È però un dato di dimensionamento per il nuovo disegno, per tre ragioni:
- **backup e replica verso il cloud**, che il progetto vuole rafforzare, devono trasferire questi volumi;
- **politica di conservazione** di log e telemetria (`ecl_log`, `CoinlessDati`), che oggi non sembra esistere;
- **modello multi-sala**: il cloud riceve la somma di più sale.

**Indici sproporzionati.** Una revisione dei 29 indici di `TransCard` e dei 13 di `Tickets`, molti dei quali duplicati nel DB di test, ridurrebbe dimensione, tempi di scrittura, sincronizzazione e backup. Non è urgente, ma è un'indicazione utile anche per le sale attuali.

## 3. Conferme rispetto al database di test

- **`IdContatto` è la chiave reale del cliente.** Gli orfani sono quasi nulli in tutte le tabelle figlie, mentre verso `IdLong` sono il 100%.
- **`TransCard.CodMac` ha due significati.** 134.500 righe con soli 4 codici non corrispondono a macchine: sono postazioni (cassa, totem). Sono le stesse righe che hanno `Operatore`, `D0` e `T0` valorizzati (circa 134.000): le operazioni di cassa e totem.
- **Gli articoli spariscono dallo storico.** 23.048 consegne di premi (9,5%, su 449 codici) puntano ad articoli che non esistono più. Lo stesso vale per 127 carichi e 71 resi.
- **Il proprietario delle macchine è testo libero** (un solo valore) e `Owners` è vuota.
- **Frammentazione del 92–99%** su `TransCard`, `Tickets`, `EcsDati` e sulle relative tabelle di tracking, cioè sulle tabelle con chiave GUID. Qui i volumi sono reali, quindi l'impatto sulle prestazioni è concreto.
- **Password in chiaro.** Nessun valore con aspetto di hash: 624 clienti con password, di cui solo 167 distinte, lunghe al massimo 8 caratteri.

---

## 4. Differenze rispetto al database di test

- **Sincronizzazione estesa a 61 tabelle** (40 nel test). Sono state aggiunte, tra le altre, AuditLog, BEConfig, Compleanni, Gru*, Ospiti, PartiteOspiti, promozioni*, setup2, cache_dati_grafico_giornaliero e CoinlessLogEventiBlacklist. Q11 e Q12 lo confermeranno.
- **Tabelle presenti solo nel test:** `pos_transaction` e `Nayax` non esistono in produzione, e `LogTransazioniPos` è vuota. **I pagamenti POS non sono attivi in questa sala** (da segnalare al team).
- **PAN in `LogTransazioniTotem`:** 252 valori, nessuno mascherato e nessuno composto da 13–19 cifre. Q14 ne mostrerà la forma.
- **Magazzino fermo:** ultimo carico nel **giugno 2024**, nessuno scarico, 317 carichi in vent'anni. L'inventario premi di questa sala non passa da WinMT.
- **Campi jolly.** `Tickets.F1` e `Tickets.T1` sono valorizzati esattamente sulle stesse 275.637 righe che hanno `NImp = 0`. È quindi un sottotipo di ticket, probabilmente generato dal circuito ECL. `Clienti.T0` è valorizzato per circa 24.100 clienti, un numero vicino alle 23.700 card coinless.
- **Date anomale:** `TransCard.Data` arriva al **2047** (orologio di dispositivo errato), `Setup.DataEnd` vale 2999-12-31, `Clienti.Nascita` ha 1900-01-01 come segnaposto.

---

## 5. Domande nuove per il team

1. Esiste un monitoraggio della dimensione dei DB di sala?
2. Cosa è stato fatto il 03/06/2026? Dove si trova lo storico coinless precedente?
3. `ecl_log` e `CoinlessDati` vengono ripuliti periodicamente? Con quale politica?
4. Gli indici di `TransCard` e `Tickets` sono stati aggiunti per report specifici? Qualcuno ne conosce l'origine?
5. Il magazzino premi di questa sala è gestito fuori da WinMT?
