# Galileo HQ — DB 06: database di produzione, risultati Q11–Q17

**Stato:** bozza · **Responsabile:** Piero · **Aggiornato:** 2026-10-27

**Fonte:** `[WinMtSqlDBNuovo]` (copia del 14/07/2026) · **Collegati:** `db-05-produzione-01.md`. Questo documento **corregge** alcune conclusioni di DB 04, tratte dal database di test.

---

## 1. La sala

Il database è della **salagiochi Central Park di Rimini** (impianto 196). `Setup` (Q16) contiene 11 postazioni:

| Postazione | Ruolo presunto | Note |
|------------|----------------|------|
| `WINMTSQL` | Master, cassa principale | Sync abilitata; ultimo esito registrato "Success" del **04/06/2024** |
| `TOTEM-ECL-1`, `TOTEMECL-2` | Totem | Etichetta "VIP Card" |
| `CASSA-MOBILE` | Cassa mobile | Compare solo in `TransCard`, non in `Setup` |
| `GALILEOSERVER-1`, `GALILEOSERVER-2` | Server di sala, forse primario e secondario | Il manuale cita un "Secondary server" non documentato |
| `PRIZEHUB01` | PrizeHub | Nessun dato in `PrizeHubSlots` |
| `DESKTOP-VECCHIO` | Postazione dismessa | `MName` termina con un carattere spurio |
| `TOBY-DEV-VM` | **Macchina di sviluppo registrata in produzione** | Da chiarire |
| Due postazioni senza nome (109, 110) | ? | La 110 registra "Success" il **14/07/2026 alle 10:53**: è probabilmente l'host che oggi esegue la sincronizzazione |
| `MISTRAL` (111) | Configurazione raccolta card | |

Le operazioni di cassa e totem su card (Q15) vengono da **quattro sole postazioni**: `WINMTSQL` (111.741), `TOTEMECL-2` (9.307), `CASSA-MOBILE` (7.332) e `TOTEM-ECL-1` (6.120). Il totale, 134.500, coincide con gli "orfani" di Q05. In produzione non compaiono movimenti di postazioni di sviluppo. Togliendo il `|` finale, `CodMac` corrisponde a `Setup.MName` nel 94,5% delle operazioni (Q19). Il resto è quasi tutto `CASSA-MOBILE`, che non è censita in `Setup`.

$1
>
> **Aggiornamento 27/10 (sync 00 § 2.1).** Confermata: `LocalSync` è la replica fra il server primario (`Setup(102).NRep2` = 192.168.169.50) e il secondario (`NRep3` = 192.168.169.60); `WinMtSync` sincronizza la sala con `DB0196` nel cloud.

---

## 2. Sincronizzazione

- **Scope** (Q11): `LocalSync` e `WinMtSync` contengono le stesse **61 tabelle**, senza filtri.
- **Tombstone** (Q12): pochissime. Ci sono 814 cancellazioni in `TransCard` e 9 in `Vincite` dal 03/06/2026, e nessuna in `EcsDati`, `Tickets` e `Clienti`. Il tracking è stato riprovisionato il 03/06/2026, quindi le cancellazioni precedenti non sono visibili.
- **Storico conservato.** In questa sala vincite e ticket risalgono al 2002 (Q08).

> **Correzione di DB 04, § 2.** La cancellazione massiva del 22/05/2026 e le cancellazioni progressive di contatori e movimenti riguardano il **database di test**, non la produzione. Per il requisito di migrazione resta valida l'osservazione generale: Sync Framework propaga le cancellazioni, quindi una pulizia in sala raggiunge anche il cloud.

---

## 3. Identificativi delle card

Q13, Q18 e Q21, lette insieme a Q05 e Q06, chiariscono la catena:

- **`UID_Ammessi`** (50.010 righe) è l'anagrafica delle card fisiche emesse: UID RFID più barcode stampato.
- **`Clienti.T0` contiene l'UID della card del cliente.** 24.089 UID di `UID_Ammessi` corrispondono a `Clienti.T0`, e lo stesso numero di barcode corrisponde a `Clienti.CodBar`. Le restanti 25.900 card sono scorta non assegnata.
- **`CoinlessCards.cardid` è lo stesso UID in un altro formato** (Q18 e Q21):
  - `cardid` ha 8 caratteri esadecimali, cioè l'UID RFID a 4 byte;
  - `UID_Ammessi.UID` e `Clienti.T0` hanno 16 caratteri: lo stesso UID seguito da 8 cifre **costanti** (un solo valore su 50.010 righe), quindi un semplice riempimento;
  - 23.710 card coinless su 23.716 (99,97%) compaiono tra le card fisiche emesse, confrontando i primi 8 caratteri.
- **`Clienti.T0` non è sempre aggiornato.** Per lo stesso cliente, la card coinless e `T0` coincidono in 21.907 casi su 23.715 (92,4%). Nei circa 1.800 casi restanti il cliente ha probabilmente più card (sostituzioni, master/slave) e `T0` ne conserva una sola, forse quella originaria.
- **`TransCard.IdCli`** è l'`IdContatto` scritto come testo. **Confermato in produzione** (Q19): corrisponde in 1.272.299 righe su 1.272.353, con solo 54 orfani.

> **Correzione di DB 04, § 4.** In DB 04 l'ipotesi "`Clienti.T0` = UID della card" era stata data per smentita. Era smentita solo rispetto a `CoinlessCards.cardid`. Rispetto a `UID_Ammessi` è **confermata**. Nel nuovo modello servirà un'unica entità *card*, con UID (un solo formato), barcode e stato, collegata al cliente con una relazione uno-a-molti che conservi la storia delle sostituzioni. Oggi lo stesso dato vive in tre tabelle con due formati e può divergere.

---

## 4. Livelli card

| TipoCard | Clienti | Quota |
|---------:|--------:|------:|
| 2 | 36.245 | 91,9% |
| 3 | 3.043 | 7,7% |
| 0 | 99 | 0,3% |
| 1 | 50 | 0,1% |

> **Correzione di DB 04, § 5.** Il 39% di card con `TipoCard = 0` era un artefatto del database di test. In produzione le card con valore 0 sono 99. Se 0 corrisponde a Platinum, il problema del default non si manifesta qui: `TipoCard` viene evidentemente impostato a 2, verosimilmente Silver, alla creazione.
>
> Resta da chiarire cosa sia il valore 3 (3.043 clienti). È improbabile che sia "Compleanno" con questa numerosità; potrebbe essere un altro livello o una categoria.

`Clienti.N0` assume i valori 0 e 1 in proporzioni simili e non segue `TipoCard`: il suo significato resta da decodificare dal codice.

---

## 5. Pagamenti

I 252 valori di `LogTransazioniTotem.PAN` sono **tutti stringhe vuote** (Q14), e `LogTransazioniPos` è vuota. Anche Q20, che cerca 16 o più cifre consecutive, non restituisce righe. In questa sala **non ci sono dati di carte di pagamento**, coerentemente con l'assenza del POS.

---

## 6. Domande per il team

$1 **Probabilmente sì** (sync 00 § 2.1): resta da confermare che i due nomi corrispondano ai due IP.
2. Quale host esegue oggi la sincronizzazione (postazione 110, senza nome)?
3. Perché una macchina di sviluppo (`TOBY-DEV-VM`) è registrata nel database di produzione?
4. Cosa significano i valori 2 e 3 di `TipoCard`?
5. Cosa rappresenta `Clienti.T0` quando un cliente ha più card? Le 8 cifre finali dell'UID hanno un significato storico?
