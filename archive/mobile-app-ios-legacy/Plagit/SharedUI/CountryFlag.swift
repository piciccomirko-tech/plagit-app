//
//  CountryFlag.swift
//  Plagit
//
//  Country flag emoji from ISO 3166-1 alpha-2 code.
//

import Foundation

// MARK: - Country Model

struct Country: Identifiable {
    let id: String      // ISO 3166-1 alpha-2 code
    let code: String    // same as id
    let name: String
    let flag: String    // stored emoji flag string
}

// MARK: - Flag Generation (free function, no static dependency)

/// Converts an ISO 3166-1 alpha-2 code like "IT" into a flag emoji like the Italian flag.
/// Uses Unicode Regional Indicator Symbols: each ASCII letter is offset to the
/// Regional Indicator block (U+1F1E6..U+1F1FF). Two consecutive indicators form a flag.
private func flagEmoji(_ code: String) -> String {
    let upper = code.uppercased()
    guard upper.count == 2 else { return "" }
    let chars = Array(upper)
    guard let a = chars[0].asciiValue, let b = chars[1].asciiValue,
          let s1 = Unicode.Scalar(0x1F1E6 &+ UInt32(a) &- 0x41),
          let s2 = Unicode.Scalar(0x1F1E6 &+ UInt32(b) &- 0x41)
    else { return "" }
    var s = ""
    s.unicodeScalars.append(s1)
    s.unicodeScalars.append(s2)
    return s
}

/// Shorthand to create a Country with auto-generated flag from code
private func c(_ code: String, _ name: String) -> Country {
    Country(id: code, code: code, name: name, flag: flagEmoji(code))
}

// MARK: - CountryFlag Helpers

enum CountryFlag {
    /// Convert a code string to flag emoji (for use outside the Country model)
    static func emoji(for code: String?) -> String {
        guard let code else { return "" }
        return flagEmoji(code)
    }

    /// Format: "flag Italy" or just "Italy" if no code
    static func label(country: String?, code: String?) -> String {
        let flag = emoji(for: code)
        guard let country, !country.isEmpty else { return flag }
        return flag.isEmpty ? country : "\(flag) \(country)"
    }

    /// Legacy tuple accessor — (code, name) pairs for backwards compatibility
    static var commonCountries: [(String, String)] {
        allCountries.map { ($0.code, $0.name) }
    }

    /// Look up a Country by code
    static func country(for code: String) -> Country? {
        allCountries.first { $0.code == code }
    }

    /// Full country list — alphabetical by name, flags stored as let properties
    static let allCountries: [Country] = [
        c("AF", "Afghanistan"),
        c("AL", "Albania"),
        c("DZ", "Algeria"),
        c("AR", "Argentina"),
        c("AM", "Armenia"),
        c("AU", "Australia"),
        c("AT", "Austria"),
        c("AZ", "Azerbaijan"),
        c("BH", "Bahrain"),
        c("BD", "Bangladesh"),
        c("BY", "Belarus"),
        c("BE", "Belgium"),
        c("BA", "Bosnia and Herzegovina"),
        c("BR", "Brazil"),
        c("BG", "Bulgaria"),
        c("KH", "Cambodia"),
        c("CM", "Cameroon"),
        c("CA", "Canada"),
        c("CL", "Chile"),
        c("CN", "China"),
        c("CO", "Colombia"),
        c("CR", "Costa Rica"),
        c("HR", "Croatia"),
        c("CU", "Cuba"),
        c("CY", "Cyprus"),
        c("CZ", "Czech Republic"),
        c("DK", "Denmark"),
        c("DO", "Dominican Republic"),
        c("EC", "Ecuador"),
        c("EG", "Egypt"),
        c("SV", "El Salvador"),
        c("EE", "Estonia"),
        c("ET", "Ethiopia"),
        c("FI", "Finland"),
        c("FR", "France"),
        c("GE", "Georgia"),
        c("DE", "Germany"),
        c("GH", "Ghana"),
        c("GR", "Greece"),
        c("GT", "Guatemala"),
        c("HK", "Hong Kong"),
        c("HU", "Hungary"),
        c("IS", "Iceland"),
        c("IN", "India"),
        c("ID", "Indonesia"),
        c("IR", "Iran"),
        c("IQ", "Iraq"),
        c("IE", "Ireland"),
        c("IL", "Israel"),
        c("IT", "Italy"),
        c("JM", "Jamaica"),
        c("JP", "Japan"),
        c("JO", "Jordan"),
        c("KZ", "Kazakhstan"),
        c("KE", "Kenya"),
        c("KW", "Kuwait"),
        c("KG", "Kyrgyzstan"),
        c("LV", "Latvia"),
        c("LB", "Lebanon"),
        c("LT", "Lithuania"),
        c("LU", "Luxembourg"),
        c("MO", "Macau"),
        c("MY", "Malaysia"),
        c("MV", "Maldives"),
        c("MT", "Malta"),
        c("MU", "Mauritius"),
        c("MX", "Mexico"),
        c("MD", "Moldova"),
        c("MC", "Monaco"),
        c("MN", "Mongolia"),
        c("ME", "Montenegro"),
        c("MA", "Morocco"),
        c("MM", "Myanmar"),
        c("NP", "Nepal"),
        c("NL", "Netherlands"),
        c("NZ", "New Zealand"),
        c("NG", "Nigeria"),
        c("MK", "North Macedonia"),
        c("NO", "Norway"),
        c("OM", "Oman"),
        c("PK", "Pakistan"),
        c("PA", "Panama"),
        c("PY", "Paraguay"),
        c("PE", "Peru"),
        c("PH", "Philippines"),
        c("PL", "Poland"),
        c("PT", "Portugal"),
        c("QA", "Qatar"),
        c("RO", "Romania"),
        c("RU", "Russia"),
        c("RW", "Rwanda"),
        c("SA", "Saudi Arabia"),
        c("SN", "Senegal"),
        c("RS", "Serbia"),
        c("SG", "Singapore"),
        c("SK", "Slovakia"),
        c("SI", "Slovenia"),
        c("ZA", "South Africa"),
        c("KR", "South Korea"),
        c("ES", "Spain"),
        c("LK", "Sri Lanka"),
        c("SE", "Sweden"),
        c("CH", "Switzerland"),
        c("TW", "Taiwan"),
        c("TZ", "Tanzania"),
        c("TH", "Thailand"),
        c("TN", "Tunisia"),
        c("TR", "Turkey"),
        c("UA", "Ukraine"),
        c("AE", "United Arab Emirates"),
        c("GB", "United Kingdom"),
        c("US", "United States"),
        c("UY", "Uruguay"),
        c("UZ", "Uzbekistan"),
        c("VE", "Venezuela"),
        c("VN", "Vietnam"),
        c("ZM", "Zambia"),
        c("ZW", "Zimbabwe"),
    ]
}
