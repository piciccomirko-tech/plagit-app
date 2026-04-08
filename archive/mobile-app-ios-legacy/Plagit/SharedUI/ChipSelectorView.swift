//
//  ChipSelectorView.swift
//  Plagit
//
//  Reusable chip/tag selector for predefined options.
//

import SwiftUI

struct ChipSelectorView: View {
    let options: [ChipOption]
    @Binding var selected: String
    var multiSelect: Bool = false
    @Binding var selectedSet: Set<String>

    var body: some View {
        FlowLayout(spacing: PlagitSpacing.sm) {
            ForEach(options) { option in
                let isActive = multiSelect
                    ? selectedSet.contains(option.value)
                    : selected == option.value

                Button {
                    if multiSelect {
                        if selectedSet.contains(option.value) {
                            selectedSet.remove(option.value)
                        } else {
                            selectedSet.insert(option.value)
                        }
                    } else {
                        selected = option.value
                    }
                } label: {
                    HStack(spacing: PlagitSpacing.xs) {
                        if let icon = option.icon {
                            Image(systemName: icon)
                                .font(.system(size: 11, weight: .medium))
                        }
                        Text(option.label)
                            .font(PlagitFont.captionMedium())
                    }
                    .padding(.horizontal, PlagitSpacing.lg)
                    .padding(.vertical, PlagitSpacing.sm + 2)
                    .foregroundColor(isActive ? .white : .plagitSecondary)
                    .background(
                        Capsule()
                            .fill(isActive ? Color.plagitTeal : Color.plagitSurface)
                    )
                    .overlay(
                        Capsule()
                            .stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// Single-select convenience initializer
extension ChipSelectorView {
    init(options: [ChipOption], selected: Binding<String>) {
        self.options = options
        self._selected = selected
        self.multiSelect = false
        self._selectedSet = .constant([])
    }
}

struct ChipOption: Identifiable {
    let id: String
    let value: String
    let label: String
    let icon: String?

    init(value: String, label: String, icon: String? = nil) {
        self.id = value
        self.value = value
        self.label = label
        self.icon = icon
    }
}

// FlowLayout is defined in CandidateCommunityView.swift — shared across the app
