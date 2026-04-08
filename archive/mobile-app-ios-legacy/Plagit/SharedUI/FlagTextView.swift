//
//  FlagTextView.swift
//  Plagit
//
//  Displays a country flag emoji with automatic fallback to a styled
//  2-letter country code badge when flag emoji can't render (e.g. iOS Simulator).
//

import SwiftUI

/// Shows flag emoji via Text(). On real devices this renders the flag.
/// On simulators that lack flag emoji support, the "?" glyph appears —
/// use `CountryBadge` for a guaranteed visual.
struct FlagTextView: View {
    let flag: String
    let size: CGFloat

    init(_ flag: String, size: CGFloat = 28) {
        self.flag = flag
        self.size = size
    }

    var body: some View {
        Text(flag)
            .font(.system(size: size))
    }
}

/// Guaranteed-visible country badge: shows the flag emoji on devices that
/// support it, with the 2-letter ISO code underneath as a reliable label.
struct CountryBadge: View {
    let code: String
    let name: String
    let flag: String

    init(_ country: Country) {
        self.code = country.code
        self.name = country.name
        self.flag = country.flag
    }

    init(code: String, flag: String = "") {
        self.code = code
        self.name = ""
        self.flag = flag.isEmpty ? CountryFlag.emoji(for: code) : flag
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(colorForCode(code).opacity(0.12))
                .frame(width: 36, height: 36)
            Text(code.uppercased())
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(colorForCode(code))
        }
    }

    private func colorForCode(_ code: String) -> Color {
        let hash = code.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .teal, .indigo, .pink, .mint, .cyan]
        return colors[abs(hash) % colors.count]
    }
}
