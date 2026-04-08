//
//  AdminMessagesView.swift
//  Plagit
//
//  Admin — Messages Moderation & Support Oversight
//

import SwiftUI

// MARK: - View

struct AdminMessagesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminMessagesViewModel()
    @State private var showSearch = false
    @State private var showSortMenu = false
    @State private var showCandidateDetail = false
    @State private var showBusinessDetail = false
    @State private var showDeleteAlert = false
    @State private var actionConvoId: UUID?

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
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, PlagitSpacing.xxxl * 2)
                    case .error(let message):
                        VStack(spacing: PlagitSpacing.lg) {
                            ZStack {
                                Circle().fill(Color.plagitUrgent.opacity(0.1)).frame(width: 48, height: 48)
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.plagitUrgent)
                            }
                            Text(message).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            Button {
                                Task { await viewModel.loadConversations() }
                            } label: {
                                Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                                    .background(Capsule().fill(Color.plagitTealLight))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, PlagitSpacing.xxxl * 2)
                        .padding(.horizontal, PlagitSpacing.xxl)
                    case .loaded:
                        if viewModel.filtered.isEmpty {
                            emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, convo in
                                    convoRow(convo)
                                    if idx < viewModel.filtered.count - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + 44 + PlagitSpacing.md) }
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xxxl)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .navigationDestination(isPresented: $showCandidateDetail) { AdminCandidateDetailView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showBusinessDetail) { AdminBusinessDetailView().navigationBarHidden(true) }
        .alert("Delete Conversation?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let id = actionConvoId { withAnimation { viewModel.deleteConversation(id: id) }; actionConvoId = nil }
            }
            Button("Cancel", role: .cancel) { actionConvoId = nil }
        } message: { Text("This conversation will be permanently removed.") }
        .confirmationDialog("Sort By", isPresented: $showSortMenu) {
            ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
            Button("Cancel", role: .cancel) {}
        }
        .task { await viewModel.loadConversations() }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Messages").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search candidate, business, job…", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.convos.count)", .plagitCharcoal, "All")
                sumChip("Flagged", "\(viewModel.countFor("Flagged"))", .plagitUrgent, "Flagged")
                sumChip("Review", "\(viewModel.countFor("Under Review"))", .plagitAmber, "Under Review")
                sumChip("Interview", "\(viewModel.countFor("Interview Related"))", .plagitIndigo, "Interview Related")
                sumChip("Support", "\(viewModel.countFor("Support Issues"))", .plagitTeal, "Support Issues")
                sumChip("Restricted", "\(viewModel.countFor("Restricted"))", .plagitTertiary, "Restricted")
                sumChip("No Reply", "\(viewModel.countFor("No Reply"))", .plagitAmber, "No Reply")
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
            Text("\(viewModel.filtered.count) conversations").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Spacer()
            Button { showSortMenu = true } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Conversation Row
    private func convoRow(_ convo: AdminConvo) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            Circle().fill(LinearGradient(colors: [Color(hue: convo.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: convo.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
                .overlay(Text(convo.candidateInitials).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                // Names + status
                HStack(spacing: PlagitSpacing.xs) {
                    Text("\(convo.candidateName) × \(convo.businessName)").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        .lineLimit(1).layoutPriority(-1)
                    statusBadge(convo.status)
                }

                // Job + last activity
                HStack(spacing: PlagitSpacing.sm) {
                    Text("Re: \(convo.jobTitle)").font(PlagitFont.caption()).foregroundColor(.plagitTeal).lineLimit(1)
                    Text("·").foregroundColor(.plagitTertiary)
                    Text(convo.lastActivity).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }

                // Last message snippet
                Text(convo.lastMessage).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)

                // Indicators
                HStack(spacing: PlagitSpacing.sm) {
                    if convo.flagCount > 0 {
                        HStack(spacing: 2) { Image(systemName: "flag.fill").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitUrgent); Text("\(convo.flagCount)").font(PlagitFont.micro()).foregroundColor(.plagitUrgent) }
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1).background(Capsule().fill(Color.plagitUrgent.opacity(0.08)))
                    }
                    if convo.supportState != "None" && convo.supportState != "Resolved" {
                        HStack(spacing: 2) { Image(systemName: "headphones").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitIndigo); Text(convo.supportState).font(PlagitFont.micro()).foregroundColor(.plagitIndigo) }
                            .lineLimit(1).fixedSize()
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1).background(Capsule().fill(Color.plagitIndigo.opacity(0.06)))
                    }
                    if convo.isInterviewRelated {
                        HStack(spacing: 2) { Image(systemName: "calendar").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitOnline); Text("Interview").font(PlagitFont.micro()).foregroundColor(.plagitOnline) }
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1).background(Capsule().fill(Color.plagitOnline.opacity(0.06)))
                    }
                    if convo.noReplyDays >= 3 {
                        Text("No reply \(convo.noReplyDays)d").font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                            .lineLimit(1).fixedSize()
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1).background(Capsule().stroke(Color.plagitAmber.opacity(0.3), lineWidth: 0.5))
                    }
                }
            }

            Spacer(minLength: 0)

            convoActionMenu(convo)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        .contentShape(Rectangle())
        .onTapGesture {
        }
    }

    // MARK: - Conversation Action Menu
    private func convoActionMenu(_ convo: AdminConvo) -> some View {
        Menu {
            Button { } label: {
                Label("View Thread", systemImage: "bubble.left.and.bubble.right")
            }

            Button { showCandidateDetail = true } label: {
                Label("View Candidate", systemImage: "person")
            }

            Button { showBusinessDetail = true } label: {
                Label("View Business", systemImage: "building.2")
            }

            Divider()

            if convo.status == "Normal" || convo.status == "Flagged" {
                Button {
                    withAnimation { viewModel.updateStatus(id: convo.id, status: "Under Review") }
                } label: {
                    Label("Mark Under Review", systemImage: "eye")
                }
            }

            if convo.status == "Flagged" || convo.status == "Under Review" {
                Button {
                    withAnimation { viewModel.updateStatus(id: convo.id, status: "Normal") }
                } label: {
                    Label("Unflag", systemImage: "flag.slash")
                }
            } else if convo.status == "Normal" {
                Button {
                    withAnimation { viewModel.updateStatus(id: convo.id, status: "Flagged") }
                } label: {
                    Label("Flag", systemImage: "flag")
                }
            }

            Button { } label: {
                Label("Escalate", systemImage: "exclamationmark.triangle")
            }

            Button { } label: {
                Label("Assign to Support", systemImage: "headphones")
            }

            Divider()

            if convo.status != "Restricted" {
                Button {
                    withAnimation { viewModel.updateStatus(id: convo.id, status: "Restricted") }
                } label: {
                    Label("Mute Thread", systemImage: "speaker.slash")
                }
            }

            if convo.status != "Archived" {
                Button {
                    withAnimation { viewModel.updateStatus(id: convo.id, status: "Archived") }
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
            }

            if convo.status == "Restricted" || convo.status == "Archived" {
                Button {
                    withAnimation { viewModel.updateStatus(id: convo.id, status: "Normal") }
                } label: {
                    Label("Restore", systemImage: "arrow.uturn.left")
                }
            }

            Button { } label: {
                Label("Add Note", systemImage: "note.text")
            }

            Divider()

            Button(role: .destructive) {
                actionConvoId = convo.id
                showDeleteAlert = true
            } label: {
                Label("Delete Conversation", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
    }

    // MARK: - Helpers

    private func statusBadge(_ status: String) -> some View {
        let color: Color = { switch status { case "Flagged": return .plagitUrgent; case "Under Review": return .plagitAmber; case "Restricted": return .plagitTertiary; case "Archived": return .plagitSecondary; case "Support": return .plagitIndigo; default: return .plagitOnline } }()
        return Group {
            if status != "Normal" {
                Text(status).font(PlagitFont.micro()).foregroundColor(color)
                    .lineLimit(1).fixedSize()
                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
                    .background(Capsule().fill(color.opacity(0.08)))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No conversations match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminMessagesView() }.preferredColorScheme(.light) }
