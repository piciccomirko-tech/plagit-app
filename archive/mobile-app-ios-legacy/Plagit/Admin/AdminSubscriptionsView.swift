//
//  AdminSubscriptionsView.swift
//  Plagit
//
//  Admin — Subscriptions & Billing Control Center
//

import SwiftUI

// MARK: - View

struct AdminSubscriptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminSubscriptionsViewModel()
    @State private var showSearch = false
    @State private var showCancelAlert = false
    @State private var cancelTargetId: UUID?

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView("Loading subscriptions...").frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let message):
                errorView(message)
            case .loaded:
                loadedContent
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .alert("Cancel Subscription", isPresented: $showCancelAlert) {
            Button("Cancel Subscription", role: .destructive) { if let id = cancelTargetId { viewModel.cancelSubscription(id: id) } }
            Button("Keep Active", role: .cancel) {}
        } message: { Text("This will cancel the subscription immediately.") }
        .task { await viewModel.loadSubscriptions() }
    }

    // MARK: - Loaded Content
    private var loadedContent: some View {
        VStack(spacing: 0) {
            topBar.background(Color.plagitBackground).zIndex(1)
            if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    revenueMetrics.padding(.top, PlagitSpacing.md)
                    summaryCards.padding(.top, PlagitSpacing.lg)
                    userTypeChips.padding(.top, PlagitSpacing.sm)
                    filterChips.padding(.top, PlagitSpacing.sm)
                    sortRow.padding(.top, PlagitSpacing.sm)

                    // Failed Payments
                    if viewModel.selectedFilter == "All" && viewModel.searchText.isEmpty && !viewModel.failedSubs.isEmpty {
                        failedSection.padding(.top, PlagitSpacing.md)
                    }

                    // Expiring Soon
                    if viewModel.selectedFilter == "All" && viewModel.searchText.isEmpty && !viewModel.expiringSubs.isEmpty {
                        expiringSection.padding(.top, PlagitSpacing.md)
                    }

                    if viewModel.filtered.isEmpty {
                        emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, sub in
                                subRow(sub)
                                if idx < viewModel.filtered.count - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + 40 + PlagitSpacing.md) }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xxxl)
                    }
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
            Button { Task { await viewModel.loadSubscriptions() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) }
            Spacer()
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Subscriptions & Billing").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search business, plan, amount...", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Revenue Metrics
    private var revenueMetrics: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "chart.bar.fill").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                Text("Billing Health").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            }
            HStack(spacing: PlagitSpacing.md) {
                revMetric("$2,894", "MRR", .plagitTeal)
                revMetric("6", "Paying", .plagitOnline)
                revMetric("33%", "Trial Conv.", .plagitAmber)
                revMetric("20%", "Failed Rate", .plagitUrgent)
                revMetric("3", "Renewing", .plagitIndigo)
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func revMetric(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(PlagitFont.headline()).foregroundColor(color)
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
        }.frame(maxWidth: .infinity)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.subs.count)", .plagitCharcoal, "All")
                sumChip("Active", "\(viewModel.countFor("Active"))", .plagitOnline, "Active")
                sumChip("Trial", "\(viewModel.countFor("Trial"))", .plagitAmber, "Trial")
                sumChip("Expiring", "\(viewModel.countFor("Expiring Soon"))", .plagitIndigo, "Expiring Soon")
                sumChip("Failed", "\(viewModel.countFor("Failed Payment"))", .plagitUrgent, "Failed Payment")
                sumChip("Cancelled", "\(viewModel.countFor("Cancelled"))", .plagitTertiary, "Cancelled")
                sumChip("Grace", "\(viewModel.countFor("Grace Period"))", .plagitAmber, "Grace Period")
                sumChip("Comp", "\(viewModel.countFor("Comp Access"))", .plagitTeal, "Comp Access")
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
    private var userTypeChips: some View {
        HStack(spacing: PlagitSpacing.sm) {
            ForEach(viewModel.userTypeFilters, id: \.self) { t in
                let isActive = viewModel.selectedUserType == t
                Button { withAnimation { viewModel.selectedUserType = t } } label: {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: t == "Candidate" ? "person.fill" : t == "Business" ? "building.2.fill" : "person.2.fill")
                            .font(.system(size: 10, weight: .medium))
                        Text(t).font(PlagitFont.captionMedium())
                    }
                    .foregroundColor(isActive ? .white : .plagitSecondary)
                    .padding(.horizontal, PlagitSpacing.lg)
                    .padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(isActive ? Color.plagitIndigo : Color.plagitSurface))
                    .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                }
            }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

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
            Text("\(viewModel.filtered.count) subscriptions").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
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

    // MARK: - Failed Payments Section
    private var failedSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitUrgent)
                Text("Failed Payments").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Text("\(viewModel.failedSubs.count)").font(PlagitFont.micro()).foregroundColor(.white).frame(width: 20, height: 20).background(Circle().fill(Color.plagitUrgent))
                Spacer()
            }
            ForEach(viewModel.failedSubs) { sub in
                HStack(spacing: PlagitSpacing.md) {
                    Circle().fill(Color.plagitUrgent).frame(width: 6, height: 6)
                    Text(sub.businessName).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    Text(sub.plan).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                    Spacer()
                    Text(sub.amount).font(PlagitFont.captionMedium()).foregroundColor(.plagitUrgent)
                    Button { } label: {
                        Text("Resend").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                    }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitUrgent.opacity(0.15), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Expiring Soon Section
    private var expiringSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitAmber)
                Text("Expiring Soon").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Spacer()
            }
            ForEach(viewModel.expiringSubs) { sub in
                HStack(spacing: PlagitSpacing.md) {
                    Circle().fill(Color.plagitAmber).frame(width: 6, height: 6)
                    Text(sub.businessName).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    Text("Renews \(sub.renewalDate)").font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                    Spacer()
                    if !sub.autoRenew { Text("Auto-off").font(PlagitFont.micro()).foregroundColor(.plagitUrgent) }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitAmber.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Subscription Row
    private func subRow(_ sub: AdminSubscription) -> some View {
        Menu {
            Button { } label: { Label("View Business", systemImage: "building.2") }
            if sub.plan != "Enterprise" { Button { viewModel.updateStatus(id: sub.id, status: sub.plan == "Basic" ? "Premium" : "Enterprise") } label: { Label("Upgrade", systemImage: "arrow.up.circle") } }
            if sub.plan != "Basic" { Button { viewModel.updateStatus(id: sub.id, status: sub.plan == "Enterprise" ? "Premium" : "Basic") } label: { Label("Downgrade", systemImage: "arrow.down.circle") } }
            if sub.status == "Trial" { Button { } label: { Label("Extend Trial", systemImage: "clock.arrow.circlepath") } }
            if sub.paymentState == "Failed" { Button { } label: { Label("Resend Invoice", systemImage: "envelope") } }
            if sub.status != "Comp" { Button { } label: { Label("Comp Access", systemImage: "gift") } }
            if sub.status != "Cancelled" { Button(role: .destructive) { cancelTargetId = sub.id; showCancelAlert = true } label: { Label("Cancel", systemImage: "xmark.circle") } }
            Button { } label: { Label("Add Note", systemImage: "note.text") }
            Button { } label: { Label("View Payment History", systemImage: "clock") }
        } label: {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                Circle().fill(LinearGradient(colors: [Color(hue: sub.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: sub.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                    .overlay(Text(sub.initials).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(.white))

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(sub.businessName).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        // User type badge
                        Text(sub.userType.capitalized)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(sub.userType == "candidate" ? Color.plagitTeal : Color.plagitIndigo))
                        planBadge(sub.plan)
                        statusBadge(sub.status)
                    }

                    HStack(spacing: PlagitSpacing.md) {
                        Text(sub.amount).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                        Text(sub.billingCycle).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                        paymentBadge(sub.paymentState)
                    }

                    HStack(spacing: PlagitSpacing.sm) {
                        if sub.status == "Trial" && sub.trialDaysLeft > 0 {
                            HStack(spacing: 2) { Image(systemName: "clock").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitAmber); Text("\(sub.trialDaysLeft)d left").font(PlagitFont.micro()).foregroundColor(.plagitAmber) }
                                .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(Color.plagitAmber.opacity(0.08)))
                        }
                        if sub.renewalDate != "\u{2014}" { Text("Renews \(sub.renewalDate)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }
                        if !sub.autoRenew && sub.status != "Cancelled" && sub.status != "Comp" {
                            Text("Auto-renew off").font(PlagitFont.micro()).foregroundColor(.plagitUrgent)
                                .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().stroke(Color.plagitUrgent.opacity(0.3), lineWidth: 0.5))
                        }
                    }

                    HStack(spacing: PlagitSpacing.sm) {
                        Text("Last payment: \(sub.lastPayment)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        Text("\u{00B7}").foregroundColor(.plagitTertiary)
                        Text("\(sub.invoiceCount) invoices").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }

                Spacer(minLength: 0)
                Image(systemName: "ellipsis").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        }.buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func planBadge(_ plan: String) -> some View {
        let color: Color = plan == "Enterprise" ? .plagitIndigo : (plan == "Premium" ? .plagitTeal : .plagitSecondary)
        return Text(plan).font(PlagitFont.micro()).foregroundColor(color).padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08))).lineLimit(1).fixedSize()
    }

    private func statusBadge(_ status: String) -> some View {
        let color: Color = { switch status { case "Active": return .plagitOnline; case "Trial": return .plagitAmber; case "Expiring": return .plagitIndigo; case "Failed": return .plagitUrgent; case "Cancelled": return .plagitTertiary; case "Grace": return .plagitAmber; case "Comp": return .plagitTeal; default: return .plagitSecondary } }()
        return Text(status).font(PlagitFont.micro()).foregroundColor(color).padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08))).lineLimit(1).fixedSize()
    }

    private func paymentBadge(_ state: String) -> some View {
        let color: Color = state == "Paid" ? .plagitOnline : (state == "Failed" ? .plagitUrgent : (state == "Trial" || state == "Pending" ? .plagitAmber : .plagitTertiary))
        return HStack(spacing: 2) {
            Image(systemName: state == "Paid" ? "checkmark.circle" : (state == "Failed" ? "xmark.circle" : "clock")).font(.system(size: 8, weight: .medium)).foregroundColor(color)
            Text(state).font(PlagitFont.micro()).foregroundColor(color)
        }.lineLimit(1).fixedSize()
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "creditcard").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No subscriptions match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminSubscriptionsView() }.preferredColorScheme(.light) }
