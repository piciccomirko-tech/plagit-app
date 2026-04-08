//
//  AdminLogsView.swift
//  Plagit
//
//  Admin — Audit Trail & Activity Logs
//

import SwiftUI

struct AdminLogsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminLogsViewModel()
    @State private var showSearch = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView("Loading logs...").frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let message):
                errorView(message)
            case .loaded:
                loadedContent
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .task { await viewModel.loadLogs() }
    }

    // MARK: - Loaded Content
    private var loadedContent: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
                Spacer(); Text("Admin Logs").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
                Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: { Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal) }
            }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg).background(Color.plagitBackground)

            if showSearch {
                HStack(spacing: PlagitSpacing.md) {
                    Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
                    TextField("Search action, target, admin...", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
                }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl).transition(.move(edge: .top).combined(with: .opacity))
            }

            // Summary cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    sumChip("All", "\(viewModel.logs.count)", .plagitCharcoal, "All")
                    sumChip("Today", "\(viewModel.countFor("Today"))", .plagitTeal, "Today")
                    sumChip("Users", "\(viewModel.countFor("Users"))", .plagitTeal, "Users")
                    sumChip("Jobs", "\(viewModel.countFor("Jobs"))", .plagitIndigo, "Jobs")
                    sumChip("Business", "\(viewModel.countFor("Businesses"))", .plagitAmber, "Businesses")
                    sumChip("Reports", "\(viewModel.countFor("Reports"))", .plagitUrgent, "Reports")
                    sumChip("Billing", "\(viewModel.countFor("Billing"))", .plagitOnline, "Billing")
                    sumChip("Settings", "\(viewModel.countFor("Settings"))", .plagitSecondary, "Settings")
                }.padding(.horizontal, PlagitSpacing.xl)
            }.padding(.top, PlagitSpacing.xs)

            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    ForEach(viewModel.filters, id: \.self) { f in
                        let isActive = viewModel.selectedFilter == f; let c = viewModel.countFor(f)
                        Button { withAnimation { viewModel.selectedFilter = f } } label: {
                            HStack(spacing: PlagitSpacing.xs) { Text(f).font(PlagitFont.captionMedium()); if f != "All" && c > 0 { Text("\(c)").font(PlagitFont.micro()).foregroundColor(isActive ? .white.opacity(0.7) : .plagitTertiary) } }
                                .foregroundColor(isActive ? .white : .plagitSecondary).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                                .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface)).overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                        }
                    }
                }.padding(.horizontal, PlagitSpacing.xl)
            }.padding(.top, PlagitSpacing.sm)

            // Sort
            HStack { Text("\(viewModel.filtered.count) log entries").font(PlagitFont.caption()).foregroundColor(.plagitSecondary); Spacer()
                Menu {
                    ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
                } label: {
                    HStack(spacing: PlagitSpacing.xs) { Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal); Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal) }
                }
            }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm)

            ScrollView(.vertical, showsIndicators: false) {
                if viewModel.filtered.isEmpty {
                    VStack(spacing: PlagitSpacing.lg) { ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "clock.arrow.circlepath").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }; Text("No logs match").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
                    }.frame(maxWidth: .infinity).padding(.top, PlagitSpacing.xxxl * 2)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, log in
                            logRow(log)
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
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
                Spacer(); Text("Admin Logs").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
                Color.clear.frame(width: 36, height: 36)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg).background(Color.plagitBackground)
            Spacer()
            ZStack { Circle().fill(Color.plagitUrgent.opacity(0.08)).frame(width: 48, height: 48); Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent) }
            Text(message).font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
            Button { Task { await viewModel.loadLogs() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) }
            Spacer()
        }
    }

    private func logRow(_ log: AdminLog) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            ZStack { RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(catColor(log.category).opacity(0.08)).frame(width: 36, height: 36); Image(systemName: catIcon(log.category)).font(.system(size: 13, weight: .medium)).foregroundColor(catColor(log.category)) }
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text(log.action).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(log.target).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                if let o = log.oldValue, let n = log.newValue {
                    HStack(spacing: PlagitSpacing.xs) { Text(o).font(PlagitFont.micro()).foregroundColor(.plagitUrgent).strikethrough(); Image(systemName: "arrow.right").font(.system(size: 8, weight: .bold)).foregroundColor(.plagitTertiary); Text(n).font(PlagitFont.micro()).foregroundColor(.plagitOnline) }
                }
                HStack(spacing: PlagitSpacing.sm) {
                    Text(log.adminUser).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                    Text("\u{00B7}").foregroundColor(.plagitTertiary)
                    Text(log.timestamp).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Text("\u{00B7}").foregroundColor(.plagitTertiary)
                    Text(log.result).font(PlagitFont.micro()).foregroundColor(log.result == "Success" ? .plagitOnline : .plagitUrgent)
                }
            }
            Spacer()
        }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color, _ filter: String) -> some View {
        Button { withAnimation { viewModel.selectedFilter = filter } } label: {
            VStack(spacing: 2) { Text(count).font(PlagitFont.headline()).foregroundColor(color); Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary) }
                .frame(width: 62).padding(.vertical, PlagitSpacing.sm).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
    }

    private func catIcon(_ c: String) -> String { switch c { case "Users": return "person"; case "Jobs": return "briefcase"; case "Businesses": return "building.2"; case "Reports": return "flag"; case "Moderation": return "shield"; case "Billing": return "creditcard"; case "Community": return "text.bubble"; case "Settings": return "gearshape"; default: return "doc" } }
    private func catColor(_ c: String) -> Color { switch c { case "Users": return .plagitTeal; case "Jobs": return .plagitIndigo; case "Businesses": return .plagitAmber; case "Reports": return .plagitUrgent; case "Moderation": return .plagitUrgent; case "Billing": return .plagitOnline; case "Community": return .plagitTeal; case "Settings": return .plagitSecondary; default: return .plagitTertiary } }
}

#Preview { NavigationStack { AdminLogsView() }.preferredColorScheme(.light) }
