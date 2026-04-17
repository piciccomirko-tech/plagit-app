// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Plagit';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Регистрация';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get createBusinessAccount => 'Создать бизнес-аккаунт';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get done => 'Готово';

  @override
  String get retry => 'Повторить';

  @override
  String get search => 'Поиск';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get apply => 'Откликнуться';

  @override
  String get clear => 'Очистить';

  @override
  String get clearAll => 'Очистить всё';

  @override
  String get edit => 'Изменить';

  @override
  String get delete => 'Удалить';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get home => 'Главная';

  @override
  String get jobs => 'Вакансии';

  @override
  String get messages => 'Сообщения';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get logout => 'Выйти';

  @override
  String get categoryAndRole => 'Категория и должность';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get subcategory => 'Подкатегория';

  @override
  String get role => 'Должность';

  @override
  String get recentSearches => 'Недавние запросы';

  @override
  String noResultsFor(String query) {
    return 'Нет результатов по запросу «$query»';
  }

  @override
  String get mostPopular => 'Самые популярные';

  @override
  String get allCategories => 'Все категории';

  @override
  String get selectVenueTypeAndRole =>
      'Выберите тип заведения и требуемую должность';

  @override
  String get selectCategoryAndRole => 'Выберите категорию и должность';

  @override
  String get businessDetails => 'Данные о компании';

  @override
  String get yourDetails => 'Ваши данные';

  @override
  String get companyName => 'Название компании';

  @override
  String get contactPerson => 'Контактное лицо';

  @override
  String get location => 'Местоположение';

  @override
  String get website => 'Website';

  @override
  String get fullName => 'Полное имя';

  @override
  String get yearsExperience => 'Стаж работы (лет)';

  @override
  String get languagesSpoken => 'Владение языками';

  @override
  String get jobType => 'Тип занятости';

  @override
  String get jobTypeFullTime => 'Полная занятость';

  @override
  String get jobTypePartTime => 'Неполная занятость';

  @override
  String get jobTypeTemporary => 'Временная работа';

  @override
  String get jobTypeFreelance => 'Фриланс';

  @override
  String get openToInternational => 'Рассматриваю международных кандидатов';

  @override
  String get passwordHint => 'Пароль (минимум 8 символов)';

  @override
  String get termsOfServiceNote =>
      'Создавая аккаунт, Вы соглашаетесь с Условиями использования и Политикой конфиденциальности.';

  @override
  String get networkError => 'Ошибка сети';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get loading => 'Загрузка…';

  @override
  String get errorGeneric =>
      'Произошла непредвиденная ошибка. Попробуйте ещё раз.';

  @override
  String get joinAsCandidate => 'Вход для кандидатов';

  @override
  String get joinAsBusiness => 'Вход для бизнеса';

  @override
  String get findYourNextRole =>
      'Найдите свою следующую работу в сфере гостеприимства';

  @override
  String get candidateLoginSubtitle =>
      'Общайтесь с ведущими работодателями Лондона, Дубая и не только.';

  @override
  String get businessLoginSubtitle =>
      'Находите лучших специалистов и развивайте свою команду.';

  @override
  String get rememberMe => 'Запомнить меня';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get lookingForStaff => 'Ищете персонал? ';

  @override
  String get lookingForJob => 'Ищете работу? ';

  @override
  String get switchToBusiness => 'Переключиться на бизнес';

  @override
  String get switchToCandidate => 'Переключиться на кандидата';

  @override
  String get createYourProfile =>
      'Создайте профиль, чтобы Вас заметили лучшие работодатели.';

  @override
  String get createBusinessProfile =>
      'Создайте бизнес-профиль и начните нанимать лучших специалистов индустрии гостеприимства.';

  @override
  String get locationCityCountry => 'Местоположение (город, страна)';

  @override
  String get termsAgreement =>
      'Создавая аккаунт, Вы соглашаетесь с Условиями использования и Политикой конфиденциальности.';

  @override
  String get searchHospitalityHint =>
      'Поиск по категории, подкатегории или должности…';

  @override
  String get mostCommonRoles => 'Самые востребованные должности';

  @override
  String get allRoles => 'Все должности';

  @override
  String suggestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подсказки',
      many: '$count подсказок',
      few: '$count подсказки',
      one: '$count подсказка',
    );
    return '$_temp0';
  }

  @override
  String subcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подкатегории',
      many: '$count подкатегорий',
      few: '$count подкатегории',
      one: '$count подкатегория',
    );
    return '$_temp0';
  }

  @override
  String rolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count должности',
      many: '$count должностей',
      few: '$count должности',
      one: '$count должность',
    );
    return '$_temp0';
  }

  @override
  String get kindCategory => 'Категория';

  @override
  String get kindSubcategory => 'Подкатегория';

  @override
  String get kindRole => 'Должность';

  @override
  String get resetPassword => 'Сбросить пароль';

  @override
  String get forgotPasswordSubtitle =>
      'Введите электронную почту, и мы отправим ссылку для сброса пароля.';

  @override
  String get sendResetLink => 'Отправить ссылку';

  @override
  String get resetEmailSent =>
      'Если аккаунт с такой почтой существует, ссылка для сброса уже отправлена.';

  @override
  String get profileSetupTitle => 'Заполните профиль';

  @override
  String get profileSetupSubtitle => 'Полный профиль замечают быстрее.';

  @override
  String get uploadPhoto => 'Загрузить фото';

  @override
  String get uploadCV => 'Загрузить резюме';

  @override
  String get skipForNow => 'Пропустить';

  @override
  String get finish => 'Завершить';

  @override
  String get noInternet => 'Нет подключения к интернету. Проверьте сеть.';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get emptyJobs => 'Вакансий пока нет';

  @override
  String get emptyApplications => 'Откликов пока нет';

  @override
  String get emptyMessages => 'Сообщений пока нет';

  @override
  String get emptyNotifications => 'Все прочитано';

  @override
  String get onboardingRoleTitle => 'Какую должность Вы ищете?';

  @override
  String get onboardingRoleSubtitle => 'Выберите все подходящие варианты';

  @override
  String get onboardingExperienceTitle => 'Какой у Вас опыт?';

  @override
  String get onboardingLocationTitle => 'Где Вы находитесь?';

  @override
  String get onboardingLocationHint => 'Введите город или индекс';

  @override
  String get useMyCurrentLocation => 'Использовать моё текущее местоположение';

  @override
  String get onboardingAvailabilityTitle => 'Что Вы ищете?';

  @override
  String get finishSetup => 'Завершить настройку';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String get findJobs => 'Найти работу';

  @override
  String get applications => 'Отклики';

  @override
  String get community => 'Сообщество';

  @override
  String get recommendedForYou => 'Рекомендуем Вам';

  @override
  String get seeAll => 'Смотреть все';

  @override
  String get searchJobsHint => 'Поиск вакансий, должностей, городов…';

  @override
  String get searchJobs => 'Поиск вакансий';

  @override
  String get postedJob => 'Опубликовано';

  @override
  String get applyNow => 'Откликнуться';

  @override
  String get applied => 'Откликнулся';

  @override
  String get saveJob => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get jobDescription => 'Описание вакансии';

  @override
  String get requirements => 'Требования';

  @override
  String get benefits => 'Бонусы';

  @override
  String get salary => 'Зарплата';

  @override
  String get contract => 'Контракт';

  @override
  String get schedule => 'График';

  @override
  String get viewCompany => 'Посмотреть компанию';

  @override
  String get interview => 'Собеседование';

  @override
  String get interviews => 'Собеседования';

  @override
  String get notifications => 'Уведомления';

  @override
  String get matches => 'Совпадения';

  @override
  String get quickPlug => 'Quick Plug';

  @override
  String get discover => 'Обзор';

  @override
  String get shortlist => 'Шортлист';

  @override
  String get message => 'Сообщение';

  @override
  String get messageCandidate => 'Написать';

  @override
  String get nextInterview => 'Собеседование';

  @override
  String get loadingDashboard => 'Загрузка панели…';

  @override
  String get tryAgainCta => 'Повторить';

  @override
  String get careerDashboard => 'ПАНЕЛЬ КАРЬЕРЫ';

  @override
  String get yourNextInterview => 'Ваше следующее собеседование\nуже назначено';

  @override
  String get yourCareerTakingOff => 'Ваша карьера\nнабирает обороты';

  @override
  String get yourCareerOnTheMove => 'Ваша карьера\nдвижется вперёд';

  @override
  String get yourJourneyStartsHere => 'Ваш путь\nначинается';

  @override
  String get applyFirstJob => 'Откликнитесь на первую вакансию, чтобы начать';

  @override
  String get interviewComingUp => 'Скоро собеседование';

  @override
  String get unlockPlagitPremium => 'Откройте Plagit Premium';

  @override
  String get premiumSubtitle =>
      'Выделяйтесь среди лучших заведений — получайте отклики быстрее';

  @override
  String get premiumActive => 'Premium активен';

  @override
  String get premiumActiveSubtitle =>
      'Приоритетная видимость включена · Управление тарифом';

  @override
  String get noJobsFound => 'По Вашему запросу вакансий не найдено';

  @override
  String get noApplicationsYet => 'Откликов пока нет';

  @override
  String get startApplying => 'Начните просматривать вакансии и откликаться';

  @override
  String get noMessagesYet => 'Сообщений пока нет';

  @override
  String get allCaughtUp => 'Всё прочитано';

  @override
  String get noNotificationsYet => 'Уведомлений пока нет';

  @override
  String get about => 'О себе';

  @override
  String get experience => 'Опыт';

  @override
  String get skills => 'Навыки';

  @override
  String get languages => 'Языки';

  @override
  String get availability => 'Доступность';

  @override
  String get verified => 'Проверено';

  @override
  String get totalViews => 'Всего просмотров';

  @override
  String get verifiedVenuePrefix => 'Проверено';

  @override
  String get notVerified => 'Не проверено';

  @override
  String get pendingReview => 'На рассмотрении';

  @override
  String get viewProfile => 'Посмотреть профиль';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get share => 'Поделиться';

  @override
  String get report => 'Пожаловаться';

  @override
  String get block => 'Заблокировать';

  @override
  String get typeMessage => 'Введите сообщение…';

  @override
  String get send => 'Отправить';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get now => 'сейчас';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мин назад',
      many: '$count мин назад',
      few: '$count мин назад',
      one: '$count мин назад',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ч назад',
      many: '$count ч назад',
      few: '$count ч назад',
      one: '$count ч назад',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count д назад',
      many: '$count д назад',
      few: '$count д назад',
      one: '$count д назад',
    );
    return '$_temp0';
  }

  @override
  String get filters => 'Фильтры';

  @override
  String get refineSearch => 'Уточнить поиск';

  @override
  String get distance => 'Расстояние';

  @override
  String get applyFilters => 'Применить фильтры';

  @override
  String get reset => 'Сбросить';

  @override
  String noResultsTitle(String query) {
    return 'Нет результатов по запросу «$query»';
  }

  @override
  String get noResultsSubtitle => 'Попробуйте другое слово или очистите поиск.';

  @override
  String get recentSearchesEmptyTitle => 'Недавних запросов нет';

  @override
  String get recentSearchesEmptyHint => 'Ваши недавние поиски появятся здесь';

  @override
  String get allJobs => 'Все вакансии';

  @override
  String get nearby => 'Рядом';

  @override
  String get saved2 => 'Сохранённые';

  @override
  String get remote => 'Удалённо';

  @override
  String get inPerson => 'Очно';

  @override
  String get aboutTheJob => 'О вакансии';

  @override
  String get aboutCompany => 'О компании';

  @override
  String get applyForJob => 'Откликнуться на вакансию';

  @override
  String get unsaveJob => 'Убрать';

  @override
  String get noJobsNearby => 'Вакансий поблизости нет';

  @override
  String get noSavedJobs => 'Сохранённых вакансий нет';

  @override
  String get adjustFilters => 'Измените фильтры, чтобы увидеть больше вакансий';

  @override
  String get fullTime => 'Полная занятость';

  @override
  String get partTime => 'Неполная занятость';

  @override
  String get temporary => 'Временная работа';

  @override
  String get freelance => 'Фриланс';

  @override
  String postedAgo(String time) {
    return 'Опубликовано $time';
  }

  @override
  String kmAway(String km) {
    return '$km км от Вас';
  }

  @override
  String get jobDetails => 'Детали вакансии';

  @override
  String get aboutThisRole => 'Об этой должности';

  @override
  String get aboutTheBusiness => 'О компании';

  @override
  String get urgentHiring => 'Срочный найм';

  @override
  String get distanceRadius => 'Радиус поиска';

  @override
  String get contractType => 'Тип контракта';

  @override
  String get shiftType => 'Тип смены';

  @override
  String get all => 'Все';

  @override
  String get casual => 'Подработка';

  @override
  String get seasonal => 'Сезонная работа';

  @override
  String get morning => 'Утро';

  @override
  String get afternoon => 'День';

  @override
  String get evening => 'Вечер';

  @override
  String get night => 'Ночь';

  @override
  String get startDate => 'Дата начала';

  @override
  String get shiftHours => 'Часы смены';

  @override
  String get category => 'Категория';

  @override
  String get venueType => 'Тип заведения';

  @override
  String get employment => 'Занятость';

  @override
  String get pay => 'Оплата';

  @override
  String get duration => 'Продолжительность';

  @override
  String get weeklyHours => 'Часов в неделю';

  @override
  String get businessLocation => 'Адрес компании';

  @override
  String get jobViews => 'Просмотры вакансии';

  @override
  String positions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count позиции',
      many: '$count позиций',
      few: '$count позиции',
      one: '$count позиция',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца',
      many: '$count месяцев',
      few: '$count месяца',
      one: '$count месяц',
    );
    return '$_temp0';
  }

  @override
  String get myApplications => 'Мои отклики';

  @override
  String get active => 'Активно';

  @override
  String get interviewStatus => 'Собеседование';

  @override
  String get rejected => 'Отклонено';

  @override
  String get offer => 'Оффер';

  @override
  String appliedOn(String date) {
    return 'Отклик отправлен $date';
  }

  @override
  String get viewJob => 'Открыть';

  @override
  String get withdraw => 'Отозвать отклик';

  @override
  String get applicationStatus => 'Статус отклика';

  @override
  String get noConversations => 'Диалогов пока нет';

  @override
  String get startConversation => 'Ответьте на вакансию, чтобы начать общение';

  @override
  String get online => 'В сети';

  @override
  String get offline => 'Не в сети';

  @override
  String lastSeen(String time) {
    return 'Был(а) в сети $time';
  }

  @override
  String get newNotification => 'Новое';

  @override
  String get markAllRead => 'Отметить все как прочитанные';

  @override
  String get yourProfile => 'Ваш профиль';

  @override
  String completionPercent(int percent) {
    return '$percent% заполнено';
  }

  @override
  String get personalDetails => 'Личные данные';

  @override
  String get phone => 'Телефон';

  @override
  String get bio => 'Bio';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get addCV => 'Добавить резюме';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get subscription => 'Подписка';

  @override
  String get support => 'Поддержка';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get terms => 'Условия';

  @override
  String get applicationDetails => 'Детали отклика';

  @override
  String get timeline => 'Хронология';

  @override
  String get submitted => 'Отправлено';

  @override
  String get underReview => 'На рассмотрении';

  @override
  String get interviewScheduled => 'Собеседование назначено';

  @override
  String get offerExtended => 'Оффер получен';

  @override
  String get withdrawApp => 'Отозвать отклик';

  @override
  String get withdrawConfirm => 'Вы уверены, что хотите отозвать отклик?';

  @override
  String get applicationWithdrawn => 'Отклик отозван';

  @override
  String get statusApplied => 'Отправлен';

  @override
  String get statusInReview => 'Проверка';

  @override
  String get statusInterview => 'Интервью';

  @override
  String get statusHired => 'Принят(а)';

  @override
  String get statusClosed => 'Закрыт';

  @override
  String get statusRejected => 'Отклонён';

  @override
  String get statusOffer => 'Оффер';

  @override
  String get messagesSearch => 'Поиск по сообщениям…';

  @override
  String get noMessagesTitle => 'Сообщений пока нет';

  @override
  String get noMessagesSubtitle => 'Ответьте на вакансию, чтобы начать общение';

  @override
  String get youOnline => 'Вы в сети';

  @override
  String get noNotificationsTitle => 'Уведомлений пока нет';

  @override
  String get noNotificationsSubtitle => 'Мы сообщим, когда появятся новости';

  @override
  String get today2 => 'Сегодня';

  @override
  String get earlier => 'Ранее';

  @override
  String get completeYourProfile => 'Заполните профиль';

  @override
  String get profileCompletion => 'Заполнение профиля';

  @override
  String get personalInfo => 'Личная информация';

  @override
  String get professional => 'Профессиональное';

  @override
  String get preferences => 'Предпочтения';

  @override
  String get documents => 'Документы';

  @override
  String get myCV => 'Моё резюме';

  @override
  String get premium => 'Premium';

  @override
  String get addLanguages => 'Добавить языки';

  @override
  String get addExperience => 'Добавить опыт';

  @override
  String get addAvailability => 'Добавить доступность';

  @override
  String get matchesTitle => 'Ваши совпадения';

  @override
  String get noMatchesTitle => 'Совпадений пока нет';

  @override
  String get noMatchesSubtitle =>
      'Продолжайте откликаться — совпадения появятся здесь';

  @override
  String get interestedBusinesses => 'Заинтересованные компании';

  @override
  String get accept => 'Принять';

  @override
  String get decline => 'Отклонить';

  @override
  String get newMatch => 'Новое совпадение';

  @override
  String get quickPlugTitle => 'Quick Plug';

  @override
  String get quickPlugEmpty => 'Новых компаний пока нет';

  @override
  String get quickPlugSubtitle =>
      'Загляните позже — появятся свежие возможности';

  @override
  String get uploadYourCV => 'Загрузите резюме';

  @override
  String get cvSubtitle =>
      'Добавьте резюме, чтобы откликаться быстрее и выделяться';

  @override
  String get chooseFile => 'Выбрать файл';

  @override
  String get removeCV => 'Удалить резюме';

  @override
  String get noCVUploaded => 'Резюме ещё не загружено';

  @override
  String get discoverCompanies => 'Откройте компании';

  @override
  String get exploreSubtitle =>
      'Изучайте ведущие компании индустрии гостеприимства';

  @override
  String get follow => 'Подписаться';

  @override
  String get following => 'Подписки';

  @override
  String get view => 'Смотреть';

  @override
  String get selectLanguages => 'Выберите языки';

  @override
  String selectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get allLanguages => 'Все языки';

  @override
  String get uploadCVBig =>
      'Загрузите резюме, чтобы автоматически заполнить профиль и сэкономить время.';

  @override
  String get supportedFormats => 'Поддерживаемые форматы: PDF, DOC, DOCX';

  @override
  String get fillManually => 'Заполнить вручную';

  @override
  String get fillManuallySubtitle =>
      'Введите данные самостоятельно и заполните профиль шаг за шагом.';

  @override
  String get photoUploadSoon =>
      'Загрузка фото скоро появится — используйте профессиональный аватар.';

  @override
  String get yourCV => 'Ваше резюме';

  @override
  String get aboutYou => 'О Вас';

  @override
  String get optional => 'Необязательно';

  @override
  String get completeProfile => 'Завершить профиль';

  @override
  String get openToRelocation => 'Готов(а) к переезду';

  @override
  String get matchLabel => 'Match';

  @override
  String get accepted => 'Принято';

  @override
  String get deny => 'Отклонить';

  @override
  String get featured => 'Избранное';

  @override
  String get reviewYourProfile => 'Проверьте свой профиль';

  @override
  String get nothingSavedYet =>
      'Ничего не будет сохранено до Вашего подтверждения.';

  @override
  String get editAnyField =>
      'Вы можете отредактировать любое поле перед сохранением.';

  @override
  String get saveToProfile => 'Сохранить в профиль';

  @override
  String get findCompanies => 'Найти компании';

  @override
  String get mapView => 'Карта';

  @override
  String get mapComingSoon => 'Просмотр карты скоро появится.';

  @override
  String get noCompaniesFound => 'Компании не найдены';

  @override
  String get tryWiderRadius =>
      'Попробуйте увеличить радиус или выбрать другую категорию.';

  @override
  String get verifiedOnly => 'Только проверенные';

  @override
  String get resetFilters => 'Сбросить фильтры';

  @override
  String get available => 'Доступен';

  @override
  String lookingFor(String role) {
    return 'Ищет: $role';
  }

  @override
  String get boostMyProfile => 'Продвинуть профиль';

  @override
  String get openToRelocationTravel => 'Готов(а) к переезду / командировкам';

  @override
  String get tellEmployersAboutYourself => 'Расскажите работодателям о себе…';

  @override
  String get profileUpdated => 'Профиль обновлён';

  @override
  String get contractPreference => 'Предпочтения по контракту';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get languagePickerSoon => 'Выбор языка скоро появится';

  @override
  String get selectCategoryRoleShort => 'Выберите категорию и должность';

  @override
  String get cvUploadSoon => 'Загрузка резюме скоро появится';

  @override
  String get restorePurchasesSoon => 'Восстановление покупок скоро появится';

  @override
  String get photoUploadShort => 'Загрузка фото скоро появится';

  @override
  String get hireBestTalent =>
      'Нанимайте лучших специалистов индустрии гостеприимства';

  @override
  String get businessLoginSub =>
      'Публикуйте вакансии и находите проверенных кандидатов.';

  @override
  String get lookingForWork => 'Ищете работу? ';

  @override
  String get postJob => 'Опубликовать вакансию';

  @override
  String get editJob => 'Редактировать';

  @override
  String get jobTitle => 'Название вакансии';

  @override
  String get jobDescription2 => 'Описание вакансии';

  @override
  String get publish => 'Опубликовать';

  @override
  String get saveDraft => 'Сохранить черновик';

  @override
  String get applicantsTitle => 'Кандидаты';

  @override
  String get newApplicants => 'Новые отклики';

  @override
  String get noApplicantsYet => 'Откликов пока нет';

  @override
  String get noApplicantsSubtitle =>
      'Кандидаты появятся здесь, как только откликнутся.';

  @override
  String get scheduleInterview => 'Назначить собеседование';

  @override
  String get sendInvite => 'Отправить приглашение';

  @override
  String get interviewSent => 'Приглашение на собеседование отправлено';

  @override
  String get rejectCandidate => 'Отклонить';

  @override
  String get shortlistCandidate => 'В шортлист';

  @override
  String get hiringDashboard => 'ПАНЕЛЬ НАЙМА';

  @override
  String get yourPipelineActive => 'Ваша воронка\nактивна';

  @override
  String get postJobToStart => 'Опубликуйте первую вакансию';

  @override
  String reviewApplicants(int count) {
    return 'Рассмотреть новых кандидатов: $count';
  }

  @override
  String replyMessages(int count) {
    return 'Ответить на непрочитанные сообщения: $count';
  }

  @override
  String get interviews2 => 'Собеседования';

  @override
  String get businessProfile => 'Профиль компании';

  @override
  String get venueGallery => 'Галерея заведения';

  @override
  String get addPhotos => 'Добавить фото';

  @override
  String get businessName => 'Название компании';

  @override
  String get venueTypeLabel => 'Тип заведения';

  @override
  String selectedItems(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get hiringProgress => 'Прогресс найма';

  @override
  String get unlockBusinessPremium => 'Откройте Business Premium';

  @override
  String get businessPremiumSubtitle =>
      'Получите приоритетный доступ к лучшим кандидатам';

  @override
  String get scheduleFromApplicants => 'Назначить из откликов';

  @override
  String get recentApplicants => 'Недавние кандидаты';

  @override
  String get viewAll => 'Смотреть все ›';

  @override
  String get recentActivity => 'Недавняя активность';

  @override
  String get candidatePipeline => 'Воронка кандидатов';

  @override
  String get allApplicants => 'Все кандидаты';

  @override
  String get searchCandidates => 'Поиск кандидатов, вакансий, собеседований...';

  @override
  String get thisWeek => 'На этой неделе';

  @override
  String get thisMonth => 'В этом месяце';

  @override
  String get allTime => 'За всё время';

  @override
  String get post => 'Опубликовать';

  @override
  String get candidates => 'Кандидаты';

  @override
  String get applicantDetail => 'Данные кандидата';

  @override
  String get candidateProfile => 'Профиль кандидата';

  @override
  String get shortlistTitle => 'Шортлист';

  @override
  String get noShortlistedCandidates => 'В шортлисте пока нет кандидатов';

  @override
  String get shortlistEmpty =>
      'Кандидаты, которых Вы добавите в шортлист, появятся здесь';

  @override
  String get removeFromShortlist => 'Убрать из шортлиста';

  @override
  String get viewMessages => 'Смотреть сообщения';

  @override
  String get manageJobs => 'Управление вакансиями';

  @override
  String get yourJobs => 'Ваши вакансии';

  @override
  String get noJobsPosted => 'Вакансий ещё не опубликовано';

  @override
  String get noJobsPostedSubtitle =>
      'Опубликуйте первую вакансию, чтобы начать нанимать';

  @override
  String get draftJobs => 'Черновики';

  @override
  String get activeJobs => 'Активные';

  @override
  String get expiredJobs => 'Истёкшие';

  @override
  String get closedJobs => 'Закрытые';

  @override
  String get createJob => 'Создать вакансию';

  @override
  String get jobDetailsTitle => 'Детали вакансии';

  @override
  String get salaryRange => 'Диапазон зарплаты';

  @override
  String get currency => 'Валюта';

  @override
  String get monthly => 'В месяц';

  @override
  String get annual => 'В год';

  @override
  String get hourly => 'В час';

  @override
  String get minSalary => 'Мин.';

  @override
  String get maxSalary => 'Макс.';

  @override
  String get perks => 'Бонусы';

  @override
  String get addPerk => 'Добавить бонус';

  @override
  String get remove => 'Удалить';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get publishJob => 'Опубликовать вакансию';

  @override
  String get jobPublished => 'Вакансия опубликована';

  @override
  String get jobUpdated => 'Вакансия обновлена';

  @override
  String get jobSavedDraft => 'Сохранено как черновик';

  @override
  String get fillRequired => 'Пожалуйста, заполните обязательные поля';

  @override
  String get jobUrgent => 'Отметить как срочную';

  @override
  String get addAtLeastOne => 'Добавьте хотя бы одно требование';

  @override
  String get createUpdate => 'Создать новость';

  @override
  String get shareCompanyNews => 'Поделитесь новостями компании';

  @override
  String get addStory => 'Добавить историю';

  @override
  String get showWorkplace => 'Покажите своё рабочее место';

  @override
  String get viewShortlist => 'Смотреть шортлист';

  @override
  String get yourSavedCandidates => 'Ваши сохранённые кандидаты';

  @override
  String get inviteCandidate => 'Пригласить кандидата';

  @override
  String get reachOutDirectly => 'Связаться напрямую';

  @override
  String activeJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активных вакансий',
      many: '$count активных вакансий',
      few: '$count активные вакансии',
      one: '$count активная вакансия',
    );
    return '$_temp0';
  }

  @override
  String get employmentType => 'Тип занятости';

  @override
  String get requiredRole => 'Требуемая должность';

  @override
  String get selectCategoryRole2 => 'Выберите категорию и должность';

  @override
  String get hiresNeeded => 'Требуется сотрудников';

  @override
  String get compensation => 'Вознаграждение';

  @override
  String get useSalaryRange => 'Использовать диапазон зарплаты';

  @override
  String get contractDuration => 'Срок контракта';

  @override
  String get limitReached => 'Лимит исчерпан';

  @override
  String get upgradePlan => 'Улучшить тариф';

  @override
  String usingXofY(int used, int total) {
    return 'Вы используете $used из $total публикаций.';
  }

  @override
  String get businessInterviewsTitle => 'Собеседования';

  @override
  String get noInterviewsYet => 'Собеседований пока нет';

  @override
  String get scheduleFirstInterview =>
      'Назначьте первое собеседование с кандидатом';

  @override
  String get sendInterviewInvite => 'Отправить приглашение на собеседование';

  @override
  String get interviewSentTitle => 'Приглашение отправлено!';

  @override
  String get interviewSentSubtitle => 'Кандидат получил уведомление.';

  @override
  String get scheduleInterviewTitle => 'Назначить собеседование';

  @override
  String get interviewType => 'Тип собеседования';

  @override
  String get inPersonInterview => 'Очно';

  @override
  String get videoCallInterview => 'Видеозвонок';

  @override
  String get phoneCallInterview => 'Телефонный звонок';

  @override
  String get interviewDate => 'Дата';

  @override
  String get interviewTime => 'Время';

  @override
  String get interviewLocation => 'Место';

  @override
  String get interviewNotes => 'Заметки';

  @override
  String get optionalLabel => 'Необязательно';

  @override
  String get sendInviteCta => 'Отправить приглашение';

  @override
  String messagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сообщения',
      many: '$count сообщений',
      few: '$count сообщения',
      one: '$count сообщение',
    );
    return '$_temp0';
  }

  @override
  String get noNewMessages => 'Новых сообщений нет';

  @override
  String get subscriptionTitle => 'Подписка';

  @override
  String get currentPlan => 'Текущий тариф';

  @override
  String get manage => 'Управлять';

  @override
  String get upgrade => 'Улучшить';

  @override
  String get renewalDate => 'Дата продления';

  @override
  String get nearbyTalent => 'Специалисты рядом';

  @override
  String get searchNearby => 'Поиск рядом';

  @override
  String get communityTitle => 'Сообщество';

  @override
  String get createPost => 'Создать публикацию';

  @override
  String get insights => 'Аналитика';

  @override
  String get viewsLabel => 'Просмотры';

  @override
  String get applicationsLabel => 'Отклики';

  @override
  String get conversionRate => 'Конверсия';

  @override
  String get topPerformingJob => 'Самая эффективная вакансия';

  @override
  String get viewAllSimple => 'Смотреть все';

  @override
  String get viewAllApplicantsForJob => 'Смотреть всех кандидатов по вакансии';

  @override
  String get noUpcomingInterviews => 'Предстоящих собеседований нет';

  @override
  String get noActivityYet => 'Активности пока нет';

  @override
  String get noResultsFound => 'Ничего не найдено';

  @override
  String get renewsAutomatically => 'Продлевается автоматически';

  @override
  String get plagitBusinessPlans => 'Тарифы Plagit Business';

  @override
  String get scaleYourHiringSubtitle =>
      'Масштабируйте найм с подходящим тарифом.';

  @override
  String get yearly => 'Годовой';

  @override
  String get saveWithAnnualBilling => 'Экономьте больше при годовой оплате';

  @override
  String get chooseYourPlanSubtitle =>
      'Выберите тариф под Ваши задачи по найму.';

  @override
  String continueWithPlan(String plan) {
    return 'Продолжить с $plan';
  }

  @override
  String get subscriptionAutoRenewNote =>
      'Подписка продлевается автоматически. Отмена в Настройках.';

  @override
  String get purchaseFlowComingSoon => 'Оплата скоро появится';

  @override
  String get applicant => 'Кандидат';

  @override
  String get applicantNotFound => 'Кандидат не найден';

  @override
  String get cvViewerComingSoon => 'Просмотр резюме скоро появится';

  @override
  String get viewCV => 'Открыть резюме';

  @override
  String get application => 'Отклик';

  @override
  String get messagingComingSoon => 'Сообщения скоро появятся';

  @override
  String get interviewConfirmed => 'Собеседование подтверждено';

  @override
  String get interviewMarkedCompleted =>
      'Собеседование отмечено как завершённое';

  @override
  String get cancelInterviewConfirm =>
      'Вы уверены, что хотите отменить собеседование?';

  @override
  String get yesCancel => 'Да, отменить';

  @override
  String get interviewNotFound => 'Собеседование не найдено';

  @override
  String get openingMeetingLink => 'Открываем ссылку на встречу...';

  @override
  String get rescheduleComingSoon => 'Перенос скоро появится';

  @override
  String get notesFeatureComingSoon => 'Заметки скоро появятся';

  @override
  String get candidateMarkedHired => 'Кандидат отмечен как нанятый!';

  @override
  String get feedbackComingSoon => 'Обратная связь скоро появится';

  @override
  String get googleMapsComingSoon => 'Интеграция с Google Maps скоро появится';

  @override
  String get noCandidatesNearby => 'Кандидатов рядом нет';

  @override
  String get tryExpandingRadius => 'Попробуйте увеличить радиус поиска.';

  @override
  String get candidate => 'Кандидат';

  @override
  String get forOpenPosition => 'На открытую позицию';

  @override
  String get dateAndTimeUpper => 'ДАТА И ВРЕМЯ';

  @override
  String get interviewTypeUpper => 'ТИП СОБЕСЕДОВАНИЯ';

  @override
  String get timezoneUpper => 'ЧАСОВОЙ ПОЯС';

  @override
  String get highlights => 'Ключевое';

  @override
  String get cvNotAvailable => 'Резюме недоступно';

  @override
  String get cvWillAppearHere => 'Появится здесь после загрузки';

  @override
  String get seenEveryone => 'Вы просмотрели всех';

  @override
  String get checkBackForCandidates =>
      'Загляните позже — будут новые кандидаты.';

  @override
  String get dailyLimitReached => 'Дневной лимит исчерпан';

  @override
  String get upgradeForUnlimitedSwipes =>
      'Улучшите тариф для безлимитных свайпов.';

  @override
  String get distanceUpper => 'РАССТОЯНИЕ';

  @override
  String get inviteToInterview => 'Пригласить на собеседование';

  @override
  String get details => 'Подробнее';

  @override
  String get shortlistedSuccessfully => 'Добавлен(а) в шортлист';

  @override
  String get tabDashboard => 'Панель';

  @override
  String get tabCandidates => 'Кандидаты';

  @override
  String get tabActivity => 'Активность';

  @override
  String get statusPosted => 'Опубликовано';

  @override
  String get statusApplicants => 'Отклики';

  @override
  String get statusInterviewsShort => 'Собеседования';

  @override
  String get statusHiredShort => 'Нанято';

  @override
  String get jobLiveVisible => 'Ваша вакансия опубликована и видна';

  @override
  String get postJobShort => 'Опубликовать';

  @override
  String get messagesTitle => 'Сообщения';

  @override
  String get online2 => 'В сети';

  @override
  String get candidateUpper => 'КАНДИДАТ';

  @override
  String get searchConversationsHint =>
      'Поиск диалогов, кандидатов, должностей…';

  @override
  String get filterUnread => 'Непрочитанные';

  @override
  String get filterAll => 'Все';

  @override
  String get whenCandidatesMessage =>
      'Когда кандидаты напишут Вам, диалоги появятся здесь.';

  @override
  String get trySwitchingFilter => 'Попробуйте другой фильтр.';

  @override
  String get reply => 'Ответить';

  @override
  String get selectItems => 'Выбрать';

  @override
  String countSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get deleteConversation => 'Удалить диалог?';

  @override
  String get deleteAllConversations => 'Удалить все диалоги?';

  @override
  String get deleteSelectedNote =>
      'Выбранные чаты будут удалены из Вашей папки «Входящие». У кандидата копия сохранится.';

  @override
  String get deleteAll => 'Удалить все';

  @override
  String get selectConversations => 'Выберите диалоги';

  @override
  String get feedTab => 'Feed';

  @override
  String get myPostsTab => 'Мои публикации';

  @override
  String get savedTab => 'Сохранённые';

  @override
  String postingAs(String name) {
    return 'Публикуется как $name';
  }

  @override
  String get noPostsYet => 'Вы ещё ничего не опубликовали';

  @override
  String get nothingHereYet => 'Здесь пока пусто';

  @override
  String get shareVenueUpdate =>
      'Поделитесь новостями из Вашего заведения, чтобы строить присутствие в сообществе.';

  @override
  String get communityPostsAppearHere =>
      'Публикации сообщества появятся здесь.';

  @override
  String get createFirstPost => 'Создать первую публикацию';

  @override
  String get yourPostUpper => 'ВАША ПУБЛИКАЦИЯ';

  @override
  String get businessLabel => 'Бизнес';

  @override
  String get profileNotAvailable => 'Профиль недоступен';

  @override
  String get companyProfile => 'Профиль компании';

  @override
  String get premiumVenue => 'Premium-заведение';

  @override
  String get businessDetailsTitle => 'Данные о компании';

  @override
  String get businessNameLabel => 'Название компании';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get locationLabel => 'Местоположение';

  @override
  String get verificationLabel => 'Верификация';

  @override
  String get pendingLabel => 'В ожидании';

  @override
  String get notSet => 'Не указано';

  @override
  String get contactLabel => 'Контакт';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get companyNameField => 'Название компании';

  @override
  String get phoneField => 'Телефон';

  @override
  String get locationField => 'Местоположение';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutTitle => 'Выйти?';

  @override
  String get signOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String activeCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активно',
      many: '$count активно',
      few: '$count активно',
      one: '$count активно',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count новых на этой неделе',
      many: '$count новых на этой неделе',
      few: '$count новых на этой неделе',
      one: '$count новый на этой неделе',
    );
    return '$_temp0';
  }

  @override
  String get jobStatusActive => 'Активна';

  @override
  String get jobStatusPaused => 'На паузе';

  @override
  String get jobStatusClosed => 'Закрыта';

  @override
  String get jobStatusDraft => 'Черновик';

  @override
  String get contractCasual => 'Подработка';

  @override
  String get planBasic => 'Basic';

  @override
  String get planPro => 'Pro';

  @override
  String get planPremium => 'Premium';

  @override
  String get bestForMaxVisibility => 'Идеально для максимальной видимости';

  @override
  String saveDollarsPerYear(String currency, String amount) {
    return 'Экономия $currency$amount в год';
  }

  @override
  String get planBasicFeature1 => 'До 3 вакансий';

  @override
  String get planBasicFeature2 => 'Просмотр профилей кандидатов';

  @override
  String get planBasicFeature3 => 'Базовый поиск кандидатов';

  @override
  String get planBasicFeature4 => 'Поддержка по email';

  @override
  String get planProFeature1 => 'До 10 вакансий';

  @override
  String get planProFeature2 => 'Расширенный поиск кандидатов';

  @override
  String get planProFeature3 => 'Приоритетная сортировка откликов';

  @override
  String get planProFeature4 => 'Доступ к Quick Plug';

  @override
  String get planProFeature5 => 'Чат-поддержка';

  @override
  String get planPremiumFeature1 => 'Безлимит вакансий';

  @override
  String get planPremiumFeature2 => 'Избранные вакансии';

  @override
  String get planPremiumFeature3 => 'Расширенная аналитика';

  @override
  String get planPremiumFeature4 => 'Безлимит Quick Plug';

  @override
  String get planPremiumFeature5 => 'Приоритетный подбор кандидатов';

  @override
  String get planPremiumFeature6 => 'Персональный менеджер';

  @override
  String get currentSelectionCheck => 'Текущий выбор ✓';

  @override
  String selectPlanName(String plan) {
    return 'Выбрать $plan';
  }

  @override
  String get perYear => '/год';

  @override
  String get perMonth => '/мес.';

  @override
  String get jobTitleHintExample => 'напр. Шеф-повар';

  @override
  String get locationHintExample => 'напр. Дубай, ОАЭ';

  @override
  String annualSalaryLabel(String currency) {
    return 'Годовая зарплата ($currency)';
  }

  @override
  String monthlyPayLabel(String currency) {
    return 'Зарплата в месяц ($currency)';
  }

  @override
  String hourlyRateLabel(String currency) {
    return 'Ставка в час ($currency)';
  }

  @override
  String minSalaryLabel(String currency) {
    return 'Мин. ($currency)';
  }

  @override
  String maxSalaryLabel(String currency) {
    return 'Макс. ($currency)';
  }

  @override
  String get hoursPerWeekLabel => 'Часов / неделю';

  @override
  String get expectedHoursWeekLabel =>
      'Ожидаемые часы / неделю (необязательно)';

  @override
  String get bonusTipsLabel => 'Бонус / чаевые (необязательно)';

  @override
  String get bonusTipsHint => 'напр. чаевые и сервисный сбор';

  @override
  String get housingIncludedLabel => 'Проживание включено';

  @override
  String get travelIncludedLabel => 'Проезд включён';

  @override
  String get overtimeAvailableLabel => 'Возможны переработки';

  @override
  String get flexibleScheduleLabel => 'Гибкий график';

  @override
  String get weekendShiftsLabel => 'Смены по выходным';

  @override
  String get describeRoleHint =>
      'Опишите должность, обязанности и что делает эту работу особенной...';

  @override
  String get requirementsHint => 'Необходимые навыки, опыт, сертификаты...';

  @override
  String previewPrefix(String text) {
    return 'Предпросмотр: $text';
  }

  @override
  String monthsShort(int count) {
    return '$count мес.';
  }

  @override
  String get roleAll => 'Все';

  @override
  String get roleChef => 'Шеф-повар';

  @override
  String get roleWaiter => 'Официант';

  @override
  String get roleBartender => 'Бармен';

  @override
  String get roleHost => 'Хостес';

  @override
  String get roleManager => 'Менеджер';

  @override
  String get roleReception => 'Администратор';

  @override
  String get roleKitchenPorter => 'Помощник на кухне';

  @override
  String get roleRelocate => 'Переезд';

  @override
  String get experience02Years => '0–2 года';

  @override
  String get experience35Years => '3–5 лет';

  @override
  String get experience5PlusYears => '5+ лет';

  @override
  String get roleUpper => 'ДОЛЖНОСТЬ';

  @override
  String get experienceUpper => 'ОПЫТ';

  @override
  String get cvLabel => 'Резюме';

  @override
  String get addShort => 'Добавить';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count фото',
      many: '$count фото',
      few: '$count фото',
      one: '$count фото',
    );
    return '$_temp0';
  }

  @override
  String candidatesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count кандидатов найдено',
      many: '$count кандидатов найдено',
      few: '$count кандидата найдено',
      one: '$count кандидат найден',
    );
    return '$_temp0';
  }

  @override
  String get maxKmLabel => 'макс. 50 км';

  @override
  String get shortlistAction => 'В шортлист';

  @override
  String get messageAction => 'Написать';

  @override
  String get interviewAction => 'Собеседование';

  @override
  String get viewAction => 'Смотреть';

  @override
  String get rejectAction => 'Отклонить';

  @override
  String get basedIn => 'Находится в';

  @override
  String get verificationPending => 'Верификация в ожидании';

  @override
  String get refreshAction => 'Обновить';

  @override
  String get upgradeAction => 'Улучшить';

  @override
  String get searchJobsByTitleHint =>
      'Поиск вакансий по названию, должности или месту…';

  @override
  String xShortlisted(String name) {
    return '$name добавлен(а) в шортлист';
  }

  @override
  String xRejected(String name) {
    return '$name отклонён(а)';
  }

  @override
  String rejectConfirmName(String name) {
    return 'Вы уверены, что хотите отклонить $name?';
  }

  @override
  String appliedToRoleOn(String role, String date) {
    return 'Откликнулся(ась) на $role $date';
  }

  @override
  String appliedDatePrefix(String date) {
    return 'Отклик $date';
  }

  @override
  String get salaryExpectationTitle => 'Ожидания по зарплате';

  @override
  String get previousEmployer => 'Предыдущий работодатель';

  @override
  String get earlierVenue => 'Более раннее заведение';

  @override
  String get presentLabel => 'Сейчас';

  @override
  String get skillCustomerService => 'Клиентский сервис';

  @override
  String get skillTeamwork => 'Командная работа';

  @override
  String get skillCommunication => 'Коммуникация';

  @override
  String get stepApplied => 'Отправлено';

  @override
  String get stepViewed => 'Просмотрено';

  @override
  String get stepShortlisted => 'В шортлисте';

  @override
  String get stepInterviewScheduled => 'Собеседование назначено';

  @override
  String get stepRejected => 'Отклонено';

  @override
  String get stepUnderReview => 'На рассмотрении';

  @override
  String get stepPendingReview => 'Ожидает рассмотрения';

  @override
  String get sortNewest => 'Сначала новые';

  @override
  String get sortMostExperienced => 'По опыту';

  @override
  String get sortBestMatch => 'Лучшее совпадение';

  @override
  String get filterApplied => 'Откликнулся';

  @override
  String get filterUnderReview => 'На рассмотрении';

  @override
  String get filterShortlisted => 'В шортлисте';

  @override
  String get filterInterview => 'Собеседование';

  @override
  String get filterHired => 'Нанят(а)';

  @override
  String get filterRejected => 'Отклонён(а)';

  @override
  String get confirmed => 'Подтверждено';

  @override
  String get pending => 'В ожидании';

  @override
  String get completed => 'Завершено';

  @override
  String get cancelled => 'Отменено';

  @override
  String get videoLabel => 'Видео';

  @override
  String get viewDetails => 'Подробнее';

  @override
  String get interviewDetails => 'Детали собеседования';

  @override
  String get interviewConfirmedHeadline => 'Собеседование подтверждено';

  @override
  String get interviewConfirmedSubline =>
      'Всё готово. Мы напомним ближе к началу.';

  @override
  String get dateLabel => 'Дата';

  @override
  String get timeLabel => 'Время';

  @override
  String get formatLabel => 'Формат';

  @override
  String get joinMeeting => 'Подключиться';

  @override
  String get viewJobAction => 'Открыть вакансию';

  @override
  String get addToCalendar => 'В календарь';

  @override
  String get needsYourAttention => 'Требует Вашего внимания';

  @override
  String get reviewAction => 'Рассмотреть';

  @override
  String applicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отклика',
      many: '$count откликов',
      few: '$count отклика',
      one: '$count отклик',
    );
    return '$_temp0';
  }

  @override
  String get sortMostRecent => 'Сначала новые';

  @override
  String get interviewScheduledLabel => 'Собеседование назначено';

  @override
  String get editAction => 'Изменить';

  @override
  String get currentPlanLabel => 'Текущий тариф';

  @override
  String get freePlan => 'Бесплатный тариф';

  @override
  String get profileStrength => 'Сила профиля';

  @override
  String get detailsLabel => 'Подробнее';

  @override
  String get basedInLabel => 'Находится в';

  @override
  String get verificationLabel2 => 'Верификация';

  @override
  String get contactLabel2 => 'Контакт';

  @override
  String get notSetLabel => 'Не указано';

  @override
  String get chipAll => 'Все';

  @override
  String get chipFullTime => 'Полная занятость';

  @override
  String get chipPartTime => 'Неполная';

  @override
  String get chipTemporary => 'Временная работа';

  @override
  String get chipCasual => 'Подработка';

  @override
  String get sortBestMatchLabel => 'Лучшее совпадение';

  @override
  String get sortAZ => 'А–Я';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get featuredBadge => 'Избранное';

  @override
  String get urgentBadge => 'Срочно';

  @override
  String get salaryOnRequest => 'Зарплата по запросу';

  @override
  String get upgradeToPremium => 'Перейти на Premium';

  @override
  String get urgentJobsOnly => 'Только срочные вакансии';

  @override
  String get showOnlyUrgentListings => 'Показывать только срочные вакансии';

  @override
  String get verifiedBusinessesOnly => 'Только проверенные компании';

  @override
  String get showOnlyVerifiedBusinesses =>
      'Показывать только проверенные компании';

  @override
  String get split => 'Разделить';

  @override
  String get payUpper => 'ОПЛАТА';

  @override
  String get typeUpper => 'ТИП';

  @override
  String get whereUpper => 'ГДЕ';

  @override
  String get payLabel => 'Оплата';

  @override
  String get typeLabel => 'Тип';

  @override
  String get whereLabel => 'Где';

  @override
  String get whereYouWillWork => 'Где Вы будете работать';

  @override
  String get mapPreviewDirections =>
      'Предпросмотр карты · открыть для маршрута';

  @override
  String get directionsAction => 'Маршрут';

  @override
  String get communityTabForYou => 'Для Вас';

  @override
  String get communityTabFollowing => 'Подписки';

  @override
  String get communityTabNearby => 'Рядом';

  @override
  String get communityTabSaved => 'Сохранённые';

  @override
  String get viewProfileAction => 'Посмотреть профиль';

  @override
  String get copyLinkAction => 'Копировать ссылку';

  @override
  String get savePostAction => 'Сохранить публикацию';

  @override
  String get unsavePostAction => 'Убрать из сохранённых';

  @override
  String get hideThisPost => 'Скрыть публикацию';

  @override
  String get reportPost => 'Пожаловаться на публикацию';

  @override
  String get cancelAction => 'Отмена';

  @override
  String get newPostTitle => 'Новая публикация';

  @override
  String get youLabel => 'Вы';

  @override
  String get postingToCommunityAsBusiness =>
      'Публикация в сообществе от имени бизнеса';

  @override
  String get postingToCommunityAsPro =>
      'Публикация в сообществе от имени специалиста';

  @override
  String get whatsOnYourMind => 'О чём Вы думаете?';

  @override
  String get publishAction => 'Опубликовать';

  @override
  String get attachmentPhoto => 'Фото';

  @override
  String get attachmentVideo => 'Видео';

  @override
  String get attachmentLocation => 'Местоположение';

  @override
  String get boostMyProfileCta => 'Продвинуть профиль';

  @override
  String get unlockYourFullPotential => 'Раскройте весь свой потенциал';

  @override
  String get annualPlan => 'Годовой';

  @override
  String get monthlyPlan => 'Месячный';

  @override
  String get bestValueBadge => 'ВЫГОДНО';

  @override
  String get whatsIncluded => 'Что входит';

  @override
  String get continueWithAnnual => 'Продолжить с годовым';

  @override
  String get continueWithMonthly => 'Продолжить с месячным';

  @override
  String get maybeLater => 'Возможно, позже';

  @override
  String get restorePurchasesLabel => 'Восстановить покупки';

  @override
  String get subscriptionAutoRenewsNote =>
      'Подписка продлевается автоматически. Отмена в Настройках.';

  @override
  String get appStatusPillApplied => 'Отправлен';

  @override
  String get appStatusPillUnderReview => 'На рассмотрении';

  @override
  String get appStatusPillShortlisted => 'В шортлисте';

  @override
  String get appStatusPillInterviewInvited => 'Собеседование';

  @override
  String get appStatusPillInterviewScheduled => 'Собеседование назначено';

  @override
  String get appStatusPillHired => 'Нанят(а)';

  @override
  String get appStatusPillRejected => 'Отклонён(а)';

  @override
  String get appStatusPillWithdrawn => 'Отозван';

  @override
  String get jobActionPause => 'Поставить на паузу';

  @override
  String get jobActionResume => 'Возобновить';

  @override
  String get jobActionClose => 'Закрыть вакансию';

  @override
  String get statusConfirmedLower => 'подтверждено';

  @override
  String get postInsightsTitle => 'Статистика публикации';

  @override
  String get postInsightsSubtitle => 'Кто видит Ваш контент';

  @override
  String get recentViewers => 'Недавние зрители';

  @override
  String get lockedBadge => 'ЗАКРЫТО';

  @override
  String get viewerBreakdown => 'Разбивка аудитории';

  @override
  String get viewersByRole => 'Зрители по должностям';

  @override
  String get topLocations => 'Топ локаций';

  @override
  String get businesses => 'Компании';

  @override
  String get saveToCollectionTitle => 'Сохранить в коллекцию';

  @override
  String get chooseCategory => 'Выберите категорию';

  @override
  String get removeFromCollection => 'Убрать из коллекции';

  @override
  String newApplicationTemplate(String role) {
    return 'Новый отклик — $role';
  }

  @override
  String get categoryRestaurants => 'Рестораны';

  @override
  String get categoryCookingVideos => 'Кулинарные видео';

  @override
  String get categoryJobsTips => 'Советы по трудоустройству';

  @override
  String get categoryHospitalityNews => 'Новости индустрии';

  @override
  String get categoryRecipes => 'Рецепты';

  @override
  String get categoryOther => 'Другое';

  @override
  String get premiumHeroTagline =>
      'Больше видимости, приоритетные уведомления и расширенные фильтры для серьёзных профессионалов гостеприимства.';

  @override
  String get benefitAdvancedFilters => 'Расширенные фильтры поиска';

  @override
  String get benefitPriorityNotifications =>
      'Приоритетные уведомления о вакансиях';

  @override
  String get benefitProfileVisibility => 'Повышенная видимость профиля';

  @override
  String get benefitPremiumBadge => 'Значок Premium на профиле';

  @override
  String get benefitEarlyAccess => 'Ранний доступ к новым вакансиям';

  @override
  String get unlockCandidatePremium => 'Откройте Candidate Premium';

  @override
  String get getStartedAction => 'Начать';

  @override
  String get findYourFirstJob => 'Найдите свою первую работу';

  @override
  String get browseHospitalityRolesNearby =>
      'Смотрите сотни вакансий в гостеприимстве рядом с Вами';

  @override
  String get seeWhoViewedYourPostTitle =>
      'Узнайте, кто просмотрел Вашу публикацию';

  @override
  String get upgradeToPremiumCta => 'Перейти на Premium';

  @override
  String get upgradeToPremiumSubtitle =>
      'Перейдите на Premium, чтобы увидеть проверенные компании, рекрутёров и руководителей, просматривавших Ваш контент.';

  @override
  String get verifiedBusinessViewers => 'Проверенные просмотры от компаний';

  @override
  String get recruiterHiringManagerActivity =>
      'Активность рекрутёров и менеджеров по найму';

  @override
  String get cityLevelReachBreakdown => 'Разбивка охвата по городам';

  @override
  String liveApplicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активных',
      many: '$count активных',
      few: '$count активных',
      one: '$count активный',
    );
    return '$_temp0';
  }

  @override
  String nearbyJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рядом',
      many: '$count рядом',
      few: '$count рядом',
      one: '$count рядом',
    );
    return '$_temp0';
  }

  @override
  String jobsNearYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вакансии рядом',
      many: '$count вакансий рядом',
      few: '$count вакансии рядом',
      one: '$count вакансия рядом',
    );
    return '$_temp0';
  }

  @override
  String applicationsUnderReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отклика на рассмотрении',
      many: '$count откликов на рассмотрении',
      few: '$count отклика на рассмотрении',
      one: '$count отклик на рассмотрении',
    );
    return '$_temp0';
  }

  @override
  String interviewsScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count собеседования назначено',
      many: '$count собеседований назначено',
      few: '$count собеседования назначено',
      one: '$count собеседование назначено',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанных сообщения',
      many: '$count непрочитанных сообщений',
      few: '$count непрочитанных сообщения',
      one: '$count непрочитанное сообщение',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesFromEmployersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанных сообщения от работодателей',
      many: '$count непрочитанных сообщений от работодателей',
      few: '$count непрочитанных сообщения от работодателей',
      one: '$count непрочитанное сообщение от работодателей',
    );
    return '$_temp0';
  }

  @override
  String stepsLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'осталось $count шага',
      many: 'осталось $count шагов',
      few: 'осталось $count шага',
      one: 'остался $count шаг',
    );
    return '$_temp0';
  }

  @override
  String get profileCompleteGreatWork => 'Профиль заполнен — отличная работа';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
    );
    return '$_temp0';
  }

  @override
  String get perHour => '/час';

  @override
  String hoursPerWeekShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ч/нед.',
      many: '$count ч/нед.',
      few: '$count ч/нед.',
      one: '$count ч/нед.',
    );
    return '$_temp0';
  }

  @override
  String forMonthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'на $count месяца',
      many: 'на $count месяцев',
      few: 'на $count месяца',
      one: 'на $count месяц',
    );
    return '$_temp0';
  }

  @override
  String interviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count собеседования',
      many: '$count собеседований',
      few: '$count собеседования',
      one: '$count собеседование',
    );
    return '$_temp0';
  }

  @override
  String get quickActionFindJobs => 'Найти работу';

  @override
  String get quickActionMyApplications => 'Мои отклики';

  @override
  String get quickActionUpdateProfile => 'Обновить профиль';

  @override
  String get quickActionCreatePost => 'Создать публикацию';

  @override
  String get quickActionViewInterviews => 'Смотреть собеседования';

  @override
  String get confirmSubscriptionTitle => 'Подтвердите подписку';

  @override
  String get confirmAndSubscribeCta => 'Подтвердить и подписаться';

  @override
  String get timelineLabel => 'Хронология';

  @override
  String get interviewLabel => 'Собеседование';

  @override
  String get payOnRequest => 'Оплата по запросу';

  @override
  String get rateOnRequest => 'Ставка по запросу';

  @override
  String get quickActionFindJobsSubtitle => 'Найдите вакансии рядом';

  @override
  String get quickActionMyApplicationsSubtitle => 'Отслеживайте каждый отклик';

  @override
  String get quickActionUpdateProfileSubtitle =>
      'Повысьте видимость и совпадение';

  @override
  String get quickActionCreatePostSubtitle =>
      'Поделитесь работой с сообществом';

  @override
  String get quickActionViewInterviewsSubtitle =>
      'Готовьтесь к следующему шагу';

  @override
  String get offerLabel => 'Оффер';

  @override
  String hiringForTemplate(String role) {
    return 'Набираем на $role';
  }

  @override
  String get tapToOpenInMaps => 'Нажмите, чтобы открыть в Картах';

  @override
  String get alreadyAppliedToJob => 'Вы уже откликнулись на эту вакансию.';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get changeAvatar => 'Изменить аватар';

  @override
  String get addPhotoAction => 'Добавить фото';

  @override
  String get nationalityLabel => 'Гражданство';

  @override
  String get targetRoleLabel => 'Желаемая должность';

  @override
  String get salaryExpectationLabel => 'Ожидания по зарплате';

  @override
  String get addLanguageCta => '+ Добавить язык';

  @override
  String get experienceLabel => 'Опыт';

  @override
  String get nameLabel => 'Имя';

  @override
  String get zeroHours => 'Нулевой контракт';

  @override
  String get checkInterviewDetailsLine => 'Проверьте детали собеседования';

  @override
  String get interviewInvitedSubline =>
      'Работодатель хочет провести собеседование — подтвердите время';

  @override
  String get shortlistedSubline =>
      'Вы попали в шортлист — ждите следующего шага';

  @override
  String get underReviewSubline => 'Работодатель изучает Ваш профиль';

  @override
  String get hiredHeadline => 'Приняты';

  @override
  String get hiredSubline => 'Поздравляем! Вы получили оффер';

  @override
  String get applicationSubmittedHeadline => 'Отклик отправлен';

  @override
  String get applicationSubmittedSubline =>
      'Работодатель рассмотрит Ваш отклик';

  @override
  String get withdrawnHeadline => 'Отозван';

  @override
  String get withdrawnSubline => 'Вы отозвали этот отклик';

  @override
  String get notSelectedHeadline => 'Не выбран(а)';

  @override
  String get notSelectedSubline => 'Спасибо за интерес';

  @override
  String jobsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вакансии найдено',
      many: '$count вакансий найдено',
      few: '$count вакансии найдено',
      one: '$count вакансия найдена',
    );
    return '$_temp0';
  }

  @override
  String applicationsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'всего $count',
      many: 'всего $count',
      few: 'всего $count',
      one: 'всего $count',
    );
    return '$_temp0';
  }

  @override
  String applicationsInReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count на рассмотрении',
      many: '$count на рассмотрении',
      few: '$count на рассмотрении',
      one: '$count на рассмотрении',
    );
    return '$_temp0';
  }

  @override
  String applicationsLiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активных',
      many: '$count активных',
      few: '$count активных',
      one: '$count активный',
    );
    return '$_temp0';
  }

  @override
  String interviewsPendingConfirmTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count собеседования ожидают — подтвердите время.',
      many: '$count собеседований ожидают — подтвердите время.',
      few: '$count собеседования ожидают — подтвердите время.',
      one: '$count собеседование ожидает — подтвердите время.',
    );
    return '$_temp0';
  }

  @override
  String notifInterviewConfirmedTitle(String name) {
    return 'Собеседование подтверждено — $name';
  }

  @override
  String notifInterviewRequestTitle(String name) {
    return 'Запрос на собеседование — $name';
  }

  @override
  String notifApplicationUpdateTitle(String name) {
    return 'Обновление по отклику — $name';
  }

  @override
  String notifOfferReceivedTitle(String name) {
    return 'Получен оффер — $name';
  }

  @override
  String notifMessageFromTitle(String name) {
    return 'Сообщение от — $name';
  }

  @override
  String notifInterviewReminderTitle(String name) {
    return 'Напоминание о собеседовании — $name';
  }

  @override
  String notifProfileViewedTitle(String name) {
    return 'Профиль просмотрен — $name';
  }

  @override
  String notifNewJobMatchTitle(String name) {
    return 'Новое совпадение — $name';
  }

  @override
  String notifApplicationViewedTitle(String name) {
    return 'Отклик просмотрен — $name';
  }

  @override
  String notifShortlistedTitle(String name) {
    return 'В шортлисте — $name';
  }

  @override
  String get notifCompleteProfile => 'Заполните профиль для лучших совпадений';

  @override
  String get notifCompleteBusinessProfile =>
      'Заполните профиль компании для большей видимости';

  @override
  String notifNewJobViews(String role, String count) {
    return 'Ваша вакансия $role получила новых просмотров: $count';
  }

  @override
  String notifAppliedForRole(String name, String role) {
    return '$name откликнулся(ась) на $role';
  }

  @override
  String notifNewApplicationNameRole(String name, String role) {
    return 'Новый отклик: $name на $role';
  }

  @override
  String get chatTyping => 'Печатает...';

  @override
  String get chatStatusSeen => 'Прочитано';

  @override
  String get chatStatusDelivered => 'Доставлено';

  @override
  String get entryTagline =>
      'Платформа подбора персонала для индустрии гостеприимства.';

  @override
  String get entryFindWork => 'Найти работу';

  @override
  String get entryFindWorkSubtitle => 'Смотрите вакансии от ведущих заведений';

  @override
  String get entryHireStaff => 'Нанять персонал';

  @override
  String get entryHireStaffSubtitle =>
      'Публикуйте вакансии и находите лучших специалистов';

  @override
  String get entryFindCompanies => 'Найти компании';

  @override
  String get entryFindCompaniesSubtitle =>
      'Открывайте заведения и сервисные компании';

  @override
  String get servicesEntryTitle => 'Поиск компаний';

  @override
  String get servicesHospitalityServices =>
      'Услуги для индустрии гостеприимства';

  @override
  String get servicesEntrySubtitle =>
      'Зарегистрируйте свою компанию или найдите поставщиков услуг рядом';

  @override
  String get servicesRegisterCardTitle => 'Зарегистрировать бизнес';

  @override
  String get servicesRegisterCardSubtitle =>
      'Разместите свою услугу и получайте новых клиентов';

  @override
  String get servicesLookingCardTitle => 'Я ищу компанию';

  @override
  String get servicesLookingCardSubtitle =>
      'Найдите поставщиков услуг для индустрии гостеприимства рядом';

  @override
  String get registerBusinessTitle => 'Зарегистрируйте бизнес';

  @override
  String get enterCompanyName => 'Введите название компании';

  @override
  String get subcategoryOptional => 'Подкатегория (необязательно)';

  @override
  String get subcategoryHintFloristDj => 'напр. Флорист, DJ-услуги';

  @override
  String get searchCompaniesHint => 'Поиск компаний...';

  @override
  String get browseCategories => 'Все категории';

  @override
  String companiesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count компании найдено',
      many: '$count компаний найдено',
      few: '$count компании найдено',
      one: '$count компания найдена',
    );
    return '$_temp0';
  }

  @override
  String get serviceCategoryFoodBeverage => 'Поставщики еды и напитков';

  @override
  String get serviceCategoryEventServices => 'Услуги для мероприятий';

  @override
  String get serviceCategoryDecorDesign => 'Декор и дизайн';

  @override
  String get serviceCategoryEntertainment => 'Развлечения';

  @override
  String get serviceCategoryEquipmentOps => 'Оборудование и операции';

  @override
  String get serviceCategoryCleaningMaintenance => 'Уборка и обслуживание';

  @override
  String distanceMiles(String value) {
    return '$value mi';
  }

  @override
  String distanceKilometers(String value) {
    return '$value km';
  }

  @override
  String get postDetailTitle => 'Публикация';

  @override
  String get likeAction => 'Нравится';

  @override
  String get commentAction => 'Комментировать';

  @override
  String get saveActionLabel => 'Сохранить';

  @override
  String get commentsTitle => 'Комментарии';

  @override
  String get addCommentHint => 'Добавьте комментарий…';

  @override
  String likesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count лайка',
      many: '$count лайков',
      few: '$count лайка',
      one: '$count лайк',
    );
    return '$_temp0';
  }

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментария',
      many: '$count комментариев',
      few: '$count комментария',
      one: '$count комментарий',
    );
    return '$_temp0';
  }

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сохранения',
      many: '$count сохранений',
      few: '$count сохранения',
      one: '$count сохранение',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutesShort(int count) {
    return '$countмин';
  }

  @override
  String timeAgoHoursShort(int count) {
    return '$countч';
  }

  @override
  String timeAgoDaysShort(int count) {
    return '$countд';
  }

  @override
  String get timeAgoNow => 'сейчас';

  @override
  String get activityTitle => 'Активность';

  @override
  String get activityLikedPost => 'лайкнул(а) Вашу публикацию';

  @override
  String get activityCommented => 'прокомментировал(а) Вашу публикацию';

  @override
  String get activityStartedFollowing => 'подписался(ась) на Вас';

  @override
  String get activityMentioned => 'упомянул(а) Вас';

  @override
  String get activitySystemUpdate => 'отправил(а) Вам обновление';

  @override
  String get noActivityYetDesc =>
      'Когда кто-то поставит лайк, прокомментирует или подпишется — это появится здесь.';

  @override
  String get activeStatus => 'Активно';

  @override
  String get activeBadge => 'АКТИВНО';

  @override
  String get nextRenewalLabel => 'Следующее продление';

  @override
  String get startedLabel => 'Начало';

  @override
  String get statusLabel => 'Статус';

  @override
  String get billingAndCancellation => 'Оплата и отмена';

  @override
  String get billingAndCancellationCopy =>
      'Ваша подписка оплачивается через аккаунт App Store / Google Play. Вы можете отменить её в любой момент в настройках устройства — премиум-доступ сохранится до даты продления.';

  @override
  String get premiumIsActive => 'Premium активен';

  @override
  String get premiumThanksCopy =>
      'Спасибо, что поддерживаете Plagit. Вам доступны все возможности Premium.';

  @override
  String get manageSubscription => 'Управление подпиской';

  @override
  String get candidatePremiumPlanName => 'Candidate Premium';

  @override
  String renewsOnDate(String date) {
    return 'Продление $date';
  }

  @override
  String get fullViewerAccessLine =>
      'Полный доступ к аудитории · вся аналитика открыта';

  @override
  String get premiumActiveBadge => 'Premium активен';

  @override
  String get fullInsightsUnlocked =>
      'Вся аналитика и данные о зрителях открыты.';

  @override
  String get noViewersInCategory => 'В этой категории пока нет зрителей';

  @override
  String get onlyVerifiedViewersShown =>
      'Показаны только проверенные зрители с публичными профилями.';

  @override
  String get notEnoughDataYet => 'Данных пока недостаточно.';

  @override
  String get noViewInsightsYet => 'Аналитики просмотров пока нет';

  @override
  String get noViewInsightsDesc =>
      'Аналитика появится, когда публикация наберёт больше просмотров.';

  @override
  String get suspiciousEngagementDetected =>
      'Обнаружена подозрительная активность';

  @override
  String get patternReviewRequired => 'Требуется проверка паттернов';

  @override
  String get adminInsightsFooter =>
      'Режим администратора — та же аналитика, что видит автор, плюс модерационные флаги. Только агрегированные данные, личности зрителей не раскрываются.';

  @override
  String get viewerKindBusiness => 'Бизнес';

  @override
  String get viewerKindCandidate => 'Кандидат';

  @override
  String get viewerKindRecruiter => 'Рекрутёр';

  @override
  String get viewerKindHiringManager => 'Менеджер по найму';

  @override
  String get viewerKindBusinessesPlural => 'Компании';

  @override
  String get viewerKindCandidatesPlural => 'Кандидаты';

  @override
  String get viewerKindRecruitersPlural => 'Рекрутёры';

  @override
  String get viewerKindHiringManagersPlural => 'Менеджеры по найму';

  @override
  String get searchPeoplePostsVenuesHint =>
      'Поиск людей, публикаций, заведений…';

  @override
  String get searchCommunityTitle => 'Поиск по сообществу';

  @override
  String get roleSommelier => 'Сомелье';

  @override
  String get candidatePremiumActivated => 'Вы теперь Candidate Premium';

  @override
  String get purchasesRestoredPremium =>
      'Покупки восстановлены — Вы теперь Candidate Premium';

  @override
  String get nothingToRestore => 'Нечего восстанавливать';

  @override
  String get noValidSubscriptionPremiumRemoved =>
      'Действующая подписка не найдена — премиум-доступ снят';

  @override
  String restoreFailedWithError(String error) {
    return 'Восстановление не удалось. $error';
  }

  @override
  String get subscriptionTitleAnnual => 'Candidate Premium · Годовой';

  @override
  String get subscriptionTitleMonthly => 'Candidate Premium · Месячный';

  @override
  String pricePerYearSlash(String price) {
    return '$price / год';
  }

  @override
  String pricePerMonthSlash(String price) {
    return '$price / мес.';
  }

  @override
  String get nearbyJobsTitle => 'Вакансии рядом';

  @override
  String get expandRadius => 'Увеличить радиус';

  @override
  String get noJobsInRadius => 'В этом радиусе вакансий нет';

  @override
  String jobsWithinRadius(int count, int radius) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вакансии в радиусе $radius миль',
      many: '$count вакансий в радиусе $radius миль',
      few: '$count вакансии в радиусе $radius миль',
      one: '$count вакансия в радиусе $radius миль',
    );
    return '$_temp0';
  }

  @override
  String get interviewAcceptedSnack => 'Собеседование принято!';

  @override
  String get declineInterviewTitle => 'Отклонить собеседование';

  @override
  String get declineInterviewConfirm =>
      'Вы уверены, что хотите отклонить это собеседование?';

  @override
  String get addedToCalendar => 'Добавлено в календарь';

  @override
  String get removeCompanyTitle => 'Удалить?';

  @override
  String get removeCompanyConfirm =>
      'Вы уверены, что хотите удалить эту компанию из сохранённых?';

  @override
  String get signOutAllRolesConfirm =>
      'Вы уверены, что хотите выйти из всех ролей?';

  @override
  String get tapToViewAllConversations =>
      'Нажмите, чтобы посмотреть все диалоги';

  @override
  String get savedJobsTitle => 'Сохранённые вакансии';

  @override
  String savedJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сохранённые вакансии',
      many: '$count сохранённых вакансий',
      few: '$count сохранённые вакансии',
      one: '$count сохранённая вакансия',
    );
    return '$_temp0';
  }

  @override
  String get removeFromSavedTitle => 'Удалить из сохранённых?';

  @override
  String get removeFromSavedConfirm =>
      'Эта вакансия будет удалена из Ваших сохранённых.';

  @override
  String get noSavedJobsSubtitle =>
      'Просматривайте вакансии и сохраняйте понравившиеся';

  @override
  String get browseJobsAction => 'Смотреть вакансии';

  @override
  String matchingJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подходящие вакансии',
      many: '$count подходящих вакансий',
      few: '$count подходящие вакансии',
      one: '$count подходящая вакансия',
    );
    return '$_temp0';
  }

  @override
  String get savedPostsTitle => 'Сохранённые публикации';

  @override
  String get searchSavedPostsHint => 'Поиск по сохранённым публикациям…';

  @override
  String get skipAction => 'Пропустить';

  @override
  String get submitAction => 'Отправить';

  @override
  String get doneAction => 'Готово';

  @override
  String get resetYourPasswordTitle => 'Сброс пароля';

  @override
  String get enterEmailForResetCode =>
      'Введите электронную почту, чтобы получить код сброса';

  @override
  String get sendResetCode => 'Отправить код';

  @override
  String get enterResetCode => 'Введите код сброса';

  @override
  String get resendCode => 'Отправить повторно';

  @override
  String get passwordResetComplete => 'Сброс пароля завершён';

  @override
  String get backToSignIn => 'Вернуться ко входу';

  @override
  String get passwordChanged => 'Пароль изменён';

  @override
  String get passwordUpdatedShort => 'Ваш пароль успешно обновлён.';

  @override
  String get passwordUpdatedRelogin =>
      'Ваш пароль обновлён. Пожалуйста, войдите снова с новым паролем.';

  @override
  String get updatePassword => 'Обновить пароль';

  @override
  String get changePasswordTitle => 'Изменить пароль';

  @override
  String get passwordRequirements => 'Требования к паролю';

  @override
  String get newPasswordHint => 'Новый пароль (минимум 8 символов)';

  @override
  String get confirmPasswordField => 'Подтвердите пароль';

  @override
  String get enterEmailField => 'Введите электронную почту';

  @override
  String get enterPasswordField => 'Введите пароль';

  @override
  String get welcomeBack => 'С возвращением!';

  @override
  String get selectHowToUse =>
      'Выберите, как хотите использовать Plagit сегодня';

  @override
  String get continueAsCandidate => 'Войти как кандидат';

  @override
  String get continueAsBusiness => 'Войти как бизнес';

  @override
  String get signInToPlagit => 'Вход в Plagit';

  @override
  String get enterCredentials => 'Введите данные для входа';

  @override
  String get adminPortal => 'Портал администратора';

  @override
  String get plagitAdmin => 'Plagit Admin';

  @override
  String get signInToAdminAccount => 'Войдите в аккаунт администратора';

  @override
  String get admin => 'Admin';

  @override
  String get searchJobsRolesRestaurantsHint =>
      'Поиск вакансий, должностей, ресторанов...';

  @override
  String get exploreNearbyJobs => 'Вакансии рядом';

  @override
  String get findOpportunitiesOnMap =>
      'Найдите возможности на карте вокруг Вас';

  @override
  String get featuredJobs => 'Избранные вакансии';

  @override
  String get jobsNearYou => 'Вакансии рядом';

  @override
  String get jobsMatchingRoleType =>
      'Вакансии под Вашу должность и тип занятости';

  @override
  String get availableNow => 'Доступно сейчас';

  @override
  String get noNearbyJobsYet => 'Вакансий рядом пока нет';

  @override
  String get tryIncreasingRadius =>
      'Попробуйте увеличить радиус или изменить фильтры';

  @override
  String get checkBackForOpportunities =>
      'Загляните позже — появятся новые возможности';

  @override
  String get noNotifications => 'Уведомлений нет';

  @override
  String get okAction => 'ОК';

  @override
  String get onlineNow => 'В сети';

  @override
  String get businessUpper => 'БИЗНЕС';

  @override
  String get waitingForBusinessFirstMessage =>
      'Ждём, когда компания напишет первой';

  @override
  String get whenEmployersMessageYou =>
      'Когда работодатели напишут Вам, они появятся здесь.';

  @override
  String get replyToCandidate => 'Ответить кандидату…';

  @override
  String get quickFeedback => 'Быстрая обратная связь';

  @override
  String get helpImproveMatches => 'Помогите улучшить Ваши совпадения';

  @override
  String get thanksForFeedback => 'Спасибо за отзыв!';

  @override
  String get accountSettings => 'Настройки аккаунта';

  @override
  String get notificationSettings => 'Настройки уведомлений';

  @override
  String get privacyAndSecurity => 'Конфиденциальность и безопасность';

  @override
  String get helpAndSupport => 'Помощь и поддержка';

  @override
  String get activeRoleUpper => 'АКТИВНАЯ РОЛЬ';

  @override
  String get meetingLink => 'Ссылка на встречу';

  @override
  String get joinMeeting2 => 'Подключиться ко встрече';

  @override
  String get notes => 'Заметки';

  @override
  String get completeBusinessProfileTitle => 'Заполните профиль компании';

  @override
  String get businessDescription => 'Описание компании';

  @override
  String get finishSetupAction => 'Завершить настройку';

  @override
  String get describeBusinessHintLong =>
      'Опишите Вашу компанию, культуру и что делает её отличным местом работы... (рекомендуется минимум 150 символов)';

  @override
  String get describeBusinessHintShort => 'Опишите Вашу компанию...';

  @override
  String get writeShortIntroAboutYourself =>
      'Напишите короткое представление о себе...';

  @override
  String get createBusinessAccountTitle => 'Создать бизнес-аккаунт';

  @override
  String get businessDetailsSection => 'Данные о компании';

  @override
  String get openToInternationalCandidates =>
      'Рассматриваю международных кандидатов';

  @override
  String get createAccountShort => 'Создать аккаунт';

  @override
  String get yourDetailsSection => 'Ваши данные';

  @override
  String get jobTypeField => 'Тип занятости';

  @override
  String get communityFeed => 'Лента сообщества';

  @override
  String get postPublished => 'Публикация опубликована';

  @override
  String get postHidden => 'Публикация скрыта';

  @override
  String get postReportedReview =>
      'Жалоба отправлена — администратор рассмотрит';

  @override
  String get postNotFound => 'Публикация не найдена';

  @override
  String get goBack => 'Назад';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String get removedFromSaved => 'Удалено из сохранённых';

  @override
  String get noPostsFound => 'Публикаций не найдено';

  @override
  String get tipsStoriesAdvice =>
      'Советы, истории и опыт профессионалов индустрии гостеприимства';

  @override
  String get searchTalentPostsRolesHint =>
      'Поиск специалистов, публикаций, должностей…';

  @override
  String get videoAttachmentsComingSoon => 'Вложения видео скоро появятся';

  @override
  String get locationTaggingComingSoon => 'Метки местоположения скоро появятся';

  @override
  String get fullImageViewerComingSoon =>
      'Полный просмотр изображений скоро появится';

  @override
  String get shareComingSoon => 'Поделиться скоро появится';

  @override
  String get findServices => 'Найти услуги';

  @override
  String get findHospitalityServices =>
      'Найти услуги для индустрии гостеприимства';

  @override
  String get browseServices => 'Просмотр услуг';

  @override
  String get searchServicesCompaniesLocationsHint =>
      'Поиск услуг, компаний, адресов...';

  @override
  String get searchCompaniesServicesLocationsHint =>
      'Поиск компаний, услуг, адресов...';

  @override
  String get nearbyCompanies => 'Компании рядом';

  @override
  String get nearYou => 'Рядом с Вами';

  @override
  String get listLabel => 'Список';

  @override
  String get mapViewLabel => 'Карта';

  @override
  String get noServicesFound => 'Услуг не найдено';

  @override
  String get noCompaniesFoundNearby => 'Компаний поблизости не найдено';

  @override
  String get noSavedCompanies => 'Сохранённых компаний нет';

  @override
  String get savedCompaniesTitle => 'Сохранённые компании';

  @override
  String get saveCompaniesForLater =>
      'Сохраняйте понравившиеся компании, чтобы легко находить их позже';

  @override
  String get latestUpdates => 'Последние новости';

  @override
  String get noPromotions => 'Акций нет';

  @override
  String get companyHasNoPromotions => 'У этой компании нет активных акций.';

  @override
  String get companyHasNoUpdates => 'Эта компания не публиковала новостей.';

  @override
  String get promotionsAndOffers => 'Акции и предложения';

  @override
  String get promotionNotFound => 'Акция не найдена';

  @override
  String get promotionDetails => 'Детали акции';

  @override
  String get termsAndConditions => 'Правила и условия';

  @override
  String get relatedPosts => 'Похожие публикации';

  @override
  String get viewOffer => 'Открыть';

  @override
  String get offerBadge => 'АКЦИЯ';

  @override
  String get requestQuote => 'Запросить смету';

  @override
  String get sendRequest => 'Отправить запрос';

  @override
  String get quoteRequestSent => 'Запрос сметы отправлен!';

  @override
  String get inquiry => 'Запрос';

  @override
  String get dateNeeded => 'Нужная дата';

  @override
  String get serviceType => 'Тип услуги';

  @override
  String get serviceArea => 'Район обслуживания';

  @override
  String get servicesOffered => 'Предлагаемые услуги';

  @override
  String get servicesLabel => 'Услуги';

  @override
  String get servicePlans => 'Тарифы на услуги';

  @override
  String get growYourServiceBusiness => 'Развивайте свой сервисный бизнес';

  @override
  String get getDiscoveredPremium =>
      'Привлекайте больше клиентов с premium-размещением.';

  @override
  String get unlockPremium => 'Открыть Premium';

  @override
  String get getMoreVisibility =>
      'Получите больше видимости и лучшие совпадения';

  @override
  String get plagitPremiumUpper => 'PLAGIT PREMIUM';

  @override
  String get premiumOnly => 'Только Premium';

  @override
  String get savePercent17 => 'Скидка 17%';

  @override
  String get registerBusinessCta => 'Зарегистрировать бизнес';

  @override
  String get registrationSubmitted => 'Регистрация отправлена';

  @override
  String get serviceDescription => 'Описание услуги';

  @override
  String get describeServicesHint =>
      'Опишите Ваши услуги, опыт и что выделяет Вас среди других...';

  @override
  String get websiteOptional => 'Website (необязательно)';

  @override
  String get viewCompanyProfileCta => 'Посмотреть профиль компании';

  @override
  String get contactCompany => 'Связаться с компанией';

  @override
  String get aboutUs => 'О нас';

  @override
  String get address => 'Адрес';

  @override
  String get city => 'Город';

  @override
  String get yourLocation => 'Ваше местоположение';

  @override
  String get enterYourCity => 'Введите Ваш город';

  @override
  String get clearFilters => 'Очистить фильтры';

  @override
  String get tryDifferentSearchTerm => 'Попробуйте другой запрос';

  @override
  String get tryDifferentOrAdjust =>
      'Попробуйте другой запрос, категорию или измените фильтры.';

  @override
  String get noPostsYetCompany => 'Публикаций пока нет';

  @override
  String requestQuoteFromCompany(String companyName) {
    return 'Запросить смету у $companyName';
  }

  @override
  String validUntilDate(String validUntil) {
    return 'Действует до $validUntil';
  }

  @override
  String get employerCheckingProfile =>
      'Работодатель сейчас смотрит Ваш профиль';

  @override
  String profileStrengthPercent(int percent) {
    return 'Ваш профиль заполнен на $percent%';
  }

  @override
  String get profileGetsMoreViews =>
      'Полный профиль получает в 3× больше просмотров';

  @override
  String get applicationUpdate => 'Статус отклика';

  @override
  String get findJobsAndApply => 'Найти работу и откликнуться';

  @override
  String get manageJobsAndHiring => 'Управление вакансиями и наймом';

  @override
  String get managePlatform => 'Управление платформой';

  @override
  String get findHospitalityCompanies => 'Найти hospitality-компании';

  @override
  String get candidateMessages => 'СООБЩЕНИЯ КАНДИДАТОВ';

  @override
  String get businessMessages => 'СООБЩЕНИЯ БИЗНЕСА';

  @override
  String get serviceInquiries => 'ЗАПРОСЫ УСЛУГ';

  @override
  String get acceptInterview => 'Принять интервью';

  @override
  String get adminMenuDashboard => 'Панель';

  @override
  String get adminMenuUsers => 'Пользователи';

  @override
  String get adminMenuCandidates => 'Кандидаты';

  @override
  String get adminMenuBusinesses => 'Компании';

  @override
  String get adminMenuJobs => 'Вакансии';

  @override
  String get adminMenuApplications => 'Заявки';

  @override
  String get adminMenuBookings => 'Бронирования';

  @override
  String get adminMenuPayments => 'Платежи';

  @override
  String get adminMenuMessages => 'Сообщения';

  @override
  String get adminMenuNotifications => 'Уведомления';

  @override
  String get adminMenuReports => 'Отчёты';

  @override
  String get adminMenuAnalytics => 'Аналитика';

  @override
  String get adminMenuSettings => 'Настройки';

  @override
  String get adminMenuSupport => 'Поддержка';

  @override
  String get adminMenuModeration => 'Модерация';

  @override
  String get adminMenuRoles => 'Роли';

  @override
  String get adminMenuInvoices => 'Счета';

  @override
  String get adminMenuLogs => 'Журналы';

  @override
  String get adminMenuIntegrations => 'Интеграции';

  @override
  String get adminMenuLogout => 'Выйти';

  @override
  String get adminActionApprove => 'Одобрить';

  @override
  String get adminActionReject => 'Отклонить';

  @override
  String get adminActionSuspend => 'Приостановить';

  @override
  String get adminActionActivate => 'Активировать';

  @override
  String get adminActionDelete => 'Удалить';

  @override
  String get adminActionExport => 'Экспорт';

  @override
  String get adminSectionOverview => 'Обзор';

  @override
  String get adminSectionManagement => 'Управление';

  @override
  String get adminSectionFinance => 'Финансы';

  @override
  String get adminSectionOperations => 'Операции';

  @override
  String get adminSectionSystem => 'Система';

  @override
  String get adminStatTotalUsers => 'Всего пользователей';

  @override
  String get adminStatActiveJobs => 'Активные вакансии';

  @override
  String get adminStatPendingApprovals => 'Ожидающие одобрения';

  @override
  String get adminStatRevenue => 'Доход';

  @override
  String get adminStatBookingsToday => 'Бронирования сегодня';

  @override
  String get adminStatNewSignups => 'Новые регистрации';

  @override
  String get adminStatConversionRate => 'Коэффициент конверсии';

  @override
  String get adminMiscWelcome => 'С возвращением';

  @override
  String get adminMiscLoading => 'Загрузка…';

  @override
  String get adminMiscNoData => 'Нет данных';

  @override
  String get adminMiscSearchPlaceholder => 'Поиск…';

  @override
  String get adminMenuContent => 'Контент';

  @override
  String get adminMenuMore => 'Ещё';

  @override
  String get adminMenuVerifications => 'Проверки';

  @override
  String get adminMenuSubscriptions => 'Подписки';

  @override
  String get adminMenuCommunity => 'Сообщество';

  @override
  String get adminMenuInterviews => 'Собеседования';

  @override
  String get adminMenuMatches => 'Совпадения';

  @override
  String get adminMenuFeaturedContent => 'Рекомендуемое';

  @override
  String get adminMenuAuditLog => 'Журнал аудита';

  @override
  String get adminMenuChangePassword => 'Изменить пароль';

  @override
  String get adminSectionPeople => 'Люди';

  @override
  String get adminSectionHiring => 'Операции найма';

  @override
  String get adminSectionContentComm => 'Контент и коммуникации';

  @override
  String get adminSectionRevenue => 'Бизнес и доход';

  @override
  String get adminSectionToolsContent => 'Инструменты и контент';

  @override
  String get adminSectionQuickActions => 'Быстрые действия';

  @override
  String get adminSectionNeedsAttention => 'Требует внимания';

  @override
  String get adminStatActiveBusinesses => 'Активные компании';

  @override
  String get adminStatApplicationsToday => 'Заявки сегодня';

  @override
  String get adminStatInterviewsToday => 'Собеседования сегодня';

  @override
  String get adminStatFlaggedContent => 'Помеченный контент';

  @override
  String get adminStatActiveSubs => 'Активные подписки';

  @override
  String get adminActionFlagged => 'Помечено';

  @override
  String get adminActionFeatured => 'Избранное';

  @override
  String get adminActionReviewFlagged => 'Проверить помеченное';

  @override
  String get adminActionTodayInterviews => 'Собеседования сегодня';

  @override
  String get adminActionOpenReports => 'Открытые отчёты';

  @override
  String get adminActionManageSubscriptions => 'Управление подписками';

  @override
  String get adminActionAnalyticsDashboard => 'Панель аналитики';

  @override
  String get adminActionSendNotification => 'Отправить уведомление';

  @override
  String get adminActionCreateCommunityPost => 'Создать пост сообщества';

  @override
  String get adminActionRetry => 'Повторить';

  @override
  String get adminMiscGreetingMorning => 'Доброе утро';

  @override
  String get adminMiscGreetingAfternoon => 'Добрый день';

  @override
  String get adminMiscGreetingEvening => 'Добрый вечер';

  @override
  String get adminMiscAllClear => 'Всё в порядке — ничего не требует внимания.';

  @override
  String get adminSubtitleAllUsers => 'Все пользователи';

  @override
  String get adminSubtitleCandidates => 'Профили соискателей';

  @override
  String get adminSubtitleBusinesses => 'Аккаунты работодателей';

  @override
  String get adminSubtitleJobs => 'Активные вакансии';

  @override
  String get adminSubtitleApplications => 'Поданные заявки';

  @override
  String get adminSubtitleInterviews => 'Назначенные собеседования';

  @override
  String get adminSubtitleMatches => 'Совпадения по роли и типу';

  @override
  String get adminSubtitleVerifications => 'Проверки в ожидании';

  @override
  String get adminSubtitleReports => 'Жалобы и модерация';

  @override
  String get adminSubtitleSupport => 'Открытые обращения';

  @override
  String get adminSubtitleMessages => 'Разговоры пользователей';

  @override
  String get adminSubtitleNotifications => 'Push- и in-app уведомления';

  @override
  String get adminSubtitleCommunity => 'Публикации и обсуждения';

  @override
  String get adminSubtitleFeaturedContent => 'Избранный контент';

  @override
  String get adminSubtitleSubscriptions => 'Планы и оплата';

  @override
  String get adminSubtitleAuditLog => 'Журналы действий администратора';

  @override
  String get adminSubtitleAnalytics => 'Метрики платформы';

  @override
  String get adminSubtitleSettings => 'Настройки платформы';

  @override
  String get adminSubtitleUsersPage => 'Управление аккаунтами';

  @override
  String get adminSubtitleContentPage => 'Вакансии, заявки и собеседования';

  @override
  String get adminSubtitleModerationPage => 'Проверки, жалобы и поддержка';

  @override
  String get adminSubtitleMorePage => 'Настройки, аналитика и аккаунт';

  @override
  String get adminSubtitleAnalyticsHero => 'KPI, тренды и здоровье платформы';

  @override
  String get adminBadgeUrgent => 'Срочно';

  @override
  String get adminBadgeReview => 'Проверить';

  @override
  String get adminBadgeAction => 'Действие';

  @override
  String get adminMenuAllUsers => 'Все пользователи';

  @override
  String get adminMiscSuperAdmin => 'Супер-админ';

  @override
  String adminBadgeNToday(int count) {
    return '$count сегодня';
  }

  @override
  String adminBadgeNOpen(int count) {
    return '$count открытых';
  }

  @override
  String adminBadgeNActive(int count) {
    return '$count активных';
  }

  @override
  String adminBadgeNUnread(int count) {
    return '$count непрочит.';
  }

  @override
  String adminBadgeNPending(int count) {
    return '$count в ожидании';
  }

  @override
  String adminBadgeNPosts(int count) {
    return '$count публикаций';
  }

  @override
  String adminBadgeNFeatured(int count) {
    return '$count избранных';
  }

  @override
  String get adminStatusActive => 'Активно';

  @override
  String get adminStatusPaused => 'Приостановлено';

  @override
  String get adminStatusClosed => 'Закрыто';

  @override
  String get adminStatusDraft => 'Черновик';

  @override
  String get adminStatusFlagged => 'Помечено';

  @override
  String get adminStatusSuspended => 'Приостановлен';

  @override
  String get adminStatusPending => 'В ожидании';

  @override
  String get adminStatusConfirmed => 'Подтверждено';

  @override
  String get adminStatusCompleted => 'Завершено';

  @override
  String get adminStatusCancelled => 'Отменено';

  @override
  String get adminStatusAccepted => 'Принято';

  @override
  String get adminStatusDenied => 'Отклонено';

  @override
  String get adminStatusExpired => 'Истёк';

  @override
  String get adminStatusResolved => 'Решено';

  @override
  String get adminStatusScheduled => 'Запланировано';

  @override
  String get adminStatusBanned => 'Заблокировано';

  @override
  String get adminStatusVerified => 'Проверено';

  @override
  String get adminStatusFailed => 'Ошибка';

  @override
  String get adminStatusSuccess => 'Успех';

  @override
  String get adminStatusDelivered => 'Доставлено';

  @override
  String get adminFilterAll => 'Все';

  @override
  String get adminFilterToday => 'Сегодня';

  @override
  String get adminFilterUnread => 'Непрочитанные';

  @override
  String get adminFilterRead => 'Прочитанные';

  @override
  String get adminFilterCandidates => 'Кандидаты';

  @override
  String get adminFilterBusinesses => 'Компании';

  @override
  String get adminFilterAdmins => 'Админы';

  @override
  String get adminFilterCandidate => 'Кандидат';

  @override
  String get adminFilterBusiness => 'Компания';

  @override
  String get adminFilterSystem => 'Система';

  @override
  String get adminFilterPinned => 'Закреплённые';

  @override
  String get adminFilterEmployers => 'Работодатели';

  @override
  String get adminFilterBanners => 'Баннеры';

  @override
  String get adminFilterBilling => 'Биллинг';

  @override
  String get adminFilterFeaturedEmployer => 'Избранный работодатель';

  @override
  String get adminFilterFeaturedJob => 'Избранная вакансия';

  @override
  String get adminFilterHomeBanner => 'Баннер главной';

  @override
  String get adminEmptyAdjustFilters => 'Попробуйте изменить фильтры.';

  @override
  String get adminEmptyJobsTitle => 'Нет вакансий';

  @override
  String get adminEmptyJobsSub => 'Нет совпадений.';

  @override
  String get adminEmptyUsersTitle => 'Нет пользователей';

  @override
  String get adminEmptyMessagesTitle => 'Нет сообщений';

  @override
  String get adminEmptyMessagesSub => 'Нет разговоров.';

  @override
  String get adminEmptyReportsTitle => 'Нет жалоб';

  @override
  String get adminEmptyReportsSub => 'Нет жалоб для проверки.';

  @override
  String get adminEmptyBusinessesTitle => 'Нет компаний';

  @override
  String get adminEmptyBusinessesSub => 'Нет совпадений.';

  @override
  String get adminEmptyNotifsTitle => 'Нет уведомлений';

  @override
  String get adminEmptySubsTitle => 'Нет подписок';

  @override
  String get adminEmptySubsSub => 'Нет совпадений.';

  @override
  String get adminEmptyLogsTitle => 'Нет записей';

  @override
  String get adminEmptyContentTitle => 'Нет контента';

  @override
  String get adminEmptyInterviewsTitle => 'Нет собеседований';

  @override
  String get adminEmptyInterviewsSub => 'Нет совпадений.';

  @override
  String get adminEmptyFeedback => 'Отзывы появятся здесь';

  @override
  String get adminEmptyMatchNotifs =>
      'Уведомления о совпадениях появятся здесь';

  @override
  String get adminTitleMatchManagement => 'Управление совпадениями';

  @override
  String get adminTitleAdminLogs => 'Логи админа';

  @override
  String get adminTitleContentFeatured => 'Контент / Избранное';

  @override
  String get adminTabFeedback => 'Отзывы';

  @override
  String get adminTabStats => 'Статистика';

  @override
  String get adminSortNewest => 'Новые';

  @override
  String get adminSortPriority => 'Приоритет';

  @override
  String get adminStatTotalMatches => 'Всего совпадений';

  @override
  String get adminStatAccepted => 'Принято';

  @override
  String get adminStatDenied => 'Отклонено';

  @override
  String get adminStatFeedbackCount => 'Отзывы';

  @override
  String get adminStatMatchQuality => 'Оценка качества совпадений';

  @override
  String get adminStatTotal => 'Всего';

  @override
  String get adminStatPendingCount => 'В ожидании';

  @override
  String get adminStatNotificationsCount => 'Уведомления';

  @override
  String get adminStatActiveCount => 'Активные';

  @override
  String get adminSectionPlatformSettings => 'Настройки платформы';

  @override
  String get adminSectionNotificationSettings => 'Настройки уведомлений';

  @override
  String get adminSettingMaintenanceTitle => 'Режим обслуживания';

  @override
  String get adminSettingMaintenanceSub => 'Отключить доступ для всех';

  @override
  String get adminSettingNewRegsTitle => 'Новые регистрации';

  @override
  String get adminSettingNewRegsSub => 'Разрешить новые регистрации';

  @override
  String get adminSettingFeaturedJobsTitle => 'Избранные вакансии';

  @override
  String get adminSettingFeaturedJobsSub =>
      'Показывать избранные вакансии на главной';

  @override
  String get adminSettingEmailNotifsTitle => 'Email-уведомления';

  @override
  String get adminSettingEmailNotifsSub => 'Отправлять email-оповещения';

  @override
  String get adminSettingPushNotifsTitle => 'Push-уведомления';

  @override
  String get adminSettingPushNotifsSub => 'Отправлять push-уведомления';

  @override
  String get adminActionSaveChanges => 'Сохранить изменения';

  @override
  String get adminToastSettingsSaved => 'Настройки сохранены';

  @override
  String get adminActionResolve => 'Решить';

  @override
  String get adminActionDismiss => 'Отклонить';

  @override
  String get adminActionBanUser => 'Забанить';

  @override
  String get adminSearchUsersHint => 'Поиск: имя, email, роль, место...';

  @override
  String get adminMiscPositive => 'положительно';

  @override
  String adminCountUsers(int count) {
    return '$count пользователей';
  }

  @override
  String adminCountNotifs(int count) {
    return '$count уведомлений';
  }

  @override
  String adminCountLogs(int count) {
    return '$count записей';
  }

  @override
  String adminCountItems(int count) {
    return '$count элементов';
  }

  @override
  String adminBadgeNRetried(int count) {
    return 'Повторы x$count';
  }

  @override
  String get adminStatusApplied => 'Подана';

  @override
  String get adminStatusUnderReview => 'На рассмотрении';

  @override
  String get adminStatusShortlisted => 'В шорт-листе';

  @override
  String get adminStatusInterview => 'Интервью';

  @override
  String get adminStatusHired => 'Нанят';

  @override
  String get adminStatusRejected => 'Отклонён';

  @override
  String get adminStatusOpen => 'Открыт';

  @override
  String get adminStatusInReview => 'На рассмотрении';

  @override
  String get adminStatusWaiting => 'Ожидание';

  @override
  String get adminPriorityHigh => 'Высокий';

  @override
  String get adminPriorityMedium => 'Средний';

  @override
  String get adminPriorityLow => 'Низкий';

  @override
  String get adminActionViewProfile => 'Смотреть профиль';

  @override
  String get adminActionVerify => 'Проверить';

  @override
  String get adminActionReview => 'Проверить';

  @override
  String get adminActionOverride => 'Переопределить';

  @override
  String get adminEmptyCandidatesTitle => 'Нет кандидатов';

  @override
  String get adminEmptyApplicationsTitle => 'Нет заявок';

  @override
  String get adminEmptyVerificationsTitle => 'Нет ожидающих проверок';

  @override
  String get adminEmptyIssuesTitle => 'Нет обращений';

  @override
  String get adminEmptyAuditTitle => 'Нет записей аудита';

  @override
  String get adminSearchCandidatesTitle => 'Поиск кандидатов';

  @override
  String get adminSearchCandidatesHint => 'Поиск по имени, email или роли…';

  @override
  String get adminSearchAuditHint => 'Поиск в журнале…';

  @override
  String get adminMiscUnknown => 'Неизвестно';

  @override
  String adminCountTotal(int count) {
    return 'всего $count';
  }

  @override
  String adminBadgeNFlagged(int count) {
    return '$count отмечено';
  }

  @override
  String adminBadgeNDaysWaiting(int count) {
    return 'ожидание $count дн.';
  }

  @override
  String get adminPeriodWeek => 'Неделя';

  @override
  String get adminPeriodMonth => 'Месяц';

  @override
  String get adminPeriodYear => 'Год';

  @override
  String get adminKpiNewCandidates => 'Новые кандидаты';

  @override
  String get adminKpiNewBusinesses => 'Новые компании';

  @override
  String get adminKpiJobsPosted => 'Размещённые вакансии';

  @override
  String get adminSectionApplicationFunnel => 'Воронка заявок';

  @override
  String get adminSectionPlatformGrowth => 'Рост платформы';

  @override
  String get adminSectionPremiumConversion => 'Премиум-конверсия';

  @override
  String get adminSectionTopLocations => 'Топ городов';

  @override
  String get adminStatusViewed => 'Просмотрено';

  @override
  String get adminWeekdayMon => 'Пн';

  @override
  String get adminWeekdayTue => 'Вт';

  @override
  String get adminWeekdayWed => 'Ср';

  @override
  String get adminWeekdayThu => 'Чт';

  @override
  String get adminWeekdayFri => 'Пт';

  @override
  String get adminWeekdaySat => 'Сб';

  @override
  String get adminWeekdaySun => 'Вс';

  @override
  String get adminFilterReported => 'Сообщённые';

  @override
  String get adminFilterHidden => 'Скрытые';

  @override
  String get adminEmptyPostsTitle => 'Нет публикаций';

  @override
  String get adminEmptyContentFilter =>
      'Ничего не соответствует этому фильтру.';

  @override
  String get adminBannerReportedReview => 'СООБЩЕНО — ТРЕБУЕТСЯ ПРОВЕРКА';

  @override
  String get adminBannerHiddenFromFeed => 'СКРЫТО ИЗ ЛЕНТЫ';

  @override
  String get adminActionInsights => 'Аналитика';

  @override
  String get adminActionHide => 'Скрыть';

  @override
  String get adminActionRemove => 'Удалить';

  @override
  String get adminActionCancel => 'Отмена';

  @override
  String get adminDialogRemovePostTitle => 'Удалить публикацию?';

  @override
  String get adminDialogRemovePostBody =>
      'Публикация и её комментарии будут удалены навсегда. Это действие нельзя отменить.';

  @override
  String get adminSnackbarReportCleared => 'Жалоба снята';

  @override
  String get adminSnackbarPostHidden => 'Публикация скрыта из ленты';

  @override
  String get adminSnackbarPostRemoved => 'Публикация удалена';

  @override
  String adminCountReported(int count) {
    return 'Сообщено: $count';
  }

  @override
  String adminCountHidden(int count) {
    return 'Скрыто: $count';
  }

  @override
  String adminMiscPremiumOutOfTotal(int premium, int total) {
    return '$premium премиум из $total';
  }

  @override
  String get adminActionUnverify => 'Отменить верификацию';

  @override
  String get adminActionReactivate => 'Реактивировать';

  @override
  String get adminActionFeature => 'Выделить';

  @override
  String get adminActionUnfeature => 'Снять выделение';

  @override
  String get adminActionFlagAccount => 'Отметить аккаунт';

  @override
  String get adminActionUnflagAccount => 'Снять отметку';

  @override
  String get adminActionConfirm => 'Подтвердить';

  @override
  String get adminDialogVerifyBusinessTitle => 'Верифицировать компанию';

  @override
  String get adminDialogUnverifyBusinessTitle =>
      'Отменить верификацию компании';

  @override
  String get adminDialogSuspendBusinessTitle => 'Приостановить компанию';

  @override
  String get adminDialogReactivateBusinessTitle => 'Реактивировать компанию';

  @override
  String get adminDialogVerifyCandidateTitle => 'Верифицировать кандидата';

  @override
  String get adminDialogSuspendCandidateTitle => 'Приостановить кандидата';

  @override
  String get adminDialogReactivateCandidateTitle => 'Реактивировать кандидата';

  @override
  String get adminSnackbarBusinessVerified => 'Компания верифицирована';

  @override
  String get adminSnackbarVerificationRemoved => 'Верификация снята';

  @override
  String get adminSnackbarBusinessSuspended => 'Компания приостановлена';

  @override
  String get adminSnackbarBusinessReactivated => 'Компания реактивирована';

  @override
  String get adminSnackbarBusinessFeatured => 'Компания выделена';

  @override
  String get adminSnackbarBusinessUnfeatured => 'Выделение компании снято';

  @override
  String get adminSnackbarUserVerified => 'Пользователь верифицирован';

  @override
  String get adminSnackbarUserSuspended => 'Пользователь приостановлен';

  @override
  String get adminSnackbarUserReactivated => 'Пользователь реактивирован';

  @override
  String get adminTabProfile => 'Профиль';

  @override
  String get adminTabActivity => 'Активность';

  @override
  String get adminTabNotes => 'Заметки';

  @override
  String adminDialogVerifyBody(String name) {
    return 'Отметить $name как верифицированного?';
  }

  @override
  String adminDialogUnverifyBody(String name) {
    return 'Снять верификацию с $name?';
  }

  @override
  String adminDialogReactivateBody(String name) {
    return 'Реактивировать $name?';
  }

  @override
  String adminDialogSuspendBusinessBody(String name) {
    return 'Приостановить $name? Все вакансии будут приостановлены.';
  }

  @override
  String adminDialogSuspendCandidateBody(String name) {
    return 'Приостановить $name? Доступ будет закрыт.';
  }

  @override
  String get adminFieldName => 'Имя';

  @override
  String get adminFieldEmail => 'Электронная почта';

  @override
  String get adminFieldPhone => 'Телефон';

  @override
  String get adminFieldLocation => 'Местоположение';

  @override
  String get adminFieldPlan => 'Тариф';

  @override
  String get adminFieldVerified => 'Подтверждён';

  @override
  String get adminFieldStatus => 'Статус';

  @override
  String get adminFieldJoined => 'Присоединился';

  @override
  String get adminFieldCategory => 'Категория';

  @override
  String get adminFieldSize => 'Размер';

  @override
  String get adminFieldRole => 'Роль';

  @override
  String get adminFieldProfileCompletion => 'Заполнение профиля';

  @override
  String get adminStatApplicants => 'Кандидаты';

  @override
  String get adminStatSaved => 'Сохранённые';

  @override
  String get adminPlaceholderAddNote => 'Добавить заметку...';

  @override
  String get adminEmptyNoJobsPosted => 'Нет опубликованных вакансий';

  @override
  String get adminSectionSubscriptionDetail => 'Сведения о подписке';

  @override
  String get adminEmptySubscriptionNotFound => 'Подписка не найдена';

  @override
  String get adminSectionPlanDetails => 'Детали тарифа';

  @override
  String get adminFieldPrice => 'Цена';

  @override
  String get adminFieldStartDate => 'Дата начала';

  @override
  String get adminFieldRenewalDate => 'Дата продления';

  @override
  String get adminSectionAdminOverride => 'Переопределение админом';

  @override
  String get adminPlanCandidatePremium => 'Кандидат Premium';

  @override
  String get adminPlanBusinessPro => 'Business Pro';

  @override
  String get adminPlanBusinessPremium => 'Business Premium';

  @override
  String get adminPlanFree => 'Бесплатно';

  @override
  String get adminFieldNewRenewalDate => 'Новая дата продления';

  @override
  String get adminPlaceholderDateExample => 'напр. 15 июн 2026';

  @override
  String get adminFieldReason => 'Причина';

  @override
  String get adminPlaceholderReasonOverride => 'Причина переопределения...';

  @override
  String get adminActionApplyOverride => 'Применить переопределение';

  @override
  String get adminSectionHistory => 'История';

  @override
  String get adminTimelineSubscriptionCreated => 'Подписка создана';

  @override
  String get adminTimelinePaymentProcessed => 'Платёж обработан';

  @override
  String get adminEmptyNoAdminNotes => 'Нет заметок админа.';

  @override
  String get adminSectionAuditDetail => 'Сведения аудита';

  @override
  String get adminEmptyEntryNotFound => 'Запись не найдена';

  @override
  String get adminFieldAdmin => 'Админ';

  @override
  String get adminFieldAction => 'Действие';

  @override
  String get adminFieldTimestamp => 'Метка времени';

  @override
  String get adminFieldTarget => 'Цель';

  @override
  String get adminFieldType => 'Тип';

  @override
  String get adminSectionChanges => 'Изменения';

  @override
  String get adminFieldIpAddress => 'IP-адрес';

  @override
  String get adminAuditUnverified => 'Не подтверждён';

  @override
  String get adminAuditStandard => 'Обычный';

  @override
  String get adminAuditFeatured => 'Рекомендуемый';

  @override
  String get adminAuditPreviousStatus => 'Прежний статус';

  @override
  String get adminAuditOverridden => 'Переопределено';

  @override
  String get adminAuditPrevious => 'Ранее';

  @override
  String get adminAuditUpdated => 'Обновлено';

  @override
  String get adminStatusWithdrawn => 'Отозвано';

  @override
  String get adminStatusNoShow => 'Не явился';

  @override
  String get adminStatusInProgress => 'В процессе';

  @override
  String get adminStatusReviewed => 'Рассмотрено';

  @override
  String get adminStatusDecision => 'Решение';

  @override
  String get adminSectionApplicationDetail => 'Детали заявки';

  @override
  String get adminSectionInterviewDetail => 'Детали интервью';

  @override
  String get adminSectionTimeline => 'Хронология';

  @override
  String get adminSectionAdminNotes => 'Заметки администратора';

  @override
  String get adminSectionActions => 'Действия';

  @override
  String get adminFieldCandidate => 'Кандидат';

  @override
  String get adminFieldJob => 'Вакансия';

  @override
  String get adminFieldBusiness => 'Бизнес';

  @override
  String get adminFieldDate => 'Дата';

  @override
  String get adminFieldTime => 'Время';

  @override
  String get adminFieldFormat => 'Формат';

  @override
  String get adminBadgeFlaggedForReview => 'Отмечено для проверки модератором';

  @override
  String get adminPlaceholderSelectStatus => 'Выберите статус';

  @override
  String get adminDialogConfirmOverrideTitle => 'Подтвердить переопределение';

  @override
  String adminDialogConfirmOverrideQuestion(String status) {
    return 'Изменить статус на «$status»?';
  }

  @override
  String get adminDialogReasonPrefix => 'Причина:';

  @override
  String get adminMiscNoneProvided => 'Не указано';

  @override
  String get adminSnackbarStatusOverrideApplied =>
      'Переопределение статуса применено';

  @override
  String get adminSnackbarNoteSaved => 'Заметка сохранена';

  @override
  String get adminSnackbarNoteAdded => 'Заметка добавлена';

  @override
  String get adminSnackbarMarkedNoShow => 'Отмечено как не явился';

  @override
  String get adminSnackbarInterviewCancelled => 'Интервью отменено';

  @override
  String get adminSnackbarInterviewCompleted => 'Интервью завершено';

  @override
  String get adminActionSaveNote => 'Сохранить заметку';

  @override
  String get adminActionAddNote => 'Добавить заметку';

  @override
  String get adminActionComplete => 'Завершить';

  @override
  String get adminActionMarkNoShow => 'Отметить не явился';

  @override
  String get adminEmptyNoNotes => 'Заметок пока нет.';

  @override
  String get adminSectionVerificationReview => 'Проверка верификации';

  @override
  String get adminSectionProfileSummary => 'Сводка профиля';

  @override
  String get adminSectionDocuments => 'Документы';

  @override
  String get adminSectionReportDetail => 'Детали отчёта';

  @override
  String get adminSectionReportInformation => 'Информация об отчёте';

  @override
  String get adminSectionEvidence => 'Доказательства';

  @override
  String get adminSectionAdminDecision => 'Решение администратора';

  @override
  String get adminSectionAuditTrail => 'Журнал аудита';

  @override
  String get adminSectionSupportIssue => 'Запрос поддержки';

  @override
  String get adminSectionDescription => 'Описание';

  @override
  String get adminSectionUpdateStatus => 'Обновить статус';

  @override
  String get adminSectionResolution => 'Решение';

  @override
  String get adminFieldSubmitted => 'Отправлено';

  @override
  String get adminFieldReporter => 'Заявитель';

  @override
  String get adminFieldEntity => 'Объект';

  @override
  String get adminFieldUser => 'Пользователь';

  @override
  String get adminFieldNote => 'Заметка';

  @override
  String get adminFieldCreated => 'Создано';

  @override
  String get adminFieldUpdated => 'Обновлено';

  @override
  String get adminFieldPriority => 'Приоритет';

  @override
  String get adminDocTitleIdDocument => 'Удостоверение личности';

  @override
  String get adminDocSubtitleIdDocument => 'Паспорт / удостоверение личности';

  @override
  String get adminDocTitleCv => 'Резюме';

  @override
  String get adminDocSubtitleCv => 'Резюме';

  @override
  String get adminDocTitleRegistration => 'Регистрация';

  @override
  String get adminDocSubtitleRegistration => 'Документ о регистрации компании';

  @override
  String get adminActionViewDocument => 'Просмотреть документ';

  @override
  String get adminActionSaveDecision => 'Сохранить решение';

  @override
  String get adminActionUpdate => 'Обновить';

  @override
  String get adminActionMarkResolved => 'Отметить как решено';

  @override
  String get adminActionOptionNone => 'Нет';

  @override
  String get adminActionOptionWarning => 'Предупреждение';

  @override
  String get adminActionOptionContentRemoved => 'Контент удалён';

  @override
  String get adminActionOptionAccountSuspended => 'Аккаунт заблокирован';

  @override
  String get adminPlaceholderRejectionReason => 'Причина отказа...';

  @override
  String get adminPlaceholderDecisionNotes => 'Добавить заметки о решении...';

  @override
  String get adminPlaceholderResolutionSummary => 'Описание решения...';

  @override
  String get adminSnackbarVerificationApproved => 'Верификация одобрена';

  @override
  String get adminSnackbarVerificationRejected => 'Верификация отклонена';

  @override
  String get adminSnackbarIssueResolved => 'Проблема решена';

  @override
  String adminSnackbarViewingDocument(String title) {
    return 'Просмотр $title (заглушка)';
  }

  @override
  String adminSnackbarStatusUpdatedTo(String status) {
    return 'Статус обновлён на $status';
  }

  @override
  String adminSnackbarDecisionSaved(String status, String action) {
    return 'Решение сохранено: $status / $action';
  }

  @override
  String get adminDialogApproveVerificationTitle => 'Одобрить верификацию';

  @override
  String adminDialogApproveVerificationBody(String name) {
    return 'Одобрить верификацию для $name?';
  }

  @override
  String get adminDialogRejectVerificationTitle => 'Отклонить верификацию';

  @override
  String adminDialogRejectVerificationBody(String name) {
    return 'Отклонить верификацию для $name?';
  }

  @override
  String get adminEmptyIssueNotFound => 'Запрос не найден';

  @override
  String get adminValuePlatform => 'Платформа';

  @override
  String get adminValueSupport => 'Поддержка';

  @override
  String get adminMiscReportCreatedByPlatform =>
      'Отчёт создан автоматическим обнаружением платформы';

  @override
  String get adminActionPause => 'Приостановить';

  @override
  String get adminActionClose => 'Закрыть';

  @override
  String get adminActionViewApplicants => 'Просмотреть кандидатов';

  @override
  String get adminBadgeFeatured => 'Рекомендуемое';

  @override
  String get adminFieldPosted => 'Опубликовано';

  @override
  String get adminFieldViews => 'Просмотры';

  @override
  String get adminFieldPay => 'Оплата';

  @override
  String get adminFieldEmployment => 'Трудоустройство';

  @override
  String get adminFieldSummary => 'Сводка';

  @override
  String get adminFieldAnnual => 'Годовой';

  @override
  String get adminFieldMonthly => 'Ежемесячно';

  @override
  String get adminFieldDuration => 'Продолжительность';

  @override
  String get adminFieldHourly => 'Почасово';

  @override
  String get adminFieldWeeklyHours => 'Часов в неделю';

  @override
  String get adminFieldBonus => 'Бонус';

  @override
  String get adminFieldShift => 'Смена';

  @override
  String get adminFieldSalaryRange => 'Диапазон зарплаты';

  @override
  String get adminMiscNotSpecified => 'Не указано';

  @override
  String get adminSectionModeration => 'Модерация';

  @override
  String get adminSectionCompensationReview => 'Обзор вознаграждения';

  @override
  String get adminSectionApplicantsSummary => 'Сводка кандидатов';

  @override
  String get adminSectionExtras => 'Дополнительно';

  @override
  String get adminPlaceholderFlagReason => 'Причина пометки...';

  @override
  String get adminSnackbarJobFeatured => 'Вакансия выделена';

  @override
  String get adminSnackbarJobUnfeatured => 'Вакансия снята с рекомендаций';

  @override
  String get adminSnackbarJobRemoved => 'Вакансия удалена';

  @override
  String get adminDialogPauseJobTitle => 'Приостановить вакансию';

  @override
  String get adminDialogPauseJobBody => 'Приостановить это объявление?';

  @override
  String get adminDialogCloseJobTitle => 'Закрыть вакансию';

  @override
  String get adminDialogCloseJobBody => 'Закрыть эту вакансию навсегда?';

  @override
  String get adminDialogRemoveJobTitle => 'Удалить вакансию';

  @override
  String get adminDialogRemoveJobBody =>
      'Полностью удалить эту вакансию? Это действие нельзя отменить.';

  @override
  String get adminModerationFlagThis => 'Пометить эту вакансию';

  @override
  String get adminModerationIsFlagged => 'Эта вакансия помечена';

  @override
  String get adminPerkHousing => 'Включает жильё';

  @override
  String get adminPerkTravel => 'Включает проезд';

  @override
  String get adminPerkOvertime => 'Сверхурочная работа';

  @override
  String get adminPerkFlexible => 'Гибкий график';

  @override
  String get adminPerkWeekend => 'Смены в выходные';

  @override
  String get adminStatNew => 'Новые';

  @override
  String get adminStatReviewed => 'Проверено';

  @override
  String get adminStatShortlisted => 'В шортлисте';

  @override
  String get adminStatRejected => 'Отклонены';

  @override
  String get switchRoleTitle => 'Сменить роль';

  @override
  String get postsTab => 'Публикации';

  @override
  String get galleryTab => 'Галерея';

  @override
  String get promotionsTab => 'Акции';

  @override
  String get filterUpdates => 'Обновления';

  @override
  String get badgePro => 'PRO';

  @override
  String get badgeAdmin => 'ADMIN';
}
