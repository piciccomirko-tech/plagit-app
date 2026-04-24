// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Plagit';

  @override
  String get welcome => 'Benvenuto';

  @override
  String get signIn => 'Accedi';

  @override
  String get signUp => 'Registrati';

  @override
  String get createAccount => 'Crea Account';

  @override
  String get createBusinessAccount => 'Crea Account Azienda';

  @override
  String get alreadyHaveAccount => 'Hai già un account?';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get continueLabel => 'Continua';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get done => 'Fatto';

  @override
  String get retry => 'Riprova';

  @override
  String get search => 'Cerca';

  @override
  String get back => 'Indietro';

  @override
  String get next => 'Avanti';

  @override
  String get apply => 'Applica';

  @override
  String get clear => 'Cancella';

  @override
  String get clearAll => 'Cancella tutto';

  @override
  String get edit => 'Modifica';

  @override
  String get delete => 'Elimina';

  @override
  String get confirm => 'Conferma';

  @override
  String get home => 'Home';

  @override
  String get jobs => 'Lavori';

  @override
  String get messages => 'Messaggi';

  @override
  String get profile => 'Profilo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get logout => 'Esci';

  @override
  String get categoryAndRole => 'Categoria e Ruolo';

  @override
  String get selectCategory => 'Seleziona Categoria';

  @override
  String get subcategory => 'Sottocategoria';

  @override
  String get role => 'Ruolo';

  @override
  String get recentSearches => 'Ricerche recenti';

  @override
  String noResultsFor(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get mostPopular => 'Più popolari';

  @override
  String get allCategories => 'Tutte le categorie';

  @override
  String get selectVenueTypeAndRole => 'Seleziona tipo di locale e ruolo';

  @override
  String get selectCategoryAndRole => 'Seleziona categoria e ruolo';

  @override
  String get businessDetails => 'Dettagli Azienda';

  @override
  String get yourDetails => 'I tuoi dati';

  @override
  String get companyName => 'Nome Azienda';

  @override
  String get contactPerson => 'Persona di contatto';

  @override
  String get location => 'Località';

  @override
  String get website => 'Sito web';

  @override
  String get fullName => 'Nome completo';

  @override
  String get yearsExperience => 'Anni di esperienza';

  @override
  String get languagesSpoken => 'Lingue parlate';

  @override
  String get jobType => 'Tipo di lavoro';

  @override
  String get jobTypeFullTime => 'Tempo pieno';

  @override
  String get jobTypePartTime => 'Tempo parziale';

  @override
  String get jobTypeTemporary => 'Temporaneo';

  @override
  String get jobTypeFreelance => 'Freelance';

  @override
  String get openToInternational => 'Aperto a candidati internazionali';

  @override
  String get passwordHint => 'Password (min 8 caratteri)';

  @override
  String get termsOfServiceNote => 'Creando un account accetti i nostri Termini di servizio e la Privacy.';

  @override
  String get networkError => 'Errore di rete';

  @override
  String get somethingWentWrong => 'Qualcosa è andato storto';

  @override
  String get loading => 'Caricamento…';

  @override
  String get errorGeneric => 'Si è verificato un errore imprevisto. Riprova.';

  @override
  String get joinAsCandidate => 'Unisciti come Candidato';

  @override
  String get joinAsBusiness => 'Unisciti come Azienda';

  @override
  String get findYourNextRole => 'Trova il tuo prossimo ruolo nell\'ospitalità';

  @override
  String get candidateLoginSubtitle => 'Connettiti con i migliori datori di lavoro a Londra, Dubai e oltre.';

  @override
  String get businessLoginSubtitle => 'Raggiungi i migliori talenti dell\'ospitalità e fai crescere il tuo team.';

  @override
  String get rememberMe => 'Ricordami';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get lookingForStaff => 'Cerchi personale? ';

  @override
  String get lookingForJob => 'Cerchi lavoro? ';

  @override
  String get switchToBusiness => 'Passa ad Azienda';

  @override
  String get switchToCandidate => 'Passa a Candidato';

  @override
  String get createYourProfile => 'Crea il tuo profilo e fatti scoprire dai migliori datori di lavoro.';

  @override
  String get createBusinessProfile => 'Crea il profilo della tua azienda e inizia ad assumere i migliori talenti.';

  @override
  String get locationCityCountry => 'Località (città, paese)';

  @override
  String get termsAgreement => 'Creando un account accetti i nostri Termini di servizio e la Privacy.';

  @override
  String get searchHospitalityHint => 'Cerca categoria, sottocategoria o ruolo…';

  @override
  String get mostCommonRoles => 'Ruoli più comuni';

  @override
  String get allRoles => 'Tutti i ruoli';

  @override
  String suggestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggerimenti',
      one: '1 suggerimento',
    );
    return '$_temp0';
  }

  @override
  String subcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sottocategorie',
      one: '1 sottocategoria',
    );
    return '$_temp0';
  }

  @override
  String rolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ruoli',
      one: '1 ruolo',
    );
    return '$_temp0';
  }

  @override
  String get kindCategory => 'Categoria';

  @override
  String get kindSubcategory => 'Sottocategoria';

  @override
  String get kindRole => 'Ruolo';

  @override
  String get resetPassword => 'Reimposta password';

  @override
  String get forgotPasswordSubtitle => 'Inserisci la tua email e ti invieremo un link per reimpostare la password.';

  @override
  String get sendResetLink => 'Invia link di reset';

  @override
  String get resetEmailSent => 'Se esiste un account per questa email, il link di reset è stato inviato.';

  @override
  String get profileSetupTitle => 'Completa il tuo profilo';

  @override
  String get profileSetupSubtitle => 'Un profilo completo viene scoperto più velocemente.';

  @override
  String get uploadPhoto => 'Carica foto';

  @override
  String get uploadCV => 'Carica CV';

  @override
  String get skipForNow => 'Salta per ora';

  @override
  String get finish => 'Fine';

  @override
  String get noInternet => 'Nessuna connessione. Controlla la rete.';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get emptyJobs => 'Ancora nessun lavoro';

  @override
  String get emptyApplications => 'Ancora nessuna candidatura';

  @override
  String get emptyMessages => 'Ancora nessun messaggio';

  @override
  String get emptyNotifications => 'Sei aggiornato';

  @override
  String get onboardingRoleTitle => 'Che ruolo stai cercando?';

  @override
  String get onboardingRoleSubtitle => 'Seleziona tutti quelli rilevanti';

  @override
  String get onboardingExperienceTitle => 'Quanta esperienza hai?';

  @override
  String get onboardingLocationTitle => 'Dove ti trovi?';

  @override
  String get onboardingLocationHint => 'Inserisci città o CAP';

  @override
  String get useMyCurrentLocation => 'Usa la mia posizione';

  @override
  String get onboardingAvailabilityTitle => 'Cosa stai cercando?';

  @override
  String get finishSetup => 'Completa configurazione';

  @override
  String get goodMorning => 'Buongiorno';

  @override
  String get goodAfternoon => 'Buon pomeriggio';

  @override
  String get goodEvening => 'Buonasera';

  @override
  String get findJobs => 'Trova lavori';

  @override
  String get applications => 'Candidature';

  @override
  String get community => 'Community';

  @override
  String get recommendedForYou => 'Consigliati per te';

  @override
  String get seeAll => 'Vedi tutto';

  @override
  String get searchJobsHint => 'Cerca lavori, ruoli, località…';

  @override
  String get searchJobs => 'Cerca lavori';

  @override
  String get postedJob => 'Pubblicato';

  @override
  String get applyNow => 'Candidati ora';

  @override
  String get applied => 'Candidato';

  @override
  String get saveJob => 'Salva';

  @override
  String get saved => 'Salvato';

  @override
  String get jobDescription => 'Descrizione';

  @override
  String get requirements => 'Requisiti';

  @override
  String get benefits => 'Benefit';

  @override
  String get salary => 'Stipendio';

  @override
  String get contract => 'Contratto';

  @override
  String get schedule => 'Orario';

  @override
  String get viewCompany => 'Vedi azienda';

  @override
  String get interview => 'Colloquio';

  @override
  String get interviews => 'Colloqui';

  @override
  String get notifications => 'Notifiche';

  @override
  String get matches => 'Match';

  @override
  String get quickPlug => 'Quick Plug';

  @override
  String get discover => 'Scopri';

  @override
  String get shortlist => 'Shortlist';

  @override
  String get message => 'Messaggio';

  @override
  String get messageCandidate => 'Messaggia';

  @override
  String get nextInterview => 'Prossimo colloquio';

  @override
  String get loadingDashboard => 'Caricamento dashboard…';

  @override
  String get tryAgainCta => 'Riprova';

  @override
  String get careerDashboard => 'CARRIERA';

  @override
  String get yourNextInterview => 'Il tuo prossimo colloquio\nè in programma';

  @override
  String get yourCareerTakingOff => 'La tua carriera\nsta decollando';

  @override
  String get yourCareerOnTheMove => 'La tua carriera\nè in movimento';

  @override
  String get yourJourneyStartsHere => 'Il tuo percorso\ninizia qui';

  @override
  String get applyFirstJob => 'Candidati al tuo primo lavoro per iniziare';

  @override
  String get interviewComingUp => 'Colloquio in arrivo';

  @override
  String get unlockPlagitPremium => 'Sblocca Plagit Premium';

  @override
  String get premiumSubtitle => 'Fatti notare dai migliori locali — match più veloci';

  @override
  String get premiumActive => 'Premium Attivo';

  @override
  String get premiumActiveSubtitle => 'Visibilità prioritaria · Gestisci piano';

  @override
  String get noJobsFound => 'Nessun lavoro corrisponde alla ricerca';

  @override
  String get noApplicationsYet => 'Ancora nessuna candidatura';

  @override
  String get startApplying => 'Esplora i lavori per candidarti';

  @override
  String get noMessagesYet => 'Ancora nessun messaggio';

  @override
  String get allCaughtUp => 'Sei aggiornato';

  @override
  String get noNotificationsYet => 'Ancora nessuna notifica';

  @override
  String get about => 'Info';

  @override
  String get experience => 'Esperienza';

  @override
  String get skills => 'Competenze';

  @override
  String get languages => 'Lingue';

  @override
  String get availability => 'Disponibilità';

  @override
  String get verified => 'Verificato';

  @override
  String get totalViews => 'Visualizzazioni totali';

  @override
  String get verifiedVenuePrefix => 'Verificato';

  @override
  String get notVerified => 'Non verificato';

  @override
  String get pendingReview => 'In attesa di verifica';

  @override
  String get viewProfile => 'Vedi profilo';

  @override
  String get editProfile => 'Modifica profilo';

  @override
  String get share => 'Condividi';

  @override
  String get report => 'Segnala';

  @override
  String get block => 'Blocca';

  @override
  String get typeMessage => 'Scrivi un messaggio…';

  @override
  String get send => 'Invia';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get now => 'ora';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min fa',
      one: '1 min fa',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h fa',
      one: '1 h fa',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count g fa',
      one: '1 g fa',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filtri';

  @override
  String get refineSearch => 'Affina ricerca';

  @override
  String get distance => 'Distanza';

  @override
  String get applyFilters => 'Applica filtri';

  @override
  String get reset => 'Reimposta';

  @override
  String noResultsTitle(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get noResultsSubtitle => 'Prova con un\'altra parola chiave o cancella la ricerca.';

  @override
  String get recentSearchesEmptyTitle => 'Nessuna ricerca recente';

  @override
  String get recentSearchesEmptyHint => 'Le tue ricerche recenti appariranno qui';

  @override
  String get allJobs => 'Tutti i lavori';

  @override
  String get nearby => 'Vicino a te';

  @override
  String get saved2 => 'Salvati';

  @override
  String get remote => 'Remoto';

  @override
  String get inPerson => 'In presenza';

  @override
  String get aboutTheJob => 'Sul lavoro';

  @override
  String get aboutCompany => 'Sull\'azienda';

  @override
  String get applyForJob => 'Candidati a questo lavoro';

  @override
  String get unsaveJob => 'Rimuovi';

  @override
  String get noJobsNearby => 'Nessun lavoro nelle vicinanze';

  @override
  String get noSavedJobs => 'Nessun lavoro salvato';

  @override
  String get adjustFilters => 'Modifica i filtri per vedere più lavori';

  @override
  String get fullTime => 'Tempo pieno';

  @override
  String get partTime => 'Tempo parziale';

  @override
  String get temporary => 'Temporaneo';

  @override
  String get freelance => 'Freelance';

  @override
  String postedAgo(String time) {
    return 'Pubblicato $time';
  }

  @override
  String kmAway(String km) {
    return 'a $km km';
  }

  @override
  String get jobDetails => 'Dettagli lavoro';

  @override
  String get aboutThisRole => 'Su questo ruolo';

  @override
  String get aboutTheBusiness => 'Sull\'azienda';

  @override
  String get urgentHiring => 'Assunzione urgente';

  @override
  String get distanceRadius => 'Raggio distanza';

  @override
  String get contractType => 'Tipo contratto';

  @override
  String get shiftType => 'Tipo turno';

  @override
  String get all => 'Tutti';

  @override
  String get casual => 'Occasionale';

  @override
  String get seasonal => 'Stagionale';

  @override
  String get morning => 'Mattina';

  @override
  String get afternoon => 'Pomeriggio';

  @override
  String get evening => 'Sera';

  @override
  String get night => 'Notte';

  @override
  String get startDate => 'Data di inizio';

  @override
  String get shiftHours => 'Orario turno';

  @override
  String get category => 'Categoria';

  @override
  String get venueType => 'Tipo di locale';

  @override
  String get employment => 'Contratto';

  @override
  String get pay => 'Retribuzione';

  @override
  String get duration => 'Durata';

  @override
  String get weeklyHours => 'Ore settimanali';

  @override
  String get businessLocation => 'Sede azienda';

  @override
  String get jobViews => 'Visualizzazioni';

  @override
  String positions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Posizioni',
      one: '1 Posizione',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesi',
      one: '1 mese',
    );
    return '$_temp0';
  }

  @override
  String get myApplications => 'Le mie candidature';

  @override
  String get active => 'Attive';

  @override
  String get interviewStatus => 'Colloquio';

  @override
  String get rejected => 'Rifiutate';

  @override
  String get offer => 'Offerta';

  @override
  String appliedOn(String date) {
    return 'Inviata $date';
  }

  @override
  String get viewJob => 'Vedi lavoro';

  @override
  String get withdraw => 'Ritira candidatura';

  @override
  String get applicationStatus => 'Stato candidatura';

  @override
  String get noConversations => 'Nessuna conversazione';

  @override
  String get startConversation => 'Rispondi a un lavoro per iniziare a chattare';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String lastSeen(String time) {
    return 'Ultimo accesso $time';
  }

  @override
  String get newNotification => 'Nuovo';

  @override
  String get markAllRead => 'Segna tutto come letto';

  @override
  String get yourProfile => 'Il tuo profilo';

  @override
  String completionPercent(int percent) {
    return '$percent% completo';
  }

  @override
  String get personalDetails => 'Dati personali';

  @override
  String get phone => 'Telefono';

  @override
  String get bio => 'Bio';

  @override
  String get addPhoto => 'Aggiungi foto';

  @override
  String get addCV => 'Aggiungi CV';

  @override
  String get saveChanges => 'Salva modifiche';

  @override
  String get logoutConfirm => 'Sicuro di voler uscire?';

  @override
  String get subscription => 'Abbonamento';

  @override
  String get support => 'Supporto';

  @override
  String get privacy => 'Privacy';

  @override
  String get terms => 'Termini';

  @override
  String get applicationDetails => 'Dettagli candidatura';

  @override
  String get timeline => 'Cronologia';

  @override
  String get submitted => 'Inviata';

  @override
  String get underReview => 'In valutazione';

  @override
  String get interviewScheduled => 'Colloquio fissato';

  @override
  String get offerExtended => 'Offerta inviata';

  @override
  String get withdrawApp => 'Ritira candidatura';

  @override
  String get withdrawConfirm => 'Sicuro di voler ritirare questa candidatura?';

  @override
  String get applicationWithdrawn => 'Candidatura ritirata';

  @override
  String get statusApplied => 'Inviata';

  @override
  String get statusInReview => 'In valutazione';

  @override
  String get statusInterview => 'Colloquio';

  @override
  String get statusHired => 'Assunto';

  @override
  String get statusClosed => 'Chiusa';

  @override
  String get statusRejected => 'Rifiutata';

  @override
  String get statusOffer => 'Offerta';

  @override
  String get messagesSearch => 'Cerca messaggi…';

  @override
  String get noMessagesTitle => 'Nessun messaggio';

  @override
  String get noMessagesSubtitle => 'Rispondi a un lavoro per iniziare a chattare';

  @override
  String get youOnline => 'Sei online';

  @override
  String get noNotificationsTitle => 'Nessuna notifica';

  @override
  String get noNotificationsSubtitle => 'Ti avviseremo quando succede qualcosa';

  @override
  String get today2 => 'Oggi';

  @override
  String get earlier => 'Precedenti';

  @override
  String get completeYourProfile => 'Completa il tuo profilo';

  @override
  String get profileCompletion => 'Completamento profilo';

  @override
  String get personalInfo => 'Dati personali';

  @override
  String get professional => 'Professionale';

  @override
  String get preferences => 'Preferenze';

  @override
  String get documents => 'Documenti';

  @override
  String get myCV => 'Il mio CV';

  @override
  String get premium => 'Premium';

  @override
  String get addLanguages => 'Aggiungi lingue';

  @override
  String get addExperience => 'Aggiungi esperienza';

  @override
  String get addAvailability => 'Aggiungi disponibilità';

  @override
  String get matchesTitle => 'I tuoi match';

  @override
  String get noMatchesTitle => 'Ancora nessun match';

  @override
  String get noMatchesSubtitle => 'Continua a candidarti — i tuoi match appariranno qui';

  @override
  String get interestedBusinesses => 'Aziende interessate';

  @override
  String get accept => 'Accetta';

  @override
  String get decline => 'Rifiuta';

  @override
  String get newMatch => 'Nuovo match';

  @override
  String get quickPlugTitle => 'Quick Plug';

  @override
  String get quickPlugEmpty => 'Nessuna nuova azienda al momento';

  @override
  String get quickPlugSubtitle => 'Torna più tardi per nuove opportunità';

  @override
  String get uploadYourCV => 'Carica il tuo CV';

  @override
  String get cvSubtitle => 'Aggiungi un CV per candidarti più velocemente';

  @override
  String get chooseFile => 'Scegli file';

  @override
  String get removeCV => 'Rimuovi CV';

  @override
  String get noCVUploaded => 'Nessun CV caricato';

  @override
  String get discoverCompanies => 'Scopri aziende';

  @override
  String get exploreSubtitle => 'Esplora le migliori aziende dell\'ospitalità';

  @override
  String get follow => 'Segui';

  @override
  String get following => 'Seguito';

  @override
  String get view => 'Vedi';

  @override
  String get selectLanguages => 'Seleziona lingue';

  @override
  String selectedCount(int count) {
    return '$count selezionate';
  }

  @override
  String get allLanguages => 'Tutte le lingue';

  @override
  String get uploadCVBig => 'Carica il tuo CV per pre-compilare il profilo automaticamente.';

  @override
  String get supportedFormats => 'Formati supportati: PDF, DOC, DOCX';

  @override
  String get fillManually => 'Compila a mano';

  @override
  String get fillManuallySubtitle => 'Inserisci i tuoi dati e completa il profilo passo dopo passo.';

  @override
  String get photoUploadSoon => 'Caricamento foto in arrivo — usa un avatar professionale per ora.';

  @override
  String get yourCV => 'Il tuo CV';

  @override
  String get aboutYou => 'Su di te';

  @override
  String get optional => 'Facoltativo';

  @override
  String get completeProfile => 'Completa il profilo';

  @override
  String get openToRelocation => 'Disponibile a trasferirsi';

  @override
  String get matchLabel => 'Match';

  @override
  String get accepted => 'Accettato';

  @override
  String get deny => 'Rifiuta';

  @override
  String get featured => 'In evidenza';

  @override
  String get reviewYourProfile => 'Rivedi il tuo profilo';

  @override
  String get nothingSavedYet => 'Nulla verrà salvato finché non confermi.';

  @override
  String get editAnyField => 'Puoi modificare qualsiasi campo prima di salvare.';

  @override
  String get saveToProfile => 'Salva sul profilo';

  @override
  String get findCompanies => 'Trova aziende';

  @override
  String get mapView => 'Mappa';

  @override
  String get mapComingSoon => 'La mappa arriverà presto.';

  @override
  String get noCompaniesFound => 'Nessuna azienda trovata';

  @override
  String get tryWiderRadius => 'Prova un raggio più ampio o un\'altra categoria.';

  @override
  String get verifiedOnly => 'Solo verificate';

  @override
  String get resetFilters => 'Reimposta filtri';

  @override
  String get available => 'Disponibile';

  @override
  String lookingFor(String role) {
    return 'Cerca: $role';
  }

  @override
  String get boostMyProfile => 'Promuovi il mio profilo';

  @override
  String get openToRelocationTravel => 'Disponibile a trasferirsi / viaggiare';

  @override
  String get tellEmployersAboutYourself => 'Racconta ai datori di lavoro chi sei…';

  @override
  String get profileUpdated => 'Profilo aggiornato';

  @override
  String get contractPreference => 'Preferenza contratto';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get languagePickerSoon => 'Selettore lingua in arrivo';

  @override
  String get selectCategoryRoleShort => 'Seleziona categoria e ruolo';

  @override
  String get cvUploadSoon => 'Caricamento CV in arrivo';

  @override
  String get restorePurchasesSoon => 'Ripristino acquisti in arrivo';

  @override
  String get photoUploadShort => 'Caricamento foto in arrivo';

  @override
  String get hireBestTalent => 'Assumi i migliori talenti dell\'ospitalità';

  @override
  String get businessLoginSub => 'Pubblica annunci e connetti con candidati verificati.';

  @override
  String get lookingForWork => 'Cerchi lavoro? ';

  @override
  String get postJob => 'Pubblica annuncio';

  @override
  String get editJob => 'Modifica annuncio';

  @override
  String get jobTitle => 'Titolo del lavoro';

  @override
  String get jobDescription2 => 'Descrizione';

  @override
  String get publish => 'Pubblica';

  @override
  String get saveDraft => 'Salva bozza';

  @override
  String get applicantsTitle => 'Candidati';

  @override
  String get newApplicants => 'Nuovi candidati';

  @override
  String get noApplicantsYet => 'Ancora nessun candidato';

  @override
  String get noApplicantsSubtitle => 'I candidati appariranno qui dopo aver fatto domanda.';

  @override
  String get scheduleInterview => 'Pianifica colloquio';

  @override
  String get sendInvite => 'Invia invito';

  @override
  String get interviewSent => 'Invito al colloquio inviato';

  @override
  String get rejectCandidate => 'Rifiuta';

  @override
  String get shortlistCandidate => 'Aggiungi alla shortlist';

  @override
  String get hiringDashboard => 'DASHBOARD ASSUNZIONI';

  @override
  String get yourPipelineActive => 'La tua pipeline\nè attiva';

  @override
  String get postJobToStart => 'Pubblica un annuncio per iniziare';

  @override
  String reviewApplicants(int count) {
    return 'Rivedi $count nuovi candidati';
  }

  @override
  String replyMessages(int count) {
    return 'Rispondi a $count messaggi non letti';
  }

  @override
  String get interviews2 => 'Colloqui';

  @override
  String get businessProfile => 'Profilo azienda';

  @override
  String get venueGallery => 'Galleria locale';

  @override
  String get addPhotos => 'Aggiungi foto';

  @override
  String get businessName => 'Nome attività';

  @override
  String get venueTypeLabel => 'Tipo di locale';

  @override
  String selectedItems(int count) {
    return '$count selezionati';
  }

  @override
  String get hiringProgress => 'Progresso assunzioni';

  @override
  String get unlockBusinessPremium => 'Sblocca Business Premium';

  @override
  String get businessPremiumSubtitle => 'Accesso prioritario ai migliori candidati';

  @override
  String get scheduleFromApplicants => 'Pianifica dai candidati';

  @override
  String get recentApplicants => 'Candidati recenti';

  @override
  String get viewAll => 'Vedi tutti ›';

  @override
  String get recentActivity => 'Attività recente';

  @override
  String get candidatePipeline => 'Pipeline candidati';

  @override
  String get allApplicants => 'Tutti i candidati';

  @override
  String get searchCandidates => 'Cerca candidati, lavori, colloqui...';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get thisMonth => 'Questo mese';

  @override
  String get allTime => 'Sempre';

  @override
  String get post => 'Pubblica';

  @override
  String get candidates => 'Candidati';

  @override
  String get applicantDetail => 'Dettagli candidato';

  @override
  String get candidateProfile => 'Profilo candidato';

  @override
  String get shortlistTitle => 'Shortlist';

  @override
  String get noShortlistedCandidates => 'Nessun candidato in shortlist';

  @override
  String get shortlistEmpty => 'I candidati in shortlist appariranno qui';

  @override
  String get removeFromShortlist => 'Rimuovi dalla shortlist';

  @override
  String get viewMessages => 'Vedi messaggi';

  @override
  String get manageJobs => 'Gestisci lavori';

  @override
  String get yourJobs => 'I tuoi lavori';

  @override
  String get noJobsPosted => 'Nessun lavoro pubblicato';

  @override
  String get noJobsPostedSubtitle => 'Pubblica il primo lavoro per iniziare';

  @override
  String get draftJobs => 'Bozze';

  @override
  String get activeJobs => 'Attivi';

  @override
  String get expiredJobs => 'Scaduti';

  @override
  String get closedJobs => 'Chiusi';

  @override
  String get createJob => 'Crea lavoro';

  @override
  String get jobDetailsTitle => 'Dettagli lavoro';

  @override
  String get salaryRange => 'Range stipendio';

  @override
  String get currency => 'Valuta';

  @override
  String get monthly => 'Mensile';

  @override
  String get annual => 'Annuale';

  @override
  String get hourly => 'Orario';

  @override
  String get minSalary => 'Min';

  @override
  String get maxSalary => 'Max';

  @override
  String get perks => 'Benefit';

  @override
  String get addPerk => 'Aggiungi benefit';

  @override
  String get remove => 'Rimuovi';

  @override
  String get preview => 'Anteprima';

  @override
  String get publishJob => 'Pubblica lavoro';

  @override
  String get jobPublished => 'Lavoro pubblicato';

  @override
  String get jobUpdated => 'Lavoro aggiornato';

  @override
  String get jobSavedDraft => 'Salvato come bozza';

  @override
  String get fillRequired => 'Compila i campi obbligatori';

  @override
  String get jobUrgent => 'Segna come urgente';

  @override
  String get addAtLeastOne => 'Aggiungi almeno un requisito';

  @override
  String get createUpdate => 'Crea aggiornamento';

  @override
  String get shareCompanyNews => 'Condividi le novità dell\'azienda';

  @override
  String get addStory => 'Aggiungi storia';

  @override
  String get showWorkplace => 'Mostra il tuo locale';

  @override
  String get viewShortlist => 'Vedi shortlist';

  @override
  String get yourSavedCandidates => 'I tuoi candidati salvati';

  @override
  String get inviteCandidate => 'Invita candidato';

  @override
  String get reachOutDirectly => 'Contatta direttamente';

  @override
  String activeJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count annunci attivi',
      one: '1 annuncio attivo',
    );
    return '$_temp0';
  }

  @override
  String get employmentType => 'Tipo di contratto';

  @override
  String get requiredRole => 'Ruolo richiesto';

  @override
  String get selectCategoryRole2 => 'Seleziona categoria e ruolo';

  @override
  String get hiresNeeded => 'Assunzioni necessarie';

  @override
  String get compensation => 'Retribuzione';

  @override
  String get useSalaryRange => 'Usa range stipendio';

  @override
  String get contractDuration => 'Durata contratto';

  @override
  String get limitReached => 'Limite raggiunto';

  @override
  String get upgradePlan => 'Aggiorna piano';

  @override
  String usingXofY(int used, int total) {
    return 'Stai usando $used di $total annunci.';
  }

  @override
  String get businessInterviewsTitle => 'Colloqui';

  @override
  String get noInterviewsYet => 'Nessun colloquio pianificato';

  @override
  String get scheduleFirstInterview => 'Pianifica il primo colloquio con un candidato';

  @override
  String get sendInterviewInvite => 'Invia invito al colloquio';

  @override
  String get interviewSentTitle => 'Invito inviato!';

  @override
  String get interviewSentSubtitle => 'Il candidato è stato avvisato.';

  @override
  String get scheduleInterviewTitle => 'Pianifica colloquio';

  @override
  String get interviewType => 'Tipo di colloquio';

  @override
  String get inPersonInterview => 'In presenza';

  @override
  String get videoCallInterview => 'Videochiamata';

  @override
  String get phoneCallInterview => 'Telefonata';

  @override
  String get interviewDate => 'Data';

  @override
  String get interviewTime => 'Ora';

  @override
  String get interviewLocation => 'Luogo';

  @override
  String get interviewNotes => 'Note';

  @override
  String get optionalLabel => 'Facoltativo';

  @override
  String get sendInviteCta => 'Invia invito';

  @override
  String messagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi',
      one: '1 messaggio',
    );
    return '$_temp0';
  }

  @override
  String get noNewMessages => 'Nessun nuovo messaggio';

  @override
  String get subscriptionTitle => 'Abbonamento';

  @override
  String get currentPlan => 'Piano attuale';

  @override
  String get manage => 'Gestisci';

  @override
  String get upgrade => 'Aggiorna';

  @override
  String get renewalDate => 'Data di rinnovo';

  @override
  String get nearbyTalent => 'Talenti nelle vicinanze';

  @override
  String get searchNearby => 'Cerca vicino';

  @override
  String get communityTitle => 'Community';

  @override
  String get createPost => 'Crea post';

  @override
  String get insights => 'Statistiche';

  @override
  String get viewsLabel => 'Visualizzazioni';

  @override
  String get applicationsLabel => 'Candidature';

  @override
  String get conversionRate => 'Tasso conversione';

  @override
  String get topPerformingJob => 'Annuncio top';

  @override
  String get viewAllSimple => 'Vedi tutti';

  @override
  String get viewAllApplicantsForJob => 'Vedi tutti i candidati per questo lavoro';

  @override
  String get noUpcomingInterviews => 'Nessun colloquio in arrivo';

  @override
  String get noActivityYet => 'Ancora nessuna attività';

  @override
  String get noResultsFound => 'Nessun risultato';

  @override
  String get renewsAutomatically => 'Si rinnova automaticamente';

  @override
  String get plagitBusinessPlans => 'Piani Plagit Business';

  @override
  String get scaleYourHiringSubtitle => 'Fai crescere le tue assunzioni con il piano giusto per la tua azienda.';

  @override
  String get yearly => 'Annuale';

  @override
  String get saveWithAnnualBilling => 'Risparmia con la fatturazione annuale';

  @override
  String get chooseYourPlanSubtitle => 'Scegli il piano che si adatta alle tue esigenze di recruiting.';

  @override
  String continueWithPlan(String plan) {
    return 'Continua con $plan';
  }

  @override
  String get subscriptionAutoRenewNote => 'L\'abbonamento si rinnova automaticamente. Disdici in qualsiasi momento nelle Impostazioni.';

  @override
  String get purchaseFlowComingSoon => 'Acquisto disponibile a breve';

  @override
  String get applicant => 'Candidato';

  @override
  String get applicantNotFound => 'Candidato non trovato';

  @override
  String get cvViewerComingSoon => 'Visualizzatore CV disponibile a breve';

  @override
  String get viewCV => 'Vedi CV';

  @override
  String get application => 'Candidatura';

  @override
  String get messagingComingSoon => 'Messaggistica disponibile a breve';

  @override
  String get interviewConfirmed => 'Colloquio confermato';

  @override
  String get interviewMarkedCompleted => 'Colloquio segnato come completato';

  @override
  String get cancelInterviewConfirm => 'Sei sicuro di voler annullare questo colloquio?';

  @override
  String get yesCancel => 'Sì, annulla';

  @override
  String get interviewNotFound => 'Colloquio non trovato';

  @override
  String get openingMeetingLink => 'Apertura link riunione...';

  @override
  String get rescheduleComingSoon => 'Riprogrammazione disponibile a breve';

  @override
  String get notesFeatureComingSoon => 'Funzione note disponibile a breve';

  @override
  String get candidateMarkedHired => 'Candidato segnato come assunto!';

  @override
  String get feedbackComingSoon => 'Feedback disponibile a breve';

  @override
  String get googleMapsComingSoon => 'Integrazione Google Maps disponibile a breve';

  @override
  String get noCandidatesNearby => 'Nessun candidato nelle vicinanze';

  @override
  String get tryExpandingRadius => 'Prova ad ampliare il raggio di ricerca.';

  @override
  String get candidate => 'Candidato';

  @override
  String get forOpenPosition => 'Per posizione aperta';

  @override
  String get dateAndTimeUpper => 'DATA E ORA';

  @override
  String get interviewTypeUpper => 'TIPO COLLOQUIO';

  @override
  String get timezoneUpper => 'FUSO ORARIO';

  @override
  String get highlights => 'In evidenza';

  @override
  String get cvNotAvailable => 'CV non disponibile';

  @override
  String get cvWillAppearHere => 'Apparirà qui una volta caricato';

  @override
  String get seenEveryone => 'Hai visto tutti';

  @override
  String get checkBackForCandidates => 'Torna più tardi per nuovi candidati.';

  @override
  String get dailyLimitReached => 'Limite giornaliero raggiunto';

  @override
  String get upgradeForUnlimitedSwipes => 'Aggiorna per swipe illimitati.';

  @override
  String get distanceUpper => 'DISTANZA';

  @override
  String get inviteToInterview => 'Invita al colloquio';

  @override
  String get details => 'Dettagli';

  @override
  String get shortlistedSuccessfully => 'Aggiunto alla shortlist';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabCandidates => 'Candidati';

  @override
  String get tabActivity => 'Attività';

  @override
  String get statusPosted => 'Pubblicato';

  @override
  String get statusApplicants => 'Candidati';

  @override
  String get statusInterviewsShort => 'Colloqui';

  @override
  String get statusHiredShort => 'Assunti';

  @override
  String get jobLiveVisible => 'Il tuo annuncio è online e visibile';

  @override
  String get postJobShort => 'Pubblica';

  @override
  String get messagesTitle => 'Messaggi';

  @override
  String get online2 => 'Online ora';

  @override
  String get candidateUpper => 'CANDIDATO';

  @override
  String get searchConversationsHint => 'Cerca conversazioni, candidati, ruoli…';

  @override
  String get filterUnread => 'Non letti';

  @override
  String get filterAll => 'Tutti';

  @override
  String get whenCandidatesMessage => 'Quando i candidati ti scriveranno, le conversazioni appariranno qui.';

  @override
  String get trySwitchingFilter => 'Prova a cambiare filtro.';

  @override
  String get reply => 'Rispondi';

  @override
  String get selectItems => 'Seleziona elementi';

  @override
  String countSelected(int count) {
    return '$count selezionati';
  }

  @override
  String get selectAll => 'Seleziona tutti';

  @override
  String get deleteConversation => 'Elimina conversazione?';

  @override
  String get deleteAllConversations => 'Elimina tutte le conversazioni?';

  @override
  String get deleteSelectedNote => 'Le chat selezionate saranno rimosse dalla tua casella. Il candidato conserva la sua copia.';

  @override
  String get deleteAll => 'Elimina tutti';

  @override
  String get selectConversations => 'Seleziona conversazioni';

  @override
  String get feedTab => 'Feed';

  @override
  String get myPostsTab => 'I miei post';

  @override
  String get savedTab => 'Salvati';

  @override
  String postingAs(String name) {
    return 'Pubblichi come $name';
  }

  @override
  String get noPostsYet => 'Non hai ancora pubblicato';

  @override
  String get nothingHereYet => 'Niente qui per ora';

  @override
  String get shareVenueUpdate => 'Condividi un aggiornamento dal tuo locale per iniziare a costruire la tua presenza nella community.';

  @override
  String get communityPostsAppearHere => 'I post della community appariranno qui.';

  @override
  String get createFirstPost => 'Crea il primo post';

  @override
  String get yourPostUpper => 'IL TUO POST';

  @override
  String get businessLabel => 'Azienda';

  @override
  String get profileNotAvailable => 'Profilo non disponibile';

  @override
  String get companyProfile => 'Profilo azienda';

  @override
  String get premiumVenue => 'Locale premium';

  @override
  String get businessDetailsTitle => 'Dettagli azienda';

  @override
  String get businessNameLabel => 'Nome azienda';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get locationLabel => 'Località';

  @override
  String get verificationLabel => 'Verifica';

  @override
  String get pendingLabel => 'In attesa';

  @override
  String get notSet => 'Non impostato';

  @override
  String get contactLabel => 'Contatto';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Telefono';

  @override
  String get editProfileTitle => 'Modifica profilo';

  @override
  String get companyNameField => 'Nome azienda';

  @override
  String get phoneField => 'Telefono';

  @override
  String get locationField => 'Località';

  @override
  String get signOut => 'Esci';

  @override
  String get signOutTitle => 'Uscire?';

  @override
  String get signOutConfirm => 'Sei sicuro di voler uscire?';

  @override
  String activeCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attivi',
      one: '1 attivo',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi questa settimana',
      one: '1 nuovo questa settimana',
    );
    return '$_temp0';
  }

  @override
  String get jobStatusActive => 'Attivo';

  @override
  String get jobStatusPaused => 'In pausa';

  @override
  String get jobStatusClosed => 'Chiuso';

  @override
  String get jobStatusDraft => 'Bozza';

  @override
  String get contractCasual => 'Occasionale';

  @override
  String get planBasic => 'Basic';

  @override
  String get planPro => 'Pro';

  @override
  String get planPremium => 'Premium';

  @override
  String get bestForMaxVisibility => 'Ideale per massima visibilità';

  @override
  String saveDollarsPerYear(String currency, String amount) {
    return 'Risparmia $currency$amount/anno';
  }

  @override
  String get planBasicFeature1 => 'Fino a 3 annunci';

  @override
  String get planBasicFeature2 => 'Visualizza profili candidati';

  @override
  String get planBasicFeature3 => 'Ricerca candidati base';

  @override
  String get planBasicFeature4 => 'Supporto email';

  @override
  String get planProFeature1 => 'Fino a 10 annunci';

  @override
  String get planProFeature2 => 'Ricerca candidati avanzata';

  @override
  String get planProFeature3 => 'Ordinamento candidati prioritario';

  @override
  String get planProFeature4 => 'Accesso Quick Plug';

  @override
  String get planProFeature5 => 'Supporto chat';

  @override
  String get planPremiumFeature1 => 'Annunci illimitati';

  @override
  String get planPremiumFeature2 => 'Annunci in evidenza';

  @override
  String get planPremiumFeature3 => 'Analisi avanzate';

  @override
  String get planPremiumFeature4 => 'Quick Plug illimitato';

  @override
  String get planPremiumFeature5 => 'Matching prioritario';

  @override
  String get planPremiumFeature6 => 'Account manager dedicato';

  @override
  String get currentSelectionCheck => 'Selezione attuale ✓';

  @override
  String selectPlanName(String plan) {
    return 'Seleziona $plan';
  }

  @override
  String get perYear => '/anno';

  @override
  String get perMonth => '/mese';

  @override
  String get jobTitleHintExample => 'es. Chef Senior';

  @override
  String get locationHintExample => 'es. Dubai, UAE';

  @override
  String annualSalaryLabel(String currency) {
    return 'Stipendio annuo ($currency)';
  }

  @override
  String monthlyPayLabel(String currency) {
    return 'Paga mensile ($currency)';
  }

  @override
  String hourlyRateLabel(String currency) {
    return 'Tariffa oraria ($currency)';
  }

  @override
  String minSalaryLabel(String currency) {
    return 'Min ($currency)';
  }

  @override
  String maxSalaryLabel(String currency) {
    return 'Max ($currency)';
  }

  @override
  String get hoursPerWeekLabel => 'Ore / settimana';

  @override
  String get expectedHoursWeekLabel => 'Ore previste / settimana (facoltativo)';

  @override
  String get bonusTipsLabel => 'Bonus / Mance (facoltativo)';

  @override
  String get bonusTipsHint => 'es. Mance e servizio';

  @override
  String get housingIncludedLabel => 'Alloggio incluso';

  @override
  String get travelIncludedLabel => 'Viaggio incluso';

  @override
  String get overtimeAvailableLabel => 'Straordinari disponibili';

  @override
  String get flexibleScheduleLabel => 'Orario flessibile';

  @override
  String get weekendShiftsLabel => 'Turni nel weekend';

  @override
  String get describeRoleHint => 'Descrivi il ruolo, le responsabilità e cosa rende speciale questo lavoro...';

  @override
  String get requirementsHint => 'Competenze, esperienza, certificazioni richieste...';

  @override
  String previewPrefix(String text) {
    return 'Anteprima: $text';
  }

  @override
  String monthsShort(int count) {
    return '$count mesi';
  }

  @override
  String get roleAll => 'Tutti';

  @override
  String get roleChef => 'Chef';

  @override
  String get roleWaiter => 'Cameriere';

  @override
  String get roleBartender => 'Barista';

  @override
  String get roleHost => 'Host';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleReception => 'Reception';

  @override
  String get roleKitchenPorter => 'Aiuto cucina';

  @override
  String get roleRelocate => 'Trasferimento';

  @override
  String get experience02Years => '0-2 anni';

  @override
  String get experience35Years => '3-5 anni';

  @override
  String get experience5PlusYears => '5+ anni';

  @override
  String get roleUpper => 'RUOLO';

  @override
  String get experienceUpper => 'ESPERIENZA';

  @override
  String get cvLabel => 'CV';

  @override
  String get addShort => 'Aggiungi';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count foto',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String candidatesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidati trovati',
      one: '1 candidato trovato',
    );
    return '$_temp0';
  }

  @override
  String get maxKmLabel => 'max 50 km';

  @override
  String get shortlistAction => 'Shortlist';

  @override
  String get messageAction => 'Messaggio';

  @override
  String get interviewAction => 'Colloquio';

  @override
  String get viewAction => 'Vedi';

  @override
  String get rejectAction => 'Rifiuta';

  @override
  String get basedIn => 'Residenza';

  @override
  String get verificationPending => 'Verifica in corso';

  @override
  String get refreshAction => 'Aggiorna';

  @override
  String get upgradeAction => 'Passa a Premium';

  @override
  String get searchJobsByTitleHint => 'Cerca per titolo, ruolo o località…';

  @override
  String xShortlisted(String name) {
    return '$name aggiunto alla shortlist';
  }

  @override
  String xRejected(String name) {
    return '$name rifiutato';
  }

  @override
  String rejectConfirmName(String name) {
    return 'Sei sicuro di voler rifiutare $name?';
  }

  @override
  String appliedToRoleOn(String role, String date) {
    return 'Candidato a $role il $date';
  }

  @override
  String appliedDatePrefix(String date) {
    return 'Inviata $date';
  }

  @override
  String get salaryExpectationTitle => 'Stipendio atteso';

  @override
  String get previousEmployer => 'Datore di lavoro precedente';

  @override
  String get earlierVenue => 'Locale precedente';

  @override
  String get presentLabel => 'Attuale';

  @override
  String get skillCustomerService => 'Servizio clienti';

  @override
  String get skillTeamwork => 'Lavoro di squadra';

  @override
  String get skillCommunication => 'Comunicazione';

  @override
  String get stepApplied => 'Candidato';

  @override
  String get stepViewed => 'Visualizzato';

  @override
  String get stepShortlisted => 'In shortlist';

  @override
  String get stepInterviewScheduled => 'Colloquio fissato';

  @override
  String get stepRejected => 'Rifiutato';

  @override
  String get stepUnderReview => 'In valutazione';

  @override
  String get stepPendingReview => 'In attesa di valutazione';

  @override
  String get sortNewest => 'Più recenti';

  @override
  String get sortMostExperienced => 'Più esperti';

  @override
  String get sortBestMatch => 'Miglior match';

  @override
  String get filterApplied => 'Inviata';

  @override
  String get filterUnderReview => 'In valutazione';

  @override
  String get filterShortlisted => 'In shortlist';

  @override
  String get filterInterview => 'Colloquio';

  @override
  String get filterHired => 'Assunti';

  @override
  String get filterRejected => 'Rifiutati';

  @override
  String get confirmed => 'Confermato';

  @override
  String get pending => 'In attesa';

  @override
  String get completed => 'Completato';

  @override
  String get cancelled => 'Annullato';

  @override
  String get videoLabel => 'Video';

  @override
  String get viewDetails => 'Vedi dettagli';

  @override
  String get interviewDetails => 'Dettagli colloquio';

  @override
  String get interviewConfirmedHeadline => 'Colloquio confermato';

  @override
  String get interviewConfirmedSubline => 'È tutto pronto. Ti invieremo un promemoria prima dell\'orario.';

  @override
  String get dateLabel => 'Data';

  @override
  String get timeLabel => 'Ora';

  @override
  String get formatLabel => 'Modalità';

  @override
  String get joinMeeting => 'Partecipa';

  @override
  String get viewJobAction => 'Vedi annuncio';

  @override
  String get addToCalendar => 'Aggiungi al calendario';

  @override
  String get needsYourAttention => 'Richiede la tua attenzione';

  @override
  String get reviewAction => 'Rivedi';

  @override
  String applicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidature',
      one: '1 candidatura',
    );
    return '$_temp0';
  }

  @override
  String get sortMostRecent => 'Più recenti';

  @override
  String get interviewScheduledLabel => 'Colloquio programmato';

  @override
  String get editAction => 'Modifica';

  @override
  String get currentPlanLabel => 'Piano attuale';

  @override
  String get freePlan => 'Piano gratuito';

  @override
  String get profileStrength => 'Forza del profilo';

  @override
  String get detailsLabel => 'Dettagli';

  @override
  String get basedInLabel => 'Residenza';

  @override
  String get verificationLabel2 => 'Verifica';

  @override
  String get contactLabel2 => 'Contatti';

  @override
  String get notSetLabel => 'Non impostato';

  @override
  String get chipAll => 'Tutti';

  @override
  String get chipFullTime => 'Full-time';

  @override
  String get chipPartTime => 'Part-time';

  @override
  String get chipTemporary => 'Temporaneo';

  @override
  String get chipCasual => 'Occasionale';

  @override
  String get sortBestMatchLabel => 'Migliore corrispondenza';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortBy => 'Ordina per';

  @override
  String get featuredBadge => 'In evidenza';

  @override
  String get urgentBadge => 'Urgente';

  @override
  String get salaryOnRequest => 'Stipendio su richiesta';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get urgentJobsOnly => 'Solo lavori urgenti';

  @override
  String get showOnlyUrgentListings => 'Mostra solo annunci urgenti';

  @override
  String get verifiedBusinessesOnly => 'Solo aziende verificate';

  @override
  String get showOnlyVerifiedBusinesses => 'Mostra solo aziende verificate';

  @override
  String get split => 'Misto';

  @override
  String get payUpper => 'PAGA';

  @override
  String get typeUpper => 'TIPO';

  @override
  String get whereUpper => 'DOVE';

  @override
  String get payLabel => 'Paga';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get whereLabel => 'Dove';

  @override
  String get whereYouWillWork => 'Dove lavorerai';

  @override
  String get mapPreviewDirections => 'Anteprima mappa · apri per indicazioni complete';

  @override
  String get directionsAction => 'Indicazioni';

  @override
  String get communityTabForYou => 'Per te';

  @override
  String get communityTabFollowing => 'Seguiti';

  @override
  String get communityTabNearby => 'Vicini';

  @override
  String get communityTabSaved => 'Salvati';

  @override
  String get viewProfileAction => 'Vedi profilo';

  @override
  String get copyLinkAction => 'Copia link';

  @override
  String get savePostAction => 'Salva post';

  @override
  String get unsavePostAction => 'Rimuovi dai salvati';

  @override
  String get hideThisPost => 'Nascondi questo post';

  @override
  String get reportPost => 'Segnala post';

  @override
  String get cancelAction => 'Annulla';

  @override
  String get newPostTitle => 'Nuovo post';

  @override
  String get youLabel => 'Tu';

  @override
  String get postingToCommunityAsBusiness => 'Stai pubblicando nella community come Azienda';

  @override
  String get postingToCommunityAsPro => 'Stai pubblicando nella community come Hospitality Pro';

  @override
  String get whatsOnYourMind => 'A cosa stai pensando?';

  @override
  String get publishAction => 'Pubblica';

  @override
  String get attachmentPhoto => 'Foto';

  @override
  String get attachmentVideo => 'Video';

  @override
  String get attachmentLocation => 'Posizione';

  @override
  String get boostMyProfileCta => 'Potenzia il mio profilo';

  @override
  String get unlockYourFullPotential => 'Sblocca il tuo pieno potenziale';

  @override
  String get annualPlan => 'Annuale';

  @override
  String get monthlyPlan => 'Mensile';

  @override
  String get bestValueBadge => 'MIGLIORE OFFERTA';

  @override
  String get whatsIncluded => 'Cosa è incluso';

  @override
  String get continueWithAnnual => 'Continua con Annuale';

  @override
  String get continueWithMonthly => 'Continua con Mensile';

  @override
  String get maybeLater => 'Forse più tardi';

  @override
  String get restorePurchasesLabel => 'Ripristina acquisti';

  @override
  String get subscriptionAutoRenewsNote => 'L\'abbonamento si rinnova automaticamente. Annulla in qualsiasi momento nelle Impostazioni.';

  @override
  String get appStatusPillApplied => 'Candidato';

  @override
  String get appStatusPillUnderReview => 'In revisione';

  @override
  String get appStatusPillShortlisted => 'In shortlist';

  @override
  String get appStatusPillInterviewInvited => 'Invito al colloquio';

  @override
  String get appStatusPillInterviewScheduled => 'Colloquio programmato';

  @override
  String get appStatusPillHired => 'Assunto';

  @override
  String get appStatusPillRejected => 'Rifiutato';

  @override
  String get appStatusPillWithdrawn => 'Ritirato';

  @override
  String get jobActionPause => 'Metti in pausa';

  @override
  String get jobActionResume => 'Riattiva annuncio';

  @override
  String get jobActionClose => 'Chiudi annuncio';

  @override
  String get statusConfirmedLower => 'confermato';

  @override
  String get postInsightsTitle => 'Statistiche post';

  @override
  String get postInsightsSubtitle => 'Chi sta vedendo i tuoi contenuti';

  @override
  String get recentViewers => 'Visualizzatori recenti';

  @override
  String get lockedBadge => 'BLOCCATO';

  @override
  String get viewerBreakdown => 'Dettaglio visualizzazioni';

  @override
  String get viewersByRole => 'Visualizzatori per ruolo';

  @override
  String get topLocations => 'Località principali';

  @override
  String get businesses => 'Aziende';

  @override
  String get saveToCollectionTitle => 'Salva nella raccolta';

  @override
  String get chooseCategory => 'Scegli categoria';

  @override
  String get removeFromCollection => 'Rimuovi dalla raccolta';

  @override
  String newApplicationTemplate(String role) {
    return 'Nuova candidatura — $role';
  }

  @override
  String get categoryRestaurants => 'Ristoranti';

  @override
  String get categoryCookingVideos => 'Video di cucina';

  @override
  String get categoryJobsTips => 'Consigli di lavoro';

  @override
  String get categoryHospitalityNews => 'News hospitality';

  @override
  String get categoryRecipes => 'Ricette';

  @override
  String get categoryOther => 'Altro';

  @override
  String get premiumHeroTagline => 'Più visibilità, notifiche prioritarie e filtri avanzati pensati per i professionisti dell\'hospitality.';

  @override
  String get benefitAdvancedFilters => 'Filtri di ricerca avanzati';

  @override
  String get benefitPriorityNotifications => 'Notifiche lavoro prioritarie';

  @override
  String get benefitProfileVisibility => 'Maggiore visibilità del profilo';

  @override
  String get benefitPremiumBadge => 'Badge profilo Premium';

  @override
  String get benefitEarlyAccess => 'Accesso anticipato ai nuovi lavori';

  @override
  String get unlockCandidatePremium => 'Sblocca Candidate Premium';

  @override
  String get getStartedAction => 'Inizia ora';

  @override
  String get findYourFirstJob => 'Trova il tuo primo lavoro';

  @override
  String get browseHospitalityRolesNearby => 'Esplora centinaia di ruoli nell\'hospitality vicino a te';

  @override
  String get seeWhoViewedYourPostTitle => 'Vedi chi ha visualizzato il tuo post';

  @override
  String get upgradeToPremiumCta => 'Passa a Premium';

  @override
  String get upgradeToPremiumSubtitle => 'Passa a Premium per vedere aziende verificate, recruiter e responsabili delle assunzioni che hanno visualizzato i tuoi contenuti.';

  @override
  String get verifiedBusinessViewers => 'Visualizzatori aziendali verificati';

  @override
  String get recruiterHiringManagerActivity => 'Attività di recruiter e responsabili assunzioni';

  @override
  String get cityLevelReachBreakdown => 'Copertura per città';

  @override
  String liveApplicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attive',
      one: '1 attiva',
    );
    return '$_temp0';
  }

  @override
  String nearbyJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vicino a te',
      one: '1 vicino a te',
    );
    return '$_temp0';
  }

  @override
  String jobsNearYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lavori vicino a te',
      one: '1 lavoro vicino a te',
    );
    return '$_temp0';
  }

  @override
  String applicationsUnderReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidature in valutazione',
      one: '1 candidatura in valutazione',
    );
    return '$_temp0';
  }

  @override
  String interviewsScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count colloqui programmati',
      one: '1 colloquio programmato',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi non letti',
      one: '1 messaggio non letto',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesFromEmployersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi non letti dai datori di lavoro',
      one: '1 messaggio non letto dai datori di lavoro',
    );
    return '$_temp0';
  }

  @override
  String stepsLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passi rimanenti',
      one: '1 passo rimanente',
    );
    return '$_temp0';
  }

  @override
  String get profileCompleteGreatWork => 'Profilo completo — ottimo lavoro';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anni',
      one: '1 anno',
    );
    return '$_temp0';
  }

  @override
  String get perHour => '/ora';

  @override
  String hoursPerWeekShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore/settimana',
      one: '1 ora/settimana',
    );
    return '$_temp0';
  }

  @override
  String forMonthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'per $count mesi',
      one: 'per 1 mese',
    );
    return '$_temp0';
  }

  @override
  String interviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count colloqui',
      one: '1 colloquio',
    );
    return '$_temp0';
  }

  @override
  String get quickActionFindJobs => 'Trova lavori';

  @override
  String get quickActionMyApplications => 'Le mie candidature';

  @override
  String get quickActionUpdateProfile => 'Aggiorna profilo';

  @override
  String get quickActionCreatePost => 'Crea post';

  @override
  String get quickActionViewInterviews => 'Vedi colloqui';

  @override
  String get confirmSubscriptionTitle => 'Conferma abbonamento';

  @override
  String get confirmAndSubscribeCta => 'Conferma e abbonati';

  @override
  String get timelineLabel => 'Cronologia';

  @override
  String get interviewLabel => 'Colloquio';

  @override
  String get payOnRequest => 'Retribuzione su richiesta';

  @override
  String get rateOnRequest => 'Tariffa su richiesta';

  @override
  String get quickActionFindJobsSubtitle => 'Scopri ruoli vicino a te';

  @override
  String get quickActionMyApplicationsSubtitle => 'Monitora ogni candidatura';

  @override
  String get quickActionUpdateProfileSubtitle => 'Migliora visibilità e punteggio di match';

  @override
  String get quickActionCreatePostSubtitle => 'Condividi il tuo lavoro con la community';

  @override
  String get quickActionViewInterviewsSubtitle => 'Preparati a ciò che viene dopo';

  @override
  String get offerLabel => 'Offerta';

  @override
  String hiringForTemplate(String role) {
    return 'Sta assumendo per $role';
  }

  @override
  String get tapToOpenInMaps => 'Tocca per aprire in Mappe';

  @override
  String get alreadyAppliedToJob => 'Hai già inviato una candidatura per questo lavoro.';

  @override
  String get changePhoto => 'Cambia foto';

  @override
  String get changeAvatar => 'Cambia avatar';

  @override
  String get addPhotoAction => 'Aggiungi foto';

  @override
  String get nationalityLabel => 'Nazionalità';

  @override
  String get targetRoleLabel => 'Ruolo desiderato';

  @override
  String get salaryExpectationLabel => 'Aspettativa salariale';

  @override
  String get addLanguageCta => '+ Aggiungi lingua';

  @override
  String get experienceLabel => 'Esperienza';

  @override
  String get nameLabel => 'Nome';

  @override
  String get zeroHours => 'Ore zero';

  @override
  String get checkInterviewDetailsLine => 'Controlla i dettagli del colloquio';

  @override
  String get interviewInvitedSubline => 'L\'azienda vuole incontrarti — conferma un orario';

  @override
  String get shortlistedSubline => 'Sei nella shortlist — attendi il prossimo passo';

  @override
  String get underReviewSubline => 'L\'azienda sta valutando il tuo profilo';

  @override
  String get hiredHeadline => 'Assunto';

  @override
  String get hiredSubline => 'Congratulazioni! Hai ricevuto un\'offerta';

  @override
  String get applicationSubmittedHeadline => 'Candidatura inviata';

  @override
  String get applicationSubmittedSubline => 'L\'azienda valuterà la tua candidatura';

  @override
  String get withdrawnHeadline => 'Ritirata';

  @override
  String get withdrawnSubline => 'Hai ritirato questa candidatura';

  @override
  String get notSelectedHeadline => 'Non selezionato';

  @override
  String get notSelectedSubline => 'Grazie per il tuo interesse';

  @override
  String jobsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lavori trovati',
      one: '1 lavoro trovato',
    );
    return '$_temp0';
  }

  @override
  String applicationsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count totali',
      one: '1 totale',
    );
    return '$_temp0';
  }

  @override
  String applicationsInReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in valutazione',
      one: '1 in valutazione',
    );
    return '$_temp0';
  }

  @override
  String applicationsLiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attive',
      one: '1 attiva',
    );
    return '$_temp0';
  }

  @override
  String interviewsPendingConfirmTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count colloqui in attesa — conferma un orario.',
      one: '1 colloquio in attesa — conferma un orario.',
    );
    return '$_temp0';
  }

  @override
  String notifInterviewConfirmedTitle(String name) {
    return 'Colloquio confermato — $name';
  }

  @override
  String notifInterviewRequestTitle(String name) {
    return 'Richiesta di colloquio — $name';
  }

  @override
  String notifApplicationUpdateTitle(String name) {
    return 'Aggiornamento candidatura — $name';
  }

  @override
  String notifOfferReceivedTitle(String name) {
    return 'Offerta ricevuta — $name';
  }

  @override
  String notifMessageFromTitle(String name) {
    return 'Messaggio da — $name';
  }

  @override
  String notifInterviewReminderTitle(String name) {
    return 'Promemoria colloquio — $name';
  }

  @override
  String notifProfileViewedTitle(String name) {
    return 'Profilo visualizzato — $name';
  }

  @override
  String notifNewJobMatchTitle(String name) {
    return 'Nuovo lavoro compatibile — $name';
  }

  @override
  String notifApplicationViewedTitle(String name) {
    return 'Candidatura visualizzata da — $name';
  }

  @override
  String notifShortlistedTitle(String name) {
    return 'Selezionato presso — $name';
  }

  @override
  String get notifCompleteProfile => 'Completa il profilo per match migliori';

  @override
  String get notifCompleteBusinessProfile => 'Completa il profilo aziendale per maggiore visibilità';

  @override
  String notifNewJobViews(String role, String count) {
    return 'Il tuo annuncio $role ha $count nuove visualizzazioni';
  }

  @override
  String notifAppliedForRole(String name, String role) {
    return '$name si è candidato per $role';
  }

  @override
  String notifNewApplicationNameRole(String name, String role) {
    return 'Nuova candidatura: $name per $role';
  }

  @override
  String get chatTyping => 'Sta scrivendo...';

  @override
  String get chatStatusSeen => 'Visualizzato';

  @override
  String get chatStatusDelivered => 'Consegnato';

  @override
  String get entryTagline => 'La piattaforma di staffing per professionisti dell\'ospitalità.';

  @override
  String get entryFindWork => 'Trova lavoro';

  @override
  String get entryFindWorkSubtitle => 'Sfoglia lavori e fatti assumere dai migliori locali';

  @override
  String get entryHireStaff => 'Assumi staff';

  @override
  String get entryHireStaffSubtitle => 'Pubblica annunci e trova i migliori talenti';

  @override
  String get entryFindCompanies => 'Trova aziende';

  @override
  String get entryFindCompaniesSubtitle => 'Scopri locali e fornitori di servizi per l\'ospitalità';

  @override
  String get servicesEntryTitle => 'In cerca di aziende';

  @override
  String get servicesHospitalityServices => 'Servizi per l\'ospitalità';

  @override
  String get servicesEntrySubtitle => 'Registra la tua azienda di servizi o trova fornitori vicino a te';

  @override
  String get servicesRegisterCardTitle => 'Registrati come azienda';

  @override
  String get servicesRegisterCardSubtitle => 'Inserisci il tuo servizio e fatti scoprire dai clienti';

  @override
  String get servicesLookingCardTitle => 'Sto cercando un\'azienda';

  @override
  String get servicesLookingCardSubtitle => 'Trova fornitori di servizi vicino a te';

  @override
  String get registerBusinessTitle => 'Registra la tua azienda';

  @override
  String get enterCompanyName => 'Inserisci nome azienda';

  @override
  String get subcategoryOptional => 'Sottocategoria (opzionale)';

  @override
  String get subcategoryHintFloristDj => 'es. Fiorista, servizi DJ';

  @override
  String get searchCompaniesHint => 'Cerca aziende...';

  @override
  String get browseCategories => 'Esplora categorie';

  @override
  String companiesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aziende trovate',
      one: '1 azienda trovata',
    );
    return '$_temp0';
  }

  @override
  String get serviceCategoryFoodBeverage => 'Fornitori di food & beverage';

  @override
  String get serviceCategoryEventServices => 'Servizi per eventi';

  @override
  String get serviceCategoryDecorDesign => 'Decorazioni e design';

  @override
  String get serviceCategoryEntertainment => 'Intrattenimento';

  @override
  String get serviceCategoryEquipmentOps => 'Attrezzature e operazioni';

  @override
  String get serviceCategoryCleaningMaintenance => 'Pulizia e manutenzione';

  @override
  String distanceMiles(String value) {
    return '$value mi';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String get postDetailTitle => 'Post';

  @override
  String get likeAction => 'Mi piace';

  @override
  String get commentAction => 'Commenta';

  @override
  String get saveActionLabel => 'Salva';

  @override
  String get commentsTitle => 'Commenti';

  @override
  String get addCommentHint => 'Aggiungi un commento…';

  @override
  String likesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mi piace',
      one: '1 mi piace',
    );
    return '$_temp0';
  }

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commenti',
      one: '1 commento',
    );
    return '$_temp0';
  }

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salvataggi',
      one: '1 salvataggio',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutesShort(int count) {
    return '${count}m';
  }

  @override
  String timeAgoHoursShort(int count) {
    return '${count}h';
  }

  @override
  String timeAgoDaysShort(int count) {
    return '${count}g';
  }

  @override
  String get timeAgoNow => 'ora';

  @override
  String get activityTitle => 'Attività';

  @override
  String get activityLikedPost => 'ha messo mi piace al tuo post';

  @override
  String get activityCommented => 'ha commentato il tuo post';

  @override
  String get activityStartedFollowing => 'ha iniziato a seguirti';

  @override
  String get activityMentioned => 'ti ha menzionato';

  @override
  String get activitySystemUpdate => 'ti ha inviato un aggiornamento';

  @override
  String get noActivityYetDesc => 'Quando le persone mettono mi piace, commentano o ti seguono, apparirà qui.';

  @override
  String get activeStatus => 'Attivo';

  @override
  String get activeBadge => 'ATTIVO';

  @override
  String get nextRenewalLabel => 'Prossimo rinnovo';

  @override
  String get startedLabel => 'Iniziato';

  @override
  String get statusLabel => 'Stato';

  @override
  String get billingAndCancellation => 'Fatturazione e cancellazione';

  @override
  String get billingAndCancellationCopy => 'Il tuo abbonamento viene addebitato tramite il tuo account App Store / Google Play. Puoi annullarlo in qualsiasi momento dalle Impostazioni del dispositivo — manterrai l\'accesso Premium fino alla data di rinnovo.';

  @override
  String get premiumIsActive => 'Premium è attivo';

  @override
  String get premiumThanksCopy => 'Grazie per supportare Plagit. Hai accesso completo a tutte le funzioni premium.';

  @override
  String get manageSubscription => 'Gestisci abbonamento';

  @override
  String get candidatePremiumPlanName => 'Candidate Premium';

  @override
  String renewsOnDate(String date) {
    return 'Si rinnova il $date';
  }

  @override
  String get fullViewerAccessLine => 'Accesso completo ai visualizzatori · tutte le statistiche sbloccate';

  @override
  String get premiumActiveBadge => 'Premium attivo';

  @override
  String get fullInsightsUnlocked => 'Statistiche complete e dettagli visualizzatori sbloccati.';

  @override
  String get noViewersInCategory => 'Ancora nessun visualizzatore in questa categoria';

  @override
  String get onlyVerifiedViewersShown => 'Vengono mostrati solo i visualizzatori verificati con profili pubblici.';

  @override
  String get notEnoughDataYet => 'Dati ancora insufficienti.';

  @override
  String get noViewInsightsYet => 'Ancora nessuna statistica visualizzazioni';

  @override
  String get noViewInsightsDesc => 'Le statistiche appariranno quando il tuo post avrà più visualizzazioni.';

  @override
  String get suspiciousEngagementDetected => 'Rilevata interazione sospetta';

  @override
  String get patternReviewRequired => 'Richiesta analisi del pattern';

  @override
  String get adminInsightsFooter => 'Vista admin — le stesse statistiche viste dall\'autore, più i flag di moderazione. Solo dati aggregati, nessuna identità individuale viene esposta.';

  @override
  String get viewerKindBusiness => 'Azienda';

  @override
  String get viewerKindCandidate => 'Candidato';

  @override
  String get viewerKindRecruiter => 'Recruiter';

  @override
  String get viewerKindHiringManager => 'Responsabile assunzioni';

  @override
  String get viewerKindBusinessesPlural => 'Aziende';

  @override
  String get viewerKindCandidatesPlural => 'Candidati';

  @override
  String get viewerKindRecruitersPlural => 'Recruiter';

  @override
  String get viewerKindHiringManagersPlural => 'Responsabili assunzioni';

  @override
  String get searchPeoplePostsVenuesHint => 'Cerca persone, post, locali…';

  @override
  String get searchCommunityTitle => 'Cerca nella community';

  @override
  String get roleSommelier => 'Sommelier';

  @override
  String get candidatePremiumActivated => 'Ora sei Candidate Premium';

  @override
  String get purchasesRestoredPremium => 'Acquisti ripristinati — ora sei Candidate Premium';

  @override
  String get nothingToRestore => 'Niente da ripristinare';

  @override
  String get noValidSubscriptionPremiumRemoved => 'Nessun abbonamento valido trovato — accesso premium rimosso';

  @override
  String restoreFailedWithError(String error) {
    return 'Ripristino non riuscito. $error';
  }

  @override
  String get subscriptionTitleAnnual => 'Candidate Premium · Annuale';

  @override
  String get subscriptionTitleMonthly => 'Candidate Premium · Mensile';

  @override
  String pricePerYearSlash(String price) {
    return '$price / anno';
  }

  @override
  String pricePerMonthSlash(String price) {
    return '$price / mese';
  }

  @override
  String get nearbyJobsTitle => 'Lavori vicini';

  @override
  String get expandRadius => 'Amplia raggio';

  @override
  String get noJobsInRadius => 'Nessun lavoro in questo raggio';

  @override
  String jobsWithinRadius(int count, int radius) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lavori entro $radius miglia',
      one: '1 lavoro entro $radius miglia',
    );
    return '$_temp0';
  }

  @override
  String get interviewAcceptedSnack => 'Colloquio accettato!';

  @override
  String get declineInterviewTitle => 'Rifiuta colloquio';

  @override
  String get declineInterviewConfirm => 'Sei sicuro di voler rifiutare questo colloquio?';

  @override
  String get addedToCalendar => 'Aggiunto al calendario';

  @override
  String get removeCompanyTitle => 'Rimuovere?';

  @override
  String get removeCompanyConfirm => 'Sei sicuro di voler rimuovere questa azienda dalla lista salvati?';

  @override
  String get signOutAllRolesConfirm => 'Sei sicuro di voler uscire da tutti i ruoli?';

  @override
  String get tapToViewAllConversations => 'Tocca per vedere tutte le conversazioni';

  @override
  String get savedJobsTitle => 'Lavori salvati';

  @override
  String savedJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lavori salvati',
      one: '1 lavoro salvato',
    );
    return '$_temp0';
  }

  @override
  String get removeFromSavedTitle => 'Rimuovere dai salvati?';

  @override
  String get removeFromSavedConfirm => 'Questo lavoro verrà rimosso dalla lista salvati.';

  @override
  String get noSavedJobsSubtitle => 'Sfoglia i lavori e salva quelli che ti interessano';

  @override
  String get browseJobsAction => 'Sfoglia lavori';

  @override
  String matchingJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lavori compatibili',
      one: '1 lavoro compatibile',
    );
    return '$_temp0';
  }

  @override
  String get savedPostsTitle => 'Post salvati';

  @override
  String get searchSavedPostsHint => 'Cerca tra i post salvati…';

  @override
  String get skipAction => 'Salta';

  @override
  String get submitAction => 'Invia';

  @override
  String get doneAction => 'Fatto';

  @override
  String get resetYourPasswordTitle => 'Reimposta la password';

  @override
  String get enterEmailForResetCode => 'Inserisci la tua email per ricevere un codice di reset';

  @override
  String get sendResetCode => 'Invia codice di reset';

  @override
  String get enterResetCode => 'Inserisci il codice di reset';

  @override
  String get resendCode => 'Invia di nuovo il codice';

  @override
  String get passwordResetComplete => 'Reset password completato';

  @override
  String get backToSignIn => 'Torna all\'accesso';

  @override
  String get passwordChanged => 'Password aggiornata';

  @override
  String get passwordUpdatedShort => 'La tua password è stata aggiornata con successo.';

  @override
  String get passwordUpdatedRelogin => 'La tua password è stata aggiornata. Accedi di nuovo con la nuova password.';

  @override
  String get updatePassword => 'Aggiorna password';

  @override
  String get changePasswordTitle => 'Cambia password';

  @override
  String get passwordRequirements => 'Requisiti password';

  @override
  String get newPasswordHint => 'Nuova password (min 8 caratteri)';

  @override
  String get confirmPasswordField => 'Conferma password';

  @override
  String get enterEmailField => 'Inserisci email';

  @override
  String get enterPasswordField => 'Inserisci password';

  @override
  String get welcomeBack => 'Bentornato!';

  @override
  String get selectHowToUse => 'Scegli come vuoi usare Plagit oggi';

  @override
  String get continueAsCandidate => 'Continua come candidato';

  @override
  String get continueAsBusiness => 'Continua come azienda';

  @override
  String get signInToPlagit => 'Accedi a Plagit';

  @override
  String get enterCredentials => 'Inserisci le credenziali per continuare';

  @override
  String get adminPortal => 'Portale Admin';

  @override
  String get plagitAdmin => 'Plagit Admin';

  @override
  String get signInToAdminAccount => 'Accedi al tuo account admin';

  @override
  String get admin => 'Admin';

  @override
  String get searchJobsRolesRestaurantsHint => 'Cerca lavori, ruoli, ristoranti...';

  @override
  String get exploreNearbyJobs => 'Esplora lavori vicini';

  @override
  String get findOpportunitiesOnMap => 'Scopri opportunità sulla mappa intorno a te';

  @override
  String get featuredJobs => 'Lavori in evidenza';

  @override
  String get jobsNearYou => 'Lavori vicino a te';

  @override
  String get jobsMatchingRoleType => 'Lavori in linea con ruolo e tipologia';

  @override
  String get availableNow => 'Disponibile ora';

  @override
  String get noNearbyJobsYet => 'Ancora nessun lavoro vicino';

  @override
  String get tryIncreasingRadius => 'Prova ad ampliare il raggio o cambiare i filtri';

  @override
  String get checkBackForOpportunities => 'Torna presto per nuove opportunità';

  @override
  String get noNotifications => 'Nessuna notifica';

  @override
  String get okAction => 'OK';

  @override
  String get onlineNow => 'Online ora';

  @override
  String get businessUpper => 'AZIENDA';

  @override
  String get waitingForBusinessFirstMessage => 'In attesa che l\'azienda invii il primo messaggio';

  @override
  String get whenEmployersMessageYou => 'Quando le aziende ti scrivono, appariranno qui.';

  @override
  String get replyToCandidate => 'Rispondi al candidato…';

  @override
  String get quickFeedback => 'Feedback rapido';

  @override
  String get helpImproveMatches => 'Aiutaci a migliorare i tuoi match';

  @override
  String get thanksForFeedback => 'Grazie per il tuo feedback!';

  @override
  String get accountSettings => 'Impostazioni account';

  @override
  String get notificationSettings => 'Impostazioni notifiche';

  @override
  String get privacyAndSecurity => 'Privacy e sicurezza';

  @override
  String get helpAndSupport => 'Aiuto e supporto';

  @override
  String get activeRoleUpper => 'RUOLO ATTIVO';

  @override
  String get meetingLink => 'Link della riunione';

  @override
  String get joinMeeting2 => 'Partecipa alla riunione';

  @override
  String get notes => 'Note';

  @override
  String get completeBusinessProfileTitle => 'Completa il profilo aziendale';

  @override
  String get businessDescription => 'Descrizione aziendale';

  @override
  String get finishSetupAction => 'Completa la configurazione';

  @override
  String get describeBusinessHintLong => 'Descrivi la tua azienda, la cultura e cosa la rende un posto di lavoro eccellente... (min 150 caratteri suggeriti)';

  @override
  String get describeBusinessHintShort => 'Descrivi la tua azienda...';

  @override
  String get writeShortIntroAboutYourself => 'Scrivi una breve presentazione su di te...';

  @override
  String get createBusinessAccountTitle => 'Crea account azienda';

  @override
  String get businessDetailsSection => 'Dettagli aziendali';

  @override
  String get openToInternationalCandidates => 'Aperto a candidati internazionali';

  @override
  String get createAccountShort => 'Crea account';

  @override
  String get yourDetailsSection => 'I tuoi dati';

  @override
  String get jobTypeField => 'Tipo di lavoro';

  @override
  String get communityFeed => 'Feed della community';

  @override
  String get postPublished => 'Post pubblicato';

  @override
  String get postHidden => 'Post nascosto';

  @override
  String get postReportedReview => 'Post segnalato — verrà esaminato dall\'admin';

  @override
  String get postNotFound => 'Post non trovato';

  @override
  String get goBack => 'Torna indietro';

  @override
  String get linkCopied => 'Link copiato';

  @override
  String get removedFromSaved => 'Rimosso dai salvati';

  @override
  String get noPostsFound => 'Nessun post trovato';

  @override
  String get tipsStoriesAdvice => 'Consigli, storie e suggerimenti dai professionisti dell\'ospitalità';

  @override
  String get searchTalentPostsRolesHint => 'Cerca talenti, post, ruoli…';

  @override
  String get videoAttachmentsComingSoon => 'Allegati video in arrivo';

  @override
  String get locationTaggingComingSoon => 'Tag posizione in arrivo';

  @override
  String get fullImageViewerComingSoon => 'Visualizzatore immagini in arrivo';

  @override
  String get shareComingSoon => 'Condivisione in arrivo';

  @override
  String get findServices => 'Trova servizi';

  @override
  String get findHospitalityServices => 'Trova servizi per l\'ospitalità';

  @override
  String get browseServices => 'Esplora servizi';

  @override
  String get searchServicesCompaniesLocationsHint => 'Cerca servizi, aziende, località...';

  @override
  String get searchCompaniesServicesLocationsHint => 'Cerca aziende, servizi, località...';

  @override
  String get nearbyCompanies => 'Aziende vicine';

  @override
  String get nearYou => 'Vicino a te';

  @override
  String get listLabel => 'Elenco';

  @override
  String get mapViewLabel => 'Vista mappa';

  @override
  String get noServicesFound => 'Nessun servizio trovato';

  @override
  String get noCompaniesFoundNearby => 'Nessuna azienda nelle vicinanze';

  @override
  String get noSavedCompanies => 'Nessuna azienda salvata';

  @override
  String get savedCompaniesTitle => 'Aziende salvate';

  @override
  String get saveCompaniesForLater => 'Salva le aziende che ti interessano per ritrovarle facilmente';

  @override
  String get latestUpdates => 'Ultimi aggiornamenti';

  @override
  String get noPromotions => 'Nessuna promozione';

  @override
  String get companyHasNoPromotions => 'Questa azienda non ha promozioni attive.';

  @override
  String get companyHasNoUpdates => 'Questa azienda non ha pubblicato aggiornamenti.';

  @override
  String get promotionsAndOffers => 'Promozioni e offerte';

  @override
  String get promotionNotFound => 'Promozione non trovata';

  @override
  String get promotionDetails => 'Dettagli promozione';

  @override
  String get termsAndConditions => 'Termini e condizioni';

  @override
  String get relatedPosts => 'Post correlati';

  @override
  String get viewOffer => 'Vedi offerta';

  @override
  String get offerBadge => 'OFFERTA';

  @override
  String get requestQuote => 'Richiedi preventivo';

  @override
  String get sendRequest => 'Invia richiesta';

  @override
  String get quoteRequestSent => 'Richiesta di preventivo inviata!';

  @override
  String get inquiry => 'Richiesta';

  @override
  String get dateNeeded => 'Data richiesta';

  @override
  String get serviceType => 'Tipo di servizio';

  @override
  String get serviceArea => 'Area di servizio';

  @override
  String get servicesOffered => 'Servizi offerti';

  @override
  String get servicesLabel => 'Servizi';

  @override
  String get servicePlans => 'Piani di servizio';

  @override
  String get growYourServiceBusiness => 'Fai crescere la tua attività di servizi';

  @override
  String get getDiscoveredPremium => 'Fatti scoprire da più clienti con un annuncio premium.';

  @override
  String get unlockPremium => 'Attiva Premium';

  @override
  String get getMoreVisibility => 'Ottieni più visibilità e match migliori';

  @override
  String get plagitPremiumUpper => 'PLAGIT PREMIUM';

  @override
  String get premiumOnly => 'Solo Premium';

  @override
  String get savePercent17 => 'Risparmia il 17%';

  @override
  String get registerBusinessCta => 'Registra azienda';

  @override
  String get registrationSubmitted => 'Registrazione inviata';

  @override
  String get serviceDescription => 'Descrizione servizio';

  @override
  String get describeServicesHint => 'Descrivi i tuoi servizi, l\'esperienza e cosa ti distingue...';

  @override
  String get websiteOptional => 'Sito web (opzionale)';

  @override
  String get viewCompanyProfileCta => 'Vedi profilo azienda';

  @override
  String get contactCompany => 'Contatta azienda';

  @override
  String get aboutUs => 'Chi siamo';

  @override
  String get address => 'Indirizzo';

  @override
  String get city => 'Città';

  @override
  String get yourLocation => 'La tua posizione';

  @override
  String get enterYourCity => 'Inserisci la tua città';

  @override
  String get clearFilters => 'Azzera filtri';

  @override
  String get tryDifferentSearchTerm => 'Prova un termine diverso';

  @override
  String get tryDifferentOrAdjust => 'Prova con ricerca, categoria o filtri diversi.';

  @override
  String get noPostsYetCompany => 'Nessun post ancora';

  @override
  String requestQuoteFromCompany(String companyName) {
    return 'Richiedi un preventivo a $companyName';
  }

  @override
  String validUntilDate(String validUntil) {
    return 'Valido fino al $validUntil';
  }

  @override
  String get employerCheckingProfile => 'Un datore di lavoro sta controllando il tuo profilo';

  @override
  String profileStrengthPercent(int percent) {
    return 'Il tuo profilo è completo al $percent%';
  }

  @override
  String get profileGetsMoreViews => 'Un profilo completo riceve 3× più visualizzazioni';

  @override
  String get applicationUpdate => 'Aggiornamento candidatura';

  @override
  String get findJobsAndApply => 'Trova lavori e candidati';

  @override
  String get manageJobsAndHiring => 'Gestisci lavori e assunzioni';

  @override
  String get managePlatform => 'Gestisci piattaforma';

  @override
  String get findHospitalityCompanies => 'Trova aziende hospitality';

  @override
  String get candidateMessages => 'MESSAGGI CANDIDATI';

  @override
  String get businessMessages => 'MESSAGGI AZIENDE';

  @override
  String get serviceInquiries => 'RICHIESTE SERVIZIO';

  @override
  String get acceptInterview => 'Accetta colloquio';

  @override
  String get adminMenuDashboard => 'Dashboard';

  @override
  String get adminMenuUsers => 'Utenti';

  @override
  String get adminMenuCandidates => 'Candidati';

  @override
  String get adminMenuBusinesses => 'Aziende';

  @override
  String get adminMenuJobs => 'Lavori';

  @override
  String get adminMenuApplications => 'Candidature';

  @override
  String get adminMenuBookings => 'Prenotazioni';

  @override
  String get adminMenuPayments => 'Pagamenti';

  @override
  String get adminMenuMessages => 'Messaggi';

  @override
  String get adminMenuNotifications => 'Notifiche';

  @override
  String get adminMenuReports => 'Report';

  @override
  String get adminMenuAnalytics => 'Analisi';

  @override
  String get adminMenuSettings => 'Impostazioni';

  @override
  String get adminMenuSupport => 'Supporto';

  @override
  String get adminMenuModeration => 'Moderazione';

  @override
  String get adminMenuRoles => 'Ruoli';

  @override
  String get adminMenuInvoices => 'Fatture';

  @override
  String get adminMenuLogs => 'Log';

  @override
  String get adminMenuIntegrations => 'Integrazioni';

  @override
  String get adminMenuLogout => 'Esci';

  @override
  String get adminActionApprove => 'Approva';

  @override
  String get adminActionReject => 'Rifiuta';

  @override
  String get adminActionSuspend => 'Sospendi';

  @override
  String get adminActionActivate => 'Attiva';

  @override
  String get adminActionDelete => 'Elimina';

  @override
  String get adminActionExport => 'Esporta';

  @override
  String get adminSectionOverview => 'Panoramica';

  @override
  String get adminSectionManagement => 'Gestione';

  @override
  String get adminSectionFinance => 'Finanza';

  @override
  String get adminSectionOperations => 'Operazioni';

  @override
  String get adminSectionSystem => 'Sistema';

  @override
  String get adminStatTotalUsers => 'Utenti totali';

  @override
  String get adminStatActiveJobs => 'Lavori attivi';

  @override
  String get adminStatPendingApprovals => 'Approvazioni in sospeso';

  @override
  String get adminStatRevenue => 'Ricavi';

  @override
  String get adminStatBookingsToday => 'Prenotazioni oggi';

  @override
  String get adminStatNewSignups => 'Nuove registrazioni';

  @override
  String get adminStatConversionRate => 'Tasso di conversione';

  @override
  String get adminMiscWelcome => 'Bentornato';

  @override
  String get adminMiscLoading => 'Caricamento…';

  @override
  String get adminMiscNoData => 'Nessun dato disponibile';

  @override
  String get adminMiscSearchPlaceholder => 'Cerca…';

  @override
  String get adminMenuContent => 'Contenuti';

  @override
  String get adminMenuMore => 'Altro';

  @override
  String get adminMenuVerifications => 'Verifiche';

  @override
  String get adminMenuSubscriptions => 'Abbonamenti';

  @override
  String get adminMenuCommunity => 'Community';

  @override
  String get adminMenuInterviews => 'Colloqui';

  @override
  String get adminMenuMatches => 'Match';

  @override
  String get adminMenuFeaturedContent => 'Contenuti in evidenza';

  @override
  String get adminMenuAuditLog => 'Log di audit';

  @override
  String get adminMenuChangePassword => 'Cambia password';

  @override
  String get adminSectionPeople => 'Persone';

  @override
  String get adminSectionHiring => 'Operazioni di hiring';

  @override
  String get adminSectionContentComm => 'Contenuti e comunicazioni';

  @override
  String get adminSectionRevenue => 'Business e ricavi';

  @override
  String get adminSectionToolsContent => 'Strumenti e contenuti';

  @override
  String get adminSectionQuickActions => 'Azioni rapide';

  @override
  String get adminSectionNeedsAttention => 'Richiede attenzione';

  @override
  String get adminStatActiveBusinesses => 'Aziende attive';

  @override
  String get adminStatApplicationsToday => 'Candidature oggi';

  @override
  String get adminStatInterviewsToday => 'Colloqui oggi';

  @override
  String get adminStatFlaggedContent => 'Contenuti segnalati';

  @override
  String get adminStatActiveSubs => 'Abbonamenti attivi';

  @override
  String get adminActionFlagged => 'Segnalati';

  @override
  String get adminActionFeatured => 'In evidenza';

  @override
  String get adminActionReviewFlagged => 'Controlla contenuti segnalati';

  @override
  String get adminActionTodayInterviews => 'Colloqui di oggi';

  @override
  String get adminActionOpenReports => 'Segnalazioni aperte';

  @override
  String get adminActionManageSubscriptions => 'Gestisci abbonamenti';

  @override
  String get adminActionAnalyticsDashboard => 'Dashboard analisi';

  @override
  String get adminActionSendNotification => 'Invia notifica';

  @override
  String get adminActionCreateCommunityPost => 'Crea post community';

  @override
  String get adminActionRetry => 'Riprova';

  @override
  String get adminMiscGreetingMorning => 'Buongiorno';

  @override
  String get adminMiscGreetingAfternoon => 'Buon pomeriggio';

  @override
  String get adminMiscGreetingEvening => 'Buonasera';

  @override
  String get adminMiscAllClear => 'Tutto ok — nulla richiede attenzione.';

  @override
  String get adminSubtitleAllUsers => 'Tutti gli utenti della piattaforma';

  @override
  String get adminSubtitleCandidates => 'Profili candidati';

  @override
  String get adminSubtitleBusinesses => 'Account aziendali';

  @override
  String get adminSubtitleJobs => 'Offerte di lavoro attive';

  @override
  String get adminSubtitleApplications => 'Candidature inviate';

  @override
  String get adminSubtitleInterviews => 'Colloqui programmati';

  @override
  String get adminSubtitleMatches => 'Corrispondenze ruolo e tipo lavoro';

  @override
  String get adminSubtitleVerifications => 'Revisiona verifiche in sospeso';

  @override
  String get adminSubtitleReports => 'Segnalazioni e moderazione';

  @override
  String get adminSubtitleSupport => 'Problemi di supporto aperti';

  @override
  String get adminSubtitleMessages => 'Conversazioni utenti';

  @override
  String get adminSubtitleNotifications => 'Avvisi push e in-app';

  @override
  String get adminSubtitleCommunity => 'Post e discussioni';

  @override
  String get adminSubtitleFeaturedContent => 'Contenuti in evidenza';

  @override
  String get adminSubtitleSubscriptions => 'Piani e fatturazione';

  @override
  String get adminSubtitleAuditLog => 'Log attività admin';

  @override
  String get adminSubtitleAnalytics => 'Metriche piattaforma';

  @override
  String get adminSubtitleSettings => 'Configurazione piattaforma';

  @override
  String get adminSubtitleUsersPage => 'Gestisci gli account della piattaforma';

  @override
  String get adminSubtitleContentPage => 'Lavori, candidature e colloqui';

  @override
  String get adminSubtitleModerationPage => 'Verifiche, segnalazioni e supporto';

  @override
  String get adminSubtitleMorePage => 'Impostazioni, analitiche e account';

  @override
  String get adminSubtitleAnalyticsHero => 'KPI, tendenze e salute della piattaforma';

  @override
  String get adminBadgeUrgent => 'Urgente';

  @override
  String get adminBadgeReview => 'Rivedi';

  @override
  String get adminBadgeAction => 'Azione';

  @override
  String get adminMenuAllUsers => 'Tutti gli utenti';

  @override
  String get adminMiscSuperAdmin => 'Super Admin';

  @override
  String adminBadgeNToday(int count) {
    return '$count oggi';
  }

  @override
  String adminBadgeNOpen(int count) {
    return '$count aperti';
  }

  @override
  String adminBadgeNActive(int count) {
    return '$count attivi';
  }

  @override
  String adminBadgeNUnread(int count) {
    return '$count non letti';
  }

  @override
  String adminBadgeNPending(int count) {
    return '$count in sospeso';
  }

  @override
  String adminBadgeNPosts(int count) {
    return '$count post';
  }

  @override
  String adminBadgeNFeatured(int count) {
    return '$count in evidenza';
  }

  @override
  String get adminStatusActive => 'Attivo';

  @override
  String get adminStatusPaused => 'In pausa';

  @override
  String get adminStatusClosed => 'Chiuso';

  @override
  String get adminStatusDraft => 'Bozza';

  @override
  String get adminStatusFlagged => 'Segnalato';

  @override
  String get adminStatusSuspended => 'Sospeso';

  @override
  String get adminStatusPending => 'In sospeso';

  @override
  String get adminStatusConfirmed => 'Confermato';

  @override
  String get adminStatusCompleted => 'Completato';

  @override
  String get adminStatusCancelled => 'Annullato';

  @override
  String get adminStatusAccepted => 'Accettato';

  @override
  String get adminStatusDenied => 'Rifiutato';

  @override
  String get adminStatusExpired => 'Scaduto';

  @override
  String get adminStatusResolved => 'Risolto';

  @override
  String get adminStatusScheduled => 'Programmato';

  @override
  String get adminStatusBanned => 'Bannato';

  @override
  String get adminStatusVerified => 'Verificato';

  @override
  String get adminStatusFailed => 'Fallito';

  @override
  String get adminStatusSuccess => 'Successo';

  @override
  String get adminStatusDelivered => 'Consegnato';

  @override
  String get adminFilterAll => 'Tutti';

  @override
  String get adminFilterToday => 'Oggi';

  @override
  String get adminFilterUnread => 'Non letti';

  @override
  String get adminFilterRead => 'Letti';

  @override
  String get adminFilterCandidates => 'Candidati';

  @override
  String get adminFilterBusinesses => 'Aziende';

  @override
  String get adminFilterAdmins => 'Admin';

  @override
  String get adminFilterCandidate => 'Candidato';

  @override
  String get adminFilterBusiness => 'Azienda';

  @override
  String get adminFilterSystem => 'Sistema';

  @override
  String get adminFilterPinned => 'Fissati';

  @override
  String get adminFilterEmployers => 'Datori';

  @override
  String get adminFilterBanners => 'Banner';

  @override
  String get adminFilterBilling => 'Fatturazione';

  @override
  String get adminFilterFeaturedEmployer => 'Datore in evidenza';

  @override
  String get adminFilterFeaturedJob => 'Lavoro in evidenza';

  @override
  String get adminFilterHomeBanner => 'Banner Home';

  @override
  String get adminEmptyAdjustFilters => 'Prova a modificare i filtri.';

  @override
  String get adminEmptyJobsTitle => 'Nessun lavoro';

  @override
  String get adminEmptyJobsSub => 'Nessun lavoro corrisponde.';

  @override
  String get adminEmptyUsersTitle => 'Nessun utente';

  @override
  String get adminEmptyMessagesTitle => 'Nessun messaggio';

  @override
  String get adminEmptyMessagesSub => 'Nessuna conversazione da mostrare.';

  @override
  String get adminEmptyReportsTitle => 'Nessuna segnalazione';

  @override
  String get adminEmptyReportsSub => 'Nessuna segnalazione da rivedere.';

  @override
  String get adminEmptyBusinessesTitle => 'Nessuna azienda';

  @override
  String get adminEmptyBusinessesSub => 'Nessuna azienda corrisponde.';

  @override
  String get adminEmptyNotifsTitle => 'Nessuna notifica';

  @override
  String get adminEmptySubsTitle => 'Nessun abbonamento';

  @override
  String get adminEmptySubsSub => 'Nessun abbonamento corrisponde.';

  @override
  String get adminEmptyLogsTitle => 'Nessun log';

  @override
  String get adminEmptyContentTitle => 'Nessun contenuto';

  @override
  String get adminEmptyInterviewsTitle => 'Nessun colloquio';

  @override
  String get adminEmptyInterviewsSub => 'Nessun colloquio corrisponde.';

  @override
  String get adminEmptyFeedback => 'I feedback appariranno qui';

  @override
  String get adminEmptyMatchNotifs => 'Le notifiche match appariranno qui';

  @override
  String get adminTitleMatchManagement => 'Gestione match';

  @override
  String get adminTitleAdminLogs => 'Log admin';

  @override
  String get adminTitleContentFeatured => 'Contenuti / In evidenza';

  @override
  String get adminTabFeedback => 'Feedback';

  @override
  String get adminTabStats => 'Statistiche';

  @override
  String get adminSortNewest => 'Più recenti';

  @override
  String get adminSortPriority => 'Priorità';

  @override
  String get adminStatTotalMatches => 'Match totali';

  @override
  String get adminStatAccepted => 'Accettati';

  @override
  String get adminStatDenied => 'Rifiutati';

  @override
  String get adminStatFeedbackCount => 'Feedback';

  @override
  String get adminStatMatchQuality => 'Punteggio qualità match';

  @override
  String get adminStatTotal => 'Totale';

  @override
  String get adminStatPendingCount => 'In sospeso';

  @override
  String get adminStatNotificationsCount => 'Notifiche';

  @override
  String get adminStatActiveCount => 'Attivi';

  @override
  String get adminSectionPlatformSettings => 'Impostazioni piattaforma';

  @override
  String get adminSectionNotificationSettings => 'Impostazioni notifiche';

  @override
  String get adminSettingMaintenanceTitle => 'Modalità manutenzione';

  @override
  String get adminSettingMaintenanceSub => 'Disabilita l\'accesso per tutti';

  @override
  String get adminSettingNewRegsTitle => 'Nuove registrazioni';

  @override
  String get adminSettingNewRegsSub => 'Consenti nuove iscrizioni';

  @override
  String get adminSettingFeaturedJobsTitle => 'Lavori in evidenza';

  @override
  String get adminSettingFeaturedJobsSub => 'Mostra i lavori in evidenza in home';

  @override
  String get adminSettingEmailNotifsTitle => 'Notifiche email';

  @override
  String get adminSettingEmailNotifsSub => 'Invia avvisi email';

  @override
  String get adminSettingPushNotifsTitle => 'Notifiche push';

  @override
  String get adminSettingPushNotifsSub => 'Invia notifiche push';

  @override
  String get adminActionSaveChanges => 'Salva modifiche';

  @override
  String get adminToastSettingsSaved => 'Impostazioni salvate';

  @override
  String get adminActionResolve => 'Risolvi';

  @override
  String get adminActionDismiss => 'Ignora';

  @override
  String get adminActionBanUser => 'Banna utente';

  @override
  String get adminSearchUsersHint => 'Cerca nome, email, ruolo, sede...';

  @override
  String get adminMiscPositive => 'positivo';

  @override
  String adminCountUsers(int count) {
    return '$count utenti';
  }

  @override
  String adminCountNotifs(int count) {
    return '$count notifiche';
  }

  @override
  String adminCountLogs(int count) {
    return '$count voci log';
  }

  @override
  String adminCountItems(int count) {
    return '$count elementi';
  }

  @override
  String adminBadgeNRetried(int count) {
    return 'Ritentato x$count';
  }

  @override
  String get adminStatusApplied => 'Candidato';

  @override
  String get adminStatusUnderReview => 'In revisione';

  @override
  String get adminStatusShortlisted => 'Preselezionato';

  @override
  String get adminStatusInterview => 'Colloquio';

  @override
  String get adminStatusHired => 'Assunto';

  @override
  String get adminStatusRejected => 'Rifiutato';

  @override
  String get adminStatusOpen => 'Aperto';

  @override
  String get adminStatusInReview => 'In revisione';

  @override
  String get adminStatusWaiting => 'In attesa';

  @override
  String get adminPriorityHigh => 'Alta';

  @override
  String get adminPriorityMedium => 'Media';

  @override
  String get adminPriorityLow => 'Bassa';

  @override
  String get adminActionViewProfile => 'Vedi profilo';

  @override
  String get adminActionVerify => 'Verifica';

  @override
  String get adminActionReview => 'Rivedi';

  @override
  String get adminActionOverride => 'Sovrascrivi';

  @override
  String get adminEmptyCandidatesTitle => 'Nessun candidato';

  @override
  String get adminEmptyApplicationsTitle => 'Nessuna candidatura';

  @override
  String get adminEmptyVerificationsTitle => 'Nessuna verifica in sospeso';

  @override
  String get adminEmptyIssuesTitle => 'Nessuna segnalazione';

  @override
  String get adminEmptyAuditTitle => 'Nessuna voce di audit';

  @override
  String get adminSearchCandidatesTitle => 'Cerca candidati';

  @override
  String get adminSearchCandidatesHint => 'Cerca per nome, email o ruolo…';

  @override
  String get adminSearchAuditHint => 'Cerca nell\'audit…';

  @override
  String get adminMiscUnknown => 'Sconosciuto';

  @override
  String adminCountTotal(int count) {
    return '$count totali';
  }

  @override
  String adminBadgeNFlagged(int count) {
    return '$count segnalati';
  }

  @override
  String adminBadgeNDaysWaiting(int count) {
    return '$count giorni in attesa';
  }

  @override
  String get adminPeriodWeek => 'Settimana';

  @override
  String get adminPeriodMonth => 'Mese';

  @override
  String get adminPeriodYear => 'Anno';

  @override
  String get adminKpiNewCandidates => 'Nuovi candidati';

  @override
  String get adminKpiNewBusinesses => 'Nuove aziende';

  @override
  String get adminKpiJobsPosted => 'Offerte pubblicate';

  @override
  String get adminSectionApplicationFunnel => 'Funnel candidature';

  @override
  String get adminSectionPlatformGrowth => 'Crescita piattaforma';

  @override
  String get adminSectionPremiumConversion => 'Conversione premium';

  @override
  String get adminSectionTopLocations => 'Località principali';

  @override
  String get adminStatusViewed => 'Visualizzato';

  @override
  String get adminWeekdayMon => 'Lun';

  @override
  String get adminWeekdayTue => 'Mar';

  @override
  String get adminWeekdayWed => 'Mer';

  @override
  String get adminWeekdayThu => 'Gio';

  @override
  String get adminWeekdayFri => 'Ven';

  @override
  String get adminWeekdaySat => 'Sab';

  @override
  String get adminWeekdaySun => 'Dom';

  @override
  String get adminFilterReported => 'Segnalati';

  @override
  String get adminFilterHidden => 'Nascosti';

  @override
  String get adminEmptyPostsTitle => 'Nessun post';

  @override
  String get adminEmptyContentFilter => 'Nessun contenuto corrisponde al filtro.';

  @override
  String get adminBannerReportedReview => 'SEGNALATO — REVISIONE RICHIESTA';

  @override
  String get adminBannerHiddenFromFeed => 'NASCOSTO DAL FEED';

  @override
  String get adminActionInsights => 'Insight';

  @override
  String get adminActionHide => 'Nascondi';

  @override
  String get adminActionRemove => 'Rimuovi';

  @override
  String get adminActionCancel => 'Annulla';

  @override
  String get adminDialogRemovePostTitle => 'Rimuovere il post?';

  @override
  String get adminDialogRemovePostBody => 'Questa azione elimina definitivamente il post e i suoi commenti. Non può essere annullata.';

  @override
  String get adminSnackbarReportCleared => 'Segnalazione rimossa';

  @override
  String get adminSnackbarPostHidden => 'Post nascosto dal feed';

  @override
  String get adminSnackbarPostRemoved => 'Post rimosso';

  @override
  String adminCountReported(int count) {
    return '$count segnalati';
  }

  @override
  String adminCountHidden(int count) {
    return '$count nascosti';
  }

  @override
  String adminMiscPremiumOutOfTotal(int premium, int total) {
    return '$premium premium su $total totali';
  }

  @override
  String get adminActionUnverify => 'Rimuovi verifica';

  @override
  String get adminActionReactivate => 'Riattiva';

  @override
  String get adminActionFeature => 'In evidenza';

  @override
  String get adminActionUnfeature => 'Togli evidenza';

  @override
  String get adminActionFlagAccount => 'Segnala account';

  @override
  String get adminActionUnflagAccount => 'Rimuovi segnalazione';

  @override
  String get adminActionConfirm => 'Conferma';

  @override
  String get adminDialogVerifyBusinessTitle => 'Verifica azienda';

  @override
  String get adminDialogUnverifyBusinessTitle => 'Rimuovi verifica azienda';

  @override
  String get adminDialogSuspendBusinessTitle => 'Sospendi azienda';

  @override
  String get adminDialogReactivateBusinessTitle => 'Riattiva azienda';

  @override
  String get adminDialogVerifyCandidateTitle => 'Verifica candidato';

  @override
  String get adminDialogSuspendCandidateTitle => 'Sospendi candidato';

  @override
  String get adminDialogReactivateCandidateTitle => 'Riattiva candidato';

  @override
  String get adminSnackbarBusinessVerified => 'Azienda verificata';

  @override
  String get adminSnackbarVerificationRemoved => 'Verifica rimossa';

  @override
  String get adminSnackbarBusinessSuspended => 'Azienda sospesa';

  @override
  String get adminSnackbarBusinessReactivated => 'Azienda riattivata';

  @override
  String get adminSnackbarBusinessFeatured => 'Azienda in evidenza';

  @override
  String get adminSnackbarBusinessUnfeatured => 'Evidenza rimossa dall\'azienda';

  @override
  String get adminSnackbarUserVerified => 'Utente verificato';

  @override
  String get adminSnackbarUserSuspended => 'Utente sospeso';

  @override
  String get adminSnackbarUserReactivated => 'Utente riattivato';

  @override
  String get adminTabProfile => 'Profilo';

  @override
  String get adminTabActivity => 'Attività';

  @override
  String get adminTabNotes => 'Note';

  @override
  String adminDialogVerifyBody(String name) {
    return 'Contrassegnare $name come verificato?';
  }

  @override
  String adminDialogUnverifyBody(String name) {
    return 'Rimuovere la verifica da $name?';
  }

  @override
  String adminDialogReactivateBody(String name) {
    return 'Riattivare $name?';
  }

  @override
  String adminDialogSuspendBusinessBody(String name) {
    return 'Sospendere $name? Tutte le offerte verranno messe in pausa.';
  }

  @override
  String adminDialogSuspendCandidateBody(String name) {
    return 'Sospendere $name? Perderà l\'accesso.';
  }

  @override
  String get adminFieldName => 'Nome';

  @override
  String get adminFieldEmail => 'Email';

  @override
  String get adminFieldPhone => 'Telefono';

  @override
  String get adminFieldLocation => 'Posizione';

  @override
  String get adminFieldPlan => 'Piano';

  @override
  String get adminFieldVerified => 'Verificato';

  @override
  String get adminFieldStatus => 'Stato';

  @override
  String get adminFieldJoined => 'Iscritto';

  @override
  String get adminFieldCategory => 'Categoria';

  @override
  String get adminFieldSize => 'Dimensione';

  @override
  String get adminFieldRole => 'Ruolo';

  @override
  String get adminFieldProfileCompletion => 'Completamento profilo';

  @override
  String get adminStatApplicants => 'Candidati';

  @override
  String get adminStatSaved => 'Salvati';

  @override
  String get adminPlaceholderAddNote => 'Aggiungi una nota...';

  @override
  String get adminEmptyNoJobsPosted => 'Nessun annuncio pubblicato';

  @override
  String get adminSectionSubscriptionDetail => 'Dettaglio abbonamento';

  @override
  String get adminEmptySubscriptionNotFound => 'Abbonamento non trovato';

  @override
  String get adminSectionPlanDetails => 'Dettagli piano';

  @override
  String get adminFieldPrice => 'Prezzo';

  @override
  String get adminFieldStartDate => 'Data inizio';

  @override
  String get adminFieldRenewalDate => 'Data rinnovo';

  @override
  String get adminSectionAdminOverride => 'Override admin';

  @override
  String get adminPlanCandidatePremium => 'Candidato Premium';

  @override
  String get adminPlanBusinessPro => 'Business Pro';

  @override
  String get adminPlanBusinessPremium => 'Business Premium';

  @override
  String get adminPlanFree => 'Gratuito';

  @override
  String get adminFieldNewRenewalDate => 'Nuova data rinnovo';

  @override
  String get adminPlaceholderDateExample => 'es. 15 giu 2026';

  @override
  String get adminFieldReason => 'Motivo';

  @override
  String get adminPlaceholderReasonOverride => 'Motivo dell\'override...';

  @override
  String get adminActionApplyOverride => 'Applica override';

  @override
  String get adminSectionHistory => 'Cronologia';

  @override
  String get adminTimelineSubscriptionCreated => 'Abbonamento creato';

  @override
  String get adminTimelinePaymentProcessed => 'Pagamento elaborato';

  @override
  String get adminEmptyNoAdminNotes => 'Nessuna nota admin.';

  @override
  String get adminSectionAuditDetail => 'Dettaglio audit';

  @override
  String get adminEmptyEntryNotFound => 'Voce non trovata';

  @override
  String get adminFieldAdmin => 'Admin';

  @override
  String get adminFieldAction => 'Azione';

  @override
  String get adminFieldTimestamp => 'Data e ora';

  @override
  String get adminFieldTarget => 'Destinatario';

  @override
  String get adminFieldType => 'Tipo';

  @override
  String get adminSectionChanges => 'Modifiche';

  @override
  String get adminFieldIpAddress => 'Indirizzo IP';

  @override
  String get adminAuditUnverified => 'Non verificato';

  @override
  String get adminAuditStandard => 'Standard';

  @override
  String get adminAuditFeatured => 'In evidenza';

  @override
  String get adminAuditPreviousStatus => 'Stato precedente';

  @override
  String get adminAuditOverridden => 'Sovrascritto';

  @override
  String get adminAuditPrevious => 'Precedente';

  @override
  String get adminAuditUpdated => 'Aggiornato';

  @override
  String get adminStatusWithdrawn => 'Ritirata';

  @override
  String get adminStatusNoShow => 'Assente';

  @override
  String get adminStatusInProgress => 'In corso';

  @override
  String get adminStatusReviewed => 'Esaminata';

  @override
  String get adminStatusDecision => 'Decisione';

  @override
  String get adminSectionApplicationDetail => 'Dettagli candidatura';

  @override
  String get adminSectionInterviewDetail => 'Dettagli colloquio';

  @override
  String get adminSectionTimeline => 'Cronologia';

  @override
  String get adminSectionAdminNotes => 'Note admin';

  @override
  String get adminSectionActions => 'Azioni';

  @override
  String get adminFieldCandidate => 'Candidato';

  @override
  String get adminFieldJob => 'Annuncio';

  @override
  String get adminFieldBusiness => 'Azienda';

  @override
  String get adminFieldDate => 'Data';

  @override
  String get adminFieldTime => 'Ora';

  @override
  String get adminFieldFormat => 'Formato';

  @override
  String get adminBadgeFlaggedForReview => 'Segnalato per revisione moderatore';

  @override
  String get adminPlaceholderSelectStatus => 'Seleziona stato';

  @override
  String get adminDialogConfirmOverrideTitle => 'Conferma override';

  @override
  String adminDialogConfirmOverrideQuestion(String status) {
    return 'Cambiare lo stato in \"$status\"?';
  }

  @override
  String get adminDialogReasonPrefix => 'Motivo:';

  @override
  String get adminMiscNoneProvided => 'Nessuno indicato';

  @override
  String get adminSnackbarStatusOverrideApplied => 'Override stato applicato';

  @override
  String get adminSnackbarNoteSaved => 'Nota salvata';

  @override
  String get adminSnackbarNoteAdded => 'Nota aggiunta';

  @override
  String get adminSnackbarMarkedNoShow => 'Contrassegnato come assente';

  @override
  String get adminSnackbarInterviewCancelled => 'Colloquio annullato';

  @override
  String get adminSnackbarInterviewCompleted => 'Colloquio completato';

  @override
  String get adminActionSaveNote => 'Salva nota';

  @override
  String get adminActionAddNote => 'Aggiungi nota';

  @override
  String get adminActionComplete => 'Completa';

  @override
  String get adminActionMarkNoShow => 'Segna assente';

  @override
  String get adminEmptyNoNotes => 'Nessuna nota ancora.';

  @override
  String get adminSectionVerificationReview => 'Revisione verifica';

  @override
  String get adminSectionProfileSummary => 'Riepilogo profilo';

  @override
  String get adminSectionDocuments => 'Documenti';

  @override
  String get adminSectionReportDetail => 'Dettaglio segnalazione';

  @override
  String get adminSectionReportInformation => 'Informazioni segnalazione';

  @override
  String get adminSectionEvidence => 'Prove';

  @override
  String get adminSectionAdminDecision => 'Decisione admin';

  @override
  String get adminSectionAuditTrail => 'Traccia audit';

  @override
  String get adminSectionSupportIssue => 'Ticket assistenza';

  @override
  String get adminSectionDescription => 'Descrizione';

  @override
  String get adminSectionUpdateStatus => 'Aggiorna stato';

  @override
  String get adminSectionResolution => 'Risoluzione';

  @override
  String get adminFieldSubmitted => 'Inviato';

  @override
  String get adminFieldReporter => 'Segnalante';

  @override
  String get adminFieldEntity => 'Entità';

  @override
  String get adminFieldUser => 'Utente';

  @override
  String get adminFieldNote => 'Nota';

  @override
  String get adminFieldCreated => 'Creato';

  @override
  String get adminFieldUpdated => 'Aggiornato';

  @override
  String get adminFieldPriority => 'Priorità';

  @override
  String get adminDocTitleIdDocument => 'Documento identità';

  @override
  String get adminDocSubtitleIdDocument => 'Passaporto / Carta d\'identità';

  @override
  String get adminDocTitleCv => 'CV';

  @override
  String get adminDocSubtitleCv => 'Curriculum vitae';

  @override
  String get adminDocTitleRegistration => 'Registrazione';

  @override
  String get adminDocSubtitleRegistration => 'Documento di registrazione attività';

  @override
  String get adminActionViewDocument => 'Visualizza documento';

  @override
  String get adminActionSaveDecision => 'Salva decisione';

  @override
  String get adminActionUpdate => 'Aggiorna';

  @override
  String get adminActionMarkResolved => 'Segna come risolto';

  @override
  String get adminActionOptionNone => 'Nessuna';

  @override
  String get adminActionOptionWarning => 'Avviso';

  @override
  String get adminActionOptionContentRemoved => 'Contenuto rimosso';

  @override
  String get adminActionOptionAccountSuspended => 'Account sospeso';

  @override
  String get adminPlaceholderRejectionReason => 'Motivo del rifiuto...';

  @override
  String get adminPlaceholderDecisionNotes => 'Aggiungi note della decisione...';

  @override
  String get adminPlaceholderResolutionSummary => 'Sintesi risoluzione...';

  @override
  String get adminSnackbarVerificationApproved => 'Verifica approvata';

  @override
  String get adminSnackbarVerificationRejected => 'Verifica rifiutata';

  @override
  String get adminSnackbarIssueResolved => 'Ticket risolto';

  @override
  String adminSnackbarViewingDocument(String title) {
    return 'Visualizzazione $title (placeholder)';
  }

  @override
  String adminSnackbarStatusUpdatedTo(String status) {
    return 'Stato aggiornato a $status';
  }

  @override
  String adminSnackbarDecisionSaved(String status, String action) {
    return 'Decisione salvata: $status / $action';
  }

  @override
  String get adminDialogApproveVerificationTitle => 'Approva verifica';

  @override
  String adminDialogApproveVerificationBody(String name) {
    return 'Approvare la verifica per $name?';
  }

  @override
  String get adminDialogRejectVerificationTitle => 'Rifiuta verifica';

  @override
  String adminDialogRejectVerificationBody(String name) {
    return 'Rifiutare la verifica per $name?';
  }

  @override
  String get adminEmptyIssueNotFound => 'Ticket non trovato';

  @override
  String get adminValuePlatform => 'Piattaforma';

  @override
  String get adminValueSupport => 'Assistenza';

  @override
  String get adminMiscReportCreatedByPlatform => 'Segnalazione creata dal rilevamento automatico piattaforma';

  @override
  String get adminActionPause => 'Pausa';

  @override
  String get adminActionClose => 'Chiudi';

  @override
  String get adminActionViewApplicants => 'Visualizza candidati';

  @override
  String get adminBadgeFeatured => 'In evidenza';

  @override
  String get adminFieldPosted => 'Pubblicato';

  @override
  String get adminFieldViews => 'Visualizzazioni';

  @override
  String get adminFieldPay => 'Retribuzione';

  @override
  String get adminFieldEmployment => 'Impiego';

  @override
  String get adminFieldSummary => 'Riepilogo';

  @override
  String get adminFieldAnnual => 'Annuale';

  @override
  String get adminFieldMonthly => 'Mensile';

  @override
  String get adminFieldDuration => 'Durata';

  @override
  String get adminFieldHourly => 'Orario';

  @override
  String get adminFieldWeeklyHours => 'Ore settimanali';

  @override
  String get adminFieldBonus => 'Bonus';

  @override
  String get adminFieldShift => 'Turno';

  @override
  String get adminFieldSalaryRange => 'Fascia salariale';

  @override
  String get adminMiscNotSpecified => 'Non specificato';

  @override
  String get adminSectionModeration => 'Moderazione';

  @override
  String get adminSectionCompensationReview => 'Revisione retribuzione';

  @override
  String get adminSectionApplicantsSummary => 'Riepilogo candidati';

  @override
  String get adminSectionExtras => 'Extra';

  @override
  String get adminPlaceholderFlagReason => 'Motivo della segnalazione...';

  @override
  String get adminSnackbarJobFeatured => 'Lavoro in evidenza';

  @override
  String get adminSnackbarJobUnfeatured => 'Lavoro non più in evidenza';

  @override
  String get adminSnackbarJobRemoved => 'Lavoro rimosso';

  @override
  String get adminDialogPauseJobTitle => 'Sospendi lavoro';

  @override
  String get adminDialogPauseJobBody => 'Sospendere questo annuncio?';

  @override
  String get adminDialogCloseJobTitle => 'Chiudi lavoro';

  @override
  String get adminDialogCloseJobBody => 'Chiudere definitivamente questo annuncio?';

  @override
  String get adminDialogRemoveJobTitle => 'Rimuovi lavoro';

  @override
  String get adminDialogRemoveJobBody => 'Rimuovere completamente questo lavoro? Operazione irreversibile.';

  @override
  String get adminModerationFlagThis => 'Segnala questo lavoro';

  @override
  String get adminModerationIsFlagged => 'Questo lavoro è segnalato';

  @override
  String get adminPerkHousing => 'Alloggio incluso';

  @override
  String get adminPerkTravel => 'Viaggio incluso';

  @override
  String get adminPerkOvertime => 'Straordinari disponibili';

  @override
  String get adminPerkFlexible => 'Orario flessibile';

  @override
  String get adminPerkWeekend => 'Turni nel weekend';

  @override
  String get adminStatNew => 'Nuovi';

  @override
  String get adminStatReviewed => 'Revisionati';

  @override
  String get adminStatShortlisted => 'In shortlist';

  @override
  String get adminStatRejected => 'Respinti';

  @override
  String get switchRoleTitle => 'Cambia ruolo';

  @override
  String get postsTab => 'Post';

  @override
  String get galleryTab => 'Galleria';

  @override
  String get promotionsTab => 'Promozioni';

  @override
  String get filterUpdates => 'Aggiornamenti';

  @override
  String get badgePro => 'PRO';

  @override
  String get badgeAdmin => 'ADMIN';

  @override
  String codeSentToEmail(String email) {
    return 'Abbiamo inviato un codice di 6 cifre a $email.';
  }

  @override
  String get businessFieldMeetingLink => 'Link riunione';

  @override
  String get businessFieldLocation => 'Posizione';

  @override
  String rePrefix(String context) {
    return 'Re: $context';
  }

  @override
  String conversationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversazioni',
      one: '1 conversazione',
    );
    return '$_temp0';
  }

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count da leggere',
      one: '1 da leggere',
    );
    return '$_temp0';
  }

  @override
  String removeChatBody(String company) {
    return 'Rimuovere la conversazione con $company? L\'azione non è reversibile.';
  }

  @override
  String deleteConversationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminare $count conversazioni?',
      one: 'Eliminare 1 conversazione?',
    );
    return '$_temp0';
  }

  @override
  String get selectedChatsBody => 'Le chat selezionate verranno rimosse definitivamente.';

  @override
  String clearInboxBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Svuotare tutte le $count conversazioni dalla casella?',
      one: 'Svuotare 1 conversazione dalla casella?',
    );
    return '$_temp0';
  }

  @override
  String get orLabel => 'OPPURE';

  @override
  String quickPlugNewBadge(int count) {
    return '$count NUOVI';
  }

  @override
  String get statusActive => 'Attivo';

  @override
  String get statusDraft => 'Bozza';

  @override
  String get statusPaused => 'In pausa';

  @override
  String get filterActive => 'Attivi';

  @override
  String get filterDraft => 'Bozze';

  @override
  String get filterPaused => 'In pausa';

  @override
  String get filterClosed => 'Chiusi';

  @override
  String get myJobsTitle => 'I miei annunci';

  @override
  String noJobsForFilter(String filter) {
    return 'Nessun annuncio $filter';
  }

  @override
  String get retryAction => 'Riprova';

  @override
  String get jobMenuEdit => 'Modifica';

  @override
  String get jobMenuPause => 'Metti in pausa';

  @override
  String get jobMenuClose => 'Chiudi';

  @override
  String get jobMenuDuplicate => 'Duplica';

  @override
  String jobsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count annunci',
      one: '1 annuncio',
      zero: 'Nessun annuncio',
    );
    return '$_temp0';
  }

  @override
  String applicantsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidati',
      one: '1 candidato',
      zero: 'Nessun candidato',
    );
    return '$_temp0';
  }

  @override
  String activeJobsShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attivi',
      one: '1 attivo',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi questa settimana',
      one: '1 nuovo questa settimana',
    );
    return '$_temp0';
  }

  @override
  String newApplicantsToReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi candidati da rivedere',
      one: '1 nuovo candidato da rivedere',
    );
    return '$_temp0';
  }

  @override
  String get chipFlexible => 'Flessibile';

  @override
  String get businessPremiumTitle => 'Business Premium';

  @override
  String get hireFasterWithPremium => 'Assumi più velocemente con strumenti premium';

  @override
  String get unlockPowerfulRecruiting => 'Sblocca funzionalità di recruiting avanzate';

  @override
  String get benefitQuickPlug => 'Quick Plug — scorri per abbinare i migliori talenti';

  @override
  String get benefitFeaturedJobs => 'Annunci in evidenza';

  @override
  String get benefitApplicantInsights => 'Statistiche e analisi sui candidati';

  @override
  String get benefitUnlimitedJobs => 'Annunci illimitati';

  @override
  String get benefitPriorityVisibility => 'Visibilità prioritaria per i migliori candidati';

  @override
  String get savePercent30 => 'Risparmia 30%';

  @override
  String get freeTrialStarted => 'Prova gratuita attivata!';

  @override
  String get startFreeTrial => 'Inizia prova gratuita';

  @override
  String planActiveSuffix(String plan) {
    return 'Piano $plan attivo';
  }

  @override
  String planRenewsOn(String date) {
    return 'Il tuo piano si rinnova il $date';
  }

  @override
  String get premiumPlanIsActive => 'Il tuo piano premium è attivo';

  @override
  String get postJobTitle => 'Pubblica un annuncio';

  @override
  String get saveDraftButton => 'Salva bozza';

  @override
  String get jobTitleLabel => 'Titolo dell\'annuncio';

  @override
  String get jobTitleHint => 'es. Cameriere senior';

  @override
  String get locationHint => 'es. Mayfair, Londra';

  @override
  String get numberOfPositions => 'Numero di posizioni';

  @override
  String get nextButton => 'Avanti';

  @override
  String get salaryLabel => 'Stipendio';

  @override
  String get salaryHint => 'es. €14';

  @override
  String get contractTypeLabel => 'Tipo di contratto';

  @override
  String get shiftTypeLabel => 'Tipo di turno';

  @override
  String get startDateLabel => 'Data di inizio';

  @override
  String get asapChip => 'Subito';

  @override
  String get specificDateChip => 'Data specifica';

  @override
  String get jobDescriptionLabel => 'Descrizione dell\'annuncio';

  @override
  String get jobDescriptionHint => 'Descrivi il ruolo, le responsabilità e com\'è un tipico turno...';

  @override
  String charCountMin(int count) {
    return '$count / min 50';
  }

  @override
  String get requirementsLabel => 'Requisiti';

  @override
  String get benefitsLabel => 'Benefit';

  @override
  String get benefitsHint => 'Elenca i benefit offerti (mance, pasti, trasporto, ecc.)';

  @override
  String get markAsUrgent => 'Contrassegna come urgente';

  @override
  String get featuredJobToggle => 'Annuncio in evidenza';

  @override
  String get premiumBadge => 'Premium';

  @override
  String get publishJobButton => 'Pubblica annuncio';

  @override
  String get jobPublishedHeadline => 'Annuncio pubblicato!';

  @override
  String get jobPublishedSubtext => 'Il tuo annuncio è online e visibile ai candidati';

  @override
  String get postAnother => 'Pubblica un altro';

  @override
  String get addAction => 'Aggiungi';

  @override
  String get noShortlistedHeadline => 'Nessun candidato preselezionato';

  @override
  String get noShortlistedSubtext => 'Preseleziona candidati da Vicino a te, Candidati o risultati di ricerca.';

  @override
  String get jobNotFound => 'Annuncio non trovato';

  @override
  String get tabDetails => 'Dettagli';

  @override
  String tabApplicantsCount(int count) {
    return 'Candidati ($count)';
  }

  @override
  String get pauseJobButton => 'Metti in pausa';

  @override
  String get closeJobButton => 'Chiudi annuncio';

  @override
  String get sectionDescription => 'Descrizione';

  @override
  String get sectionRequirements => 'Requisiti';

  @override
  String get sectionBenefits => 'Benefit';

  @override
  String get labelPosted => 'Pubblicato';

  @override
  String get labelViews => 'Visualizzazioni';

  @override
  String get labelSaves => 'Salvati';

  @override
  String get noApplicantsText => 'Ancora nessun candidato';

  @override
  String get quickActionShortlist => 'Preseleziona';

  @override
  String get quickActionReject => 'Rifiuta';

  @override
  String get quickActionMessage => 'Messaggio';
}
