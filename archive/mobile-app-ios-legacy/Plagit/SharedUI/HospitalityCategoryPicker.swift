//
//  HospitalityCategoryPicker.swift
//  Plagit
//
//  3-step drill-down picker: Category → Subcategory → Role.
//  Presented as a sheet. Includes search across all levels.
//
//  Usage:
//    .sheet(isPresented: $showPicker) {
//        HospitalityCategoryPicker(
//            selectedCategoryId: $categoryId,
//            selectedSubcategoryId: $subcategoryId,
//            selectedRoleId: $roleId
//        )
//    }
//

import SwiftUI

struct HospitalityCategoryPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategoryId: String
    @Binding var selectedSubcategoryId: String
    @Binding var selectedRoleId: String

    @State private var step: Step = .category
    @State private var pickedCategory: HospitalityCategory?
    @State private var pickedSubcategory: HospitalitySubcategory?
    @State private var searchText = ""

    enum Step { case category, subcategory, role }

    // MARK: - Derived

    private var filteredCategories: [HospitalityCategory] {
        if searchText.isEmpty { return HospitalityCatalog.all }
        let q = searchText.lowercased()
        return HospitalityCatalog.all.filter { cat in
            cat.name.lowercased().contains(q)
            || cat.subcategories.contains { sub in
                sub.name.lowercased().contains(q)
                || sub.roles.contains { $0.name.lowercased().contains(q) }
            }
        }
    }

    /// Split categories into (popular, other) — only when not searching
    private var popularCategories: [HospitalityCategory] {
        guard searchText.isEmpty else { return [] }
        let order = HospitalityCatalog.popularCategoryIds
        return order.compactMap { id in HospitalityCatalog.all.first { $0.id == id } }
    }
    private var otherCategories: [HospitalityCategory] {
        guard searchText.isEmpty else { return filteredCategories }
        let pop = Set(HospitalityCatalog.popularCategoryIds)
        return HospitalityCatalog.all.filter { !pop.contains($0.id) }
    }

    private var filteredSubcategories: [HospitalitySubcategory] {
        guard let cat = pickedCategory else { return [] }
        if searchText.isEmpty { return cat.subcategories }
        let q = searchText.lowercased()
        return cat.subcategories.filter { sub in
            sub.name.lowercased().contains(q)
            || sub.roles.contains { $0.name.lowercased().contains(q) }
        }
    }

    private var filteredRoles: [HospitalityRole] {
        guard let sub = pickedSubcategory else { return [] }
        if searchText.isEmpty { return sub.roles }
        let q = searchText.lowercased()
        return sub.roles.filter { $0.name.lowercased().contains(q) }
    }

    private var smartResults: [HospitalityCatalog.SmartSearchResult] {
        HospitalityCatalog.smartSearch(searchText)
    }

    private var isSearching: Bool { !searchText.isEmpty && step == .category }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    searchBar
                    stepIndicator
                        .padding(.top, PlagitSpacing.sm)

                    if isSearching {
                        searchResultsList
                    } else {
                        switch step {
                        case .category:   categoryList
                        case .subcategory: subcategoryList
                        case .role:        roleList
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { handleBack() } label: {
                Image(systemName: step == .category ? "xmark" : "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.plagitCharcoal)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Text(headerTitle)
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)
            Spacer()
            // Clear selection
            if !selectedCategoryId.isEmpty {
                Button {
                    selectedCategoryId = ""
                    selectedSubcategoryId = ""
                    selectedRoleId = ""
                    dismiss()
                } label: {
                    Text("Clear")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitUrgent)
                }
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.sm)
    }

    private var headerTitle: String {
        switch step {
        case .category:    return "Select Category"
        case .subcategory: return pickedCategory?.name ?? "Subcategory"
        case .role:        return pickedSubcategory?.name ?? "Role"
        }
    }

    private func handleBack() {
        searchText = ""
        switch step {
        case .category:    dismiss()
        case .subcategory: step = .category; pickedCategory = nil
        case .role:        step = .subcategory; pickedSubcategory = nil
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
            TextField("Search category, subcategory or role...", text: $searchText)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.plagitTertiary)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.md)
        .padding(.vertical, PlagitSpacing.sm + 2)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.sm)
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: PlagitSpacing.sm) {
            stepDot(label: "Category", active: true)
            stepLine(active: step != .category)
            stepDot(label: "Subcategory", active: step == .subcategory || step == .role)
            stepLine(active: step == .role)
            stepDot(label: "Role", active: step == .role)
        }
        .padding(.horizontal, PlagitSpacing.xxl)
        .padding(.vertical, PlagitSpacing.md)
    }

    private func stepDot(label: String, active: Bool) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(active ? Color.plagitTeal : Color.plagitBorder)
                .frame(width: 10, height: 10)
            Text(label)
                .font(PlagitFont.micro())
                .foregroundColor(active ? .plagitTeal : .plagitTertiary)
        }
    }

    private func stepLine(active: Bool) -> some View {
        Rectangle()
            .fill(active ? Color.plagitTeal : Color.plagitBorder)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16) // align with dots, above labels
    }

    // MARK: - Category List

    private var categoryList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.sm) {
                if searchText.isEmpty {
                    // Popular section
                    sectionHeader("Most Popular")
                    ForEach(popularCategories) { cat in categoryRow(cat) }
                    // All section
                    sectionHeader("All Categories").padding(.top, PlagitSpacing.md)
                    ForEach(otherCategories) { cat in categoryRow(cat) }
                } else {
                    ForEach(filteredCategories) { cat in categoryRow(cat) }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.sm)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func categoryRow(_ cat: HospitalityCategory) -> some View {
        let isSelected = cat.id == selectedCategoryId
        return Button {
            pickedCategory = cat
            searchText = ""
            withAnimation(.easeInOut(duration: 0.2)) { step = .subcategory }
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.plagitTeal.opacity(0.12) : Color.plagitSurface)
                        .frame(width: 40, height: 40)
                    Image(systemName: cat.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .plagitTeal : .plagitSecondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(cat.name)
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)
                    Text("\(cat.subcategories.count) subcategories")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTertiary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.plagitTeal)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(isSelected ? Color.plagitTeal.opacity(0.04) : Color.plagitCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .stroke(isSelected ? Color.plagitTeal.opacity(0.3) : Color.plagitBorder.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitSecondary)
            Spacer()
        }
        .padding(.top, PlagitSpacing.sm)
    }

    // MARK: - Subcategory List

    private var subcategoryList: some View {
        let subs = filteredSubcategories
        let catId = pickedCategory?.id ?? ""
        let sorted = searchText.isEmpty
            ? HospitalityCatalog.sortedSubcategories(for: catId, from: subs)
            : (popular: [HospitalitySubcategory](), other: subs)

        return ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.sm) {
                if !sorted.popular.isEmpty {
                    sectionHeader("Most Common")
                    ForEach(sorted.popular) { sub in subcategoryRow(sub) }
                    if !sorted.other.isEmpty {
                        sectionHeader("All").padding(.top, PlagitSpacing.md)
                    }
                }
                ForEach(sorted.other) { sub in subcategoryRow(sub) }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.sm)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func subcategoryRow(_ sub: HospitalitySubcategory) -> some View {
        let isSelected = sub.id == selectedSubcategoryId
        return Button {
            pickedSubcategory = sub
            searchText = ""
            withAnimation(.easeInOut(duration: 0.2)) { step = .role }
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(sub.name)
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)
                    Text("\(sub.roles.count) roles")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTertiary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.plagitTeal)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(isSelected ? Color.plagitTeal.opacity(0.04) : Color.plagitCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .stroke(isSelected ? Color.plagitTeal.opacity(0.3) : Color.plagitBorder.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Role List

    private var roleList: some View {
        let allRoles = filteredRoles
        let sorted = searchText.isEmpty
            ? HospitalityCatalog.sortedRoles(from: allRoles)
            : (popular: [HospitalityRole](), other: allRoles)

        return ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.sm) {
                if !sorted.popular.isEmpty {
                    sectionHeader("Most Common Roles")
                    ForEach(sorted.popular) { role in roleRow(role) }
                    if !sorted.other.isEmpty {
                        sectionHeader("All Roles").padding(.top, PlagitSpacing.md)
                    }
                }
                ForEach(sorted.other) { role in roleRow(role) }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.sm)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func roleRow(_ role: HospitalityRole) -> some View {
        let isSelected = role.id == selectedRoleId
        return Button {
            selectRole(role)
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.plagitTeal.opacity(0.12) : Color.plagitSurface)
                        .frame(width: 36, height: 36)
                    Image(systemName: role.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .plagitTeal : .plagitSecondary)
                }
                Text(role.name)
                    .font(PlagitFont.bodyMedium())
                    .foregroundColor(.plagitCharcoal)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.plagitTeal)
                }
            }
            .padding(PlagitSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(isSelected ? Color.plagitTeal.opacity(0.04) : Color.plagitCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .stroke(isSelected ? Color.plagitTeal.opacity(0.3) : Color.plagitBorder.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        Group {
            if smartResults.isEmpty {
                VStack(spacing: PlagitSpacing.md) {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 28))
                        .foregroundColor(.plagitTertiary)
                    Text("No results for \"\(searchText)\"")
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitSecondary)
                    Spacer()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: PlagitSpacing.sm) {
                        ForEach(smartResults) { result in
                            smartResultRow(result)
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.sm)
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
    }

    private func smartResultRow(_ result: HospitalityCatalog.SmartSearchResult) -> some View {
        let isSelected: Bool = {
            switch result.kind {
            case .category:    return result.category.id == selectedCategoryId && selectedSubcategoryId.isEmpty
            case .subcategory: return result.subcategory?.id == selectedSubcategoryId && selectedRoleId.isEmpty
            case .role:        return result.role?.id == selectedRoleId
            }
        }()

        return Button {
            searchText = ""
            switch result.kind {
            case .category:
                pickedCategory = result.category
                withAnimation(.easeInOut(duration: 0.2)) { step = .subcategory }
            case .subcategory:
                pickedCategory = result.category
                pickedSubcategory = result.subcategory
                withAnimation(.easeInOut(duration: 0.2)) { step = .role }
            case .role:
                if let sub = result.subcategory, let role = result.role {
                    pickedCategory = result.category
                    pickedSubcategory = sub
                    selectRole(role)
                }
            }
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.plagitTeal.opacity(0.12) : Color.plagitSurface)
                        .frame(width: 36, height: 36)
                    Image(systemName: result.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? .plagitTeal : .plagitSecondary)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(result.name)
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(result.kindLabel)
                            .font(PlagitFont.micro())
                            .foregroundColor(kindColor(result.kind))
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(kindColor(result.kind).opacity(0.1)))
                        if result.kind != .category {
                            Text(result.breadcrumb)
                                .font(PlagitFont.micro())
                                .foregroundColor(.plagitTertiary)
                        }
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.plagitTeal)
                }
                Image(systemName: result.kind == .role ? "" : "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(isSelected ? Color.plagitTeal.opacity(0.04) : Color.plagitCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .stroke(isSelected ? Color.plagitTeal.opacity(0.3) : Color.plagitBorder.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func kindColor(_ kind: HospitalityCatalog.SmartResultKind) -> Color {
        switch kind {
        case .category:    return .plagitTeal
        case .subcategory: return .plagitIndigo
        case .role:        return .plagitAmber
        }
    }

    // MARK: - Selection

    private func selectRole(_ role: HospitalityRole) {
        guard let cat = pickedCategory, let sub = pickedSubcategory else { return }
        selectedCategoryId = cat.id
        selectedSubcategoryId = sub.id
        selectedRoleId = role.id
        dismiss()
    }
}

// MARK: - Compact Display Button

/// Tappable row that shows the current selection and opens the picker sheet.
/// Use this inside forms to replace old venue/role chips.
struct HospitalityCategoryButton: View {
    let categoryId: String
    let subcategoryId: String
    let roleId: String
    let action: () -> Void

    private var displayText: String {
        let path = HospitalityCatalog.displayPath(categoryId: categoryId, subcategoryId: subcategoryId, roleId: roleId)
        return path.isEmpty ? "Select category & role" : path
    }

    private var hasSelection: Bool { !categoryId.isEmpty }

    var body: some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle()
                        .fill(hasSelection ? Color.plagitTeal.opacity(0.1) : Color.plagitSurface)
                        .frame(width: 36, height: 36)
                    Image(systemName: hasSelection
                          ? (HospitalityCatalog.category(id: categoryId)?.icon ?? "briefcase")
                          : "briefcase")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(hasSelection ? .plagitTeal : .plagitTertiary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Category & Role")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTertiary)
                    Text(displayText)
                        .font(PlagitFont.body())
                        .foregroundColor(hasSelection ? .plagitCharcoal : .plagitTertiary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.md)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
        .buttonStyle(.plain)
    }
}
