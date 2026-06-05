# RUNBOOK N5.6-B — Backend Release in Produzione

> **STATO: PLANNING ONLY — NON ESEGUIRE.**
> Questo documento descrive *come* si farebbe la release del backend in produzione.
> **Nessuno step va eseguito** finché Mirko non dà un **GO esplicito** per ciascuna fase.
> Aggiornato: 2026-06-05 (rev. push kill-switch). Repo: `~/Projects/Plagit-new-project/backend-node` · branch `restore-2026-04-14-pre-extra-languages` · HEAD `e1da3a4` (kill-switch push — vedi §0.1).
> Remote: **`origin` esiste** = `github.com/piciccomirko-tech/plagit-app.git` · **branch ahead 50 vs `origin`**, behind 0. Il canale di deploy va deciso prima del GO (vedi §3 e §4 Step 3).

---

## 0. Cosa è (e cosa NON è) N5.6-B

**N5.6-B = portare il backend di produzione al pari del codice locale**, cioè:
- deploy del codice backend aggiornato su Railway (prod è ~250 commit indietro);
- applicazione della **migration mancante `055_feed_post_reposts`** sul DB di produzione.

**N5.6-B NON include** (sono decisioni separate e successive, ognuna con il proprio GO):
- ❌ **Abilitare i push reali in produzione** (= settare `PUSH_REAL_ENABLED=true`) → è la **N5.6 “FCM prod”**, track a parte con GO dedicato. In N5.6-B prod **resta in LOG MODE** (vedi **§0.1**: `FCM_SERVICE_ACCOUNT_JSON` è già su Railway ma da solo **NON** attiva più i push reali, grazie al kill-switch).
- ❌ **TestFlight / build bump / Codemagic** (lato Flutter).
- ❌ **Android push** (manca `google-services.json` + plugin gradle).

---

## 0.1 Push mode — kill-switch `PUSH_REAL_ENABLED` (CRITICO)

> Aggiunto dopo la scoperta del 2026-06-05 + fix commit `e1da3a4` (`feat(push): gate real delivery behind PUSH_REAL_ENABLED opt-in`).

1. **`FCM_SERVICE_ACCOUNT_JSON` è GIÀ presente su Railway prod** (valore reale, ~2328 char). Non era documentato; ora è un fatto acquisito.
2. **Da solo NON deve più attivare i push reali.** Dopo `e1da3a4` la sola presenza di FCM non è più sufficiente a passare in modalità reale.
3. **Il backend parte in LOG MODE di default.** `resolveMode()` ritorna `'log'` a meno che `PUSH_REAL_ENABLED` non sia **esattamente** `'true'`.
4. **I push reali partono SOLO se** `PUSH_REAL_ENABLED=true` **E** è presente una credenziale provider (FCM o APNs).
5. **Se `PUSH_REAL_ENABLED` è assente, `false`, o qualunque valore ≠ `true`** (anche `TRUE` maiuscolo) → **push mode = log**.
6. **Durante il deploy N5.6-B, verificare nei log Railway al boot:**
   ```
   [Plagit API] Push mode: log
   ```
7. **Se nei log compare `[Plagit API] Push mode: live` → STOP IMMEDIATO**: non eseguire la migration, fare rollback / fermare il deploy (§6). Significa che `PUSH_REAL_ENABLED=true` è su Railway — **non deve esserlo** in N5.6-B.
8. **NON rimuovere `FCM_SERVICE_ACCOUNT_JSON` da Railway.** Resta dov'è; il kill-switch la rende innocua in N5.6-B.
9. **NON settare `PUSH_REAL_ENABLED=true` durante N5.6-B.**
10. **La fase “FCM prod reale” (push reali agli utenti) resta FUORI SCOPE** e richiede un **GO separato** (= settare `PUSH_REAL_ENABLED=true`, vedi §7).

---

## 1. Pre-condizioni già validate (dry-run 2026-06-05 — PASS)

Vedi checkpoint in `MEMORY.md` (Flutter repo). In sintesi, **su copia isolata di prod**:
- Backup nativo Railway **2026-06-05 13:21 UTC (~141 MB)** + dump logico `pg_dump` 18.3 (~21 MB).
- Restore su **Postgres 18 locale `:5433` → PASS, 0 errori**.
- `knex migrate:latest` sulla copia → **applicata SOLO `055_feed_post_reposts`** (delta reale = **1**).
- Code smoke locale (LOG MODE) su `health` / notifiche / conversations → **PASS**.
- Produzione **mai toccata**; TCP Proxy aperto solo per il dump e **già richiuso**.

