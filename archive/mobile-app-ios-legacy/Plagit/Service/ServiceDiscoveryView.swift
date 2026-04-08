//
//  ServiceDiscoveryView.swift
//  Plagit
//
//  Browse and search hospitality service providers.
//  Entry point from "Find Services" on the main screen.
//

import SwiftUI

struct ServiceDiscoveryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategoryId: String?
    @State private var selectedSubcategoryId: String?
    @State private var verifiedOnly = false
    @State private var premiumOnly = false
    @State private var availableOnly = false
    @State private var showFilters = false
    @State private var showCompanyProfile = false
    @State private var selectedCompany: ServiceCompany?

    private var filteredCompanies: [ServiceCompany] {
        ServiceCatalog.searchCompanies(
            query: searchText,
            categoryId: selectedCategoryId,
            subcategoryId: selectedSubcategoryId,
            verifiedOnly: verifiedOnly,
            premiumOnly: premiumOnly,
            availableOnly: availableOnly
        )
    }

    private var activeFilterCount: Int {
        var c = 0
        if verifiedOnly { c += 1 }
        if premiumOnly { c += 1 }
        if availableOnly { c += 1 }
        if selectedSubcategoryId != nil { c += 1 }
        return c
    }

    private var subcategories: [ServiceSubcategory] {
        guard let catId = selectedCategoryId else { return [] }
        return ServiceCatalog.category(id: catId)?.subcategories ?? []
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                searchBar
                categoryChips.padding(.top, PlagitSpacing.sm)
                if !subcategories.isEmpty {
                    subcategoryChips.padding(.top, PlagitSpacing.xs)
                }

                if filteredCompanies.isEmpty {
                    emptyState
                } else {
                    companyList
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showCompanyProfile) {
            if let company = selectedCompany {
                ServiceCompanyProfileView(company: company).navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showFilters) { filterSheet }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.plagitCharcoal)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Text(L10n.findServices)
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)
            Spacer()
            Button { showFilters = true } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.plagitCharcoal)
                        .frame(width: 36, height: 36)
                    if activeFilterCount > 0 {
                        Text("\(activeFilterCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(Color.plagitAmber))
                            .offset(x: 4, y: -2)
                    }
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.sm)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
            TextField("Search services, companies, locations...", text: $searchText)
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
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                chipButton(label: "All", icon: nil, isActive: selectedCategoryId == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategoryId = nil
                        selectedSubcategoryId = nil
                    }
                }
                ForEach(ServiceCatalog.all) { cat in
                    chipButton(label: cat.name, icon: cat.icon, isActive: selectedCategoryId == cat.id) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedCategoryId == cat.id {
                                selectedCategoryId = nil
                            } else {
                                selectedCategoryId = cat.id
                            }
                            selectedSubcategoryId = nil
                        }
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Subcategory Chips

    private var subcategoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                subChip(label: "All", isActive: selectedSubcategoryId == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedSubcategoryId = nil }
                }
                ForEach(subcategories) { sub in
                    subChip(label: sub.name, isActive: selectedSubcategoryId == sub.id) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedSubcategoryId = selectedSubcategoryId == sub.id ? nil : sub.id
                        }
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func subChip(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(PlagitFont.micro())
                .foregroundColor(isActive ? .white : .plagitTertiary)
                .padding(.horizontal, PlagitSpacing.md)
                .padding(.vertical, PlagitSpacing.xs + 1)
                .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
                .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
        }
    }

    private func chipButton(label: String, icon: String?, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.xs) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 11, weight: .medium))
                }
                Text(label).font(PlagitFont.captionMedium())
            }
            .foregroundColor(isActive ? .white : .plagitSecondary)
            .padding(.horizontal, PlagitSpacing.lg)
            .padding(.vertical, PlagitSpacing.sm)
            .background(Capsule().fill(isActive ? Color.plagitAmber : Color.plagitSurface))
            .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
        }
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                VStack(spacing: PlagitSpacing.lg) {
                    Toggle(isOn: $verifiedOnly) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 14)).foregroundColor(.plagitVerified)
                            Text("Verified Only").font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        }
                    }.tint(.plagitTeal)

                    Toggle(isOn: $premiumOnly) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "crown.fill").font(.system(size: 14)).foregroundColor(.plagitAmber)
                            Text("Premium Only").font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        }
                    }.tint(.plagitTeal)

                    Toggle(isOn: $availableOnly) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "clock.badge.checkmark").font(.system(size: 14)).foregroundColor(.plagitOnline)
                            Text("Available Now").font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        }
                    }.tint(.plagitTeal)

                    Spacer()

                    Button {
                        verifiedOnly = false; premiumOnly = false; availableOnly = false
                    } label: {
                        Text("Reset Filters")
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.plagitUrgent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PlagitSpacing.md)
                            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitUrgent.opacity(0.06)))
                    }
                }
                .padding(PlagitSpacing.xxl)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showFilters = false }
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitTeal)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Company List

    private var companyList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.md) {
                ForEach(filteredCompanies) { company in
                    companyCard(company)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.lg)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func companyCard(_ company: ServiceCompany) -> some View {
        Button {
            selectedCompany = company
            showCompanyProfile = true
        } label: {
            VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: PlagitRadius.md)
                            .fill(Color(hue: company.avatarHue, saturation: 0.15, brightness: 0.95))
                            .frame(width: 48, height: 48)
                        Text(company.initials)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hue: company.avatarHue, saturation: 0.6, brightness: 0.5))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Text(company.name)
                                .font(PlagitFont.bodyMedium())
                                .foregroundColor(.plagitCharcoal)
                                .lineLimit(1)
                            if company.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.plagitVerified)
                            }
                            if company.isPremium {
                                Text("PRO")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(Capsule().fill(Color.plagitAmber))
                            }
                        }
                        Text(company.subcategoryName)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitTeal)
                            .lineLimit(1)
                    }
                    Spacer()

                    if let rating = company.rating {
                        VStack(spacing: 2) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.plagitAmber)
                                Text(String(format: "%.1f", rating))
                                    .font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                            }
                            Text("\(company.reviewCount)")
                                .font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                }

                Text(company.description)
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)
                    .lineLimit(2)

                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "mappin").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal)
                    Text(company.location).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Spacer()
                    if company.isAvailable {
                        HStack(spacing: 3) {
                            Circle().fill(Color.plagitOnline).frame(width: 6, height: 6)
                            Text("Available").font(PlagitFont.micro()).foregroundColor(.plagitOnline)
                        }
                    }
                    Text(company.categoryName)
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitAmber)
                        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                        .background(Capsule().fill(Color.plagitAmber.opacity(0.1)))
                }
            }
            .padding(PlagitSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            Spacer()
            ZStack {
                Circle().fill(Color.plagitAmber.opacity(0.1)).frame(width: 56, height: 56)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.plagitAmber)
            }
            Text("No services found")
                .font(PlagitFont.bodyMedium())
                .foregroundColor(.plagitCharcoal)
            Text("Try a different search, category, or adjust your filters.")
                .font(PlagitFont.caption())
                .foregroundColor(.plagitSecondary)
                .multilineTextAlignment(.center)
            if activeFilterCount > 0 {
                Button {
                    verifiedOnly = false; premiumOnly = false; availableOnly = false
                    selectedSubcategoryId = nil
                } label: {
                    Text("Clear Filters")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitTeal)
                }
            }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xxl)
    }
}
