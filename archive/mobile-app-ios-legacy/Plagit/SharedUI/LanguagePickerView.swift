//
//  LanguagePickerView.swift
//  Plagit
//
//  Searchable multi-select language picker with proper Language model.
//

import SwiftUI

struct Language: Identifiable {
    let id: String  // ISO 639-1 code
    let code: String
    let name: String
    let nativeName: String
    let flag: String?
}

struct LanguagePickerView: View {
    @Binding var selected: Set<String>
    var onDone: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""
    @State private var draft: Set<String> = []

    private var filtered: [Language] {
        let list = Language.all
        if search.isEmpty { return list }
        let q = search.lowercased()
        return list.filter {
            $0.name.lowercased().contains(q) ||
            $0.nativeName.lowercased().contains(q) ||
            $0.code.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Selected section at top when not searching
                if search.isEmpty && !draft.isEmpty {
                    Section {
                        ForEach(Language.all.filter { draft.contains($0.code) }) { lang in
                            languageRow(lang)
                        }
                    } header: {
                        Text("\(draft.count) selected").font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                    }
                }

                // All languages
                Section {
                    ForEach(filtered) { lang in
                        languageRow(lang)
                    }
                } header: {
                    if search.isEmpty && !draft.isEmpty {
                        Text("All Languages").font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                    }
                }
            }
            .searchable(text: $search, prompt: "Search by name or language code")
            .navigationTitle("Languages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selected = draft
                        onDone()
                        dismiss()
                    }
                    .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).bold()
                }
            }
        }
        .onAppear { draft = selected }
    }

    private func languageRow(_ lang: Language) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if draft.contains(lang.code) { draft.remove(lang.code) }
                else { draft.insert(lang.code) }
            }
        } label: {
            HStack(spacing: PlagitSpacing.sm) {
                // Flag
                if let flag = lang.flag {
                    Text(flag).font(.system(size: 18)).frame(width: 28)
                } else {
                    Color.clear.frame(width: 28, height: 18)
                }

                // nativeName (English name)
                if lang.nativeName == lang.name {
                    Text(lang.name).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                } else {
                    Text("\(lang.nativeName) (\(lang.name))").font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                }

                Spacer()

                // Checkmark
                if draft.contains(lang.code) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.plagitTeal)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.plagitBorder)
                }
            }
        }
    }
}

// MARK: - Language Helpers

extension Language {
    /// Format one language: "Italiano (Italian)" or "English"
    private static func formatOne(_ lang: Language) -> String {
        lang.nativeName == lang.name ? lang.name : "\(lang.nativeName) (\(lang.name))"
    }

    /// Full display: all languages comma-separated
    static func displayLabel(for codes: Set<String>) -> String {
        let byCode = Dictionary(uniqueKeysWithValues: all.map { ($0.code, $0) })
        return codes.sorted().compactMap { byCode[$0] }.map { formatOne($0) }.joined(separator: ", ")
    }

    /// Profile display: 1-3 inline, 4+ shows first 3 + "+N more"
    static func profileLabel(for codes: Set<String>) -> String {
        let byCode = Dictionary(uniqueKeysWithValues: all.map { ($0.code, $0) })
        let resolved = codes.sorted().compactMap { byCode[$0] }
        if resolved.isEmpty { return "" }
        if resolved.count <= 3 {
            return resolved.map { formatOne($0) }.joined(separator: ", ")
        }
        let shown = resolved.prefix(3).map { formatOne($0) }.joined(separator: ", ")
        return "\(shown) +\(resolved.count - 3) more"
    }

