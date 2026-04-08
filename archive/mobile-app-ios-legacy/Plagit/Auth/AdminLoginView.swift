//
//  AdminLoginView.swift
//  Plagit
//
//  Admin login screen — authenticates against POST /v1/auth/login.
//

import SwiftUI

struct AdminLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPassword = false
    @State private var rememberMe = false
    @State private var showForgotPassword = false
    @State private var showForgotEmail = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 80)

                    // Logo / branding
                    VStack(spacing: PlagitSpacing.md) {
                        Image("PlagitLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.lg))

                        Text("Plagit Admin")
                            .font(PlagitFont.displayMedium())
                            .foregroundColor(.plagitCharcoal)

                        Text("Sign in to your admin account")
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)
                    }

                    Spacer().frame(height: PlagitSpacing.xxxl + PlagitSpacing.lg)

                    // Login form
                    VStack(spacing: 0) {
                        // Email field
                        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                            Text("Email")
                                .font(PlagitFont.micro())
                                .foregroundColor(.plagitTertiary)
                            TextField("Enter email", text: $email)
                                .font(PlagitFont.body())
                                .foregroundColor(.plagitCharcoal)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                        }
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.vertical, PlagitSpacing.lg)

                        Rectangle().fill(Color.plagitDivider).frame(height: 1)
                            .padding(.leading, PlagitSpacing.xl)

                        // Password field
                        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                            Text("Password")
                                .font(PlagitFont.micro())
                                .foregroundColor(.plagitTertiary)
                            HStack(spacing: PlagitSpacing.sm) {
                                Group {
                                    if showPassword {
                                        TextField("Enter password", text: $password)
                                    } else {
                                        SecureField("Enter password", text: $password)
                                    }
                                }
                                .font(PlagitFont.body())
                                .foregroundColor(.plagitCharcoal)
                                .textContentType(.password)
                                .focused($focusedField, equals: .password)

                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.plagitTertiary)
                                        .frame(width: 28, height: 28)
                                        .contentShape(Rectangle())
                                }
                            }
                        }
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.vertical, PlagitSpacing.lg)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: PlagitRadius.xl)
                            .fill(Color.plagitCardBackground)
                            .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
                    )
                    .padding(.horizontal, PlagitSpacing.xl)

                    // Remember me + recovery links
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                rememberMe.toggle()
                            }
                        } label: {
                            HStack(spacing: PlagitSpacing.sm) {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(rememberMe ? .plagitTeal : .plagitTertiary)
                                    .contentTransition(.symbolEffect(.replace))
                                Text("Remember me")
                                    .font(PlagitFont.caption())
                                    .foregroundColor(rememberMe ? .plagitCharcoal : .plagitSecondary)
                            }
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        HStack(spacing: PlagitSpacing.md) {
                            Button { showForgotPassword = true } label: {
                                Text("Forgot password?")
                                    .font(PlagitFont.caption())
                                    .foregroundColor(.plagitTeal)
                            }
                            Button { showForgotEmail = true } label: {
                                Text("Forgot email?")
                                    .font(PlagitFont.caption())
                                    .foregroundColor(.plagitTeal)
                            }
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.xl + PlagitSpacing.xs)
                    .padding(.top, PlagitSpacing.md)

                    // Error message
                    if let errorMessage {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plagitUrgent)
                            Text(errorMessage)
                                .font(PlagitFont.caption())
                                .foregroundColor(.plagitUrgent)
                        }
                        .padding(.horizontal, PlagitSpacing.xl + PlagitSpacing.sm)
                        .padding(.top, PlagitSpacing.md)
                    }

                    // Login button
                    Button {
                        performLogin()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            } else {
                                Text("Sign In")
                                    .font(PlagitFont.bodyMedium())
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PlagitSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                                .fill(canLogin ? Color.plagitTeal : Color.plagitTeal.opacity(0.4))
                        )
                    }
                    .disabled(!canLogin || isLoading)
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.xxl)

                    Spacer().frame(height: PlagitSpacing.xxxl)

                    // Footer
                    Text("Plagit Admin v1.0.0")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTertiary)
                }
            }
        }
        .onSubmit {
            if focusedField == .email { focusedField = .password }
            else if focusedField == .password && canLogin { performLogin() }
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "rememberMe") {
                rememberMe = true
                email = UserDefaults.standard.string(forKey: "rememberedEmail") ?? ""
                // Pre-filled email → jump straight to password
                if !email.isEmpty {
                    focusedField = .password
                }
            }
            // Surface expired-session feedback from the auth service
            if AdminAuthService.shared.sessionExpired {
                errorMessage = "Your session has expired. Please sign in again."
                AdminAuthService.shared.sessionExpired = false
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            AdminForgotPasswordSheet()
        }
        .sheet(isPresented: $showForgotEmail) {
            AdminForgotEmailSheet()
        }
    }

    private var canLogin: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.isEmpty
    }

    private func performLogin() {
        guard canLogin, !isLoading else { return }
        focusedField = nil
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await AdminAuthService.shared.login(
                    email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                    password: password,
                    rememberMe: rememberMe
                )
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - Forgot Password Sheet

struct AdminForgotPasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var resetEmail = ""
    @State private var resetCode = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var step: ResetStep = .email
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
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
                Text("Reset Your Password").font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text("Enter your admin email. We'll send you a 6-digit code to reset your password.")
                    .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.md)
            }

            formField("Admin email") {
                TextField("Enter your admin email", text: $resetEmail)
                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    .keyboardType(.emailAddress).textContentType(.emailAddress).autocapitalization(.none).autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
            }

            if let errorMessage { errorBanner(errorMessage) }

            actionButton("Send Reset Code", enabled: resetEmail.contains("@"), loading: isLoading) {
                requestCode()
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Step 2: Code + New Password

    private var codeStep: some View {
        VStack(spacing: PlagitSpacing.lg) {
            VStack(spacing: PlagitSpacing.sm) {
                Text("Enter Reset Code").font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text("A 6-digit code was sent to **\(resetEmail)**. Enter it below with your new password.")
                    .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.md)
            }

            formField("6-digit code") {
                TextField("000000", text: $resetCode)
                    .font(.system(size: 24, weight: .bold, design: .monospaced)).foregroundColor(.plagitCharcoal)
                    .keyboardType(.numberPad).multilineTextAlignment(.center)
                    .focused($focusedField, equals: .code)
                    .onChange(of: resetCode) { _, new in
                        resetCode = String(new.filter(\.isNumber).prefix(6))
                    }
            }

            formField("New password") {
                HStack {
                    Group {
                        if showNewPassword { TextField("Min 12 chars, upper, lower, number", text: $newPassword) }
                        else { SecureField("Min 12 chars, upper, lower, number", text: $newPassword) }
                    }
                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal).textContentType(.newPassword)
                    .focused($focusedField, equals: .password)

                    Button { showNewPassword.toggle() } label: {
                        Image(systemName: showNewPassword ? "eye.slash" : "eye")
                            .font(.system(size: 15)).foregroundColor(.plagitTertiary).frame(width: 28, height: 28)
                    }
                }
            }

            formField("Confirm password") {
                SecureField("Re-enter new password", text: $confirmPassword)
                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal).textContentType(.newPassword)
                    .focused($focusedField, equals: .confirm)
            }

            if let errorMessage { errorBanner(errorMessage) }

            actionButton("Reset Password", enabled: canReset, loading: isLoading) {
                performReset()
            }

            Button { withAnimation { step = .email; errorMessage = nil } } label: {
                Text("Didn't receive the code? Send again").font(PlagitFont.caption()).foregroundColor(.plagitTeal)
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Step 3: Done

    private var doneStep: some View {
        VStack(spacing: PlagitSpacing.lg) {
            VStack(spacing: PlagitSpacing.sm) {
                Text("Password Reset").font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text("Your password has been reset successfully. You can now sign in with your new password.")
                    .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.md)
            }

            actionButton("Back to Sign In", enabled: true, loading: false) { dismiss() }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Helpers

    private var canReset: Bool {
        resetCode.count == 6 && newPassword.count >= 12 && newPassword == confirmPassword
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

// MARK: - Forgot Email Sheet

struct AdminForgotEmailSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        Spacer().frame(height: PlagitSpacing.xl)

                        ZStack {
                            Circle().fill(Color.plagitIndigo.opacity(0.10)).frame(width: 64, height: 64)
                            Image(systemName: "person.crop.circle.badge.questionmark")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(.plagitIndigo)
                        }

                        VStack(spacing: PlagitSpacing.sm) {
                            Text("Recover Your Account")
                                .font(PlagitFont.displayMedium())
                                .foregroundColor(.plagitCharcoal)
                            Text("If you don't remember the email address associated with your admin account, contact support through one of the options below. We'll verify your identity and help you regain access.")
                                .font(PlagitFont.body())
                                .foregroundColor(.plagitSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, PlagitSpacing.md)
                        }

                        VStack(spacing: PlagitSpacing.md) {
                            recoveryButton(
                                icon: "envelope.fill",
                                title: "Email Support",
                                subtitle: "support@plagit.com",
                                style: .primary
                            ) {
                                if let url = URL(string: "mailto:support@plagit.com?subject=Admin%20Account%20Recovery%20%E2%80%94%20Forgot%20Email") {
                                    UIApplication.shared.open(url)
                                }
                            }

                            recoveryButton(
                                icon: "message.fill",
                                title: "WhatsApp Support",
                                subtitle: "+971 50 999 0000",
                                style: .secondary
                            ) {
                                if let url = URL(string: "https://wa.me/971509990000?text=Hi%2C%20I%20need%20help%20recovering%20my%20Plagit%20admin%20account.%20I%20don't%20remember%20my%20login%20email.") {
                                    UIApplication.shared.open(url)
                                }
                            }

                            recoveryButton(
                                icon: "phone.fill",
                                title: "Call Support",
                                subtitle: "+971 800 PLAGIT",
                                style: .secondary
                            ) {
                                if let url = URL(string: "tel:+971800752448") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                        .padding(.horizontal, PlagitSpacing.xl)

                        VStack(spacing: PlagitSpacing.xs) {
                            Text("You'll need to verify:").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                            HStack(spacing: PlagitSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 11)).foregroundColor(.plagitTeal)
                                Text("Your full name").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            }
                            HStack(spacing: PlagitSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 11)).foregroundColor(.plagitTeal)
                                Text("Your admin role").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            }
                            HStack(spacing: PlagitSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 11)).foregroundColor(.plagitTeal)
                                Text("Phone number on file").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            }
                        }
                        .padding(PlagitSpacing.lg)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitSurface))
                        .padding(.horizontal, PlagitSpacing.xl)

                        Button { dismiss() } label: {
                            Text("Back to Sign In")
                                .font(PlagitFont.captionMedium())
                                .foregroundColor(.plagitSecondary)
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

    private enum ButtonStyle { case primary, secondary }

    private func recoveryButton(icon: String, title: String, subtitle: String, style: ButtonStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(style == .primary ? .white : .plagitTeal)
                    .frame(width: 32, height: 32)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(style == .primary ? Color.plagitTeal : Color.plagitTeal.opacity(0.12)))
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(PlagitFont.bodyMedium()).foregroundColor(style == .primary ? .white : .plagitCharcoal)
                    Text(subtitle).font(PlagitFont.micro()).foregroundColor(style == .primary ? .white.opacity(0.7) : .plagitTertiary)
                }
                Spacer()
                Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .medium)).foregroundColor(style == .primary ? .white.opacity(0.6) : .plagitTertiary)
            }
            .padding(PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(style == .primary ? Color.plagitTeal : Color.plagitCardBackground))
            .shadow(color: style == .primary ? .clear : PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        }
    }
}

#Preview {
    AdminLoginView()
        .preferredColorScheme(.light)
}

#Preview("Forgot Password") {
    AdminForgotPasswordSheet()
        .preferredColorScheme(.light)
}

#Preview("Forgot Email") {
    AdminForgotEmailSheet()
        .preferredColorScheme(.light)
}
