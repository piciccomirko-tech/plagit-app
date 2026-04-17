/// Localization helpers for seeded DEMO content.
///
/// The app ships with a handful of mock chat conversations and demo
/// messages (e.g. the Ritz thread) that are written in English in
/// `lib/core/mock/mock_data.dart`. For non-English device locales these
/// feel jarring — so at display time we map the well-known English
/// strings to localized equivalents.
///
/// Real (backend/user-typed) messages are NOT in the lookup table and
/// therefore pass through untouched — this helper is a safe no-op for
/// anything it doesn't recognise.
library;

import 'package:flutter/widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

/// Returns a localized version of a known demo chat message, or the
/// original string if the message isn't a known demo fixture.
String localizeDemoChat(BuildContext context, String raw) {
  final locale = Localizations.localeOf(context).languageCode;
  // English is the canonical text — skip lookup entirely.
  if (locale == 'en') return raw;

  final map = _demoChatMap[locale];
  if (map == null) return raw;

  return map[raw.trim()] ?? raw;
}

/// Returns a localized version of a conversation's last-message preview.
/// Same semantics as [localizeDemoChat] but kept as a separate entry
/// point so callers can be explicit at the call site.
String localizeDemoLastMessage(BuildContext context, String raw) =>
    localizeDemoChat(context, raw);

/// Returns a localized version of a known demo company description
/// (marketing blurb), or the original string if it isn't a known fixture.
///
/// Mock data in `lib/core/mock/mock_data.dart` ships English marketing
/// copy for demo service-provider companies. Real backend-driven
/// descriptions pass through untouched.
String localizeDemoCompanyDescription(BuildContext context, String raw) {
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'en') return raw;

  final map = _demoCompanyDescriptionMap[locale];
  if (map == null) return raw;

  return map[raw.trim()] ?? raw;
}

/// Returns a localized version of a known demo community post body.
/// English seed post bodies from `lib/core/mock/mock_data.dart` are
/// mapped to IT/AR equivalents; anything else passes through untouched.
String localizeDemoPostBody(BuildContext context, String raw) {
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'en') return raw;

  final map = _demoPostBodyMap[locale];
  if (map == null) return raw;

  return map[raw.trim()] ?? raw;
}

/// Returns a localized version of a known demo community comment body.
/// English seed comments from `lib/core/mock/mock_data.dart` are mapped
/// to IT/AR equivalents; anything else passes through untouched.
String localizeDemoComment(BuildContext context, String raw) {
  final locale = Localizations.localeOf(context).languageCode;
  if (locale == 'en') return raw;

  final map = _demoCommentMap[locale];
  if (map == null) return raw;

  return map[raw.trim()] ?? raw;
}

/// Localized `Typing...` helper for chat status lines.
String localizedTyping(BuildContext context) =>
    AppLocalizations.of(context).chatTyping;

/// Localized `Seen` / `Delivered` helpers.
String localizedMessageSeen(BuildContext context) =>
    AppLocalizations.of(context).chatStatusSeen;
String localizedMessageDelivered(BuildContext context) =>
    AppLocalizations.of(context).chatStatusDelivered;

// ─────────────────────────────────────────────
// Lookup tables — keep in sync with lib/core/mock/mock_data.dart
// ─────────────────────────────────────────────

const Map<String, Map<String, String>> _demoChatMap = {
  'it': _itChat,
  'ar': _arChat,
  'es': _esChat,
};

const Map<String, Map<String, String>> _demoCompanyDescriptionMap = {
  'it': _itCompanyDescriptions,
  'ar': _arCompanyDescriptions,
  'es': _esCompanyDescriptions,
};

const Map<String, Map<String, String>> _demoPostBodyMap = {
  'it': _itPostBodies,
  'ar': _arPostBodies,
  'es': _esPostBodies,
};

const Map<String, Map<String, String>> _demoCommentMap = {
  'it': _itComments,
  'ar': _arComments,
  'es': _esComments,
};

