// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Plagit';

  @override
  String get welcome => '欢迎';

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册';

  @override
  String get createAccount => '创建账户';

  @override
  String get createBusinessAccount => '创建企业账户';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get email => '邮箱地址';

  @override
  String get password => '密码';

  @override
  String get continueLabel => '继续';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get done => '完成';

  @override
  String get retry => '重试';

  @override
  String get search => '搜索';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get apply => '应用';

  @override
  String get clear => '清除';

  @override
  String get clearAll => '全部清除';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get home => '主页';

  @override
  String get jobs => '职位';

  @override
  String get messages => '消息';

  @override
  String get profile => '我的';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get logout => '退出登录';

  @override
  String get categoryAndRole => '类别与岗位';

  @override
  String get selectCategory => '选择类别';

  @override
  String get subcategory => '子类别';

  @override
  String get role => '岗位';

  @override
  String get recentSearches => '最近搜索';

  @override
  String noResultsFor(String query) {
    return '未找到\"$query\"的结果';
  }

  @override
  String get mostPopular => '热门';

  @override
  String get allCategories => '全部类别';

  @override
  String get selectVenueTypeAndRole => '选择场所类型和岗位';

  @override
  String get selectCategoryAndRole => '选择类别和岗位';

  @override
  String get businessDetails => '企业信息';

  @override
  String get yourDetails => '个人信息';

  @override
  String get companyName => '公司名称';

  @override
  String get contactPerson => '联系人';

  @override
  String get location => '位置';

  @override
  String get website => '网站';

  @override
  String get fullName => '姓名';

  @override
  String get yearsExperience => '工作年限';

  @override
  String get languagesSpoken => '掌握语言';

  @override
  String get jobType => '职位类型';

  @override
  String get jobTypeFullTime => '全职';

  @override
  String get jobTypePartTime => '兼职';

  @override
  String get jobTypeTemporary => '临时';

  @override
  String get jobTypeFreelance => '自由职业';

  @override
  String get openToInternational => '接受国际候选人';

  @override
  String get passwordHint => '密码（至少8位）';

  @override
  String get termsOfServiceNote => '创建账户即表示同意《服务条款》和《隐私政策》。';

  @override
  String get networkError => '网络错误';

  @override
  String get somethingWentWrong => '出错了';

  @override
  String get loading => '加载中…';

  @override
  String get errorGeneric => '发生意外错误，请重试。';

  @override
  String get joinAsCandidate => '求职者注册';

  @override
  String get joinAsBusiness => '企业注册';

  @override
  String get findYourNextRole => '寻找你的下一份餐饮服务工作';

  @override
  String get candidateLoginSubtitle => '与伦敦、迪拜等顶级雇主建立联系。';

  @override
  String get businessLoginSubtitle => '接触顶尖餐饮服务人才，壮大你的团队。';

  @override
  String get rememberMe => '记住我';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get lookingForStaff => '招聘员工？';

  @override
  String get lookingForJob => '寻找工作？';

  @override
  String get switchToBusiness => '切换到企业端';

  @override
  String get switchToCandidate => '切换到求职端';

  @override
  String get createYourProfile => '创建你的档案，让顶级雇主发现你。';

  @override
  String get createBusinessProfile => '创建企业档案，招聘顶尖餐饮服务人才。';

  @override
  String get locationCityCountry => '位置（城市、国家）';

  @override
  String get termsAgreement => '创建账户即表示同意《服务条款》和《隐私政策》。';

  @override
  String get searchHospitalityHint => '搜索类别、子类别或岗位…';

  @override
  String get mostCommonRoles => '常见岗位';

  @override
  String get allRoles => '全部岗位';

  @override
  String suggestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count条建议',
    );
    return '$_temp0';
  }

  @override
  String subcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个子类别',
    );
    return '$_temp0';
  }

  @override
  String rolesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个岗位',
    );
    return '$_temp0';
  }

  @override
  String get kindCategory => '类别';

  @override
  String get kindSubcategory => '子类别';

  @override
  String get kindRole => '岗位';

  @override
  String get resetPassword => '重置密码';

  @override
  String get forgotPasswordSubtitle => '输入邮箱，我们将发送密码重置链接。';

  @override
  String get sendResetLink => '发送重置链接';

  @override
  String get resetEmailSent => '若该邮箱存在账户，重置链接已发送。';

  @override
  String get profileSetupTitle => '完善个人档案';

  @override
  String get profileSetupSubtitle => '完整的档案更容易被发现。';

  @override
  String get uploadPhoto => '上传照片';

  @override
  String get uploadCV => '上传简历';

  @override
  String get skipForNow => '暂时跳过';

  @override
  String get finish => '完成';

  @override
  String get noInternet => '无网络连接，请检查网络。';

  @override
  String get tryAgain => '再试一次';

  @override
  String get emptyJobs => '暂无职位';

  @override
  String get emptyApplications => '暂无申请';

  @override
  String get emptyMessages => '暂无消息';

  @override
  String get emptyNotifications => '全部已读';

  @override
  String get onboardingRoleTitle => '你在寻找什么岗位？';

  @override
  String get onboardingRoleSubtitle => '可多选';

  @override
  String get onboardingExperienceTitle => '你有多少工作经验？';

  @override
  String get onboardingLocationTitle => '你在哪里工作？';

  @override
  String get onboardingLocationHint => '输入城市或邮编';

  @override
  String get useMyCurrentLocation => '使用当前位置';

  @override
  String get onboardingAvailabilityTitle => '你在找什么？';

  @override
  String get finishSetup => '完成设置';

  @override
  String get goodMorning => '早上好';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get goodEvening => '晚上好';

  @override
  String get findJobs => '找工作';

  @override
  String get applications => '我的申请';

  @override
  String get community => '社区';

  @override
  String get recommendedForYou => '为你推荐';

  @override
  String get seeAll => '查看全部';

  @override
  String get searchJobsHint => '搜索职位、岗位、地点…';

  @override
  String get searchJobs => '搜索职位';

  @override
  String get postedJob => '发布';

  @override
  String get applyNow => '立即申请';

  @override
  String get applied => '已申请';

  @override
  String get saveJob => '收藏';

  @override
  String get saved => '已收藏';

  @override
  String get jobDescription => '职位描述';

  @override
  String get requirements => '任职要求';

  @override
  String get benefits => '福利待遇';

  @override
  String get salary => '薪资';

  @override
  String get contract => '合同';

  @override
  String get schedule => '班次';

  @override
  String get viewCompany => '查看公司';

  @override
  String get interview => '面试';

  @override
  String get interviews => '面试';

  @override
  String get notifications => '通知';

  @override
  String get matches => '匹配';

  @override
  String get quickPlug => 'Quick Plug';

  @override
  String get discover => '发现';

  @override
  String get shortlist => '候选';

  @override
  String get message => '消息';

  @override
  String get messageCandidate => '消息';

  @override
  String get nextInterview => '下次面试';

  @override
  String get loadingDashboard => '加载中…';

  @override
  String get tryAgainCta => '重试';

  @override
  String get careerDashboard => '职业面板';

  @override
  String get yourNextInterview => '你的下次面试';

  @override
  String get yourCareerTakingOff => '你的职业';

  @override
  String get yourCareerOnTheMove => '你的职业';

  @override
  String get yourJourneyStartsHere => '你的旅程\n从这里开始';

  @override
  String get applyFirstJob => '申请第一份工作开启旅程';

  @override
  String get interviewComingUp => '即将面试';

  @override
  String get unlockPlagitPremium => '解锁 Plagit Premium';

  @override
  String get premiumSubtitle => '在顶级场所中脱颖而出，更快匹配';

  @override
  String get premiumActive => 'Premium 已激活';

  @override
  String get premiumActiveSubtitle => '优先曝光已开启 · 管理订阅';

  @override
  String get noJobsFound => '没有符合搜索的职位';

  @override
  String get noApplicationsYet => '暂无申请';

  @override
  String get startApplying => '开始浏览职位去申请';

  @override
  String get noMessagesYet => '暂无消息';

  @override
  String get allCaughtUp => '全部已读';

  @override
  String get noNotificationsYet => '暂无通知';

  @override
  String get about => '简介';

  @override
  String get experience => '经验';

  @override
  String get skills => '技能';

  @override
  String get languages => '语言';

  @override
  String get availability => '可用状态';

  @override
  String get verified => '已认证';

  @override
  String get totalViews => '总浏览';

  @override
  String get verifiedVenuePrefix => '已认证';

  @override
  String get notVerified => '未认证';

  @override
  String get pendingReview => '审核中';

  @override
  String get viewProfile => '查看档案';

  @override
  String get editProfile => '编辑档案';

  @override
  String get share => '分享';

  @override
  String get report => '举报';

  @override
  String get block => '屏蔽';

  @override
  String get typeMessage => '输入消息…';

  @override
  String get send => '发送';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get now => '刚刚';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分钟前',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count小时前',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count天前',
    );
    return '$_temp0';
  }

  @override
  String get filters => '筛选';

  @override
  String get refineSearch => '优化搜索';

  @override
  String get distance => '距离';

  @override
  String get applyFilters => '应用筛选';

  @override
  String get reset => '重置';

  @override
  String noResultsTitle(String query) {
    return '未找到\"$query\"的结果';
  }

  @override
  String get noResultsSubtitle => '请尝试其他关键词或清除搜索。';

  @override
  String get recentSearchesEmptyTitle => '暂无最近搜索';

  @override
  String get recentSearchesEmptyHint => '你的最近搜索将显示在这里';

  @override
  String get allJobs => '全部职位';

  @override
  String get nearby => '附近';

  @override
  String get saved2 => '已收藏';

  @override
  String get remote => '远程';

  @override
  String get inPerson => '现场';

  @override
  String get aboutTheJob => '关于岗位';

  @override
  String get aboutCompany => '关于公司';

  @override
  String get applyForJob => '申请此职位';

  @override
  String get unsaveJob => '取消收藏';

  @override
  String get noJobsNearby => '附近暂无职位';

  @override
  String get noSavedJobs => '暂无收藏';

  @override
  String get adjustFilters => '调整筛选查看更多职位';

  @override
  String get fullTime => '全职';

  @override
  String get partTime => '兼职';

  @override
  String get temporary => '临时';

  @override
  String get freelance => '自由职业';

  @override
  String postedAgo(String time) {
    return '发布于 $time';
  }

  @override
  String kmAway(String km) {
    return '$km 公里';
  }

  @override
  String get jobDetails => '职位详情';

  @override
  String get aboutThisRole => '关于此岗位';

  @override
  String get aboutTheBusiness => '关于企业';

  @override
  String get urgentHiring => '急招';

  @override
  String get distanceRadius => '距离范围';

  @override
  String get contractType => '合同类型';

  @override
  String get shiftType => '班次类型';

  @override
  String get all => '全部';

  @override
  String get casual => '零工';

  @override
  String get seasonal => '季节性';

  @override
  String get morning => '早班';

  @override
  String get afternoon => '午班';

  @override
  String get evening => '晚班';

  @override
  String get night => '夜班';

  @override
  String get startDate => '开始日期';

  @override
  String get shiftHours => '工作时长';

  @override
  String get category => '类别';

  @override
  String get venueType => '场所类型';

  @override
  String get employment => '雇佣形式';

  @override
  String get pay => '薪酬';

  @override
  String get duration => '期限';

  @override
  String get weeklyHours => '周工时';

  @override
  String get businessLocation => '企业位置';

  @override
  String get jobViews => '浏览量';

  @override
  String positions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个岗位',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个月',
    );
    return '$_temp0';
  }

  @override
  String get myApplications => '我的申请';

  @override
  String get active => '进行中';

  @override
  String get interviewStatus => '面试';

  @override
  String get rejected => '未录用';

  @override
  String get offer => '录用';

  @override
  String appliedOn(String date) {
    return '$date 申请';
  }

  @override
  String get viewJob => '查看职位';

  @override
  String get withdraw => '撤回申请';

  @override
  String get applicationStatus => '申请状态';

  @override
  String get noConversations => '暂无对话';

  @override
  String get startConversation => '回复职位开始聊天';

  @override
  String get online => '在线';

  @override
  String get offline => '离线';

  @override
  String lastSeen(String time) {
    return '最后在线 $time';
  }

  @override
  String get newNotification => '新';

  @override
  String get markAllRead => '全部标记已读';

  @override
  String get yourProfile => '我的档案';

  @override
  String completionPercent(int percent) {
    return '完成度 $percent%';
  }

  @override
  String get personalDetails => '个人资料';

  @override
  String get phone => '电话';

  @override
  String get bio => '简介';

  @override
  String get addPhoto => '添加照片';

  @override
  String get addCV => '添加简历';

  @override
  String get saveChanges => '保存更改';

  @override
  String get logoutConfirm => '确定要退出登录吗？';

  @override
  String get subscription => '订阅';

  @override
  String get support => '客服';

  @override
  String get privacy => '隐私';

  @override
  String get terms => '条款';

  @override
  String get applicationDetails => '申请详情';

  @override
  String get timeline => '时间线';

  @override
  String get submitted => '已提交';

  @override
  String get underReview => '审核中';

  @override
  String get interviewScheduled => '面试已安排';

  @override
  String get offerExtended => '已发出录用';

  @override
  String get withdrawApp => '撤回申请';

  @override
  String get withdrawConfirm => '确定要撤回此申请吗？';

  @override
  String get applicationWithdrawn => '申请已撤回';

  @override
  String get statusApplied => '已申请';

  @override
  String get statusInReview => '审核中';

  @override
  String get statusInterview => '面试';

  @override
  String get statusHired => '已录用';

  @override
  String get statusClosed => '已关闭';

  @override
  String get statusRejected => '未录用';

  @override
  String get statusOffer => '录用';

  @override
  String get messagesSearch => '搜索消息…';

  @override
  String get noMessagesTitle => '暂无消息';

  @override
  String get noMessagesSubtitle => '回复职位开始聊天';

  @override
  String get youOnline => '你在线';

  @override
  String get noNotificationsTitle => '暂无通知';

  @override
  String get noNotificationsSubtitle => '有新动态时我们会通知你';

  @override
  String get today2 => '今天';

  @override
  String get earlier => '更早';

  @override
  String get completeYourProfile => '完善档案';

  @override
  String get profileCompletion => '档案完成度';

  @override
  String get personalInfo => '个人信息';

  @override
  String get professional => '职业信息';

  @override
  String get preferences => '偏好';

  @override
  String get documents => '文件';

  @override
  String get myCV => '我的简历';

  @override
  String get premium => 'Premium';

  @override
  String get addLanguages => '添加语言';

  @override
  String get addExperience => '添加经验';

  @override
  String get addAvailability => '添加可用时间';

  @override
  String get matchesTitle => '匹配';

  @override
  String get noMatchesTitle => '暂无匹配';

  @override
  String get noMatchesSubtitle => '继续申请——匹配将出现在这里';

  @override
  String get interestedBusinesses => '感兴趣的企业';

  @override
  String get accept => '接受';

  @override
  String get decline => '拒绝';

  @override
  String get newMatch => '新匹配';

  @override
  String get quickPlugTitle => 'Quick Plug';

  @override
  String get quickPlugEmpty => '暂无新企业';

  @override
  String get quickPlugSubtitle => '稍后再来看看新机会';

  @override
  String get uploadYourCV => '上传简历';

  @override
  String get cvSubtitle => '添加简历快速申请并脱颖而出';

  @override
  String get chooseFile => '选择文件';

  @override
  String get removeCV => '删除简历';

  @override
  String get noCVUploaded => '暂未上传简历';

  @override
  String get discoverCompanies => '发现企业';

  @override
  String get exploreSubtitle => '探索顶级餐饮服务企业';

  @override
  String get follow => '关注';

  @override
  String get following => '已关注';

  @override
  String get view => '查看';

  @override
  String get selectLanguages => '选择语言';

  @override
  String selectedCount(int count) {
    return '已选 $count';
  }

  @override
  String get allLanguages => '全部语言';

  @override
  String get uploadCVBig => '上传简历自动填写档案，节省时间。';

  @override
  String get supportedFormats => '支持格式：PDF、DOC、DOCX';

  @override
  String get fillManually => '手动填写';

  @override
  String get fillManuallySubtitle => '自己填写资料，一步步完善档案。';

  @override
  String get photoUploadSoon => '照片上传即将上线——请先使用专业头像。';

  @override
  String get yourCV => '我的简历';

  @override
  String get aboutYou => '关于你';

  @override
  String get optional => '可选';

  @override
  String get completeProfile => '完成档案';

  @override
  String get openToRelocation => '愿意异地工作';

  @override
  String get matchLabel => '匹配';

  @override
  String get accepted => '已接受';

  @override
  String get deny => '拒绝';

  @override
  String get featured => '精选';

  @override
  String get reviewYourProfile => '确认档案';

  @override
  String get nothingSavedYet => '确认前不会保存任何内容。';

  @override
  String get editAnyField => '保存前可编辑任意字段。';

  @override
  String get saveToProfile => '保存到档案';

  @override
  String get findCompanies => '查找企业';

  @override
  String get mapView => '地图';

  @override
  String get mapComingSoon => '地图功能即将上线。';

  @override
  String get noCompaniesFound => '未找到企业';

  @override
  String get tryWiderRadius => '尝试扩大范围或更换类别。';

  @override
  String get verifiedOnly => '仅认证';

  @override
  String get resetFilters => '重置筛选';

  @override
  String get available => '可用';

  @override
  String lookingFor(String role) {
    return '寻找：$role';
  }

  @override
  String get boostMyProfile => '提升档案';

  @override
  String get openToRelocationTravel => '愿意异地 / 出差';

  @override
  String get tellEmployersAboutYourself => '介绍一下你自己…';

  @override
  String get profileUpdated => '档案已更新';

  @override
  String get contractPreference => '合同偏好';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get languagePickerSoon => '语言选择即将上线';

  @override
  String get selectCategoryRoleShort => '选择类别与岗位';

  @override
  String get cvUploadSoon => '简历上传即将上线';

  @override
  String get restorePurchasesSoon => '恢复购买即将上线';

  @override
  String get photoUploadShort => '照片上传即将上线';

  @override
  String get hireBestTalent => '招聘顶级餐饮服务人才';

  @override
  String get businessLoginSub => '发布职位，联系认证候选人。';

  @override
  String get lookingForWork => '寻找工作？';

  @override
  String get postJob => '发布职位';

  @override
  String get editJob => '编辑职位';

  @override
  String get jobTitle => '职位名称';

  @override
  String get jobDescription2 => '职位描述';

  @override
  String get publish => '发布';

  @override
  String get saveDraft => '保存草稿';

  @override
  String get applicantsTitle => '申请人';

  @override
  String get newApplicants => '新申请';

  @override
  String get noApplicantsYet => '暂无申请人';

  @override
  String get noApplicantsSubtitle => '有人申请后会显示在这里。';

  @override
  String get scheduleInterview => '安排面试';

  @override
  String get sendInvite => '发送邀请';

  @override
  String get interviewSent => '面试邀请已发送';

  @override
  String get rejectCandidate => '拒绝';

  @override
  String get shortlistCandidate => '加入候选';

  @override
  String get hiringDashboard => '招聘面板';

  @override
  String get yourPipelineActive => '你的招聘';

  @override
  String get postJobToStart => '发布第一个职位';

  @override
  String reviewApplicants(int count) {
    return '审阅 $count 位新申请人';
  }

  @override
  String replyMessages(int count) {
    return '回复 $count 条未读消息';
  }

  @override
  String get interviews2 => '面试';

  @override
  String get businessProfile => '企业档案';

  @override
  String get venueGallery => '场所图库';

  @override
  String get addPhotos => '添加照片';

  @override
  String get businessName => '企业名称';

  @override
  String get venueTypeLabel => '场所类型';

  @override
  String selectedItems(int count) {
    return '已选 $count';
  }

  @override
  String get hiringProgress => '招聘进度';

  @override
  String get unlockBusinessPremium => '解锁企业 Premium';

  @override
  String get businessPremiumSubtitle => '优先触达顶级候选人';

  @override
  String get scheduleFromApplicants => '从申请人中安排';

  @override
  String get recentApplicants => '最新申请人';

  @override
  String get viewAll => '查看全部 ›';

  @override
  String get recentActivity => '最近动态';

  @override
  String get candidatePipeline => '候选人流程';

  @override
  String get allApplicants => '全部申请人';

  @override
  String get searchCandidates => '搜索候选人、职位、面试…';

  @override
  String get thisWeek => '本周';

  @override
  String get thisMonth => '本月';

  @override
  String get allTime => '全部时间';

  @override
  String get post => '发布';

  @override
  String get candidates => '候选人';

  @override
  String get applicantDetail => '申请人详情';

  @override
  String get candidateProfile => '候选人档案';

  @override
  String get shortlistTitle => '候选名单';

  @override
  String get noShortlistedCandidates => '暂无候选';

  @override
  String get shortlistEmpty => '你的候选人将显示在这里';

  @override
  String get removeFromShortlist => '移出候选';

  @override
  String get viewMessages => '查看消息';

  @override
  String get manageJobs => '管理职位';

  @override
  String get yourJobs => '我的职位';

  @override
  String get noJobsPosted => '尚未发布职位';

  @override
  String get noJobsPostedSubtitle => '发布第一个职位开始招聘';

  @override
  String get draftJobs => '草稿';

  @override
  String get activeJobs => '进行中';

  @override
  String get expiredJobs => '已过期';

  @override
  String get closedJobs => '已关闭';

  @override
  String get createJob => '创建职位';

  @override
  String get jobDetailsTitle => '职位详情';

  @override
  String get salaryRange => '薪资范围';

  @override
  String get currency => '币种';

  @override
  String get monthly => '月薪';

  @override
  String get annual => '年薪';

  @override
  String get hourly => '时薪';

  @override
  String get minSalary => '最低';

  @override
  String get maxSalary => '最高';

  @override
  String get perks => '福利';

  @override
  String get addPerk => '添加福利';

  @override
  String get remove => '移除';

  @override
  String get preview => '预览';

  @override
  String get publishJob => '发布职位';

  @override
  String get jobPublished => '职位已发布';

  @override
  String get jobUpdated => '职位已更新';

  @override
  String get jobSavedDraft => '已保存为草稿';

  @override
  String get fillRequired => '请填写必填字段';

  @override
  String get jobUrgent => '标记为急招';

  @override
  String get addAtLeastOne => '至少添加一个要求';

  @override
  String get createUpdate => '发布动态';

  @override
  String get shareCompanyNews => '分享公司动态';

  @override
  String get addStory => '添加故事';

  @override
  String get showWorkplace => '展示你的工作环境';

  @override
  String get viewShortlist => '查看候选';

  @override
  String get yourSavedCandidates => '你收藏的候选人';

  @override
  String get inviteCandidate => '邀请候选人';

  @override
  String get reachOutDirectly => '直接联系';

  @override
  String activeJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个在招职位',
    );
    return '$_temp0';
  }

  @override
  String get employmentType => '雇佣类型';

  @override
  String get requiredRole => '所需岗位';

  @override
  String get selectCategoryRole2 => '选择类别与岗位';

  @override
  String get hiresNeeded => '招聘人数';

  @override
  String get compensation => '薪酬';

  @override
  String get useSalaryRange => '使用薪资范围';

  @override
  String get contractDuration => '合同期限';

  @override
  String get limitReached => '已达上限';

  @override
  String get upgradePlan => '升级套餐';

  @override
  String usingXofY(int used, int total) {
    return '已使用 $used / $total 个职位发布。';
  }

  @override
  String get businessInterviewsTitle => '面试';

  @override
  String get noInterviewsYet => '暂无面试安排';

  @override
  String get scheduleFirstInterview => '安排第一次与候选人的面试';

  @override
  String get sendInterviewInvite => '发送面试邀请';

  @override
  String get interviewSentTitle => '邀请已发送！';

  @override
  String get interviewSentSubtitle => '候选人已收到通知。';

  @override
  String get scheduleInterviewTitle => '安排面试';

  @override
  String get interviewType => '面试形式';

  @override
  String get inPersonInterview => '现场面试';

  @override
  String get videoCallInterview => '视频面试';

  @override
  String get phoneCallInterview => '电话面试';

  @override
  String get interviewDate => '日期';

  @override
  String get interviewTime => '时间';

  @override
  String get interviewLocation => '地点';

  @override
  String get interviewNotes => '备注';

  @override
  String get optionalLabel => '可选';

  @override
  String get sendInviteCta => '发送邀请';

  @override
  String messagesCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count条消息',
    );
    return '$_temp0';
  }

  @override
  String get noNewMessages => '暂无新消息';

  @override
  String get subscriptionTitle => '订阅';

  @override
  String get currentPlan => '当前套餐';

  @override
  String get manage => '管理';

  @override
  String get upgrade => '升级';

  @override
  String get renewalDate => '续费日期';

  @override
  String get nearbyTalent => '附近人才';

  @override
  String get searchNearby => '搜索附近';

  @override
  String get communityTitle => '社区';

  @override
  String get createPost => '发布帖子';

  @override
  String get insights => '数据';

  @override
  String get viewsLabel => '浏览';

  @override
  String get applicationsLabel => '申请';

  @override
  String get conversionRate => '转化率';

  @override
  String get topPerformingJob => '热门职位';

  @override
  String get viewAllSimple => '查看全部';

  @override
  String get viewAllApplicantsForJob => '查看此职位全部申请人';

  @override
  String get noUpcomingInterviews => '暂无待面试';

  @override
  String get noActivityYet => '暂无动态';

  @override
  String get noResultsFound => '未找到结果';

  @override
  String get renewsAutomatically => '自动续订';

  @override
  String get plagitBusinessPlans => 'Plagit 企业套餐';

  @override
  String get scaleYourHiringSubtitle => '选择最适合你的招聘套餐。';

  @override
  String get yearly => '年度';

  @override
  String get saveWithAnnualBilling => '按年订阅更省钱';

  @override
  String get chooseYourPlanSubtitle => '选择最适合你招聘需求的套餐。';

  @override
  String continueWithPlan(String plan) {
    return '继续使用 $plan';
  }

  @override
  String get subscriptionAutoRenewNote => '订阅自动续订。可随时在设置中取消。';

  @override
  String get purchaseFlowComingSoon => '购买流程即将上线';

  @override
  String get applicant => '申请人';

  @override
  String get applicantNotFound => '未找到申请人';

  @override
  String get cvViewerComingSoon => '简历查看器即将上线';

  @override
  String get viewCV => '查看简历';

  @override
  String get application => '申请';

  @override
  String get messagingComingSoon => '消息功能即将上线';

  @override
  String get interviewConfirmed => '面试已确认';

  @override
  String get interviewMarkedCompleted => '面试已标记完成';

  @override
  String get cancelInterviewConfirm => '确定要取消此次面试吗？';

  @override
  String get yesCancel => '确认取消';

  @override
  String get interviewNotFound => '未找到面试';

  @override
  String get openingMeetingLink => '正在打开会议链接…';

  @override
  String get rescheduleComingSoon => '重新安排功能即将上线';

  @override
  String get notesFeatureComingSoon => '备注功能即将上线';

  @override
  String get candidateMarkedHired => '候选人已标记为录用！';

  @override
  String get feedbackComingSoon => '反馈功能即将上线';

  @override
  String get googleMapsComingSoon => 'Google 地图集成即将上线';

  @override
  String get noCandidatesNearby => '附近暂无候选人';

  @override
  String get tryExpandingRadius => '尝试扩大搜索范围。';

  @override
  String get candidate => '候选人';

  @override
  String get forOpenPosition => '对应职位';

  @override
  String get dateAndTimeUpper => '日期与时间';

  @override
  String get interviewTypeUpper => '面试形式';

  @override
  String get timezoneUpper => '时区';

  @override
  String get highlights => '亮点';

  @override
  String get cvNotAvailable => '暂无简历';

  @override
  String get cvWillAppearHere => '上传后将在此显示';

  @override
  String get seenEveryone => '你已看完所有人';

  @override
  String get checkBackForCandidates => '稍后再来查看新候选人。';

  @override
  String get dailyLimitReached => '已达每日上限';

  @override
  String get upgradeForUnlimitedSwipes => '升级以无限浏览。';

  @override
  String get distanceUpper => '距离';

  @override
  String get inviteToInterview => '邀请面试';

  @override
  String get details => '详情';

  @override
  String get shortlistedSuccessfully => '已加入候选';

  @override
  String get tabDashboard => '面板';

  @override
  String get tabCandidates => '候选人';

  @override
  String get tabActivity => '动态';

  @override
  String get statusPosted => '已发布';

  @override
  String get statusApplicants => '申请人';

  @override
  String get statusInterviewsShort => '面试';

  @override
  String get statusHiredShort => '已录用';

  @override
  String get jobLiveVisible => '你的职位已上线';

  @override
  String get postJobShort => '发布';

  @override
  String get messagesTitle => '消息';

  @override
  String get online2 => '现在在线';

  @override
  String get candidateUpper => '候选人';

  @override
  String get searchConversationsHint => '搜索对话、候选人、岗位…';

  @override
  String get filterUnread => '未读';

  @override
  String get filterAll => '全部';

  @override
  String get whenCandidatesMessage => '候选人发消息时，对话将显示在这里。';

  @override
  String get trySwitchingFilter => '尝试切换其他筛选。';

  @override
  String get reply => '回复';

  @override
  String get selectItems => '选择项目';

  @override
  String countSelected(int count) {
    return '已选 $count';
  }

  @override
  String get selectAll => '全选';

  @override
  String get deleteConversation => '删除对话？';

  @override
  String get deleteAllConversations => '删除全部对话？';

  @override
  String get deleteSelectedNote => '所选对话将从收件箱移除。候选人仍保留其副本。';

  @override
  String get deleteAll => '全部删除';

  @override
  String get selectConversations => '选择对话';

  @override
  String get feedTab => '动态';

  @override
  String get myPostsTab => '我的帖子';

  @override
  String get savedTab => '已保存';

  @override
  String postingAs(String name) {
    return '以 $name 身份发布';
  }

  @override
  String get noPostsYet => '你还没有发布内容';

  @override
  String get nothingHereYet => '这里还空着';

  @override
  String get shareVenueUpdate => '分享场所动态，开始建立社区存在感。';

  @override
  String get communityPostsAppearHere => '社区帖子将显示在这里。';

  @override
  String get createFirstPost => '发布第一条帖子';

  @override
  String get yourPostUpper => '你的帖子';

  @override
  String get businessLabel => '企业';

  @override
  String get profileNotAvailable => '档案不可用';

  @override
  String get companyProfile => '公司档案';

  @override
  String get premiumVenue => 'Premium 场所';

  @override
  String get businessDetailsTitle => '企业信息';

  @override
  String get businessNameLabel => '企业名称';

  @override
  String get categoryLabel => '类别';

  @override
  String get locationLabel => '位置';

  @override
  String get verificationLabel => '认证';

  @override
  String get pendingLabel => '审核中';

  @override
  String get notSet => '未设置';

  @override
  String get contactLabel => '联系方式';

  @override
  String get emailLabel => '邮箱';

  @override
  String get phoneLabel => '电话';

  @override
  String get editProfileTitle => '编辑档案';

  @override
  String get companyNameField => '公司名称';

  @override
  String get phoneField => '电话';

  @override
  String get locationField => '位置';

  @override
  String get signOut => '退出登录';

  @override
  String get signOutTitle => '退出登录？';

  @override
  String get signOutConfirm => '确定要退出登录吗？';

  @override
  String activeCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个进行中',
    );
    return '$_temp0';
  }

  @override
  String newThisWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '本周新增$count个',
    );
    return '$_temp0';
  }

  @override
  String get jobStatusActive => '进行中';

  @override
  String get jobStatusPaused => '已暂停';

  @override
  String get jobStatusClosed => '已关闭';

  @override
  String get jobStatusDraft => '草稿';

  @override
  String get contractCasual => '零工';

  @override
  String get planBasic => '基础版';

  @override
  String get planPro => '专业版';

  @override
  String get planPremium => 'Premium';

  @override
  String get bestForMaxVisibility => '最大曝光推荐';

  @override
  String saveDollarsPerYear(String currency, String amount) {
    return '每年省 $currency$amount';
  }

  @override
  String get planBasicFeature1 => '发布最多3个职位';

  @override
  String get planBasicFeature2 => '查看申请人档案';

  @override
  String get planBasicFeature3 => '基础候选人搜索';

  @override
  String get planBasicFeature4 => '邮件客服';

  @override
  String get planProFeature1 => '发布最多10个职位';

  @override
  String get planProFeature2 => '高级候选人搜索';

  @override
  String get planProFeature3 => '申请人优先排序';

  @override
  String get planProFeature4 => 'Quick Plug 权限';

  @override
  String get planProFeature5 => '在线客服';

  @override
  String get planPremiumFeature1 => '无限发布职位';

  @override
  String get planPremiumFeature2 => '精选职位展示';

  @override
  String get planPremiumFeature3 => '高级数据分析';

  @override
  String get planPremiumFeature4 => 'Quick Plug 无限量';

  @override
  String get planPremiumFeature5 => '优先候选匹配';

  @override
  String get planPremiumFeature6 => '专属客户经理';

  @override
  String get currentSelectionCheck => '当前选择 ✓';

  @override
  String selectPlanName(String plan) {
    return '选择 $plan';
  }

  @override
  String get perYear => '/年';

  @override
  String get perMonth => '/月';

  @override
  String get jobTitleHintExample => '例如：主厨';

  @override
  String get locationHintExample => '例如：迪拜';

  @override
  String annualSalaryLabel(String currency) {
    return '年薪（$currency）';
  }

  @override
  String monthlyPayLabel(String currency) {
    return '月薪（$currency）';
  }

  @override
  String hourlyRateLabel(String currency) {
    return '时薪（$currency）';
  }

  @override
  String minSalaryLabel(String currency) {
    return '最低（$currency）';
  }

  @override
  String maxSalaryLabel(String currency) {
    return '最高（$currency）';
  }

  @override
  String get hoursPerWeekLabel => '周工时';

  @override
  String get expectedHoursWeekLabel => '预计周工时（可选）';

  @override
  String get bonusTipsLabel => '奖金 / 小费（可选）';

  @override
  String get bonusTipsHint => '例如：小费和服务费';

  @override
  String get housingIncludedLabel => '提供住宿';

  @override
  String get travelIncludedLabel => '提供交通';

  @override
  String get overtimeAvailableLabel => '可加班';

  @override
  String get flexibleScheduleLabel => '弹性班次';

  @override
  String get weekendShiftsLabel => '周末班次';

  @override
  String get describeRoleHint => '描述岗位、职责和这份工作的亮点…';

  @override
  String get requirementsHint => '所需技能、经验、证书…';

  @override
  String previewPrefix(String text) {
    return '预览：$text';
  }

  @override
  String monthsShort(int count) {
    return '$count个月';
  }

  @override
  String get roleAll => '全部';

  @override
  String get roleChef => '厨师';

  @override
  String get roleWaiter => '服务员';

  @override
  String get roleBartender => '调酒师';

  @override
  String get roleHost => '接待';

  @override
  String get roleManager => '经理';

  @override
  String get roleReception => '前台';

  @override
  String get roleKitchenPorter => '后厨帮工';

  @override
  String get roleRelocate => '异地工作';

  @override
  String get experience02Years => '0-2年';

  @override
  String get experience35Years => '3-5年';

  @override
  String get experience5PlusYears => '5年以上';

  @override
  String get roleUpper => '岗位';

  @override
  String get experienceUpper => '经验';

  @override
  String get cvLabel => '简历';

  @override
  String get addShort => '添加';

  @override
  String photosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count张照片',
    );
    return '$_temp0';
  }

  @override
  String candidatesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到$count位候选人',
    );
    return '$_temp0';
  }

  @override
  String get maxKmLabel => '最大 50 公里';

  @override
  String get shortlistAction => '候选';

  @override
  String get messageAction => '消息';

  @override
  String get interviewAction => '面试';

  @override
  String get viewAction => '查看';

  @override
  String get rejectAction => '拒绝';

  @override
  String get basedIn => '所在地';

  @override
  String get verificationPending => '认证审核中';

  @override
  String get refreshAction => '刷新';

  @override
  String get upgradeAction => '升级';

  @override
  String get searchJobsByTitleHint => '按标题、岗位或地点搜索职位…';

  @override
  String xShortlisted(String name) {
    return '$name 已加入候选';
  }

  @override
  String xRejected(String name) {
    return '$name 已拒绝';
  }

  @override
  String rejectConfirmName(String name) {
    return '确定要拒绝 $name 吗？';
  }

  @override
  String appliedToRoleOn(String role, String date) {
    return '$date 申请了 $role';
  }

  @override
  String appliedDatePrefix(String date) {
    return '$date 申请';
  }

  @override
  String get salaryExpectationTitle => '期望薪资';

  @override
  String get previousEmployer => '上一任雇主';

  @override
  String get earlierVenue => '更早场所';

  @override
  String get presentLabel => '至今';

  @override
  String get skillCustomerService => '客户服务';

  @override
  String get skillTeamwork => '团队协作';

  @override
  String get skillCommunication => '沟通能力';

  @override
  String get stepApplied => '已申请';

  @override
  String get stepViewed => '已查看';

  @override
  String get stepShortlisted => '已候选';

  @override
  String get stepInterviewScheduled => '面试已安排';

  @override
  String get stepRejected => '未录用';

  @override
  String get stepUnderReview => '审核中';

  @override
  String get stepPendingReview => '待审核';

  @override
  String get sortNewest => '最新';

  @override
  String get sortMostExperienced => '经验丰富';

  @override
  String get sortBestMatch => '最佳匹配';

  @override
  String get filterApplied => '已申请';

  @override
  String get filterUnderReview => '审核中';

  @override
  String get filterShortlisted => '候选';

  @override
  String get filterInterview => '面试';

  @override
  String get filterHired => '已录用';

  @override
  String get filterRejected => '未录用';

  @override
  String get confirmed => '已确认';

  @override
  String get pending => '待定';

  @override
  String get completed => '已完成';

  @override
  String get cancelled => '已取消';

  @override
  String get videoLabel => '视频';

  @override
  String get viewDetails => '查看详情';

  @override
  String get interviewDetails => '面试详情';

  @override
  String get interviewConfirmedHeadline => '面试已确认';

  @override
  String get interviewConfirmedSubline => '一切就绪。临近时间我们会提醒你。';

  @override
  String get dateLabel => '日期';

  @override
  String get timeLabel => '时间';

  @override
  String get formatLabel => '形式';

  @override
  String get joinMeeting => '加入';

  @override
  String get viewJobAction => '查看职位';

  @override
  String get addToCalendar => '加入日历';

  @override
  String get needsYourAttention => '需要你的关注';

  @override
  String get reviewAction => '审阅';

  @override
  String applicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count份申请',
    );
    return '$_temp0';
  }

  @override
  String get sortMostRecent => '最新';

  @override
  String get interviewScheduledLabel => '面试已安排';

  @override
  String get editAction => '编辑';

  @override
  String get currentPlanLabel => '当前套餐';

  @override
  String get freePlan => '免费版';

  @override
  String get profileStrength => '档案强度';

  @override
  String get detailsLabel => '详情';

  @override
  String get basedInLabel => '所在地';

  @override
  String get verificationLabel2 => '认证';

  @override
  String get contactLabel2 => '联系方式';

  @override
  String get notSetLabel => '未设置';

  @override
  String get chipAll => '全部';

  @override
  String get chipFullTime => '全职';

  @override
  String get chipPartTime => '兼职';

  @override
  String get chipTemporary => '临时';

  @override
  String get chipCasual => '零工';

  @override
  String get sortBestMatchLabel => '最佳匹配';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortBy => '排序';

  @override
  String get featuredBadge => '精选';

  @override
  String get urgentBadge => '急招';

  @override
  String get salaryOnRequest => '薪资面议';

  @override
  String get upgradeToPremium => '升级到 Premium';

  @override
  String get urgentJobsOnly => '仅急招职位';

  @override
  String get showOnlyUrgentListings => '只显示急招职位';

  @override
  String get verifiedBusinessesOnly => '仅认证企业';

  @override
  String get showOnlyVerifiedBusinesses => '只显示认证企业';

  @override
  String get split => '对半';

  @override
  String get payUpper => '薪资';

  @override
  String get typeUpper => '类型';

  @override
  String get whereUpper => '地点';

  @override
  String get payLabel => '薪资';

  @override
  String get typeLabel => '类型';

  @override
  String get whereLabel => '地点';

  @override
  String get whereYouWillWork => '工作地点';

  @override
  String get mapPreviewDirections => '地图预览 · 点击查看导航';

  @override
  String get directionsAction => '导航';

  @override
  String get communityTabForYou => '为你推荐';

  @override
  String get communityTabFollowing => '关注';

  @override
  String get communityTabNearby => '附近';

  @override
  String get communityTabSaved => '已保存';

  @override
  String get viewProfileAction => '查看档案';

  @override
  String get copyLinkAction => '复制链接';

  @override
  String get savePostAction => '保存帖子';

  @override
  String get unsavePostAction => '取消保存';

  @override
  String get hideThisPost => '隐藏此帖';

  @override
  String get reportPost => '举报帖子';

  @override
  String get cancelAction => '取消';

  @override
  String get newPostTitle => '新帖子';

  @override
  String get youLabel => '你';

  @override
  String get postingToCommunityAsBusiness => '以企业身份发布到社区';

  @override
  String get postingToCommunityAsPro => '以餐饮服务专业人士身份发布';

  @override
  String get whatsOnYourMind => '分享想法…';

  @override
  String get publishAction => '发布';

  @override
  String get attachmentPhoto => '照片';

  @override
  String get attachmentVideo => '视频';

  @override
  String get attachmentLocation => '位置';

  @override
  String get boostMyProfileCta => '提升档案';

  @override
  String get unlockYourFullPotential => '释放全部潜能';

  @override
  String get annualPlan => '年度';

  @override
  String get monthlyPlan => '月度';

  @override
  String get bestValueBadge => '最划算';

  @override
  String get whatsIncluded => '包含内容';

  @override
  String get continueWithAnnual => '选择年度套餐';

  @override
  String get continueWithMonthly => '选择月度套餐';

  @override
  String get maybeLater => '以后再说';

  @override
  String get restorePurchasesLabel => '恢复购买';

  @override
  String get subscriptionAutoRenewsNote => '订阅自动续订。可随时在设置中取消。';

  @override
  String get appStatusPillApplied => '已申请';

  @override
  String get appStatusPillUnderReview => '审核中';

  @override
  String get appStatusPillShortlisted => '已候选';

  @override
  String get appStatusPillInterviewInvited => '已邀面试';

  @override
  String get appStatusPillInterviewScheduled => '面试已定';

  @override
  String get appStatusPillHired => '已录用';

  @override
  String get appStatusPillRejected => '未录用';

  @override
  String get appStatusPillWithdrawn => '已撤回';

  @override
  String get jobActionPause => '暂停职位';

  @override
  String get jobActionResume => '恢复职位';

  @override
  String get jobActionClose => '关闭职位';

  @override
  String get statusConfirmedLower => '已确认';

  @override
  String get postInsightsTitle => '帖子数据';

  @override
  String get postInsightsSubtitle => '谁在浏览你的内容';

  @override
  String get recentViewers => '最近浏览';

  @override
  String get lockedBadge => '已锁定';

  @override
  String get viewerBreakdown => '浏览者分布';

  @override
  String get viewersByRole => '按岗位浏览';

  @override
  String get topLocations => '热门地点';

  @override
  String get businesses => '企业';

  @override
  String get saveToCollectionTitle => '保存到收藏';

  @override
  String get chooseCategory => '选择类别';

  @override
  String get removeFromCollection => '从收藏移除';

  @override
  String newApplicationTemplate(String role) {
    return '新申请 — $role';
  }

  @override
  String get categoryRestaurants => '餐厅';

  @override
  String get categoryCookingVideos => '烹饪视频';

  @override
  String get categoryJobsTips => '求职技巧';

  @override
  String get categoryHospitalityNews => '行业资讯';

  @override
  String get categoryRecipes => '食谱';

  @override
  String get categoryOther => '其他';

  @override
  String get premiumHeroTagline => '更多曝光、优先提醒、专业筛选——为资深餐饮服务人士打造。';

  @override
  String get benefitAdvancedFilters => '高级搜索筛选';

  @override
  String get benefitPriorityNotifications => '优先职位通知';

  @override
  String get benefitProfileVisibility => '提升档案曝光';

  @override
  String get benefitPremiumBadge => 'Premium 专属徽章';

  @override
  String get benefitEarlyAccess => '抢先查看新职位';

  @override
  String get unlockCandidatePremium => '解锁候选人 Premium';

  @override
  String get getStartedAction => '开始使用';

  @override
  String get findYourFirstJob => '找到第一份工作';

  @override
  String get browseHospitalityRolesNearby => '浏览附近数百个餐饮服务岗位';

  @override
  String get seeWhoViewedYourPostTitle => '查看谁浏览了你的帖子';

  @override
  String get upgradeToPremiumCta => '升级到 Premium';

  @override
  String get upgradeToPremiumSubtitle => '升级到 Premium 查看浏览你内容的认证企业、招聘官和行业领袖。';

  @override
  String get verifiedBusinessViewers => '认证企业浏览者';

  @override
  String get recruiterHiringManagerActivity => '招聘官与用人经理活动';

  @override
  String get cityLevelReachBreakdown => '城市级覆盖分布';

  @override
  String liveApplicationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个进行中',
    );
    return '$_temp0';
  }

  @override
  String nearbyJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个附近',
    );
    return '$_temp0';
  }

  @override
  String jobsNearYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '附近$count个职位',
    );
    return '$_temp0';
  }

  @override
  String applicationsUnderReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count份申请审核中',
    );
    return '$_temp0';
  }

  @override
  String interviewsScheduledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count场面试已安排',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count条未读消息',
    );
    return '$_temp0';
  }

  @override
  String unreadMessagesFromEmployersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '雇主$count条未读消息',
    );
    return '$_temp0';
  }

  @override
  String stepsLeftCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还剩$count步',
    );
    return '$_temp0';
  }

  @override
  String get profileCompleteGreatWork => '档案已完成——做得好';

  @override
  String yearsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年',
    );
    return '$_temp0';
  }

  @override
  String get perHour => '/时';

  @override
  String hoursPerWeekShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count小时/周',
    );
    return '$_temp0';
  }

  @override
  String forMonthsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '为期$count个月',
    );
    return '$_temp0';
  }

  @override
  String interviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count场面试',
    );
    return '$_temp0';
  }

  @override
  String get quickActionFindJobs => '找工作';

  @override
  String get quickActionMyApplications => '我的申请';

  @override
  String get quickActionUpdateProfile => '更新档案';

  @override
  String get quickActionCreatePost => '发布帖子';

  @override
  String get quickActionViewInterviews => '查看面试';

  @override
  String get confirmSubscriptionTitle => '确认订阅';

  @override
  String get confirmAndSubscribeCta => '确认并订阅';

  @override
  String get timelineLabel => '时间线';

  @override
  String get interviewLabel => '面试';

  @override
  String get payOnRequest => '薪资面议';

  @override
  String get rateOnRequest => '费用面议';

  @override
  String get quickActionFindJobsSubtitle => '发现附近职位';

  @override
  String get quickActionMyApplicationsSubtitle => '跟踪每份申请';

  @override
  String get quickActionUpdateProfileSubtitle => '提升曝光与匹配度';

  @override
  String get quickActionCreatePostSubtitle => '与社区分享你的作品';

  @override
  String get quickActionViewInterviewsSubtitle => '为下一步做准备';

  @override
  String get offerLabel => '录用';

  @override
  String hiringForTemplate(String role) {
    return '招聘 $role';
  }

  @override
  String get tapToOpenInMaps => '点击在地图中打开';

  @override
  String get alreadyAppliedToJob => '你已申请过此职位。';

  @override
  String get changePhoto => '更换照片';

  @override
  String get changeAvatar => '更换头像';

  @override
  String get addPhotoAction => '添加照片';

  @override
  String get nationalityLabel => '国籍';

  @override
  String get targetRoleLabel => '目标岗位';

  @override
  String get salaryExpectationLabel => '期望薪资';

  @override
  String get addLanguageCta => '+ 添加语言';

  @override
  String get experienceLabel => '经验';

  @override
  String get nameLabel => '姓名';

  @override
  String get zeroHours => '零工时';

  @override
  String get checkInterviewDetailsLine => '查看面试详情';

  @override
  String get interviewInvitedSubline => '雇主邀请你面试——请确认时间';

  @override
  String get shortlistedSubline => '你已入围候选——等待下一步';

  @override
  String get underReviewSubline => '雇主正在审阅你的档案';

  @override
  String get hiredHeadline => '已录用';

  @override
  String get hiredSubline => '恭喜！你收到录用通知';

  @override
  String get applicationSubmittedHeadline => '申请已提交';

  @override
  String get applicationSubmittedSubline => '雇主将审阅你的申请';

  @override
  String get withdrawnHeadline => '已撤回';

  @override
  String get withdrawnSubline => '你已撤回此申请';

  @override
  String get notSelectedHeadline => '未入选';

  @override
  String get notSelectedSubline => '感谢你的关注';

  @override
  String jobsFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到$count个职位',
    );
    return '$_temp0';
  }

  @override
  String applicationsTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '共$count份',
    );
    return '$_temp0';
  }

  @override
  String applicationsInReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count份审核中',
    );
    return '$_temp0';
  }

  @override
  String applicationsLiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count份进行中',
    );
    return '$_temp0';
  }

  @override
  String interviewsPendingConfirmTime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count场面试待确认时间。',
    );
    return '$_temp0';
  }

  @override
  String notifInterviewConfirmedTitle(String name) {
    return '面试已确认 — $name';
  }

  @override
  String notifInterviewRequestTitle(String name) {
    return '面试请求 — $name';
  }

  @override
  String notifApplicationUpdateTitle(String name) {
    return '申请进展 — $name';
  }

  @override
  String notifOfferReceivedTitle(String name) {
    return '收到录用 — $name';
  }

  @override
  String notifMessageFromTitle(String name) {
    return '来自 $name 的消息';
  }

  @override
  String notifInterviewReminderTitle(String name) {
    return '面试提醒 — $name';
  }

  @override
  String notifProfileViewedTitle(String name) {
    return '档案被查看 — $name';
  }

  @override
  String notifNewJobMatchTitle(String name) {
    return '新职位匹配 — $name';
  }

  @override
  String notifApplicationViewedTitle(String name) {
    return '申请已被查看 — $name';
  }

  @override
  String notifShortlistedTitle(String name) {
    return '入围候选 — $name';
  }

  @override
  String get notifCompleteProfile => '完善档案获得更好匹配';

  @override
  String get notifCompleteBusinessProfile => '完善企业档案提升曝光';

  @override
  String notifNewJobViews(String role, String count) {
    return '你的 $role 职位有 $count 次新浏览';
  }

  @override
  String notifAppliedForRole(String name, String role) {
    return '$name 申请了 $role';
  }

  @override
  String notifNewApplicationNameRole(String name, String role) {
    return '新申请：$name 应聘 $role';
  }

  @override
  String get chatTyping => '正在输入…';

  @override
  String get chatStatusSeen => '已读';

  @override
  String get chatStatusDelivered => '已送达';

  @override
  String get entryTagline => '为餐饮服务专业人士打造的人才平台。';

  @override
  String get entryFindWork => '找工作';

  @override
  String get entryFindWorkSubtitle => '浏览职位，被顶级场所录用';

  @override
  String get entryHireStaff => '招员工';

  @override
  String get entryHireStaffSubtitle => '发布职位，找到顶尖人才';

  @override
  String get entryFindCompanies => '查找企业';

  @override
  String get entryFindCompaniesSubtitle => '发现餐饮服务场所与服务商';

  @override
  String get servicesEntryTitle => '查找企业';

  @override
  String get servicesHospitalityServices => '餐饮服务';

  @override
  String get servicesEntrySubtitle => '注册你的服务公司或查找附近的餐饮服务商';

  @override
  String get servicesRegisterCardTitle => '注册企业';

  @override
  String get servicesRegisterCardSubtitle => '展示你的餐饮服务，被客户发现';

  @override
  String get servicesLookingCardTitle => '我在找企业';

  @override
  String get servicesLookingCardSubtitle => '查找附近的餐饮服务商';

  @override
  String get registerBusinessTitle => '注册你的企业';

  @override
  String get enterCompanyName => '输入公司名称';

  @override
  String get subcategoryOptional => '子类别（可选）';

  @override
  String get subcategoryHintFloristDj => '例如：花艺、DJ 服务';

  @override
  String get searchCompaniesHint => '搜索企业…';

  @override
  String get browseCategories => '浏览类别';

  @override
  String companiesFoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到$count家企业',
    );
    return '$_temp0';
  }

  @override
  String get serviceCategoryFoodBeverage => '食品饮料供应';

  @override
  String get serviceCategoryEventServices => '活动服务';

  @override
  String get serviceCategoryDecorDesign => '装饰与设计';

  @override
  String get serviceCategoryEntertainment => '娱乐';

  @override
  String get serviceCategoryEquipmentOps => '设备与运营';

  @override
  String get serviceCategoryCleaningMaintenance => '清洁与维护';

  @override
  String distanceMiles(String value) {
    return '$value 英里';
  }

  @override
  String distanceKilometers(String value) {
    return '$value 公里';
  }

  @override
  String get postDetailTitle => '帖子';

  @override
  String get likeAction => '点赞';

  @override
  String get commentAction => '评论';

  @override
  String get saveActionLabel => '保存';

  @override
  String get commentsTitle => '评论';

  @override
  String get addCommentHint => '添加评论…';

  @override
  String likesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个赞',
    );
    return '$_temp0';
  }

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count条评论',
    );
    return '$_temp0';
  }

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count次保存',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutesShort(int count) {
    return '$count分';
  }

  @override
  String timeAgoHoursShort(int count) {
    return '$count时';
  }

  @override
  String timeAgoDaysShort(int count) {
    return '$count天';
  }

  @override
  String get timeAgoNow => '刚刚';

  @override
  String get activityTitle => '动态';

  @override
  String get activityLikedPost => '赞了你的帖子';

  @override
  String get activityCommented => '评论了你的帖子';

  @override
  String get activityStartedFollowing => '开始关注你';

  @override
  String get activityMentioned => '提到了你';

  @override
  String get activitySystemUpdate => '向你发送了更新';

  @override
  String get noActivityYetDesc => '当有人点赞、评论或关注你时，会显示在这里。';

  @override
  String get activeStatus => '活跃';

  @override
  String get activeBadge => '活跃';

  @override
  String get nextRenewalLabel => '下次续订';

  @override
  String get startedLabel => '开始时间';

  @override
  String get statusLabel => '状态';

  @override
  String get billingAndCancellation => '账单与取消';

  @override
  String get billingAndCancellationCopy =>
      '你的订阅通过 App Store / Google Play 账户收费。可随时在设备设置中取消——Premium 权益保留至续订日期。';

  @override
  String get premiumIsActive => 'Premium 已激活';

  @override
  String get premiumThanksCopy => '感谢支持 Plagit。你可以使用全部 Premium 功能。';

  @override
  String get manageSubscription => '管理订阅';

  @override
  String get candidatePremiumPlanName => '候选人 Premium';

  @override
  String renewsOnDate(String date) {
    return '$date 续订';
  }

  @override
  String get fullViewerAccessLine => '完整查看权限 · 全部数据已解锁';

  @override
  String get premiumActiveBadge => 'Premium 已激活';

  @override
  String get fullInsightsUnlocked => '全部数据与浏览者详情已解锁。';

  @override
  String get noViewersInCategory => '此类别暂无浏览者';

  @override
  String get onlyVerifiedViewersShown => '仅显示公开档案的认证浏览者。';

  @override
  String get notEnoughDataYet => '数据尚不足。';

  @override
  String get noViewInsightsYet => '暂无浏览数据';

  @override
  String get noViewInsightsDesc => '当你的帖子获得更多浏览时，数据将显示在这里。';

  @override
  String get suspiciousEngagementDetected => '检测到可疑互动';

  @override
  String get patternReviewRequired => '需要人工审核';

  @override
  String get adminInsightsFooter => '管理员视图——与作者看到的数据相同，加上审核标记。仅聚合数据，不暴露个人身份。';

  @override
  String get viewerKindBusiness => '企业';

  @override
  String get viewerKindCandidate => '候选人';

  @override
  String get viewerKindRecruiter => '招聘官';

  @override
  String get viewerKindHiringManager => '用人经理';

  @override
  String get viewerKindBusinessesPlural => '企业';

  @override
  String get viewerKindCandidatesPlural => '候选人';

  @override
  String get viewerKindRecruitersPlural => '招聘官';

  @override
  String get viewerKindHiringManagersPlural => '用人经理';

  @override
  String get searchPeoplePostsVenuesHint => '搜索人、帖子、场所…';

  @override
  String get searchCommunityTitle => '搜索社区';

  @override
  String get roleSommelier => '侍酒师';

  @override
  String get candidatePremiumActivated => '你已成为候选人 Premium';

  @override
  String get purchasesRestoredPremium => '已恢复购买——你已成为候选人 Premium';

  @override
  String get nothingToRestore => '没有可恢复的购买';

  @override
  String get noValidSubscriptionPremiumRemoved => '未找到有效订阅——Premium 权限已移除';

  @override
  String restoreFailedWithError(String error) {
    return '恢复失败。$error';
  }

  @override
  String get subscriptionTitleAnnual => '候选人 Premium · 年度';

  @override
  String get subscriptionTitleMonthly => '候选人 Premium · 月度';

  @override
  String pricePerYearSlash(String price) {
    return '$price / 年';
  }

  @override
  String pricePerMonthSlash(String price) {
    return '$price / 月';
  }

  @override
  String get nearbyJobsTitle => '附近职位';

  @override
  String get expandRadius => '扩大范围';

  @override
  String get noJobsInRadius => '此范围内暂无职位';

  @override
  String jobsWithinRadius(int count, int radius) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$radius英里内$count个职位',
    );
    return '$_temp0';
  }

  @override
  String get interviewAcceptedSnack => '已接受面试！';

  @override
  String get declineInterviewTitle => '拒绝面试';

  @override
  String get declineInterviewConfirm => '确定要拒绝此次面试吗？';

  @override
  String get addedToCalendar => '已加入日历';

  @override
  String get removeCompanyTitle => '移除？';

  @override
  String get removeCompanyConfirm => '确定要从收藏列表移除这家企业吗？';

  @override
  String get signOutAllRolesConfirm => '确定要退出所有角色吗？';

  @override
  String get tapToViewAllConversations => '点击查看全部对话';

  @override
  String get savedJobsTitle => '已收藏职位';

  @override
  String savedJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个收藏职位',
    );
    return '$_temp0';
  }

  @override
  String get removeFromSavedTitle => '从收藏移除？';

  @override
  String get removeFromSavedConfirm => '此职位将从收藏列表移除。';

  @override
  String get noSavedJobsSubtitle => '浏览职位并收藏喜欢的';

  @override
  String get browseJobsAction => '浏览职位';

  @override
  String matchingJobsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个匹配职位',
    );
    return '$_temp0';
  }

  @override
  String get savedPostsTitle => '已保存帖子';

  @override
  String get searchSavedPostsHint => '搜索已保存帖子…';

  @override
  String get skipAction => '跳过';

  @override
  String get submitAction => '提交';

  @override
  String get doneAction => '完成';

  @override
  String get resetYourPasswordTitle => '重置密码';

  @override
  String get enterEmailForResetCode => '输入邮箱接收重置码';

  @override
  String get sendResetCode => '发送重置码';

  @override
  String get enterResetCode => '输入重置码';

  @override
  String get resendCode => '重新发送';

  @override
  String get passwordResetComplete => '密码重置完成';

  @override
  String get backToSignIn => '返回登录';

  @override
  String get passwordChanged => '密码已修改';

  @override
  String get passwordUpdatedShort => '你的密码已成功更新。';

  @override
  String get passwordUpdatedRelogin => '你的密码已更新。请使用新密码重新登录。';

  @override
  String get updatePassword => '更新密码';

  @override
  String get changePasswordTitle => '修改密码';

  @override
  String get passwordRequirements => '密码要求';

  @override
  String get newPasswordHint => '新密码（至少8位）';

  @override
  String get confirmPasswordField => '确认密码';

  @override
  String get enterEmailField => '输入邮箱';

  @override
  String get enterPasswordField => '输入密码';

  @override
  String get welcomeBack => '欢迎回来！';

  @override
  String get selectHowToUse => '选择今天如何使用 Plagit';

  @override
  String get continueAsCandidate => '以候选人身份继续';

  @override
  String get continueAsBusiness => '以企业身份继续';

  @override
  String get signInToPlagit => '登录 Plagit';

  @override
  String get enterCredentials => '输入凭据继续';

  @override
  String get adminPortal => '管理门户';

  @override
  String get plagitAdmin => 'Plagit 管理端';

  @override
  String get signInToAdminAccount => '登录管理员账户';

  @override
  String get admin => '管理员';

  @override
  String get searchJobsRolesRestaurantsHint => '搜索职位、岗位、餐厅…';

  @override
  String get exploreNearbyJobs => '探索附近职位';

  @override
  String get findOpportunitiesOnMap => '在地图上查找附近机会';

  @override
  String get featuredJobs => '精选职位';

  @override
  String get jobsNearYou => '附近职位';

  @override
  String get jobsMatchingRoleType => '匹配你岗位与类型的职位';

  @override
  String get availableNow => '立即可用';

  @override
  String get noNearbyJobsYet => '附近暂无职位';

  @override
  String get tryIncreasingRadius => '尝试扩大范围或调整筛选';

  @override
  String get checkBackForOpportunities => '稍后再来查看新机会';

  @override
  String get noNotifications => '暂无通知';

  @override
  String get okAction => '好的';

  @override
  String get onlineNow => '现在在线';

  @override
  String get businessUpper => '企业';

  @override
  String get waitingForBusinessFirstMessage => '等待企业发送第一条消息';

  @override
  String get whenEmployersMessageYou => '雇主发消息时会显示在这里。';

  @override
  String get replyToCandidate => '回复候选人…';

  @override
  String get quickFeedback => '快速反馈';

  @override
  String get helpImproveMatches => '帮助我们改善匹配';

  @override
  String get thanksForFeedback => '感谢你的反馈！';

  @override
  String get accountSettings => '账户设置';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get privacyAndSecurity => '隐私与安全';

  @override
  String get helpAndSupport => '帮助与支持';

  @override
  String get activeRoleUpper => '当前角色';

  @override
  String get meetingLink => '会议链接';

  @override
  String get joinMeeting2 => '加入会议';

  @override
  String get notes => '备注';

  @override
  String get completeBusinessProfileTitle => '完善企业档案';

  @override
  String get businessDescription => '企业介绍';

  @override
  String get finishSetupAction => '完成设置';

  @override
  String get describeBusinessHintLong => '介绍你的企业、文化以及它作为工作场所的优势…（建议至少150字）';

  @override
  String get describeBusinessHintShort => '介绍你的企业…';

  @override
  String get writeShortIntroAboutYourself => '写一段关于自己的简介…';

  @override
  String get createBusinessAccountTitle => '创建企业账户';

  @override
  String get businessDetailsSection => '企业信息';

  @override
  String get openToInternationalCandidates => '接受国际候选人';

  @override
  String get createAccountShort => '创建账户';

  @override
  String get yourDetailsSection => '个人信息';

  @override
  String get jobTypeField => '职位类型';

  @override
  String get communityFeed => '社区动态';

  @override
  String get postPublished => '帖子已发布';

  @override
  String get postHidden => '帖子已隐藏';

  @override
  String get postReportedReview => '帖子已举报——管理员将审核';

  @override
  String get postNotFound => '未找到帖子';

  @override
  String get goBack => '返回';

  @override
  String get linkCopied => '链接已复制';

  @override
  String get removedFromSaved => '已从收藏移除';

  @override
  String get noPostsFound => '未找到帖子';

  @override
  String get tipsStoriesAdvice => '来自餐饮服务专业人士的建议、故事和经验';

  @override
  String get searchTalentPostsRolesHint => '搜索人才、帖子、岗位…';

  @override
  String get videoAttachmentsComingSoon => '视频附件即将上线';

  @override
  String get locationTaggingComingSoon => '位置标记即将上线';

  @override
  String get fullImageViewerComingSoon => '图片查看器即将上线';

  @override
  String get shareComingSoon => '分享功能即将上线';

  @override
  String get findServices => '查找服务';

  @override
  String get findHospitalityServices => '查找餐饮服务';

  @override
  String get browseServices => '浏览服务';

  @override
  String get searchServicesCompaniesLocationsHint => '搜索服务、企业、地点…';

  @override
  String get searchCompaniesServicesLocationsHint => '搜索企业、服务、地点…';

  @override
  String get nearbyCompanies => '附近企业';

  @override
  String get nearYou => '附近';

  @override
  String get listLabel => '列表';

  @override
  String get mapViewLabel => '地图';

  @override
  String get noServicesFound => '未找到服务';

  @override
  String get noCompaniesFoundNearby => '附近未找到企业';

  @override
  String get noSavedCompanies => '暂无已保存企业';

  @override
  String get savedCompaniesTitle => '已保存企业';

  @override
  String get saveCompaniesForLater => '收藏喜欢的企业方便以后查找';

  @override
  String get latestUpdates => '最新动态';

  @override
  String get noPromotions => '暂无促销';

  @override
  String get companyHasNoPromotions => '此企业暂无活动促销。';

  @override
  String get companyHasNoUpdates => '此企业尚未发布动态。';

  @override
  String get promotionsAndOffers => '促销与优惠';

  @override
  String get promotionNotFound => '未找到促销';

  @override
  String get promotionDetails => '促销详情';

  @override
  String get termsAndConditions => '条款与条件';

  @override
  String get relatedPosts => '相关帖子';

  @override
  String get viewOffer => '查看优惠';

  @override
  String get offerBadge => '优惠';

  @override
  String get requestQuote => '索取报价';

  @override
  String get sendRequest => '发送请求';

  @override
  String get quoteRequestSent => '报价请求已发送！';

  @override
  String get inquiry => '咨询';

  @override
  String get dateNeeded => '所需日期';

  @override
  String get serviceType => '服务类型';

  @override
  String get serviceArea => '服务区域';

  @override
  String get servicesOffered => '提供的服务';

  @override
  String get servicesLabel => '服务';

  @override
  String get servicePlans => '服务套餐';

  @override
  String get growYourServiceBusiness => '发展你的服务业务';

  @override
  String get getDiscoveredPremium => '通过 Premium 展示让更多客户发现你。';

  @override
  String get unlockPremium => '解锁 Premium';

  @override
  String get getMoreVisibility => '获得更多曝光和更好匹配';

  @override
  String get plagitPremiumUpper => 'PLAGIT PREMIUM';

  @override
  String get premiumOnly => '仅 Premium';

  @override
  String get savePercent17 => '省 17%';

  @override
  String get registerBusinessCta => '注册企业';

  @override
  String get registrationSubmitted => '注册已提交';

  @override
  String get serviceDescription => '服务介绍';

  @override
  String get describeServicesHint => '介绍你的服务、经验和独特之处…';

  @override
  String get websiteOptional => '网站（可选）';

  @override
  String get viewCompanyProfileCta => '查看企业档案';

  @override
  String get contactCompany => '联系企业';

  @override
  String get aboutUs => '关于我们';

  @override
  String get address => '地址';

  @override
  String get city => '城市';

  @override
  String get yourLocation => '你的位置';

  @override
  String get enterYourCity => '输入你的城市';

  @override
  String get clearFilters => '清除筛选';

  @override
  String get tryDifferentSearchTerm => '尝试其他搜索词';

  @override
  String get tryDifferentOrAdjust => '尝试其他搜索、类别或调整筛选。';

  @override
  String get noPostsYetCompany => '暂无帖子';

  @override
  String requestQuoteFromCompany(String companyName) {
    return '向 $companyName 索取报价';
  }

  @override
  String validUntilDate(String validUntil) {
    return '有效期至 $validUntil';
  }

  @override
  String get employerCheckingProfile => '有雇主正在查看你的档案';

  @override
  String profileStrengthPercent(int percent) {
    return '档案完成度 $percent%';
  }

  @override
  String get profileGetsMoreViews => '完整档案获得3倍浏览';

  @override
  String get applicationUpdate => '申请进展';

  @override
  String get findJobsAndApply => '找工作并申请';

  @override
  String get manageJobsAndHiring => '管理职位与招聘';

  @override
  String get managePlatform => '管理平台';

  @override
  String get findHospitalityCompanies => '查找餐饮服务企业';

  @override
  String get candidateMessages => '候选人消息';

  @override
  String get businessMessages => '企业消息';

  @override
  String get serviceInquiries => '服务咨询';

  @override
  String get acceptInterview => '接受面试';

  @override
  String get adminMenuDashboard => '仪表盘';

  @override
  String get adminMenuUsers => '用户';

  @override
  String get adminMenuCandidates => '候选人';

  @override
  String get adminMenuBusinesses => '企业';

  @override
  String get adminMenuJobs => '职位';

  @override
  String get adminMenuApplications => '申请';

  @override
  String get adminMenuBookings => '预订';

  @override
  String get adminMenuPayments => '支付';

  @override
  String get adminMenuMessages => '消息';

  @override
  String get adminMenuNotifications => '通知';

  @override
  String get adminMenuReports => '报告';

  @override
  String get adminMenuAnalytics => '分析';

  @override
  String get adminMenuSettings => '设置';

  @override
  String get adminMenuSupport => '支持';

  @override
  String get adminMenuModeration => '审核';

  @override
  String get adminMenuRoles => '角色';

  @override
  String get adminMenuInvoices => '发票';

  @override
  String get adminMenuLogs => '日志';

  @override
  String get adminMenuIntegrations => '集成';

  @override
  String get adminMenuLogout => '退出登录';

  @override
  String get adminActionApprove => '批准';

  @override
  String get adminActionReject => '拒绝';

  @override
  String get adminActionSuspend => '暂停';

  @override
  String get adminActionActivate => '激活';

  @override
  String get adminActionDelete => '删除';

  @override
  String get adminActionExport => '导出';

  @override
  String get adminSectionOverview => '概览';

  @override
  String get adminSectionManagement => '管理';

  @override
  String get adminSectionFinance => '财务';

  @override
  String get adminSectionOperations => '运营';

  @override
  String get adminSectionSystem => '系统';

  @override
  String get adminStatTotalUsers => '用户总数';

  @override
  String get adminStatActiveJobs => '活跃职位';

  @override
  String get adminStatPendingApprovals => '待批准';

  @override
  String get adminStatRevenue => '收入';

  @override
  String get adminStatBookingsToday => '今日预订';

  @override
  String get adminStatNewSignups => '新注册';

  @override
  String get adminStatConversionRate => '转化率';

  @override
  String get adminMiscWelcome => '欢迎回来';

  @override
  String get adminMiscLoading => '加载中…';

  @override
  String get adminMiscNoData => '暂无数据';

  @override
  String get adminMiscSearchPlaceholder => '搜索…';

  @override
  String get adminMenuContent => '内容';

  @override
  String get adminMenuMore => '更多';

  @override
  String get adminMenuVerifications => '验证';

  @override
  String get adminMenuSubscriptions => '订阅';

  @override
  String get adminMenuCommunity => '社区';

  @override
  String get adminMenuInterviews => '面试';

  @override
  String get adminMenuMatches => '匹配';

  @override
  String get adminMenuFeaturedContent => '精选内容';

  @override
  String get adminMenuAuditLog => '审计日志';

  @override
  String get adminMenuChangePassword => '修改密码';

  @override
  String get adminSectionPeople => '人员';

  @override
  String get adminSectionHiring => '招聘运营';

  @override
  String get adminSectionContentComm => '内容与沟通';

  @override
  String get adminSectionRevenue => '业务与收入';

  @override
  String get adminSectionToolsContent => '工具与内容';

  @override
  String get adminSectionQuickActions => '快捷操作';

  @override
  String get adminSectionNeedsAttention => '需要关注';

  @override
  String get adminStatActiveBusinesses => '活跃企业';

  @override
  String get adminStatApplicationsToday => '今日申请';

  @override
  String get adminStatInterviewsToday => '今日面试';

  @override
  String get adminStatFlaggedContent => '举报内容';

  @override
  String get adminStatActiveSubs => '活跃订阅';

  @override
  String get adminActionFlagged => '已举报';

  @override
  String get adminActionFeatured => '精选';

  @override
  String get adminActionReviewFlagged => '审核举报内容';

  @override
  String get adminActionTodayInterviews => '今日面试';

  @override
  String get adminActionOpenReports => '待处理举报';

  @override
  String get adminActionManageSubscriptions => '管理订阅';

  @override
  String get adminActionAnalyticsDashboard => '分析面板';

  @override
  String get adminActionSendNotification => '发送通知';

  @override
  String get adminActionCreateCommunityPost => '创建社区帖子';

  @override
  String get adminActionRetry => '重试';

  @override
  String get adminMiscGreetingMorning => '早上好';

  @override
  String get adminMiscGreetingAfternoon => '下午好';

  @override
  String get adminMiscGreetingEvening => '晚上好';

  @override
  String get adminMiscAllClear => '一切正常 — 无需关注。';

  @override
  String get adminSubtitleAllUsers => '所有平台用户';

  @override
  String get adminSubtitleCandidates => '求职者档案';

  @override
  String get adminSubtitleBusinesses => '雇主账号';

  @override
  String get adminSubtitleJobs => '活跃职位';

  @override
  String get adminSubtitleApplications => '已提交申请';

  @override
  String get adminSubtitleInterviews => '已安排面试';

  @override
  String get adminSubtitleMatches => '角色和职位类型匹配';

  @override
  String get adminSubtitleVerifications => '审核待处理验证';

  @override
  String get adminSubtitleReports => '举报和审核';

  @override
  String get adminSubtitleSupport => '未解决的支持问题';

  @override
  String get adminSubtitleMessages => '用户对话';

  @override
  String get adminSubtitleNotifications => '推送和应用内提醒';

  @override
  String get adminSubtitleCommunity => '帖子和讨论';

  @override
  String get adminSubtitleFeaturedContent => '精选内容';

  @override
  String get adminSubtitleSubscriptions => '套餐和账单';

  @override
  String get adminSubtitleAuditLog => '管理员活动日志';

  @override
  String get adminSubtitleAnalytics => '平台指标';

  @override
  String get adminSubtitleSettings => '平台配置';

  @override
  String get adminSubtitleUsersPage => '管理平台账号';

  @override
  String get adminSubtitleContentPage => '职位、申请和面试';

  @override
  String get adminSubtitleModerationPage => '验证、举报和支持';

  @override
  String get adminSubtitleMorePage => '设置、分析和账号';

  @override
  String get adminSubtitleAnalyticsHero => '关键指标、趋势和平台健康';

  @override
  String get adminBadgeUrgent => '紧急';

  @override
  String get adminBadgeReview => '审核';

  @override
  String get adminBadgeAction => '操作';

  @override
  String get adminMenuAllUsers => '所有用户';

  @override
  String get adminMiscSuperAdmin => '超级管理员';

  @override
  String adminBadgeNToday(int count) {
    return '今日 $count';
  }

  @override
  String adminBadgeNOpen(int count) {
    return '$count 个未处理';
  }

  @override
  String adminBadgeNActive(int count) {
    return '$count 个活跃';
  }

  @override
  String adminBadgeNUnread(int count) {
    return '$count 条未读';
  }

  @override
  String adminBadgeNPending(int count) {
    return '$count 待处理';
  }

  @override
  String adminBadgeNPosts(int count) {
    return '$count 条帖子';
  }

  @override
  String adminBadgeNFeatured(int count) {
    return '$count 个精选';
  }

  @override
  String get adminStatusActive => '活跃';

  @override
  String get adminStatusPaused => '已暂停';

  @override
  String get adminStatusClosed => '已关闭';

  @override
  String get adminStatusDraft => '草稿';

  @override
  String get adminStatusFlagged => '已标记';

  @override
  String get adminStatusSuspended => '已暂停';

  @override
  String get adminStatusPending => '待处理';

  @override
  String get adminStatusConfirmed => '已确认';

  @override
  String get adminStatusCompleted => '已完成';

  @override
  String get adminStatusCancelled => '已取消';

  @override
  String get adminStatusAccepted => '已接受';

  @override
  String get adminStatusDenied => '已拒绝';

  @override
  String get adminStatusExpired => '已过期';

  @override
  String get adminStatusResolved => '已解决';

  @override
  String get adminStatusScheduled => '已排期';

  @override
  String get adminStatusBanned => '已封禁';

  @override
  String get adminStatusVerified => '已验证';

  @override
  String get adminStatusFailed => '失败';

  @override
  String get adminStatusSuccess => '成功';

  @override
  String get adminStatusDelivered => '已送达';

  @override
  String get adminFilterAll => '全部';

  @override
  String get adminFilterToday => '今天';

  @override
  String get adminFilterUnread => '未读';

  @override
  String get adminFilterRead => '已读';

  @override
  String get adminFilterCandidates => '候选人';

  @override
  String get adminFilterBusinesses => '企业';

  @override
  String get adminFilterAdmins => '管理员';

  @override
  String get adminFilterCandidate => '候选人';

  @override
  String get adminFilterBusiness => '企业';

  @override
  String get adminFilterSystem => '系统';

  @override
  String get adminFilterPinned => '已置顶';

  @override
  String get adminFilterEmployers => '雇主';

  @override
  String get adminFilterBanners => '横幅';

  @override
  String get adminFilterBilling => '账单';

  @override
  String get adminFilterFeaturedEmployer => '精选雇主';

  @override
  String get adminFilterFeaturedJob => '精选职位';

  @override
  String get adminFilterHomeBanner => '首页横幅';

  @override
  String get adminEmptyAdjustFilters => '请尝试调整筛选。';

  @override
  String get adminEmptyJobsTitle => '无职位';

  @override
  String get adminEmptyJobsSub => '无匹配职位。';

  @override
  String get adminEmptyUsersTitle => '无用户';

  @override
  String get adminEmptyMessagesTitle => '无消息';

  @override
  String get adminEmptyMessagesSub => '无对话可显示。';

  @override
  String get adminEmptyReportsTitle => '无举报';

  @override
  String get adminEmptyReportsSub => '无待审核举报。';

  @override
  String get adminEmptyBusinessesTitle => '无企业';

  @override
  String get adminEmptyBusinessesSub => '无匹配企业。';

  @override
  String get adminEmptyNotifsTitle => '无通知';

  @override
  String get adminEmptySubsTitle => '无订阅';

  @override
  String get adminEmptySubsSub => '无匹配订阅。';

  @override
  String get adminEmptyLogsTitle => '无日志';

  @override
  String get adminEmptyContentTitle => '无内容';

  @override
  String get adminEmptyInterviewsTitle => '无面试';

  @override
  String get adminEmptyInterviewsSub => '无匹配面试。';

  @override
  String get adminEmptyFeedback => '反馈数据将显示在此处';

  @override
  String get adminEmptyMatchNotifs => '匹配通知将显示在此处';

  @override
  String get adminTitleMatchManagement => '匹配管理';

  @override
  String get adminTitleAdminLogs => '管理日志';

  @override
  String get adminTitleContentFeatured => '内容 / 精选';

  @override
  String get adminTabFeedback => '反馈';

  @override
  String get adminTabStats => '统计';

  @override
  String get adminSortNewest => '最新';

  @override
  String get adminSortPriority => '优先级';

  @override
  String get adminStatTotalMatches => '总匹配';

  @override
  String get adminStatAccepted => '已接受';

  @override
  String get adminStatDenied => '已拒绝';

  @override
  String get adminStatFeedbackCount => '反馈';

  @override
  String get adminStatMatchQuality => '匹配质量分';

  @override
  String get adminStatTotal => '总计';

  @override
  String get adminStatPendingCount => '待处理';

  @override
  String get adminStatNotificationsCount => '通知';

  @override
  String get adminStatActiveCount => '活跃';

  @override
  String get adminSectionPlatformSettings => '平台设置';

  @override
  String get adminSectionNotificationSettings => '通知设置';

  @override
  String get adminSettingMaintenanceTitle => '维护模式';

  @override
  String get adminSettingMaintenanceSub => '对所有用户禁用访问';

  @override
  String get adminSettingNewRegsTitle => '新注册';

  @override
  String get adminSettingNewRegsSub => '允许新用户注册';

  @override
  String get adminSettingFeaturedJobsTitle => '精选职位';

  @override
  String get adminSettingFeaturedJobsSub => '在首页显示精选职位';

  @override
  String get adminSettingEmailNotifsTitle => '邮件通知';

  @override
  String get adminSettingEmailNotifsSub => '发送邮件提醒';

  @override
  String get adminSettingPushNotifsTitle => '推送通知';

  @override
  String get adminSettingPushNotifsSub => '发送推送通知';

  @override
  String get adminActionSaveChanges => '保存更改';

  @override
  String get adminToastSettingsSaved => '设置已保存';

  @override
  String get adminActionResolve => '解决';

  @override
  String get adminActionDismiss => '忽略';

  @override
  String get adminActionBanUser => '封禁用户';

  @override
  String get adminSearchUsersHint => '搜索姓名、邮箱、角色、地点...';

  @override
  String get adminMiscPositive => '正面';

  @override
  String adminCountUsers(int count) {
    return '$count 个用户';
  }

  @override
  String adminCountNotifs(int count) {
    return '$count 条通知';
  }

  @override
  String adminCountLogs(int count) {
    return '$count 条日志';
  }

  @override
  String adminCountItems(int count) {
    return '$count 项';
  }

  @override
  String adminBadgeNRetried(int count) {
    return '已重试 x$count';
  }

  @override
  String get adminStatusApplied => '已申请';

  @override
  String get adminStatusUnderReview => '审核中';

  @override
  String get adminStatusShortlisted => '入围';

  @override
  String get adminStatusInterview => '面试';

  @override
  String get adminStatusHired => '已录用';

  @override
  String get adminStatusRejected => '已拒绝';

  @override
  String get adminStatusOpen => '开放';

  @override
  String get adminStatusInReview => '审核中';

  @override
  String get adminStatusWaiting => '等待中';

  @override
  String get adminPriorityHigh => '高';

  @override
  String get adminPriorityMedium => '中';

  @override
  String get adminPriorityLow => '低';

  @override
  String get adminActionViewProfile => '查看资料';

  @override
  String get adminActionVerify => '验证';

  @override
  String get adminActionReview => '审核';

  @override
  String get adminActionOverride => '覆盖';

  @override
  String get adminEmptyCandidatesTitle => '暂无候选人';

  @override
  String get adminEmptyApplicationsTitle => '暂无申请';

  @override
  String get adminEmptyVerificationsTitle => '暂无待审核';

  @override
  String get adminEmptyIssuesTitle => '暂无问题';

  @override
  String get adminEmptyAuditTitle => '暂无审计记录';

  @override
  String get adminSearchCandidatesTitle => '搜索候选人';

  @override
  String get adminSearchCandidatesHint => '按姓名、邮箱或角色搜索…';

  @override
  String get adminSearchAuditHint => '搜索审计日志…';

  @override
  String get adminMiscUnknown => '未知';

  @override
  String adminCountTotal(int count) {
    return '共 $count';
  }

  @override
  String adminBadgeNFlagged(int count) {
    return '$count 已标记';
  }

  @override
  String adminBadgeNDaysWaiting(int count) {
    return '等待 $count 天';
  }

  @override
  String get adminPeriodWeek => '周';

  @override
  String get adminPeriodMonth => '月';

  @override
  String get adminPeriodYear => '年';

  @override
  String get adminKpiNewCandidates => '新候选人';

  @override
  String get adminKpiNewBusinesses => '新企业';

  @override
  String get adminKpiJobsPosted => '已发布职位';

  @override
  String get adminSectionApplicationFunnel => '申请漏斗';

  @override
  String get adminSectionPlatformGrowth => '平台增长';

  @override
  String get adminSectionPremiumConversion => '高级版转化';

  @override
  String get adminSectionTopLocations => '热门地点';

  @override
  String get adminStatusViewed => '已查看';

  @override
  String get adminWeekdayMon => '周一';

  @override
  String get adminWeekdayTue => '周二';

  @override
  String get adminWeekdayWed => '周三';

  @override
  String get adminWeekdayThu => '周四';

  @override
  String get adminWeekdayFri => '周五';

  @override
  String get adminWeekdaySat => '周六';

  @override
  String get adminWeekdaySun => '周日';

  @override
  String get adminFilterReported => '已举报';

  @override
  String get adminFilterHidden => '已隐藏';

  @override
  String get adminEmptyPostsTitle => '暂无帖子';

  @override
  String get adminEmptyContentFilter => '没有内容匹配此筛选条件。';

  @override
  String get adminBannerReportedReview => '已举报 — 需要审核';

  @override
  String get adminBannerHiddenFromFeed => '已从信息流隐藏';

  @override
  String get adminActionInsights => '洞察';

  @override
  String get adminActionHide => '隐藏';

  @override
  String get adminActionRemove => '移除';

  @override
  String get adminActionCancel => '取消';

  @override
  String get adminDialogRemovePostTitle => '移除帖子？';

  @override
  String get adminDialogRemovePostBody => '这将永久删除该帖子及其评论。此操作无法撤销。';

  @override
  String get adminSnackbarReportCleared => '举报已清除';

  @override
  String get adminSnackbarPostHidden => '帖子已从信息流隐藏';

  @override
  String get adminSnackbarPostRemoved => '帖子已移除';

  @override
  String adminCountReported(int count) {
    return '$count 个已举报';
  }

  @override
  String adminCountHidden(int count) {
    return '$count 个已隐藏';
  }

  @override
  String adminMiscPremiumOutOfTotal(int premium, int total) {
    return '$total 中有 $premium 个高级版';
  }

  @override
  String get adminActionUnverify => '取消验证';

  @override
  String get adminActionReactivate => '重新激活';

  @override
  String get adminActionFeature => '推荐';

  @override
  String get adminActionUnfeature => '取消推荐';

  @override
  String get adminActionFlagAccount => '标记账户';

  @override
  String get adminActionUnflagAccount => '取消标记';

  @override
  String get adminActionConfirm => '确认';

  @override
  String get adminDialogVerifyBusinessTitle => '验证企业';

  @override
  String get adminDialogUnverifyBusinessTitle => '取消企业验证';

  @override
  String get adminDialogSuspendBusinessTitle => '暂停企业';

  @override
  String get adminDialogReactivateBusinessTitle => '重新激活企业';

  @override
  String get adminDialogVerifyCandidateTitle => '验证候选人';

  @override
  String get adminDialogSuspendCandidateTitle => '暂停候选人';

  @override
  String get adminDialogReactivateCandidateTitle => '重新激活候选人';

  @override
  String get adminSnackbarBusinessVerified => '企业已验证';

  @override
  String get adminSnackbarVerificationRemoved => '验证已取消';

  @override
  String get adminSnackbarBusinessSuspended => '企业已暂停';

  @override
  String get adminSnackbarBusinessReactivated => '企业已重新激活';

  @override
  String get adminSnackbarBusinessFeatured => '企业已推荐';

  @override
  String get adminSnackbarBusinessUnfeatured => '已取消企业推荐';

  @override
  String get adminSnackbarUserVerified => '用户已验证';

  @override
  String get adminSnackbarUserSuspended => '用户已暂停';

  @override
  String get adminSnackbarUserReactivated => '用户已重新激活';

  @override
  String get adminTabProfile => '资料';

  @override
  String get adminTabActivity => '活动';

  @override
  String get adminTabNotes => '备注';

  @override
  String adminDialogVerifyBody(String name) {
    return '将 $name 标记为已验证？';
  }

  @override
  String adminDialogUnverifyBody(String name) {
    return '取消对 $name 的验证？';
  }

  @override
  String adminDialogReactivateBody(String name) {
    return '重新激活 $name？';
  }

  @override
  String adminDialogSuspendBusinessBody(String name) {
    return '暂停 $name？所有职位将被暂停。';
  }

  @override
  String adminDialogSuspendCandidateBody(String name) {
    return '暂停 $name？其访问权限将被取消。';
  }
}
