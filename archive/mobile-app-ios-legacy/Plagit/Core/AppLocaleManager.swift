//
//  AppLocaleManager.swift
//  Plagit
//
//  Manages app language detection, manual override, and persistence.
//
//  User profile model:
//    countryCode: "IT"          — user's country (for flag/profile)
//    appLanguageCode: "it"      — app display language
//    spokenLanguages: ["it","en"] — languages the user speaks (profile data)
//

import Foundation

@Observable
final class AppLocaleManager {
    static let shared = AppLocaleManager()

    /// Current app language code (ISO 639-1)
    var appLanguageCode: String {
        didSet { UserDefaults.standard.set(appLanguageCode, forKey: "plagit_app_language") }
    }

    /// User's country code (ISO 3166-1 alpha-2) — for flag display
    var countryCode: String? {
        didSet { UserDefaults.standard.set(countryCode, forKey: "plagit_country_code") }
    }

    /// User's spoken languages (ISO 639-1 codes)
    var spokenLanguages: [String] {
        didSet { UserDefaults.standard.set(spokenLanguages, forKey: "plagit_spoken_languages") }
    }

    /// Supported app languages (languages we have translations for)
    static let supportedAppLanguages: [(code: String, name: String, nativeName: String)] = [
        ("en", "English", "English"),
        ("it", "Italian", "Italiano"),
        ("fr", "French", "Français"),
        ("es", "Spanish", "Español"),
        ("de", "German", "Deutsch"),
        ("ar", "Arabic", "العربية"),
        ("pt", "Portuguese", "Português"),
        ("ru", "Russian", "Русский"),
        ("tr", "Turkish", "Türkçe"),
        ("hi", "Hindi", "हिन्दी"),
        ("zh", "Chinese", "中文"),
    ]

    /// Whether current language is English
    var isEnglish: Bool { appLanguageCode == "en" }

    /// Display label for current language: "IT" or "EN"
    var currentLanguageLabel: String { appLanguageCode.uppercased() }

    private init() {
        // Always detect native device language first
        let detected = Self.detectDeviceLanguage()
        self.nativeLanguageCode = detected

        // Restore persisted values
        let saved = UserDefaults.standard.string(forKey: "plagit_app_language")
        let savedCountry = UserDefaults.standard.string(forKey: "plagit_country_code")
        let savedSpoken = UserDefaults.standard.stringArray(forKey: "plagit_spoken_languages")

        self.countryCode = savedCountry
        self.spokenLanguages = savedSpoken ?? []

        if let saved {
            self.appLanguageCode = saved
        } else {
            // Auto-detect from device on first launch
            self.appLanguageCode = detected
        }
        // Init complete
    }

    /// Detect device's preferred language, fallback to "en"
    static func detectDeviceLanguage() -> String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        // Extract base language code: "it-IT" -> "it", "en-GB" -> "en"
        let baseCode = String(preferred.prefix(2)).lowercased()

        // Check if we support it
        if supportedAppLanguages.contains(where: { $0.code == baseCode }) {
            return baseCode
        }
        return "en"
    }

    /// Detect device's country/region
    static func detectDeviceCountry() -> String? {
        Locale.current.region?.identifier
    }

    /// Set app language manually
    func setLanguage(_ code: String) {
        appLanguageCode = code
    }

    /// The user's native (device) language code, cached at init
    private let nativeLanguageCode: String

    /// Toggle between native device language and English
    func toggleEnglish() {
        if isEnglish {
            appLanguageCode = nativeLanguageCode
        } else {
            appLanguageCode = "en"
        }
        // Toggled
    }

    /// Set user profile data (called after login/registration)
    func setUserProfile(countryCode: String?, spokenLanguages: [String]) {
        self.countryCode = countryCode
        self.spokenLanguages = spokenLanguages
    }

    /// Infer language from a location string (e.g. "London, UK" → "en")
    func inferLanguageFromLocation(_ location: String) {
        let loc = location.lowercased()
        let mapping: [(keywords: [String], code: String)] = [
            (["uk", "united kingdom", "london", "manchester", "birmingham", "edinburgh", "liverpool", "bristol", "leeds",
              "usa", "united states", "new york", "los angeles", "chicago", "miami", "san francisco",
              "australia", "sydney", "melbourne", "canada", "toronto", "vancouver"], "en"),
            (["italy", "italia", "rome", "roma", "milan", "milano", "napoli", "naples", "torino", "firenze", "florence", "bologna", "palermo"], "it"),
            (["france", "paris", "lyon", "marseille", "nice", "toulouse", "bordeaux"], "fr"),
            (["spain", "españa", "madrid", "barcelona", "valencia", "sevilla", "seville", "malaga"], "es"),
            (["germany", "deutschland", "berlin", "munich", "münchen", "hamburg", "frankfurt", "köln", "cologne"], "de"),
            (["portugal", "lisboa", "lisbon", "porto"], "pt"),
            (["turkey", "türkiye", "istanbul", "ankara", "izmir"], "tr"),
            (["dubai", "abu dhabi", "saudi", "riyadh", "qatar", "doha", "kuwait", "bahrain", "oman"], "ar"),
            (["russia", "москва", "moscow", "saint petersburg"], "ru"),
            (["china", "beijing", "shanghai", "guangzhou", "shenzhen"], "zh"),
            (["india", "mumbai", "delhi", "bangalore", "bengaluru"], "hi"),
        ]
        for entry in mapping {
            if entry.keywords.contains(where: { loc.contains($0) }) {
                setLanguage(entry.code)
                return
            }
        }
    }

    /// Reset persisted language (used on logout to avoid stale state)
    func resetToDeviceLanguage() {
        let detected = Self.detectDeviceLanguage()
        appLanguageCode = detected
    }

    /// Get the full profile payload for API
    var profilePayload: [String: Any] {
        var d: [String: Any] = ["app_language_code": appLanguageCode]
        if let cc = countryCode { d["country_code"] = cc }
        if !spokenLanguages.isEmpty { d["spoken_languages"] = spokenLanguages.joined(separator: ",") }
        return d
    }
}