// ── Italian company descriptions ──
const Map<String, String> _itCompanyDescriptions = {
  "London's premier event florist specializing in luxury arrangements for weddings, corporate events, and hospitality venues. We create stunning floral designs that transform any space.":
      'Il fiorista di eventi più prestigioso di Londra, specializzato in composizioni di lusso per matrimoni, eventi aziendali e strutture ricettive. Creiamo design floreali straordinari che trasformano qualsiasi spazio.',
  'Premium beverage supplier serving hotels, restaurants, and bars across the UAE. From craft cocktails to fine wines, we deliver excellence in every bottle.':
      'Fornitore premium di beverage per hotel, ristoranti e bar in tutti gli Emirati. Dai cocktail artigianali ai grandi vini, eccellenza in ogni bottiglia.',
  'Professional DJ and AV services for events of all sizes. State-of-the-art equipment and experienced DJs to make your event unforgettable.':
      'Servizi DJ e audio-video professionali per eventi di ogni dimensione. Attrezzature all\'avanguardia e DJ esperti per rendere il tuo evento indimenticabile.',
  'Your one-stop shop for professional kitchen equipment. We supply top-quality commercial kitchen gear to restaurants, hotels, and catering companies.':
      'Il tuo punto di riferimento per attrezzature professionali da cucina. Forniamo strumenti di alta qualità per cucine commerciali a ristoranti, hotel e aziende di catering.',
  'Luxury event decoration and design services. We specialize in creating breathtaking settings for weddings, galas, and corporate events in Dubai.':
      'Servizi di decorazione e design per eventi di lusso. Creiamo scenografie mozzafiato per matrimoni, gala ed eventi aziendali a Dubai.',
  'Professional cleaning services for hospitality businesses. We keep your venue spotless with eco-friendly products and reliable teams.':
      'Servizi di pulizia professionale per il settore dell\'ospitalità. Manteniamo il tuo locale impeccabile con prodotti eco-sostenibili e team affidabili.',
  'Fresh food supplier delivering quality ingredients to restaurants and caterers across London. Farm-to-table produce, meats, and specialty items.':
      'Fornitore di prodotti freschi per ristoranti e catering a Londra. Materie prime dalla fattoria alla tavola, carni e specialità.',
  'Modern POS systems designed for hospitality. Cloud-based solutions for restaurants, bars, and hotels with real-time analytics and inventory management.':
      'Sistemi POS moderni progettati per l\'ospitalità. Soluzioni cloud per ristoranti, bar e hotel con analisi in tempo reale e gestione del magazzino.',
};

// ── Arabic company descriptions ──
const Map<String, String> _arCompanyDescriptions = {
  "London's premier event florist specializing in luxury arrangements for weddings, corporate events, and hospitality venues. We create stunning floral designs that transform any space.":
      'بائع الأزهار الأول للفعاليات في لندن، متخصص في الترتيبات الفاخرة لحفلات الزفاف والفعاليات المؤسسية وأماكن الضيافة. نصمّم تنسيقات زهور مذهلة تحوّل أي مكان.',
  'Premium beverage supplier serving hotels, restaurants, and bars across the UAE. From craft cocktails to fine wines, we deliver excellence in every bottle.':
      'مورّد مشروبات فاخر يخدم الفنادق والمطاعم والبارات في جميع أنحاء الإمارات. من الكوكتيلات الحرفية إلى أجود النبيذ، نقدّم التميز في كل زجاجة.',
  'Professional DJ and AV services for events of all sizes. State-of-the-art equipment and experienced DJs to make your event unforgettable.':
      'خدمات دي جي ومعدات صوت وصورة احترافية لفعاليات بجميع الأحجام. معدات متطورة ومنسّقو موسيقى خبراء لجعل حدثك لا يُنسى.',
  'Your one-stop shop for professional kitchen equipment. We supply top-quality commercial kitchen gear to restaurants, hotels, and catering companies.':
      'وجهتك الشاملة لمعدات المطاعم الاحترافية. نوفّر أجود معدات المطابخ التجارية للمطاعم والفنادق وشركات التموين.',
  'Luxury event decoration and design services. We specialize in creating breathtaking settings for weddings, galas, and corporate events in Dubai.':
      'خدمات ديكور وتصميم فعاليات فاخرة. نتخصص في ابتكار أجواء خلّابة لحفلات الزفاف والفعاليات الكبرى والمؤسسية في دبي.',
  'Professional cleaning services for hospitality businesses. We keep your venue spotless with eco-friendly products and reliable teams.':
      'خدمات تنظيف احترافية لقطاع الضيافة. نحافظ على نظافة مكانك باستخدام منتجات صديقة للبيئة وفرق موثوقة.',
  'Fresh food supplier delivering quality ingredients to restaurants and caterers across London. Farm-to-table produce, meats, and specialty items.':
      'مورد أغذية طازجة يوصل مكونات عالية الجودة للمطاعم وشركات التموين في لندن. منتجات من المزرعة إلى المائدة، ولحوم وأصناف مميزة.',
  'Modern POS systems designed for hospitality. Cloud-based solutions for restaurants, bars, and hotels with real-time analytics and inventory management.':
      'أنظمة نقاط بيع حديثة مصممة لقطاع الضيافة. حلول سحابية للمطاعم والبارات والفنادق مع تحليلات لحظية وإدارة مخزون.',
};

