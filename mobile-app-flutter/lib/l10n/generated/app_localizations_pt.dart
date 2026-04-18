// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Plagit';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Criar conta';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get createBusinessAccount => 'Criar conta de empresa';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta?';

  @override
  String get email => 'Endereço de e-mail';

  @override
  String get password => 'Palavra-passe';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get done => 'Concluído';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get search => 'Procurar';

  @override
  String get back => 'Voltar';

  @override
  String get next => 'Seguinte';

  @override
  String get apply => 'Candidatar-se';

  @override
  String get clear => 'Limpar';

  @override
  String get clearAll => 'Limpar tudo';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get home => 'Início';

  @override
  String get jobs => 'Empregos';

  @override
  String get messages => 'Mensagens';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Definições';

  @override
  String get language => 'Idioma';

  @override
  String get logout => 'Terminar sessão';

  @override
  String get categoryAndRole => 'Categoria e função';

  @override
  String get selectCategory => 'Selecionar categoria';

  @override
  String get subcategory => 'Subcategoria';

  @override
  String get role => 'Função';

  @override
  String get recentSearches => 'Pesquisas recentes';

  @override
  String noResultsFor(String query) {
    return 'Sem resultados para «$query»';
  }

  @override
  String get mostPopular => 'Mais populares';

  @override
  String get allCategories => 'Todas as categorias';

  @override
  String get selectVenueTypeAndRole =>
      'Selecionar tipo de estabelecimento e função necessária';

  @override
  String get selectCategoryAndRole => 'Selecionar categoria e função';

  @override
  String get businessDetails => 'Detalhes da empresa';

  @override
  String get yourDetails => 'Os seus dados';

  @override
  String get companyName => 'Nome da empresa';

  @override
  String get contactPerson => 'Pessoa de contacto';

  @override
  String get location => 'Localização';

  @override
  String get website => 'Site';

  @override
  String get fullName => 'Nome completo';

  @override
  String get yearsExperience => 'Anos de experiência';

  @override
  String get languagesSpoken => 'Idiomas falados';

  @override
  String get jobType => 'Tipo de emprego';

  @override
  String get jobTypeFullTime => 'Tempo inteiro';

  @override
  String get jobTypePartTime => 'Tempo parcial';

  @override
  String get jobTypeTemporary => 'Temporário';

  @override
  String get jobTypeFreelance => 'Freelancer';

  @override
  String get openToInternational => 'Aberto a candidatos internacionais';

  @override
  String get passwordHint => 'Palavra-passe (mín. 8 caracteres)';

  @override
  String get termsOfServiceNote =>
      'Ao criar uma conta, aceita os nossos Termos de Serviço e a Política de Privacidade.';

  @override
  String get networkError => 'Erro de rede';

  @override
  String get somethingWentWrong => 'Ocorreu um erro';

  @override
  String get loading => 'A carregar…';

  @override
  String get errorGeneric => 'Ocorreu um erro inesperado. Tente novamente.';

  @override
  String get joinAsCandidate => 'Entrar como Candidato';

  @override
  String get joinAsBusiness => 'Entrar como Empresa';

  @override
  String get findYourNextRole => 'Encontre o seu próximo emprego na hotelaria';

  @override
  String get candidateLoginSubtitle =>
      'Ligue-se aos melhores empregadores em Londres, Dubai e muito mais.';

  @override
  String get businessLoginSubtitle =>
      'Alcance os melhores talentos da hotelaria e expanda a sua equipa.';

  @override
  String get rememberMe => 'Lembrar-me';

  @override
  String get forgotPassword => 'Esqueceu-se da palavra-passe?';

  @override
  String get lookingForStaff => 'À procura de pessoal? ';

  @override
  String get lookingForJob => 'À procura de emprego? ';

  @override
  String get switchToBusiness => 'Mudar para Empresa';

  @override
  String get switchToCandidate => 'Mudar para Candidato';

  @override
  String get createYourProfile =>
      'Crie o seu perfil e seja descoberto pelos melhores empregadores.';

  @override
  String get createBusinessProfile =>
      'Crie o perfil da sua empresa e comece a contratar os melhores talentos da hotelaria.';

  @override
  String get locationCityCountry => 'Localização (cidade, país)';

  @override
  String get termsAgreement =>
      'Ao criar uma conta, aceita os nossos Termos de Serviço e a Política de Privacidade.';

  @override
  String get searchHospitalityHint =>
      'Procurar categoria, subcategoria ou função…';

  @override
  String get mostCommonRoles => 'Funções mais comuns';

  @override
  String get allRoles => 'Todas as funções';

  @override
  String suggestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sugestões',
      one: '1 sugestão',
    );
    return '$_temp0';
  }

  @override
  String subcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategorias',
      one: '1 subcategoria',
    );
    return '$_temp0';
  }

  @override
  String rolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count funções',
      one: '1 função',
    );
    return '$_temp0';
  }

  @override
  String get kindCategory => 'Categoria';

  @override
  String get kindSubcategory => 'Subcategoria';

  @override
  String get kindRole => 'Função';

  @override
  String get resetPassword => 'Redefinir palavra-passe';

  @override
  String get forgotPasswordSubtitle =>
      'Introduza o seu e-mail e enviaremos um link para redefinir a sua palavra-passe.';

  @override
  String get sendResetLink => 'Enviar link';

  @override
  String get resetEmailSent =>
      'Se existir uma conta com esse e-mail, foi enviado um link de redefinição.';

  @override
  String get profileSetupTitle => 'Complete o seu perfil';

  @override
  String get profileSetupSubtitle =>
      'Um perfil completo é descoberto mais rapidamente.';

  @override
  String get uploadPhoto => 'Carregar foto';

  @override
  String get uploadCV => 'Carregar CV';

  @override
  String get skipForNow => 'Ignorar por agora';

  @override
  String get finish => 'Terminar';

  @override
  String get noInternet => 'Sem ligação à Internet. Verifique a sua rede.';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get emptyJobs => 'Ainda não há empregos';

  @override
  String get emptyApplications => 'Ainda não há candidaturas';

  @override
  String get emptyMessages => 'Ainda não há mensagens';

  @override
  String get emptyNotifications => 'Está tudo em dia';

  @override
  String get onboardingRoleTitle => 'Que função procura?';

  @override
  String get onboardingRoleSubtitle => 'Selecione todas as opções aplicáveis';

  @override
  String get onboardingExperienceTitle => 'Quanta experiência tem?';

  @override
  String get onboardingLocationTitle => 'Onde está localizado?';

  @override
  String get onboardingLocationHint =>
      'Introduza a sua cidade ou código postal';

  @override
  String get useMyCurrentLocation => 'Usar a minha localização atual';

  @override
  String get onboardingAvailabilityTitle => 'O que procura?';

  @override
  String get finishSetup => 'Concluir configuração';

  @override
  String get goodMorning => 'Bom dia';

  @override
  String get goodAfternoon => 'Boa tarde';

  @override
  String get goodEvening => 'Boa noite';

  @override
  String get findJobs => 'Encontrar empregos';

  @override
  String get applications => 'Candidaturas';

  @override
  String get community => 'Comunidade';

  @override
  String get recommendedForYou => 'Recomendado para si';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get searchJobsHint => 'Procurar empregos, funções, locais…';

  @override
  String get searchJobs => 'Procurar empregos';

  @override
  String get postedJob => 'Publicado';

  @override
  String get applyNow => 'Candidatar-me';

  @override
  String get applied => 'Candidatura enviada';

  @override
  String get saveJob => 'Guardar';

  @override
  String get saved => 'Guardado';

  @override
  String get jobDescription => 'Descrição do emprego';

  @override
  String get requirements => 'Requisitos';

  @override
  String get benefits => 'Benefícios';

  @override
  String get salary => 'Salário';

  @override
  String get contract => 'Contrato';

  @override
  String get schedule => 'Horário';

  @override
  String get viewCompany => 'Ver empresa';

  @override
  String get interview => 'Entrevista';

  @override
  String get interviews => 'Entrevistas';

  @override
  String get notifications => 'Notificações';

  @override
  String get matches => 'Correspondências';

  @override
  String get quickPlug => 'Quick Plug';

  @override
  String get discover => 'Descobrir';

  @override
  String get shortlist => 'Pré-seleção';

  @override
  String get message => 'Mensagem';

  @override
  String get messageCandidate => 'Mensagem';

  @override
  String get nextInterview => 'Próxima entrevista';

  @override
  String get loadingDashboard => 'A carregar o painel…';

  @override
  String get tryAgainCta => 'Tentar novamente';

  @override
  String get careerDashboard => 'PAINEL DE CARREIRA';

  @override
  String get yourNextInterview => 'A sua próxima entrevista\nestá agendada';

  @override
  String get yourCareerTakingOff => 'A sua carreira\nestá a descolar';

  @override
  String get yourCareerOnTheMove => 'A sua carreira\nestá em movimento';

  @override
  String get yourJourneyStartsHere => 'A sua jornada\ncomeça aqui';

  @override
  String get applyFirstJob =>
      'Candidate-se ao seu primeiro emprego para começar';

  @override
  String get interviewComingUp => 'Entrevista a chegar';

  @override
  String get unlockPlagitPremium => 'Desbloquear Plagit Premium';

  @override
  String get premiumSubtitle =>
      'Destaque-se junto dos melhores estabelecimentos — tenha matches mais rápidos';

  @override
  String get premiumActive => 'Premium Ativo';

  @override
  String get premiumActiveSubtitle =>
      'Visibilidade prioritária ativada · Gerir plano';

  @override
  String get noJobsFound => 'Nenhum emprego corresponde à sua pesquisa';

  @override
  String get noApplicationsYet => 'Ainda não há candidaturas';

  @override
  String get startApplying => 'Comece a explorar empregos para se candidatar';

  @override
  String get noMessagesYet => 'Ainda não há mensagens';

  @override
  String get allCaughtUp => 'Está tudo em dia';

  @override
  String get noNotificationsYet => 'Ainda não há notificações';

  @override
  String get about => 'Sobre';

  @override
  String get experience => 'Experiência';

  @override
  String get skills => 'Competências';

  @override
  String get languages => 'Idiomas';

  @override
  String get availability => 'Disponibilidade';

  @override
  String get verified => 'Verificado';

  @override
  String get totalViews => 'Visualizações totais';

  @override
  String get verifiedVenuePrefix => 'Verificado';

  @override
  String get notVerified => 'Não verificado';

  @override
  String get pendingReview => 'Em análise';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get share => 'Partilhar';

  @override
  String get report => 'Denunciar';

  @override
  String get block => 'Bloquear';

  @override
  String get typeMessage => 'Escreva uma mensagem…';

  @override
  String get send => 'Enviar';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get now => 'agora';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count min',
      one: 'há 1 min',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count h',
      one: 'há 1 h',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count d',
      one: 'há 1 d',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Filtros';

  @override
  String get refineSearch => 'Refinar pesquisa';

  @override
  String get distance => 'Distância';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get reset => 'Repor';

  @override
  String noResultsTitle(String query) {
    return 'Sem resultados para «$query»';
  }

  @override
  String get noResultsSubtitle =>
      'Tente outra palavra-chave ou limpe a pesquisa.';

  @override
  String get recentSearchesEmptyTitle => 'Sem pesquisas recentes';

  @override
  String get recentSearchesEmptyHint =>
      'As suas pesquisas recentes aparecerão aqui';

  @override
  String get allJobs => 'Todos os empregos';

  @override
  String get nearby => 'Perto de si';

  @override
  String get saved2 => 'Guardados';

  @override
  String get remote => 'Remoto';

  @override
  String get inPerson => 'Presencial';

  @override
  String get aboutTheJob => 'Sobre o emprego';

  @override
  String get aboutCompany => 'Sobre a empresa';

  @override
  String get applyForJob => 'Candidatar-me a este emprego';

  @override
  String get unsaveJob => 'Remover';

  @override
  String get noJobsNearby => 'Nenhum emprego por perto';

  @override
  String get noSavedJobs => 'Sem empregos guardados';

  @override
  String get adjustFilters => 'Ajuste os seus filtros para ver mais empregos';

  @override
  String get fullTime => 'Tempo inteiro';

  @override
  String get partTime => 'Tempo parcial';

  @override
  String get temporary => 'Temporário';

  @override
  String get freelance => 'Freelancer';

  @override
  String postedAgo(String time) {
    return 'Publicado $time';
  }

  @override
  String kmAway(String km) {
    return 'a $km km';
  }

  @override
  String get jobDetails => 'Detalhes do emprego';

  @override
  String get aboutThisRole => 'Sobre esta função';

  @override
  String get aboutTheBusiness => 'Sobre a empresa';

  @override
  String get urgentHiring => 'Contratação urgente';

  @override
  String get distanceRadius => 'Raio de distância';

  @override
  String get contractType => 'Tipo de contrato';

  @override
  String get shiftType => 'Tipo de turno';

  @override
  String get all => 'Todos';

  @override
  String get casual => 'Ocasional';

  @override
  String get seasonal => 'Sazonal';

  @override
  String get morning => 'Manhã';

  @override
  String get afternoon => 'Tarde';

  @override
  String get evening => 'Noite';

  @override
  String get night => 'Madrugada';

  @override
  String get startDate => 'Data de início';

  @override
  String get shiftHours => 'Horário do turno';

  @override
  String get category => 'Categoria';

  @override
  String get venueType => 'Tipo de estabelecimento';

  @override
  String get employment => 'Emprego';

  @override
  String get pay => 'Remuneração';

  @override
  String get duration => 'Duração';

  @override
  String get weeklyHours => 'Horas semanais';

  @override
  String get businessLocation => 'Localização da empresa';

  @override
  String get jobViews => 'Visualizações do anúncio';

  @override
  String positions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vagas',
      one: '1 vaga',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mês',
    );
    return '$_temp0';
  }

  @override
  String get myApplications => 'As minhas candidaturas';

  @override
  String get active => 'Ativa';

  @override
  String get interviewStatus => 'Entrevista';

  @override
  String get rejected => 'Rejeitada';

  @override
  String get offer => 'Proposta';

  @override
  String appliedOn(String date) {
    return 'Candidatou-se em $date';
  }

  @override
  String get viewJob => 'Ver anúncio';

  @override
  String get withdraw => 'Retirar candidatura';

  @override
  String get applicationStatus => 'Estado da candidatura';

  @override
  String get noConversations => 'Ainda não há conversas';

  @override
  String get startConversation =>
      'Responda a um anúncio para começar a conversar';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String lastSeen(String time) {
    return 'Visto $time';
  }

  @override
  String get newNotification => 'Novo';

  @override
  String get markAllRead => 'Marcar tudo como lido';

  @override
  String get yourProfile => 'O seu perfil';

  @override
  String completionPercent(int percent) {
    return '$percent% concluído';
  }

  @override
  String get personalDetails => 'Dados pessoais';

  @override
  String get phone => 'Telefone';

  @override
  String get bio => 'Bio';

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get addCV => 'Adicionar CV';

  @override
  String get saveChanges => 'Guardar alterações';

  @override
  String get logoutConfirm => 'Tem a certeza de que pretende terminar sessão?';

  @override
  String get subscription => 'Subscrição';

  @override
  String get support => 'Apoio';

  @override
  String get privacy => 'Privacidade';

  @override
  String get terms => 'Termos';

  @override
  String get applicationDetails => 'Detalhes da candidatura';

  @override
  String get timeline => 'Cronologia';

  @override
  String get submitted => 'Enviada';

  @override
  String get underReview => 'Em análise';

  @override
  String get interviewScheduled => 'Entrevista agendada';

  @override
  String get offerExtended => 'Proposta enviada';

  @override
  String get withdrawApp => 'Retirar candidatura';

  @override
  String get withdrawConfirm =>
      'Tem a certeza de que pretende retirar esta candidatura?';

  @override
  String get applicationWithdrawn => 'Candidatura retirada';

  @override
  String get statusApplied => 'Enviada';

  @override
  String get statusInReview => 'Em análise';

  @override
  String get statusInterview => 'Entrevista';

  @override
  String get statusHired => 'Contratado';

  @override
  String get statusClosed => 'Encerrada';

  @override
  String get statusRejected => 'Rejeitada';

  @override
  String get statusOffer => 'Proposta';

  @override
  String get messagesSearch => 'Procurar mensagens…';

  @override
  String get noMessagesTitle => 'Ainda não há mensagens';

  @override
  String get noMessagesSubtitle =>
      'Responda a um anúncio para começar a conversar';

  @override
  String get youOnline => 'Está online';

  @override
  String get noNotificationsTitle => 'Ainda não há notificações';

  @override
  String get noNotificationsSubtitle => 'Avisamos-lhe assim que algo acontecer';

  @override
  String get today2 => 'Hoje';

  @override
  String get earlier => 'Anteriormente';

  @override
  String get completeYourProfile => 'Complete o seu perfil';

  @override
  String get profileCompletion => 'Conclusão do perfil';

  @override
  String get personalInfo => 'Informações pessoais';

  @override
  String get professional => 'Profissional';

  @override
  String get preferences => 'Preferências';

  @override
  String get documents => 'Documentos';

  @override
  String get myCV => 'O meu CV';

  @override
  String get premium => 'Premium';

  @override
  String get addLanguages => 'Adicionar idiomas';

  @override
  String get addExperience => 'Adicionar experiência';

  @override
  String get addAvailability => 'Adicionar disponibilidade';

  @override
  String get matchesTitle => 'As suas correspondências';

  @override
  String get noMatchesTitle => 'Ainda não há correspondências';

  @override
  String get noMatchesSubtitle =>
      'Continue a candidatar-se — as correspondências aparecerão aqui';

  @override
  String get interestedBusinesses => 'Empresas interessadas';

  @override
  String get accept => 'Aceitar';

  @override
  String get decline => 'Recusar';

  @override
  String get newMatch => 'Nova correspondência';

  @override
  String get quickPlugTitle => 'Quick Plug';

  @override
  String get quickPlugEmpty => 'Sem novas empresas de momento';

  @override
  String get quickPlugSubtitle => 'Volte mais tarde para novas oportunidades';

  @override
  String get uploadYourCV => 'Carregue o seu CV';

  @override
  String get cvSubtitle =>
      'Adicione um CV para se candidatar mais rápido e destacar-se';

  @override
  String get chooseFile => 'Escolher ficheiro';

  @override
  String get removeCV => 'Remover CV';

  @override
  String get noCVUploaded => 'Ainda não carregou nenhum CV';

  @override
  String get discoverCompanies => 'Descobrir empresas';

  @override
  String get exploreSubtitle =>
      'Explore os melhores estabelecimentos da hotelaria';

  @override
  String get follow => 'Seguir';

  @override
  String get following => 'A seguir';

  @override
  String get view => 'Ver';

  @override
  String get selectLanguages => 'Selecionar idiomas';

  @override
  String selectedCount(int count) {
    return '$count selecionado(s)';
  }

  @override
  String get allLanguages => 'Todos os idiomas';

  @override
  String get uploadCVBig =>
      'Carregue o seu CV para preencher automaticamente o perfil e poupar tempo.';

  @override
  String get supportedFormats => 'Formatos suportados: PDF, DOC, DOCX';

  @override
  String get fillManually => 'Preencher manualmente';

  @override
  String get fillManuallySubtitle =>
      'Introduza os seus dados e complete o perfil passo a passo.';

  @override
  String get photoUploadSoon =>
      'Carregamento de fotos em breve — utilize um avatar profissional entretanto.';

  @override
  String get yourCV => 'O seu CV';

  @override
  String get aboutYou => 'Sobre si';

  @override
  String get optional => 'Opcional';

  @override
  String get completeProfile => 'Completar perfil';

  @override
  String get openToRelocation => 'Aberto a mudança de residência';

  @override
  String get matchLabel => 'Match';

  @override
  String get accepted => 'Aceite';

  @override
  String get deny => 'Recusar';

  @override
  String get featured => 'Em destaque';

  @override
  String get reviewYourProfile => 'Reveja o seu perfil';

  @override
  String get nothingSavedYet => 'Nada será guardado até confirmar.';

  @override
  String get editAnyField =>
      'Pode editar qualquer campo extraído antes de guardar.';

  @override
  String get saveToProfile => 'Guardar no perfil';

  @override
  String get findCompanies => 'Encontrar empresas';

  @override
  String get mapView => 'Vista de mapa';

  @override
  String get mapComingSoon => 'Vista de mapa em breve.';

  @override
  String get noCompaniesFound => 'Nenhuma empresa encontrada';

  @override
  String get tryWiderRadius => 'Tente um raio maior ou outra categoria.';

  @override
  String get verifiedOnly => 'Apenas verificadas';

  @override
  String get resetFilters => 'Repor filtros';

  @override
  String get available => 'Disponível';

  @override
  String lookingFor(String role) {
    return 'À procura de: $role';
  }

  @override
  String get boostMyProfile => 'Impulsionar o meu perfil';

  @override
  String get openToRelocationTravel =>
      'Aberto a mudança de residência / viagens';

  @override
  String get tellEmployersAboutYourself => 'Fale de si aos empregadores…';

  @override
  String get profileUpdated => 'Perfil atualizado';

  @override
  String get contractPreference => 'Preferência de contrato';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get languagePickerSoon => 'Seletor de idiomas em breve';

  @override
  String get selectCategoryRoleShort => 'Selecionar categoria e função';

  @override
  String get cvUploadSoon => 'Carregamento de CV em breve';

  @override
  String get restorePurchasesSoon => 'Restauro de compras em breve';

  @override
  String get photoUploadShort => 'Carregamento de fotos em breve';

  @override
  String get hireBestTalent => 'Contrate os melhores talentos da hotelaria';

  @override
  String get businessLoginSub =>
      'Publique anúncios e ligue-se a candidatos verificados.';

  @override
  String get lookingForWork => 'À procura de emprego? ';

  @override
  String get postJob => 'Publicar anúncio';

  @override
  String get editJob => 'Editar anúncio';

  @override
  String get jobTitle => 'Título do emprego';

  @override
  String get jobDescription2 => 'Descrição do emprego';

  @override
  String get publish => 'Publicar';

  @override
  String get saveDraft => 'Guardar rascunho';

  @override
  String get applicantsTitle => 'Candidatos';

  @override
  String get newApplicants => 'Novos candidatos';

  @override
  String get noApplicantsYet => 'Ainda não há candidatos';

  @override
  String get noApplicantsSubtitle =>
      'Os candidatos aparecerão aqui assim que se candidatarem.';

  @override
  String get scheduleInterview => 'Agendar entrevista';

  @override
  String get sendInvite => 'Enviar convite';

  @override
  String get interviewSent => 'Convite de entrevista enviado';

  @override
  String get rejectCandidate => 'Recusar';

  @override
  String get shortlistCandidate => 'Pré-selecionar';

  @override
  String get hiringDashboard => 'PAINEL DE CONTRATAÇÃO';

  @override
  String get yourPipelineActive => 'O seu pipeline\nestá ativo';

  @override
  String get postJobToStart => 'Publique um anúncio para começar a contratar';

  @override
  String reviewApplicants(int count) {
    return 'Analise $count novos candidatos';
  }

  @override
  String replyMessages(int count) {
    return 'Responda a $count mensagens não lidas';
  }

  @override
  String get interviews2 => 'Entrevistas';

  @override
  String get businessProfile => 'Perfil da empresa';

  @override
  String get venueGallery => 'Galeria do estabelecimento';

  @override
  String get addPhotos => 'Adicionar fotos';

  @override
  String get businessName => 'Nome da empresa';

  @override
  String get venueTypeLabel => 'Tipo de estabelecimento';

  @override
  String selectedItems(int count) {
    return '$count selecionado(s)';
  }

  @override
  String get hiringProgress => 'Progresso da contratação';

  @override
  String get unlockBusinessPremium => 'Desbloquear Business Premium';

  @override
  String get businessPremiumSubtitle =>
      'Acesso prioritário aos melhores candidatos';

  @override
  String get scheduleFromApplicants => 'Agendar a partir dos candidatos';

  @override
  String get recentApplicants => 'Candidatos recentes';

  @override
  String get viewAll => 'Ver tudo ›';

  @override
  String get recentActivity => 'Atividade recente';

  @override
  String get candidatePipeline => 'Pipeline de candidatos';

  @override
  String get allApplicants => 'Todos os candidatos';

  @override
  String get searchCandidates => 'Procurar candidatos, anúncios, entrevistas…';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mês';

  @override
  String get allTime => 'Sempre';

  @override
  String get post => 'Publicação';

  @override
  String get candidates => 'Candidatos';

  @override
  String get applicantDetail => 'Detalhes do candidato';

  @override
  String get candidateProfile => 'Perfil do candidato';

  @override
  String get shortlistTitle => 'Pré-seleção';

  @override
  String get noShortlistedCandidates =>
      'Ainda não há candidatos pré-selecionados';

  @override
  String get shortlistEmpty =>
      'Os candidatos que pré-selecionar aparecerão aqui';

  @override
  String get removeFromShortlist => 'Remover da pré-seleção';

  @override
  String get viewMessages => 'Ver mensagens';

  @override
  String get manageJobs => 'Gerir anúncios';

  @override
  String get yourJobs => 'Os seus anúncios';

  @override
  String get noJobsPosted => 'Ainda não há anúncios publicados';

  @override
  String get noJobsPostedSubtitle =>
      'Publique o seu primeiro anúncio para começar a contratar';

  @override
  String get draftJobs => 'Rascunhos';

  @override
  String get activeJobs => 'Ativos';

  @override
  String get expiredJobs => 'Expirados';

  @override
  String get closedJobs => 'Encerrados';

  @override
  String get createJob => 'Criar anúncio';

  @override
  String get jobDetailsTitle => 'Detalhes do anúncio';

  @override
  String get salaryRange => 'Intervalo salarial';

  @override
  String get currency => 'Moeda';

  @override
  String get monthly => 'Mensal';

  @override
  String get annual => 'Anual';

  @override
  String get hourly => 'Horário';

  @override
  String get minSalary => 'Mín';

  @override
  String get maxSalary => 'Máx';

  @override
  String get perks => 'Benefícios';

  @override
  String get addPerk => 'Adicionar benefício';

  @override
  String get remove => 'Remover';

  @override
  String get preview => 'Pré-visualização';

  @override
  String get publishJob => 'Publicar anúncio';

  @override
  String get jobPublished => 'Anúncio publicado';

  @override
  String get jobUpdated => 'Anúncio atualizado';

  @override
  String get jobSavedDraft => 'Guardado como rascunho';

  @override
  String get fillRequired => 'Preencha os campos obrigatórios';

  @override
  String get jobUrgent => 'Marcar como urgente';

  @override
  String get addAtLeastOne => 'Adicione pelo menos um requisito';

  @override
  String get createUpdate => 'Criar publicação';

  @override
  String get shareCompanyNews => 'Partilhe novidades da empresa';

  @override
  String get addStory => 'Adicionar story';

  @override
  String get showWorkplace => 'Mostre o seu local de trabalho';

  @override
  String get viewShortlist => 'Ver pré-seleção';

  @override
  String get yourSavedCandidates => 'Os seus candidatos guardados';

  @override
  String get inviteCandidate => 'Convidar candidato';

  @override
  String get reachOutDirectly => 'Contactar diretamente';

  @override
  String activeJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anúncios ativos',
      one: '1 anúncio ativo',
    );
    return '$_temp0';
  }

  @override
  String get employmentType => 'Tipo de emprego';

  @override
  String get requiredRole => 'Função requerida';

  @override
  String get selectCategoryRole2 => 'Selecionar categoria e função';

  @override
  String get hiresNeeded => 'Contratações necessárias';

  @override
  String get compensation => 'Remuneração';

  @override
  String get useSalaryRange => 'Usar intervalo salarial';

  @override
  String get contractDuration => 'Duração do contrato';

  @override
  String get limitReached => 'Limite atingido';

  @override
  String get upgradePlan => 'Atualizar plano';

  @override
  String usingXofY(int used, int total) {
    return 'Está a utilizar $used de $total anúncios.';
  }

  @override
  String get businessInterviewsTitle => 'Entrevistas';

  @override
  String get noInterviewsYet => 'Nenhuma entrevista agendada';

  @override
  String get scheduleFirstInterview =>
      'Agende a sua primeira entrevista com um candidato';

  @override
  String get sendInterviewInvite => 'Enviar convite de entrevista';

  @override
  String get interviewSentTitle => 'Convite enviado!';

  @override
  String get interviewSentSubtitle => 'O candidato foi notificado.';

  @override
  String get scheduleInterviewTitle => 'Agendar entrevista';

  @override
  String get interviewType => 'Tipo de entrevista';

  @override
  String get inPersonInterview => 'Presencial';

  @override
  String get videoCallInterview => 'Videochamada';

  @override
  String get phoneCallInterview => 'Chamada telefónica';

  @override
  String get interviewDate => 'Data';

  @override
  String get interviewTime => 'Hora';

  @override
  String get interviewLocation => 'Localização';

  @override
  String get interviewNotes => 'Notas';

  @override
  String get optionalLabel => 'Opcional';

  @override
  String get sendInviteCta => 'Enviar convite';

  @override
  String messagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens',
      one: '1 mensagem',
    );
    return '$_temp0';
  }

  @override
  String get noNewMessages => 'Sem novas mensagens';

  @override
  String get subscriptionTitle => 'Subscrição';

  @override
  String get currentPlan => 'Plano atual';

  @override
  String get manage => 'Gerir';

  @override
  String get upgrade => 'Atualizar';

  @override
  String get renewalDate => 'Data de renovação';

  @override
  String get nearbyTalent => 'Talentos por perto';

  @override
  String get searchNearby => 'Procurar por perto';

  @override
  String get communityTitle => 'Comunidade';

  @override
  String get createPost => 'Criar publicação';

  @override
  String get insights => 'Estatísticas';

  @override
  String get viewsLabel => 'Visualizações';

  @override
  String get applicationsLabel => 'Candidaturas';

  @override
  String get conversionRate => 'Taxa de conversão';

  @override
  String get topPerformingJob => 'Anúncio de melhor desempenho';

  @override
  String get viewAllSimple => 'Ver tudo';

  @override
  String get viewAllApplicantsForJob => 'Ver todos os candidatos deste anúncio';

  @override
  String get noUpcomingInterviews => 'Nenhuma entrevista próxima';

  @override
  String get noActivityYet => 'Ainda não há atividade';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado';

  @override
  String get renewsAutomatically => 'Renovação automática';

  @override
  String get plagitBusinessPlans => 'Planos Plagit Business';

  @override
  String get scaleYourHiringSubtitle =>
      'Escale as suas contratações com o plano certo para a sua empresa.';

  @override
  String get yearly => 'Anual';

  @override
  String get saveWithAnnualBilling => 'Poupe mais com a faturação anual';

  @override
  String get chooseYourPlanSubtitle =>
      'Escolha o plano adequado às suas necessidades de contratação.';

  @override
  String continueWithPlan(String plan) {
    return 'Continuar com $plan';
  }

  @override
  String get subscriptionAutoRenewNote =>
      'A subscrição renova-se automaticamente. Cancele quando quiser nas Definições.';

  @override
  String get purchaseFlowComingSoon => 'Fluxo de compra em breve';

  @override
  String get applicant => 'Candidato';

  @override
  String get applicantNotFound => 'Candidato não encontrado';

  @override
  String get cvViewerComingSoon => 'Visualizador de CV em breve';

  @override
  String get viewCV => 'Ver CV';

  @override
  String get application => 'Candidatura';

  @override
  String get messagingComingSoon => 'Mensagens em breve';

  @override
  String get interviewConfirmed => 'Entrevista confirmada';

  @override
  String get interviewMarkedCompleted => 'Entrevista marcada como concluída';

  @override
  String get cancelInterviewConfirm =>
      'Tem a certeza de que pretende cancelar esta entrevista?';

  @override
  String get yesCancel => 'Sim, cancelar';

  @override
  String get interviewNotFound => 'Entrevista não encontrada';

  @override
  String get openingMeetingLink => 'A abrir link da reunião…';

  @override
  String get rescheduleComingSoon => 'Reagendamento em breve';

  @override
  String get notesFeatureComingSoon => 'Notas em breve';

  @override
  String get candidateMarkedHired => 'Candidato marcado como contratado!';

  @override
  String get feedbackComingSoon => 'Avaliações em breve';

  @override
  String get googleMapsComingSoon => 'Integração Google Maps em breve';

  @override
  String get noCandidatesNearby => 'Nenhum candidato por perto';

  @override
  String get tryExpandingRadius => 'Tente aumentar o raio de pesquisa.';

  @override
  String get candidate => 'Candidato';

  @override
  String get forOpenPosition => 'Para vaga aberta';

  @override
  String get dateAndTimeUpper => 'DATA E HORA';

  @override
  String get interviewTypeUpper => 'TIPO DE ENTREVISTA';

  @override
  String get timezoneUpper => 'FUSO HORÁRIO';

  @override
  String get highlights => 'Destaques';

  @override
  String get cvNotAvailable => 'CV não disponível';

  @override
  String get cvWillAppearHere => 'Aparecerá aqui assim que for carregado';

  @override
  String get seenEveryone => 'Já viu todos';

  @override
  String get checkBackForCandidates =>
      'Volte mais tarde para ver novos candidatos.';

  @override
  String get dailyLimitReached => 'Limite diário atingido';

  @override
  String get upgradeForUnlimitedSwipes => 'Atualize para swipes ilimitados.';

  @override
  String get distanceUpper => 'DISTÂNCIA';

  @override
  String get inviteToInterview => 'Convidar para entrevista';

  @override
  String get details => 'Detalhes';

  @override
  String get shortlistedSuccessfully => 'Adicionado à pré-seleção';

  @override
  String get tabDashboard => 'Painel';

  @override
  String get tabCandidates => 'Candidatos';

  @override
  String get tabActivity => 'Atividade';

  @override
  String get statusPosted => 'Publicado';

  @override
  String get statusApplicants => 'Candidatos';

  @override
  String get statusInterviewsShort => 'Entrevistas';

  @override
  String get statusHiredShort => 'Contratados';

  @override
  String get jobLiveVisible => 'O seu anúncio está online e visível';

  @override
  String get postJobShort => 'Publicar';

  @override
  String get messagesTitle => 'Mensagens';

  @override
  String get online2 => 'Online agora';

  @override
  String get candidateUpper => 'CANDIDATO';

  @override
  String get searchConversationsHint =>
      'Procurar conversas, candidatos, funções…';

  @override
  String get filterUnread => 'Não lidas';

  @override
  String get filterAll => 'Todas';

  @override
  String get whenCandidatesMessage =>
      'Quando os candidatos lhe escreverem, as conversas aparecerão aqui.';

  @override
  String get trySwitchingFilter => 'Experimente outro filtro.';

  @override
  String get reply => 'Responder';

  @override
  String get selectItems => 'Selecionar itens';

  @override
  String countSelected(int count) {
    return '$count selecionado(s)';
  }

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get deleteConversation => 'Eliminar conversa?';

  @override
  String get deleteAllConversations => 'Eliminar todas as conversas?';

  @override
  String get deleteSelectedNote =>
      'As conversas selecionadas serão removidas da sua caixa. O candidato mantém a cópia dele.';

  @override
  String get deleteAll => 'Eliminar tudo';

  @override
  String get selectConversations => 'Selecionar conversas';

  @override
  String get feedTab => 'Feed';

  @override
  String get myPostsTab => 'As minhas publicações';

  @override
  String get savedTab => 'Guardadas';

  @override
  String postingAs(String name) {
    return 'A publicar como $name';
  }

  @override
  String get noPostsYet => 'Ainda não publicou nada';

  @override
  String get nothingHereYet => 'Ainda nada por aqui';

  @override
  String get shareVenueUpdate =>
      'Partilhe uma novidade do seu estabelecimento para construir a sua presença na comunidade.';

  @override
  String get communityPostsAppearHere =>
      'As publicações da comunidade aparecerão aqui.';

  @override
  String get createFirstPost => 'Criar primeira publicação';

  @override
  String get yourPostUpper => 'A SUA PUBLICAÇÃO';

  @override
  String get businessLabel => 'Empresa';

  @override
  String get profileNotAvailable => 'Perfil não disponível';

  @override
  String get companyProfile => 'Perfil da empresa';

  @override
  String get premiumVenue => 'Estabelecimento premium';

  @override
  String get businessDetailsTitle => 'Detalhes da empresa';

  @override
  String get businessNameLabel => 'Nome da empresa';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get locationLabel => 'Localização';

  @override
  String get verificationLabel => 'Verificação';

  @override
  String get pendingLabel => 'Pendente';

  @override
  String get notSet => 'Não definido';

  @override
  String get contactLabel => 'Contacto';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get companyNameField => 'Nome da empresa';

  @override
  String get phoneField => 'Telefone';

  @override
  String get locationField => 'Localização';

  @override
  String get signOut => 'Terminar sessão';

  @override
  String get signOutTitle => 'Terminar sessão?';

  @override
  String get signOutConfirm => 'Tem a certeza de que pretende terminar sessão?';

  @override
  String activeCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ativos',
      one: '1 ativo',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novos esta semana',
      one: '1 novo esta semana',
    );
    return '$_temp0';
  }

  @override
  String get jobStatusActive => 'Ativo';

  @override
  String get jobStatusPaused => 'Em pausa';

  @override
  String get jobStatusClosed => 'Encerrado';

  @override
  String get jobStatusDraft => 'Rascunho';

  @override
  String get contractCasual => 'Ocasional';

  @override
  String get planBasic => 'Basic';

  @override
  String get planPro => 'Pro';

  @override
  String get planPremium => 'Premium';

  @override
  String get bestForMaxVisibility => 'Ideal para visibilidade máxima';

  @override
  String saveDollarsPerYear(String currency, String amount) {
    return 'Poupe $currency$amount/ano';
  }

  @override
  String get planBasicFeature1 => 'Até 3 anúncios publicados';

  @override
  String get planBasicFeature2 => 'Consulta de perfis de candidatos';

  @override
  String get planBasicFeature3 => 'Pesquisa básica de candidatos';

  @override
  String get planBasicFeature4 => 'Apoio por e-mail';

  @override
  String get planProFeature1 => 'Até 10 anúncios publicados';

  @override
  String get planProFeature2 => 'Pesquisa avançada de candidatos';

  @override
  String get planProFeature3 => 'Ordenação prioritária de candidatos';

  @override
  String get planProFeature4 => 'Acesso Quick Plug';

  @override
  String get planProFeature5 => 'Apoio por chat';

  @override
  String get planPremiumFeature1 => 'Anúncios ilimitados';

  @override
  String get planPremiumFeature2 => 'Anúncios em destaque';

  @override
  String get planPremiumFeature3 => 'Análises avançadas';

  @override
  String get planPremiumFeature4 => 'Quick Plug ilimitado';

  @override
  String get planPremiumFeature5 => 'Matching prioritário de candidatos';

  @override
  String get planPremiumFeature6 => 'Gestor de conta dedicado';

  @override
  String get currentSelectionCheck => 'Seleção atual ✓';

  @override
  String selectPlanName(String plan) {
    return 'Selecionar $plan';
  }

  @override
  String get perYear => '/ano';

  @override
  String get perMonth => '/mês';

  @override
  String get jobTitleHintExample => 'ex. Chef de cozinha';

  @override
  String get locationHintExample => 'ex. Dubai, EAU';

  @override
  String annualSalaryLabel(String currency) {
    return 'Salário anual ($currency)';
  }

  @override
  String monthlyPayLabel(String currency) {
    return 'Remuneração mensal ($currency)';
  }

  @override
  String hourlyRateLabel(String currency) {
    return 'Taxa horária ($currency)';
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
  String get bonusTipsLabel => 'Prémio / Gorjetas (opcional)';

  @override
  String get bonusTipsHint => 'ex. Gorjetas e taxa de serviço';

  @override
  String get housingIncludedLabel => 'Alojamento incluído';

  @override
  String get travelIncludedLabel => 'Viagens incluídas';

  @override
  String get overtimeAvailableLabel => 'Horas extra disponíveis';

  @override
  String get flexibleScheduleLabel => 'Horário flexível';

  @override
  String get weekendShiftsLabel => 'Turnos ao fim de semana';

  @override
  String get describeRoleHint =>
      'Descreva a função, responsabilidades e o que torna este anúncio especial…';

  @override
  String get requirementsHint =>
      'Competências, experiência, certificações necessárias…';

  @override
  String previewPrefix(String text) {
    return 'Pré-visualização: $text';
  }

  @override
  String monthsShort(int count) {
    return '$count m';
  }

  @override
  String get roleAll => 'Todos';

  @override
  String get roleChef => 'Chef';

  @override
  String get roleWaiter => 'Empregado de mesa';

  @override
  String get roleBartender => 'Barman';

  @override
  String get roleHost => 'Rececionista de sala';

  @override
  String get roleManager => 'Gestor';

  @override
  String get roleReception => 'Receção';

  @override
  String get roleKitchenPorter => 'Auxiliar de cozinha';

  @override
  String get roleRelocate => 'Mudança';

  @override
  String get experience02Years => '0-2 anos';

  @override
  String get experience35Years => '3-5 anos';

  @override
  String get experience5PlusYears => '5+ anos';

  @override
  String get roleUpper => 'FUNÇÃO';

  @override
  String get experienceUpper => 'EXPERIÊNCIA';

  @override
  String get cvLabel => 'CV';

  @override
  String get addShort => 'Adicionar';

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
  String get shortlistAction => 'Pré-selecionar';

  @override
  String get messageAction => 'Mensagem';

  @override
  String get interviewAction => 'Entrevista';

  @override
  String get viewAction => 'Ver';

  @override
  String get rejectAction => 'Recusar';

  @override
  String get basedIn => 'Sediado em';

  @override
  String get verificationPending => 'Verificação pendente';

  @override
  String get refreshAction => 'Atualizar';

  @override
  String get upgradeAction => 'Obter Premium';

  @override
  String get searchJobsByTitleHint =>
      'Procurar por título, função ou localização…';

  @override
  String xShortlisted(String name) {
    return '$name pré-selecionado(a)';
  }

  @override
  String xRejected(String name) {
    return '$name recusado(a)';
  }

  @override
  String rejectConfirmName(String name) {
    return 'Tem a certeza de que pretende recusar $name?';
  }

  @override
  String appliedToRoleOn(String role, String date) {
    return 'Candidatou-se a $role em $date';
  }

  @override
  String appliedDatePrefix(String date) {
    return 'Candidatou-se em $date';
  }

  @override
  String get salaryExpectationTitle => 'Expectativa salarial';

  @override
  String get previousEmployer => 'Empregador anterior';

  @override
  String get earlierVenue => 'Estabelecimento anterior';

  @override
  String get presentLabel => 'Atual';

  @override
  String get skillCustomerService => 'Atendimento ao cliente';

  @override
  String get skillTeamwork => 'Trabalho em equipa';

  @override
  String get skillCommunication => 'Comunicação';

  @override
  String get stepApplied => 'Candidatura enviada';

  @override
  String get stepViewed => 'Visualizada';

  @override
  String get stepShortlisted => 'Pré-selecionado';

  @override
  String get stepInterviewScheduled => 'Entrevista agendada';

  @override
  String get stepRejected => 'Recusado';

  @override
  String get stepUnderReview => 'Em análise';

  @override
  String get stepPendingReview => 'Análise pendente';

  @override
  String get sortNewest => 'Mais recentes';

  @override
  String get sortMostExperienced => 'Mais experientes';

  @override
  String get sortBestMatch => 'Melhor match';

  @override
  String get filterApplied => 'Enviada';

  @override
  String get filterUnderReview => 'Em análise';

  @override
  String get filterShortlisted => 'Pré-selecionados';

  @override
  String get filterInterview => 'Entrevista';

  @override
  String get filterHired => 'Contratados';

  @override
  String get filterRejected => 'Recusados';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get pending => 'Pendente';

  @override
  String get completed => 'Concluído';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get videoLabel => 'Vídeo';

  @override
  String get viewDetails => 'Ver detalhes';

  @override
  String get interviewDetails => 'Detalhes da entrevista';

  @override
  String get interviewConfirmedHeadline => 'Entrevista confirmada';

  @override
  String get interviewConfirmedSubline =>
      'Está tudo pronto. Avisamos-lhe mais perto da data.';

  @override
  String get dateLabel => 'Data';

  @override
  String get timeLabel => 'Hora';

  @override
  String get formatLabel => 'Formato';

  @override
  String get joinMeeting => 'Entrar';

  @override
  String get viewJobAction => 'Ver anúncio';

  @override
  String get addToCalendar => 'Adicionar ao calendário';

  @override
  String get needsYourAttention => 'Precisa da sua atenção';

  @override
  String get reviewAction => 'Analisar';

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
  String get sortMostRecent => 'Mais recentes';

  @override
  String get interviewScheduledLabel => 'Entrevista agendada';

  @override
  String get editAction => 'Editar';

  @override
  String get currentPlanLabel => 'Plano atual';

  @override
  String get freePlan => 'Plano gratuito';

  @override
  String get profileStrength => 'Força do perfil';

  @override
  String get detailsLabel => 'Detalhes';

  @override
  String get basedInLabel => 'Sediado em';

  @override
  String get verificationLabel2 => 'Verificação';

  @override
  String get contactLabel2 => 'Contacto';

  @override
  String get notSetLabel => 'Não definido';

  @override
  String get chipAll => 'Todos';

  @override
  String get chipFullTime => 'Tempo inteiro';

  @override
  String get chipPartTime => 'Tempo parcial';

  @override
  String get chipTemporary => 'Temporário';

  @override
  String get chipCasual => 'Ocasional';

  @override
  String get sortBestMatchLabel => 'Melhor match';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get featuredBadge => 'Em destaque';

  @override
  String get urgentBadge => 'Urgente';

  @override
  String get salaryOnRequest => 'Salário a pedido';

  @override
  String get upgradeToPremium => 'Obter Premium';

  @override
  String get urgentJobsOnly => 'Apenas anúncios urgentes';

  @override
  String get showOnlyUrgentListings => 'Mostrar apenas anúncios urgentes';

  @override
  String get verifiedBusinessesOnly => 'Apenas empresas verificadas';

  @override
  String get showOnlyVerifiedBusinesses =>
      'Mostrar apenas empresas verificadas';

  @override
  String get split => 'Dividir';

  @override
  String get payUpper => 'REMUNERAÇÃO';

  @override
  String get typeUpper => 'TIPO';

  @override
  String get whereUpper => 'LOCAL';

  @override
  String get payLabel => 'Remuneração';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get whereLabel => 'Local';

  @override
  String get whereYouWillWork => 'Onde vai trabalhar';

  @override
  String get mapPreviewDirections =>
      'Pré-visualização · abrir para direções completas';

  @override
  String get directionsAction => 'Direções';

  @override
  String get communityTabForYou => 'Para si';

  @override
  String get communityTabFollowing => 'A seguir';

  @override
  String get communityTabNearby => 'Perto de si';

  @override
  String get communityTabSaved => 'Guardadas';

  @override
  String get viewProfileAction => 'Ver perfil';

  @override
  String get copyLinkAction => 'Copiar link';

  @override
  String get savePostAction => 'Guardar publicação';

  @override
  String get unsavePostAction => 'Remover publicação guardada';

  @override
  String get hideThisPost => 'Ocultar esta publicação';

  @override
  String get reportPost => 'Denunciar publicação';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get newPostTitle => 'Nova publicação';

  @override
  String get youLabel => 'Você';

  @override
  String get postingToCommunityAsBusiness =>
      'A publicar na Comunidade como Empresa';

  @override
  String get postingToCommunityAsPro =>
      'A publicar na Comunidade como Profissional de Hotelaria';

  @override
  String get whatsOnYourMind => 'O que tem em mente?';

  @override
  String get publishAction => 'Publicar';

  @override
  String get attachmentPhoto => 'Foto';

  @override
  String get attachmentVideo => 'Vídeo';

  @override
  String get attachmentLocation => 'Localização';

  @override
  String get boostMyProfileCta => 'Impulsionar o meu perfil';

  @override
  String get unlockYourFullPotential => 'Liberte todo o seu potencial';

  @override
  String get annualPlan => 'Anual';

  @override
  String get monthlyPlan => 'Mensal';

  @override
  String get bestValueBadge => 'MELHOR VALOR';

  @override
  String get whatsIncluded => 'O que está incluído';

  @override
  String get continueWithAnnual => 'Continuar com Anual';

  @override
  String get continueWithMonthly => 'Continuar com Mensal';

  @override
  String get maybeLater => 'Talvez mais tarde';

  @override
  String get restorePurchasesLabel => 'Restaurar compras';

  @override
  String get subscriptionAutoRenewsNote =>
      'A subscrição renova-se automaticamente. Cancele quando quiser nas Definições.';

  @override
  String get appStatusPillApplied => 'Enviada';

  @override
  String get appStatusPillUnderReview => 'Em análise';

  @override
  String get appStatusPillShortlisted => 'Pré-selecionado';

  @override
  String get appStatusPillInterviewInvited => 'Entrevista proposta';

  @override
  String get appStatusPillInterviewScheduled => 'Entrevista agendada';

  @override
  String get appStatusPillHired => 'Contratado';

  @override
  String get appStatusPillRejected => 'Rejeitada';

  @override
  String get appStatusPillWithdrawn => 'Retirada';

  @override
  String get jobActionPause => 'Pausar anúncio';

  @override
  String get jobActionResume => 'Retomar anúncio';

  @override
  String get jobActionClose => 'Encerrar anúncio';

  @override
  String get statusConfirmedLower => 'confirmado';

  @override
  String get postInsightsTitle => 'Estatísticas da publicação';

  @override
  String get postInsightsSubtitle => 'Quem está a ver o seu conteúdo';

  @override
  String get recentViewers => 'Visualizadores recentes';

  @override
  String get lockedBadge => 'BLOQUEADO';

  @override
  String get viewerBreakdown => 'Distribuição de visualizadores';

  @override
  String get viewersByRole => 'Visualizadores por função';

  @override
  String get topLocations => 'Principais localizações';

  @override
  String get businesses => 'Empresas';

  @override
  String get saveToCollectionTitle => 'Guardar numa coleção';

  @override
  String get chooseCategory => 'Escolher categoria';

  @override
  String get removeFromCollection => 'Remover da coleção';

  @override
  String newApplicationTemplate(String role) {
    return 'Nova candidatura — $role';
  }

  @override
  String get categoryRestaurants => 'Restaurantes';

  @override
  String get categoryCookingVideos => 'Vídeos de cozinha';

  @override
  String get categoryJobsTips => 'Dicas de emprego';

  @override
  String get categoryHospitalityNews => 'Notícias de hotelaria';

  @override
  String get categoryRecipes => 'Receitas';

  @override
  String get categoryOther => 'Outros';

  @override
  String get premiumHeroTagline =>
      'Mais visibilidade, alertas prioritários e filtros avançados para profissionais da hotelaria exigentes.';

  @override
  String get benefitAdvancedFilters => 'Filtros de pesquisa avançados';

  @override
  String get benefitPriorityNotifications => 'Alertas de emprego prioritários';

  @override
  String get benefitProfileVisibility => 'Maior visibilidade do perfil';

  @override
  String get benefitPremiumBadge => 'Selo Premium no perfil';

  @override
  String get benefitEarlyAccess => 'Acesso antecipado a novos anúncios';

  @override
  String get unlockCandidatePremium => 'Desbloquear Candidate Premium';

  @override
  String get getStartedAction => 'Começar';

  @override
  String get findYourFirstJob => 'Encontre o seu primeiro emprego';

  @override
  String get browseHospitalityRolesNearby =>
      'Explore centenas de vagas de hotelaria perto de si';

  @override
  String get seeWhoViewedYourPostTitle =>
      'Ver quem visualizou a sua publicação';

  @override
  String get upgradeToPremiumCta => 'Obter Premium';

  @override
  String get upgradeToPremiumSubtitle =>
      'Obtenha Premium para ver empresas verificadas, recrutadores e líderes da hotelaria que viram o seu conteúdo.';

  @override
  String get verifiedBusinessViewers =>
      'Visualizadores de empresas verificadas';

  @override
  String get recruiterHiringManagerActivity =>
      'Atividade de recrutadores e gestores de contratação';

  @override
  String get cityLevelReachBreakdown => 'Alcance ao nível das cidades';

  @override
  String liveApplicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ao vivo',
      one: '1 ao vivo',
    );
    return '$_temp0';
  }

  @override
  String nearbyJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por perto',
      one: '1 por perto',
    );
    return '$_temp0';
  }

  @override
  String jobsNearYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count empregos perto de si',
      one: '1 emprego perto de si',
    );
    return '$_temp0';
  }

  @override
  String applicationsUnderReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count candidaturas em análise',
      one: '1 candidatura em análise',
    );
    return '$_temp0';
  }

  @override
  String interviewsScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrevistas agendadas',
      one: '1 entrevista agendada',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens não lidas',
      one: '1 mensagem não lida',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesFromEmployersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens não lidas de empregadores',
      one: '1 mensagem não lida de empregadores',
    );
    return '$_temp0';
  }

  @override
  String stepsLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passos em falta',
      one: '1 passo em falta',
    );
    return '$_temp0';
  }

  @override
  String get profileCompleteGreatWork => 'Perfil completo — excelente trabalho';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anos',
      one: '1 ano',
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
      other: 'durante $count meses',
      one: 'durante 1 mês',
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
  String get quickActionFindJobs => 'Encontrar empregos';

  @override
  String get quickActionMyApplications => 'As minhas candidaturas';

  @override
  String get quickActionUpdateProfile => 'Atualizar perfil';

  @override
  String get quickActionCreatePost => 'Criar publicação';

  @override
  String get quickActionViewInterviews => 'Ver entrevistas';

  @override
  String get confirmSubscriptionTitle => 'Confirmar subscrição';

  @override
  String get confirmAndSubscribeCta => 'Confirmar e subscrever';

  @override
  String get timelineLabel => 'Cronologia';

  @override
  String get interviewLabel => 'Entrevista';

  @override
  String get payOnRequest => 'Remuneração a pedido';

  @override
  String get rateOnRequest => 'Taxa a pedido';

  @override
  String get quickActionFindJobsSubtitle => 'Descubra funções perto de si';

  @override
  String get quickActionMyApplicationsSubtitle =>
      'Acompanhe todas as suas candidaturas';

  @override
  String get quickActionUpdateProfileSubtitle =>
      'Melhore a sua visibilidade e pontuação de match';

  @override
  String get quickActionCreatePostSubtitle =>
      'Partilhe o seu trabalho com a comunidade';

  @override
  String get quickActionViewInterviewsSubtitle =>
      'Prepare-se para o próximo passo';

  @override
  String get offerLabel => 'Proposta';

  @override
  String hiringForTemplate(String role) {
    return 'A contratar para $role';
  }

  @override
  String get tapToOpenInMaps => 'Tocar para abrir no Mapas';

  @override
  String get alreadyAppliedToJob => 'Já se candidatou a este anúncio.';

  @override
  String get changePhoto => 'Alterar foto';

  @override
  String get changeAvatar => 'Alterar avatar';

  @override
  String get addPhotoAction => 'Adicionar foto';

  @override
  String get nationalityLabel => 'Nacionalidade';

  @override
  String get targetRoleLabel => 'Função pretendida';

  @override
  String get salaryExpectationLabel => 'Expectativa salarial';

  @override
  String get addLanguageCta => '+ Adicionar idioma';

  @override
  String get experienceLabel => 'Experiência';

  @override
  String get nameLabel => 'Nome';

  @override
  String get zeroHours => 'Zero horas';

  @override
  String get checkInterviewDetailsLine => 'Veja os detalhes da sua entrevista';

  @override
  String get interviewInvitedSubline =>
      'O empregador quer entrevistá-lo — confirme um horário';

  @override
  String get shortlistedSubline =>
      'Entrou na pré-seleção — aguarde o próximo passo';

  @override
  String get underReviewSubline => 'O empregador está a analisar o seu perfil';

  @override
  String get hiredHeadline => 'Contratado';

  @override
  String get hiredSubline => 'Parabéns! Recebeu uma proposta';

  @override
  String get applicationSubmittedHeadline => 'Candidatura enviada';

  @override
  String get applicationSubmittedSubline =>
      'O empregador vai analisar a sua candidatura';

  @override
  String get withdrawnHeadline => 'Retirada';

  @override
  String get withdrawnSubline => 'Retirou esta candidatura';

  @override
  String get notSelectedHeadline => 'Não selecionado';

  @override
  String get notSelectedSubline => 'Obrigado pelo seu interesse';

  @override
  String jobsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anúncios encontrados',
      one: '1 anúncio encontrado',
    );
    return '$_temp0';
  }

  @override
  String applicationsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count no total',
      one: '1 no total',
    );
    return '$_temp0';
  }

  @override
  String applicationsInReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count em análise',
      one: '1 em análise',
    );
    return '$_temp0';
  }

  @override
  String applicationsLiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ativas',
      one: '1 ativa',
    );
    return '$_temp0';
  }

  @override
  String interviewsPendingConfirmTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrevistas pendentes — confirme um horário.',
      one: '1 entrevista pendente — confirme um horário.',
    );
    return '$_temp0';
  }

  @override
  String notifInterviewConfirmedTitle(String name) {
    return 'Entrevista confirmada — $name';
  }

  @override
  String notifInterviewRequestTitle(String name) {
    return 'Pedido de entrevista — $name';
  }

  @override
  String notifApplicationUpdateTitle(String name) {
    return 'Atualização da candidatura — $name';
  }

  @override
  String notifOfferReceivedTitle(String name) {
    return 'Proposta recebida — $name';
  }

  @override
  String notifMessageFromTitle(String name) {
    return 'Mensagem de — $name';
  }

  @override
  String notifInterviewReminderTitle(String name) {
    return 'Lembrete de entrevista — $name';
  }

  @override
  String notifProfileViewedTitle(String name) {
    return 'Perfil visualizado — $name';
  }

  @override
  String notifNewJobMatchTitle(String name) {
    return 'Novo match de emprego — $name';
  }

  @override
  String notifApplicationViewedTitle(String name) {
    return 'Candidatura vista por — $name';
  }

  @override
  String notifShortlistedTitle(String name) {
    return 'Pré-selecionado em — $name';
  }

  @override
  String get notifCompleteProfile =>
      'Complete o seu perfil para melhores matches';

  @override
  String get notifCompleteBusinessProfile =>
      'Complete o perfil da sua empresa para maior visibilidade';

  @override
  String notifNewJobViews(String role, String count) {
    return 'O seu anúncio $role tem $count novas visualizações';
  }

  @override
  String notifAppliedForRole(String name, String role) {
    return '$name candidatou-se a $role';
  }

  @override
  String notifNewApplicationNameRole(String name, String role) {
    return 'Nova candidatura: $name para $role';
  }

  @override
  String get chatTyping => 'A escrever…';

  @override
  String get chatStatusSeen => 'Visto';

  @override
  String get chatStatusDelivered => 'Entregue';

  @override
  String get entryTagline =>
      'A plataforma de recrutamento para profissionais da hotelaria.';

  @override
  String get entryFindWork => 'Encontrar emprego';

  @override
  String get entryFindWorkSubtitle =>
      'Explore anúncios e seja contratado pelos melhores estabelecimentos';

  @override
  String get entryHireStaff => 'Contratar pessoal';

  @override
  String get entryHireStaffSubtitle =>
      'Publique anúncios e encontre os melhores talentos da hotelaria';

  @override
  String get entryFindCompanies => 'Encontrar empresas';

  @override
  String get entryFindCompaniesSubtitle =>
      'Descubra estabelecimentos de hotelaria e prestadores de serviços';

  @override
  String get servicesEntryTitle => 'À procura de empresas';

  @override
  String get servicesHospitalityServices => 'Serviços de hotelaria';

  @override
  String get servicesEntrySubtitle =>
      'Registe a sua empresa de serviços ou encontre prestadores de hotelaria perto de si';

  @override
  String get servicesRegisterCardTitle => 'Registar como empresa';

  @override
  String get servicesRegisterCardSubtitle =>
      'Liste o seu serviço de hotelaria e seja descoberto por clientes';

  @override
  String get servicesLookingCardTitle => 'Procuro uma empresa';

  @override
  String get servicesLookingCardSubtitle =>
      'Encontre prestadores de serviços de hotelaria perto de si';

  @override
  String get registerBusinessTitle => 'Registe a sua empresa';

  @override
  String get enterCompanyName => 'Introduza o nome da empresa';

  @override
  String get subcategoryOptional => 'Subcategoria (opcional)';

  @override
  String get subcategoryHintFloristDj => 'ex. Floricultura, Serviços de DJ';

  @override
  String get searchCompaniesHint => 'Procurar empresas…';

  @override
  String get browseCategories => 'Explorar categorias';

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
      'Fornecedores de alimentação e bebidas';

  @override
  String get serviceCategoryEventServices => 'Serviços de eventos';

  @override
  String get serviceCategoryDecorDesign => 'Decoração e design';

  @override
  String get serviceCategoryEntertainment => 'Entretenimento';

  @override
  String get serviceCategoryEquipmentOps => 'Equipamento e operações';

  @override
  String get serviceCategoryCleaningMaintenance => 'Limpeza e manutenção';

  @override
  String distanceMiles(String value) {
    return '$value mi';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String get postDetailTitle => 'Publicação';

  @override
  String get likeAction => 'Gosto';

  @override
  String get commentAction => 'Comentar';

  @override
  String get saveActionLabel => 'Guardar';

  @override
  String get commentsTitle => 'Comentários';

  @override
  String get addCommentHint => 'Adicionar um comentário…';

  @override
  String likesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gostos',
      one: '1 gosto',
    );
    return '$_temp0';
  }

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentários',
      one: '1 comentário',
    );
    return '$_temp0';
  }

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guardados',
      one: '1 guardado',
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
    return '$count d';
  }

  @override
  String get timeAgoNow => 'agora';

  @override
  String get activityTitle => 'Atividade';

  @override
  String get activityLikedPost => 'gostou da sua publicação';

  @override
  String get activityCommented => 'comentou na sua publicação';

  @override
  String get activityStartedFollowing => 'começou a segui-lo';

  @override
  String get activityMentioned => 'mencionou-o';

  @override
  String get activitySystemUpdate => 'enviou-lhe uma atualização';

  @override
  String get noActivityYetDesc =>
      'Quando alguém gostar, comentar ou o seguir, irá aparecer aqui.';

  @override
  String get activeStatus => 'Ativo';

  @override
  String get activeBadge => 'ATIVO';

  @override
  String get nextRenewalLabel => 'Próxima renovação';

  @override
  String get startedLabel => 'Iniciado';

  @override
  String get statusLabel => 'Estado';

  @override
  String get billingAndCancellation => 'Faturação e cancelamento';

  @override
  String get billingAndCancellationCopy =>
      'A sua subscrição é faturada através da conta App Store / Google Play. Pode cancelar quando quiser nas Definições do dispositivo — mantém o acesso premium até à data de renovação.';

  @override
  String get premiumIsActive => 'Premium está ativo';

  @override
  String get premiumThanksCopy =>
      'Obrigado por apoiar o Plagit. Tem acesso total a todas as funcionalidades premium.';

  @override
  String get manageSubscription => 'Gerir subscrição';

  @override
  String get candidatePremiumPlanName => 'Candidate Premium';

  @override
  String renewsOnDate(String date) {
    return 'Renova a $date';
  }

  @override
  String get fullViewerAccessLine =>
      'Acesso total aos visualizadores · todas as estatísticas desbloqueadas';

  @override
  String get premiumActiveBadge => 'Premium ativo';

  @override
  String get fullInsightsUnlocked =>
      'Estatísticas completas e detalhes dos visualizadores desbloqueados.';

  @override
  String get noViewersInCategory =>
      'Ainda não há visualizadores nesta categoria';

  @override
  String get onlyVerifiedViewersShown =>
      'Apenas são mostrados visualizadores verificados com perfil público.';

  @override
  String get notEnoughDataYet => 'Ainda não há dados suficientes.';

  @override
  String get noViewInsightsYet => 'Ainda não há estatísticas de visualização';

  @override
  String get noViewInsightsDesc =>
      'As estatísticas aparecerão quando a publicação tiver mais visualizações.';

  @override
  String get suspiciousEngagementDetected => 'Interação suspeita detetada';

  @override
  String get patternReviewRequired => 'Análise de padrão necessária';

  @override
  String get adminInsightsFooter =>
      'Vista de admin — as mesmas estatísticas que o autor vê, mais alertas de moderação. Apenas agregadas, sem exposição de identidades individuais.';

  @override
  String get viewerKindBusiness => 'Empresa';

  @override
  String get viewerKindCandidate => 'Candidato';

  @override
  String get viewerKindRecruiter => 'Recrutador';

  @override
  String get viewerKindHiringManager => 'Gestor de Contratação';

  @override
  String get viewerKindBusinessesPlural => 'Empresas';

  @override
  String get viewerKindCandidatesPlural => 'Candidatos';

  @override
  String get viewerKindRecruitersPlural => 'Recrutadores';

  @override
  String get viewerKindHiringManagersPlural => 'Gestores de Contratação';

  @override
  String get searchPeoplePostsVenuesHint =>
      'Procurar pessoas, publicações, estabelecimentos…';

  @override
  String get searchCommunityTitle => 'Procurar na comunidade';

  @override
  String get roleSommelier => 'Sommelier';

  @override
  String get candidatePremiumActivated => 'É agora Candidate Premium';

  @override
  String get purchasesRestoredPremium =>
      'Compras restauradas — é agora Candidate Premium';

  @override
  String get nothingToRestore => 'Nada para restaurar';

  @override
  String get noValidSubscriptionPremiumRemoved =>
      'Nenhuma subscrição válida encontrada — acesso premium removido';

  @override
  String restoreFailedWithError(String error) {
    return 'Falha ao restaurar. $error';
  }

  @override
  String get subscriptionTitleAnnual => 'Candidate Premium · Anual';

  @override
  String get subscriptionTitleMonthly => 'Candidate Premium · Mensal';

  @override
  String pricePerYearSlash(String price) {
    return '$price / ano';
  }

  @override
  String pricePerMonthSlash(String price) {
    return '$price / mês';
  }

  @override
  String get nearbyJobsTitle => 'Empregos por perto';

  @override
  String get expandRadius => 'Aumentar raio';

  @override
  String get noJobsInRadius => 'Nenhum emprego neste raio';

  @override
  String jobsWithinRadius(int count, int radius) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count empregos num raio de $radius milhas',
      one: '1 emprego num raio de $radius milhas',
    );
    return '$_temp0';
  }

  @override
  String get interviewAcceptedSnack => 'Entrevista aceite!';

  @override
  String get declineInterviewTitle => 'Recusar entrevista';

  @override
  String get declineInterviewConfirm =>
      'Tem a certeza de que pretende recusar esta entrevista?';

  @override
  String get addedToCalendar => 'Adicionado ao calendário';

  @override
  String get removeCompanyTitle => 'Remover?';

  @override
  String get removeCompanyConfirm =>
      'Tem a certeza de que pretende remover esta empresa da sua lista de guardados?';

  @override
  String get signOutAllRolesConfirm =>
      'Tem a certeza de que pretende terminar sessão em todas as funções?';

  @override
  String get tapToViewAllConversations => 'Tocar para ver todas as conversas';

  @override
  String get savedJobsTitle => 'Empregos guardados';

  @override
  String savedJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count empregos guardados',
      one: '1 emprego guardado',
    );
    return '$_temp0';
  }

  @override
  String get removeFromSavedTitle => 'Remover dos guardados?';

  @override
  String get removeFromSavedConfirm =>
      'Este anúncio será removido da sua lista de guardados.';

  @override
  String get noSavedJobsSubtitle => 'Explore anúncios e guarde os que gostar';

  @override
  String get browseJobsAction => 'Explorar anúncios';

  @override
  String matchingJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anúncios correspondentes',
      one: '1 anúncio correspondente',
    );
    return '$_temp0';
  }

  @override
  String get savedPostsTitle => 'Publicações guardadas';

  @override
  String get searchSavedPostsHint => 'Procurar nas publicações guardadas…';

  @override
  String get skipAction => 'Ignorar';

  @override
  String get submitAction => 'Enviar';

  @override
  String get doneAction => 'Concluído';

  @override
  String get resetYourPasswordTitle => 'Redefinir palavra-passe';

  @override
  String get enterEmailForResetCode =>
      'Introduza o seu e-mail para receber um código';

  @override
  String get sendResetCode => 'Enviar código';

  @override
  String get enterResetCode => 'Introduzir código';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get passwordResetComplete => 'Palavra-passe redefinida';

  @override
  String get backToSignIn => 'Voltar ao início de sessão';

  @override
  String get passwordChanged => 'Palavra-passe alterada';

  @override
  String get passwordUpdatedShort =>
      'A sua palavra-passe foi atualizada com sucesso.';

  @override
  String get passwordUpdatedRelogin =>
      'A sua palavra-passe foi atualizada. Inicie sessão novamente com a nova.';

  @override
  String get updatePassword => 'Atualizar palavra-passe';

  @override
  String get changePasswordTitle => 'Alterar palavra-passe';

  @override
  String get passwordRequirements => 'Requisitos da palavra-passe';

  @override
  String get newPasswordHint => 'Nova palavra-passe (mín 8 caracteres)';

  @override
  String get confirmPasswordField => 'Confirmar palavra-passe';

  @override
  String get enterEmailField => 'Introduzir e-mail';

  @override
  String get enterPasswordField => 'Introduzir palavra-passe';

  @override
  String get welcomeBack => 'Bem-vindo de volta!';

  @override
  String get selectHowToUse => 'Escolha como quer usar o Plagit hoje';

  @override
  String get continueAsCandidate => 'Continuar como candidato';

  @override
  String get continueAsBusiness => 'Continuar como empresa';

  @override
  String get signInToPlagit => 'Inicie sessão no Plagit';

  @override
  String get enterCredentials => 'Introduza as credenciais para continuar';

  @override
  String get adminPortal => 'Portal de administração';

  @override
  String get plagitAdmin => 'Plagit Admin';

  @override
  String get signInToAdminAccount => 'Inicie sessão na conta de administrador';

  @override
  String get admin => 'Admin';

  @override
  String get searchJobsRolesRestaurantsHint =>
      'Pesquisar empregos, funções, restaurantes...';

  @override
  String get exploreNearbyJobs => 'Explorar empregos próximos';

  @override
  String get findOpportunitiesOnMap => 'Descubra oportunidades no mapa';

  @override
  String get featuredJobs => 'Empregos em destaque';

  @override
  String get jobsNearYou => 'Empregos perto de si';

  @override
  String get jobsMatchingRoleType =>
      'Empregos compatíveis com a sua função e tipo';

  @override
  String get availableNow => 'Disponível agora';

  @override
  String get noNearbyJobsYet => 'Ainda não há empregos próximos';

  @override
  String get tryIncreasingRadius => 'Aumente o raio ou mude os filtros';

  @override
  String get checkBackForOpportunities =>
      'Volte em breve para novas oportunidades';

  @override
  String get noNotifications => 'Sem notificações';

  @override
  String get okAction => 'OK';

  @override
  String get onlineNow => 'Online agora';

  @override
  String get businessUpper => 'EMPRESA';

  @override
  String get waitingForBusinessFirstMessage =>
      'A aguardar o primeiro contacto da empresa';

  @override
  String get whenEmployersMessageYou =>
      'As mensagens dos empregadores aparecem aqui.';

  @override
  String get replyToCandidate => 'Responder ao candidato…';

  @override
  String get quickFeedback => 'Feedback rápido';

  @override
  String get helpImproveMatches => 'Ajude-nos a melhorar os seus matches';

  @override
  String get thanksForFeedback => 'Obrigado pelo seu feedback!';

  @override
  String get accountSettings => 'Definições da conta';

  @override
  String get notificationSettings => 'Definições de notificações';

  @override
  String get privacyAndSecurity => 'Privacidade e segurança';

  @override
  String get helpAndSupport => 'Ajuda e suporte';

  @override
  String get activeRoleUpper => 'FUNÇÃO ATIVA';

  @override
  String get meetingLink => 'Link da reunião';

  @override
  String get joinMeeting2 => 'Entrar na reunião';

  @override
  String get notes => 'Notas';

  @override
  String get completeBusinessProfileTitle => 'Complete o perfil da empresa';

  @override
  String get businessDescription => 'Descrição da empresa';

  @override
  String get finishSetupAction => 'Concluir configuração';

  @override
  String get describeBusinessHintLong =>
      'Descreva a empresa, cultura e o que a torna um ótimo local de trabalho... (mín 150 caracteres)';

  @override
  String get describeBusinessHintShort => 'Descreva a empresa...';

  @override
  String get writeShortIntroAboutYourself =>
      'Escreva uma breve apresentação sobre si...';

  @override
  String get createBusinessAccountTitle => 'Criar conta de empresa';

  @override
  String get businessDetailsSection => 'Detalhes da empresa';

  @override
  String get openToInternationalCandidates =>
      'Aberto a candidatos internacionais';

  @override
  String get createAccountShort => 'Criar conta';

  @override
  String get yourDetailsSection => 'Os seus dados';

  @override
  String get jobTypeField => 'Tipo de emprego';

  @override
  String get communityFeed => 'Feed da comunidade';

  @override
  String get postPublished => 'Publicação publicada';

  @override
  String get postHidden => 'Publicação ocultada';

  @override
  String get postReportedReview => 'Publicação denunciada — o admin vai rever';

  @override
  String get postNotFound => 'Publicação não encontrada';

  @override
  String get goBack => 'Voltar';

  @override
  String get linkCopied => 'Link copiado';

  @override
  String get removedFromSaved => 'Removido dos guardados';

  @override
  String get noPostsFound => 'Nenhuma publicação encontrada';

  @override
  String get tipsStoriesAdvice =>
      'Dicas, histórias e conselhos de profissionais';

  @override
  String get searchTalentPostsRolesHint =>
      'Pesquisar talentos, publicações, funções…';

  @override
  String get videoAttachmentsComingSoon => 'Anexos de vídeo em breve';

  @override
  String get locationTaggingComingSoon => 'Etiqueta de localização em breve';

  @override
  String get fullImageViewerComingSoon => 'Visualizador de imagens em breve';

  @override
  String get shareComingSoon => 'Partilha em breve';

  @override
  String get findServices => 'Encontrar serviços';

  @override
  String get findHospitalityServices => 'Encontrar serviços de hotelaria';

  @override
  String get browseServices => 'Explorar serviços';

  @override
  String get searchServicesCompaniesLocationsHint =>
      'Pesquisar serviços, empresas, locais...';

  @override
  String get searchCompaniesServicesLocationsHint =>
      'Pesquisar empresas, serviços, locais...';

  @override
  String get nearbyCompanies => 'Empresas próximas';

  @override
  String get nearYou => 'Perto de si';

  @override
  String get listLabel => 'Lista';

  @override
  String get mapViewLabel => 'Vista do mapa';

  @override
  String get noServicesFound => 'Nenhum serviço encontrado';

  @override
  String get noCompaniesFoundNearby => 'Nenhuma empresa por perto';

  @override
  String get noSavedCompanies => 'Sem empresas guardadas';

  @override
  String get savedCompaniesTitle => 'Empresas guardadas';

  @override
  String get saveCompaniesForLater =>
      'Guarde empresas para as encontrar mais tarde';

  @override
  String get latestUpdates => 'Últimas atualizações';

  @override
  String get noPromotions => 'Sem promoções';

  @override
  String get companyHasNoPromotions => 'Esta empresa não tem promoções ativas.';

  @override
  String get companyHasNoUpdates => 'Esta empresa não publicou atualizações.';

  @override
  String get promotionsAndOffers => 'Promoções e ofertas';

  @override
  String get promotionNotFound => 'Promoção não encontrada';

  @override
  String get promotionDetails => 'Detalhes da promoção';

  @override
  String get termsAndConditions => 'Termos e condições';

  @override
  String get relatedPosts => 'Publicações relacionadas';

  @override
  String get viewOffer => 'Ver oferta';

  @override
  String get offerBadge => 'OFERTA';

  @override
  String get requestQuote => 'Pedir orçamento';

  @override
  String get sendRequest => 'Enviar pedido';

  @override
  String get quoteRequestSent => 'Pedido de orçamento enviado!';

  @override
  String get inquiry => 'Consulta';

  @override
  String get dateNeeded => 'Data pretendida';

  @override
  String get serviceType => 'Tipo de serviço';

  @override
  String get serviceArea => 'Área de serviço';

  @override
  String get servicesOffered => 'Serviços oferecidos';

  @override
  String get servicesLabel => 'Serviços';

  @override
  String get servicePlans => 'Planos de serviço';

  @override
  String get growYourServiceBusiness => 'Expanda o seu negócio de serviços';

  @override
  String get getDiscoveredPremium =>
      'Seja descoberto por mais clientes com um anúncio premium.';

  @override
  String get unlockPremium => 'Desbloquear Premium';

  @override
  String get getMoreVisibility =>
      'Obtenha mais visibilidade e melhores matches';

  @override
  String get plagitPremiumUpper => 'PLAGIT PREMIUM';

  @override
  String get premiumOnly => 'Apenas Premium';

  @override
  String get savePercent17 => 'Poupe 17%';

  @override
  String get registerBusinessCta => 'Registar empresa';

  @override
  String get registrationSubmitted => 'Registo enviado';

  @override
  String get serviceDescription => 'Descrição do serviço';

  @override
  String get describeServicesHint =>
      'Descreva os seus serviços, experiência e diferenciais...';

  @override
  String get websiteOptional => 'Site (opcional)';

  @override
  String get viewCompanyProfileCta => 'Ver perfil da empresa';

  @override
  String get contactCompany => 'Contactar empresa';

  @override
  String get aboutUs => 'Sobre nós';

  @override
  String get address => 'Morada';

  @override
  String get city => 'Cidade';

  @override
  String get yourLocation => 'A sua localização';

  @override
  String get enterYourCity => 'Introduza a sua cidade';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get tryDifferentSearchTerm => 'Tente um termo diferente';

  @override
  String get tryDifferentOrAdjust =>
      'Tente outra pesquisa, categoria ou filtros.';

  @override
  String get noPostsYetCompany => 'Ainda não há publicações';

  @override
  String requestQuoteFromCompany(String companyName) {
    return 'Solicitar orçamento a $companyName';
  }

  @override
  String validUntilDate(String validUntil) {
    return 'Válido até $validUntil';
  }

  @override
  String get employerCheckingProfile =>
      'Um empregador está a verificar o seu perfil agora';

  @override
  String profileStrengthPercent(int percent) {
    return 'O seu perfil está $percent% completo';
  }

  @override
  String get profileGetsMoreViews =>
      'Um perfil completo recebe 3× mais visualizações';

  @override
  String get applicationUpdate => 'Atualização de candidatura';

  @override
  String get findJobsAndApply => 'Encontre vagas e candidate-se';

  @override
  String get manageJobsAndHiring => 'Gerenciar vagas e contratações';

  @override
  String get managePlatform => 'Gerenciar plataforma';

  @override
  String get findHospitalityCompanies => 'Encontre empresas de hospitalidade';

  @override
  String get candidateMessages => 'MENSAGENS DE CANDIDATOS';

  @override
  String get businessMessages => 'MENSAGENS DE EMPRESAS';

  @override
  String get serviceInquiries => 'CONSULTAS DE SERVIÇO';

  @override
  String get acceptInterview => 'Aceitar entrevista';

  @override
  String get adminMenuDashboard => 'Painel';

  @override
  String get adminMenuUsers => 'Usuários';

  @override
  String get adminMenuCandidates => 'Candidatos';

  @override
  String get adminMenuBusinesses => 'Empresas';

  @override
  String get adminMenuJobs => 'Empregos';

  @override
  String get adminMenuApplications => 'Candidaturas';

  @override
  String get adminMenuBookings => 'Reservas';

  @override
  String get adminMenuPayments => 'Pagamentos';

  @override
  String get adminMenuMessages => 'Mensagens';

  @override
  String get adminMenuNotifications => 'Notificações';

  @override
  String get adminMenuReports => 'Relatórios';

  @override
  String get adminMenuAnalytics => 'Análises';

  @override
  String get adminMenuSettings => 'Configurações';

  @override
  String get adminMenuSupport => 'Suporte';

  @override
  String get adminMenuModeration => 'Moderação';

  @override
  String get adminMenuRoles => 'Funções';

  @override
  String get adminMenuInvoices => 'Faturas';

  @override
  String get adminMenuLogs => 'Registros';

  @override
  String get adminMenuIntegrations => 'Integrações';

  @override
  String get adminMenuLogout => 'Sair';

  @override
  String get adminActionApprove => 'Aprovar';

  @override
  String get adminActionReject => 'Rejeitar';

  @override
  String get adminActionSuspend => 'Suspender';

  @override
  String get adminActionActivate => 'Ativar';

  @override
  String get adminActionDelete => 'Excluir';

  @override
  String get adminActionExport => 'Exportar';

  @override
  String get adminSectionOverview => 'Visão geral';

  @override
  String get adminSectionManagement => 'Gestão';

  @override
  String get adminSectionFinance => 'Finanças';

  @override
  String get adminSectionOperations => 'Operações';

  @override
  String get adminSectionSystem => 'Sistema';

  @override
  String get adminStatTotalUsers => 'Usuários totais';

  @override
  String get adminStatActiveJobs => 'Empregos ativos';

  @override
  String get adminStatPendingApprovals => 'Aprovações pendentes';

  @override
  String get adminStatRevenue => 'Receita';

  @override
  String get adminStatBookingsToday => 'Reservas hoje';

  @override
  String get adminStatNewSignups => 'Novos cadastros';

  @override
  String get adminStatConversionRate => 'Taxa de conversão';

  @override
  String get adminMiscWelcome => 'Bem-vindo de volta';

  @override
  String get adminMiscLoading => 'Carregando…';

  @override
  String get adminMiscNoData => 'Nenhum dado disponível';

  @override
  String get adminMiscSearchPlaceholder => 'Pesquisar…';

  @override
  String get adminMenuContent => 'Conteúdo';

  @override
  String get adminMenuMore => 'Mais';

  @override
  String get adminMenuVerifications => 'Verificações';

  @override
  String get adminMenuSubscriptions => 'Assinaturas';

  @override
  String get adminMenuCommunity => 'Comunidade';

  @override
  String get adminMenuInterviews => 'Entrevistas';

  @override
  String get adminMenuMatches => 'Correspondências';

  @override
  String get adminMenuFeaturedContent => 'Conteúdo em destaque';

  @override
  String get adminMenuAuditLog => 'Log de auditoria';

  @override
  String get adminMenuChangePassword => 'Alterar senha';

  @override
  String get adminSectionPeople => 'Pessoas';

  @override
  String get adminSectionHiring => 'Operações de contratação';

  @override
  String get adminSectionContentComm => 'Conteúdo e comunicação';

  @override
  String get adminSectionRevenue => 'Negócios e receita';

  @override
  String get adminSectionToolsContent => 'Ferramentas e conteúdo';

  @override
  String get adminSectionQuickActions => 'Ações rápidas';

  @override
  String get adminSectionNeedsAttention => 'Requer atenção';

  @override
  String get adminStatActiveBusinesses => 'Empresas ativas';

  @override
  String get adminStatApplicationsToday => 'Candidaturas hoje';

  @override
  String get adminStatInterviewsToday => 'Entrevistas hoje';

  @override
  String get adminStatFlaggedContent => 'Conteúdo sinalizado';

  @override
  String get adminStatActiveSubs => 'Assinaturas ativas';

  @override
  String get adminActionFlagged => 'Sinalizados';

  @override
  String get adminActionFeatured => 'Destaque';

  @override
  String get adminActionReviewFlagged => 'Revisar conteúdo sinalizado';

  @override
  String get adminActionTodayInterviews => 'Entrevistas de hoje';

  @override
  String get adminActionOpenReports => 'Denúncias abertas';

  @override
  String get adminActionManageSubscriptions => 'Gerenciar assinaturas';

  @override
  String get adminActionAnalyticsDashboard => 'Painel de análises';

  @override
  String get adminActionSendNotification => 'Enviar notificação';

  @override
  String get adminActionCreateCommunityPost => 'Criar post da comunidade';

  @override
  String get adminActionRetry => 'Tentar novamente';

  @override
  String get adminMiscGreetingMorning => 'Bom dia';

  @override
  String get adminMiscGreetingAfternoon => 'Boa tarde';

  @override
  String get adminMiscGreetingEvening => 'Boa noite';

  @override
  String get adminMiscAllClear => 'Tudo certo — nada requer atenção.';

  @override
  String get adminSubtitleAllUsers => 'Todos os usuários';

  @override
  String get adminSubtitleCandidates => 'Perfis de candidatos';

  @override
  String get adminSubtitleBusinesses => 'Contas de empresas';

  @override
  String get adminSubtitleJobs => 'Vagas ativas';

  @override
  String get adminSubtitleApplications => 'Candidaturas enviadas';

  @override
  String get adminSubtitleInterviews => 'Entrevistas agendadas';

  @override
  String get adminSubtitleMatches => 'Correspondências de função e tipo';

  @override
  String get adminSubtitleVerifications => 'Verificações pendentes';

  @override
  String get adminSubtitleReports => 'Denúncias e moderação';

  @override
  String get adminSubtitleSupport => 'Tickets de suporte abertos';

  @override
  String get adminSubtitleMessages => 'Conversas de usuários';

  @override
  String get adminSubtitleNotifications => 'Alertas push e in-app';

  @override
  String get adminSubtitleCommunity => 'Publicações e discussões';

  @override
  String get adminSubtitleFeaturedContent => 'Conteúdo em destaque';

  @override
  String get adminSubtitleSubscriptions => 'Planos e cobrança';

  @override
  String get adminSubtitleAuditLog => 'Logs de atividade admin';

  @override
  String get adminSubtitleAnalytics => 'Métricas da plataforma';

  @override
  String get adminSubtitleSettings => 'Configuração da plataforma';

  @override
  String get adminSubtitleUsersPage => 'Gerenciar contas';

  @override
  String get adminSubtitleContentPage => 'Vagas, candidaturas e entrevistas';

  @override
  String get adminSubtitleModerationPage => 'Verificações, denúncias e suporte';

  @override
  String get adminSubtitleMorePage => 'Configurações, análises e conta';

  @override
  String get adminSubtitleAnalyticsHero =>
      'KPIs, tendências e saúde da plataforma';

  @override
  String get adminBadgeUrgent => 'Urgente';

  @override
  String get adminBadgeReview => 'Revisar';

  @override
  String get adminBadgeAction => 'Ação';

  @override
  String get adminMenuAllUsers => 'Todos os usuários';

  @override
  String get adminMiscSuperAdmin => 'Super Admin';

  @override
  String adminBadgeNToday(int count) {
    return '$count hoje';
  }

  @override
  String adminBadgeNOpen(int count) {
    return '$count abertos';
  }

  @override
  String adminBadgeNActive(int count) {
    return '$count ativos';
  }

  @override
  String adminBadgeNUnread(int count) {
    return '$count não lidos';
  }

  @override
  String adminBadgeNPending(int count) {
    return '$count pendentes';
  }

  @override
  String adminBadgeNPosts(int count) {
    return '$count publicações';
  }

  @override
  String adminBadgeNFeatured(int count) {
    return '$count em destaque';
  }

  @override
  String get adminStatusActive => 'Ativo';

  @override
  String get adminStatusPaused => 'Pausado';

  @override
  String get adminStatusClosed => 'Fechado';

  @override
  String get adminStatusDraft => 'Rascunho';

  @override
  String get adminStatusFlagged => 'Sinalizado';

  @override
  String get adminStatusSuspended => 'Suspenso';

  @override
  String get adminStatusPending => 'Pendente';

  @override
  String get adminStatusConfirmed => 'Confirmado';

  @override
  String get adminStatusCompleted => 'Concluído';

  @override
  String get adminStatusCancelled => 'Cancelado';

  @override
  String get adminStatusAccepted => 'Aceito';

  @override
  String get adminStatusDenied => 'Negado';

  @override
  String get adminStatusExpired => 'Expirado';

  @override
  String get adminStatusResolved => 'Resolvido';

  @override
  String get adminStatusScheduled => 'Agendado';

  @override
  String get adminStatusBanned => 'Banido';

  @override
  String get adminStatusVerified => 'Verificado';

  @override
  String get adminStatusFailed => 'Falhou';

  @override
  String get adminStatusSuccess => 'Sucesso';

  @override
  String get adminStatusDelivered => 'Entregue';

  @override
  String get adminFilterAll => 'Todos';

  @override
  String get adminFilterToday => 'Hoje';

  @override
  String get adminFilterUnread => 'Não lidos';

  @override
  String get adminFilterRead => 'Lidos';

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
  String get adminFilterPinned => 'Fixados';

  @override
  String get adminFilterEmployers => 'Empregadores';

  @override
  String get adminFilterBanners => 'Banners';

  @override
  String get adminFilterBilling => 'Faturamento';

  @override
  String get adminFilterFeaturedEmployer => 'Empregador em destaque';

  @override
  String get adminFilterFeaturedJob => 'Vaga em destaque';

  @override
  String get adminFilterHomeBanner => 'Banner Home';

  @override
  String get adminEmptyAdjustFilters => 'Tente ajustar os filtros.';

  @override
  String get adminEmptyJobsTitle => 'Sem vagas';

  @override
  String get adminEmptyJobsSub => 'Nenhuma vaga corresponde.';

  @override
  String get adminEmptyUsersTitle => 'Sem usuários';

  @override
  String get adminEmptyMessagesTitle => 'Sem mensagens';

  @override
  String get adminEmptyMessagesSub => 'Nenhuma conversa para exibir.';

  @override
  String get adminEmptyReportsTitle => 'Sem denúncias';

  @override
  String get adminEmptyReportsSub => 'Sem denúncias para revisar.';

  @override
  String get adminEmptyBusinessesTitle => 'Sem empresas';

  @override
  String get adminEmptyBusinessesSub => 'Nenhuma empresa corresponde.';

  @override
  String get adminEmptyNotifsTitle => 'Sem notificações';

  @override
  String get adminEmptySubsTitle => 'Sem assinaturas';

  @override
  String get adminEmptySubsSub => 'Nenhuma assinatura corresponde.';

  @override
  String get adminEmptyLogsTitle => 'Sem registros';

  @override
  String get adminEmptyContentTitle => 'Sem conteúdo';

  @override
  String get adminEmptyInterviewsTitle => 'Sem entrevistas';

  @override
  String get adminEmptyInterviewsSub => 'Nenhuma entrevista corresponde.';

  @override
  String get adminEmptyFeedback => 'O feedback aparecerá aqui';

  @override
  String get adminEmptyMatchNotifs =>
      'As notificações de match aparecerão aqui';

  @override
  String get adminTitleMatchManagement => 'Gerenciamento de matches';

  @override
  String get adminTitleAdminLogs => 'Logs admin';

  @override
  String get adminTitleContentFeatured => 'Conteúdo / Destaque';

  @override
  String get adminTabFeedback => 'Feedback';

  @override
  String get adminTabStats => 'Estatísticas';

  @override
  String get adminSortNewest => 'Mais recentes';

  @override
  String get adminSortPriority => 'Prioridade';

  @override
  String get adminStatTotalMatches => 'Matches totais';

  @override
  String get adminStatAccepted => 'Aceitos';

  @override
  String get adminStatDenied => 'Negados';

  @override
  String get adminStatFeedbackCount => 'Feedback';

  @override
  String get adminStatMatchQuality => 'Pontuação de qualidade de match';

  @override
  String get adminStatTotal => 'Total';

  @override
  String get adminStatPendingCount => 'Pendentes';

  @override
  String get adminStatNotificationsCount => 'Notificações';

  @override
  String get adminStatActiveCount => 'Ativos';

  @override
  String get adminSectionPlatformSettings => 'Configurações da plataforma';

  @override
  String get adminSectionNotificationSettings =>
      'Configurações de notificações';

  @override
  String get adminSettingMaintenanceTitle => 'Modo de manutenção';

  @override
  String get adminSettingMaintenanceSub => 'Desabilitar acesso a todos';

  @override
  String get adminSettingNewRegsTitle => 'Novos cadastros';

  @override
  String get adminSettingNewRegsSub => 'Permitir novos cadastros';

  @override
  String get adminSettingFeaturedJobsTitle => 'Vagas em destaque';

  @override
  String get adminSettingFeaturedJobsSub => 'Mostrar vagas em destaque na home';

  @override
  String get adminSettingEmailNotifsTitle => 'Notificações por email';

  @override
  String get adminSettingEmailNotifsSub => 'Enviar alertas por email';

  @override
  String get adminSettingPushNotifsTitle => 'Notificações push';

  @override
  String get adminSettingPushNotifsSub => 'Enviar notificações push';

  @override
  String get adminActionSaveChanges => 'Salvar alterações';

  @override
  String get adminToastSettingsSaved => 'Configurações salvas';

  @override
  String get adminActionResolve => 'Resolver';

  @override
  String get adminActionDismiss => 'Ignorar';

  @override
  String get adminActionBanUser => 'Banir usuário';

  @override
  String get adminSearchUsersHint => 'Buscar nome, email, cargo, local...';

  @override
  String get adminMiscPositive => 'positivo';

  @override
  String adminCountUsers(int count) {
    return '$count usuários';
  }

  @override
  String adminCountNotifs(int count) {
    return '$count notificações';
  }

  @override
  String adminCountLogs(int count) {
    return '$count entradas de log';
  }

  @override
  String adminCountItems(int count) {
    return '$count itens';
  }

  @override
  String adminBadgeNRetried(int count) {
    return 'Tentado x$count';
  }

  @override
  String get adminStatusApplied => 'Candidatado';

  @override
  String get adminStatusUnderReview => 'Em análise';

  @override
  String get adminStatusShortlisted => 'Pré-selecionado';

  @override
  String get adminStatusInterview => 'Entrevista';

  @override
  String get adminStatusHired => 'Contratado';

  @override
  String get adminStatusRejected => 'Rejeitado';

  @override
  String get adminStatusOpen => 'Aberto';

  @override
  String get adminStatusInReview => 'Em revisão';

  @override
  String get adminStatusWaiting => 'Aguardando';

  @override
  String get adminPriorityHigh => 'Alta';

  @override
  String get adminPriorityMedium => 'Média';

  @override
  String get adminPriorityLow => 'Baixa';

  @override
  String get adminActionViewProfile => 'Ver perfil';

  @override
  String get adminActionVerify => 'Verificar';

  @override
  String get adminActionReview => 'Revisar';

  @override
  String get adminActionOverride => 'Substituir';

  @override
  String get adminEmptyCandidatesTitle => 'Sem candidatos';

  @override
  String get adminEmptyApplicationsTitle => 'Sem candidaturas';

  @override
  String get adminEmptyVerificationsTitle => 'Sem verificações pendentes';

  @override
  String get adminEmptyIssuesTitle => 'Sem ocorrências';

  @override
  String get adminEmptyAuditTitle => 'Sem registos de auditoria';

  @override
  String get adminSearchCandidatesTitle => 'Procurar candidatos';

  @override
  String get adminSearchCandidatesHint =>
      'Procurar por nome, e-mail ou função…';

  @override
  String get adminSearchAuditHint => 'Procurar no registo…';

  @override
  String get adminMiscUnknown => 'Desconhecido';

  @override
  String adminCountTotal(int count) {
    return '$count no total';
  }

  @override
  String adminBadgeNFlagged(int count) {
    return '$count sinalizados';
  }

  @override
  String adminBadgeNDaysWaiting(int count) {
    return '$count dias em espera';
  }

  @override
  String get adminPeriodWeek => 'Semana';

  @override
  String get adminPeriodMonth => 'Mês';

  @override
  String get adminPeriodYear => 'Ano';

  @override
  String get adminKpiNewCandidates => 'Novos candidatos';

  @override
  String get adminKpiNewBusinesses => 'Novas empresas';

  @override
  String get adminKpiJobsPosted => 'Vagas publicadas';

  @override
  String get adminSectionApplicationFunnel => 'Funil de candidaturas';

  @override
  String get adminSectionPlatformGrowth => 'Crescimento da plataforma';

  @override
  String get adminSectionPremiumConversion => 'Conversão premium';

  @override
  String get adminSectionTopLocations => 'Principais localizações';

  @override
  String get adminStatusViewed => 'Visualizado';

  @override
  String get adminWeekdayMon => 'Seg';

  @override
  String get adminWeekdayTue => 'Ter';

  @override
  String get adminWeekdayWed => 'Qua';

  @override
  String get adminWeekdayThu => 'Qui';

  @override
  String get adminWeekdayFri => 'Sex';

  @override
  String get adminWeekdaySat => 'Sáb';

  @override
  String get adminWeekdaySun => 'Dom';

  @override
  String get adminFilterReported => 'Reportados';

  @override
  String get adminFilterHidden => 'Ocultos';

  @override
  String get adminEmptyPostsTitle => 'Sem publicações';

  @override
  String get adminEmptyContentFilter =>
      'Nenhum conteúdo corresponde a este filtro.';

  @override
  String get adminBannerReportedReview => 'REPORTADO — REVISÃO NECESSÁRIA';

  @override
  String get adminBannerHiddenFromFeed => 'OCULTO DO FEED';

  @override
  String get adminActionInsights => 'Insights';

  @override
  String get adminActionHide => 'Ocultar';

  @override
  String get adminActionRemove => 'Remover';

  @override
  String get adminActionCancel => 'Cancelar';

  @override
  String get adminDialogRemovePostTitle => 'Remover publicação?';

  @override
  String get adminDialogRemovePostBody =>
      'Isto exclui permanentemente a publicação e os seus comentários. Esta ação não pode ser desfeita.';

  @override
  String get adminSnackbarReportCleared => 'Denúncia removida';

  @override
  String get adminSnackbarPostHidden => 'Publicação ocultada do feed';

  @override
  String get adminSnackbarPostRemoved => 'Publicação removida';

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
    return '$premium premium de $total no total';
  }
}