    /// Convert a comma-separated code string "en,it,ar" to profile display
    static func profileLabel(from codeString: String?) -> String {
        guard let str = codeString, !str.isEmpty else { return "" }
        let codes = Set(str.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
        return profileLabel(for: codes)
    }

    /// Convert a comma-separated code string to full display
    static func displayLabel(from codeString: String?) -> String {
        guard let str = codeString, !str.isEmpty else { return "" }
        let codes = Set(str.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
        return displayLabel(for: codes)
    }

    /// Convert a set of codes to a storage string "en,it,ar"
    static func storageString(from codes: Set<String>) -> String {
        codes.sorted().joined(separator: ",")
    }

    /// Parse a storage string back to a set of codes
    static func parseCodes(from storage: String?) -> Set<String> {
        guard let s = storage, !s.isEmpty else { return [] }
        return Set(s.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
    }
}

// MARK: - Language Data

extension Language {
    static let all: [Language] = [
        Language(id: "af", code: "af", name: "Afrikaans", nativeName: "Afrikaans", flag: "🇿🇦"),
        Language(id: "sq", code: "sq", name: "Albanian", nativeName: "Shqip", flag: "🇦🇱"),
        Language(id: "am", code: "am", name: "Amharic", nativeName: "አማርኛ", flag: "🇪🇹"),
        Language(id: "ar", code: "ar", name: "Arabic", nativeName: "العربية", flag: "🇸🇦"),
        Language(id: "hy", code: "hy", name: "Armenian", nativeName: "Հայերեն", flag: "🇦🇲"),
        Language(id: "az", code: "az", name: "Azerbaijani", nativeName: "Azərbaycanca", flag: "🇦🇿"),
        Language(id: "eu", code: "eu", name: "Basque", nativeName: "Euskara", flag: "🇪🇸"),
        Language(id: "be", code: "be", name: "Belarusian", nativeName: "Беларуская", flag: "🇧🇾"),
        Language(id: "bn", code: "bn", name: "Bengali", nativeName: "বাংলা", flag: "🇧🇩"),
        Language(id: "bs", code: "bs", name: "Bosnian", nativeName: "Bosanski", flag: "🇧🇦"),
        Language(id: "bg", code: "bg", name: "Bulgarian", nativeName: "Български", flag: "🇧🇬"),
        Language(id: "ca", code: "ca", name: "Catalan", nativeName: "Català", flag: "🇪🇸"),
        Language(id: "ceb", code: "ceb", name: "Cebuano", nativeName: "Cebuano", flag: "🇵🇭"),
        Language(id: "ny", code: "ny", name: "Chichewa", nativeName: "ChiCheŵa", flag: "🇲🇼"),
        Language(id: "zh", code: "zh", name: "Chinese", nativeName: "中文", flag: "🇨🇳"),
        Language(id: "co", code: "co", name: "Corsican", nativeName: "Corsu", flag: "🇫🇷"),
        Language(id: "hr", code: "hr", name: "Croatian", nativeName: "Hrvatski", flag: "🇭🇷"),
        Language(id: "cs", code: "cs", name: "Czech", nativeName: "Čeština", flag: "🇨🇿"),
        Language(id: "da", code: "da", name: "Danish", nativeName: "Dansk", flag: "🇩🇰"),
        Language(id: "nl", code: "nl", name: "Dutch", nativeName: "Nederlands", flag: "🇳🇱"),
        Language(id: "en", code: "en", name: "English", nativeName: "English", flag: "🇬🇧"),
        Language(id: "eo", code: "eo", name: "Esperanto", nativeName: "Esperanto", flag: nil),
        Language(id: "et", code: "et", name: "Estonian", nativeName: "Eesti", flag: "🇪🇪"),
        Language(id: "tl", code: "tl", name: "Filipino", nativeName: "Filipino", flag: "🇵🇭"),
        Language(id: "fi", code: "fi", name: "Finnish", nativeName: "Suomi", flag: "🇫🇮"),
        Language(id: "fr", code: "fr", name: "French", nativeName: "Français", flag: "🇫🇷"),
        Language(id: "fy", code: "fy", name: "Frisian", nativeName: "Frysk", flag: "🇳🇱"),
        Language(id: "gl", code: "gl", name: "Galician", nativeName: "Galego", flag: "🇪🇸"),
        Language(id: "ka", code: "ka", name: "Georgian", nativeName: "ქართული", flag: "🇬🇪"),
        Language(id: "de", code: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪"),
        Language(id: "el", code: "el", name: "Greek", nativeName: "Ελληνικά", flag: "🇬🇷"),
        Language(id: "gu", code: "gu", name: "Gujarati", nativeName: "ગુજરાતી", flag: "🇮🇳"),
        Language(id: "ht", code: "ht", name: "Haitian Creole", nativeName: "Kreyòl Ayisyen", flag: "🇭🇹"),
        Language(id: "ha", code: "ha", name: "Hausa", nativeName: "Hausa", flag: "🇳🇬"),
        Language(id: "haw", code: "haw", name: "Hawaiian", nativeName: "ʻŌlelo Hawaiʻi", flag: "🇺🇸"),
        Language(id: "he", code: "he", name: "Hebrew", nativeName: "עברית", flag: "🇮🇱"),
        Language(id: "hi", code: "hi", name: "Hindi", nativeName: "हिन्दी", flag: "🇮🇳"),
        Language(id: "hmn", code: "hmn", name: "Hmong", nativeName: "Hmong", flag: nil),
        Language(id: "hu", code: "hu", name: "Hungarian", nativeName: "Magyar", flag: "🇭🇺"),
        Language(id: "is", code: "is", name: "Icelandic", nativeName: "Íslenska", flag: "🇮🇸"),
        Language(id: "ig", code: "ig", name: "Igbo", nativeName: "Igbo", flag: "🇳🇬"),
        Language(id: "id", code: "id", name: "Indonesian", nativeName: "Bahasa Indonesia", flag: "🇮🇩"),
        Language(id: "ga", code: "ga", name: "Irish", nativeName: "Gaeilge", flag: "🇮🇪"),
        Language(id: "it", code: "it", name: "Italian", nativeName: "Italiano", flag: "🇮🇹"),
        Language(id: "ja", code: "ja", name: "Japanese", nativeName: "日本語", flag: "🇯🇵"),
        Language(id: "jv", code: "jv", name: "Javanese", nativeName: "Basa Jawa", flag: "🇮🇩"),
        Language(id: "kn", code: "kn", name: "Kannada", nativeName: "ಕನ್ನಡ", flag: "🇮🇳"),
        Language(id: "kk", code: "kk", name: "Kazakh", nativeName: "Қазақша", flag: "🇰🇿"),
        Language(id: "km", code: "km", name: "Khmer", nativeName: "ខ្មែរ", flag: "🇰🇭"),
        Language(id: "rw", code: "rw", name: "Kinyarwanda", nativeName: "Ikinyarwanda", flag: "🇷🇼"),
        Language(id: "ko", code: "ko", name: "Korean", nativeName: "한국어", flag: "🇰🇷"),
        Language(id: "ku", code: "ku", name: "Kurdish", nativeName: "Kurdî", flag: nil),
        Language(id: "ky", code: "ky", name: "Kyrgyz", nativeName: "Кыргызча", flag: "🇰🇬"),
        Language(id: "lo", code: "lo", name: "Lao", nativeName: "ລາວ", flag: "🇱🇦"),
        Language(id: "la", code: "la", name: "Latin", nativeName: "Latina", flag: nil),
        Language(id: "lv", code: "lv", name: "Latvian", nativeName: "Latviešu", flag: "🇱🇻"),
        Language(id: "lt", code: "lt", name: "Lithuanian", nativeName: "Lietuvių", flag: "🇱🇹"),
        Language(id: "lb", code: "lb", name: "Luxembourgish", nativeName: "Lëtzebuergesch", flag: "🇱🇺"),
        Language(id: "mk", code: "mk", name: "Macedonian", nativeName: "Македонски", flag: "🇲🇰"),
        Language(id: "mg", code: "mg", name: "Malagasy", nativeName: "Malagasy", flag: "🇲🇬"),
        Language(id: "ms", code: "ms", name: "Malay", nativeName: "Bahasa Melayu", flag: "🇲🇾"),
        Language(id: "ml", code: "ml", name: "Malayalam", nativeName: "മലയാളം", flag: "🇮🇳"),
        Language(id: "mt", code: "mt", name: "Maltese", nativeName: "Malti", flag: "🇲🇹"),
        Language(id: "mi", code: "mi", name: "Māori", nativeName: "Te Reo Māori", flag: "🇳🇿"),
        Language(id: "mr", code: "mr", name: "Marathi", nativeName: "मराठी", flag: "🇮🇳"),
        Language(id: "mn", code: "mn", name: "Mongolian", nativeName: "Монгол", flag: "🇲🇳"),
        Language(id: "ne", code: "ne", name: "Nepali", nativeName: "नेपाली", flag: "🇳🇵"),
        Language(id: "no", code: "no", name: "Norwegian", nativeName: "Norsk", flag: "🇳🇴"),
        Language(id: "or", code: "or", name: "Odia", nativeName: "ଓଡ଼ିଆ", flag: "🇮🇳"),
        Language(id: "ps", code: "ps", name: "Pashto", nativeName: "پښتو", flag: "🇦🇫"),
        Language(id: "fa", code: "fa", name: "Persian", nativeName: "فارسی", flag: "🇮🇷"),
        Language(id: "pl", code: "pl", name: "Polish", nativeName: "Polski", flag: "🇵🇱"),
        Language(id: "pt", code: "pt", name: "Portuguese", nativeName: "Português", flag: "🇵🇹"),
        Language(id: "pa", code: "pa", name: "Punjabi", nativeName: "ਪੰਜਾਬੀ", flag: "🇮🇳"),
        Language(id: "ro", code: "ro", name: "Romanian", nativeName: "Română", flag: "🇷🇴"),
        Language(id: "ru", code: "ru", name: "Russian", nativeName: "Русский", flag: "🇷🇺"),
        Language(id: "sm", code: "sm", name: "Samoan", nativeName: "Gagana Samoa", flag: "🇼🇸"),
        Language(id: "gd", code: "gd", name: "Scottish Gaelic", nativeName: "Gàidhlig", flag: "🇬🇧"),
        Language(id: "sr", code: "sr", name: "Serbian", nativeName: "Српски", flag: "🇷🇸"),
        Language(id: "st", code: "st", name: "Sesotho", nativeName: "Sesotho", flag: "🇱🇸"),
        Language(id: "sn", code: "sn", name: "Shona", nativeName: "ChiShona", flag: "🇿🇼"),
        Language(id: "sd", code: "sd", name: "Sindhi", nativeName: "سنڌي", flag: "🇵🇰"),
        Language(id: "si", code: "si", name: "Sinhala", nativeName: "සිංහල", flag: "🇱🇰"),
        Language(id: "sk", code: "sk", name: "Slovak", nativeName: "Slovenčina", flag: "🇸🇰"),
        Language(id: "sl", code: "sl", name: "Slovenian", nativeName: "Slovenščina", flag: "🇸🇮"),
        Language(id: "so", code: "so", name: "Somali", nativeName: "Soomaali", flag: "🇸🇴"),
        Language(id: "es", code: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸"),
        Language(id: "su", code: "su", name: "Sundanese", nativeName: "Basa Sunda", flag: "🇮🇩"),
        Language(id: "sw", code: "sw", name: "Swahili", nativeName: "Kiswahili", flag: "🇹🇿"),
        Language(id: "sv", code: "sv", name: "Swedish", nativeName: "Svenska", flag: "🇸🇪"),
        Language(id: "tg", code: "tg", name: "Tajik", nativeName: "Тоҷикӣ", flag: "🇹🇯"),
        Language(id: "ta", code: "ta", name: "Tamil", nativeName: "தமிழ்", flag: "🇮🇳"),
        Language(id: "tt", code: "tt", name: "Tatar", nativeName: "Татар", flag: "🇷🇺"),
        Language(id: "te", code: "te", name: "Telugu", nativeName: "తెలుగు", flag: "🇮🇳"),
        Language(id: "th", code: "th", name: "Thai", nativeName: "ไทย", flag: "🇹🇭"),
        Language(id: "tr", code: "tr", name: "Turkish", nativeName: "Türkçe", flag: "🇹🇷"),
        Language(id: "tk", code: "tk", name: "Turkmen", nativeName: "Türkmen", flag: "🇹🇲"),
        Language(id: "uk", code: "uk", name: "Ukrainian", nativeName: "Українська", flag: "🇺🇦"),
        Language(id: "ur", code: "ur", name: "Urdu", nativeName: "اردو", flag: "🇵🇰"),
        Language(id: "ug", code: "ug", name: "Uyghur", nativeName: "ئۇيغۇرچە", flag: "🇨🇳"),
        Language(id: "uz", code: "uz", name: "Uzbek", nativeName: "Oʻzbek", flag: "🇺🇿"),
        Language(id: "vi", code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt", flag: "🇻🇳"),
        Language(id: "cy", code: "cy", name: "Welsh", nativeName: "Cymraeg", flag: "🇬🇧"),
        Language(id: "xh", code: "xh", name: "Xhosa", nativeName: "isiXhosa", flag: "🇿🇦"),
        Language(id: "yi", code: "yi", name: "Yiddish", nativeName: "ייִדיש", flag: nil),
        Language(id: "yo", code: "yo", name: "Yoruba", nativeName: "Yorùbá", flag: "🇳🇬"),
        Language(id: "zu", code: "zu", name: "Zulu", nativeName: "isiZulu", flag: "🇿🇦"),
    ]
}