// ── Italian ──
const Map<String, String> _itChat = {
  // Ritz conversation bodies
  'Thank you for applying to the Waiter position at The Ritz.':
      'Grazie per esserti candidato alla posizione di Cameriere presso The Ritz.',
  'We have reviewed your profile and are impressed with your experience.':
      'Abbiamo esaminato il tuo profilo e siamo colpiti dalla tua esperienza.',
  "Thank you! I'm very excited about this opportunity.":
      'Grazie! Sono molto entusiasta di questa opportunità.',
  "We'd love to invite you for an interview. Are you available this Saturday?":
      'Ci piacerebbe invitarti per un colloquio. Sei disponibile sabato?',
  'Yes, Saturday works perfectly for me. What time?':
      'Sì, sabato va benissimo. A che ora?',

  // Last-message previews from mock conversations
  "We'd love to invite you for an interview":
      'Ci piacerebbe invitarti per un colloquio',
  'Your application is under review': 'La tua candidatura è in revisione',
  "Congratulations! You've been shortlisted":
      'Congratulazioni! Sei stato selezionato',
  'Looking forward to the interview on Saturday!':
      'Non vedo l\'ora del colloquio di sabato!',
  'Thank you for reviewing my application':
      'Grazie per aver esaminato la mia candidatura',
  'When can I expect to hear back?': 'Quando posso aspettarmi una risposta?',

  // Service messaging
  'Thank you for your inquiry!': 'Grazie per la tua richiesta!',
  "We'd be happy to arrange a quote":
      'Saremo felici di preparare un preventivo',

  // Status / system short strings
  'Typing...': 'Sta scrivendo...',
  'Seen': 'Visualizzato',
  'Delivered': 'Consegnato',
};

// ── Arabic ──
const Map<String, String> _arChat = {
  // Ritz conversation bodies
  'Thank you for applying to the Waiter position at The Ritz.':
      'شكرًا لتقدمك لوظيفة نادل في فندق The Ritz.',
  'We have reviewed your profile and are impressed with your experience.':
      'لقد راجعنا ملفك الشخصي وأعجبتنا خبرتك.',
  "Thank you! I'm very excited about this opportunity.":
      'شكرًا لكم! أنا متحمس جدًا لهذه الفرصة.',
  "We'd love to invite you for an interview. Are you available this Saturday?":
      'نود دعوتك لإجراء مقابلة. هل أنت متاح يوم السبت؟',
  'Yes, Saturday works perfectly for me. What time?':
      'نعم، السبت مناسب تمامًا. في أي ساعة؟',

  // Last-message previews
  "We'd love to invite you for an interview": 'نود دعوتك لإجراء مقابلة',
  'Your application is under review': 'طلبك قيد المراجعة',
  "Congratulations! You've been shortlisted":
      'تهانينا! تمت إضافتك إلى القائمة المختصرة',
  'Looking forward to the interview on Saturday!':
      'أتطلع إلى المقابلة يوم السبت!',
  'Thank you for reviewing my application':
      'شكرًا لمراجعة طلبي',
  'When can I expect to hear back?': 'متى يمكنني توقع الرد؟',

  // Service messaging
  'Thank you for your inquiry!': 'شكرًا على استفسارك!',
  "We'd be happy to arrange a quote":
      'يسعدنا إعداد عرض أسعار',

  // Status / system short strings
  'Typing...': 'يكتب...',
  'Seen': 'تمت المشاهدة',
  'Delivered': 'تم التسليم',
};

// ─────────────────────────────────────────────
// Demo community POST BODIES — seeded in mock_data.dart
// ─────────────────────────────────────────────