➡️ **Rischio della migrate di prod: BASSO** — 1 sola migration additiva, già provata sui dati reali.

---

## 2. Delta esatto prod → codice

| Cosa | Prod attuale | Codice (HEAD `b7f9511`) |
|------|--------------|--------------------------|
| Ultima migration applicata | `054_device_tokens_p32_extend` | `055_feed_post_reposts` |
| Migration da applicare | — | **`055_feed_post_reposts` (1 sola)** |
| Codice backend | ~250 commit indietro | aggiornato |
| Modalità push | LOG MODE (FCM dormiente, codice vecchio) | **LOG MODE** — FCM presente ma neutralizzato dal kill-switch `PUSH_REAL_ENABLED` (§0.1) |

---

## 3. Pre-flight checklist (prima di toccare prod)

- [ ] **GO esplicito di Mirko** per la release backend (N5.6-B).
- [ ] **Backup fresco di prod il giorno stesso** (il backup del dry-run è valido per il test, ma per la release vero rifare un backup nativo Railway + `pg_dump` 18.3 *immediatamente prima*).
- [ ] Verificare che `migrate:latest` su prod risulti ancora con **un solo** pending (`055`) — se nel frattempo sono comparse altre migration, **rivalidare** il dry-run.
- [ ] **Decidere il canale di deploy PRIMA del GO** (correzione 2026-06-05): il repo **HA un remote** (`origin = github.com/piciccomirko-tech/plagit-app.git`) e il branch è **ahead 49 vs `origin`**. Due opzioni mutuamente esclusive:
  - **Opzione A — `railway up` manuale** dalla cartella `backend-node/` (carica la working dir sul service Railway, rispetta `.gitignore` + `.railwayignore`).
  - **Opzione B — push su GitHub** (`origin`) **solo se** il service Railway è collegato all'auto-deploy da quel branch.
  - ⚠️ Verificare nella dashboard Railway se l'auto-deploy GitHub è attivo: se sì → A e B insieme causerebbero un doppio deploy. **Per ora NESSUNA delle due viene eseguita.** Annotare `service` / `environment` Railway corretto.
- [ ] Finestra di basso traffico concordata.
- [ ] `FCM_SERVICE_ACCOUNT_JSON` **è presente** su Railway (FATTO NOTO) → **lasciarla così, NON rimuoverla**. Il kill-switch `PUSH_REAL_ENABLED` mantiene LOG MODE (§0.1).
- [ ] `PUSH_REAL_ENABLED` **NON deve essere `true`** su Railway durante N5.6-B. Verifica read-only (solo conteggio): `railway variables --kv | grep -c '^PUSH_REAL_ENABLED='` → atteso `0` (o comunque valore ≠ `true`).
- [ ] Il codice da deployare **include il kill-switch** (working tree al commit `e1da3a4` o successivo).
- [ ] Confermare env prod intatte: `DATABASE_URL`, `DB_SSL`, JWT/secret invariati.

---

## 4. Esecuzione (ogni step ha verifica + STOP gate)

> Comandi reali dal `package.json`:
> `migrate:prod` = `NODE_ENV=production npx knex migrate:latest` ·
> rollback prod = `NODE_ENV=production npx knex migrate:rollback` ·
> start = `node src/server.js` · healthcheck = `GET /health`.

**Step 1 — Backup di sicurezza (read-only)**
```bash
# 1a. Backup nativo Railway (da dashboard Railway → Postgres → Backups → Create backup)
# 1b. Dump logico locale con client allineato alla versione server (PG 18.x)
pg_dump --version            # deve essere 18.x
pg_dump "$DATABASE_URL_PROD_READONLY" -Fc -f prod_$(date +%Y%m%d_%H%M).dump
```
✅ Verifica: file dump creato, dimensione coerente (~20+ MB). **Chiudere subito il TCP Proxy** se aperto per il dump.
🛑 STOP: non proseguire senza backup confermato.

**Step 2 — Dry-run finale (ripetere su copia, NON su prod)**
```bash
# restore del dump su un Postgres 18 locale isolato (es. :5433) e:
NODE_ENV=development npx knex migrate:latest   # contro la copia
```
✅ Verifica: applica **solo** `055_feed_post_reposts`, 0 errori, smoke `health`/notifiche/conversations OK.
🛑 STOP: se compaiono altre migration o errori → **non rilasciare**, rianalizzare.

