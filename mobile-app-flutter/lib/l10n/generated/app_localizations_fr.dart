// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Plagit';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createBusinessAccount => 'Créer un compte entreprise';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get email => 'Adresse e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get done => 'Terminé';

  @override
  String get retry => 'Réessayer';

  @override
  String get search => 'Rechercher';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get apply => 'Postuler';

  @override
  String get clear => 'Effacer';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get home => 'Accueil';

  @override
  String get jobs => 'Emplois';

  @override
  String get messages => 'Messages';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get logout => 'Déconnexion';

  @override
  String get categoryAndRole => 'Catégorie et rôle';

  @override
  String get selectCategory => 'Choisir une catégorie';

  @override
  String get subcategory => 'Sous-catégorie';

  @override
  String get role => 'Rôle';

  @override
  String get recentSearches => 'Recherches récentes';

  @override
  String noResultsFor(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get mostPopular => 'Les plus populaires';

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get selectVenueTypeAndRole =>
      'Choisir le type d\'établissement et le rôle requis';

  @override
  String get selectCategoryAndRole => 'Choisir la catégorie et le rôle';

  @override
  String get businessDetails => 'Détails de l\'entreprise';

  @override
  String get yourDetails => 'Vos informations';

  @override
  String get companyName => 'Nom de l\'entreprise';

  @override
  String get contactPerson => 'Personne de contact';

  @override
  String get location => 'Lieu';

  @override
  String get website => 'Site web';

  @override
  String get fullName => 'Nom complet';

  @override
  String get yearsExperience => 'Années d\'expérience';

  @override
  String get languagesSpoken => 'Langues parlées';

  @override
  String get jobType => 'Type d\'emploi';

  @override
  String get jobTypeFullTime => 'Temps plein';

  @override
  String get jobTypePartTime => 'Temps partiel';

  @override
  String get jobTypeTemporary => 'Temporaire';

  @override
  String get jobTypeFreelance => 'Indépendant';

  @override
  String get openToInternational => 'Ouvert aux candidats internationaux';

  @override
  String get passwordHint => 'Mot de passe (min. 8 caractères)';

  @override
  String get termsOfServiceNote =>
      'En créant un compte, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get networkError => 'Erreur réseau';

  @override
  String get somethingWentWrong => 'Une erreur est survenue';

  @override
  String get loading => 'Chargement…';

  @override
  String get errorGeneric =>
      'Une erreur inattendue s\'est produite. Réessayez.';

  @override
  String get joinAsCandidate => 'Rejoindre en tant que Candidat';

  @override
  String get joinAsBusiness => 'Rejoindre en tant qu\'Entreprise';

  @override
  String get findYourNextRole =>
      'Trouvez votre prochain poste dans l\'hôtellerie-restauration';

  @override
  String get candidateLoginSubtitle =>
      'Connectez-vous avec les meilleurs employeurs à Londres, Dubaï et au-delà.';

  @override
  String get businessLoginSubtitle =>
      'Atteignez les meilleurs talents de l\'hôtellerie et développez votre équipe.';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get lookingForStaff => 'Vous cherchez du personnel ? ';

  @override
  String get lookingForJob => 'Vous cherchez un emploi ? ';

  @override
  String get switchToBusiness => 'Passer à Entreprise';

  @override
  String get switchToCandidate => 'Passer à Candidat';

  @override
  String get createYourProfile =>
      'Créez votre profil et faites-vous découvrir par les meilleurs employeurs.';

  @override
  String get createBusinessProfile =>
      'Créez le profil de votre entreprise et commencez à recruter les meilleurs talents de l\'hôtellerie.';

  @override
  String get locationCityCountry => 'Lieu (ville, pays)';

  @override
  String get termsAgreement =>
      'En créant un compte, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get searchHospitalityHint =>
      'Rechercher catégorie, sous-catégorie ou rôle…';

  @override
  String get mostCommonRoles => 'Rôles les plus courants';

  @override
  String get allRoles => 'Tous les rôles';

  @override
  String suggestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suggestions',
      one: '1 suggestion',
    );
    return '$_temp0';
  }

  @override
  String subcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sous-catégories',
      one: '1 sous-catégorie',
    );
    return '$_temp0';
  }

  @override
  String rolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rôles',
      one: '1 rôle',
    );
    return '$_temp0';
  }

  @override
  String get kindCategory => 'Catégorie';

  @override
  String get kindSubcategory => 'Sous-catégorie';

  @override
  String get kindRole => 'Rôle';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordSubtitle =>
      'Saisissez votre e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String get resetEmailSent =>
      'Si un compte existe pour cet e-mail, un lien de réinitialisation a été envoyé.';

  @override
  String get profileSetupTitle => 'Complétez votre profil';

  @override
  String get profileSetupSubtitle =>
      'Un profil complet est découvert plus rapidement.';

  @override
  String get uploadPhoto => 'Ajouter une photo';

  @override
  String get uploadCV => 'Téléverser un CV';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get finish => 'Terminer';

  @override
  String get noInternet => 'Aucune connexion Internet. Vérifiez votre réseau.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get emptyJobs => 'Aucun emploi pour le moment';

  @override
  String get emptyApplications => 'Aucune candidature pour le moment';

  @override
  String get emptyMessages => 'Aucun message pour le moment';

  @override
  String get emptyNotifications => 'Vous êtes à jour';

  @override
  String get onboardingRoleTitle => 'Quel rôle recherchez-vous ?';

  @override
  String get onboardingRoleSubtitle => 'Sélectionnez tout ce qui s\'applique';

  @override
  String get onboardingExperienceTitle => 'Combien d\'expérience avez-vous ?';

  @override
  String get onboardingLocationTitle => 'Où êtes-vous basé ?';

  @override
  String get onboardingLocationHint => 'Saisissez votre ville ou code postal';

  @override
  String get useMyCurrentLocation => 'Utiliser ma position actuelle';

  @override
  String get onboardingAvailabilityTitle => 'Que recherchez-vous ?';

  @override
  String get finishSetup => 'Terminer la configuration';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get findJobs => 'Trouver des emplois';

  @override
  String get applications => 'Candidatures';

  @override
  String get community => 'Communauté';

  @override
  String get recommendedForYou => 'Recommandés pour vous';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get searchJobsHint => 'Rechercher emplois, rôles, lieux…';

  @override
  String get searchJobs => 'Rechercher des emplois';

  @override
  String get postedJob => 'Publié';

  @override
  String get applyNow => 'Postuler';

  @override
  String get applied => 'Candidature envoyée';

  @override
  String get saveJob => 'Enregistrer';

  @override
  String get saved => 'Enregistré';

  @override
  String get jobDescription => 'Description du poste';

  @override
  String get requirements => 'Exigences';

  @override
  String get benefits => 'Avantages';

  @override
  String get salary => 'Salaire';

  @override
  String get contract => 'Contrat';

  @override
  String get schedule => 'Horaires';

  @override
  String get viewCompany => 'Voir l\'entreprise';

  @override
  String get interview => 'Entretien';

  @override
  String get interviews => 'Entretiens';

  @override
  String get notifications => 'Notifications';

  @override
  String get matches => 'Correspondances';

  @override
  String get quickPlug => 'Quick Plug';

  @override
  String get discover => 'Découvrir';

  @override
  String get shortlist => 'Présélection';

  @override
  String get message => 'Message';

  @override
  String get messageCandidate => 'Message';

  @override
  String get nextInterview => 'Prochain entretien';

  @override
  String get loadingDashboard => 'Chargement du tableau de bord…';

  @override
  String get tryAgainCta => 'Réessayer';

  @override
  String get careerDashboard => 'TABLEAU DE BORD CARRIÈRE';

  @override
  String get yourNextInterview => 'Votre prochain entretien\nest prévu';

  @override
  String get yourCareerTakingOff => 'Votre carrière\ndécolle';

  @override
  String get yourCareerOnTheMove => 'Votre carrière\nest en mouvement';

  @override
  String get yourJourneyStartsHere => 'Votre parcours\ncommence ici';

  @override
  String get applyFirstJob => 'Postulez à votre premier emploi pour commencer';

  @override
  String get interviewComingUp => 'Entretien à venir';

  @override
  String get unlockPlagitPremium => 'Débloquer Plagit Premium';

  @override
  String get premiumSubtitle =>
      'Démarquez-vous auprès des meilleurs établissements — matchez plus vite';

  @override
  String get premiumActive => 'Premium Actif';

  @override
  String get premiumActiveSubtitle =>
      'Visibilité prioritaire activée · Gérer l\'abonnement';

  @override
  String get noJobsFound => 'Aucun emploi ne correspond à votre recherche';

  @override
  String get noApplicationsYet => 'Aucune candidature pour le moment';

  @override
  String get startApplying => 'Commencez à explorer les emplois pour postuler';

  @override
  String get noMessagesYet => 'Aucun message pour le moment';

  @override
  String get allCaughtUp => 'Vous êtes à jour';

  @override
  String get noNotificationsYet => 'Aucune notification pour le moment';

  @override
  String get about => 'À propos';

  @override
  String get experience => 'Expérience';

  @override
  String get skills => 'Compétences';

  @override
  String get languages => 'Langues';

  @override
  String get availability => 'Disponibilité';

  @override
  String get verified => 'Vérifié';

  @override
  String get totalViews => 'Vues totales';

  @override
  String get verifiedVenuePrefix => 'Vérifié';

  @override
  String get notVerified => 'Non vérifié';

  @override
  String get pendingReview => 'En cours de révision';

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get share => 'Partager';

  @override
  String get report => 'Signaler';

  @override
  String get block => 'Bloquer';

  @override
  String get typeMessage => 'Écrire un message…';

  @override
  String get send => 'Envoyer';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get now => 'maintenant';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count min',
      one: 'il y a 1 min',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count h',
      one: 'il y a 1 h',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count j',
      one: 'il y a 1 j',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filtres';

  @override
  String get refineSearch => 'Affiner la recherche';

  @override
  String get distance => 'Distance';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String get reset => 'Réinitialiser';

  @override
  String noResultsTitle(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get noResultsSubtitle =>
      'Essayez un autre mot-clé ou effacez la recherche.';

  @override
  String get recentSearchesEmptyTitle => 'Aucune recherche récente';

  @override
  String get recentSearchesEmptyHint =>
      'Vos recherches récentes apparaîtront ici';

  @override
  String get allJobs => 'Tous les emplois';

  @override
  String get nearby => 'À proximité';

  @override
  String get saved2 => 'Enregistrés';

  @override
  String get remote => 'À distance';

  @override
  String get inPerson => 'En personne';

  @override
  String get aboutTheJob => 'À propos du poste';

  @override
  String get aboutCompany => 'À propos de l\'entreprise';

  @override
  String get applyForJob => 'Postuler à cet emploi';

  @override
  String get unsaveJob => 'Retirer';

  @override
  String get noJobsNearby => 'Aucun emploi à proximité';

  @override
  String get noSavedJobs => 'Aucun emploi enregistré';

  @override
  String get adjustFilters => 'Ajustez vos filtres pour voir plus d\'emplois';

  @override
  String get fullTime => 'Temps plein';

  @override
  String get partTime => 'Temps partiel';

  @override
  String get temporary => 'Temporaire';

  @override
  String get freelance => 'Indépendant';

  @override
  String postedAgo(String time) {
    return 'Publié $time';
  }

  @override
  String kmAway(String km) {
    return 'à $km km';
  }

  @override
  String get jobDetails => 'Détails du poste';

  @override
  String get aboutThisRole => 'À propos de ce poste';

  @override
  String get aboutTheBusiness => 'À propos de l\'entreprise';

  @override
  String get urgentHiring => 'Recrutement urgent';

  @override
  String get distanceRadius => 'Rayon de distance';

  @override
  String get contractType => 'Type de contrat';

  @override
  String get shiftType => 'Type d\'horaire';

  @override
  String get all => 'Tous';

  @override
  String get casual => 'Occasionnel';

  @override
  String get seasonal => 'Saisonnier';

  @override
  String get morning => 'Matin';

  @override
  String get afternoon => 'Après-midi';

  @override
  String get evening => 'Soirée';

  @override
  String get night => 'Nuit';

  @override
  String get startDate => 'Date de début';

  @override
  String get shiftHours => 'Heures de service';

  @override
  String get category => 'Catégorie';

  @override
  String get venueType => 'Type d\'établissement';

  @override
  String get employment => 'Emploi';

  @override
  String get pay => 'Rémunération';

  @override
  String get duration => 'Durée';

  @override
  String get weeklyHours => 'Heures hebdomadaires';

  @override
  String get businessLocation => 'Lieu de l\'entreprise';

  @override
  String get jobViews => 'Vues de l\'annonce';

  @override
  String positions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count postes',
      one: '1 poste',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '1 mois',
    );
    return '$_temp0';
  }

  @override
  String get myApplications => 'Mes candidatures';

  @override
  String get active => 'Active';

  @override
  String get interviewStatus => 'Entretien';

  @override
  String get rejected => 'Refusée';

  @override
  String get offer => 'Offre';

  @override
  String appliedOn(String date) {
    return 'Candidature le $date';
  }

  @override
  String get viewJob => 'Voir l\'annonce';

  @override
  String get withdraw => 'Retirer la candidature';

  @override
  String get applicationStatus => 'Statut de la candidature';

  @override
  String get noConversations => 'Aucune conversation pour le moment';

  @override
  String get startConversation =>
      'Répondez à une offre pour commencer à discuter';

  @override
  String get online => 'En ligne';

  @override
  String get offline => 'Hors ligne';

  @override
  String lastSeen(String time) {
    return 'Vu $time';
  }

  @override
  String get newNotification => 'Nouveau';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get yourProfile => 'Votre profil';

  @override
  String completionPercent(int percent) {
    return '$percent % complété';
  }

  @override
  String get personalDetails => 'Informations personnelles';

  @override
  String get phone => 'Téléphone';

  @override
  String get bio => 'Bio';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get addCV => 'Ajouter un CV';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get logoutConfirm => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get subscription => 'Abonnement';

  @override
  String get support => 'Assistance';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get terms => 'Conditions';

  @override
  String get applicationDetails => 'Détails de la candidature';

  @override
  String get timeline => 'Chronologie';

  @override
  String get submitted => 'Envoyée';

  @override
  String get underReview => 'En cours d\'examen';

  @override
  String get interviewScheduled => 'Entretien planifié';

  @override
  String get offerExtended => 'Offre envoyée';

  @override
  String get withdrawApp => 'Retirer la candidature';

  @override
  String get withdrawConfirm =>
      'Voulez-vous vraiment retirer cette candidature ?';

  @override
  String get applicationWithdrawn => 'Candidature retirée';

  @override
  String get statusApplied => 'Envoyée';

  @override
  String get statusInReview => 'En examen';

  @override
  String get statusInterview => 'Entretien';

  @override
  String get statusHired => 'Embauché';

  @override
  String get statusClosed => 'Clôturée';

  @override
  String get statusRejected => 'Refusée';

  @override
  String get statusOffer => 'Offre';

  @override
  String get messagesSearch => 'Rechercher des messages…';

  @override
  String get noMessagesTitle => 'Aucun message pour le moment';

  @override
  String get noMessagesSubtitle =>
      'Répondez à une offre pour commencer à discuter';

  @override
  String get youOnline => 'Vous êtes en ligne';

  @override
  String get noNotificationsTitle => 'Aucune notification pour le moment';

  @override
  String get noNotificationsSubtitle =>
      'Nous vous avertirons dès qu\'il se passera quelque chose';

  @override
  String get today2 => 'Aujourd\'hui';

  @override
  String get earlier => 'Plus tôt';

  @override
  String get completeYourProfile => 'Complétez votre profil';

  @override
  String get profileCompletion => 'Complétion du profil';

  @override
  String get personalInfo => 'Infos personnelles';

  @override
  String get professional => 'Professionnel';

  @override
  String get preferences => 'Préférences';

  @override
  String get documents => 'Documents';

  @override
  String get myCV => 'Mon CV';

  @override
  String get premium => 'Premium';

  @override
  String get addLanguages => 'Ajouter des langues';

  @override
  String get addExperience => 'Ajouter une expérience';

  @override
  String get addAvailability => 'Ajouter une disponibilité';

  @override
  String get matchesTitle => 'Vos correspondances';

  @override
  String get noMatchesTitle => 'Aucune correspondance pour le moment';

  @override
  String get noMatchesSubtitle =>
      'Continuez à postuler — vos correspondances apparaîtront ici';

  @override
  String get interestedBusinesses => 'Entreprises intéressées';

  @override
  String get accept => 'Accepter';

  @override
  String get decline => 'Décliner';

  @override
  String get newMatch => 'Nouvelle correspondance';

  @override
  String get quickPlugTitle => 'Quick Plug';

  @override
  String get quickPlugEmpty => 'Aucune nouvelle entreprise pour le moment';

  @override
  String get quickPlugSubtitle =>
      'Revenez plus tard pour de nouvelles opportunités';

  @override
  String get uploadYourCV => 'Téléversez votre CV';

  @override
  String get cvSubtitle =>
      'Ajoutez un CV pour postuler plus vite et vous démarquer';

  @override
  String get chooseFile => 'Choisir un fichier';

  @override
  String get removeCV => 'Supprimer le CV';

  @override
  String get noCVUploaded => 'Aucun CV téléversé';

  @override
  String get discoverCompanies => 'Découvrir les entreprises';

  @override
  String get exploreSubtitle =>
      'Explorez les meilleurs établissements hôteliers';

  @override
  String get follow => 'Suivre';

  @override
  String get following => 'Suivi';

  @override
  String get view => 'Voir';

  @override
  String get selectLanguages => 'Choisir des langues';

  @override
  String selectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get allLanguages => 'Toutes les langues';

  @override
  String get uploadCVBig =>
      'Téléversez votre CV pour pré-remplir votre profil automatiquement et gagner du temps.';

  @override
  String get supportedFormats => 'Formats pris en charge : PDF, DOC, DOCX';

  @override
  String get fillManually => 'Remplir manuellement';

  @override
  String get fillManuallySubtitle =>
      'Saisissez vos informations vous-même et complétez votre profil étape par étape.';

  @override
  String get photoUploadSoon =>
      'Téléversement de photo bientôt disponible — utilisez en attendant un avatar professionnel.';

  @override
  String get yourCV => 'Votre CV';

  @override
  String get aboutYou => 'À propos de vous';

  @override
  String get optional => 'Optionnel';

  @override
  String get completeProfile => 'Compléter le profil';

  @override
  String get openToRelocation => 'Ouvert à la mobilité';

  @override
  String get matchLabel => 'Match';

  @override
  String get accepted => 'Accepté';

  @override
  String get deny => 'Refuser';

  @override
  String get featured => 'Mis en avant';

  @override
  String get reviewYourProfile => 'Vérifiez votre profil';

  @override
  String get nothingSavedYet =>
      'Rien ne sera enregistré tant que vous n\'aurez pas confirmé.';

  @override
  String get editAnyField =>
      'Vous pouvez modifier tous les champs extraits avant de sauvegarder.';

  @override
  String get saveToProfile => 'Enregistrer dans le profil';

  @override
  String get findCompanies => 'Trouver des entreprises';

  @override
  String get mapView => 'Vue carte';

  @override
  String get mapComingSoon => 'Vue carte bientôt disponible.';

  @override
  String get noCompaniesFound => 'Aucune entreprise trouvée';

  @override
  String get tryWiderRadius =>
      'Essayez un rayon plus large ou une autre catégorie.';

  @override
  String get verifiedOnly => 'Vérifiées uniquement';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String get available => 'Disponible';

  @override
  String lookingFor(String role) {
    return 'Recherche : $role';
  }

  @override
  String get boostMyProfile => 'Booster mon profil';

  @override
  String get openToRelocationTravel =>
      'Ouvert à la mobilité / aux déplacements';

  @override
  String get tellEmployersAboutYourself => 'Parlez de vous aux employeurs…';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get contractPreference => 'Préférence de contrat';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get languagePickerSoon => 'Sélecteur de langue bientôt disponible';

  @override
  String get selectCategoryRoleShort => 'Choisir catégorie et rôle';

  @override
  String get cvUploadSoon => 'Téléversement de CV bientôt disponible';

  @override
  String get restorePurchasesSoon =>
      'Restauration des achats bientôt disponible';

  @override
  String get photoUploadShort => 'Téléversement de photo bientôt disponible';

  @override
  String get hireBestTalent =>
      'Recrutez les meilleurs talents de l\'hôtellerie';

  @override
  String get businessLoginSub =>
      'Publiez des offres et connectez-vous avec des candidats vérifiés.';

  @override
  String get lookingForWork => 'Vous cherchez un emploi ? ';

  @override
  String get postJob => 'Publier une offre';

  @override
  String get editJob => 'Modifier l\'offre';

  @override
  String get jobTitle => 'Intitulé du poste';

  @override
  String get jobDescription2 => 'Description du poste';

  @override
  String get publish => 'Publier';

  @override
  String get saveDraft => 'Enregistrer le brouillon';

  @override
  String get applicantsTitle => 'Candidats';

  @override
  String get newApplicants => 'Nouveaux candidats';

  @override
  String get noApplicantsYet => 'Aucun candidat pour le moment';

  @override
  String get noApplicantsSubtitle =>
      'Les candidats apparaîtront ici dès qu\'ils postuleront.';

  @override
  String get scheduleInterview => 'Planifier un entretien';

  @override
  String get sendInvite => 'Envoyer l\'invitation';

  @override
  String get interviewSent => 'Invitation d\'entretien envoyée';

  @override
  String get rejectCandidate => 'Refuser';

  @override
  String get shortlistCandidate => 'Présélectionner';

  @override
  String get hiringDashboard => 'TABLEAU DE BORD RECRUTEMENT';

  @override
  String get yourPipelineActive => 'Votre pipeline\nest actif';

  @override
  String get postJobToStart => 'Publiez une offre pour commencer à recruter';

  @override
  String reviewApplicants(int count) {
    return 'Examinez $count nouveaux candidats';
  }

  @override
  String replyMessages(int count) {
    return 'Répondez à $count messages non lus';
  }

  @override
  String get interviews2 => 'Entretiens';

  @override
  String get businessProfile => 'Profil d\'entreprise';

  @override
  String get venueGallery => 'Galerie de l\'établissement';

  @override
  String get addPhotos => 'Ajouter des photos';

  @override
  String get businessName => 'Nom de l\'entreprise';

  @override
  String get venueTypeLabel => 'Type d\'établissement';

  @override
  String selectedItems(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get hiringProgress => 'Progression du recrutement';

  @override
  String get unlockBusinessPremium => 'Débloquer Business Premium';

  @override
  String get businessPremiumSubtitle =>
      'Accès prioritaire aux meilleurs candidats';

  @override
  String get scheduleFromApplicants => 'Planifier depuis les candidats';

  @override
  String get recentApplicants => 'Candidats récents';

  @override
  String get viewAll => 'Tout voir ›';

  @override
  String get recentActivity => 'Activité récente';

  @override
  String get candidatePipeline => 'Pipeline de candidats';

  @override
  String get allApplicants => 'Tous les candidats';

  @override
  String get searchCandidates => 'Rechercher candidats, offres, entretiens…';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get allTime => 'Tout le temps';

  @override
  String get post => 'Publication';

  @override
  String get candidates => 'Candidats';

  @override
  String get applicantDetail => 'Détails du candidat';

  @override
  String get candidateProfile => 'Profil du candidat';

  @override
  String get shortlistTitle => 'Présélection';

  @override
  String get noShortlistedCandidates =>
      'Aucun candidat présélectionné pour le moment';

  @override
  String get shortlistEmpty =>
      'Les candidats que vous présélectionnez apparaîtront ici';

  @override
  String get removeFromShortlist => 'Retirer de la présélection';

  @override
  String get viewMessages => 'Voir les messages';

  @override
  String get manageJobs => 'Gérer les offres';

  @override
  String get yourJobs => 'Vos offres';

  @override
  String get noJobsPosted => 'Aucune offre publiée';

  @override
  String get noJobsPostedSubtitle =>
      'Publiez votre première offre pour commencer à recruter';

  @override
  String get draftJobs => 'Brouillons';

  @override
  String get activeJobs => 'Actives';

  @override
  String get expiredJobs => 'Expirées';

  @override
  String get closedJobs => 'Clôturées';

  @override
  String get createJob => 'Créer une offre';

  @override
  String get jobDetailsTitle => 'Détails de l\'offre';

  @override
  String get salaryRange => 'Fourchette salariale';

  @override
  String get currency => 'Devise';

  @override
  String get monthly => 'Mensuel';

  @override
  String get annual => 'Annuel';

  @override
  String get hourly => 'Horaire';

  @override
  String get minSalary => 'Min';

  @override
  String get maxSalary => 'Max';

  @override
  String get perks => 'Avantages';

  @override
  String get addPerk => 'Ajouter un avantage';

  @override
  String get remove => 'Supprimer';

  @override
  String get preview => 'Aperçu';

  @override
  String get publishJob => 'Publier l\'offre';

  @override
  String get jobPublished => 'Offre publiée';

  @override
  String get jobUpdated => 'Offre mise à jour';

  @override
  String get jobSavedDraft => 'Enregistrée en brouillon';

  @override
  String get fillRequired => 'Veuillez remplir les champs obligatoires';

  @override
  String get jobUrgent => 'Marquer comme urgent';

  @override
  String get addAtLeastOne => 'Ajoutez au moins une exigence';

  @override
  String get createUpdate => 'Créer une publication';

  @override
  String get shareCompanyNews => 'Partagez l\'actualité de l\'entreprise';

  @override
  String get addStory => 'Ajouter une story';

  @override
  String get showWorkplace => 'Montrez votre lieu de travail';

  @override
  String get viewShortlist => 'Voir la présélection';

  @override
  String get yourSavedCandidates => 'Vos candidats enregistrés';

  @override
  String get inviteCandidate => 'Inviter le candidat';

  @override
  String get reachOutDirectly => 'Contactez directement';

  @override
  String activeJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offres actives',
      one: '1 offre active',
    );
    return '$_temp0';
  }

  @override
  String get employmentType => 'Type d\'emploi';

  @override
  String get requiredRole => 'Rôle requis';

  @override
  String get selectCategoryRole2 => 'Choisir catégorie et rôle';

  @override
  String get hiresNeeded => 'Embauches nécessaires';

  @override
  String get compensation => 'Rémunération';

  @override
  String get useSalaryRange => 'Utiliser une fourchette salariale';

  @override
  String get contractDuration => 'Durée du contrat';

  @override
  String get limitReached => 'Limite atteinte';

  @override
  String get upgradePlan => 'Passer à un plan supérieur';

  @override
  String usingXofY(int used, int total) {
    return 'Vous utilisez $used offres sur $total.';
  }

  @override
  String get businessInterviewsTitle => 'Entretiens';

  @override
  String get noInterviewsYet => 'Aucun entretien planifié';

  @override
  String get scheduleFirstInterview =>
      'Planifiez votre premier entretien avec un candidat';

  @override
  String get sendInterviewInvite => 'Envoyer l\'invitation à un entretien';

  @override
  String get interviewSentTitle => 'Invitation envoyée !';

  @override
  String get interviewSentSubtitle => 'Le candidat a été notifié.';

  @override
  String get scheduleInterviewTitle => 'Planifier un entretien';

  @override
  String get interviewType => 'Type d\'entretien';

  @override
  String get inPersonInterview => 'En personne';

  @override
  String get videoCallInterview => 'Appel vidéo';

  @override
  String get phoneCallInterview => 'Appel téléphonique';

  @override
  String get interviewDate => 'Date';

  @override
  String get interviewTime => 'Heure';

  @override
  String get interviewLocation => 'Lieu';

  @override
  String get interviewNotes => 'Notes';

  @override
  String get optionalLabel => 'Optionnel';

  @override
  String get sendInviteCta => 'Envoyer l\'invitation';

  @override
  String messagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String get noNewMessages => 'Aucun nouveau message';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get currentPlan => 'Forfait actuel';

  @override
  String get manage => 'Gérer';

  @override
  String get upgrade => 'Passer à supérieur';

  @override
  String get renewalDate => 'Date de renouvellement';

  @override
  String get nearbyTalent => 'Talents à proximité';

  @override
  String get searchNearby => 'Rechercher à proximité';

  @override
  String get communityTitle => 'Communauté';

  @override
  String get createPost => 'Créer une publication';

  @override
  String get insights => 'Statistiques';

  @override
  String get viewsLabel => 'Vues';

  @override
  String get applicationsLabel => 'Candidatures';

  @override
  String get conversionRate => 'Taux de conversion';

  @override
  String get topPerformingJob => 'Annonce la plus performante';

  @override
  String get viewAllSimple => 'Tout voir';

  @override
  String get viewAllApplicantsForJob =>
      'Voir tous les candidats pour cette offre';

  @override
  String get noUpcomingInterviews => 'Aucun entretien à venir';

  @override
  String get noActivityYet => 'Aucune activité pour le moment';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get renewsAutomatically => 'Renouvellement automatique';

  @override
  String get plagitBusinessPlans => 'Forfaits Plagit Business';

  @override
  String get scaleYourHiringSubtitle =>
      'Développez vos recrutements avec le forfait adapté à votre entreprise.';

  @override
  String get yearly => 'Annuel';

  @override
  String get saveWithAnnualBilling => 'Économisez avec la facturation annuelle';

  @override
  String get chooseYourPlanSubtitle =>
      'Choisissez le forfait adapté à vos besoins de recrutement.';

  @override
  String continueWithPlan(String plan) {
    return 'Continuer avec $plan';
  }

  @override
  String get subscriptionAutoRenewNote =>
      'L\'abonnement se renouvelle automatiquement. Annulez à tout moment dans les Paramètres.';

  @override
  String get purchaseFlowComingSoon => 'Achat bientôt disponible';

  @override
  String get applicant => 'Candidat';

  @override
  String get applicantNotFound => 'Candidat introuvable';

  @override
  String get cvViewerComingSoon => 'Visionneuse de CV bientôt disponible';

  @override
  String get viewCV => 'Voir le CV';

  @override
  String get application => 'Candidature';

  @override
  String get messagingComingSoon => 'Messagerie bientôt disponible';

  @override
  String get interviewConfirmed => 'Entretien confirmé';

  @override
  String get interviewMarkedCompleted => 'Entretien marqué comme terminé';

  @override
  String get cancelInterviewConfirm =>
      'Voulez-vous vraiment annuler cet entretien ?';

  @override
  String get yesCancel => 'Oui, annuler';

  @override
  String get interviewNotFound => 'Entretien introuvable';

  @override
  String get openingMeetingLink => 'Ouverture du lien de réunion…';

  @override
  String get rescheduleComingSoon => 'Replanification bientôt disponible';

  @override
  String get notesFeatureComingSoon => 'Notes bientôt disponibles';

  @override
  String get candidateMarkedHired => 'Candidat marqué comme embauché !';

  @override
  String get feedbackComingSoon => 'Avis bientôt disponibles';

  @override
  String get googleMapsComingSoon =>
      'Intégration Google Maps bientôt disponible';

  @override
  String get noCandidatesNearby => 'Aucun candidat à proximité';

  @override
  String get tryExpandingRadius =>
      'Essayez d\'élargir votre rayon de recherche.';

  @override
  String get candidate => 'Candidat';

  @override
  String get forOpenPosition => 'Pour poste ouvert';

  @override
  String get dateAndTimeUpper => 'DATE ET HEURE';

  @override
  String get interviewTypeUpper => 'TYPE D\'ENTRETIEN';

  @override
  String get timezoneUpper => 'FUSEAU HORAIRE';

  @override
  String get highlights => 'Points forts';

  @override
  String get cvNotAvailable => 'CV non disponible';

  @override
  String get cvWillAppearHere => 'Apparaîtra ici une fois téléversé';

  @override
  String get seenEveryone => 'Vous avez tout vu';

  @override
  String get checkBackForCandidates =>
      'Revenez plus tard pour de nouveaux candidats.';

  @override
  String get dailyLimitReached => 'Limite quotidienne atteinte';

  @override
  String get upgradeForUnlimitedSwipes =>
      'Passez à un forfait supérieur pour des swipes illimités.';

  @override
  String get distanceUpper => 'DISTANCE';

  @override
  String get inviteToInterview => 'Inviter à un entretien';

  @override
  String get details => 'Détails';

  @override
  String get shortlistedSuccessfully => 'Ajouté à la présélection';

  @override
  String get tabDashboard => 'Tableau de bord';

  @override
  String get tabCandidates => 'Candidats';

  @override
  String get tabActivity => 'Activité';

  @override
  String get statusPosted => 'Publié';

  @override
  String get statusApplicants => 'Candidats';

  @override
  String get statusInterviewsShort => 'Entretiens';

  @override
  String get statusHiredShort => 'Embauchés';

  @override
  String get jobLiveVisible => 'Votre annonce est en ligne et visible';

  @override
  String get postJobShort => 'Publier';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get online2 => 'En ligne';

  @override
  String get candidateUpper => 'CANDIDAT';

  @override
  String get searchConversationsHint =>
      'Rechercher conversations, candidats, rôles…';

  @override
  String get filterUnread => 'Non lus';

  @override
  String get filterAll => 'Tous';

  @override
  String get whenCandidatesMessage =>
      'Lorsque les candidats vous écrivent, les conversations apparaissent ici.';

  @override
  String get trySwitchingFilter => 'Essayez un autre filtre.';

  @override
  String get reply => 'Répondre';

  @override
  String get selectItems => 'Sélectionner des éléments';

  @override
  String countSelected(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deleteConversation => 'Supprimer la conversation ?';

  @override
  String get deleteAllConversations => 'Supprimer toutes les conversations ?';

  @override
  String get deleteSelectedNote =>
      'Les conversations sélectionnées seront supprimées de votre boîte. Le candidat garde sa copie.';

  @override
  String get deleteAll => 'Tout supprimer';

  @override
  String get selectConversations => 'Sélectionner les conversations';

  @override
  String get feedTab => 'Fil';

  @override
  String get myPostsTab => 'Mes publications';

  @override
  String get savedTab => 'Enregistrés';

  @override
  String postingAs(String name) {
    return 'Publier en tant que $name';
  }

  @override
  String get noPostsYet => 'Vous n\'avez rien publié';

  @override
  String get nothingHereYet => 'Rien ici pour le moment';

  @override
  String get shareVenueUpdate =>
      'Partagez une actualité de votre établissement pour développer votre présence communautaire.';

  @override
  String get communityPostsAppearHere =>
      'Les publications de la communauté apparaîtront ici.';

  @override
  String get createFirstPost => 'Créer la première publication';

  @override
  String get yourPostUpper => 'VOTRE PUBLICATION';

  @override
  String get businessLabel => 'Entreprise';

  @override
  String get profileNotAvailable => 'Profil non disponible';

  @override
  String get companyProfile => 'Profil d\'entreprise';

  @override
  String get premiumVenue => 'Établissement premium';

  @override
  String get businessDetailsTitle => 'Détails de l\'entreprise';

  @override
  String get businessNameLabel => 'Nom de l\'entreprise';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get locationLabel => 'Localisation';

  @override
  String get verificationLabel => 'Vérification';

  @override
  String get pendingLabel => 'En attente';

  @override
  String get notSet => 'Non défini';

  @override
  String get contactLabel => 'Contact';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get companyNameField => 'Nom de l\'entreprise';

  @override
  String get phoneField => 'Téléphone';

  @override
  String get locationField => 'Localisation';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutTitle => 'Se déconnecter ?';

  @override
  String get signOutConfirm => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String activeCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actives',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux cette semaine',
      one: '1 nouveau cette semaine',
    );
    return '$_temp0';
  }

  @override
  String get jobStatusActive => 'Active';

  @override
  String get jobStatusPaused => 'En pause';

  @override
  String get jobStatusClosed => 'Clôturée';

  @override
  String get jobStatusDraft => 'Brouillon';

  @override
  String get contractCasual => 'Occasionnel';

  @override
  String get planBasic => 'Basic';

  @override
  String get planPro => 'Pro';

  @override
  String get planPremium => 'Premium';

  @override
  String get bestForMaxVisibility => 'Idéal pour une visibilité maximale';

  @override
  String saveDollarsPerYear(String currency, String amount) {
    return 'Économisez $currency$amount/an';
  }

  @override
  String get planBasicFeature1 => 'Jusqu\'à 3 offres publiées';

  @override
  String get planBasicFeature2 => 'Consultation des profils de candidats';

  @override
  String get planBasicFeature3 => 'Recherche de candidats basique';

  @override
  String get planBasicFeature4 => 'Assistance par e-mail';

  @override
  String get planProFeature1 => 'Jusqu\'à 10 offres publiées';

  @override
  String get planProFeature2 => 'Recherche avancée de candidats';

  @override
  String get planProFeature3 => 'Tri prioritaire des candidats';

  @override
  String get planProFeature4 => 'Accès Quick Plug';

  @override
  String get planProFeature5 => 'Assistance par chat';

  @override
  String get planPremiumFeature1 => 'Offres d\'emploi illimitées';

  @override
  String get planPremiumFeature2 => 'Annonces mises en avant';

  @override
  String get planPremiumFeature3 => 'Analyses avancées';

  @override
  String get planPremiumFeature4 => 'Quick Plug illimité';

  @override
  String get planPremiumFeature5 => 'Matching prioritaire des candidats';

  @override
  String get planPremiumFeature6 => 'Gestionnaire de compte dédié';

  @override
  String get currentSelectionCheck => 'Sélection actuelle ✓';

  @override
  String selectPlanName(String plan) {
    return 'Choisir $plan';
  }

  @override
  String get perYear => '/an';

  @override
  String get perMonth => '/mois';

  @override
  String get jobTitleHintExample => 'ex. Chef de cuisine';

  @override
  String get locationHintExample => 'ex. Dubaï, EAU';

  @override
  String annualSalaryLabel(String currency) {
    return 'Salaire annuel ($currency)';
  }

  @override
  String monthlyPayLabel(String currency) {
    return 'Salaire mensuel ($currency)';
  }

  @override
  String hourlyRateLabel(String currency) {
    return 'Taux horaire ($currency)';
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
  String get hoursPerWeekLabel => 'Heures / semaine';

  @override
  String get expectedHoursWeekLabel => 'Heures prévues / semaine (optionnel)';

  @override
  String get bonusTipsLabel => 'Prime / Pourboires (optionnel)';

  @override
  String get bonusTipsHint => 'ex. Pourboires et frais de service';

  @override
  String get housingIncludedLabel => 'Logement inclus';

  @override
  String get travelIncludedLabel => 'Déplacement inclus';

  @override
  String get overtimeAvailableLabel => 'Heures supplémentaires disponibles';

  @override
  String get flexibleScheduleLabel => 'Horaires flexibles';

  @override
  String get weekendShiftsLabel => 'Service le week-end';

  @override
  String get describeRoleHint =>
      'Décrivez le poste, les responsabilités et ce qui rend cette offre unique…';

  @override
  String get requirementsHint =>
      'Compétences, expérience, certifications requises…';

  @override
  String previewPrefix(String text) {
    return 'Aperçu : $text';
  }

  @override
  String monthsShort(int count) {
    return '$count mois';
  }

  @override
  String get roleAll => 'Tous';

  @override
  String get roleChef => 'Chef';

  @override
  String get roleWaiter => 'Serveur';

  @override
  String get roleBartender => 'Barman';

  @override
  String get roleHost => 'Hôte';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleReception => 'Réception';

  @override
  String get roleKitchenPorter => 'Plongeur';

  @override
  String get roleRelocate => 'Mobilité';

  @override
  String get experience02Years => '0-2 ans';

  @override
  String get experience35Years => '3-5 ans';

  @override
  String get experience5PlusYears => '5+ ans';

  @override
  String get roleUpper => 'RÔLE';

  @override
  String get experienceUpper => 'EXPÉRIENCE';

  @override
  String get cvLabel => 'CV';

  @override
  String get addShort => 'Ajouter';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String candidatesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidats trouvés',
      one: '1 candidat trouvé',
    );
    return '$_temp0';
  }

  @override
  String get maxKmLabel => 'max 50 km';

  @override
  String get shortlistAction => 'Présélectionner';

  @override
  String get messageAction => 'Message';

  @override
  String get interviewAction => 'Entretien';

  @override
  String get viewAction => 'Voir';

  @override
  String get rejectAction => 'Refuser';

  @override
  String get basedIn => 'Basé à';

  @override
  String get verificationPending => 'Vérification en attente';

  @override
  String get refreshAction => 'Actualiser';

  @override
  String get upgradeAction => 'Passer Premium';

  @override
  String get searchJobsByTitleHint => 'Rechercher par intitulé, rôle ou lieu…';

  @override
  String xShortlisted(String name) {
    return '$name présélectionné(e)';
  }

  @override
  String xRejected(String name) {
    return '$name refusé(e)';
  }

  @override
  String rejectConfirmName(String name) {
    return 'Voulez-vous vraiment refuser $name ?';
  }

  @override
  String appliedToRoleOn(String role, String date) {
    return 'Candidature envoyée pour $role le $date';
  }

  @override
  String appliedDatePrefix(String date) {
    return 'Candidature envoyée le $date';
  }

  @override
  String get salaryExpectationTitle => 'Prétentions salariales';

  @override
  String get previousEmployer => 'Employeur précédent';

  @override
  String get earlierVenue => 'Établissement antérieur';

  @override
  String get presentLabel => 'En cours';

  @override
  String get skillCustomerService => 'Service client';

  @override
  String get skillTeamwork => 'Travail d\'équipe';

  @override
  String get skillCommunication => 'Communication';

  @override
  String get stepApplied => 'Candidature envoyée';

  @override
  String get stepViewed => 'Vu';

  @override
  String get stepShortlisted => 'Présélectionné';

  @override
  String get stepInterviewScheduled => 'Entretien planifié';

  @override
  String get stepRejected => 'Refusé';

  @override
  String get stepUnderReview => 'En cours d\'examen';

  @override
  String get stepPendingReview => 'En attente d\'examen';

  @override
  String get sortNewest => 'Plus récents';

  @override
  String get sortMostExperienced => 'Plus expérimentés';

  @override
  String get sortBestMatch => 'Meilleur match';

  @override
  String get filterApplied => 'Envoyée';

  @override
  String get filterUnderReview => 'En examen';

  @override
  String get filterShortlisted => 'Présélectionnés';

  @override
  String get filterInterview => 'Entretien';

  @override
  String get filterHired => 'Embauchés';

  @override
  String get filterRejected => 'Refusés';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get pending => 'En attente';

  @override
  String get completed => 'Terminé';

  @override
  String get cancelled => 'Annulé';

  @override
  String get videoLabel => 'Vidéo';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get interviewDetails => 'Détails de l\'entretien';

  @override
  String get interviewConfirmedHeadline => 'Entretien confirmé';

  @override
  String get interviewConfirmedSubline =>
      'Tout est prêt. Nous vous rappellerons à l\'approche.';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Heure';

  @override
  String get formatLabel => 'Format';

  @override
  String get joinMeeting => 'Rejoindre';

  @override
  String get viewJobAction => 'Voir l\'offre';

  @override
  String get addToCalendar => 'Ajouter au calendrier';

  @override
  String get needsYourAttention => 'Nécessite votre attention';

  @override
  String get reviewAction => 'Examiner';

  @override
  String applicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidatures',
      one: '1 candidature',
    );
    return '$_temp0';
  }

  @override
  String get sortMostRecent => 'Plus récents';

  @override
  String get interviewScheduledLabel => 'Entretien planifié';

  @override
  String get editAction => 'Modifier';

  @override
  String get currentPlanLabel => 'Forfait actuel';

  @override
  String get freePlan => 'Forfait gratuit';

  @override
  String get profileStrength => 'Force du profil';

  @override
  String get detailsLabel => 'Détails';

  @override
  String get basedInLabel => 'Basé à';

  @override
  String get verificationLabel2 => 'Vérification';

  @override
  String get contactLabel2 => 'Contact';

  @override
  String get notSetLabel => 'Non défini';

  @override
  String get chipAll => 'Tous';

  @override
  String get chipFullTime => 'Temps plein';

  @override
  String get chipPartTime => 'Temps partiel';

  @override
  String get chipTemporary => 'Temporaire';

  @override
  String get chipCasual => 'Occasionnel';

  @override
  String get sortBestMatchLabel => 'Meilleur match';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortBy => 'Trier par';

  @override
  String get featuredBadge => 'Mis en avant';

  @override
  String get urgentBadge => 'Urgent';

  @override
  String get salaryOnRequest => 'Salaire sur demande';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get urgentJobsOnly => 'Offres urgentes uniquement';

  @override
  String get showOnlyUrgentListings =>
      'Afficher uniquement les offres urgentes';

  @override
  String get verifiedBusinessesOnly => 'Entreprises vérifiées uniquement';

  @override
  String get showOnlyVerifiedBusinesses =>
      'Afficher uniquement les entreprises vérifiées';

  @override
  String get split => 'Partage';

  @override
  String get payUpper => 'RÉMUNÉRATION';

  @override
  String get typeUpper => 'TYPE';

  @override
  String get whereUpper => 'LIEU';

  @override
  String get payLabel => 'Rémunération';

  @override
  String get typeLabel => 'Type';

  @override
  String get whereLabel => 'Lieu';

  @override
  String get whereYouWillWork => 'Où vous travaillerez';

  @override
  String get mapPreviewDirections =>
      'Aperçu carte · ouvrir pour l\'itinéraire complet';

  @override
  String get directionsAction => 'Itinéraire';

  @override
  String get communityTabForYou => 'Pour vous';

  @override
  String get communityTabFollowing => 'Abonnements';

  @override
  String get communityTabNearby => 'À proximité';

  @override
  String get communityTabSaved => 'Enregistrés';

  @override
  String get viewProfileAction => 'Voir le profil';

  @override
  String get copyLinkAction => 'Copier le lien';

  @override
  String get savePostAction => 'Enregistrer la publication';

  @override
  String get unsavePostAction => 'Retirer la publication';

  @override
  String get hideThisPost => 'Masquer cette publication';

  @override
  String get reportPost => 'Signaler la publication';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get newPostTitle => 'Nouvelle publication';

  @override
  String get youLabel => 'Vous';

  @override
  String get postingToCommunityAsBusiness =>
      'Publication dans la communauté en tant qu\'Entreprise';

  @override
  String get postingToCommunityAsPro =>
      'Publication dans la communauté en tant que Pro de l\'hôtellerie';

  @override
  String get whatsOnYourMind => 'Qu\'avez-vous en tête ?';

  @override
  String get publishAction => 'Publier';

  @override
  String get attachmentPhoto => 'Photo';

  @override
  String get attachmentVideo => 'Vidéo';

  @override
  String get attachmentLocation => 'Lieu';

  @override
  String get boostMyProfileCta => 'Booster mon profil';

  @override
  String get unlockYourFullPotential => 'Libérez tout votre potentiel';

  @override
  String get annualPlan => 'Annuel';

  @override
  String get monthlyPlan => 'Mensuel';

  @override
  String get bestValueBadge => 'MEILLEURE OFFRE';

  @override
  String get whatsIncluded => 'Ce qui est inclus';

  @override
  String get continueWithAnnual => 'Continuer avec Annuel';

  @override
  String get continueWithMonthly => 'Continuer avec Mensuel';

  @override
  String get maybeLater => 'Plus tard';

  @override
  String get restorePurchasesLabel => 'Restaurer les achats';

  @override
  String get subscriptionAutoRenewsNote =>
      'L\'abonnement se renouvelle automatiquement. Annulez à tout moment dans les Paramètres.';

  @override
  String get appStatusPillApplied => 'Envoyée';

  @override
  String get appStatusPillUnderReview => 'En examen';

  @override
  String get appStatusPillShortlisted => 'Présélectionné';

  @override
  String get appStatusPillInterviewInvited => 'Entretien proposé';

  @override
  String get appStatusPillInterviewScheduled => 'Entretien planifié';

  @override
  String get appStatusPillHired => 'Embauché';

  @override
  String get appStatusPillRejected => 'Refusée';

  @override
  String get appStatusPillWithdrawn => 'Retirée';

  @override
  String get jobActionPause => 'Suspendre l\'offre';

  @override
  String get jobActionResume => 'Reprendre l\'offre';

  @override
  String get jobActionClose => 'Clôturer l\'offre';

  @override
  String get statusConfirmedLower => 'confirmé';

  @override
  String get postInsightsTitle => 'Statistiques de publication';

  @override
  String get postInsightsSubtitle => 'Qui voit votre contenu';

  @override
  String get recentViewers => 'Spectateurs récents';

  @override
  String get lockedBadge => 'VERROUILLÉ';

  @override
  String get viewerBreakdown => 'Répartition des spectateurs';

  @override
  String get viewersByRole => 'Spectateurs par rôle';

  @override
  String get topLocations => 'Principales localisations';

  @override
  String get businesses => 'Entreprises';

  @override
  String get saveToCollectionTitle => 'Enregistrer dans une collection';

  @override
  String get chooseCategory => 'Choisir une catégorie';

  @override
  String get removeFromCollection => 'Retirer de la collection';

  @override
  String newApplicationTemplate(String role) {
    return 'Nouvelle candidature — $role';
  }

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryCookingVideos => 'Vidéos de cuisine';

  @override
  String get categoryJobsTips => 'Conseils emploi';

  @override
  String get categoryHospitalityNews => 'Actu hôtellerie';

  @override
  String get categoryRecipes => 'Recettes';

  @override
  String get categoryOther => 'Autre';

  @override
  String get premiumHeroTagline =>
      'Plus de visibilité, alertes prioritaires et filtres avancés pour les pros de l\'hôtellerie exigeants.';

  @override
  String get benefitAdvancedFilters => 'Filtres de recherche avancés';

  @override
  String get benefitPriorityNotifications => 'Alertes d\'emploi prioritaires';

  @override
  String get benefitProfileVisibility => 'Visibilité accrue du profil';

  @override
  String get benefitPremiumBadge => 'Badge de profil Premium';

  @override
  String get benefitEarlyAccess => 'Accès anticipé aux nouvelles offres';

  @override
  String get unlockCandidatePremium => 'Débloquer Candidate Premium';

  @override
  String get getStartedAction => 'Commencer';

  @override
  String get findYourFirstJob => 'Trouvez votre premier emploi';

  @override
  String get browseHospitalityRolesNearby =>
      'Parcourez des centaines de postes hôteliers près de chez vous';

  @override
  String get seeWhoViewedYourPostTitle => 'Voir qui a vu votre publication';

  @override
  String get upgradeToPremiumCta => 'Passer à Premium';

  @override
  String get upgradeToPremiumSubtitle =>
      'Passez à Premium pour voir les entreprises vérifiées, recruteurs et leaders de l\'hôtellerie qui ont consulté votre contenu.';

  @override
  String get verifiedBusinessViewers => 'Spectateurs d\'entreprises vérifiées';

  @override
  String get recruiterHiringManagerActivity =>
      'Activité des recruteurs et responsables du recrutement';

  @override
  String get cityLevelReachBreakdown => 'Portée au niveau des villes';

  @override
  String liveApplicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en direct',
      one: '1 en direct',
    );
    return '$_temp0';
  }

  @override
  String nearbyJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à proximité',
      one: '1 à proximité',
    );
    return '$_temp0';
  }

  @override
  String jobsNearYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count emplois près de vous',
      one: '1 emploi près de vous',
    );
    return '$_temp0';
  }

  @override
  String applicationsUnderReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidatures en cours d\'examen',
      one: '1 candidature en cours d\'examen',
    );
    return '$_temp0';
  }

  @override
  String interviewsScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entretiens planifiés',
      one: '1 entretien planifié',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages non lus',
      one: '1 message non lu',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesFromEmployersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages non lus d\'employeurs',
      one: '1 message non lu d\'employeurs',
    );
    return '$_temp0';
  }

  @override
  String stepsLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes restantes',
      one: '1 étape restante',
    );
    return '$_temp0';
  }

  @override
  String get profileCompleteGreatWork => 'Profil complet — beau travail';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '1 an',
    );
    return '$_temp0';
  }

  @override
  String get perHour => '/h';

  @override
  String hoursPerWeekShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h/sem',
      one: '1 h/sem',
    );
    return '$_temp0';
  }

  @override
  String forMonthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'pendant $count mois',
      one: 'pendant 1 mois',
    );
    return '$_temp0';
  }

  @override
  String interviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entretiens',
      one: '1 entretien',
    );
    return '$_temp0';
  }

  @override
  String get quickActionFindJobs => 'Trouver des emplois';

  @override
  String get quickActionMyApplications => 'Mes candidatures';

  @override
  String get quickActionUpdateProfile => 'Mettre à jour le profil';

  @override
  String get quickActionCreatePost => 'Créer une publication';

  @override
  String get quickActionViewInterviews => 'Voir les entretiens';

  @override
  String get confirmSubscriptionTitle => 'Confirmer l\'abonnement';

  @override
  String get confirmAndSubscribeCta => 'Confirmer et s\'abonner';

  @override
  String get timelineLabel => 'Chronologie';

  @override
  String get interviewLabel => 'Entretien';

  @override
  String get payOnRequest => 'Rémunération sur demande';

  @override
  String get rateOnRequest => 'Taux sur demande';

  @override
  String get quickActionFindJobsSubtitle =>
      'Découvrez des postes près de chez vous';

  @override
  String get quickActionMyApplicationsSubtitle =>
      'Suivez toutes vos candidatures';

  @override
  String get quickActionUpdateProfileSubtitle =>
      'Améliorez votre visibilité et votre score de match';

  @override
  String get quickActionCreatePostSubtitle =>
      'Partagez votre travail avec la communauté';

  @override
  String get quickActionViewInterviewsSubtitle => 'Préparez-vous pour la suite';

  @override
  String get offerLabel => 'Offre';

  @override
  String hiringForTemplate(String role) {
    return 'Recrute pour $role';
  }

  @override
  String get tapToOpenInMaps => 'Toucher pour ouvrir dans Plans';

  @override
  String get alreadyAppliedToJob => 'Vous avez déjà postulé à cette offre.';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get changeAvatar => 'Changer l\'avatar';

  @override
  String get addPhotoAction => 'Ajouter une photo';

  @override
  String get nationalityLabel => 'Nationalité';

  @override
  String get targetRoleLabel => 'Poste recherché';

  @override
  String get salaryExpectationLabel => 'Prétentions salariales';

  @override
  String get addLanguageCta => '+ Ajouter une langue';

  @override
  String get experienceLabel => 'Expérience';

  @override
  String get nameLabel => 'Nom';

  @override
  String get zeroHours => 'Zéro heure';

  @override
  String get checkInterviewDetailsLine =>
      'Vérifiez les détails de votre entretien';

  @override
  String get interviewInvitedSubline =>
      'L\'employeur souhaite vous rencontrer — confirmez un créneau';

  @override
  String get shortlistedSubline =>
      'Vous êtes présélectionné — attendez l\'étape suivante';

  @override
  String get underReviewSubline => 'L\'employeur examine votre profil';

  @override
  String get hiredHeadline => 'Embauché';

  @override
  String get hiredSubline => 'Félicitations ! Vous avez reçu une offre';

  @override
  String get applicationSubmittedHeadline => 'Candidature envoyée';

  @override
  String get applicationSubmittedSubline =>
      'L\'employeur examinera votre candidature';

  @override
  String get withdrawnHeadline => 'Retirée';

  @override
  String get withdrawnSubline => 'Vous avez retiré cette candidature';

  @override
  String get notSelectedHeadline => 'Non retenu';

  @override
  String get notSelectedSubline => 'Merci de votre intérêt';

  @override
  String jobsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offres trouvées',
      one: '1 offre trouvée',
    );
    return '$_temp0';
  }

  @override
  String applicationsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count au total',
      one: '1 au total',
    );
    return '$_temp0';
  }

  @override
  String applicationsInReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en cours d\'examen',
      one: '1 en cours d\'examen',
    );
    return '$_temp0';
  }

  @override
  String applicationsLiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actives',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String interviewsPendingConfirmTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entretiens en attente — confirmez un créneau.',
      one: '1 entretien en attente — confirmez un créneau.',
    );
    return '$_temp0';
  }

  @override
  String notifInterviewConfirmedTitle(String name) {
    return 'Entretien confirmé — $name';
  }

  @override
  String notifInterviewRequestTitle(String name) {
    return 'Demande d\'entretien — $name';
  }

  @override
  String notifApplicationUpdateTitle(String name) {
    return 'Mise à jour de candidature — $name';
  }

  @override
  String notifOfferReceivedTitle(String name) {
    return 'Offre reçue — $name';
  }

  @override
  String notifMessageFromTitle(String name) {
    return 'Message de — $name';
  }

  @override
  String notifInterviewReminderTitle(String name) {
    return 'Rappel d\'entretien — $name';
  }

  @override
  String notifProfileViewedTitle(String name) {
    return 'Profil consulté — $name';
  }

  @override
  String notifNewJobMatchTitle(String name) {
    return 'Nouveau match d\'emploi — $name';
  }

  @override
  String notifApplicationViewedTitle(String name) {
    return 'Candidature consultée par — $name';
  }

  @override
  String notifShortlistedTitle(String name) {
    return 'Présélectionné chez — $name';
  }

  @override
  String get notifCompleteProfile =>
      'Complétez votre profil pour de meilleurs matchs';

  @override
  String get notifCompleteBusinessProfile =>
      'Complétez le profil de votre entreprise pour plus de visibilité';

  @override
  String notifNewJobViews(String role, String count) {
    return 'Votre offre $role a $count nouvelles vues';
  }

  @override
  String notifAppliedForRole(String name, String role) {
    return '$name a postulé pour $role';
  }

  @override
  String notifNewApplicationNameRole(String name, String role) {
    return 'Nouvelle candidature : $name pour $role';
  }

  @override
  String get chatTyping => 'Écrit…';

  @override
  String get chatStatusSeen => 'Vu';

  @override
  String get chatStatusDelivered => 'Livré';

  @override
  String get entryTagline =>
      'La plateforme de recrutement pour les professionnels de l\'hôtellerie.';

  @override
  String get entryFindWork => 'Trouver un emploi';

  @override
  String get entryFindWorkSubtitle =>
      'Parcourez les offres et faites-vous recruter par les meilleurs établissements';

  @override
  String get entryHireStaff => 'Recruter du personnel';

  @override
  String get entryHireStaffSubtitle =>
      'Publiez des offres et trouvez les meilleurs talents de l\'hôtellerie';

  @override
  String get entryFindCompanies => 'Trouver des entreprises';

  @override
  String get entryFindCompaniesSubtitle =>
      'Découvrez des établissements hôteliers et prestataires de services';

  @override
  String get servicesEntryTitle => 'Recherche d\'entreprises';

  @override
  String get servicesHospitalityServices => 'Services hôteliers';

  @override
  String get servicesEntrySubtitle =>
      'Enregistrez votre entreprise de services ou trouvez des prestataires hôteliers près de chez vous';

  @override
  String get servicesRegisterCardTitle => 'S\'inscrire comme entreprise';

  @override
  String get servicesRegisterCardSubtitle =>
      'Référencez votre service hôtelier et faites-vous découvrir par les clients';

  @override
  String get servicesLookingCardTitle => 'Je cherche une entreprise';

  @override
  String get servicesLookingCardSubtitle =>
      'Trouvez des prestataires hôteliers près de chez vous';

  @override
  String get registerBusinessTitle => 'Inscrivez votre entreprise';

  @override
  String get enterCompanyName => 'Saisissez le nom de l\'entreprise';

  @override
  String get subcategoryOptional => 'Sous-catégorie (optionnel)';

  @override
  String get subcategoryHintFloristDj => 'ex. Fleuriste, Services DJ';

  @override
  String get searchCompaniesHint => 'Rechercher des entreprises…';

  @override
  String get browseCategories => 'Parcourir les catégories';

  @override
  String companiesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entreprises trouvées',
      one: '1 entreprise trouvée',
    );
    return '$_temp0';
  }

  @override
  String get serviceCategoryFoodBeverage =>
      'Fournisseurs alimentation et boissons';

  @override
  String get serviceCategoryEventServices => 'Services événementiels';

  @override
  String get serviceCategoryDecorDesign => 'Décoration et design';

  @override
  String get serviceCategoryEntertainment => 'Divertissement';

  @override
  String get serviceCategoryEquipmentOps => 'Équipement et opérations';

  @override
  String get serviceCategoryCleaningMaintenance => 'Nettoyage et maintenance';

  @override
  String distanceMiles(String value) {
    return '$value mi';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String get postDetailTitle => 'Publication';

  @override
  String get likeAction => 'J\'aime';

  @override
  String get commentAction => 'Commenter';

  @override
  String get saveActionLabel => 'Enregistrer';

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String get addCommentHint => 'Ajouter un commentaire…';

  @override
  String likesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count j\'aime',
      one: '1 j\'aime',
    );
    return '$_temp0';
  }

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commentaires',
      one: '1 commentaire',
    );
    return '$_temp0';
  }

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enregistrements',
      one: '1 enregistrement',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutesShort(int count) {
    return '$count min';
  }

  @override
  String timeAgoHoursShort(int count) {
    return '$count h';
  }

  @override
  String timeAgoDaysShort(int count) {
    return '$count j';
  }

  @override
  String get timeAgoNow => 'maintenant';

  @override
  String get activityTitle => 'Activité';

  @override
  String get activityLikedPost => 'a aimé votre publication';

  @override
  String get activityCommented => 'a commenté votre publication';

  @override
  String get activityStartedFollowing => 'a commencé à vous suivre';

  @override
  String get activityMentioned => 'vous a mentionné';

  @override
  String get activitySystemUpdate => 'vous a envoyé une mise à jour';

  @override
  String get noActivityYetDesc =>
      'Lorsque des personnes aimeront, commenteront ou vous suivront, cela s\'affichera ici.';

  @override
  String get activeStatus => 'Actif';

  @override
  String get activeBadge => 'ACTIF';

  @override
  String get nextRenewalLabel => 'Prochain renouvellement';

  @override
  String get startedLabel => 'Commencé';

  @override
  String get statusLabel => 'Statut';

  @override
  String get billingAndCancellation => 'Facturation et annulation';

  @override
  String get billingAndCancellationCopy =>
      'Votre abonnement est facturé via votre compte App Store / Google Play. Vous pouvez annuler à tout moment depuis les Paramètres de votre appareil — vous conservez l\'accès premium jusqu\'à la date de renouvellement.';

  @override
  String get premiumIsActive => 'Premium est actif';

  @override
  String get premiumThanksCopy =>
      'Merci de soutenir Plagit. Vous avez un accès complet à toutes les fonctionnalités premium.';

  @override
  String get manageSubscription => 'Gérer l\'abonnement';

  @override
  String get candidatePremiumPlanName => 'Candidate Premium';

  @override
  String renewsOnDate(String date) {
    return 'Renouvellement le $date';
  }

  @override
  String get fullViewerAccessLine =>
      'Accès complet aux spectateurs · toutes les statistiques débloquées';

  @override
  String get premiumActiveBadge => 'Premium actif';

  @override
  String get fullInsightsUnlocked =>
      'Statistiques complètes et détails des spectateurs débloqués.';

  @override
  String get noViewersInCategory =>
      'Aucun spectateur dans cette catégorie pour le moment';

  @override
  String get onlyVerifiedViewersShown =>
      'Seuls les spectateurs vérifiés avec un profil public sont affichés.';

  @override
  String get notEnoughDataYet => 'Pas encore assez de données.';

  @override
  String get noViewInsightsYet => 'Aucune statistique de vue pour le moment';

  @override
  String get noViewInsightsDesc =>
      'Les statistiques apparaîtront quand votre publication aura plus de vues.';

  @override
  String get suspiciousEngagementDetected => 'Engagement suspect détecté';

  @override
  String get patternReviewRequired => 'Examen du schéma requis';

  @override
  String get adminInsightsFooter =>
      'Vue admin — mêmes statistiques que l\'auteur, plus les alertes de modération. Agrégées uniquement, aucune identité individuelle de spectateur exposée.';

  @override
  String get viewerKindBusiness => 'Entreprise';

  @override
  String get viewerKindCandidate => 'Candidat';

  @override
  String get viewerKindRecruiter => 'Recruteur';

  @override
  String get viewerKindHiringManager => 'Responsable du recrutement';

  @override
  String get viewerKindBusinessesPlural => 'Entreprises';

  @override
  String get viewerKindCandidatesPlural => 'Candidats';

  @override
  String get viewerKindRecruitersPlural => 'Recruteurs';

  @override
  String get viewerKindHiringManagersPlural => 'Responsables du recrutement';

  @override
  String get searchPeoplePostsVenuesHint =>
      'Rechercher personnes, publications, établissements…';

  @override
  String get searchCommunityTitle => 'Rechercher dans la communauté';

  @override
  String get roleSommelier => 'Sommelier';

  @override
  String get candidatePremiumActivated =>
      'Vous êtes maintenant Candidate Premium';

  @override
  String get purchasesRestoredPremium =>
      'Achats restaurés — vous êtes maintenant Candidate Premium';

  @override
  String get nothingToRestore => 'Rien à restaurer';

  @override
  String get noValidSubscriptionPremiumRemoved =>
      'Aucun abonnement valide trouvé — accès premium retiré';

  @override
  String restoreFailedWithError(String error) {
    return 'Échec de la restauration. $error';
  }

  @override
  String get subscriptionTitleAnnual => 'Candidate Premium · Annuel';

  @override
  String get subscriptionTitleMonthly => 'Candidate Premium · Mensuel';

  @override
  String pricePerYearSlash(String price) {
    return '$price / an';
  }

  @override
  String pricePerMonthSlash(String price) {
    return '$price / mois';
  }

  @override
  String get nearbyJobsTitle => 'Emplois à proximité';

  @override
  String get expandRadius => 'Élargir le rayon';

  @override
  String get noJobsInRadius => 'Aucun emploi dans ce rayon';

  @override
  String jobsWithinRadius(int count, int radius) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count emplois dans un rayon de $radius miles',
      one: '1 emploi dans un rayon de $radius miles',
    );
    return '$_temp0';
  }

  @override
  String get interviewAcceptedSnack => 'Entretien accepté !';

  @override
  String get declineInterviewTitle => 'Décliner l\'entretien';

  @override
  String get declineInterviewConfirm =>
      'Voulez-vous vraiment décliner cet entretien ?';

  @override
  String get addedToCalendar => 'Ajouté au calendrier';

  @override
  String get removeCompanyTitle => 'Retirer ?';

  @override
  String get removeCompanyConfirm =>
      'Voulez-vous vraiment retirer cette entreprise de votre liste enregistrée ?';

  @override
  String get signOutAllRolesConfirm =>
      'Voulez-vous vraiment vous déconnecter de tous les rôles ?';

  @override
  String get tapToViewAllConversations =>
      'Toucher pour voir toutes les conversations';

  @override
  String get savedJobsTitle => 'Emplois enregistrés';

  @override
  String savedJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count emplois enregistrés',
      one: '1 emploi enregistré',
    );
    return '$_temp0';
  }

  @override
  String get removeFromSavedTitle => 'Retirer des enregistrés ?';

  @override
  String get removeFromSavedConfirm =>
      'Cette offre sera retirée de votre liste enregistrée.';

  @override
  String get noSavedJobsSubtitle =>
      'Parcourez les offres et enregistrez celles qui vous plaisent';

  @override
  String get browseJobsAction => 'Parcourir les offres';

  @override
  String matchingJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offres correspondantes',
      one: '1 offre correspondante',
    );
    return '$_temp0';
  }

  @override
  String get savedPostsTitle => 'Publications enregistrées';

  @override
  String get searchSavedPostsHint =>
      'Rechercher dans les publications enregistrées…';

  @override
  String get skipAction => 'Passer';

  @override
  String get submitAction => 'Envoyer';

  @override
  String get doneAction => 'Terminé';

  @override
  String get resetYourPasswordTitle => 'Réinitialiser votre mot de passe';

  @override
  String get enterEmailForResetCode =>
      'Saisissez votre e-mail pour recevoir un code';

  @override
  String get sendResetCode => 'Envoyer le code';

  @override
  String get enterResetCode => 'Saisir le code';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get passwordResetComplete => 'Mot de passe réinitialisé';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get passwordChanged => 'Mot de passe changé';

  @override
  String get passwordUpdatedShort => 'Votre mot de passe a été mis à jour.';

  @override
  String get passwordUpdatedRelogin =>
      'Votre mot de passe a été mis à jour. Reconnectez-vous avec le nouveau.';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get passwordRequirements => 'Exigences du mot de passe';

  @override
  String get newPasswordHint => 'Nouveau mot de passe (min 8 caractères)';

  @override
  String get confirmPasswordField => 'Confirmer le mot de passe';

  @override
  String get enterEmailField => 'Saisir l\'e-mail';

  @override
  String get enterPasswordField => 'Saisir le mot de passe';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String get selectHowToUse =>
      'Choisissez comment utiliser Plagit aujourd\'hui';

  @override
  String get continueAsCandidate => 'Continuer en tant que candidat';

  @override
  String get continueAsBusiness => 'Continuer en tant qu\'entreprise';

  @override
  String get signInToPlagit => 'Se connecter à Plagit';

  @override
  String get enterCredentials => 'Saisissez vos identifiants pour continuer';

  @override
  String get adminPortal => 'Portail Admin';

  @override
  String get plagitAdmin => 'Plagit Admin';

  @override
  String get signInToAdminAccount => 'Connectez-vous à votre compte admin';

  @override
  String get admin => 'Admin';

  @override
  String get searchJobsRolesRestaurantsHint =>
      'Rechercher emplois, rôles, restaurants...';

  @override
  String get exploreNearbyJobs => 'Explorer les emplois à proximité';

  @override
  String get findOpportunitiesOnMap => 'Trouvez des opportunités sur la carte';

  @override
  String get featuredJobs => 'Emplois en vedette';

  @override
  String get jobsNearYou => 'Emplois près de vous';

  @override
  String get jobsMatchingRoleType =>
      'Emplois correspondant à votre rôle et type';

  @override
  String get availableNow => 'Disponible maintenant';

  @override
  String get noNearbyJobsYet => 'Aucun emploi à proximité';

  @override
  String get tryIncreasingRadius =>
      'Élargissez le rayon ou changez les filtres';

  @override
  String get checkBackForOpportunities =>
      'Revenez bientôt pour de nouvelles opportunités';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get okAction => 'OK';

  @override
  String get onlineNow => 'En ligne maintenant';

  @override
  String get businessUpper => 'ENTREPRISE';

  @override
  String get waitingForBusinessFirstMessage =>
      'En attente du premier message de l\'entreprise';

  @override
  String get whenEmployersMessageYou =>
      'Les messages des employeurs apparaîtront ici.';

  @override
  String get replyToCandidate => 'Répondre au candidat…';

  @override
  String get quickFeedback => 'Avis rapide';

  @override
  String get helpImproveMatches => 'Aidez-nous à améliorer vos matchs';

  @override
  String get thanksForFeedback => 'Merci pour votre avis !';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get notificationSettings => 'Paramètres de notifications';

  @override
  String get privacyAndSecurity => 'Confidentialité et sécurité';

  @override
  String get helpAndSupport => 'Aide et support';

  @override
  String get activeRoleUpper => 'RÔLE ACTIF';

  @override
  String get meetingLink => 'Lien de réunion';

  @override
  String get joinMeeting2 => 'Rejoindre la réunion';

  @override
  String get notes => 'Notes';

  @override
  String get completeBusinessProfileTitle =>
      'Complétez votre profil entreprise';

  @override
  String get businessDescription => 'Description de l\'entreprise';

  @override
  String get finishSetupAction => 'Terminer la configuration';

  @override
  String get describeBusinessHintLong =>
      'Décrivez votre entreprise, sa culture et ce qui en fait un excellent lieu de travail... (min 150 caractères)';

  @override
  String get describeBusinessHintShort => 'Décrivez votre entreprise...';

  @override
  String get writeShortIntroAboutYourself =>
      'Rédigez une courte présentation...';

  @override
  String get createBusinessAccountTitle => 'Créer un compte entreprise';

  @override
  String get businessDetailsSection => 'Détails de l\'entreprise';

  @override
  String get openToInternationalCandidates =>
      'Ouvert aux candidats internationaux';

  @override
  String get createAccountShort => 'Créer un compte';

  @override
  String get yourDetailsSection => 'Vos informations';

  @override
  String get jobTypeField => 'Type d\'emploi';

  @override
  String get communityFeed => 'Fil de la communauté';

  @override
  String get postPublished => 'Publication publiée';

  @override
  String get postHidden => 'Publication masquée';

  @override
  String get postReportedReview =>
      'Publication signalée — l\'admin va l\'examiner';

  @override
  String get postNotFound => 'Publication introuvable';

  @override
  String get goBack => 'Retour';

  @override
  String get linkCopied => 'Lien copié';

  @override
  String get removedFromSaved => 'Retiré des enregistrés';

  @override
  String get noPostsFound => 'Aucune publication trouvée';

  @override
  String get tipsStoriesAdvice =>
      'Conseils, histoires et retours de professionnels';

  @override
  String get searchTalentPostsRolesHint =>
      'Rechercher talents, publications, rôles…';

  @override
  String get videoAttachmentsComingSoon => 'Pièces vidéo bientôt disponibles';

  @override
  String get locationTaggingComingSoon => 'Géolocalisation bientôt disponible';

  @override
  String get fullImageViewerComingSoon =>
      'Visualiseur d\'images bientôt disponible';

  @override
  String get shareComingSoon => 'Partage bientôt disponible';

  @override
  String get findServices => 'Trouver des services';

  @override
  String get findHospitalityServices => 'Services pour l\'hôtellerie';

  @override
  String get browseServices => 'Parcourir les services';

  @override
  String get searchServicesCompaniesLocationsHint =>
      'Rechercher services, entreprises, lieux...';

  @override
  String get searchCompaniesServicesLocationsHint =>
      'Rechercher entreprises, services, lieux...';

  @override
  String get nearbyCompanies => 'Entreprises à proximité';

  @override
  String get nearYou => 'Près de vous';

  @override
  String get listLabel => 'Liste';

  @override
  String get mapViewLabel => 'Vue carte';

  @override
  String get noServicesFound => 'Aucun service trouvé';

  @override
  String get noCompaniesFoundNearby => 'Aucune entreprise à proximité';

  @override
  String get noSavedCompanies => 'Aucune entreprise enregistrée';

  @override
  String get savedCompaniesTitle => 'Entreprises enregistrées';

  @override
  String get saveCompaniesForLater =>
      'Enregistrez des entreprises pour les retrouver';

  @override
  String get latestUpdates => 'Dernières actualités';

  @override
  String get noPromotions => 'Aucune promotion';

  @override
  String get companyHasNoPromotions =>
      'Cette entreprise n\'a pas de promotions actives.';

  @override
  String get companyHasNoUpdates =>
      'Cette entreprise n\'a pas publié de mises à jour.';

  @override
  String get promotionsAndOffers => 'Promotions et offres';

  @override
  String get promotionNotFound => 'Promotion introuvable';

  @override
  String get promotionDetails => 'Détails de la promotion';

  @override
  String get termsAndConditions => 'Conditions générales';

  @override
  String get relatedPosts => 'Publications liées';

  @override
  String get viewOffer => 'Voir l\'offre';

  @override
  String get offerBadge => 'OFFRE';

  @override
  String get requestQuote => 'Demander un devis';

  @override
  String get sendRequest => 'Envoyer la demande';

  @override
  String get quoteRequestSent => 'Demande de devis envoyée !';

  @override
  String get inquiry => 'Demande';

  @override
  String get dateNeeded => 'Date souhaitée';

  @override
  String get serviceType => 'Type de service';

  @override
  String get serviceArea => 'Zone de service';

  @override
  String get servicesOffered => 'Services proposés';

  @override
  String get servicesLabel => 'Services';

  @override
  String get servicePlans => 'Forfaits de service';

  @override
  String get growYourServiceBusiness => 'Développez votre activité';

  @override
  String get getDiscoveredPremium =>
      'Soyez découvert par plus de clients avec un profil premium.';

  @override
  String get unlockPremium => 'Activer Premium';

  @override
  String get getMoreVisibility => 'Plus de visibilité et de meilleurs matchs';

  @override
  String get plagitPremiumUpper => 'PLAGIT PREMIUM';

  @override
  String get premiumOnly => 'Premium uniquement';

  @override
  String get savePercent17 => 'Économisez 17 %';

  @override
  String get registerBusinessCta => 'Enregistrer l\'entreprise';

  @override
  String get registrationSubmitted => 'Inscription envoyée';

  @override
  String get serviceDescription => 'Description du service';

  @override
  String get describeServicesHint =>
      'Décrivez vos services, expérience et ce qui vous distingue...';

  @override
  String get websiteOptional => 'Site web (facultatif)';

  @override
  String get viewCompanyProfileCta => 'Voir le profil de l\'entreprise';

  @override
  String get contactCompany => 'Contacter l\'entreprise';

  @override
  String get aboutUs => 'À propos';

  @override
  String get address => 'Adresse';

  @override
  String get city => 'Ville';

  @override
  String get yourLocation => 'Votre emplacement';

  @override
  String get enterYourCity => 'Saisissez votre ville';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get tryDifferentSearchTerm => 'Essayez un autre terme';

  @override
  String get tryDifferentOrAdjust =>
      'Essayez une autre recherche, catégorie ou filtres.';

  @override
  String get noPostsYetCompany => 'Aucun post pour le moment';

  @override
  String requestQuoteFromCompany(String companyName) {
    return 'Demander un devis à $companyName';
  }

  @override
  String validUntilDate(String validUntil) {
    return 'Valable jusqu\'au $validUntil';
  }

  @override
  String get employerCheckingProfile =>
      'Un employeur consulte votre profil en ce moment';

  @override
  String profileStrengthPercent(int percent) {
    return 'Votre profil est complété à $percent%';
  }

  @override
  String get profileGetsMoreViews => 'Un profil complet reçoit 3× plus de vues';

  @override
  String get applicationUpdate => 'Mise à jour candidature';

  @override
  String get findJobsAndApply => 'Trouver des jobs et postuler';

  @override
  String get manageJobsAndHiring => 'Gérer jobs et recrutement';

  @override
  String get managePlatform => 'Gérer la plateforme';

  @override
  String get findHospitalityCompanies => 'Trouver des entreprises hospitality';

  @override
  String get candidateMessages => 'MESSAGES CANDIDATS';

  @override
  String get businessMessages => 'MESSAGES ENTREPRISES';

  @override
  String get serviceInquiries => 'DEMANDES DE SERVICE';

  @override
  String get acceptInterview => 'Accepter l\'entretien';

  @override
  String get adminMenuDashboard => 'Tableau de bord';

  @override
  String get adminMenuUsers => 'Utilisateurs';

  @override
  String get adminMenuCandidates => 'Candidats';

  @override
  String get adminMenuBusinesses => 'Entreprises';

  @override
  String get adminMenuJobs => 'Emplois';

  @override
  String get adminMenuApplications => 'Candidatures';

  @override
  String get adminMenuBookings => 'Réservations';

  @override
  String get adminMenuPayments => 'Paiements';

  @override
  String get adminMenuMessages => 'Messages';

  @override
  String get adminMenuNotifications => 'Notifications';

  @override
  String get adminMenuReports => 'Rapports';

  @override
  String get adminMenuAnalytics => 'Analyses';

  @override
  String get adminMenuSettings => 'Paramètres';

  @override
  String get adminMenuSupport => 'Support';

  @override
  String get adminMenuModeration => 'Modération';

  @override
  String get adminMenuRoles => 'Rôles';

  @override
  String get adminMenuInvoices => 'Factures';

  @override
  String get adminMenuLogs => 'Journaux';

  @override
  String get adminMenuIntegrations => 'Intégrations';

  @override
  String get adminMenuLogout => 'Déconnexion';

  @override
  String get adminActionApprove => 'Approuver';

  @override
  String get adminActionReject => 'Rejeter';

  @override
  String get adminActionSuspend => 'Suspendre';

  @override
  String get adminActionActivate => 'Activer';

  @override
  String get adminActionDelete => 'Supprimer';

  @override
  String get adminActionExport => 'Exporter';

  @override
  String get adminSectionOverview => 'Vue d\'ensemble';

  @override
  String get adminSectionManagement => 'Gestion';

  @override
  String get adminSectionFinance => 'Finance';

  @override
  String get adminSectionOperations => 'Opérations';

  @override
  String get adminSectionSystem => 'Système';

  @override
  String get adminStatTotalUsers => 'Utilisateurs totaux';

  @override
  String get adminStatActiveJobs => 'Emplois actifs';

  @override
  String get adminStatPendingApprovals => 'Approbations en attente';

  @override
  String get adminStatRevenue => 'Revenus';

  @override
  String get adminStatBookingsToday => 'Réservations aujourd\'hui';

  @override
  String get adminStatNewSignups => 'Nouvelles inscriptions';

  @override
  String get adminStatConversionRate => 'Taux de conversion';

  @override
  String get adminMiscWelcome => 'Bon retour';

  @override
  String get adminMiscLoading => 'Chargement…';

  @override
  String get adminMiscNoData => 'Aucune donnée disponible';

  @override
  String get adminMiscSearchPlaceholder => 'Rechercher…';

  @override
  String get adminMenuContent => 'Contenu';

  @override
  String get adminMenuMore => 'Plus';

  @override
  String get adminMenuVerifications => 'Vérifications';

  @override
  String get adminMenuSubscriptions => 'Abonnements';

  @override
  String get adminMenuCommunity => 'Communauté';

  @override
  String get adminMenuInterviews => 'Entretiens';

  @override
  String get adminMenuMatches => 'Correspondances';

  @override
  String get adminMenuFeaturedContent => 'Contenu à la une';

  @override
  String get adminMenuAuditLog => 'Journal d\'audit';

  @override
  String get adminMenuChangePassword => 'Changer le mot de passe';

  @override
  String get adminSectionPeople => 'Personnes';

  @override
  String get adminSectionHiring => 'Opérations de recrutement';

  @override
  String get adminSectionContentComm => 'Contenu et communication';

  @override
  String get adminSectionRevenue => 'Entreprise et revenus';

  @override
  String get adminSectionToolsContent => 'Outils et contenu';

  @override
  String get adminSectionQuickActions => 'Actions rapides';

  @override
  String get adminSectionNeedsAttention => 'Nécessite attention';

  @override
  String get adminStatActiveBusinesses => 'Entreprises actives';

  @override
  String get adminStatApplicationsToday => 'Candidatures aujourd\'hui';

  @override
  String get adminStatInterviewsToday => 'Entretiens aujourd\'hui';

  @override
  String get adminStatFlaggedContent => 'Contenu signalé';

  @override
  String get adminStatActiveSubs => 'Abonnements actifs';

  @override
  String get adminActionFlagged => 'Signalés';

  @override
  String get adminActionFeatured => 'À la une';

  @override
  String get adminActionReviewFlagged => 'Examiner le contenu signalé';

  @override
  String get adminActionTodayInterviews => 'Entretiens d\'aujourd\'hui';

  @override
  String get adminActionOpenReports => 'Signalements ouverts';

  @override
  String get adminActionManageSubscriptions => 'Gérer les abonnements';

  @override
  String get adminActionAnalyticsDashboard => 'Tableau d\'analyses';

  @override
  String get adminActionSendNotification => 'Envoyer une notification';

  @override
  String get adminActionCreateCommunityPost => 'Créer un post communauté';

  @override
  String get adminActionRetry => 'Réessayer';

  @override
  String get adminMiscGreetingMorning => 'Bonjour';

  @override
  String get adminMiscGreetingAfternoon => 'Bon après-midi';

  @override
  String get adminMiscGreetingEvening => 'Bonsoir';

  @override
  String get adminMiscAllClear =>
      'Tout va bien — rien ne nécessite d\'attention.';

  @override
  String get adminSubtitleAllUsers => 'Tous les utilisateurs';

  @override
  String get adminSubtitleCandidates => 'Profils candidats';

  @override
  String get adminSubtitleBusinesses => 'Comptes employeurs';

  @override
  String get adminSubtitleJobs => 'Offres actives';

  @override
  String get adminSubtitleApplications => 'Candidatures soumises';

  @override
  String get adminSubtitleInterviews => 'Entretiens planifiés';

  @override
  String get adminSubtitleMatches => 'Correspondances rôle et type';

  @override
  String get adminSubtitleVerifications => 'Vérifications en attente';

  @override
  String get adminSubtitleReports => 'Signalements et modération';

  @override
  String get adminSubtitleSupport => 'Tickets de support ouverts';

  @override
  String get adminSubtitleMessages => 'Conversations utilisateurs';

  @override
  String get adminSubtitleNotifications => 'Alertes push et in-app';

  @override
  String get adminSubtitleCommunity => 'Publications et discussions';

  @override
  String get adminSubtitleFeaturedContent => 'Contenu mis en avant';

  @override
  String get adminSubtitleSubscriptions => 'Forfaits et facturation';

  @override
  String get adminSubtitleAuditLog => 'Journaux d\'activité admin';

  @override
  String get adminSubtitleAnalytics => 'Métriques de la plateforme';

  @override
  String get adminSubtitleSettings => 'Configuration de la plateforme';

  @override
  String get adminSubtitleUsersPage => 'Gérer les comptes';

  @override
  String get adminSubtitleContentPage => 'Offres, candidatures et entretiens';

  @override
  String get adminSubtitleModerationPage =>
      'Vérifications, signalements et support';

  @override
  String get adminSubtitleMorePage => 'Paramètres, analyses et compte';

  @override
  String get adminSubtitleAnalyticsHero =>
      'KPI, tendances et santé de la plateforme';

  @override
  String get adminBadgeUrgent => 'Urgent';

  @override
  String get adminBadgeReview => 'Examiner';

  @override
  String get adminBadgeAction => 'Action';

  @override
  String get adminMenuAllUsers => 'Tous les utilisateurs';

  @override
  String get adminMiscSuperAdmin => 'Super Admin';

  @override
  String adminBadgeNToday(int count) {
    return '$count aujourd\'hui';
  }

  @override
  String adminBadgeNOpen(int count) {
    return '$count ouverts';
  }

  @override
  String adminBadgeNActive(int count) {
    return '$count actifs';
  }

  @override
  String adminBadgeNUnread(int count) {
    return '$count non lus';
  }

  @override
  String adminBadgeNPending(int count) {
    return '$count en attente';
  }

  @override
  String adminBadgeNPosts(int count) {
    return '$count publications';
  }

  @override
  String adminBadgeNFeatured(int count) {
    return '$count en avant';
  }

  @override
  String get adminStatusActive => 'Actif';

  @override
  String get adminStatusPaused => 'En pause';

  @override
  String get adminStatusClosed => 'Fermé';

  @override
  String get adminStatusDraft => 'Brouillon';

  @override
  String get adminStatusFlagged => 'Signalé';

  @override
  String get adminStatusSuspended => 'Suspendu';

  @override
  String get adminStatusPending => 'En attente';

  @override
  String get adminStatusConfirmed => 'Confirmé';

  @override
  String get adminStatusCompleted => 'Terminé';

  @override
  String get adminStatusCancelled => 'Annulé';

  @override
  String get adminStatusAccepted => 'Accepté';

  @override
  String get adminStatusDenied => 'Refusé';

  @override
  String get adminStatusExpired => 'Expiré';

  @override
  String get adminStatusResolved => 'Résolu';

  @override
  String get adminStatusScheduled => 'Programmé';

  @override
  String get adminStatusBanned => 'Banni';

  @override
  String get adminStatusVerified => 'Vérifié';

  @override
  String get adminStatusFailed => 'Échoué';

  @override
  String get adminStatusSuccess => 'Succès';

  @override
  String get adminStatusDelivered => 'Livré';

  @override
  String get adminFilterAll => 'Tous';

  @override
  String get adminFilterToday => 'Aujourd\'hui';

  @override
  String get adminFilterUnread => 'Non lus';

  @override
  String get adminFilterRead => 'Lus';

  @override
  String get adminFilterCandidates => 'Candidats';

  @override
  String get adminFilterBusinesses => 'Entreprises';

  @override
  String get adminFilterAdmins => 'Admins';

  @override
  String get adminFilterCandidate => 'Candidat';

  @override
  String get adminFilterBusiness => 'Entreprise';

  @override
  String get adminFilterSystem => 'Système';

  @override
  String get adminFilterPinned => 'Épinglés';

  @override
  String get adminFilterEmployers => 'Employeurs';

  @override
  String get adminFilterBanners => 'Bannières';

  @override
  String get adminFilterBilling => 'Facturation';

  @override
  String get adminFilterFeaturedEmployer => 'Employeur en vedette';

  @override
  String get adminFilterFeaturedJob => 'Emploi en vedette';

  @override
  String get adminFilterHomeBanner => 'Bannière accueil';

  @override
  String get adminEmptyAdjustFilters => 'Essayez d\'ajuster les filtres.';

  @override
  String get adminEmptyJobsTitle => 'Aucun emploi';

  @override
  String get adminEmptyJobsSub => 'Aucun emploi ne correspond.';

  @override
  String get adminEmptyUsersTitle => 'Aucun utilisateur';

  @override
  String get adminEmptyMessagesTitle => 'Aucun message';

  @override
  String get adminEmptyMessagesSub => 'Aucune conversation à afficher.';

  @override
  String get adminEmptyReportsTitle => 'Aucun signalement';

  @override
  String get adminEmptyReportsSub => 'Aucun signalement à examiner.';

  @override
  String get adminEmptyBusinessesTitle => 'Aucune entreprise';

  @override
  String get adminEmptyBusinessesSub => 'Aucune entreprise ne correspond.';

  @override
  String get adminEmptyNotifsTitle => 'Aucune notification';

  @override
  String get adminEmptySubsTitle => 'Aucun abonnement';

  @override
  String get adminEmptySubsSub => 'Aucun abonnement ne correspond.';

  @override
  String get adminEmptyLogsTitle => 'Aucun journal';

  @override
  String get adminEmptyContentTitle => 'Aucun contenu';

  @override
  String get adminEmptyInterviewsTitle => 'Aucun entretien';

  @override
  String get adminEmptyInterviewsSub => 'Aucun entretien ne correspond.';

  @override
  String get adminEmptyFeedback => 'Les retours apparaîtront ici';

  @override
  String get adminEmptyMatchNotifs =>
      'Les notifications de match apparaîtront ici';

  @override
  String get adminTitleMatchManagement => 'Gestion des matches';

  @override
  String get adminTitleAdminLogs => 'Journaux admin';

  @override
  String get adminTitleContentFeatured => 'Contenu / En vedette';

  @override
  String get adminTabFeedback => 'Retours';

  @override
  String get adminTabStats => 'Statistiques';

  @override
  String get adminSortNewest => 'Plus récents';

  @override
  String get adminSortPriority => 'Priorité';

  @override
  String get adminStatTotalMatches => 'Matches totaux';

  @override
  String get adminStatAccepted => 'Acceptés';

  @override
  String get adminStatDenied => 'Refusés';

  @override
  String get adminStatFeedbackCount => 'Retours';

  @override
  String get adminStatMatchQuality => 'Score de qualité de match';

  @override
  String get adminStatTotal => 'Total';

  @override
  String get adminStatPendingCount => 'En attente';

  @override
  String get adminStatNotificationsCount => 'Notifications';

  @override
  String get adminStatActiveCount => 'Actifs';

  @override
  String get adminSectionPlatformSettings => 'Paramètres de plateforme';

  @override
  String get adminSectionNotificationSettings => 'Paramètres de notifications';

  @override
  String get adminSettingMaintenanceTitle => 'Mode maintenance';

  @override
  String get adminSettingMaintenanceSub => 'Désactiver l\'accès pour tous';

  @override
  String get adminSettingNewRegsTitle => 'Nouvelles inscriptions';

  @override
  String get adminSettingNewRegsSub => 'Autoriser les nouvelles inscriptions';

  @override
  String get adminSettingFeaturedJobsTitle => 'Emplois en vedette';

  @override
  String get adminSettingFeaturedJobsSub =>
      'Afficher les emplois en vedette sur la page d\'accueil';

  @override
  String get adminSettingEmailNotifsTitle => 'Notifications email';

  @override
  String get adminSettingEmailNotifsSub => 'Envoyer des alertes email';

  @override
  String get adminSettingPushNotifsTitle => 'Notifications push';

  @override
  String get adminSettingPushNotifsSub => 'Envoyer des notifications push';

  @override
  String get adminActionSaveChanges => 'Enregistrer';

  @override
  String get adminToastSettingsSaved => 'Paramètres enregistrés';

  @override
  String get adminActionResolve => 'Résoudre';

  @override
  String get adminActionDismiss => 'Rejeter';

  @override
  String get adminActionBanUser => 'Bannir';

  @override
  String get adminSearchUsersHint => 'Rechercher nom, email, rôle, lieu...';

  @override
  String get adminMiscPositive => 'positif';

  @override
  String adminCountUsers(int count) {
    return '$count utilisateurs';
  }

  @override
  String adminCountNotifs(int count) {
    return '$count notifications';
  }

  @override
  String adminCountLogs(int count) {
    return '$count entrées de journal';
  }

  @override
  String adminCountItems(int count) {
    return '$count éléments';
  }

  @override
  String adminBadgeNRetried(int count) {
    return 'Réessayé x$count';
  }

  @override
  String get adminStatusApplied => 'Postulé';

  @override
  String get adminStatusUnderReview => 'En cours d\'examen';

  @override
  String get adminStatusShortlisted => 'Présélectionné';

  @override
  String get adminStatusInterview => 'Entretien';

  @override
  String get adminStatusHired => 'Embauché';

  @override
  String get adminStatusRejected => 'Rejeté';

  @override
  String get adminStatusOpen => 'Ouvert';

  @override
  String get adminStatusInReview => 'En examen';

  @override
  String get adminStatusWaiting => 'En attente';

  @override
  String get adminPriorityHigh => 'Haute';

  @override
  String get adminPriorityMedium => 'Moyenne';

  @override
  String get adminPriorityLow => 'Basse';

  @override
  String get adminActionViewProfile => 'Voir le profil';

  @override
  String get adminActionVerify => 'Vérifier';

  @override
  String get adminActionReview => 'Examiner';

  @override
  String get adminActionOverride => 'Remplacer';

  @override
  String get adminEmptyCandidatesTitle => 'Aucun candidat';

  @override
  String get adminEmptyApplicationsTitle => 'Aucune candidature';

  @override
  String get adminEmptyVerificationsTitle => 'Aucune vérification en attente';

  @override
  String get adminEmptyIssuesTitle => 'Aucun problème';

  @override
  String get adminEmptyAuditTitle => 'Aucune entrée d\'audit';

  @override
  String get adminSearchCandidatesTitle => 'Rechercher des candidats';

  @override
  String get adminSearchCandidatesHint => 'Rechercher par nom, e-mail ou rôle…';

  @override
  String get adminSearchAuditHint => 'Rechercher dans l\'audit…';

  @override
  String get adminMiscUnknown => 'Inconnu';

  @override
  String adminCountTotal(int count) {
    return '$count au total';
  }

  @override
  String adminBadgeNFlagged(int count) {
    return '$count signalés';
  }

  @override
  String adminBadgeNDaysWaiting(int count) {
    return '$count jours d\'attente';
  }

  @override
  String get adminPeriodWeek => 'Semaine';

  @override
  String get adminPeriodMonth => 'Mois';

  @override
  String get adminPeriodYear => 'Année';

  @override
  String get adminKpiNewCandidates => 'Nouveaux candidats';

  @override
  String get adminKpiNewBusinesses => 'Nouvelles entreprises';

  @override
  String get adminKpiJobsPosted => 'Offres publiées';

  @override
  String get adminSectionApplicationFunnel => 'Entonnoir des candidatures';

  @override
  String get adminSectionPlatformGrowth => 'Croissance de la plateforme';

  @override
  String get adminSectionPremiumConversion => 'Conversion premium';

  @override
  String get adminSectionTopLocations => 'Principaux lieux';

  @override
  String get adminStatusViewed => 'Vu';

  @override
  String get adminWeekdayMon => 'Lun';

  @override
  String get adminWeekdayTue => 'Mar';

  @override
  String get adminWeekdayWed => 'Mer';

  @override
  String get adminWeekdayThu => 'Jeu';

  @override
  String get adminWeekdayFri => 'Ven';

  @override
  String get adminWeekdaySat => 'Sam';

  @override
  String get adminWeekdaySun => 'Dim';

  @override
  String get adminFilterReported => 'Signalés';

  @override
  String get adminFilterHidden => 'Masqués';

  @override
  String get adminEmptyPostsTitle => 'Aucune publication';

  @override
  String get adminEmptyContentFilter =>
      'Aucun contenu ne correspond à ce filtre.';

  @override
  String get adminBannerReportedReview => 'SIGNALÉ — RÉVISION REQUISE';

  @override
  String get adminBannerHiddenFromFeed => 'MASQUÉ DU FIL';

  @override
  String get adminActionInsights => 'Analyses';

  @override
  String get adminActionHide => 'Masquer';

  @override
  String get adminActionRemove => 'Supprimer';

  @override
  String get adminActionCancel => 'Annuler';

  @override
  String get adminDialogRemovePostTitle => 'Supprimer la publication ?';

  @override
  String get adminDialogRemovePostBody =>
      'Ceci supprime définitivement la publication et ses commentaires. Cette action est irréversible.';

  @override
  String get adminSnackbarReportCleared => 'Signalement effacé';

  @override
  String get adminSnackbarPostHidden => 'Publication masquée du fil';

  @override
  String get adminSnackbarPostRemoved => 'Publication supprimée';

  @override
  String adminCountReported(int count) {
    return '$count signalés';
  }

  @override
  String adminCountHidden(int count) {
    return '$count masqués';
  }

  @override
  String adminMiscPremiumOutOfTotal(int premium, int total) {
    return '$premium premium sur $total au total';
  }

  @override
  String get adminActionUnverify => 'Annuler la vérification';

  @override
  String get adminActionReactivate => 'Réactiver';

  @override
  String get adminActionFeature => 'Mettre en avant';

  @override
  String get adminActionUnfeature => 'Retirer de la mise en avant';

  @override
  String get adminActionFlagAccount => 'Signaler le compte';

  @override
  String get adminActionUnflagAccount => 'Retirer le signalement';

  @override
  String get adminActionConfirm => 'Confirmer';

  @override
  String get adminDialogVerifyBusinessTitle => 'Vérifier l\'entreprise';

  @override
  String get adminDialogUnverifyBusinessTitle =>
      'Annuler la vérification de l\'entreprise';

  @override
  String get adminDialogSuspendBusinessTitle => 'Suspendre l\'entreprise';

  @override
  String get adminDialogReactivateBusinessTitle => 'Réactiver l\'entreprise';

  @override
  String get adminDialogVerifyCandidateTitle => 'Vérifier le candidat';

  @override
  String get adminDialogSuspendCandidateTitle => 'Suspendre le candidat';

  @override
  String get adminDialogReactivateCandidateTitle => 'Réactiver le candidat';

  @override
  String get adminSnackbarBusinessVerified => 'Entreprise vérifiée';

  @override
  String get adminSnackbarVerificationRemoved => 'Vérification supprimée';

  @override
  String get adminSnackbarBusinessSuspended => 'Entreprise suspendue';

  @override
  String get adminSnackbarBusinessReactivated => 'Entreprise réactivée';

  @override
  String get adminSnackbarBusinessFeatured => 'Entreprise mise en avant';

  @override
  String get adminSnackbarBusinessUnfeatured =>
      'Entreprise retirée de la mise en avant';

  @override
  String get adminSnackbarUserVerified => 'Utilisateur vérifié';

  @override
  String get adminSnackbarUserSuspended => 'Utilisateur suspendu';

  @override
  String get adminSnackbarUserReactivated => 'Utilisateur réactivé';

  @override
  String get adminTabProfile => 'Profil';

  @override
  String get adminTabActivity => 'Activité';

  @override
  String get adminTabNotes => 'Notes';

  @override
  String adminDialogVerifyBody(String name) {
    return 'Marquer $name comme vérifié ?';
  }

  @override
  String adminDialogUnverifyBody(String name) {
    return 'Retirer la vérification de $name ?';
  }

  @override
  String adminDialogReactivateBody(String name) {
    return 'Réactiver $name ?';
  }

  @override
  String adminDialogSuspendBusinessBody(String name) {
    return 'Suspendre $name ? Toutes les offres seront mises en pause.';
  }

  @override
  String adminDialogSuspendCandidateBody(String name) {
    return 'Suspendre $name ? L\'accès sera révoqué.';
  }
}