const Map<String, String> _itPostBodies = {
  'Just finished a 14-hour shift and the team absolutely smashed it tonight. Proud of everyone in the kitchen. This is what hospitality is all about.':
      'Appena finito un turno di 14 ore e la squadra è stata strepitosa stasera. Orgoglioso di tutti in cucina. Questa è l\'essenza dell\'ospitalità.',
  "We're opening our second Dubai venue next month and hiring across all roles. Great team, world-class kitchen, competitive pay. Check our jobs board!":
      'Il mese prossimo apriamo il nostro secondo locale a Dubai e stiamo assumendo in tutti i ruoli. Squadra fantastica, cucina di livello mondiale, stipendio competitivo. Dai un\'occhiata alla bacheca lavori!',
  'Tip for new sommeliers: always taste the wine before presenting it to the table. Seems obvious but I see it missed regularly. The guest experience starts with confidence.':
      'Consiglio per i nuovi sommelier: assaggiate sempre il vino prima di presentarlo al tavolo. Sembra ovvio ma viene spesso dimenticato. L\'esperienza dell\'ospite inizia dalla sicurezza.',
  'New cocktail menu drops next week — here is a sneak peek of the signature drink.':
      'Il nuovo menu cocktail esce la prossima settimana — ecco un\'anteprima del drink signature.',
  'Behind the scenes at our annual staff awards. The team that makes the magic happen every single night.':
      'Dietro le quinte dei nostri premi annuali allo staff. La squadra che rende possibile la magia ogni singola sera.',
  'Hospitality networking event next Thursday in Barcelona. DM me for details — great chance to meet industry professionals.':
      'Evento di networking nel settore hospitality giovedì prossimo a Barcellona. Mandatemi un messaggio per i dettagli — ottima occasione per conoscere professionisti del settore.',
  'BUY FOLLOWERS NOW! Click my profile for amazing offers and instant cash.':
      'COMPRA FOLLOWER ORA! Clicca sul mio profilo per offerte incredibili e guadagni immediati.',
};

const Map<String, String> _arPostBodies = {
  'Just finished a 14-hour shift and the team absolutely smashed it tonight. Proud of everyone in the kitchen. This is what hospitality is all about.':
      'أنهيت للتو مناوبة مدتها 14 ساعة والفريق أبدع الليلة. فخور بكل من في المطبخ. هذا هو جوهر الضيافة.',
  "We're opening our second Dubai venue next month and hiring across all roles. Great team, world-class kitchen, competitive pay. Check our jobs board!":
      'سنفتتح فرعنا الثاني في دبي الشهر المقبل ونوظف في جميع المناصب. فريق رائع، مطبخ عالمي، رواتب تنافسية. تفقّدوا لوحة الوظائف لدينا!',
  'Tip for new sommeliers: always taste the wine before presenting it to the table. Seems obvious but I see it missed regularly. The guest experience starts with confidence.':
      'نصيحة لسقاة النبيذ الجدد: تذوّقوا النبيذ دائمًا قبل تقديمه إلى الطاولة. يبدو الأمر بديهيًا لكنني ألاحظ تجاهله كثيرًا. تجربة الضيف تبدأ من الثقة.',
  'New cocktail menu drops next week — here is a sneak peek of the signature drink.':
      'قائمة الكوكتيلات الجديدة تنطلق الأسبوع المقبل — إليكم لمحة عن المشروب المميز.',
  'Behind the scenes at our annual staff awards. The team that makes the magic happen every single night.':
      'من كواليس حفل جوائز الموظفين السنوي. الفريق الذي يصنع السحر كل ليلة.',
  'Hospitality networking event next Thursday in Barcelona. DM me for details — great chance to meet industry professionals.':
      'فعالية تواصل لقطاع الضيافة الخميس المقبل في برشلونة. راسلوني للتفاصيل — فرصة رائعة للقاء محترفي القطاع.',
  'BUY FOLLOWERS NOW! Click my profile for amazing offers and instant cash.':
      'اشتروا المتابعين الآن! اضغطوا على ملفي للحصول على عروض مذهلة وأموال فورية.',
};

// ─────────────────────────────────────────────
// Demo community COMMENTS — seeded in mock_data.dart
// ─────────────────────────────────────────────

const Map<String, String> _itComments = {
  'This is the spirit! Hard work pays off.':
      'Questo è lo spirito giusto! Il duro lavoro paga sempre.',
  'Respect — kitchens are tough but rewarding.':
      'Rispetto — le cucine sono toste ma gratificanti.',
  'Will be applying! Always wanted to work with Nobu.':
      'Mi candiderò! Ho sempre voluto lavorare con Nobu.',
  'Solid advice — I was guilty of this in my first month.':
      'Ottimo consiglio — ci sono cascato anch\'io nel primo mese.',
  'Looks fantastic — congrats to the whole team!':
      'Sembra fantastico — complimenti a tutta la squadra!',
  'Great post!': 'Ottimo post!',
  'Thanks for sharing': 'Grazie per la condivisione',
  'Amazing work!': 'Lavoro straordinario!',
  'Great opportunity!': 'Grande opportunità!',
  'Looking for a new challenge': 'In cerca di una nuova sfida',
  '@you should check this — great fit!':
      '@te dovresti dare un\'occhiata — perfetto per te!',
};

