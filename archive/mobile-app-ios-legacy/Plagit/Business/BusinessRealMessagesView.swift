//
//  BusinessRealMessagesView.swift
//  Plagit
//
//  Real business messages backed by GET /business/conversations.
//

import SwiftUI

struct BusinessRealMessagesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var conversations: [BizConversationDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var showChat = false
    @State private var selectedConvId: String?
    @State private var searchText = ""
    @State private var showSearch = false
    @State private var bizConvToDelete: String?
    @State private var showBizDeleteConfirm = false

    private var unreadCount: Int { conversations.reduce(0) { $0 + ($1.unreadCount ?? 0) } }
    private var filtered: [BizConversationDTO] {
        guard !searchText.isEmpty else { return conversations }
        let q = searchText.lowercased()
        return conversations.filter { ($0.candidateName?.lowercased().contains(q) ?? false) || ($0.jobTitle?.lowercased().contains(q) ?? false) || ($0.lastMessage?.lowercased().contains(q) ?? false) }
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }
                if isLoading { Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer(); VStack(spacing: PlagitSpacing.md) { Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary); Button { Task { await load() } } label: { Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) } }.padding(PlagitSpacing.xxl); Spacer()
                } else if filtered.isEmpty {
                    Spacer(); emptyState; Spacer()
                } else {
                    summaryRow
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, conv in
                                conversationRow(conv)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            bizConvToDelete = conv.id; showBizDeleteConfirm = true
                                        } label: { Label(L10n.t("delete_conversation"), systemImage: "trash") }
                                    }
                                if idx < filtered.count - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + 48 + PlagitSpacing.md) }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showChat) {
            if let id = selectedConvId { BusinessRealChatView(conversationId: id).navigationBarHidden(true) }
        }
        .task { await load() }
        .alert(L10n.t("delete_conversation"), isPresented: $showBizDeleteConfirm) {
            Button(L10n.t("delete"), role: .destructive) {
                if let id = bizConvToDelete {
                    conversations.removeAll { $0.id == id }
                    Task { try? await APIClient.shared.requestVoid(.DELETE, path: "/business/conversations/\(id)") }
                }
            }
            Button(L10n.cancel, role: .cancel) {}
        } message: { Text(L10n.t("delete_conv_confirm")) }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do { conversations = try await BusinessAPIService.shared.fetchConversations() } catch { loadError = L10n.apiError(error.localizedDescription) }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text(L10n.messages).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
            Button { withAnimation(.easeInOut(duration: 0.2)) { showSearch.toggle(); if !showSearch { searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField(L10n.t("search_messages"), text: $searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !searchText.isEmpty { Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    private var summaryRow: some View {
        HStack(spacing: PlagitSpacing.lg) {
            Text("\(conversations.count) \(L10n.t("conversations"))").font(PlagitFont.micro()).foregroundColor(.plagitCharcoal)
            if unreadCount > 0 { HStack(spacing: PlagitSpacing.xs) { Circle().fill(Color.plagitTeal).frame(width: 5, height: 5); Text("\(unreadCount) \(L10n.t("unread"))").font(PlagitFont.micro()).foregroundColor(.plagitTeal) } }
            Spacer()
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm)
    }

    private func conversationRow(_ conv: BizConversationDTO) -> some View {
        let hue = conv.candidateAvatarHue ?? 0.5; let unread = (conv.unreadCount ?? 0) > 0
        return Button { selectedConvId = conv.id; showChat = true } label: {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                ProfileAvatarView(photoUrl: conv.candidatePhotoUrl, initials: conv.candidateInitials ?? "—", hue: hue, size: 48)
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(conv.candidateName ?? "Unknown").font(unread ? PlagitFont.bodyMedium() : PlagitFont.body()).foregroundColor(.plagitCharcoal)
                                let mflag = CountryFlag.emoji(for: conv.candidateNationalityCode)
                                if !mflag.isEmpty { Text(mflag).font(.system(size: 12)) }
                            }
                            if let jt = conv.jobTitle { Text("Re: \(jt)").font(PlagitFont.micro()).foregroundColor(.plagitTeal) }
                        }; Spacer()
                        if unread { Circle().fill(Color.plagitTeal).frame(width: 8, height: 8) }
                    }
                    if let msg = conv.lastMessage { Text(msg).font(PlagitFont.caption()).foregroundColor(unread ? .plagitCharcoal : .plagitSecondary).lineLimit(1) }
                }
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        }.buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            Text(L10n.t("no_messages_yet")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text(L10n.t("messages_empty_business")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
