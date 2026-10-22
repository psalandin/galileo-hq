# CLAUDE.md — Galileo HQ

Istruzioni condivise per Claude Code. Valgono per tutti i membri del team; le preferenze personali vanno in `.claude/settings.local.json` o nel proprio `~/.claude/CLAUDE.md`, non qui.

## Progetto

Riprogettazione di **WinMT** (gestionale di sala, monolite VB6) e di **HQ** (gestione centralizzata) in un sistema cloud con configurazione remota delle macchine e gestione multisala.

**Dominio:** sale giochi di intrattenimento con meccanica *redemption*. **Non è gioco d'azzardo.** I clienti giocano con gettoni, crediti o card ricaricabili; le vincite sono ticket o punti senza valore fuori dalla sala, riscattabili in premi o partite. Il glossario è in `docs/analisi/analisi-00-prima-lettura.md` (§ 5).

**Fase attuale:** 1 — analisi. Prodotti attesi: modello dati logico, censimento e pesatura dei flussi, architettura sala–cloud, stima della fase 2 con variabilità fino al ±30%.

## Vincoli tecnici già fissati

- Backend e API REST: **Laravel**
- Front-end desktop, cassa e totem: **Flutter**, su API Laravel
- Trasporto delle richieste sala–cloud: broker **MQTT**
- Database di sala e cloud: **SQL Server**
- Fuori perimetro: firmware dei dispositivi; la comunicazione dispositivi–server di sala è affidata alla BE

## Principi di analisi

- Il nuovo modello dati si progetta **a partire dalle funzionalità**, non dal database attuale, che contiene scorciatoie e non è fonte di verità.
- Il DB analizzato finora (`docs/db/`) è un **DB di test**: ogni conclusione sui dati va verificata su quello di produzione.
- La sala deve continuare a funzionare **senza connettività verso il cloud** (e senza wireless locale): requisito distintivo da preservare.
- Logica applicativa **una sola volta, lato server**; client sottili.
- Distinguere sempre tra **decisione presa**, **orientamento emerso** e **ipotesi**.

## Affidabilità delle fonti

- Le trascrizioni in `docs/riunioni/` hanno errori di riconoscimento sui termini tecnici (es. "WB6" = VB6, "ICL/ACL" = ECL).
- **L'attribuzione dei relatori non è affidabile**: non attribuire un'affermazione a una persona sulla base della sola trascrizione.
- Date, nomi e scadenze nei sommari automatici (Plaud) possono essere inferiti dallo strumento: vanno confermati.
- `docs/fonti/` contiene materiale ricevuto: si cita, **non si modifica**.

## Scrittura dei documenti

- Italiano, Markdown, prosa chiara; tabelle per confronti e cataloghi.
- In testa a ogni documento: `**Stato:** … · **Responsabile:** … · **Aggiornato:** AAAA-MM-GG`.
- Use case in `docs/use-case/`, un file ciascuno, dal modello `_modello-use-case.md`.
- Quando un documento cambia in modo sostanziale, aggiornare anche `docs/00-indice.md`.

## Cosa non fare

- Non aggiungere al repository dump di database, sorgenti di terzi, audio o credenziali (vedi `.gitignore`).
- Non riportare in chiaro stringhe di connessione o password nei documenti e negli script.
- Non fare `push --force` su `main`.
