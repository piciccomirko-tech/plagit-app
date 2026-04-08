//
//  AdminCandidatesView.swift
//  Plagit
//
//  Premium Admin Candidates Management Screen — Fully Functional
//

import SwiftUI

// MARK: - View

struct AdminCandidatesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminCandidatesViewModel()
    @State private var showSearch = false
    @State private var showCandidateDetail = false
    @State private var showSuspendAlert = false
    @State private var candidateToSuspend: UUID?

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.plagitBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                if showSearch {
                    searchBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                filterChips
                    .padding(.top, PlagitSpacing.xs)

                ScrollView(.vertical, showsIndicators: false) {
                    switch viewModel.loadingState {
                    case .idle, .loading:
                        loadingView.padding(.top, PlagitSpacing.xxxl * 2)
                    case .error(let message):
                        errorView(message).padding(.top, PlagitSpacing.xxxl * 2)
                    case .loaded:
                        if viewModel.filteredCandidates.isEmpty {
                            emptyState
                                .padding(.top, PlagitSpacing.xxxl * 2)
                        } else {
                            VStack(spacing: PlagitSpacing.lg) {
                                ForEach(viewModel.filteredCandidates) { candidate in
                                    adminCandidateCard(candidate)
                                }
                            }
                            .padding(.horizontal, PlagitSpacing.xl)
                            .padding(.top, PlagitSpacing.sectionGap)
                            .padding(.bottom, PlagitSpacing.xxxl)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await viewModel.loadCandidates() }
        .navigationDestination(isPresented: $showCandidateDetail) {
            AdminCandidateDetailView().navigationBarHidden(true)
        }
        .alert(viewModel.alertTitle(action: "Suspend", for: candidateToSuspend), isPresented: $showSuspendAlert) {
            Button("Cancel", role: .cancel) {
                candidateToSuspend = nil
            }
            Button("Suspend", role: .destructive) {
                if let id = candidateToSuspend {
                    withAnimation { viewModel.suspendCandidate(id: id) }
                }
                candidateToSuspend = nil
            }
        } message: {
            Text("Are you sure you want to suspend this candidate? They will lose access to the platform until reactivated.")
        }
    }

    // MARK: - Loading / Error States

    private var loadingView: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ProgressView().tint(.plagitTeal)
            Text("Loading candidates…").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
        }.frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitUrgent.opacity(0.10)).frame(width: 48, height: 48)
                Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text("Failed to load candidates").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(message).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            Button { Task { await viewModel.loadCandidates() } } label: {
                Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(Color.plagitTealLight))
            }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(alignment: .center) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.plagitCharcoal)
                    .frame(width: 36, height: 36)
            }

            Spacer()

            Text("Candidates")
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showSearch.toggle()
                    if !showSearch { viewModel.searchText = "" }
                }
            } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(showSearch ? .plagitTeal : .plagitCharcoal)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)

            TextField("Search by name, role, or location...", text: $viewModel.searchText)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
                .autocapitalization(.none)

            if !viewModel.searchText.isEmpty {
                Button { viewModel.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.plagitTertiary)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.sm + 2)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.md)
                .fill(Color.plagitSurface)
        )
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.bottom, PlagitSpacing.sm)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(viewModel.filters, id: \.self) { filter in
                    let count = viewModel.countFor(filter)
                    let isActive = viewModel.selectedFilter == filter

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(filter)
                                .font(PlagitFont.captionMedium())
                                .foregroundColor(isActive ? .white : .plagitSecondary)

                            if count > 0 {
                                Text("\(count)")
                                    .font(PlagitFont.micro())
                                    .foregroundColor(isActive ? .white.opacity(0.8) : .plagitTertiary)
                            }
                        }
                        .padding(.horizontal, PlagitSpacing.lg)
                        .padding(.vertical, PlagitSpacing.sm)
                        .background(
                            Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface)
                        )
                        .overlay(
                            Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5)
                        )
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Candidate Card

    private func adminCandidateCard(_ candidate: AdminCandidate) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: candidate.avatarHue, saturation: 0.45, brightness: 0.90),
                                    Color(hue: candidate.avatarHue, saturation: 0.55, brightness: 0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(candidate.initials)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )

                    if candidate.verificationStatus == "Verified" {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.plagitVerified)
                            .background(Circle().fill(.white).frame(width: 10, height: 10))
                            .offset(x: 2, y: 2)
                    }
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(candidate.name)
                            .font(PlagitFont.bodyMedium())
                            .foregroundColor(.plagitCharcoal)

                        statusPill(candidate.verificationStatus)
                    }

                    HStack(spacing: PlagitSpacing.sm) {
                        Text("\(candidate.role) · \(candidate.location)")
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)
                        if !candidate.jobType.isEmpty {
                            Text(candidate.jobType)
                                .font(PlagitFont.micro())
                                .foregroundColor(.plagitTeal)
                                .padding(.horizontal, PlagitSpacing.sm)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.plagitTealLight))
                        }
                    }

                    HStack(spacing: PlagitSpacing.sm) {
                        Text(candidate.experience)
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.plagitCharcoal)

                        Text("·")
                            .foregroundColor(.plagitTertiary)

                        Text(candidate.languages)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.xl)

            HStack(spacing: PlagitSpacing.md) {
                Text(candidate.activeSince)
                    .font(PlagitFont.micro())
                    .foregroundColor(.plagitTertiary)
                if candidate.profileViews > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "eye").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitTertiary)
                        Text("\(candidate.profileViews) views").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.sm)

            Rectangle()
                .fill(Color.plagitDivider)
                .frame(height: 1)
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.lg)

            HStack(spacing: PlagitSpacing.md) {
                Button { showCandidateDetail = true } label: {
                    Text("View Profile")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.plagitTeal))
                }

                if candidate.verificationStatus == "Verified" {
                    Button {
                        candidateToSuspend = candidate.id
                        showSuspendAlert = true
                    } label: {
                        Text("Suspend")
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.plagitUrgent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.plagitUrgent.opacity(0.08)))
                    }
                } else if candidate.verificationStatus == "Suspended" {
                    Button { withAnimation { viewModel.verifyCandidate(id: candidate.id) } } label: {
                        Text("Activate")
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.plagitOnline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.plagitOnline.opacity(0.08)))
                    }
                } else {
                    Button { withAnimation { viewModel.verifyCandidate(id: candidate.id) } } label: {
                        Text("Verify")
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.plagitTeal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.plagitTealLight))
                    }
                }

                Button { showCandidateDetail = true } label: {
                    Text("Review")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitTeal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.plagitTealLight))
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.md)
            .padding(.bottom, PlagitSpacing.xl)
        }
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
    }

    private func statusPill(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "Verified": return .plagitOnline
            case "Pending Review": return .plagitAmber
            case "Suspended": return .plagitUrgent
            case "New": return .plagitTeal
            default: return .plagitTertiary
            }
        }()

        return Text(status)
            .font(PlagitFont.micro())
            .foregroundColor(color)
            .lineLimit(1).fixedSize()
            .padding(.horizontal, PlagitSpacing.sm)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.plagitTealLight)
                    .frame(width: 48, height: 48)

                Image(systemName: emptyIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.plagitTeal)
            }

            VStack(spacing: PlagitSpacing.xs) {
                Text(emptyTitle)
                    .font(PlagitFont.bodyMedium())
                    .foregroundColor(.plagitCharcoal)

                Text(emptySubtitle)
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, PlagitSpacing.xxl)
    }

    private var emptyIcon: String {
        if !viewModel.searchText.isEmpty { return "magnifyingglass" }
        switch viewModel.selectedFilter {
        case "Verified": return "checkmark.seal"
        case "Pending Review": return "clock"
        case "Suspended": return "xmark.circle"
        case "New": return "person.badge.plus"
        default: return "person.2"
        }
    }

    private var emptyTitle: String {
        if !viewModel.searchText.isEmpty { return "No results for \"\(viewModel.searchText)\"" }
        switch viewModel.selectedFilter {
        case "Verified": return "No verified candidates"
        case "Pending Review": return "No candidates pending review"
        case "Suspended": return "No suspended candidates"
        case "New": return "No new candidates"
        default: return "No candidates found"
        }
    }

    private var emptySubtitle: String {
        if !viewModel.searchText.isEmpty { return "Try a different search term" }
        switch viewModel.selectedFilter {
        case "Pending Review": return "Candidates awaiting verification will appear here"
        case "Suspended": return "Suspended accounts will appear here"
        case "New": return "New registrations will appear here"
        default: return "Candidate accounts will appear here"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AdminCandidatesView()
    }
    .preferredColorScheme(.light)
}