**Step 3 — Deploy del codice su Railway (LOG MODE via kill-switch — FCM resta presente)** — scegliere UNA sola opzione (vedi §3)
```bash
# OPZIONE A — railway up manuale (dalla cartella backend-node/, service/environment di PROD):
railway up

# OPZIONE B — push su GitHub, SOLO se Railway ha l'auto-deploy collegato a questo branch:
git push origin restore-2026-04-14-pre-extra-languages
```
> Il branch è **ahead 49 vs origin**. Se si sceglie A, il push GitHub resta facoltativo (solo per allineare il backup del codice). Se si sceglie B, **non** lanciare anche `railway up` (doppio deploy). **Per ora nessuna delle due eseguita.**
✅ Verifica: build NIXPACKS OK, deploy “Success”, `GET /health` → 200 entro 30s (healthcheckTimeout=30).
🛑 STOP: se health non passa → vedi §6 Rollback.

**Step 3.5 — Verifica PUSH MODE = log (STOP gate, §0.1)** — PRIMA della migration
```bash
railway logs | grep -m1 "Push mode:"     # atteso: [Plagit API] Push mode: log
```
✅ Verifica: nei log di boot compare **`[Plagit API] Push mode: log`**.
🛑 STOP IMMEDIATO: se compare **`[Plagit API] Push mode: live`** → **NON** eseguire la migration; rollback / stop deploy (§6). Causa: `PUSH_REAL_ENABLED=true` su Railway (non deve esserlo in N5.6-B → §0.1 punti 7-9).

**Step 4 — Migration su DB di produzione**
```bash
NODE_ENV=production npx knex migrate:latest
# eseguibile come release/one-off command su Railway o via shell del service
```
✅ Verifica: output mostra **applicata solo `055_feed_post_reposts`**. `select * from knex_migrations order by id desc limit 3;` → ultima riga = `055_feed_post_reposts`.
🛑 STOP: qualunque altra migration o errore → §6 Rollback.

---

## 5. Smoke post-deploy in PRODUZIONE (LOG MODE)

- [ ] `GET /health` → 200.
- [ ] Endpoint **notifiche** → risposta valida (nessun 500).
- [ ] Endpoint **conversations** → lista coerente.
- [ ] Login candidate + business reali → OK (401/403 gestiti).
- [ ] **Push**: boot log = **`[Plagit API] Push mode: log`** e i dispatch restano **`[push:log]`** lato server (nessun invio reale; FCM presente ma neutralizzato dal kill-switch `PUSH_REAL_ENABLED` — §0.1).
- [ ] Nessun errore anomalo nei log Railway nei primi minuti.

---

## 6. Rollback plan

**Se il deploy/health fallisce (codice):**
- Railway → **Redeploy della release precedente** (rollback istantaneo del codice). Nessuna modifica al DB se non si è ancora eseguito lo Step 4.

**Se la migration crea problemi (DB):**
```bash
# 055_feed_post_reposts è additiva → down dovrebbe essere pulito:
NODE_ENV=production npx knex migrate:rollback   # rollback ultimo batch (055)
```
- Se il rollback knex non basta o ha effetti collaterali → **restore dal backup nativo Railway** (point-in-time / backup creato allo Step 1).
- **Regola d’oro:** non rilasciare mai senza il backup dello Step 1 verificato.

---

## 7. Fuori scope (decisioni separate, ognuna con GO dedicato)

1. **FCM prod reale (N5.6 originale)** — attivare i push reali agli utenti = **settare `PUSH_REAL_ENABLED=true`** su Railway (FCM è già presente). **NON in N5.6-B** — richiede un **GO separato e dedicato**. In N5.6-B non si tocca: né si rimuove `FCM_SERVICE_ACCOUNT_JSON`, né si setta `PUSH_REAL_ENABLED=true`.
2. **TestFlight** — solo quando Mirko è felice; richiede `aps-environment=production` sulla build release + build bump dei 3 file.
3. **Android push** — `google-services.json` + plugin gradle ancora mancanti.

---

## 8. Sign-off

| Fase | Pre-req | GO Mirko | Eseguita | Esito |
|------|---------|----------|----------|-------|
| Backup prod | — | ☐ | ☐ | |
| Dry-run finale | backup | ☐ | ☐ | |
| Deploy codice | dry-run PASS | ☐ | ☐ | |
| Verifica push mode = log | deploy OK | ☐ | ☐ | |
| Migration prod | push mode = log | ☐ | ☐ | |
| Smoke prod | migration OK | ☐ | ☐ | |

> **Finché tutte le caselle “GO Mirko” non sono spuntate, questo runbook resta solo documentazione.**