const Map<String, String> _arComments = {
  'This is the spirit! Hard work pays off.':
      'هذه هي الروح المطلوبة! العمل الجاد يؤتي ثماره.',
  'Respect — kitchens are tough but rewarding.':
      'كل الاحترام — المطابخ قاسية لكنها مجزية.',
  'Will be applying! Always wanted to work with Nobu.':
      'سأتقدم بالتأكيد! لطالما أردت العمل مع Nobu.',
  'Solid advice — I was guilty of this in my first month.':
      'نصيحة قيّمة — وقعت في هذا الخطأ في شهري الأول.',
  'Looks fantastic — congrats to the whole team!':
      'يبدو رائعًا — تهانينا للفريق بأكمله!',
  'Great post!': 'منشور رائع!',
  'Thanks for sharing': 'شكرًا على المشاركة',
  'Amazing work!': 'عمل مذهل!',
  'Great opportunity!': 'فرصة رائعة!',
  'Looking for a new challenge': 'أبحث عن تحدٍّ جديد',
  '@you should check this — great fit!':
      '@أنت عليك إلقاء نظرة — يناسبك تمامًا!',
};

// ─────────────────────────────────────────────
// Spanish ─ mirrors the IT / AR sets above.
// ─────────────────────────────────────────────

const Map<String, String> _esCompanyDescriptions = {
  "London's premier event florist specializing in luxury arrangements for weddings, corporate events, and hospitality venues. We create stunning floral designs that transform any space.":
      'El florista de eventos más prestigioso de Londres, especializado en arreglos de lujo para bodas, eventos corporativos y locales de hostelería. Creamos diseños florales impresionantes que transforman cualquier espacio.',
  'Premium beverage supplier serving hotels, restaurants, and bars across the UAE. From craft cocktails to fine wines, we deliver excellence in every bottle.':
      'Proveedor premium de bebidas para hoteles, restaurantes y bares en los Emiratos Árabes Unidos. Desde cócteles artesanales hasta vinos de alta gama, ofrecemos excelencia en cada botella.',
  'Professional DJ and AV services for events of all sizes. State-of-the-art equipment and experienced DJs to make your event unforgettable.':
      'Servicios profesionales de DJ y audiovisuales para eventos de todos los tamaños. Equipamiento de última generación y DJ con experiencia para hacer tu evento inolvidable.',
  'Your one-stop shop for professional kitchen equipment. We supply top-quality commercial kitchen gear to restaurants, hotels, and catering companies.':
      'Tu tienda integral de equipamiento profesional de cocina. Suministramos material de cocina comercial de máxima calidad a restaurantes, hoteles y empresas de catering.',
  'Luxury event decoration and design services. We specialize in creating breathtaking settings for weddings, galas, and corporate events in Dubai.':
      'Servicios de decoración y diseño para eventos de lujo. Nos especializamos en crear escenarios impresionantes para bodas, galas y eventos corporativos en Dubái.',
  'Professional cleaning services for hospitality businesses. We keep your venue spotless with eco-friendly products and reliable teams.':
      'Servicios profesionales de limpieza para empresas de hostelería. Mantenemos tu local impecable con productos ecológicos y equipos de confianza.',
  'Fresh food supplier delivering quality ingredients to restaurants and caterers across London. Farm-to-table produce, meats, and specialty items.':
      'Proveedor de alimentos frescos que entrega ingredientes de calidad a restaurantes y caterings de Londres. Productos del campo a la mesa, carnes y especialidades.',
  'Modern POS systems designed for hospitality. Cloud-based solutions for restaurants, bars, and hotels with real-time analytics and inventory management.':
      'Sistemas POS modernos diseñados para la hostelería. Soluciones en la nube para restaurantes, bares y hoteles con analítica en tiempo real y gestión de inventario.',
};

