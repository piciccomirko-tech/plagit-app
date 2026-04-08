//
//  BusinessRealChatView.swift
//  Plagit
//
//  Real business chat thread backed by GET/POST /business/conversations/:id/messages.
//

import SwiftUI

struct BusinessRealChatView: View {
    let conversationId: String
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [MessageDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var newMessage = ""
    @State private var isSending = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if isLoading { Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer(); Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).padding(PlagitSpacing.xxl); Spacer()
                } else if messages.isEmpty {
                    Spacer(); VStack(spacing: PlagitSpacing.md) { Image(systemName: "bubble.left").font(.system(size: 32)).foregroundColor(.plagitTertiary); Text("No messages yet").font(PlagitFont.caption()).foregroundColor(.plagitSecondary) }; Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: PlagitSpacing.md) {
                                ForEach(messages) { msg in messageBubble(msg).id(msg.id) }
                            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
                        }
                        .onChange(of: messages.count) { _, _ in if let last = messages.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } } }
                    }
                }
                inputBar
            }
        }
        .navigationBarHidden(true)
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do {
            messages = try await BusinessAPIService.shared.fetchMessages(conversationId: conversationId)
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text("Chat").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer(); Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg).background(Color.plagitBackground)
    }

    private func messageBubble(_ msg: MessageDTO) -> some View {
        let isMe = msg.senderType == "business"
        return HStack {
            if isMe { Spacer() }
            VStack(alignment: isMe ? .trailing : .leading, spacing: PlagitSpacing.xs) {
                if !isMe, let name = msg.senderName { Text(name).font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }
                Text(msg.body).font(PlagitFont.body()).foregroundColor(isMe ? .white : .plagitCharcoal)
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(isMe ? Color.plagitTeal : Color.plagitCardBackground))
                    .shadow(color: isMe ? .clear : PlagitShadow.subtleShadowColor, radius: isMe ? 0 : PlagitShadow.subtleShadowRadius, y: isMe ? 0 : PlagitShadow.subtleShadowY)
            }
            if !isMe { Spacer() }
        }
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.plagitDivider).frame(height: 0.5)
            HStack(spacing: PlagitSpacing.md) {
                TextField("Type a message...", text: $newMessage).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitSurface))
                Button { Task { await send() } } label: {
                    if isSending { ProgressView().tint(.white).frame(width: 32, height: 32) }
                    else { Image(systemName: "arrow.up.circle.fill").font(.system(size: 32, weight: .medium)).foregroundColor(newMessage.trimmingCharacters(in: .whitespaces).isEmpty ? .plagitTertiary : .plagitTeal) }
                }.disabled(newMessage.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md).background(Color.plagitBackground)
        }
    }

    private func send() async {
        let text = newMessage.trimmingCharacters(in: .whitespaces); guard !text.isEmpty else { return }
        isSending = true
        do {
            let sent = try await BusinessAPIService.shared.sendMessage(conversationId: conversationId, body: text)
            messages.append(sent)
            newMessage = ""
        } catch {
            loadError = L10n.t("send_failed")
        }
        isSending = false
    }
}
