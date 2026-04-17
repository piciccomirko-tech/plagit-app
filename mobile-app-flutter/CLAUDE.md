# Plagit Flutter — Project Rules

## Progetto
- Nome: Plagit — staffing platform (hospitality e tutti i settori)
- Mercati: London, Dubai, Italy
- Bundle ID: com.invain.mh
- Backend: https://plagit-backend-production.up.railway.app/v1
- Backend locale: http://localhost:3000/v1
- Admin panel locale: http://localhost:5173

## Simulatori
- Business: 63C2AAA6
- Admin/Candidate: A83ED19A

## Credenziali seed
- Email: mirko@plagit.com
- Password: admin2026

## Brand Colors
- tealMain: #00B5B0
- tealLight: #5DDDD4
- tealMid: #2BB8B0
- charcoal: #1A1C24
- indigo: #6676F0
- amber: #F59E33
- urgent: #F55748
- gold: #FFD700
- Background gradient: #1e4a52 to #163640
- Mai usare nero puro come sfondo

## Architettura
- State management: GetX — mai setState nei widget principali
- Navigation: go_router con ~90 routes
- Struttura: /screens /controllers /widgets /models /services /constants
- Colori sempre da constants/colors.dart — mai hardcodare hex
- API calls solo nei Controller, mai nei Widget
- Componenti riutilizzabili sempre in /widgets

## Dipendenze critiche
- NON aggiornare mai: intl_phone_field: ^3.2.0
- NON modificare go_router senza verificare tutte le routes

## User Types
- Candidate: cerca lavoro, si candida, gestisce profilo
- Business: cerca staff, prenota, gestisce team
- Admin: gestione piattaforma completa

## Build Bump — Regola dei 3 File
Prima di ogni push bumpa sempre in:
1. pubspec.yaml
2. ios/Runner/Info.plist
3. ios/Runner.xcodeproj/project.pbxproj

## Git
- Push: git push origin responsive:main --force
- Commit format: type(scope): descrizione in inglese
- Mai committare .env, chiavi, certificati

## Aliases disponibili
- plagit-go: avvia il progetto
- plagit-push: bump + commit + push
- plagit-clean: flutter clean + pub get
- plagit-bump: bump build nei 3 file

## Memory
- Leggi MEMORY.md all inizio di ogni sessione
- Aggiorna MEMORY.md alla fine di ogni sessione
- Se MEMORY.md non esiste, crealo subito

## Lingue supportate
Immediato: English (en), Italian (it), Arabic (ar)
Futuro: Hindi, Urdu, Spanish, Portuguese, Tagalog, French, Polish, Bengali
- Arabic usa RTL — verifica sempre il layout
- Stringhe UI sempre nei file ARB, mai hardcodate

## Regole assolute
- 0 errori flutter analyze prima di ogni push
- Mai rompere funzionalita esistenti per aggiungere nuove
- Mai lasciare l app in stato che non compila
- Dopo ogni task: riepilogo in italiano con fatto / problemi / prossimo passo
