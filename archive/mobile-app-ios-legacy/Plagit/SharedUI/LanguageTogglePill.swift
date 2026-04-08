//
//  LanguageTogglePill.swift
//  Plagit
//
//  Premium segmented language switch.
//  Two equal segments (e.g. IT | EN). Active segment has filled teal background.
//

import SwiftUI

struct LanguageTogglePill: View {
    var body: some View {
        let manager = AppLocaleManager.shared
        let deviceLang = AppLocaleManager.detectDeviceLanguage()

        if deviceLang != "en" {
            let isEN = manager.isEnglish
            HStack(spacing: 0) {
                // Device language segment (IT, RU, FR…)
                segment(deviceLang.uppercased(), active: !isEN)
                // English segment
                segment("EN", active: isEN)
            }
            .padding(2.5)
            .background(
                Capsule().fill(Color.plagitTeal.opacity(0.07))
            )
            .overlay(Capsule().stroke(Color.plagitTeal.opacity(0.12), lineWidth: 0.5))
            .contentShape(Capsule())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    manager.toggleEnglish()
                }
            }
        }
    }

    private func segment(_ label: String, active: Bool) -> some View {
        Text(label)
            .font(.system(size: 11.5, weight: active ? .semibold : .medium, design: .rounded))
            .foregroundColor(active ? .white : .plagitSecondary)
            .frame(width: 30, height: 22)
            .background(
                Capsule().fill(active ? Color.plagitTeal : Color.clear)
            )
    }
}
