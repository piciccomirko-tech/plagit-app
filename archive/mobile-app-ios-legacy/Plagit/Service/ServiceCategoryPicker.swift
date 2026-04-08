//
//  ServiceCategoryPicker.swift
//  Plagit
//
//  2-step drill-down picker for service categories: Category → Subcategory.
//  Same UX as HospitalityCategoryPicker but uses ServiceCatalog data.
//
//  Usage:
//    .sheet(isPresented: $showPicker) {
//        ServiceCategoryPicker(
//            selectedCategoryId: $categoryId,
//            selectedSubcategoryId: $subcategoryId
//        )
//    }
//

import SwiftUI

struct ServiceCategoryPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategoryId: String
    @Binding var selectedSubcategoryId: String

    @State private var step: Step = .category
    @State private var pickedCategory: ServiceCategory?
    @State private var searchText = ""

    enum Step { case category, subcategory }

    // MARK: - Derived

    private var filteredCategories: [ServiceCategory] {
        if searchText.isEmpty { return ServiceCatalog.all }
        let q = searchText.lowercased()
        return ServiceCatalog.all.filter { cat in
            cat.name.lowercased().contains(q)
            || cat.keywords.contains { $0.contains(q) }
            || cat.subcategories.contains { $0.name.lowercased().contains(q) }
        }
    }

    private var filteredSubcategories: [ServiceSubcategory] {
        guard let cat = pickedCategory else { return [] }
        if searchText.isEmpty { return cat.subcategories }
        let q = searchText.lowercased()
        return cat.subcategories.filter { $0.name.lowercased().contains(q) }
    }

    private var smartResults: [SmartResult] {
        guard !searchText.isEmpty, step == .category else { return [] }
        let q = searchText.lowercased()
        var results: [SmartResult] = []
        var seenCats = Set<String>()
        var seenSubs = Set<String>()

        for cat in ServiceCatalog.all {
            if cat.name.lowercased().contains(q), !seenCats.contains(cat.id) {
                seenCats.insert(cat.id)
                results.append(SmartResult(id: "c_\(cat.id)", name: cat.name, icon: cat.icon, kind: .category, category: cat, subcategory: nil))
            }
            for sub in cat.subcategories {
                if sub.name.lowercased().contains(q), !seenSubs.contains(sub.id) {
                    seenSubs.insert(sub.id)
                    results.append(SmartResult(id: "s_\(sub.id)", name: sub.name, icon: cat.icon, kind: .subcategory, category: cat, subcategory: sub))
                }
            }
            // Keyword match → show category
            if !cat.name.lowercased().contains(q), cat.keywords.contains(where: { $0.contains(q) }), !seenCats.contains(cat.id) {
                seenCats.insert(cat.id)
                results.append(SmartResult(id: "c_\(cat.id)", name: cat.name, icon: cat.icon, kind: .category, category: cat, subcategory: nil))
            }
        }
        return results.sorted {
            let aPrefix = $0.name.lowercased().hasPrefix(q)
            let bPrefix = $1.name.lowercased().hasPrefix(q)
            if aPrefix != bPrefix { return aPrefix }
            if $0.kind != $1.kind { return $0.kind == .category }
            return $0.name < $1.name
        }
    }

    private var isSearching: Bool { !searchText.isEmpty && step == .category }

    struct SmartResult: Identifiable {
        let id: String
        let name: String
        let icon: String
        let kind: Kind
        let category: ServiceCategory
        let subcategory: ServiceSubcategory?
        enum Kind { case category, subcategory }
        var kindLabel: String { kind == .category ? "Category" : "Subcategory" }
        var breadcrumb: String {
            switch kind {
            case .category: return "\(category.subcategories.count) subcategories"
            case .subcategory: return category.name
            }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    header
                    searchBar
                    stepIndicator.padding(.top, PlagitSpacing.sm)

                    if isSearching {
                        searchResultsList
                    } else {
                        switch step {
                        case .category:    categoryList
                        case .subcategory: subcategoryList
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
            Text(step == .category ? "Select Service Category" : (pickedCategory?.name ?? "Subcategory"))
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)
            Spacer()
            if !selectedCategoryId.isEmpty {
                Button {
                    selectedCategoryId = ""; selectedSubcategoryId = ""
                    dismiss()
                } label: {
                    Text("Clear").font(PlagitFont.captionMedium()).foregroundColor(.plagitUrgent)
                }
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.sm)
    }

    private func handleBack() {
        searchText = ""
        switch step {
        case .category:    dismiss()
        case .subcategory: step = .category; pickedCategory = nil
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search category, subcategory or service...", text: $searchText)
                .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary)
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
            stepLine(active: step == .subcategory)
            stepDot(label: "Subcategory", active: step == .subcategory)
        }
        .padding(.horizontal, PlagitSpacing.xxl)
        .padding(.vertical, PlagitSpacing.md)
    }

    private func stepDot(label: String, active: Bool) -> some View {
        VStack(spacing: 4) {
            Circle().fill(active ? Color.plagitAmber : Color.plagitBorder).frame(width: 10, height: 10)
            Text(label).font(PlagitFont.micro()).foregroundColor(active ? .plagitAmber : .plagitTertiary)
        }
    }

    private func stepLine(active: Bool) -> some View {
        Rectangle().fill(active ? Color.plagitAmber : Color.plagitBorder)
            .frame(height: 2).frame(maxWidth: .infinity).padding(.bottom, 16)
    }

    // MARK: - Category List

    private var categoryList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.sm) {
                ForEach(filteredCategories) { cat in
                    let isSelected = cat.id == selectedCategoryId
                    Button {
                        pickedCategory = cat; searchText = ""
                        withAnimation(.easeInOut(duration: 0.2)) { step = .subcategory }
                    } label: {
                        HStack(spacing: PlagitSpacing.md) {
                            ZStack {
                                Circle().fill(isSelected ? Color.plagitAmber.opacity(0.12) : Color.plagitSurface).frame(width: 40, height: 40)
                                Image(systemName: cat.icon).font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isSelected ? .plagitAmber : .plagitSecondary)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cat.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                Text("\(cat.subcategories.count) subcategories").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                            }
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 16)).foregroundColor(.plagitAmber)
                            }
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
                        }
                        .padding(PlagitSpacing.md)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(isSelected ? Color.plagitAmber.opacity(0.04) : Color.plagitCardBackground))
                        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.md).stroke(isSelected ? Color.plagitAmber.opacity(0.3) : Color.plagitBorder.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm).padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    // MARK: - Subcategory List

    private var subcategoryList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.sm) {
                ForEach(filteredSubcategories) { sub in
                    let isSelected = sub.id == selectedSubcategoryId
                    Button {
                        guard let cat = pickedCategory else { return }
                        selectedCategoryId = cat.id
                        selectedSubcategoryId = sub.id
                        dismiss()
                    } label: {
                        HStack(spacing: PlagitSpacing.md) {
                            Text(sub.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 16)).foregroundColor(.plagitAmber)
                            }
                        }
                        .padding(PlagitSpacing.md)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(isSelected ? Color.plagitAmber.opacity(0.04) : Color.plagitCardBackground))
                        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.md).stroke(isSelected ? Color.plagitAmber.opacity(0.3) : Color.plagitBorder.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm).padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        Group {
            if smartResults.isEmpty {
                VStack(spacing: PlagitSpacing.md) {
                    Spacer()
                    Image(systemName: "magnifyingglass").font(.system(size: 28)).foregroundColor(.plagitTertiary)
                    Text("No results for \"\(searchText)\"").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                    Spacer()
                }
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: PlagitSpacing.sm) {
                        ForEach(smartResults) { result in
                            Button {
                                searchText = ""
                                switch result.kind {
                                case .category:
                                    pickedCategory = result.category
                                    withAnimation(.easeInOut(duration: 0.2)) { step = .subcategory }
                                case .subcategory:
                                    if let sub = result.subcategory {
                                        selectedCategoryId = result.category.id
                                        selectedSubcategoryId = sub.id
                                        dismiss()
                                    }
                                }
                            } label: {
                                HStack(spacing: PlagitSpacing.md) {
                                    ZStack {
                                        Circle().fill(Color.plagitSurface).frame(width: 36, height: 36)
                                        Image(systemName: result.icon).font(.system(size: 14, weight: .medium)).foregroundColor(.plagitSecondary)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(result.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                        HStack(spacing: PlagitSpacing.sm) {
                                            Text(result.kindLabel).font(PlagitFont.micro())
                                                .foregroundColor(result.kind == .category ? .plagitAmber : .plagitTeal)
                                                .padding(.horizontal, 6).padding(.vertical, 2)
                                                .background(Capsule().fill((result.kind == .category ? Color.plagitAmber : Color.plagitTeal).opacity(0.1)))
                                            Text(result.breadcrumb).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: result.kind == .subcategory ? "" : "chevron.right")
                                        .font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
                                }
                                .padding(PlagitSpacing.md)
                                .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitCardBackground))
                                .overlay(RoundedRectangle(cornerRadius: PlagitRadius.md).stroke(Color.plagitBorder.opacity(0.3), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm).padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
    }
}

// MARK: - Compact Display Button

struct ServiceCategoryButton: View {
    let categoryId: String
    let subcategoryId: String
    let action: () -> Void

    private var displayText: String {
        var parts: [String] = []
        if let c = ServiceCatalog.category(id: categoryId) { parts.append(c.name) }
        if let s = ServiceCatalog.subcategory(id: subcategoryId) { parts.append(s.name) }
        return parts.isEmpty ? "Select service category" : parts.joined(separator: " > ")
    }

    private var hasSelection: Bool { !categoryId.isEmpty }

    var body: some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle().fill(hasSelection ? Color.plagitAmber.opacity(0.1) : Color.plagitSurface).frame(width: 36, height: 36)
                    Image(systemName: hasSelection
                          ? (ServiceCatalog.category(id: categoryId)?.icon ?? "briefcase")
                          : "briefcase")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(hasSelection ? .plagitAmber : .plagitTertiary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Service Category *").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Text(displayText).font(PlagitFont.body())
                        .foregroundColor(hasSelection ? .plagitCharcoal : .plagitTertiary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.md)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
        .buttonStyle(.plain)
    }
}
