//
//  SaveCategoryPickerSheet.swift
//  Plagit
//
//  Lightweight bottom sheet for choosing a category when saving a post.
//

import SwiftUI

struct SaveCategoryPickerSheet: View {
    let postPreview: String
    var currentCategory: SavedPostCategory? = nil
    let onSelect: (SavedPostCategory) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2).fill(Color.plagitTertiary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, PlagitSpacing.md)

            // Title
            Text(currentCategory != nil ? L10n.t("choose_category") : L10n.t("save_to_collection"))
                .font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
                .padding(.top, PlagitSpacing.lg)

            // Post preview (compact)
            Text(postPreview)
                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                .lineLimit(1).truncationMode(.tail)
                .padding(.horizontal, PlagitSpacing.xxl).padding(.top, PlagitSpacing.sm)

            // Category grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: PlagitSpacing.md) {
                ForEach(SavedPostCategory.allCases, id: \.self) { cat in
                    let isSelected = currentCategory == cat
                    Button {
                        onSelect(cat)
                        dismiss()
                    } label: {
                        VStack(spacing: PlagitSpacing.xs) {
                            ZStack {
                                RoundedRectangle(cornerRadius: PlagitRadius.md)
                                    .fill(isSelected ? Color.plagitTeal.opacity(0.12) : Color.plagitSurface)
                                    .frame(height: 48)
                                Image(systemName: cat.icon)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(isSelected ? .plagitTeal : .plagitSecondary)
                            }
                            Text(cat.label).font(PlagitFont.micro())
                                .foregroundColor(isSelected ? .plagitTeal : .plagitCharcoal)
                                .lineLimit(1).minimumScaleFactor(0.8)
                        }
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.lg)

            // Cancel
            Button { dismiss() } label: {
                Text(L10n.cancel).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
            }
            .padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xl)
        }
        .background(Color.plagitBackground)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
    }
}
