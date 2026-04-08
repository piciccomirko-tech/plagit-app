//
//  AdminNotificationsManageView.swift
//  Plagit
//
//  Admin — Notifications Delivery & Management
//

import SwiftUI

// MARK: - View

struct AdminNotificationsManageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminNotificationsViewModel()
    @State private var showSearch = false
    @State private var showCandidateDetail = false
    @State private var showBusinessDetail = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView("Loading notifications...").frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let message):
                errorView(message)
            case .loaded:
                loadedContent
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .navigationDestination(isPresented: $showCandidateDetail) { AdminCandidateDetailView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showBusinessDetail) { AdminBusinessDetailView().navigationBarHidden(true) }
        .task { await viewModel.loadNotifications() }
    }

    // MARK: - Loaded Content
    private var loadedContent: some View {
        VStack(spacing: 0) {
            topBar.background(Color.plagitBackground).zIndex(1)
            if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }
            summaryCards.padding(.top, PlagitSpacing.xs)
            filterChips.padding(.top, PlagitSpacing.sm)
            sortRow.padding(.top, PlagitSpacing.sm)

            ScrollView(.vertical, showsIndicators: false) {
                if viewModel.filtered.isEmpty {
                    emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, notif in
                            notifRow(notif)
                            if idx < viewModel.filtered.count - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + 36 + PlagitSpacing.md) }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                    .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
    }

    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            topBar.background(Color.plagitBackground)
            Spacer()
            ZStack { Circle().fill(Color.plagitUrgent.opacity(0.08)).frame(width: 48, height: 48); Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent) }
            Text(message).font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
            Button { Task { await viewModel.loadNotifications() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) }
            Spacer()
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Notifications").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search recipient, title, type...", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.notifs.count)", .plagitCharcoal, "All")
                sumChip("Unread", "\(viewModel.countFor("Unread"))", .plagitAmber, "Unread")
                sumChip("Failed", "\(viewModel.countFor("Failed"))", .plagitUrgent, "Failed")
                sumChip("Read", "\(viewModel.countFor("Read"))", .plagitOnline, "Read")
                sumChip("Candidate", "\(viewModel.countFor("Candidate"))", .plagitTeal, "Candidate")
                sumChip("Business", "\(viewModel.countFor("Business"))", .plagitIndigo, "Business")
                sumChip("System", "\(viewModel.countFor("System"))", .plagitSecondary, "System")
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color, _ filter: String) -> some View {
        Button { withAnimation { viewModel.selectedFilter = filter } } label: {
            VStack(spacing: 2) {
                Text(count).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }.frame(width: 62).padding(.vertical, PlagitSpacing.sm).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
    }

    // MARK: - Filters
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(viewModel.filters, id: \.self) { f in
                    let isActive = viewModel.selectedFilter == f; let c = viewModel.countFor(f)
                    Button { withAnimation { viewModel.selectedFilter = f } } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(f).font(PlagitFont.captionMedium())
                            if f != "All" && c > 0 { Text("\(c)").font(PlagitFont.micro()).foregroundColor(isActive ? .white.opacity(0.7) : .plagitTertiary) }
                        }.foregroundColor(isActive ? .white : .plagitSecondary).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private var sortRow: some View {
        HStack {
            Text("\(viewModel.filtered.count) notifications").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Spacer()
            Menu {
                ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
            } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Notification Row
    private func notifRow(_ notif: AdminNotification) -> some View {
        Menu {
            if notif.deliveryState == "Failed" {
                Button { viewModel.resend(id: notif.id) } label: { Label("Resend", systemImage: "arrow.clockwise") }
                Button { viewModel.resend(id: notif.id) } label: { Label("Retry Delivery", systemImage: "arrow.triangle.2.circlepath") }
            }
            if notif.deliveryState == "Pending" {
                Button { viewModel.forceSend(id: notif.id) } label: { Label("Force Send", systemImage: "paperplane.fill") }
            }
            Button { } label: { Label("Test Notification", systemImage: "bell.badge") }
            if notif.recipientType == "Candidate" { Button { showCandidateDetail = true } label: { Label("View Recipient", systemImage: "person") } }
            if notif.recipientType == "Business" { Button { showBusinessDetail = true } label: { Label("View Recipient", systemImage: "building.2") } }
            Button { } label: { Label("View Linked Entity", systemImage: "link") }
            Button { } label: { Label("Disable Type", systemImage: "bell.slash") }
            Button { } label: { Label("Add Note", systemImage: "note.text") }
        } label: {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(typeColor(notif.notificationType).opacity(0.08)).frame(width: 36, height: 36)
                    Image(systemName: typeIcon(notif.notificationType)).font(.system(size: 13, weight: .medium)).foregroundColor(typeColor(notif.notificationType))
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    // Title + delivery state
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(notif.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        deliveryBadge(notif.deliveryState)
                    }

                    // Recipient + type
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(notif.recipientName).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        recipientBadge(notif.recipientType)
                        Text("\u{00B7}").foregroundColor(.plagitTertiary)
                        Text(notif.notificationType).font(PlagitFont.micro()).foregroundColor(typeColor(notif.notificationType))
                    }

                    // Linked entity + route
                    HStack(spacing: PlagitSpacing.sm) {
                        HStack(spacing: 2) { Image(systemName: "link").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTertiary); Text(notif.linkedEntity).font(PlagitFont.micro()).foregroundColor(.plagitSecondary) }
                        Text("\u{2192} \(notif.destinationRoute)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }

                    // Indicators
                    HStack(spacing: PlagitSpacing.sm) {
                        if !notif.isRead && notif.deliveryState != "Failed" {
                            Circle().fill(Color.plagitTeal).frame(width: 5, height: 5)
                        }
                        if notif.retryCount > 0 {
                            Text("Retried \u{00D7}\(notif.retryCount)").font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                                .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(Color.plagitAmber.opacity(0.08)))
                        }
                        Text(notif.createdDate).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }

                Spacer(minLength: 0)
                Image(systemName: "ellipsis").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        }.buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func typeIcon(_ type: String) -> String {
        switch type { case "Push": return "bell.fill"; case "Email": return "envelope.fill"; case "In-App": return "app.badge.fill"; case "SMS": return "message.fill"; default: return "bell" }
    }

    private func typeColor(_ type: String) -> Color {
        switch type { case "Push": return .plagitTeal; case "Email": return .plagitIndigo; case "In-App": return .plagitAmber; case "SMS": return .plagitOnline; default: return .plagitSecondary }
    }

    private func deliveryBadge(_ state: String) -> some View {
        let color: Color = state == "Delivered" || state == "Sent" ? .plagitOnline : (state == "Failed" ? .plagitUrgent : .plagitAmber)
        let icon: String = state == "Delivered" || state == "Sent" ? "checkmark.circle" : (state == "Failed" ? "xmark.circle" : "clock")
        return HStack(spacing: 2) {
            Image(systemName: icon).font(.system(size: 8, weight: .medium)).foregroundColor(color)
            Text(state).font(PlagitFont.micro()).foregroundColor(color)
        }.padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08))).lineLimit(1).fixedSize()
    }

    private func recipientBadge(_ type: String) -> some View {
        let color: Color = type == "Candidate" ? .plagitTeal : (type == "Business" ? .plagitIndigo : .plagitSecondary)
        return Text(type).font(PlagitFont.micro()).foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.06))).lineLimit(1).fixedSize()
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "bell.slash").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No notifications match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminNotificationsManageView() }.preferredColorScheme(.light) }
