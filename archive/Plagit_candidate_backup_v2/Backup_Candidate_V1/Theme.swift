//
//  Theme.swift
//  Plagit
//
//  Premium Design System
//

import SwiftUI

// MARK: - Brand Colors

extension Color {
    // Primary brand teal
    static let plagitTeal = Color(red: 0.0, green: 0.71, blue: 0.69)
    static let plagitTealDark = Color(red: 0.0, green: 0.58, blue: 0.56)
    static let plagitTealLight = Color(red: 0.0, green: 0.71, blue: 0.69).opacity(0.10)
    static let plagitTealSubtle = Color(red: 0.0, green: 0.71, blue: 0.69).opacity(0.06)

    // Backgrounds
    static let plagitBackground = Color(red: 0.965, green: 0.969, blue: 0.973)
    static let plagitCardBackground = Color.white
    static let plagitSurface = Color(red: 0.976, green: 0.980, blue: 0.984)

    // Text
    static let plagitCharcoal = Color(red: 0.10, green: 0.11, blue: 0.14)
    static let plagitSecondary = Color(red: 0.44, green: 0.46, blue: 0.50)
    static let plagitTertiary = Color(red: 0.62, green: 0.64, blue: 0.68)

    // Dividers & borders
    static let plagitDivider = Color(red: 0.92, green: 0.93, blue: 0.94)
    static let plagitBorder = Color(red: 0.90, green: 0.91, blue: 0.93)

    // Status
    static let plagitOnline = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let plagitUrgent = Color(red: 0.96, green: 0.34, blue: 0.28)
    static let plagitVerified = Color(red: 0.0, green: 0.71, blue: 0.69)

    // Accent
    static let plagitAmber = Color(red: 0.96, green: 0.62, blue: 0.20)
    static let plagitIndigo = Color(red: 0.40, green: 0.46, blue: 0.94)
}

// MARK: - Typography

struct PlagitFont {
    static func displayLarge() -> Font {
        .system(size: 30, weight: .bold, design: .rounded)
    }
    static func displayMedium() -> Font {
        .system(size: 22, weight: .bold, design: .rounded)
    }
    static func headline() -> Font {
        .system(size: 18, weight: .bold, design: .rounded)
    }
    static func subheadline() -> Font {
        .system(size: 15, weight: .medium, design: .rounded)
    }
    static func body() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }
    static func bodyMedium() -> Font {
        .system(size: 15, weight: .medium, design: .default)
    }
    static func caption() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }
    static func captionMedium() -> Font {
        .system(size: 13, weight: .medium, design: .default)
    }
    static func micro() -> Font {
        .system(size: 11, weight: .medium, design: .default)
    }
    static func sectionTitle() -> Font {
        .system(size: 19, weight: .bold, design: .rounded)
    }
    static func statNumber() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    static func statLabel() -> Font {
        .system(size: 11, weight: .medium, design: .rounded)
    }
    static func tabLabel() -> Font {
        .system(size: 11, weight: .medium, design: .rounded)
    }
}

// MARK: - Shadows

struct PlagitShadow {
    static let cardShadowColor = Color.black.opacity(0.05)
    static let cardShadowRadius: CGFloat = 14
    static let cardShadowY: CGFloat = 5

    static let subtleShadowColor = Color.black.opacity(0.04)
    static let subtleShadowRadius: CGFloat = 10
    static let subtleShadowY: CGFloat = 3

    static let elevatedShadowColor = Color.black.opacity(0.08)
    static let elevatedShadowRadius: CGFloat = 20
    static let elevatedShadowY: CGFloat = 6
}

// MARK: - Spacing

struct PlagitSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let sectionGap: CGFloat = 28
}

// MARK: - Radius

struct PlagitRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 100
}
