//
//  CandidateMessagesView.swift
//  Plagit
//
//  Real candidate messages list backed by GET /candidate/conversations.
//

import SwiftUI

struct CandidateMessagesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var conversations: [ConversationDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var showChat = false
    @State private var selectedConvId: String?
    @State private var showSearch = false
    @State private var searchText = ""
    @State private var convToDelete: String?
    @State private var showDeleteConfirm = false

    private var unreadCount: Int { conversations.reduce(0) { $0 + ($1.unreadCount ?? 0) } }

    private var filteredConversations: [ConversationDTO] {
        guard !searchText.isEmpty else { return conversations }
        let q = searchText.lowercased()
        return conversations.filter {
            ($0.businessName?.lowercased().contains(q) ?? false) ||
            ($0.jobTitle?.lowercased().contains(q) ?? false) ||
            ($0.lastMessage?.lowercased().contains(q) ?? false)
        }
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }

                if isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                        Button { Task { await load() } } label: { Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else if filteredConversations.isEmpty {
                    Spacer(); emptyState; Spacer()
                } else {
                    summaryRow

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(Array(filteredConversations.enumerated()), id: \.element.id) { idx, conv in
                                conversationRow(conv)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            convToDelete = conv.id; showDeleteConfirm = true
                                        } label: { Label(L10n.t("delete_conversation"), systemImage: "trash") }
                                    }
                                if idx < filteredConversations.count - 1 {
                                    Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + 48 + PlagitSpacing.md)
                                }
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
            if let id = selectedConvId {
                CandidateChatView(conversationId: id).navigationBarHidden(true)
            }
        }
        .task { await load() }
        .alert(L10n.t("delete_conversation"), isPresented: $showDeleteConfirm) {
            Button(L10n.t("delete"), role: .destructive) {
                if let id = convToDelete {
                    conversations.removeAll { $0.id == id }
                    Task { try? await APIClient.shared.requestVoid(.DELETE, path: "/candidate/conversations/\(id)") }
                }
            }
            Button(L10n.cancel, role: .cancel) {}
        } message: { Text(L10n.t("delete_conv_confirm")) }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do { conversations = try await CandidateAPIService.shared.fetchConversations() }
        catch { loadError = L10n.apiError(error.localizedDescription) }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text(L10n.messages).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation(.easeInOut(duration: 0.2)) { showSearch.toggle(); if !showSearch { searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField(L10n.t("search_messages"), text: $searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !searchText.isEmpty { Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }
        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private var summaryRow: some View {
        HStack(spacing: PlagitSpacing.lg) {
            Text("\(conversations.count) \(L10n.t("conversations"))").font(PlagitFont.micro()).foregroundColor(.plagitCharcoal)
            if unreadCount > 0 {
                HStack(spacing: PlagitSpacing.xs) {
                    Circle().fill(Color.plagitTeal).frame(width: 5, height: 5)
                    Text("\(unreadCount) \(L10n.t("unread"))").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                }
            }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm)
    }

    private func conversationRow(_ conv: ConversationDTO) -> some View {
        let hue = conv.businessAvatarHue ?? 0.5
        let unread = (conv.unreadCount ?? 0) > 0

        return Button { selectedConvId = conv.id; showChat = true } label: {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hue: hue, saturation: 0.45, brightness: 0.90), Color(hue: hue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 48, height: 48)
                    .overlay(Text(conv.businessInitials ?? "?").font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white))

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: PlagitSpacing.sm) {
                                Text(conv.businessName ?? "Unknown").font(unread ? PlagitFont.bodyMedium() : PlagitFont.body()).foregroundColor(.plagitCharcoal)
                                let bflag = CountryFlag.emoji(for: conv.businessCountryCode)
                                if !bflag.isEmpty { Text(bflag).font(.system(size: 12)) }
                                if conv.businessVerified == true { Image(systemName: "checkmark.seal.fill").font(.system(size: 10)).foregroundColor(.plagitVerified) }
                            }
                            if let jt = conv.jobTitle { Text("Re: \(jt)").font(PlagitFont.micro()).foregroundColor(.plagitTeal) }
                        }
                        Spacer()
                        if unread {
                            Circle().fill(Color.plagitTeal).frame(width: 8, height: 8)
                        }
                    }

                    if let msg = conv.lastMessage {
                        Text(msg).font(PlagitFont.caption()).foregroundColor(unread ? .plagitCharcoal : .plagitSecondary).lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48)
                Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text(L10n.t("no_messages_yet")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(L10n.t("messages_empty_candidate")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