const Map<String, String> _esChat = {
  // Ritz conversation bodies
  'Thank you for applying to the Waiter position at The Ritz.':
      'Gracias por postular al puesto de Camarero en The Ritz.',
  'We have reviewed your profile and are impressed with your experience.':
      'Hemos revisado tu perfil y nos ha impresionado tu experiencia.',
  "Thank you! I'm very excited about this opportunity.":
      '¡Gracias! Estoy muy ilusionado con esta oportunidad.',
  "We'd love to invite you for an interview. Are you available this Saturday?":
      'Nos encantaría invitarte a una entrevista. ¿Tienes disponibilidad el sábado?',
  'Yes, Saturday works perfectly for me. What time?':
      'Sí, el sábado me viene perfecto. ¿A qué hora?',

  // Last-message previews from mock conversations
  "We'd love to invite you for an interview":
      'Nos encantaría invitarte a una entrevista',
  'Your application is under review': 'Tu candidatura está en revisión',
  "Congratulations! You've been shortlisted":
      '¡Enhorabuena! Has entrado en la shortlist',
  'Looking forward to the interview on Saturday!':
      '¡Con muchas ganas de la entrevista del sábado!',
  'Thank you for reviewing my application':
      'Gracias por revisar mi candidatura',
  'When can I expect to hear back?': '¿Cuándo puedo esperar una respuesta?',

  // Service messaging
  'Thank you for your inquiry!': '¡Gracias por tu consulta!',
  "We'd be happy to arrange a quote":
      'Estaremos encantados de preparar un presupuesto',

  // Status / system short strings
  'Typing...': 'Escribiendo...',
  'Seen': 'Visto',
  'Delivered': 'Entregado',
};

const Map<String, String> _esPostBodies = {
  'Just finished a 14-hour shift and the team absolutely smashed it tonight. Proud of everyone in the kitchen. This is what hospitality is all about.':
      'Acabo de terminar un turno de 14 horas y el equipo ha estado brillante esta noche. Orgulloso de todos los de la cocina. Esto es lo que significa la hostelería.',
  "We're opening our second Dubai venue next month and hiring across all roles. Great team, world-class kitchen, competitive pay. Check our jobs board!":
      'El mes que viene abrimos nuestro segundo local en Dubái y contratamos para todos los puestos. Gran equipo, cocina de primer nivel, sueldo competitivo. ¡Echa un vistazo a nuestro tablón de empleo!',
  'Tip for new sommeliers: always taste the wine before presenting it to the table. Seems obvious but I see it missed regularly. The guest experience starts with confidence.':
      'Consejo para sommeliers nuevos: probad siempre el vino antes de presentarlo a la mesa. Parece obvio pero se olvida a menudo. La experiencia del cliente empieza con la confianza.',
  'New cocktail menu drops next week — here is a sneak peek of the signature drink.':
      'La nueva carta de cócteles sale la semana que viene — aquí un adelanto de la copa estrella.',
  'Behind the scenes at our annual staff awards. The team that makes the magic happen every single night.':
      'Entre bastidores de nuestros premios anuales al personal. El equipo que hace posible la magia cada noche.',
  'Hospitality networking event next Thursday in Barcelona. DM me for details — great chance to meet industry professionals.':
      'Evento de networking del sector hostelero el próximo jueves en Barcelona. Mándame un DM para los detalles — gran oportunidad para conocer a profesionales del sector.',
  'BUY FOLLOWERS NOW! Click my profile for amazing offers and instant cash.':
      '¡COMPRA SEGUIDORES YA! Haz clic en mi perfil para ofertas increíbles y dinero al instante.',
};

const Map<String, String> _esComments = {
  'This is the spirit! Hard work pays off.':
      '¡Este es el espíritu! El trabajo duro siempre se recompensa.',
  'Respect — kitchens are tough but rewarding.':
      'Respeto — las cocinas son duras pero gratificantes.',
  'Will be applying! Always wanted to work with Nobu.':
      '¡Me postularé! Siempre he querido trabajar con Nobu.',
  'Solid advice — I was guilty of this in my first month.':
      'Gran consejo — yo caí en esto durante mi primer mes.',
  'Looks fantastic — congrats to the whole team!':
      'Se ve fantástico — ¡enhorabuena a todo el equipo!',
  'Great post!': '¡Gran publicación!',
  'Thanks for sharing': 'Gracias por compartir',
  'Amazing work!': '¡Trabajo increíble!',
  'Great opportunity!': '¡Gran oportunidad!',
  'Looking for a new challenge': 'Buscando un nuevo reto',
  '@you should check this — great fit!':
      '@deberías echar un vistazo — ¡encaja perfecto!',
};
