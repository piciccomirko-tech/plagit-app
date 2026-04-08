//
//  AdminUsersView.swift
//  Plagit
//
//  Admin — Unified Users Management (Candidates + Businesses + Admins)
//

import SwiftUI

struct AdminUsersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminUsersViewModel()
    @State private var showSearch = false
    @State private var showSortMenu = false
    @State private var showCandidateDetail = false
    @State private var showBusinessDetail = false
    @State private var showBanAlert = false
    @State private var showDeleteAlert = false
    @State private var actionUserId: UUID?
    @State private var editingUser: AdminUser?
    @State private var messagingUser: AdminUser?

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground).zIndex(1)
                if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }
                summaryCards.padding(.top, PlagitSpacing.xs)
                filterChips.padding(.top, PlagitSpacing.sm)
                sortRow.padding(.top, PlagitSpacing.sm)

                ScrollView(.vertical, showsIndicators: false) {
                    switch viewModel.loadingState {
                    case .idle, .loading:
                        loadingView.padding(.top, PlagitSpacing.xxxl * 2)
                    case .error(let message):
                        errorView(message).padding(.top, PlagitSpacing.xxxl * 2)
                    case .loaded:
                        if viewModel.filteredUsers.isEmpty {
                            emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.filteredUsers.enumerated()), id: \.element.id) { index, user in
                                    userRow(user)
                                    if index < viewModel.filteredUsers.count - 1 {
                                        Rectangle().fill(Color.plagitDivider).frame(height: 1)
                                            .padding(.leading, PlagitSpacing.xl + 44 + PlagitSpacing.md)
                                    }
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                            .padding(.horizontal, PlagitSpacing.xl)
                            .padding(.top, PlagitSpacing.md)
                            .padding(.bottom, PlagitSpacing.xxxl)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .task { await viewModel.loadUsers() }
        .navigationDestination(isPresented: $showCandidateDetail) { AdminCandidateDetailView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showBusinessDetail) { AdminBusinessDetailView().navigationBarHidden(true) }
        .alert(viewModel.alertTitle(action: "Ban", for: actionUserId), isPresented: $showBanAlert) {
            Button("Ban", role: .destructive) { if let id = actionUserId { withAnimation { viewModel.banUser(id: id) } } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This user will permanently lose access. This action cannot be easily reversed.") }
        .alert(viewModel.alertTitle(action: "Delete", for: actionUserId), isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { if let id = actionUserId { withAnimation { viewModel.deleteUser(id: id) } } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This action cannot be undone. All user data will be permanently removed.") }
        .confirmationDialog("Sort By", isPresented: $showSortMenu) {
            ForEach(viewModel.sortOptions, id: \.self) { opt in Button(opt) { viewModel.selectedSort = opt } }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(item: $editingUser) { user in
            AdminUserEditSheet(user: user) { updated in
                viewModel.updateUser(updated)
            }
        }
        .sheet(item: $messagingUser) { user in
            AdminUserMessageSheet(user: user) { subject, body in
                viewModel.sendMessage(to: user.id, subject: subject, body: body)
            }
        }
    }

    // MARK: - Loading State

    private var loadingView: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ProgressView()
                .tint(.plagitTeal)
            Text("Loading users…")
                .font(PlagitFont.caption())
                .foregroundColor(.plagitSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitUrgent.opacity(0.10)).frame(width: 48, height: 48)
                Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text("Failed to load users").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(message).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            Button { Task { await viewModel.loadUsers() } } label: {
                Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(Color.plagitTealLight))
            }
        }
        .frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text("Users").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search name, email, role, location…", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }
        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                summaryChip("All", "\(viewModel.users.count)", .plagitCharcoal)
                summaryChip("Candidates", "\(viewModel.countFor("Candidates"))", .plagitTeal)
                summaryChip("Businesses", "\(viewModel.countFor("Businesses"))", .plagitIndigo)
                summaryChip("Verified", "\(viewModel.countFor("Verified"))", .plagitOnline)
                summaryChip("Suspended", "\(viewModel.countFor("Suspended"))", .plagitUrgent)
                summaryChip("New", "\(viewModel.users.filter { $0.joinedDate.contains("Mar 2026") }.count)", .plagitAmber)
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func summaryChip(_ label: String, _ count: String, _ color: Color) -> some View {
        Button { withAnimation { viewModel.selectedFilter = label == "New" ? "All" : label } } label: {
            VStack(spacing: 2) {
                Text(count).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }
            .frame(width: 72)
            .padding(.vertical, PlagitSpacing.sm)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
    }

    // MARK: - Filters

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(viewModel.filters, id: \.self) { filter in
                    let isActive = viewModel.selectedFilter == filter
                    let count = viewModel.countFor(filter)
                    Button { withAnimation { viewModel.selectedFilter = filter } } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(filter).font(PlagitFont.captionMedium())
                            if filter != "All" && count > 0 {
                                Text("\(count)").font(PlagitFont.micro()).foregroundColor(isActive ? .white.opacity(0.7) : .plagitTertiary)
                            }
                        }
                        .foregroundColor(isActive ? .white : .plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Sort Row

    private var sortRow: some View {
        HStack {
            Text("\(viewModel.filteredUsers.count) users").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Spacer()
            Button { showSortMenu = true } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - User Row

    private func userRow(_ user: AdminUser) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hue: user.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: user.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .overlay(Text(user.initials).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))

                if user.isVerified {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 12)).foregroundColor(.plagitVerified)
                        .background(Circle().fill(.white).frame(width: 10, height: 10)).offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                // Name + type + status
                HStack(spacing: PlagitSpacing.xs) {
                    Text(user.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        .lineLimit(1).layoutPriority(-1)
                    typeBadge(user.userType)
                    statusBadge(user.status)
                }

                // Role + location
                Text("\(user.role) · \(user.location)").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)

                // Email
                Text(user.email).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)

                // Meta row
                HStack(spacing: PlagitSpacing.sm) {
                    Text("Joined \(user.joinedDate)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Text("·").foregroundColor(.plagitTertiary)
                    Text("Active \(user.lastActive)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)

                    if user.profileStrength < 70 {
                        Text("\(user.profileStrength)%").font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                            .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1)
                            .background(Capsule().fill(Color.plagitAmber.opacity(0.08)))
                    }

                    if user.flagCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flag.fill").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitUrgent)
                            Text("\(user.flagCount)").font(PlagitFont.micro()).foregroundColor(.plagitUrgent)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            userActionMenu(user)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        .contentShape(Rectangle())
        .onTapGesture {
            if user.userType == "Business" { showBusinessDetail = true } else { showCandidateDetail = true }
        }
    }

    // MARK: - User Action Menu

    private func userActionMenu(_ user: AdminUser) -> some View {
        Menu {
            Button { if user.userType == "Business" { showBusinessDetail = true } else { showCandidateDetail = true } } label: {
                Label("View Profile", systemImage: "person.crop.circle")
            }

            Button {
                editingUser = user
            } label: {
                Label("Edit User", systemImage: "pencil")
            }

            Button {
                messagingUser = user
            } label: {
                Label("Send Message", systemImage: "envelope")
            }

            if user.isVerified {
                Button {
                    withAnimation { viewModel.unverifyUser(id: user.id) }
                } label: {
                    Label("Unverify", systemImage: "xmark.seal")
                }
            } else {
                Button {
                    withAnimation { viewModel.verifyUser(id: user.id) }
                } label: {
                    Label("Verify", systemImage: "checkmark.seal")
                }
            }

            Divider()

            if user.status == "Active" {
                Button(role: .destructive) {
                    withAnimation { viewModel.suspendUser(id: user.id) }
                } label: {
                    Label("Suspend", systemImage: "pause.circle")
                }
            }

            if user.status == "Suspended" {
                Button {
                    withAnimation { viewModel.unsuspendUser(id: user.id) }
                } label: {
                    Label("Unsuspend", systemImage: "play.circle")
                }

                Button(role: .destructive) {
                    actionUserId = user.id
                    showBanAlert = true
                } label: {
                    Label("Ban", systemImage: "nosign")
                }
            }

            if user.status == "Banned" {
                Button {
                    withAnimation { viewModel.unbanUser(id: user.id) }
                } label: {
                    Label("Unban", systemImage: "arrow.uturn.left.circle")
                }
            }

            Divider()

            Button(role: .destructive) {
                actionUserId = user.id
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
    }

    private func typeBadge(_ type: String) -> some View {
        let color: Color = type == "Candidate" ? .plagitTeal : (type == "Business" ? .plagitIndigo : .plagitAmber)
        return Text(type).font(PlagitFont.micro()).foregroundColor(color)
            .lineLimit(1).fixedSize()
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    private func statusBadge(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "Active": return .plagitOnline
            case "Suspended": return .plagitUrgent
            case "Banned": return .plagitTertiary
            default: return .plagitSecondary
            }
        }()
        return Group {
            if status != "Active" {
                Text(status).font(PlagitFont.micro()).foregroundColor(color)
                    .lineLimit(1).fixedSize()
                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
                    .background(Capsule().fill(color.opacity(0.08)))
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48)
                Image(systemName: viewModel.searchText.isEmpty ? "person.2" : "magnifyingglass").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No users match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" {
                Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: {
                    Text("Show All Users").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(Color.plagitTealLight))
                }
            }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

// MARK: - Sheet Helper

struct AdminUserIndexWrapper: Identifiable {
    let id = UUID()
    let index: Int
}

// MARK: - Model

struct AdminUser: Identifiable {
    let id: UUID
    var name: String
    let initials: String
    var email: String
    let phone: String
    let userType: String   // "Candidate", "Business", "Admin"
    var location: String
    var role: String
    var status: String     // "Active", "Suspended", "Banned"
    var isVerified: Bool
    let joinedDate: String
    let lastActive: String
    let profileStrength: Int
    let flagCount: Int
    let avatarHue: Double
    let plan: String       // for businesses

    init(id: UUID = UUID(), name: String, initials: String, email: String, phone: String, userType: String, location: String, role: String, status: String, isVerified: Bool, joinedDate: String, lastActive: String, profileStrength: Int, flagCount: Int, avatarHue: Double, plan: String) {
        self.id = id; self.name = name; self.initials = initials; self.email = email; self.phone = phone; self.userType = userType; self.location = location; self.role = role; self.status = status; self.isVerified = isVerified; self.joinedDate = joinedDate; self.lastActive = lastActive; self.profileStrength = profileStrength; self.flagCount = flagCount; self.avatarHue = avatarHue; self.plan = plan
    }

    static let sampleData: [AdminUser] = [
        .init(name: "Elena Rossi", initials: "ER", email: "elena@email.com", phone: "+39 333 1234", userType: "Candidate", location: "Milan, IT", role: "Executive Chef", status: "Active", isVerified: true, joinedDate: "Mar 2025", lastActive: "2h ago", profileStrength: 92, flagCount: 0, avatarHue: 0.52, plan: ""),
        .init(name: "James Park", initials: "JP", email: "james@email.com", phone: "+44 7700 1234", userType: "Candidate", location: "London, UK", role: "Bar Manager", status: "Active", isVerified: false, joinedDate: "Mar 2026", lastActive: "1d ago", profileStrength: 65, flagCount: 0, avatarHue: 0.38, plan: ""),
        .init(name: "Sofia Blanc", initials: "SB", email: "sofia@email.com", phone: "+33 6 1234", userType: "Candidate", location: "Paris, FR", role: "Sommelier", status: "Active", isVerified: true, joinedDate: "Jan 2026", lastActive: "5h ago", profileStrength: 88, flagCount: 0, avatarHue: 0.62, plan: ""),
        .init(name: "Marco Bianchi", initials: "MB", email: "marco@email.com", phone: "+971 50 1234", userType: "Candidate", location: "Dubai, UAE", role: "Sous Chef", status: "Active", isVerified: false, joinedDate: "Mar 2026", lastActive: "Just now", profileStrength: 45, flagCount: 0, avatarHue: 0.45, plan: ""),
        .init(name: "Anna Weber", initials: "AW", email: "anna@email.com", phone: "+49 170 1234", userType: "Candidate", location: "Berlin, DE", role: "Restaurant Manager", status: "Suspended", isVerified: true, joinedDate: "Dec 2025", lastActive: "2w ago", profileStrength: 80, flagCount: 2, avatarHue: 0.58, plan: ""),
        .init(name: "Tom Chen", initials: "TC", email: "tom@email.com", phone: "+61 4 1234", userType: "Candidate", location: "Sydney, AU", role: "Line Cook", status: "Active", isVerified: false, joinedDate: "Mar 2026", lastActive: "3d ago", profileStrength: 35, flagCount: 0, avatarHue: 0.35, plan: ""),
        .init(name: "Nobu Restaurant", initials: "NR", email: "hr@nobu.com", phone: "+971 4 1234", userType: "Business", location: "Dubai, UAE", role: "Fine Dining", status: "Active", isVerified: true, joinedDate: "Jan 2025", lastActive: "1h ago", profileStrength: 95, flagCount: 0, avatarHue: 0.55, plan: "Premium"),
        .init(name: "The Ritz London", initials: "TR", email: "careers@theritz.com", phone: "+44 20 1234", userType: "Business", location: "London, UK", role: "Luxury Hotel", status: "Active", isVerified: true, joinedDate: "Feb 2025", lastActive: "30m ago", profileStrength: 98, flagCount: 0, avatarHue: 0.68, plan: "Enterprise"),
        .init(name: "Dishoom Soho", initials: "DS", email: "jobs@dishoom.com", phone: "+44 20 5678", userType: "Business", location: "London, UK", role: "Restaurant", status: "Active", isVerified: false, joinedDate: "Mar 2026", lastActive: "2d ago", profileStrength: 72, flagCount: 0, avatarHue: 0.55, plan: "Starter (Trial)"),
        .init(name: "Sky Lounge", initials: "SL", email: "info@skylounge.com", phone: "+971 4 5678", userType: "Business", location: "Dubai, UAE", role: "Rooftop Bar", status: "Banned", isVerified: false, joinedDate: "Nov 2025", lastActive: "1mo ago", profileStrength: 40, flagCount: 5, avatarHue: 0.42, plan: "Cancelled"),
        .init(name: "Fabric London", initials: "FB", email: "events@fabriclondon.com", phone: "+44 20 9012", userType: "Business", location: "London, UK", role: "Club", status: "Active", isVerified: false, joinedDate: "Mar 2026", lastActive: "1w ago", profileStrength: 55, flagCount: 1, avatarHue: 0.35, plan: "Expired"),
        .init(name: "Mirko Picicco", initials: "MP", email: "mirko@plagit.com", phone: "+971 50 999", userType: "Admin", location: "Dubai, UAE", role: "Super Admin", status: "Active", isVerified: true, joinedDate: "Jan 2025", lastActive: "Now", profileStrength: 100, flagCount: 0, avatarHue: 0.50, plan: ""),
    ]
}

// MARK: - Edit User Sheet

struct AdminUserEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    let user: AdminUser
    let onSave: (AdminUser) -> Void
    @State private var editName: String = ""
    @State private var editEmail: String = ""
    @State private var editRole: String = ""
    @State private var editLocation: String = ""
    @State private var editStatus: String = "Active"
    @State private var editVerified: Bool = false

    private let statusOptions = ["Active", "Suspended", "Banned"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        VStack(spacing: PlagitSpacing.sm) {
                            Circle()
                                .fill(LinearGradient(colors: [Color(hue: user.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: user.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 56, height: 56)
                                .overlay(Text(user.initials).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.white))
                            Text(user.userType).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                                .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                                .background(Capsule().fill(Color.plagitTealLight))
                        }.frame(maxWidth: .infinity).padding(.top, PlagitSpacing.lg)

                        VStack(spacing: 0) {
                            editField("Name", text: $editName)
                            fieldDivider
                            editField("Email", text: $editEmail, keyboard: .emailAddress)
                            fieldDivider
                            editField("Role", text: $editRole)
                            fieldDivider
                            editField("Location", text: $editLocation)
                        }
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                        .padding(.horizontal, PlagitSpacing.xl)

                        VStack(spacing: 0) {
                            HStack {
                                Text("Status").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                Spacer()
                                Picker("", selection: $editStatus) { ForEach(statusOptions, id: \.self) { Text($0) } }.tint(.plagitTeal)
                            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
                            fieldDivider
                            Toggle(isOn: $editVerified) { Text("Verified").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal) }
                                .tint(.plagitTeal).padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
                        }
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                        .padding(.horizontal, PlagitSpacing.xl)

                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.font(PlagitFont.bodyMedium()).foregroundColor(.plagitSecondary)
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit User").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updated = user
                        updated.name = editName
                        updated.email = editEmail
                        updated.role = editRole
                        updated.location = editLocation
                        updated.status = editStatus
                        updated.isVerified = editVerified
                        onSave(updated)
                        dismiss()
                    }.font(PlagitFont.bodyMedium()).foregroundColor(.plagitTeal)
                }
            }
            .onAppear {
                editName = user.name; editEmail = user.email; editRole = user.role
                editLocation = user.location; editStatus = user.status; editVerified = user.isVerified
            }
        }
    }

    private func editField(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            TextField(label, text: text).font(PlagitFont.body()).foregroundColor(.plagitCharcoal).keyboardType(keyboard).autocorrectionDisabled()
        }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md)
    }

    private var fieldDivider: some View {
        Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl)
    }
}

// MARK: - Send Message Sheet

struct AdminUserMessageSheet: View {
    @Environment(\.dismiss) private var dismiss
    let user: AdminUser
    let onSend: (String, String) -> Void
    @State private var subject: String = ""
    @State private var messageBody: String = ""
    @State private var showSentConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        HStack(spacing: PlagitSpacing.md) {
                            Circle()
                                .fill(LinearGradient(colors: [Color(hue: user.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: user.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 40, height: 40)
                                .overlay(Text(user.initials).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(.white))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(user.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                Text(user.email).font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                            }
                            Spacer()
                            Text(user.userType).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                                .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                                .background(Capsule().fill(Color.plagitTealLight))
                        }
                        .padding(PlagitSpacing.xl)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md)

                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                Text("Subject").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                TextField("Enter subject…", text: $subject).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md)
                            Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl)
                            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                Text("Message").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                TextEditor(text: $messageBody).font(PlagitFont.body()).foregroundColor(.plagitCharcoal).frame(minHeight: 160).scrollContentBackground(.hidden)
                            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md)
                        }
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                        .padding(.horizontal, PlagitSpacing.xl)

                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "info.circle").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
                            Text("This message will be sent as an admin notification to the user.").font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                        }.padding(.horizontal, PlagitSpacing.xl + PlagitSpacing.sm)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.font(PlagitFont.bodyMedium()).foregroundColor(.plagitSecondary)
                }
                ToolbarItem(placement: .principal) {
                    Text("New Message").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSentConfirmation = true
                    } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text("Send").font(PlagitFont.bodyMedium())
                            Image(systemName: "paperplane.fill").font(.system(size: 12, weight: .medium))
                        }.foregroundColor(canSend ? .plagitTeal : .plagitTertiary)
                    }.disabled(!canSend)
                }
            }
            .alert("Message Sent", isPresented: $showSentConfirmation) {
                Button("OK") {
                    onSend(subject, messageBody)
                    dismiss()
                }
            } message: { Text("Your message to \(user.name) has been sent.") }
        }
    }

    private var canSend: Bool {
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !messageBody.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

#Preview { NavigationStack { AdminUsersView() }.preferredColorScheme(.light) }
