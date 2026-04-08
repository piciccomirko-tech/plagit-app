//
//  ForgotPasswordSheet.swift
//  Plagit
//
//  Shared forgot-password flow for Candidate and Business users.
//  Uses /auth/forgot-password and /auth/reset-password endpoints.
//

import SwiftUI

struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var resetEmail = ""
    @State private var resetCode = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var step: ResetStep = .email
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: ResetField?

    private enum ResetStep { case email, code, done }
    private enum ResetField { case email, code, password, confirm }

    private let client = APIClient.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        Spacer().frame(height: PlagitSpacing.xl)

                        ZStack {
                            Circle().fill((step == .done ? Color.plagitOnline : Color.plagitAmber).opacity(0.10)).frame(width: 64, height: 64)
                            Image(systemName: step == .done ? "checkmark.circle" : "lock.open.rotation")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(step == .done ? .plagitOnline : .plagitAmber)
                        }

                        switch step {
                        case .email: emailStep
                        case .code: codeStep
                        case .done: doneStep
                        }

                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
                    }
                }
            }
        }
    }

    // MARK: - Step 1: Email

    private var emailStep: some View {
        VStack(spacing: PlagitSpacing.lg) {
            VStack(spacing: PlagitSpacing.sm) {
                Text(L10n.t("reset_password_title")).font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text(L10n.t("reset_password_subtitle"))
                    .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.md)
            }

            formField(L10n.t("email")) {
                TextField(L10n.emailPlaceholder, text: $resetEmail)
                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    .keyboardType(.emailAddress).textContentType(.emailAddress).autocapitalization(.none).autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
            }

            if let errorMessage { errorBanner(errorMessage) }

            actionButton(L10n.t("send_reset_code"), enabled: resetEmail.contains("@"), loading: isLoading) {
                requestCode()
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Step 2: Code + New Password

    private var codeStep: some View {
        VStack(spacing: PlagitSpacing.lg) {
            VStack(spacing: PlagitSpacing.sm) {
                Text(L10n.t("enter_reset_code")).font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text(L10n.t("reset_code_sent_to") + " **\(resetEmail)**")
                    .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.md)
            }

            formField(L10n.t("six_digit_code")) {
                TextField("000000", text: $resetCode)
                    .font(.system(size: 24, weight: .bold, design: .monospaced)).foregroundColor(.plagitCharcoal)
                    .keyboardType(.numberPad).multilineTextAlignment(.center)
                    .focused($focusedField, equals: .code)
                    .onChange(of: resetCode) { _, new in
                        resetCode = String(new.filter(\.isNumber).prefix(6))
                    }
            }

            formField(L10n.t("new_password")) {
                HStack {
                    Group {
                        if showNewPassword { TextField(L10n.t("password_requirements"), text: $newPassword) }
                        else { SecureField(L10n.t("password_requirements"), text: $newPassword) }
                    }
                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal).textContentType(.newPassword)
                    .focused($focusedField, equals: .password)

                    Button { showNewPassword.toggle() } label: {
                        Image(systemName: showNewPassword ? "eye.slash" : "eye")
                            .font(.system(size: 15)).foregroundColor(.plagitTertiary).frame(width: 28, height: 28)
                    }
                }
            }

            formField(L10n.t("confirm_password")) {
                SecureField(L10n.t("confirm_password_placeholder"), text: $confirmPassword)
                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal).textContentType(.newPassword)
                    .focused($focusedField, equals: .confirm)
            }

            if let errorMessage { errorBanner(errorMessage) }

            actionButton(L10n.t("reset_password_button"), enabled: canReset, loading: isLoading) {
                performReset()
            }

            Button { withAnimation { step = .email; errorMessage = nil } } label: {
                Text(L10n.t("resend_code")).font(PlagitFont.caption()).foregroundColor(.plagitTeal)
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Step 3: Done

    private var doneStep: some View {
        VStack(spacing: PlagitSpacing.lg) {
            VStack(spacing: PlagitSpacing.sm) {
                Text(L10n.t("password_reset_done_title")).font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text(L10n.t("password_reset_done_subtitle"))
                    .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.md)
            }

            actionButton(L10n.t("back_to_sign_in"), enabled: true, loading: false) { dismiss() }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Helpers

    private var canReset: Bool {
        resetCode.count == 6 && newPassword.count >= 8 && newPassword == confirmPassword
    }

    private func formField(_ label: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            content()
                .padding(PlagitSpacing.md)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitUrgent)
            Text(message).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
        }
    }

    private func actionButton(_ title: String, enabled: Bool, loading: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                if loading { ProgressView().tint(.white).scaleEffect(0.8) }
                else { Text(title).font(PlagitFont.bodyMedium()) }
            }
            .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(enabled ? Color.plagitTeal : Color.plagitTeal.opacity(0.4)))
        }
        .disabled(!enabled || loading)
    }

    // MARK: - API Calls

    private func requestCode() {
        guard !isLoading else { return }
        focusedField = nil; isLoading = true; errorMessage = nil
        Task {
            do {
                struct Req: Encodable { let email: String }
                try await client.requestVoid(.POST, path: "/auth/forgot-password", body: Req(email: resetEmail.lowercased().trimmingCharacters(in: .whitespaces)))
                withAnimation { step = .code }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func performReset() {
        guard canReset, !isLoading else { return }
        focusedField = nil; isLoading = true; errorMessage = nil
        Task {
            do {
                struct Req: Encodable { let email: String; let code: String; let newPassword: String }
                try await client.requestVoid(.POST, path: "/auth/reset-password", body: Req(email: resetEmail.lowercased().trimmingCharacters(in: .whitespaces), code: resetCode, newPassword: newPassword))
                withAnimation { step = .done }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
