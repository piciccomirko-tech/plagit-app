// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Plagit';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get createBusinessAccount => 'Crear cuenta empresarial';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get done => 'Hecho';

  @override
  String get retry => 'Reintentar';

  @override
  String get search => 'Buscar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get apply => 'Postular';

  @override
  String get clear => 'Borrar';

  @override
  String get clearAll => 'Borrar todo';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get home => 'Inicio';

  @override
  String get jobs => 'Trabajos';

  @override
  String get messages => 'Mensajes';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get categoryAndRole => 'Categoría y rol';

  @override
  String get selectCategory => 'Seleccionar categoría';

  @override
  String get subcategory => 'Subcategoría';

  @override
  String get role => 'Rol';

  @override
  String get recentSearches => 'Búsquedas recientes';

  @override
  String noResultsFor(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get mostPopular => 'Más populares';

  @override
  String get allCategories => 'Todas las categorías';

  @override
  String get selectVenueTypeAndRole =>
      'Selecciona tipo de local y rol requerido';

  @override
  String get selectCategoryAndRole => 'Selecciona categoría y rol';

  @override
  String get businessDetails => 'Datos de la empresa';

  @override
  String get yourDetails => 'Tus datos';

  @override
  String get companyName => 'Nombre de la empresa';

  @override
  String get contactPerson => 'Persona de contacto';

  @override
  String get location => 'Ubicación';

  @override
  String get website => 'Sitio web';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get yearsExperience => 'Años de experiencia';

  @override
  String get languagesSpoken => 'Idiomas hablados';

  @override
  String get jobType => 'Tipo de trabajo';

  @override
  String get jobTypeFullTime => 'Tiempo completo';

  @override
  String get jobTypePartTime => 'Medio tiempo';

  @override
  String get jobTypeTemporary => 'Temporal';

  @override
  String get jobTypeFreelance => 'Freelance';

  @override
  String get openToInternational => 'Abierto a candidatos internacionales';

  @override
  String get passwordHint => 'Contraseña (mín. 8 caracteres)';

  @override
  String get termsOfServiceNote =>
      'Al crear una cuenta aceptas nuestros Términos del servicio y Política de privacidad.';

  @override
  String get networkError => 'Error de red';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get loading => 'Cargando…';

  @override
  String get errorGeneric =>
      'Se ha producido un error inesperado. Inténtalo de nuevo.';

  @override
  String get joinAsCandidate => 'Únete como Candidato';

  @override
  String get joinAsBusiness => 'Únete como Empresa';

  @override
  String get findYourNextRole => 'Encuentra tu próximo puesto en hostelería';

  @override
  String get candidateLoginSubtitle =>
      'Conecta con los mejores empleadores en Londres, Dubái y más allá.';

  @override
  String get businessLoginSubtitle =>
      'Llega al mejor talento y haz crecer tu equipo.';

  @override
  String get rememberMe => 'Recuérdame';

  @override
  String get forgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get lookingForStaff => '¿Buscas personal? ';

  @override
  String get lookingForJob => '¿Buscas trabajo? ';

  @override
  String get switchToBusiness => 'Cambiar a Empresa';

  @override
  String get switchToCandidate => 'Cambiar a Candidato';

  @override
  String get createYourProfile =>
      'Crea tu perfil y deja que los mejores empleadores te descubran.';

  @override
  String get createBusinessProfile =>
      'Crea el perfil de tu empresa y empieza a contratar al mejor talento.';

  @override
  String get locationCityCountry => 'Ubicación (ciudad, país)';

  @override
  String get termsAgreement =>
      'Al crear una cuenta aceptas nuestros Términos del servicio y Política de privacidad.';

  @override
  String get searchHospitalityHint => 'Busca categoría, subcategoría o rol…';

  @override
  String get mostCommonRoles => 'Roles más comunes';

  @override
  String get allRoles => 'Todos los roles';

  @override
  String suggestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugerencias',
      one: '1 sugerencia',
    );
    return '$_temp0';
  }

  @override
  String subcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategorías',
      one: '1 subcategoría',
    );
    return '$_temp0';
  }

  @override
  String rolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count roles',
      one: '1 rol',
    );
    return '$_temp0';
  }

  @override
  String get kindCategory => 'Categoría';

  @override
  String get kindSubcategory => 'Subcategoría';

  @override
  String get kindRole => 'Rol';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Introduce tu correo y te enviaremos un enlace para restablecer la contraseña.';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get resetEmailSent =>
      'Si existe una cuenta con ese correo, se ha enviado el enlace para restablecerla.';

  @override
  String get profileSetupTitle => 'Completa tu perfil';

  @override
  String get profileSetupSubtitle =>
      'Un perfil completo se descubre más rápido.';

  @override
  String get uploadPhoto => 'Subir foto';

  @override
  String get uploadCV => 'Subir CV';

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String get finish => 'Finalizar';

  @override
  String get noInternet => 'Sin conexión a internet. Comprueba tu red.';

  @override
  String get tryAgain => 'Inténtalo de nuevo';

  @override
  String get emptyJobs => 'Aún no hay trabajos';

  @override
  String get emptyApplications => 'Aún no hay candidaturas';

  @override
  String get emptyMessages => 'Aún no hay mensajes';

  @override
  String get emptyNotifications => 'Estás al día';

  @override
  String get onboardingRoleTitle => '¿Qué puesto buscas?';

  @override
  String get onboardingRoleSubtitle => 'Selecciona todos los relevantes';

  @override
  String get onboardingExperienceTitle => '¿Cuánta experiencia tienes?';

  @override
  String get onboardingLocationTitle => '¿Dónde te encuentras?';

  @override
  String get onboardingLocationHint => 'Introduce tu ciudad o código postal';

  @override
  String get useMyCurrentLocation => 'Usar mi ubicación actual';

  @override
  String get onboardingAvailabilityTitle => '¿Qué estás buscando?';

  @override
  String get finishSetup => 'Finalizar configuración';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get findJobs => 'Buscar trabajos';

  @override
  String get applications => 'Candidaturas';

  @override
  String get community => 'Comunidad';

  @override
  String get recommendedForYou => 'Recomendado para ti';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get searchJobsHint => 'Busca trabajos, roles, ubicaciones…';

  @override
  String get searchJobs => 'Buscar trabajos';

  @override
  String get postedJob => 'Publicado';

  @override
  String get applyNow => 'Postular ahora';

  @override
  String get applied => 'Postulado';

  @override
  String get saveJob => 'Guardar';

  @override
  String get saved => 'Guardado';

  @override
  String get jobDescription => 'Descripción del trabajo';

  @override
  String get requirements => 'Requisitos';

  @override
  String get benefits => 'Beneficios';

  @override
  String get salary => 'Salario';

  @override
  String get contract => 'Contrato';

  @override
  String get schedule => 'Horario';

  @override
  String get viewCompany => 'Ver empresa';

  @override
  String get interview => 'Entrevista';

  @override
  String get interviews => 'Entrevistas';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get matches => 'Matches';

  @override
  String get quickPlug => 'Quick Plug';

  @override
  String get discover => 'Descubrir';

  @override
  String get shortlist => 'Shortlist';

  @override
  String get message => 'Mensaje';

  @override
  String get messageCandidate => 'Enviar mensaje';

  @override
  String get nextInterview => 'Próxima entrevista';

  @override
  String get loadingDashboard => 'Cargando panel…';

  @override
  String get tryAgainCta => 'Reintentar';

  @override
  String get careerDashboard => 'PANEL DE CARRERA';

  @override
  String get yourNextInterview => 'Tu próxima entrevista\nestá programada';

  @override
  String get yourCareerTakingOff => 'Tu carrera\ndespega';

  @override
  String get yourCareerOnTheMove => 'Tu carrera\nestá en marcha';

  @override
  String get yourJourneyStartsHere => 'Tu camino\nempieza aquí';

  @override
  String get applyFirstJob => 'Postula a tu primer trabajo para empezar';

  @override
  String get interviewComingUp => 'Entrevista próxima';

  @override
  String get unlockPlagitPremium => 'Desbloquea Plagit Premium';

  @override
  String get premiumSubtitle =>
      'Destaca en los mejores locales — consigue matches más rápido';

  @override
  String get premiumActive => 'Premium activo';

  @override
  String get premiumActiveSubtitle =>
      'Visibilidad prioritaria activa · Gestionar plan';

  @override
  String get noJobsFound => 'Ningún trabajo coincide con tu búsqueda';

  @override
  String get noApplicationsYet => 'Aún no hay candidaturas';

  @override
  String get startApplying => 'Empieza a explorar trabajos para postular';

  @override
  String get noMessagesYet => 'Aún no hay mensajes';

  @override
  String get allCaughtUp => 'Estás al día';

  @override
  String get noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get about => 'Acerca de';

  @override
  String get experience => 'Experiencia';

  @override
  String get skills => 'Habilidades';

  @override
  String get languages => 'Idiomas';

  @override
  String get availability => 'Disponibilidad';

  @override
  String get verified => 'Verificado';

  @override
  String get totalViews => 'Visualizaciones totales';

  @override
  String get verifiedVenuePrefix => 'Verificado';

  @override
  String get notVerified => 'No verificado';

  @override
  String get pendingReview => 'Pendiente de revisión';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get share => 'Compartir';

  @override
  String get report => 'Reportar';

  @override
  String get block => 'Bloquear';

  @override
  String get typeMessage => 'Escribe un mensaje…';

  @override
  String get send => 'Enviar';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get now => 'ahora';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count min',
      one: 'hace 1 min',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count h',
      one: 'hace 1 h',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count d',
      one: 'hace 1 d',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filtros';

  @override
  String get refineSearch => 'Refinar búsqueda';

  @override
  String get distance => 'Distancia';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get reset => 'Restablecer';

  @override
  String noResultsTitle(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get noResultsSubtitle =>
      'Prueba otra palabra clave o limpia la búsqueda.';

  @override
  String get recentSearchesEmptyTitle => 'No hay búsquedas recientes';

  @override
  String get recentSearchesEmptyHint =>
      'Tus búsquedas recientes aparecerán aquí';

  @override
  String get allJobs => 'Todos los trabajos';

  @override
  String get nearby => 'Cerca';

  @override
  String get saved2 => 'Guardados';

  @override
  String get remote => 'Remoto';

  @override
  String get inPerson => 'En persona';

  @override
  String get aboutTheJob => 'Sobre el trabajo';

  @override
  String get aboutCompany => 'Sobre la empresa';

  @override
  String get applyForJob => 'Postular a este trabajo';

  @override
  String get unsaveJob => 'Quitar de guardados';

  @override
  String get noJobsNearby => 'No hay trabajos cerca';

  @override
  String get noSavedJobs => 'No hay trabajos guardados';

  @override
  String get adjustFilters => 'Ajusta los filtros para ver más trabajos';

  @override
  String get fullTime => 'Tiempo completo';

  @override
  String get partTime => 'Medio tiempo';

  @override
  String get temporary => 'Temporal';

  @override
  String get freelance => 'Freelance';

  @override
  String postedAgo(String time) {
    return 'Publicado $time';
  }

  @override
  String kmAway(String km) {
    return 'a $km km';
  }

  @override
  String get jobDetails => 'Detalles del trabajo';

  @override
  String get aboutThisRole => 'Sobre este puesto';

  @override
  String get aboutTheBusiness => 'Sobre la empresa';

  @override
  String get urgentHiring => 'Contratación urgente';

  @override
  String get distanceRadius => 'Radio de distancia';

  @override
  String get contractType => 'Tipo de contrato';

  @override
  String get shiftType => 'Tipo de turno';

  @override
  String get all => 'Todos';

  @override
  String get casual => 'Ocasional';

  @override
  String get seasonal => 'De temporada';

  @override
  String get morning => 'Mañana';

  @override
  String get afternoon => 'Tarde';

  @override
  String get evening => 'Tarde noche';

  @override
  String get night => 'Noche';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get shiftHours => 'Horas del turno';

  @override
  String get category => 'Categoría';

  @override
  String get venueType => 'Tipo de local';

  @override
  String get employment => 'Empleo';

  @override
  String get pay => 'Remuneración';

  @override
  String get duration => 'Duración';

  @override
  String get weeklyHours => 'Horas semanales';

  @override
  String get businessLocation => 'Ubicación del negocio';

  @override
  String get jobViews => 'Visualizaciones del trabajo';

  @override
  String positions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posiciones',
      one: '1 posición',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String get myApplications => 'Mis candidaturas';

  @override
  String get active => 'Activo';

  @override
  String get interviewStatus => 'Entrevista';

  @override
  String get rejected => 'Rechazado';

  @override
  String get offer => 'Oferta';

  @override
  String appliedOn(String date) {
    return 'Postulado el $date';
  }

  @override
  String get viewJob => 'Ver trabajo';

  @override
  String get withdraw => 'Retirar candidatura';

  @override
  String get applicationStatus => 'Estado de la candidatura';

  @override
  String get noConversations => 'Aún no hay conversaciones';

  @override
  String get startConversation =>
      'Responde a un trabajo para empezar a chatear';

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Sin conexión';

  @override
  String lastSeen(String time) {
    return 'Visto por última vez $time';
  }

  @override
  String get newNotification => 'Nuevo';

  @override
  String get markAllRead => 'Marcar todo como leído';

  @override
  String get yourProfile => 'Tu perfil';

  @override
  String completionPercent(int percent) {
    return '$percent% completado';
  }

  @override
  String get personalDetails => 'Datos personales';

  @override
  String get phone => 'Teléfono';

  @override
  String get bio => 'Bio';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get addCV => 'Añadir CV';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get logoutConfirm => '¿Seguro que quieres cerrar sesión?';

  @override
  String get subscription => 'Suscripción';

  @override
  String get support => 'Soporte';

  @override
  String get privacy => 'Privacidad';

  @override
  String get terms => 'Términos';

  @override
  String get applicationDetails => 'Detalles de la candidatura';

  @override
  String get timeline => 'Cronología';

  @override
  String get submitted => 'Enviada';

  @override
  String get underReview => 'En revisión';

  @override
  String get interviewScheduled => 'Entrevista programada';

  @override
  String get offerExtended => 'Oferta enviada';

  @override
  String get withdrawApp => 'Retirar candidatura';

  @override
  String get withdrawConfirm => '¿Seguro que quieres retirar esta candidatura?';

  @override
  String get applicationWithdrawn => 'Candidatura retirada';

  @override
  String get statusApplied => 'Postulado';

  @override
  String get statusInReview => 'En revisión';

  @override
  String get statusInterview => 'Entrevista';

  @override
  String get statusHired => 'Contratado';

  @override
  String get statusClosed => 'Cerrado';

  @override
  String get statusRejected => 'Rechazado';

  @override
  String get statusOffer => 'Oferta';

  @override
  String get messagesSearch => 'Buscar mensajes…';

  @override
  String get noMessagesTitle => 'Aún no hay mensajes';

  @override
  String get noMessagesSubtitle =>
      'Responde a un trabajo para empezar a chatear';

  @override
  String get youOnline => 'Estás en línea';

  @override
  String get noNotificationsTitle => 'Aún no hay notificaciones';

  @override
  String get noNotificationsSubtitle => 'Te avisaremos cuando suceda algo';

  @override
  String get today2 => 'Hoy';

  @override
  String get earlier => 'Anteriormente';

  @override
  String get completeYourProfile => 'Completa tu perfil';

  @override
  String get profileCompletion => 'Completitud del perfil';

  @override
  String get personalInfo => 'Datos personales';

  @override
  String get professional => 'Profesional';

  @override
  String get preferences => 'Preferencias';

  @override
  String get documents => 'Documentos';

  @override
  String get myCV => 'Mi CV';

  @override
  String get premium => 'Premium';

  @override
  String get addLanguages => 'Añadir idiomas';

  @override
  String get addExperience => 'Añadir experiencia';

  @override
  String get addAvailability => 'Añadir disponibilidad';

  @override
  String get matchesTitle => 'Tus matches';

  @override
  String get noMatchesTitle => 'Aún no hay matches';

  @override
  String get noMatchesSubtitle =>
      'Sigue postulando — tus matches aparecerán aquí';

  @override
  String get interestedBusinesses => 'Empresas interesadas';

  @override
  String get accept => 'Aceptar';

  @override
  String get decline => 'Rechazar';

  @override
  String get newMatch => 'Nuevo match';

  @override
  String get quickPlugTitle => 'Quick Plug';

  @override
  String get quickPlugEmpty => 'No hay empresas nuevas ahora mismo';

  @override
  String get quickPlugSubtitle =>
      'Vuelve más tarde para ver nuevas oportunidades';

  @override
  String get uploadYourCV => 'Sube tu CV';

  @override
  String get cvSubtitle => 'Añade un CV para postular más rápido y destacar';

  @override
  String get chooseFile => 'Elegir archivo';

  @override
  String get removeCV => 'Eliminar CV';

  @override
  String get noCVUploaded => 'Aún no se ha subido ningún CV';

  @override
  String get discoverCompanies => 'Descubrir empresas';

  @override
  String get exploreSubtitle => 'Explora los mejores negocios de hostelería';

  @override
  String get follow => 'Seguir';

  @override
  String get following => 'Siguiendo';

  @override
  String get view => 'Ver';

  @override
  String get selectLanguages => 'Seleccionar idiomas';

  @override
  String selectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get allLanguages => 'Todos los idiomas';

  @override
  String get uploadCVBig =>
      'Sube tu CV para rellenar automáticamente tu perfil y ahorrar tiempo.';

  @override
  String get supportedFormats => 'Formatos soportados: PDF, DOC, DOCX';

  @override
  String get fillManually => 'Rellenar manualmente';

  @override
  String get fillManuallySubtitle =>
      'Introduce tus datos tú mismo y completa tu perfil paso a paso.';

  @override
  String get photoUploadSoon =>
      'La subida de foto llega pronto — usa un avatar profesional mientras tanto.';

  @override
  String get yourCV => 'Tu CV';

  @override
  String get aboutYou => 'Sobre ti';

  @override
  String get optional => 'Opcional';

  @override
  String get completeProfile => 'Completar perfil';

  @override
  String get openToRelocation => 'Abierto a reubicación';

  @override
  String get matchLabel => 'Match';

  @override
  String get accepted => 'Aceptado';

  @override
  String get deny => 'Rechazar';

  @override
  String get featured => 'Destacado';

  @override
  String get reviewYourProfile => 'Revisa tu perfil';

  @override
  String get nothingSavedYet => 'No se guardará nada hasta que confirmes.';

  @override
  String get editAnyField =>
      'Puedes editar cualquier campo extraído antes de guardar.';

  @override
  String get saveToProfile => 'Guardar en el perfil';

  @override
  String get findCompanies => 'Buscar empresas';

  @override
  String get mapView => 'Vista de mapa';

  @override
  String get mapComingSoon => 'La vista de mapa llegará pronto.';

  @override
  String get noCompaniesFound => 'No se han encontrado empresas';

  @override
  String get tryWiderRadius => 'Prueba un radio más amplio u otra categoría.';

  @override
  String get verifiedOnly => 'Solo verificados';

  @override
  String get resetFilters => 'Restablecer filtros';

  @override
  String get available => 'Disponible';

  @override
  String lookingFor(String role) {
    return 'Busca: $role';
  }

  @override
  String get boostMyProfile => 'Potenciar mi perfil';

  @override
  String get openToRelocationTravel => 'Abierto a reubicación / viaje';

  @override
  String get tellEmployersAboutYourself =>
      'Cuéntales a los empleadores sobre ti…';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get contractPreference => 'Preferencia de contrato';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get languagePickerSoon => 'Selector de idioma próximamente';

  @override
  String get selectCategoryRoleShort => 'Seleccionar categoría y rol';

  @override
  String get cvUploadSoon => 'Subida de CV próximamente';

  @override
  String get restorePurchasesSoon => 'Restaurar compras próximamente';

  @override
  String get photoUploadShort => 'Subida de foto próximamente';

  @override
  String get hireBestTalent => 'Contrata al mejor talento de hostelería';

  @override
  String get businessLoginSub =>
      'Publica ofertas y conecta con candidatos verificados.';

  @override
  String get lookingForWork => '¿Buscas trabajo? ';

  @override
  String get postJob => 'Publicar oferta';

  @override
  String get editJob => 'Editar oferta';

  @override
  String get jobTitle => 'Título del puesto';

  @override
  String get jobDescription2 => 'Descripción del trabajo';

  @override
  String get publish => 'Publicar';

  @override
  String get saveDraft => 'Guardar borrador';

  @override
  String get applicantsTitle => 'Candidatos';

  @override
  String get newApplicants => 'Nuevos candidatos';

  @override
  String get noApplicantsYet => 'Aún no hay candidatos';

  @override
  String get noApplicantsSubtitle =>
      'Los candidatos aparecerán aquí cuando postulen.';

  @override
  String get scheduleInterview => 'Programar entrevista';

  @override
  String get sendInvite => 'Enviar invitación';

  @override
  String get interviewSent => 'Invitación de entrevista enviada';

  @override
  String get rejectCandidate => 'Rechazar';

  @override
  String get shortlistCandidate => 'Preseleccionar';

  @override
  String get hiringDashboard => 'PANEL DE CONTRATACIÓN';

  @override
  String get yourPipelineActive => 'Tu pipeline\nestá activo';

  @override
  String get postJobToStart => 'Publica una oferta para empezar a contratar';

  @override
  String reviewApplicants(int count) {
    return 'Revisa $count nuevos candidatos';
  }

  @override
  String replyMessages(int count) {
    return 'Responde a $count mensajes no leídos';
  }

  @override
  String get interviews2 => 'Entrevistas';

  @override
  String get businessProfile => 'Perfil de la empresa';

  @override
  String get venueGallery => 'Galería del local';

  @override
  String get addPhotos => 'Añadir fotos';

  @override
  String get businessName => 'Nombre del negocio';

  @override
  String get venueTypeLabel => 'Tipo de local';

  @override
  String selectedItems(int count) {
    return '$count seleccionados';
  }

  @override
  String get hiringProgress => 'Progreso de contratación';

  @override
  String get unlockBusinessPremium => 'Desbloquea Business Premium';

  @override
  String get businessPremiumSubtitle =>
      'Obtén acceso prioritario a los mejores candidatos';

  @override
  String get scheduleFromApplicants => 'Programar desde candidatos';

  @override
  String get recentApplicants => 'Candidatos recientes';

  @override
  String get viewAll => 'Ver todo ›';

  @override
  String get recentActivity => 'Actividad reciente';

  @override
  String get candidatePipeline => 'Pipeline de candidatos';

  @override
  String get allApplicants => 'Todos los candidatos';

  @override
  String get searchCandidates => 'Buscar candidatos, trabajos, entrevistas...';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get allTime => 'Siempre';

  @override
  String get post => 'Publicar';

  @override
  String get candidates => 'Candidatos';

  @override
  String get applicantDetail => 'Detalles del candidato';

  @override
  String get candidateProfile => 'Perfil del candidato';

  @override
  String get shortlistTitle => 'Shortlist';

  @override
  String get noShortlistedCandidates =>
      'Aún no hay candidatos preseleccionados';

  @override
  String get shortlistEmpty =>
      'Los candidatos que preselecciones aparecerán aquí';

  @override
  String get removeFromShortlist => 'Quitar de la lista';

  @override
  String get viewMessages => 'Ver mensajes';

  @override
  String get manageJobs => 'Gestionar ofertas';

  @override
  String get yourJobs => 'Tus ofertas';

  @override
  String get noJobsPosted => 'Aún no hay ofertas publicadas';

  @override
  String get noJobsPostedSubtitle =>
      'Publica tu primera oferta para empezar a contratar';

  @override
  String get draftJobs => 'Borradores';

  @override
  String get activeJobs => 'Activos';

  @override
  String get expiredJobs => 'Caducados';

  @override
  String get closedJobs => 'Cerrados';

  @override
  String get createJob => 'Crear oferta';

  @override
  String get jobDetailsTitle => 'Detalles de la oferta';

  @override
  String get salaryRange => 'Rango salarial';

  @override
  String get currency => 'Moneda';

  @override
  String get monthly => 'Mensual';

  @override
  String get annual => 'Anual';

  @override
  String get hourly => 'Por hora';

  @override
  String get minSalary => 'Mín';

  @override
  String get maxSalary => 'Máx';

  @override
  String get perks => 'Beneficios adicionales';

  @override
  String get addPerk => 'Añadir beneficio';

  @override
  String get remove => 'Eliminar';

  @override
  String get preview => 'Vista previa';

  @override
  String get publishJob => 'Publicar oferta';

  @override
  String get jobPublished => 'Oferta publicada';

  @override
  String get jobUpdated => 'Oferta actualizada';

  @override
  String get jobSavedDraft => 'Guardada como borrador';

  @override
  String get fillRequired => 'Por favor rellena los campos obligatorios';

  @override
  String get jobUrgent => 'Marcar como urgente';

  @override
  String get addAtLeastOne => 'Añade al menos un requisito';

  @override
  String get createUpdate => 'Crear novedad';

  @override
  String get shareCompanyNews => 'Comparte novedades de la empresa';

  @override
  String get addStory => 'Añadir historia';

  @override
  String get showWorkplace => 'Muestra tu espacio de trabajo';

  @override
  String get viewShortlist => 'Ver preseleccionados';

  @override
  String get yourSavedCandidates => 'Tus candidatos guardados';

  @override
  String get inviteCandidate => 'Invitar candidato';

  @override
  String get reachOutDirectly => 'Contacta directamente';

  @override
  String activeJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ofertas activas',
      one: '1 oferta activa',
    );
    return '$_temp0';
  }

  @override
  String get employmentType => 'Tipo de empleo';

  @override
  String get requiredRole => 'Rol requerido';

  @override
  String get selectCategoryRole2 => 'Seleccionar categoría y rol';

  @override
  String get hiresNeeded => 'Contrataciones necesarias';

  @override
  String get compensation => 'Remuneración';

  @override
  String get useSalaryRange => 'Usar rango salarial';

  @override
  String get contractDuration => 'Duración del contrato';

  @override
  String get limitReached => 'Límite alcanzado';

  @override
  String get upgradePlan => 'Mejorar plan';

  @override
  String usingXofY(int used, int total) {
    return 'Estás usando $used de $total publicaciones.';
  }

  @override
  String get businessInterviewsTitle => 'Entrevistas';

  @override
  String get noInterviewsYet => 'No hay entrevistas programadas';

  @override
  String get scheduleFirstInterview =>
      'Programa tu primera entrevista con un candidato';

  @override
  String get sendInterviewInvite => 'Enviar invitación de entrevista';

  @override
  String get interviewSentTitle => '¡Invitación enviada!';

  @override
  String get interviewSentSubtitle => 'Se ha notificado al candidato.';

  @override
  String get scheduleInterviewTitle => 'Programar entrevista';

  @override
  String get interviewType => 'Tipo de entrevista';

  @override
  String get inPersonInterview => 'En persona';

  @override
  String get videoCallInterview => 'Videollamada';

  @override
  String get phoneCallInterview => 'Llamada telefónica';

  @override
  String get interviewDate => 'Fecha';

  @override
  String get interviewTime => 'Hora';

  @override
  String get interviewLocation => 'Ubicación';

  @override
  String get interviewNotes => 'Notas';

  @override
  String get optionalLabel => 'Opcional';

  @override
  String get sendInviteCta => 'Enviar invitación';

  @override
  String messagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes',
      one: '1 mensaje',
    );
    return '$_temp0';
  }

  @override
  String get noNewMessages => 'No hay mensajes nuevos';

  @override
  String get subscriptionTitle => 'Suscripción';

  @override
  String get currentPlan => 'Plan actual';

  @override
  String get manage => 'Gestionar';

  @override
  String get upgrade => 'Mejorar';

  @override
  String get renewalDate => 'Fecha de renovación';

  @override
  String get nearbyTalent => 'Talento cercano';

  @override
  String get searchNearby => 'Buscar cerca';

  @override
  String get communityTitle => 'Comunidad';

  @override
  String get createPost => 'Crear publicación';

  @override
  String get insights => 'Estadísticas';

  @override
  String get viewsLabel => 'Visualizaciones';

  @override
  String get applicationsLabel => 'Candidaturas';

  @override
  String get conversionRate => 'Tasa de conversión';

  @override
  String get topPerformingJob => 'Oferta con mejor rendimiento';

  @override
  String get viewAllSimple => 'Ver todo';

  @override
  String get viewAllApplicantsForJob =>
      'Ver todos los candidatos de esta oferta';

  @override
  String get noUpcomingInterviews => 'No hay entrevistas próximas';

  @override
  String get noActivityYet => 'Aún no hay actividad';

  @override
  String get noResultsFound => 'No se han encontrado resultados';

  @override
  String get renewsAutomatically => 'Se renueva automáticamente';

  @override
  String get plagitBusinessPlans => 'Planes Business de Plagit';

  @override
  String get scaleYourHiringSubtitle =>
      'Escala tu contratación con el plan adecuado para tu negocio.';

  @override
  String get yearly => 'Anual';

  @override
  String get saveWithAnnualBilling => 'Ahorra más con facturación anual';

  @override
  String get chooseYourPlanSubtitle =>
      'Elige el plan que se adapte a tus necesidades de contratación.';

  @override
  String continueWithPlan(String plan) {
    return 'Continuar con $plan';
  }

  @override
  String get subscriptionAutoRenewNote =>
      'La suscripción se renueva automáticamente. Cancela cuando quieras en Ajustes.';

  @override
  String get purchaseFlowComingSoon => 'Flujo de compra próximamente';

  @override
  String get applicant => 'Candidato';

  @override
  String get applicantNotFound => 'Candidato no encontrado';

  @override
  String get cvViewerComingSoon => 'Visor de CV próximamente';

  @override
  String get viewCV => 'Ver CV';

  @override
  String get application => 'Candidatura';

  @override
  String get messagingComingSoon => 'Mensajería próximamente';

  @override
  String get interviewConfirmed => 'Entrevista confirmada';

  @override
  String get interviewMarkedCompleted => 'Entrevista marcada como completada';

  @override
  String get cancelInterviewConfirm =>
      '¿Seguro que quieres cancelar esta entrevista?';

  @override
  String get yesCancel => 'Sí, cancelar';

  @override
  String get interviewNotFound => 'Entrevista no encontrada';

  @override
  String get openingMeetingLink => 'Abriendo enlace de reunión...';

  @override
  String get rescheduleComingSoon => 'Función de reprogramación próximamente';

  @override
  String get notesFeatureComingSoon => 'Función de notas próximamente';

  @override
  String get candidateMarkedHired => '¡Candidato marcado como contratado!';

  @override
  String get feedbackComingSoon => 'Función de feedback próximamente';

  @override
  String get googleMapsComingSoon => 'Integración con Google Maps próximamente';

  @override
  String get noCandidatesNearby => 'No hay candidatos cerca';

  @override
  String get tryExpandingRadius => 'Prueba a ampliar tu radio de búsqueda.';

  @override
  String get candidate => 'Candidato';

  @override
  String get forOpenPosition => 'Para posición abierta';

  @override
  String get dateAndTimeUpper => 'FECHA Y HORA';

  @override
  String get interviewTypeUpper => 'TIPO DE ENTREVISTA';

  @override
  String get timezoneUpper => 'ZONA HORARIA';

  @override
  String get highlights => 'Destacados';

  @override
  String get cvNotAvailable => 'CV no disponible';

  @override
  String get cvWillAppearHere => 'Aparecerá aquí cuando se suba';

  @override
  String get seenEveryone => 'Ya los has visto a todos';

  @override
  String get checkBackForCandidates =>
      'Vuelve más tarde para ver nuevos candidatos.';

  @override
  String get dailyLimitReached => 'Límite diario alcanzado';

  @override
  String get upgradeForUnlimitedSwipes => 'Mejora para swipes ilimitados.';

  @override
  String get distanceUpper => 'DISTANCIA';

  @override
  String get inviteToInterview => 'Invitar a entrevista';

  @override
  String get details => 'Detalles';

  @override
  String get shortlistedSuccessfully => 'Preseleccionado correctamente';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabCandidates => 'Candidatos';

  @override
  String get tabActivity => 'Actividad';

  @override
  String get statusPosted => 'Publicado';

  @override
  String get statusApplicants => 'Candidatos';

  @override
  String get statusInterviewsShort => 'Entrevistas';

  @override
  String get statusHiredShort => 'Contratado';

  @override
  String get jobLiveVisible => 'Tu oferta está activa y visible';

  @override
  String get postJobShort => 'Publicar oferta';

  @override
  String get messagesTitle => 'Mensajes';

  @override
  String get online2 => 'En línea ahora';

  @override
  String get candidateUpper => 'CANDIDATO';

  @override
  String get searchConversationsHint =>
      'Busca conversaciones, candidatos, roles…';

  @override
  String get filterUnread => 'No leídos';

  @override
  String get filterAll => 'Todos';

  @override
  String get whenCandidatesMessage =>
      'Cuando los candidatos te escriban, las conversaciones aparecerán aquí.';

  @override
  String get trySwitchingFilter => 'Prueba a cambiar a otro filtro.';

  @override
  String get reply => 'Responder';

  @override
  String get selectItems => 'Seleccionar elementos';

  @override
  String countSelected(int count) {
    return '$count seleccionados';
  }

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get deleteConversation => '¿Eliminar conversación?';

  @override
  String get deleteAllConversations => '¿Eliminar todas las conversaciones?';

  @override
  String get deleteSelectedNote =>
      'Los chats seleccionados se eliminarán de tu bandeja. El candidato conserva su copia.';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get selectConversations => 'Seleccionar conversaciones';

  @override
  String get feedTab => 'Feed';

  @override
  String get myPostsTab => 'Mis publicaciones';

  @override
  String get savedTab => 'Guardados';

  @override
  String postingAs(String name) {
    return 'Publicando como $name';
  }

  @override
  String get noPostsYet => 'Aún no has publicado nada';

  @override
  String get nothingHereYet => 'Aún no hay nada aquí';

  @override
  String get shareVenueUpdate =>
      'Comparte una novedad de tu local para empezar a construir tu presencia en la comunidad.';

  @override
  String get communityPostsAppearHere =>
      'Las publicaciones de la comunidad aparecerán aquí.';

  @override
  String get createFirstPost => 'Crear primera publicación';

  @override
  String get yourPostUpper => 'TU PUBLICACIÓN';

  @override
  String get businessLabel => 'Empresa';

  @override
  String get profileNotAvailable => 'Perfil no disponible';

  @override
  String get companyProfile => 'Perfil de la empresa';

  @override
  String get premiumVenue => 'Local Premium';

  @override
  String get businessDetailsTitle => 'Datos de la empresa';

  @override
  String get businessNameLabel => 'Nombre del negocio';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String get verificationLabel => 'Verificación';

  @override
  String get pendingLabel => 'Pendiente';

  @override
  String get notSet => 'No definido';

  @override
  String get contactLabel => 'Contacto';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get phoneLabel => 'Teléfono';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get companyNameField => 'Nombre de la empresa';

  @override
  String get phoneField => 'Teléfono';

  @override
  String get locationField => 'Ubicación';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutTitle => '¿Cerrar sesión?';

  @override
  String get signOutConfirm => '¿Seguro que quieres cerrar sesión?';

  @override
  String activeCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activos',
      one: '1 activo',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuevos esta semana',
      one: '1 nuevo esta semana',
    );
    return '$_temp0';
  }

  @override
  String get jobStatusActive => 'Activa';

  @override
  String get jobStatusPaused => 'Pausada';

  @override
  String get jobStatusClosed => 'Cerrada';

  @override
  String get jobStatusDraft => 'Borrador';

  @override
  String get contractCasual => 'Ocasional';

  @override
  String get planBasic => 'Basic';

  @override
  String get planPro => 'Pro';

  @override
  String get planPremium => 'Premium';

  @override
  String get bestForMaxVisibility => 'Ideal para máxima visibilidad';

  @override
  String saveDollarsPerYear(String currency, String amount) {
    return 'Ahorra $currency$amount/año';
  }

  @override
  String get planBasicFeature1 => 'Publica hasta 3 ofertas';

  @override
  String get planBasicFeature2 => 'Ver perfiles de candidatos';

  @override
  String get planBasicFeature3 => 'Búsqueda básica de candidatos';

  @override
  String get planBasicFeature4 => 'Soporte por correo';

  @override
  String get planProFeature1 => 'Publica hasta 10 ofertas';

  @override
  String get planProFeature2 => 'Búsqueda avanzada de candidatos';

  @override
  String get planProFeature3 => 'Orden prioritario de candidatos';

  @override
  String get planProFeature4 => 'Acceso a Quick Plug';

  @override
  String get planProFeature5 => 'Soporte por chat';

  @override
  String get planPremiumFeature1 => 'Ofertas ilimitadas';

  @override
  String get planPremiumFeature2 => 'Ofertas destacadas';

  @override
  String get planPremiumFeature3 => 'Analítica avanzada';

  @override
  String get planPremiumFeature4 => 'Acceso completo a Quick Plug';

  @override
  String get planPremiumFeature5 => 'Soporte prioritario 24/7';

  @override
  String get planPremiumFeature6 => 'Gestor de cuenta dedicado';

  @override
  String get currentSelectionCheck => 'Selección actual ✓';

  @override
  String selectPlanName(String plan) {
    return 'Seleccionar $plan';
  }

  @override
  String get perYear => '/año';

  @override
  String get perMonth => '/mes';

  @override
  String get jobTitleHintExample => 'ej. Chef Senior';

  @override
  String get locationHintExample => 'ej. Dubái, EAU';

  @override
  String annualSalaryLabel(String currency) {
    return 'Salario anual ($currency)';
  }

  @override
  String monthlyPayLabel(String currency) {
    return 'Paga mensual ($currency)';
  }

  @override
  String hourlyRateLabel(String currency) {
    return 'Tarifa por hora ($currency)';
  }

  @override
  String minSalaryLabel(String currency) {
    return 'Mín ($currency)';
  }

  @override
  String maxSalaryLabel(String currency) {
    return 'Máx ($currency)';
  }

  @override
  String get hoursPerWeekLabel => 'Horas / semana';

  @override
  String get expectedHoursWeekLabel => 'Horas previstas / semana (opcional)';

  @override
  String get bonusTipsLabel => 'Bonus / Propinas (opcional)';

  @override
  String get bonusTipsHint => 'ej. Propinas y servicio';

  @override
  String get housingIncludedLabel => 'Alojamiento incluido';

  @override
  String get travelIncludedLabel => 'Viaje incluido';

  @override
  String get overtimeAvailableLabel => 'Horas extra disponibles';

  @override
  String get flexibleScheduleLabel => 'Horario flexible';

  @override
  String get weekendShiftsLabel => 'Turnos de fin de semana';

  @override
  String get describeRoleHint =>
      'Describe el rol, las responsabilidades y qué hace especial este trabajo...';

  @override
  String get requirementsHint =>
      'Habilidades, experiencia, certificaciones requeridas...';

  @override
  String previewPrefix(String text) {
    return 'Vista previa: $text';
  }

  @override
  String monthsShort(int count) {
    return '$count meses';
  }

  @override
  String get roleAll => 'Todos';

  @override
  String get roleChef => 'Chef';

  @override
  String get roleWaiter => 'Camarero';

  @override
  String get roleBartender => 'Bartender';

  @override
  String get roleHost => 'Host';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleReception => 'Recepción';

  @override
  String get roleKitchenPorter => 'Ayudante de cocina';

  @override
  String get roleRelocate => 'Reubicación';

  @override
  String get experience02Years => '0-2 años';

  @override
  String get experience35Years => '3-5 años';

  @override
  String get experience5PlusYears => '5+ años';

  @override
  String get roleUpper => 'ROL';

  @override
  String get experienceUpper => 'EXPERIENCIA';

  @override
  String get cvLabel => 'CV';

  @override
  String get addShort => 'Añadir';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String candidatesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidatos encontrados',
      one: '1 candidato encontrado',
    );
    return '$_temp0';
  }

  @override
  String get maxKmLabel => 'máx 50 km';

  @override
  String get shortlistAction => 'Shortlist';

  @override
  String get messageAction => 'Mensaje';

  @override
  String get interviewAction => 'Entrevistar';

  @override
  String get viewAction => 'Ver';

  @override
  String get rejectAction => 'Rechazar';

  @override
  String get basedIn => 'Residencia';

  @override
  String get verificationPending => 'Verificación en curso';

  @override
  String get refreshAction => 'Actualizar';

  @override
  String get upgradeAction => 'Pasar a Premium';

  @override
  String get searchJobsByTitleHint => 'Busca por título, rol o ubicación…';

  @override
  String xShortlisted(String name) {
    return '$name añadido a la shortlist';
  }

  @override
  String xRejected(String name) {
    return '$name rechazado';
  }

  @override
  String rejectConfirmName(String name) {
    return '¿Seguro que quieres rechazar a $name?';
  }

  @override
  String appliedToRoleOn(String role, String date) {
    return 'Postulado a $role el $date';
  }

  @override
  String appliedDatePrefix(String date) {
    return 'Enviado $date';
  }

  @override
  String get salaryExpectationTitle => 'Salario esperado';

  @override
  String get previousEmployer => 'Empleador anterior';

  @override
  String get earlierVenue => 'Local anterior';

  @override
  String get presentLabel => 'Actual';

  @override
  String get skillCustomerService => 'Atención al cliente';

  @override
  String get skillTeamwork => 'Trabajo en equipo';

  @override
  String get skillCommunication => 'Comunicación';

  @override
  String get stepApplied => 'Postulado';

  @override
  String get stepViewed => 'Visto';

  @override
  String get stepShortlisted => 'En shortlist';

  @override
  String get stepInterviewScheduled => 'Entrevista programada';

  @override
  String get stepRejected => 'Rechazado';

  @override
  String get stepUnderReview => 'En revisión';

  @override
  String get stepPendingReview => 'Pendiente de revisión';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortMostExperienced => 'Más experimentados';

  @override
  String get sortBestMatch => 'Mejor coincidencia';

  @override
  String get filterApplied => 'Postulado';

  @override
  String get filterUnderReview => 'En revisión';

  @override
  String get filterShortlisted => 'En shortlist';

  @override
  String get filterInterview => 'Entrevista';

  @override
  String get filterHired => 'Contratados';

  @override
  String get filterRejected => 'Rechazados';

  @override
  String get confirmed => 'Confirmada';

  @override
  String get pending => 'Pendiente';

  @override
  String get completed => 'Completada';

  @override
  String get cancelled => 'Cancelada';

  @override
  String get videoLabel => 'Video';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get interviewDetails => 'Detalles de la entrevista';

  @override
  String get interviewConfirmedHeadline => 'Entrevista confirmada';

  @override
  String get interviewConfirmedSubline =>
      'Todo está listo. Te enviaremos un recordatorio antes de la hora.';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get timeLabel => 'Hora';

  @override
  String get formatLabel => 'Modalidad';

  @override
  String get joinMeeting => 'Unirse';

  @override
  String get viewJobAction => 'Ver oferta';

  @override
  String get addToCalendar => 'Añadir al calendario';

  @override
  String get needsYourAttention => 'Requiere tu atención';

  @override
  String get reviewAction => 'Revisar';

  @override
  String applicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidaturas',
      one: '1 candidatura',
    );
    return '$_temp0';
  }

  @override
  String get sortMostRecent => 'Más recientes';

  @override
  String get interviewScheduledLabel => 'Entrevista programada';

  @override
  String get editAction => 'Editar';

  @override
  String get currentPlanLabel => 'Plan actual';

  @override
  String get freePlan => 'Plan gratuito';

  @override
  String get profileStrength => 'Fuerza del perfil';

  @override
  String get detailsLabel => 'Detalles';

  @override
  String get basedInLabel => 'Residencia';

  @override
  String get verificationLabel2 => 'Verificación';

  @override
  String get contactLabel2 => 'Contactos';

  @override
  String get notSetLabel => 'No definido';

  @override
  String get chipAll => 'Todos';

  @override
  String get chipFullTime => 'Tiempo completo';

  @override
  String get chipPartTime => 'Medio tiempo';

  @override
  String get chipTemporary => 'Temporal';

  @override
  String get chipCasual => 'Ocasional';

  @override
  String get sortBestMatchLabel => 'Mejor coincidencia';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get featuredBadge => 'Destacado';

  @override
  String get urgentBadge => 'Urgente';

  @override
  String get salaryOnRequest => 'Salario a convenir';

  @override
  String get upgradeToPremium => 'Pasar a Premium';

  @override
  String get urgentJobsOnly => 'Solo trabajos urgentes';

  @override
  String get showOnlyUrgentListings => 'Mostrar solo ofertas urgentes';

  @override
  String get verifiedBusinessesOnly => 'Solo empresas verificadas';

  @override
  String get showOnlyVerifiedBusinesses => 'Mostrar solo empresas verificadas';

  @override
  String get split => 'Mixto';

  @override
  String get payUpper => 'PAGA';

  @override
  String get typeUpper => 'TIPO';

  @override
  String get whereUpper => 'DÓNDE';

  @override
  String get payLabel => 'Paga';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get whereLabel => 'Dónde';

  @override
  String get whereYouWillWork => 'Dónde trabajarás';

  @override
  String get mapPreviewDirections =>
      'Vista previa del mapa · abrir para indicaciones completas';

  @override
  String get directionsAction => 'Indicaciones';

  @override
  String get communityTabForYou => 'Para ti';

  @override
  String get communityTabFollowing => 'Siguiendo';

  @override
  String get communityTabNearby => 'Cerca';

  @override
  String get communityTabSaved => 'Guardados';

  @override
  String get viewProfileAction => 'Ver perfil';

  @override
  String get copyLinkAction => 'Copiar enlace';

  @override
  String get savePostAction => 'Guardar publicación';

  @override
  String get unsavePostAction => 'Quitar de guardados';

  @override
  String get hideThisPost => 'Ocultar esta publicación';

  @override
  String get reportPost => 'Reportar publicación';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get newPostTitle => 'Nueva publicación';

  @override
  String get youLabel => 'Tú';

  @override
  String get postingToCommunityAsBusiness =>
      'Estás publicando en la comunidad como Empresa';

  @override
  String get postingToCommunityAsPro =>
      'Estás publicando en la comunidad como Hospitality Pro';

  @override
  String get whatsOnYourMind => '¿En qué estás pensando?';

  @override
  String get publishAction => 'Publicar';

  @override
  String get attachmentPhoto => 'Foto';

  @override
  String get attachmentVideo => 'Video';

  @override
  String get attachmentLocation => 'Ubicación';

  @override
  String get boostMyProfileCta => 'Potenciar mi perfil';

  @override
  String get unlockYourFullPotential => 'Desbloquea todo tu potencial';

  @override
  String get annualPlan => 'Anual';

  @override
  String get monthlyPlan => 'Mensual';

  @override
  String get bestValueBadge => 'MEJOR VALOR';

  @override
  String get whatsIncluded => 'Qué incluye';

  @override
  String get continueWithAnnual => 'Continuar con Anual';

  @override
  String get continueWithMonthly => 'Continuar con Mensual';

  @override
  String get maybeLater => 'Quizás más tarde';

  @override
  String get restorePurchasesLabel => 'Restaurar compras';

  @override
  String get subscriptionAutoRenewsNote =>
      'La suscripción se renueva automáticamente. Cancela cuando quieras en Ajustes.';

  @override
  String get appStatusPillApplied => 'Postulado';

  @override
  String get appStatusPillUnderReview => 'En revisión';

  @override
  String get appStatusPillShortlisted => 'En shortlist';

  @override
  String get appStatusPillInterviewInvited => 'Invitación a entrevista';

  @override
  String get appStatusPillInterviewScheduled => 'Entrevista programada';

  @override
  String get appStatusPillHired => 'Contratado';

  @override
  String get appStatusPillRejected => 'Rechazado';

  @override
  String get appStatusPillWithdrawn => 'Retirado';

  @override
  String get jobActionPause => 'Pausar';

  @override
  String get jobActionResume => 'Reactivar oferta';

  @override
  String get jobActionClose => 'Cerrar oferta';

  @override
  String get statusConfirmedLower => 'confirmada';

  @override
  String get postInsightsTitle => 'Estadísticas de la publicación';

  @override
  String get postInsightsSubtitle => 'Quién está viendo tu contenido';

  @override
  String get recentViewers => 'Visitantes recientes';

  @override
  String get lockedBadge => 'BLOQUEADO';

  @override
  String get viewerBreakdown => 'Desglose de visualizaciones';

  @override
  String get viewersByRole => 'Visitantes por rol';

  @override
  String get topLocations => 'Ubicaciones principales';

  @override
  String get businesses => 'Empresas';

  @override
  String get saveToCollectionTitle => 'Guardar en la colección';

  @override
  String get chooseCategory => 'Elegir categoría';

  @override
  String get removeFromCollection => 'Quitar de la colección';

  @override
  String newApplicationTemplate(String role) {
    return 'Nueva candidatura — $role';
  }

  @override
  String get categoryRestaurants => 'Restaurantes';

  @override
  String get categoryCookingVideos => 'Vídeos de cocina';

  @override
  String get categoryJobsTips => 'Consejos de trabajo';

  @override
  String get categoryHospitalityNews => 'Noticias de hostelería';

  @override
  String get categoryRecipes => 'Recetas';

  @override
  String get categoryOther => 'Otros';

  @override
  String get premiumHeroTagline =>
      'Más visibilidad, notificaciones prioritarias y filtros avanzados pensados para los profesionales de la hostelería.';

  @override
  String get benefitAdvancedFilters => 'Filtros de búsqueda avanzados';

  @override
  String get benefitPriorityNotifications =>
      'Notificaciones de trabajo prioritarias';

  @override
  String get benefitProfileVisibility => 'Mayor visibilidad del perfil';

  @override
  String get benefitPremiumBadge => 'Insignia Premium en el perfil';

  @override
  String get benefitEarlyAccess => 'Acceso anticipado a nuevos trabajos';

  @override
  String get unlockCandidatePremium => 'Desbloquea Candidate Premium';

  @override
  String get getStartedAction => 'Empezar ahora';

  @override
  String get findYourFirstJob => 'Encuentra tu primer trabajo';

  @override
  String get browseHospitalityRolesNearby =>
      'Explora cientos de puestos de hostelería cerca de ti';

  @override
  String get seeWhoViewedYourPostTitle => 'Ve quién ha visto tu publicación';

  @override
  String get upgradeToPremiumCta => 'Pasar a Premium';

  @override
  String get upgradeToPremiumSubtitle =>
      'Pasa a Premium para ver empresas verificadas, reclutadores y responsables de contratación que han visto tu contenido.';

  @override
  String get verifiedBusinessViewers => 'Visitantes de empresas verificadas';

  @override
  String get recruiterHiringManagerActivity =>
      'Actividad de reclutadores y responsables de contratación';

  @override
  String get cityLevelReachBreakdown => 'Cobertura por ciudad';

  @override
  String liveApplicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activas',
      one: '1 activa',
    );
    return '$_temp0';
  }

  @override
  String nearbyJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cerca de ti',
      one: '1 cerca de ti',
    );
    return '$_temp0';
  }

  @override
  String jobsNearYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trabajos cerca de ti',
      one: '1 trabajo cerca de ti',
    );
    return '$_temp0';
  }

  @override
  String applicationsUnderReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidaturas en revisión',
      one: '1 candidatura en revisión',
    );
    return '$_temp0';
  }

  @override
  String interviewsScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrevistas programadas',
      one: '1 entrevista programada',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes no leídos',
      one: '1 mensaje no leído',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesFromEmployersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes no leídos de empleadores',
      one: '1 mensaje no leído de empleadores',
    );
    return '$_temp0';
  }

  @override
  String stepsLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos restantes',
      one: '1 paso restante',
    );
    return '$_temp0';
  }

  @override
  String get profileCompleteGreatWork => 'Perfil completo — ¡gran trabajo!';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '1 año',
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
      other: '$count horas/semana',
      one: '1 hora/semana',
    );
    return '$_temp0';
  }

  @override
  String forMonthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'por $count meses',
      one: 'por 1 mes',
    );
    return '$_temp0';
  }

  @override
  String interviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrevistas',
      one: '1 entrevista',
    );
    return '$_temp0';
  }

  @override
  String get quickActionFindJobs => 'Buscar trabajos';

  @override
  String get quickActionMyApplications => 'Mis candidaturas';

  @override
  String get quickActionUpdateProfile => 'Actualizar perfil';

  @override
  String get quickActionCreatePost => 'Crear publicación';

  @override
  String get quickActionViewInterviews => 'Ver entrevistas';

  @override
  String get confirmSubscriptionTitle => 'Confirmar suscripción';

  @override
  String get confirmAndSubscribeCta => 'Confirmar y suscribirse';

  @override
  String get timelineLabel => 'Cronología';

  @override
  String get interviewLabel => 'Entrevista';

  @override
  String get payOnRequest => 'Pago a convenir';

  @override
  String get rateOnRequest => 'Tarifa a convenir';

  @override
  String get quickActionFindJobsSubtitle => 'Descubre puestos cerca de ti';

  @override
  String get quickActionMyApplicationsSubtitle => 'Sigue cada candidatura';

  @override
  String get quickActionUpdateProfileSubtitle =>
      'Mejora tu visibilidad y puntuación de match';

  @override
  String get quickActionCreatePostSubtitle =>
      'Comparte tu trabajo con la comunidad';

  @override
  String get quickActionViewInterviewsSubtitle => 'Prepárate para lo que viene';

  @override
  String get offerLabel => 'Oferta';

  @override
  String hiringForTemplate(String role) {
    return 'Contratando para $role';
  }

  @override
  String get tapToOpenInMaps => 'Toca para abrir en Mapas';

  @override
  String get alreadyAppliedToJob =>
      'Ya has enviado una candidatura para este trabajo.';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get changeAvatar => 'Cambiar avatar';

  @override
  String get addPhotoAction => 'Añadir foto';

  @override
  String get nationalityLabel => 'Nacionalidad';

  @override
  String get targetRoleLabel => 'Rol deseado';

  @override
  String get salaryExpectationLabel => 'Expectativa salarial';

  @override
  String get addLanguageCta => '+ Añadir idioma';

  @override
  String get experienceLabel => 'Experiencia';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get zeroHours => 'Cero horas';

  @override
  String get checkInterviewDetailsLine =>
      'Comprueba los detalles de la entrevista';

  @override
  String get interviewInvitedSubline =>
      'La empresa quiere conocerte — confirma una hora';

  @override
  String get shortlistedSubline =>
      'Estás en la shortlist — espera el próximo paso';

  @override
  String get underReviewSubline => 'La empresa está evaluando tu perfil';

  @override
  String get hiredHeadline => 'Contratado';

  @override
  String get hiredSubline => '¡Enhorabuena! Has recibido una oferta';

  @override
  String get applicationSubmittedHeadline => 'Candidatura enviada';

  @override
  String get applicationSubmittedSubline =>
      'La empresa evaluará tu candidatura';

  @override
  String get withdrawnHeadline => 'Retirada';

  @override
  String get withdrawnSubline => 'Has retirado esta candidatura';

  @override
  String get notSelectedHeadline => 'No seleccionado';

  @override
  String get notSelectedSubline => 'Gracias por tu interés';

  @override
  String jobsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trabajos encontrados',
      one: '1 trabajo encontrado',
    );
    return '$_temp0';
  }

  @override
  String applicationsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count total',
      one: '1 total',
    );
    return '$_temp0';
  }

  @override
  String applicationsInReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en revisión',
      one: '1 en revisión',
    );
    return '$_temp0';
  }

  @override
  String applicationsLiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count activas',
      one: '1 activa',
    );
    return '$_temp0';
  }

  @override
  String interviewsPendingConfirmTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrevistas pendientes — confirma una hora.',
      one: '1 entrevista pendiente — confirma una hora.',
    );
    return '$_temp0';
  }

  @override
  String notifInterviewConfirmedTitle(String name) {
    return 'Entrevista confirmada — $name';
  }

  @override
  String notifInterviewRequestTitle(String name) {
    return 'Solicitud de entrevista — $name';
  }

  @override
  String notifApplicationUpdateTitle(String name) {
    return 'Actualización de candidatura — $name';
  }

  @override
  String notifOfferReceivedTitle(String name) {
    return 'Oferta recibida — $name';
  }

  @override
  String notifMessageFromTitle(String name) {
    return 'Mensaje de — $name';
  }

  @override
  String notifInterviewReminderTitle(String name) {
    return 'Recordatorio de entrevista — $name';
  }

  @override
  String notifProfileViewedTitle(String name) {
    return 'Perfil visto — $name';
  }

  @override
  String notifNewJobMatchTitle(String name) {
    return 'Nuevo match de trabajo — $name';
  }

  @override
  String notifApplicationViewedTitle(String name) {
    return 'Tu candidatura fue vista por — $name';
  }

  @override
  String notifShortlistedTitle(String name) {
    return 'Has entrado en la shortlist de — $name';
  }

  @override
  String get notifCompleteProfile =>
      'Completa tu perfil para mejores coincidencias';

  @override
  String get notifCompleteBusinessProfile =>
      'Completa el perfil de tu empresa para una mayor visibilidad';

  @override
  String notifNewJobViews(String role, String count) {
    return 'Tu oferta $role tiene $count nuevas visualizaciones';
  }

  @override
  String notifAppliedForRole(String name, String role) {
    return '$name ha postulado para $role';
  }

  @override
  String notifNewApplicationNameRole(String name, String role) {
    return 'Nueva candidatura: $name para $role';
  }

  @override
  String get chatTyping => 'Escribiendo...';

  @override
  String get chatStatusSeen => 'Visto';

  @override
  String get chatStatusDelivered => 'Entregado';

  @override
  String get entryTagline =>
      'La piattaforma de staffing para professionisti dell\'hostelería.';

  @override
  String get entryFindWork => 'Buscar trabajo';

  @override
  String get entryFindWorkSubtitle =>
      'Explora trabajos y hazte contratar por los mejores locales';

  @override
  String get entryHireStaff => 'Contratar personal';

  @override
  String get entryHireStaffSubtitle =>
      'Publica ofertas y encuentra el mejor talento';

  @override
  String get entryFindCompanies => 'Buscar empresas';

  @override
  String get entryFindCompaniesSubtitle =>
      'Descubre locales y proveedores de servicios para la hostelería';

  @override
  String get servicesEntryTitle => 'In buscar de empresas';

  @override
  String get servicesHospitalityServices => 'Servicios para hostelería';

  @override
  String get servicesEntrySubtitle =>
      'Registra tu empresa de servicios o busca proveedores cerca de ti';

  @override
  String get servicesRegisterCardTitle => 'Registrarse como empresa';

  @override
  String get servicesRegisterCardSubtitle =>
      'Registra tu servicio y deja que los clientes te descubran';

  @override
  String get servicesLookingCardTitle => 'Sto cercando un\'empresa';

  @override
  String get servicesLookingCardSubtitle =>
      'Busca proveedores de servicios cerca de ti';

  @override
  String get registerBusinessTitle => 'Registra la tu empresa';

  @override
  String get enterCompanyName => 'Inserisci nombre empresa';

  @override
  String get subcategoryOptional => 'Subcategoría (opcional)';

  @override
  String get subcategoryHintFloristDj => 'ej. Florista, servicios DJ';

  @override
  String get searchCompaniesHint => 'Buscar empresas...';

  @override
  String get browseCategories => 'Explorar categorías';

  @override
  String companiesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count empresas encontradas',
      one: '1 empresa encontrada',
    );
    return '$_temp0';
  }

  @override
  String get serviceCategoryFoodBeverage =>
      'Proveedores de alimentos y bebidas';

  @override
  String get serviceCategoryEventServices => 'Servicios para eventos';

  @override
  String get serviceCategoryDecorDesign => 'Decoración y diseño';

  @override
  String get serviceCategoryEntertainment => 'Entretenimiento';

  @override
  String get serviceCategoryEquipmentOps => 'Equipamiento y operaciones';

  @override
  String get serviceCategoryCleaningMaintenance => 'Limpieza y mantenimiento';

  @override
  String distanceMiles(String value) {
    return '$value mi';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String get postDetailTitle => 'Publicación';

  @override
  String get likeAction => 'Mi piace';

  @override
  String get commentAction => 'Commenta';

  @override
  String get saveActionLabel => 'Guardar';

  @override
  String get commentsTitle => 'Commenti';

  @override
  String get addCommentHint => 'Añadir un commento…';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}m',
      one: '1m',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHoursShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}h',
      one: '1h',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDaysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '${count}d',
      one: '1d',
    );
    return '$_temp0';
  }

  @override
  String get timeAgoNow => 'ahora';

  @override
  String get activityTitle => 'Negocio';

  @override
  String get activityLikedPost => 'ha messo mi piace al tu post';

  @override
  String get activityCommented => 'ha commentato el tu post';

  @override
  String get activityStartedFollowing => 'ha iniziato a seguirti';

  @override
  String get activityMentioned => 'ti ha menzionato';

  @override
  String get activitySystemUpdate => 'te ha enviado una actualización';

  @override
  String get noActivityYetDesc =>
      'Cuando alguien dé me gusta, comente o te siga, aparecerá aquí.';

  @override
  String get activeStatus => 'Activo';

  @override
  String get activeBadge => 'ACTIVO';

  @override
  String get nextRenewalLabel => 'Próxima renovación';

  @override
  String get startedLabel => 'Iniciado';

  @override
  String get statusLabel => 'Stato';

  @override
  String get billingAndCancellation => 'Facturación y cancelación';

  @override
  String get billingAndCancellationCopy =>
      'Tu suscripción se carga a través de tu cuenta de App Store / Google Play. Puedes cancelarla cuando quieras desde los Ajustes del dispositivo — mantendrás el acceso Premium hasta la fecha de renovación.';

  @override
  String get premiumIsActive => 'Premium está activo';

  @override
  String get premiumThanksCopy =>
      'Gracias por apoyar a Plagit. Tienes acceso completo a todas las funciones Premium.';

  @override
  String get manageSubscription => 'Gestionar suscripción';

  @override
  String get candidatePremiumPlanName => 'Candidate Premium';

  @override
  String renewsOnDate(String date) {
    return 'Si rinnova el $date';
  }

  @override
  String get fullViewerAccessLine =>
      'Acceso completo a los visitantes · todas las estadísticas desbloqueadas';

  @override
  String get premiumActiveBadge => 'Premium activo';

  @override
  String get fullInsightsUnlocked =>
      'Estadísticas completas y detalles de visitantes desbloqueados.';

  @override
  String get noViewersInCategory => 'Aún no hay visitantes en esta categoría';

  @override
  String get onlyVerifiedViewersShown =>
      'Solo se muestran los visitantes verificados con perfiles públicos.';

  @override
  String get notEnoughDataYet => 'Datos aún insuficientes.';

  @override
  String get noViewInsightsYet => 'Aún no hay estadísticas de visualización';

  @override
  String get noViewInsightsDesc =>
      'Las estadísticas aparecerán cuando tu publicación tenga más visualizaciones.';

  @override
  String get suspiciousEngagementDetected => 'Interacción sospechosa detectada';

  @override
  String get patternReviewRequired => 'Solicitud de análisis del patrón';

  @override
  String get adminInsightsFooter =>
      'Vista admin — las mismas estadísticas que ve el autor, además de los avisos de moderación. Solo datos agregados; no se expone la identidad individual de ningún visitante.';

  @override
  String get viewerKindBusiness => 'Empresa';

  @override
  String get viewerKindCandidate => 'Candidato';

  @override
  String get viewerKindRecruiter => 'Reclutador';

  @override
  String get viewerKindHiringManager => 'Responsable de contratación';

  @override
  String get viewerKindBusinessesPlural => 'Empresas';

  @override
  String get viewerKindCandidatesPlural => 'Candidatos';

  @override
  String get viewerKindRecruitersPlural => 'Reclutadores';

  @override
  String get viewerKindHiringManagersPlural => 'Responsables de contratación';

  @override
  String get searchPeoplePostsVenuesHint => 'Buscar persone, post, locales…';

  @override
  String get searchCommunityTitle => 'Buscar en la community';

  @override
  String get roleSommelier => 'Sommelier';

  @override
  String get candidatePremiumActivated => 'Ahora eres Candidate Premium';

  @override
  String get purchasesRestoredPremium =>
      'Compras restauradas — ahora eres Candidate Premium';

  @override
  String get nothingToRestore => 'Niente desde ripristinare';

  @override
  String get noValidSubscriptionPremiumRemoved =>
      'No se encontró una suscripción válida — se ha quitado el acceso Premium';

  @override
  String restoreFailedWithError(String error) {
    return 'Restauración fallida. $error';
  }

  @override
  String get subscriptionTitleAnnual => 'Candidate Premium · Anual';

  @override
  String get subscriptionTitleMonthly => 'Candidate Premium · Mensual';

  @override
  String pricePerYearSlash(String price) {
    return '$price / año';
  }

  @override
  String pricePerMonthSlash(String price) {
    return '$price / mes';
  }

  @override
  String get nearbyJobsTitle => 'Trabajos vicini';

  @override
  String get expandRadius => 'Amplia radio';

  @override
  String get noJobsInRadius => 'Nessun trabajo in este radio';

  @override
  String jobsWithinRadius(int count, int radius) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trabajos en $radius millas',
      one: '1 trabajo en $radius millas',
    );
    return '$_temp0';
  }

  @override
  String get interviewAcceptedSnack => '¡Entrevista aceptada!';

  @override
  String get declineInterviewTitle => 'Rechazar entrevista';

  @override
  String get declineInterviewConfirm =>
      '¿Seguro que quieres rechazar esta entrevista?';

  @override
  String get addedToCalendar => 'Aggiunto al calendario';

  @override
  String get removeCompanyTitle => 'Rimuovere?';

  @override
  String get removeCompanyConfirm =>
      '¿Seguro que quieres eliminar esta empresa de la lista de guardados?';

  @override
  String get signOutAllRolesConfirm =>
      '¿Seguro que quieres cerrar sesión de todos los roles?';

  @override
  String get tapToViewAllConversations =>
      'Toca para ver todas las conversaciones';

  @override
  String get savedJobsTitle => 'Trabajos guardados';

  @override
  String savedJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trabajos guardados',
      one: '1 trabajo guardado',
    );
    return '$_temp0';
  }

  @override
  String get removeFromSavedTitle => '¿Quitar de guardados?';

  @override
  String get removeFromSavedConfirm =>
      'Este trabajo se eliminará de la lista de guardados.';

  @override
  String get noSavedJobsSubtitle =>
      'Explora los trabajos y guarda los que te interesen';

  @override
  String get browseJobsAction => 'Explorar trabajos';

  @override
  String matchingJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trabajos compatibles',
      one: '1 trabajo compatible',
    );
    return '$_temp0';
  }

  @override
  String get savedPostsTitle => 'Publicaciones guardadas';

  @override
  String get searchSavedPostsHint =>
      'Buscar entre las publicaciones guardadas…';

  @override
  String get skipAction => 'Omitir';

  @override
  String get submitAction => 'Enviar';

  @override
  String get doneAction => 'Hecho';

  @override
  String get resetYourPasswordTitle => 'Restablece tu contraseña';

  @override
  String get enterEmailForResetCode =>
      'Introduce tu email para recibir un código';

  @override
  String get sendResetCode => 'Enviar código';

  @override
  String get enterResetCode => 'Introduce el código';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get passwordResetComplete => 'Contraseña restablecida';

  @override
  String get backToSignIn => 'Volver a iniciar sesión';

  @override
  String get passwordChanged => 'Contraseña cambiada';

  @override
  String get passwordUpdatedShort =>
      'Tu contraseña se ha actualizado correctamente.';

  @override
  String get passwordUpdatedRelogin =>
      'Tu contraseña se ha actualizado. Inicia sesión de nuevo con tu nueva contraseña.';

  @override
  String get updatePassword => 'Actualizar contraseña';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get passwordRequirements => 'Requisitos de contraseña';

  @override
  String get newPasswordHint => 'Nueva contraseña (mín 8 caracteres)';

  @override
  String get confirmPasswordField => 'Confirmar contraseña';

  @override
  String get enterEmailField => 'Introduce el email';

  @override
  String get enterPasswordField => 'Introduce la contraseña';

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get selectHowToUse => 'Elige cómo quieres usar Plagit hoy';

  @override
  String get continueAsCandidate => 'Continuar como candidato';

  @override
  String get continueAsBusiness => 'Continuar como empresa';

  @override
  String get signInToPlagit => 'Inicia sesión en Plagit';

  @override
  String get enterCredentials => 'Introduce tus credenciales para continuar';

  @override
  String get adminPortal => 'Portal de administración';

  @override
  String get plagitAdmin => 'Plagit Admin';

  @override
  String get signInToAdminAccount => 'Inicia sesión en tu cuenta admin';

  @override
  String get admin => 'Admin';

  @override
  String get searchJobsRolesRestaurantsHint =>
      'Busca empleos, roles, restaurantes...';

  @override
  String get exploreNearbyJobs => 'Explora empleos cercanos';

  @override
  String get findOpportunitiesOnMap => 'Encuentra oportunidades en el mapa';

  @override
  String get featuredJobs => 'Empleos destacados';

  @override
  String get jobsNearYou => 'Empleos cerca de ti';

  @override
  String get jobsMatchingRoleType => 'Empleos que encajan con tu rol y tipo';

  @override
  String get availableNow => 'Disponible ahora';

  @override
  String get noNearbyJobsYet => 'Aún no hay empleos cerca';

  @override
  String get tryIncreasingRadius =>
      'Prueba ampliando el radio o cambiando filtros';

  @override
  String get checkBackForOpportunities =>
      'Vuelve pronto para nuevas oportunidades';

  @override
  String get noNotifications => 'Sin notificaciones';

  @override
  String get okAction => 'OK';

  @override
  String get onlineNow => 'En línea ahora';

  @override
  String get businessUpper => 'EMPRESA';

  @override
  String get waitingForBusinessFirstMessage =>
      'Esperando a que la empresa envíe el primer mensaje';

  @override
  String get whenEmployersMessageYou =>
      'Cuando los empleadores te escriban, aparecerán aquí.';

  @override
  String get replyToCandidate => 'Responder al candidato…';

  @override
  String get quickFeedback => 'Feedback rápido';

  @override
  String get helpImproveMatches => 'Ayúdanos a mejorar tus matches';

  @override
  String get thanksForFeedback => '¡Gracias por tu feedback!';

  @override
  String get accountSettings => 'Ajustes de cuenta';

  @override
  String get notificationSettings => 'Ajustes de notificaciones';

  @override
  String get privacyAndSecurity => 'Privacidad y seguridad';

  @override
  String get helpAndSupport => 'Ayuda y soporte';

  @override
  String get activeRoleUpper => 'ROL ACTIVO';

  @override
  String get meetingLink => 'Enlace de reunión';

  @override
  String get joinMeeting2 => 'Unirse a la reunión';

  @override
  String get notes => 'Notas';

  @override
  String get completeBusinessProfileTitle => 'Completa tu perfil de empresa';

  @override
  String get businessDescription => 'Descripción de empresa';

  @override
  String get finishSetupAction => 'Finalizar configuración';

  @override
  String get describeBusinessHintLong =>
      'Describe tu empresa, cultura y qué la hace un gran lugar para trabajar... (mín 150 caracteres sugeridos)';

  @override
  String get describeBusinessHintShort => 'Describe tu empresa...';

  @override
  String get writeShortIntroAboutYourself =>
      'Escribe una breve presentación sobre ti...';

  @override
  String get createBusinessAccountTitle => 'Crear cuenta de empresa';

  @override
  String get businessDetailsSection => 'Detalles de empresa';

  @override
  String get openToInternationalCandidates =>
      'Abierto a candidatos internacionales';

  @override
  String get createAccountShort => 'Crear cuenta';

  @override
  String get yourDetailsSection => 'Tus datos';

  @override
  String get jobTypeField => 'Tipo de empleo';

  @override
  String get communityFeed => 'Feed de comunidad';

  @override
  String get postPublished => 'Publicación publicada';

  @override
  String get postHidden => 'Publicación oculta';

  @override
  String get postReportedReview =>
      'Publicación reportada — el admin la revisará';

  @override
  String get postNotFound => 'Publicación no encontrada';

  @override
  String get goBack => 'Volver';

  @override
  String get linkCopied => 'Enlace copiado';

  @override
  String get removedFromSaved => 'Eliminado de guardados';

  @override
  String get noPostsFound => 'No se encontraron publicaciones';

  @override
  String get tipsStoriesAdvice =>
      'Consejos, historias y experiencia de profesionales';

  @override
  String get searchTalentPostsRolesHint =>
      'Busca talento, publicaciones, roles…';

  @override
  String get videoAttachmentsComingSoon => 'Adjuntos de video próximamente';

  @override
  String get locationTaggingComingSoon =>
      'Etiquetado de ubicación próximamente';

  @override
  String get fullImageViewerComingSoon => 'Visor de imágenes próximamente';

  @override
  String get shareComingSoon => 'Compartir próximamente';

  @override
  String get findServices => 'Buscar servicios';

  @override
  String get findHospitalityServices => 'Buscar servicios de hospitalidad';

  @override
  String get browseServices => 'Explorar servicios';

  @override
  String get searchServicesCompaniesLocationsHint =>
      'Busca servicios, empresas, ubicaciones...';

  @override
  String get searchCompaniesServicesLocationsHint =>
      'Busca empresas, servicios, ubicaciones...';

  @override
  String get nearbyCompanies => 'Empresas cercanas';

  @override
  String get nearYou => 'Cerca de ti';

  @override
  String get listLabel => 'Lista';

  @override
  String get mapViewLabel => 'Vista de mapa';

  @override
  String get noServicesFound => 'No se encontraron servicios';

  @override
  String get noCompaniesFoundNearby => 'No hay empresas cerca';

  @override
  String get noSavedCompanies => 'Sin empresas guardadas';

  @override
  String get savedCompaniesTitle => 'Empresas guardadas';

  @override
  String get saveCompaniesForLater =>
      'Guarda empresas para encontrarlas fácilmente luego';

  @override
  String get latestUpdates => 'Últimas actualizaciones';

  @override
  String get noPromotions => 'Sin promociones';

  @override
  String get companyHasNoPromotions =>
      'Esta empresa no tiene promociones activas.';

  @override
  String get companyHasNoUpdates =>
      'Esta empresa no ha publicado actualizaciones.';

  @override
  String get promotionsAndOffers => 'Promociones y ofertas';

  @override
  String get promotionNotFound => 'Promoción no encontrada';

  @override
  String get promotionDetails => 'Detalles de promoción';

  @override
  String get termsAndConditions => 'Términos y condiciones';

  @override
  String get relatedPosts => 'Publicaciones relacionadas';

  @override
  String get viewOffer => 'Ver oferta';

  @override
  String get offerBadge => 'OFERTA';

  @override
  String get requestQuote => 'Solicitar presupuesto';

  @override
  String get sendRequest => 'Enviar solicitud';

  @override
  String get quoteRequestSent => '¡Solicitud enviada!';

  @override
  String get inquiry => 'Consulta';

  @override
  String get dateNeeded => 'Fecha requerida';

  @override
  String get serviceType => 'Tipo de servicio';

  @override
  String get serviceArea => 'Área de servicio';

  @override
  String get servicesOffered => 'Servicios ofrecidos';

  @override
  String get servicesLabel => 'Servicios';

  @override
  String get servicePlans => 'Planes de servicio';

  @override
  String get growYourServiceBusiness => 'Haz crecer tu negocio de servicios';

  @override
  String get getDiscoveredPremium =>
      'Llega a más clientes con un anuncio premium.';

  @override
  String get unlockPremium => 'Desbloquea Premium';

  @override
  String get getMoreVisibility => 'Obtén más visibilidad y mejores matches';

  @override
  String get plagitPremiumUpper => 'PLAGIT PREMIUM';

  @override
  String get premiumOnly => 'Solo Premium';

  @override
  String get savePercent17 => 'Ahorra 17%';

  @override
  String get registerBusinessCta => 'Registrar empresa';

  @override
  String get registrationSubmitted => 'Registro enviado';

  @override
  String get serviceDescription => 'Descripción del servicio';

  @override
  String get describeServicesHint =>
      'Describe tus servicios, experiencia y lo que te distingue...';

  @override
  String get websiteOptional => 'Sitio web (opcional)';

  @override
  String get viewCompanyProfileCta => 'Ver perfil de empresa';

  @override
  String get contactCompany => 'Contactar empresa';

  @override
  String get aboutUs => 'Sobre nosotros';

  @override
  String get address => 'Dirección';

  @override
  String get city => 'Ciudad';

  @override
  String get yourLocation => 'Tu ubicación';

  @override
  String get enterYourCity => 'Introduce tu ciudad';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get tryDifferentSearchTerm => 'Prueba con otro término';

  @override
  String get tryDifferentOrAdjust =>
      'Prueba otra búsqueda, categoría o filtros.';

  @override
  String get noPostsYetCompany => 'Aún no hay publicaciones';

  @override
  String requestQuoteFromCompany(String companyName) {
    return 'Solicitar presupuesto a $companyName';
  }

  @override
  String validUntilDate(String validUntil) {
    return 'Válido hasta $validUntil';
  }

  @override
  String get employerCheckingProfile =>
      'Un empleador está revisando tu perfil ahora';

  @override
  String profileStrengthPercent(int percent) {
    return 'Tu perfil está completo al $percent%';
  }

  @override
  String get profileGetsMoreViews => 'Un perfil completo recibe 3× más visitas';

  @override
  String get applicationUpdate => 'Actualización de candidatura';

  @override
  String get findJobsAndApply => 'Encuentra empleos y postúlate';

  @override
  String get manageJobsAndHiring => 'Gestionar empleos y contratación';

  @override
  String get managePlatform => 'Gestionar plataforma';

  @override
  String get findHospitalityCompanies => 'Encuentra empresas de hostelería';

  @override
  String get candidateMessages => 'MENSAJES DE CANDIDATOS';

  @override
  String get businessMessages => 'MENSAJES DE EMPRESAS';

  @override
  String get serviceInquiries => 'CONSULTAS DE SERVICIO';

  @override
  String get acceptInterview => 'Aceptar entrevista';

  @override
  String get adminMenuDashboard => 'Panel';

  @override
  String get adminMenuUsers => 'Usuarios';

  @override
  String get adminMenuCandidates => 'Candidatos';

  @override
  String get adminMenuBusinesses => 'Empresas';

  @override
  String get adminMenuJobs => 'Empleos';

  @override
  String get adminMenuApplications => 'Solicitudes';

  @override
  String get adminMenuBookings => 'Reservas';

  @override
  String get adminMenuPayments => 'Pagos';

  @override
  String get adminMenuMessages => 'Mensajes';

  @override
  String get adminMenuNotifications => 'Notificaciones';

  @override
  String get adminMenuReports => 'Informes';

  @override
  String get adminMenuAnalytics => 'Analítica';

  @override
  String get adminMenuSettings => 'Ajustes';

  @override
  String get adminMenuSupport => 'Soporte';

  @override
  String get adminMenuModeration => 'Moderación';

  @override
  String get adminMenuRoles => 'Roles';

  @override
  String get adminMenuInvoices => 'Facturas';

  @override
  String get adminMenuLogs => 'Registros';

  @override
  String get adminMenuIntegrations => 'Integraciones';

  @override
  String get adminMenuLogout => 'Cerrar sesión';

  @override
  String get adminActionApprove => 'Aprobar';

  @override
  String get adminActionReject => 'Rechazar';

  @override
  String get adminActionSuspend => 'Suspender';

  @override
  String get adminActionActivate => 'Activar';

  @override
  String get adminActionDelete => 'Eliminar';

  @override
  String get adminActionExport => 'Exportar';

  @override
  String get adminSectionOverview => 'Resumen';

  @override
  String get adminSectionManagement => 'Gestión';

  @override
  String get adminSectionFinance => 'Finanzas';

  @override
  String get adminSectionOperations => 'Operaciones';

  @override
  String get adminSectionSystem => 'Sistema';

  @override
  String get adminStatTotalUsers => 'Usuarios totales';

  @override
  String get adminStatActiveJobs => 'Empleos activos';

  @override
  String get adminStatPendingApprovals => 'Aprobaciones pendientes';

  @override
  String get adminStatRevenue => 'Ingresos';

  @override
  String get adminStatBookingsToday => 'Reservas hoy';

  @override
  String get adminStatNewSignups => 'Nuevos registros';

  @override
  String get adminStatConversionRate => 'Tasa de conversión';

  @override
  String get adminMiscWelcome => 'Bienvenido de nuevo';

  @override
  String get adminMiscLoading => 'Cargando…';

  @override
  String get adminMiscNoData => 'Sin datos disponibles';

  @override
  String get adminMiscSearchPlaceholder => 'Buscar…';

  @override
  String get adminMenuContent => 'Contenido';

  @override
  String get adminMenuMore => 'Más';

  @override
  String get adminMenuVerifications => 'Verificaciones';

  @override
  String get adminMenuSubscriptions => 'Suscripciones';

  @override
  String get adminMenuCommunity => 'Comunidad';

  @override
  String get adminMenuInterviews => 'Entrevistas';

  @override
  String get adminMenuMatches => 'Coincidencias';

  @override
  String get adminMenuFeaturedContent => 'Contenido destacado';

  @override
  String get adminMenuAuditLog => 'Registro de auditoría';

  @override
  String get adminMenuChangePassword => 'Cambiar contraseña';

  @override
  String get adminSectionPeople => 'Personas';

  @override
  String get adminSectionHiring => 'Operaciones de contratación';

  @override
  String get adminSectionContentComm => 'Contenido y comunicación';

  @override
  String get adminSectionRevenue => 'Negocio e ingresos';

  @override
  String get adminSectionToolsContent => 'Herramientas y contenido';

  @override
  String get adminSectionQuickActions => 'Acciones rápidas';

  @override
  String get adminSectionNeedsAttention => 'Requiere atención';

  @override
  String get adminStatActiveBusinesses => 'Empresas activas';

  @override
  String get adminStatApplicationsToday => 'Solicitudes hoy';

  @override
  String get adminStatInterviewsToday => 'Entrevistas hoy';

  @override
  String get adminStatFlaggedContent => 'Contenido marcado';

  @override
  String get adminStatActiveSubs => 'Subs activas';

  @override
  String get adminActionFlagged => 'Marcados';

  @override
  String get adminActionFeatured => 'Destacado';

  @override
  String get adminActionReviewFlagged => 'Revisar contenido marcado';

  @override
  String get adminActionTodayInterviews => 'Entrevistas de hoy';

  @override
  String get adminActionOpenReports => 'Reportes abiertos';

  @override
  String get adminActionManageSubscriptions => 'Gestionar suscripciones';

  @override
  String get adminActionAnalyticsDashboard => 'Panel de analítica';

  @override
  String get adminActionSendNotification => 'Enviar notificación';

  @override
  String get adminActionCreateCommunityPost => 'Crear publicación de comunidad';

  @override
  String get adminActionRetry => 'Reintentar';

  @override
  String get adminMiscGreetingMorning => 'Buenos días';

  @override
  String get adminMiscGreetingAfternoon => 'Buenas tardes';

  @override
  String get adminMiscGreetingEvening => 'Buenas noches';

  @override
  String get adminMiscAllClear => 'Todo bien — nada requiere atención.';

  @override
  String get adminSubtitleAllUsers => 'Todos los usuarios';

  @override
  String get adminSubtitleCandidates => 'Perfiles de candidatos';

  @override
  String get adminSubtitleBusinesses => 'Cuentas de empresas';

  @override
  String get adminSubtitleJobs => 'Ofertas activas';

  @override
  String get adminSubtitleApplications => 'Solicitudes enviadas';

  @override
  String get adminSubtitleInterviews => 'Entrevistas programadas';

  @override
  String get adminSubtitleMatches => 'Coincidencias de rol y tipo';

  @override
  String get adminSubtitleVerifications => 'Revisar verificaciones pendientes';

  @override
  String get adminSubtitleReports => 'Reportes y moderación';

  @override
  String get adminSubtitleSupport => 'Tickets de soporte abiertos';

  @override
  String get adminSubtitleMessages => 'Conversaciones de usuarios';

  @override
  String get adminSubtitleNotifications => 'Alertas push e in-app';

  @override
  String get adminSubtitleCommunity => 'Publicaciones y discusiones';

  @override
  String get adminSubtitleFeaturedContent => 'Contenido destacado';

  @override
  String get adminSubtitleSubscriptions => 'Planes y facturación';

  @override
  String get adminSubtitleAuditLog => 'Registros de actividad admin';

  @override
  String get adminSubtitleAnalytics => 'Métricas de la plataforma';

  @override
  String get adminSubtitleSettings => 'Configuración de la plataforma';

  @override
  String get adminSubtitleUsersPage => 'Gestiona cuentas de la plataforma';

  @override
  String get adminSubtitleContentPage => 'Ofertas, solicitudes y entrevistas';

  @override
  String get adminSubtitleModerationPage =>
      'Verificaciones, reportes y soporte';

  @override
  String get adminSubtitleMorePage => 'Ajustes, analíticas y cuenta';

  @override
  String get adminSubtitleAnalyticsHero =>
      'KPIs, tendencias y salud de la plataforma';

  @override
  String get adminBadgeUrgent => 'Urgente';

  @override
  String get adminBadgeReview => 'Revisar';

  @override
  String get adminBadgeAction => 'Acción';

  @override
  String get adminMenuAllUsers => 'Todos los usuarios';

  @override
  String get adminMiscSuperAdmin => 'Super Admin';

  @override
  String adminBadgeNToday(int count) {
    return '$count hoy';
  }

  @override
  String adminBadgeNOpen(int count) {
    return '$count abiertos';
  }

  @override
  String adminBadgeNActive(int count) {
    return '$count activos';
  }

  @override
  String adminBadgeNUnread(int count) {
    return '$count sin leer';
  }

  @override
  String adminBadgeNPending(int count) {
    return '$count pendientes';
  }

  @override
  String adminBadgeNPosts(int count) {
    return '$count publicaciones';
  }

  @override
  String adminBadgeNFeatured(int count) {
    return '$count destacados';
  }

  @override
  String get adminStatusActive => 'Activo';

  @override
  String get adminStatusPaused => 'Pausado';

  @override
  String get adminStatusClosed => 'Cerrado';

  @override
  String get adminStatusDraft => 'Borrador';

  @override
  String get adminStatusFlagged => 'Marcado';

  @override
  String get adminStatusSuspended => 'Suspendido';

  @override
  String get adminStatusPending => 'Pendiente';

  @override
  String get adminStatusConfirmed => 'Confirmado';

  @override
  String get adminStatusCompleted => 'Completado';

  @override
  String get adminStatusCancelled => 'Cancelado';

  @override
  String get adminStatusAccepted => 'Aceptado';

  @override
  String get adminStatusDenied => 'Denegado';

  @override
  String get adminStatusExpired => 'Expirado';

  @override
  String get adminStatusResolved => 'Resuelto';

  @override
  String get adminStatusScheduled => 'Programado';

  @override
  String get adminStatusBanned => 'Bloqueado';

  @override
  String get adminStatusVerified => 'Verificado';

  @override
  String get adminStatusFailed => 'Fallido';

  @override
  String get adminStatusSuccess => 'Éxito';

  @override
  String get adminStatusDelivered => 'Entregado';

  @override
  String get adminFilterAll => 'Todos';

  @override
  String get adminFilterToday => 'Hoy';

  @override
  String get adminFilterUnread => 'No leídos';

  @override
  String get adminFilterRead => 'Leídos';

  @override
  String get adminFilterCandidates => 'Candidatos';

  @override
  String get adminFilterBusinesses => 'Empresas';

  @override
  String get adminFilterAdmins => 'Admins';

  @override
  String get adminFilterCandidate => 'Candidato';

  @override
  String get adminFilterBusiness => 'Empresa';

  @override
  String get adminFilterSystem => 'Sistema';

  @override
  String get adminFilterPinned => 'Fijados';

  @override
  String get adminFilterEmployers => 'Empleadores';

  @override
  String get adminFilterBanners => 'Banners';

  @override
  String get adminFilterBilling => 'Facturación';

  @override
  String get adminFilterFeaturedEmployer => 'Empleador destacado';

  @override
  String get adminFilterFeaturedJob => 'Trabajo destacado';

  @override
  String get adminFilterHomeBanner => 'Banner Home';

  @override
  String get adminEmptyAdjustFilters => 'Intenta ajustar los filtros.';

  @override
  String get adminEmptyJobsTitle => 'Sin trabajos';

  @override
  String get adminEmptyJobsSub => 'Ningún trabajo coincide.';

  @override
  String get adminEmptyUsersTitle => 'Sin usuarios';

  @override
  String get adminEmptyMessagesTitle => 'Sin mensajes';

  @override
  String get adminEmptyMessagesSub => 'No hay conversaciones para mostrar.';

  @override
  String get adminEmptyReportsTitle => 'Sin reportes';

  @override
  String get adminEmptyReportsSub => 'No hay reportes para revisar.';

  @override
  String get adminEmptyBusinessesTitle => 'Sin empresas';

  @override
  String get adminEmptyBusinessesSub => 'Ninguna empresa coincide.';

  @override
  String get adminEmptyNotifsTitle => 'Sin notificaciones';

  @override
  String get adminEmptySubsTitle => 'Sin suscripciones';

  @override
  String get adminEmptySubsSub => 'Ninguna suscripción coincide.';

  @override
  String get adminEmptyLogsTitle => 'Sin registros';

  @override
  String get adminEmptyContentTitle => 'Sin contenido';

  @override
  String get adminEmptyInterviewsTitle => 'Sin entrevistas';

  @override
  String get adminEmptyInterviewsSub => 'Ninguna entrevista coincide.';

  @override
  String get adminEmptyFeedback => 'Los comentarios aparecerán aquí';

  @override
  String get adminEmptyMatchNotifs =>
      'Las notificaciones de match aparecerán aquí';

  @override
  String get adminTitleMatchManagement => 'Gestión de matches';

  @override
  String get adminTitleAdminLogs => 'Registros admin';

  @override
  String get adminTitleContentFeatured => 'Contenido / Destacado';

  @override
  String get adminTabFeedback => 'Comentarios';

  @override
  String get adminTabStats => 'Estadísticas';

  @override
  String get adminSortNewest => 'Más recientes';

  @override
  String get adminSortPriority => 'Prioridad';

  @override
  String get adminStatTotalMatches => 'Total de matches';

  @override
  String get adminStatAccepted => 'Aceptados';

  @override
  String get adminStatDenied => 'Denegados';

  @override
  String get adminStatFeedbackCount => 'Comentarios';

  @override
  String get adminStatMatchQuality => 'Puntuación de calidad de match';

  @override
  String get adminStatTotal => 'Total';

  @override
  String get adminStatPendingCount => 'Pendientes';

  @override
  String get adminStatNotificationsCount => 'Notificaciones';

  @override
  String get adminStatActiveCount => 'Activos';

  @override
  String get adminSectionPlatformSettings => 'Ajustes de plataforma';

  @override
  String get adminSectionNotificationSettings => 'Ajustes de notificaciones';

  @override
  String get adminSettingMaintenanceTitle => 'Modo mantenimiento';

  @override
  String get adminSettingMaintenanceSub =>
      'Deshabilitar acceso a todos los usuarios';

  @override
  String get adminSettingNewRegsTitle => 'Nuevos registros';

  @override
  String get adminSettingNewRegsSub => 'Permitir nuevos registros';

  @override
  String get adminSettingFeaturedJobsTitle => 'Trabajos destacados';

  @override
  String get adminSettingFeaturedJobsSub =>
      'Mostrar trabajos destacados en inicio';

  @override
  String get adminSettingEmailNotifsTitle => 'Notificaciones email';

  @override
  String get adminSettingEmailNotifsSub => 'Enviar alertas por email';

  @override
  String get adminSettingPushNotifsTitle => 'Notificaciones push';

  @override
  String get adminSettingPushNotifsSub => 'Enviar notificaciones push';

  @override
  String get adminActionSaveChanges => 'Guardar cambios';

  @override
  String get adminToastSettingsSaved => 'Ajustes guardados';

  @override
  String get adminActionResolve => 'Resolver';

  @override
  String get adminActionDismiss => 'Descartar';

  @override
  String get adminActionBanUser => 'Banear usuario';

  @override
  String get adminSearchUsersHint => 'Buscar nombre, email, rol, ubicación...';

  @override
  String get adminMiscPositive => 'positivo';

  @override
  String adminCountUsers(int count) {
    return '$count usuarios';
  }

  @override
  String adminCountNotifs(int count) {
    return '$count notificaciones';
  }

  @override
  String adminCountLogs(int count) {
    return '$count entradas de log';
  }

  @override
  String adminCountItems(int count) {
    return '$count elementos';
  }

  @override
  String adminBadgeNRetried(int count) {
    return 'Reintentado x$count';
  }

  @override
  String get adminStatusApplied => 'Postulado';

  @override
  String get adminStatusUnderReview => 'En revisión';

  @override
  String get adminStatusShortlisted => 'Preseleccionado';

  @override
  String get adminStatusInterview => 'Entrevista';

  @override
  String get adminStatusHired => 'Contratado';

  @override
  String get adminStatusRejected => 'Rechazado';

  @override
  String get adminStatusOpen => 'Abierto';

  @override
  String get adminStatusInReview => 'En revisión';

  @override
  String get adminStatusWaiting => 'Esperando';

  @override
  String get adminPriorityHigh => 'Alta';

  @override
  String get adminPriorityMedium => 'Media';

  @override
  String get adminPriorityLow => 'Baja';

  @override
  String get adminActionViewProfile => 'Ver perfil';

  @override
  String get adminActionVerify => 'Verificar';

  @override
  String get adminActionReview => 'Revisar';

  @override
  String get adminActionOverride => 'Anular';

  @override
  String get adminEmptyCandidatesTitle => 'Sin candidatos';

  @override
  String get adminEmptyApplicationsTitle => 'Sin solicitudes';

  @override
  String get adminEmptyVerificationsTitle => 'Sin verificaciones pendientes';

  @override
  String get adminEmptyIssuesTitle => 'Sin incidencias';

  @override
  String get adminEmptyAuditTitle => 'Sin registros de auditoría';

  @override
  String get adminSearchCandidatesTitle => 'Buscar candidatos';

  @override
  String get adminSearchCandidatesHint => 'Buscar por nombre, email o rol…';

  @override
  String get adminSearchAuditHint => 'Buscar en el registro…';

  @override
  String get adminMiscUnknown => 'Desconocido';

  @override
  String adminCountTotal(int count) {
    return '$count total';
  }

  @override
  String adminBadgeNFlagged(int count) {
    return '$count marcados';
  }

  @override
  String adminBadgeNDaysWaiting(int count) {
    return '$count días en espera';
  }

  @override
  String get adminPeriodWeek => 'Semana';

  @override
  String get adminPeriodMonth => 'Mes';

  @override
  String get adminPeriodYear => 'Año';

  @override
  String get adminKpiNewCandidates => 'Nuevos candidatos';

  @override
  String get adminKpiNewBusinesses => 'Nuevas empresas';

  @override
  String get adminKpiJobsPosted => 'Empleos publicados';

  @override
  String get adminSectionApplicationFunnel => 'Embudo de solicitudes';

  @override
  String get adminSectionPlatformGrowth => 'Crecimiento de la plataforma';

  @override
  String get adminSectionPremiumConversion => 'Conversión premium';

  @override
  String get adminSectionTopLocations => 'Ubicaciones principales';

  @override
  String get adminStatusViewed => 'Visto';

  @override
  String get adminWeekdayMon => 'Lun';

  @override
  String get adminWeekdayTue => 'Mar';

  @override
  String get adminWeekdayWed => 'Mié';

  @override
  String get adminWeekdayThu => 'Jue';

  @override
  String get adminWeekdayFri => 'Vie';

  @override
  String get adminWeekdaySat => 'Sáb';

  @override
  String get adminWeekdaySun => 'Dom';

  @override
  String get adminFilterReported => 'Reportados';

  @override
  String get adminFilterHidden => 'Ocultos';

  @override
  String get adminEmptyPostsTitle => 'Sin publicaciones';

  @override
  String get adminEmptyContentFilter =>
      'Ningún contenido coincide con este filtro.';

  @override
  String get adminBannerReportedReview => 'REPORTADO — REVISIÓN REQUERIDA';

  @override
  String get adminBannerHiddenFromFeed => 'OCULTO DEL FEED';

  @override
  String get adminActionInsights => 'Estadísticas';

  @override
  String get adminActionHide => 'Ocultar';

  @override
  String get adminActionRemove => 'Eliminar';

  @override
  String get adminActionCancel => 'Cancelar';

  @override
  String get adminDialogRemovePostTitle => '¿Eliminar publicación?';

  @override
  String get adminDialogRemovePostBody =>
      'Esto elimina permanentemente la publicación y sus comentarios. Esta acción no se puede deshacer.';

  @override
  String get adminSnackbarReportCleared => 'Reporte eliminado';

  @override
  String get adminSnackbarPostHidden => 'Publicación oculta del feed';

  @override
  String get adminSnackbarPostRemoved => 'Publicación eliminada';

  @override
  String adminCountReported(int count) {
    return '$count reportados';
  }

  @override
  String adminCountHidden(int count) {
    return '$count ocultos';
  }

  @override
  String adminMiscPremiumOutOfTotal(int premium, int total) {
    return '$premium premium de $total en total';
  }

  @override
  String get adminActionUnverify => 'Anular verificación';

  @override
  String get adminActionReactivate => 'Reactivar';

  @override
  String get adminActionFeature => 'Destacar';

  @override
  String get adminActionUnfeature => 'Quitar destacado';

  @override
  String get adminActionFlagAccount => 'Marcar cuenta';

  @override
  String get adminActionUnflagAccount => 'Desmarcar cuenta';

  @override
  String get adminActionConfirm => 'Confirmar';

  @override
  String get adminDialogVerifyBusinessTitle => 'Verificar empresa';

  @override
  String get adminDialogUnverifyBusinessTitle =>
      'Anular verificación de empresa';

  @override
  String get adminDialogSuspendBusinessTitle => 'Suspender empresa';

  @override
  String get adminDialogReactivateBusinessTitle => 'Reactivar empresa';

  @override
  String get adminDialogVerifyCandidateTitle => 'Verificar candidato';

  @override
  String get adminDialogSuspendCandidateTitle => 'Suspender candidato';

  @override
  String get adminDialogReactivateCandidateTitle => 'Reactivar candidato';

  @override
  String get adminSnackbarBusinessVerified => 'Empresa verificada';

  @override
  String get adminSnackbarVerificationRemoved => 'Verificación eliminada';

  @override
  String get adminSnackbarBusinessSuspended => 'Empresa suspendida';

  @override
  String get adminSnackbarBusinessReactivated => 'Empresa reactivada';

  @override
  String get adminSnackbarBusinessFeatured => 'Empresa destacada';

  @override
  String get adminSnackbarBusinessUnfeatured =>
      'Destaque eliminado de la empresa';

  @override
  String get adminSnackbarUserVerified => 'Usuario verificado';

  @override
  String get adminSnackbarUserSuspended => 'Usuario suspendido';

  @override
  String get adminSnackbarUserReactivated => 'Usuario reactivado';

  @override
  String get adminTabProfile => 'Perfil';

  @override
  String get adminTabActivity => 'Actividad';

  @override
  String get adminTabNotes => 'Notas';

  @override
  String adminDialogVerifyBody(String name) {
    return '¿Marcar a $name como verificado?';
  }

  @override
  String adminDialogUnverifyBody(String name) {
    return '¿Eliminar la verificación de $name?';
  }

  @override
  String adminDialogReactivateBody(String name) {
    return '¿Reactivar a $name?';
  }

  @override
  String adminDialogSuspendBusinessBody(String name) {
    return '¿Suspender a $name? Todos los empleos se pausarán.';
  }

  @override
  String adminDialogSuspendCandidateBody(String name) {
    return '¿Suspender a $name? Perderá el acceso.';
  }

  @override
  String get adminFieldName => 'Nombre';

  @override
  String get adminFieldEmail => 'Correo electrónico';

  @override
  String get adminFieldPhone => 'Teléfono';

  @override
  String get adminFieldLocation => 'Ubicación';

  @override
  String get adminFieldPlan => 'Plan';

  @override
  String get adminFieldVerified => 'Verificado';

  @override
  String get adminFieldStatus => 'Estado';

  @override
  String get adminFieldJoined => 'Registrado';

  @override
  String get adminFieldCategory => 'Categoría';

  @override
  String get adminFieldSize => 'Tamaño';

  @override
  String get adminFieldRole => 'Rol';

  @override
  String get adminFieldProfileCompletion => 'Perfil completado';

  @override
  String get adminStatApplicants => 'Candidatos';

  @override
  String get adminStatSaved => 'Guardados';

  @override
  String get adminPlaceholderAddNote => 'Añadir una nota...';

  @override
  String get adminEmptyNoJobsPosted => 'No hay empleos publicados';

  @override
  String get adminSectionSubscriptionDetail => 'Detalle de suscripción';

  @override
  String get adminEmptySubscriptionNotFound => 'Suscripción no encontrada';

  @override
  String get adminSectionPlanDetails => 'Detalles del plan';

  @override
  String get adminFieldPrice => 'Precio';

  @override
  String get adminFieldStartDate => 'Fecha de inicio';

  @override
  String get adminFieldRenewalDate => 'Fecha de renovación';

  @override
  String get adminSectionAdminOverride => 'Anulación admin';

  @override
  String get adminPlanCandidatePremium => 'Candidato Premium';

  @override
  String get adminPlanBusinessPro => 'Business Pro';

  @override
  String get adminPlanBusinessPremium => 'Business Premium';

  @override
  String get adminPlanFree => 'Gratis';

  @override
  String get adminFieldNewRenewalDate => 'Nueva fecha de renovación';

  @override
  String get adminPlaceholderDateExample => 'ej. 15 jun 2026';

  @override
  String get adminFieldReason => 'Motivo';

  @override
  String get adminPlaceholderReasonOverride => 'Motivo de la anulación...';

  @override
  String get adminActionApplyOverride => 'Aplicar anulación';

  @override
  String get adminSectionHistory => 'Historial';

  @override
  String get adminTimelineSubscriptionCreated => 'Suscripción creada';

  @override
  String get adminTimelinePaymentProcessed => 'Pago procesado';

  @override
  String get adminEmptyNoAdminNotes => 'Sin notas de admin.';

  @override
  String get adminSectionAuditDetail => 'Detalle de auditoría';

  @override
  String get adminEmptyEntryNotFound => 'Entrada no encontrada';

  @override
  String get adminFieldAdmin => 'Admin';

  @override
  String get adminFieldAction => 'Acción';

  @override
  String get adminFieldTimestamp => 'Marca de tiempo';

  @override
  String get adminFieldTarget => 'Objetivo';

  @override
  String get adminFieldType => 'Tipo';

  @override
  String get adminSectionChanges => 'Cambios';

  @override
  String get adminFieldIpAddress => 'Dirección IP';

  @override
  String get adminAuditUnverified => 'No verificado';

  @override
  String get adminAuditStandard => 'Estándar';

  @override
  String get adminAuditFeatured => 'Destacado';

  @override
  String get adminAuditPreviousStatus => 'Estado anterior';

  @override
  String get adminAuditOverridden => 'Anulado';

  @override
  String get adminAuditPrevious => 'Anterior';

  @override
  String get adminAuditUpdated => 'Actualizado';
}
