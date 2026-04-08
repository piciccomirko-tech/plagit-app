//
//  BusinessAuthView.swift
//  Plagit
//
//  Premium Business Login / Sign Up Screen
//

import SwiftUI

struct BusinessAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var rememberMe = false
    @State private var showSignUp = false
    @State private var showCandidateFlow = false
    @State private var showForgotPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email, password
    }

    var body: some View {
        ZStack {
            Color.plagitBackground
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar

                    brandIntro
                        .padding(.top, PlagitSpacing.xxxl)

                    authForm
                        .padding(.top, PlagitSpacing.sectionGap)

                    errorAndRemember
                        .padding(.top, PlagitSpacing.md)

                    primaryActions
                        .padding(.top, PlagitSpacing.lg)

                    helperText
                        .padding(.top, PlagitSpacing.xxxl)

                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if UserDefaults.standard.bool(forKey: "businessRememberMe") {
                rememberMe = true
                email = UserDefaults.standard.string(forKey: "businessRememberedEmail") ?? ""
                if !email.isEmpty { focusedField = .password }
            }
            if BusinessAuthService.shared.sessionExpired {
                errorMessage = L10n.sessionExpired
                BusinessAuthService.shared.sessionExpired = false
            }
        }
        .navigationDestination(isPresented: $showSignUp) {
            BusinessSignUpView()
                .navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showCandidateFlow) {
            CandidateRootView()
                .navigationBarHidden(true)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordSheet()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(alignment: .center) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.plagitCharcoal)
                    .frame(width: 36, height: 36)
            }

            Spacer()

            Text(L10n.joinAsBusiness)
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.xxl)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Brand + Intro

    private var brandIntro: some View {
        VStack(spacing: PlagitSpacing.xl) {
            Image("PlagitLogo")
                .resizable().scaledToFit()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.md))

            VStack(spacing: PlagitSpacing.sm) {
                Text(L10n.businessHero)
                    .font(PlagitFont.displayMedium())
                    .foregroundColor(.plagitCharcoal)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text(L10n.businessAuthSub)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Auth Form

    private var authForm: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            VStack(spacing: 0) {
                HStack(spacing: PlagitSpacing.md) {
                    Image(systemName: "envelope")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.plagitTeal)
                        .frame(width: 20)

                    TextField(L10n.businessEmailPlaceholder, text: $email)
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitCharcoal)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                }
                .padding(.horizontal, PlagitSpacing.lg)
                .padding(.vertical, PlagitSpacing.md + 2)

                Rectangle().fill(Color.plagitDivider).frame(height: 1)

                HStack(spacing: PlagitSpacing.md) {
                    Image(systemName: "lock")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.plagitTeal)
                        .frame(width: 20)

                    if showPassword {
                        TextField(L10n.passwordPlaceholder, text: $password)
                            .font(PlagitFont.body())
                            .foregroundColor(.plagitCharcoal)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .focused($focusedField, equals: .password)
                    } else {
                        SecureField(L10n.passwordPlaceholder, text: $password)
                            .font(PlagitFont.body())
                            .foregroundColor(.plagitCharcoal)
                            .textContentType(.password)
                            .focused($focusedField, equals: .password)
                    }

                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.plagitTertiary)
                    }
                }
                .padding(.horizontal, PlagitSpacing.lg)
                .padding(.vertical, PlagitSpacing.md + 2)
            }
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(Color.plagitSurface)
            )
        }
        .padding(PlagitSpacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Primary Actions

    // MARK: - Error + Remember Me

    private var errorAndRemember: some View {
        VStack(spacing: PlagitSpacing.md) {
            if let msg = errorMessage {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 13, weight: .medium)).foregroundColor(.plagitUrgent)
                    Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent).lineLimit(2)
                }
                .padding(PlagitSpacing.md).frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitUrgent.opacity(0.08)))
                .padding(.horizontal, PlagitSpacing.xl)
            }
            HStack {
                Button { withAnimation(.easeInOut(duration: 0.15)) { rememberMe.toggle() } } label: {
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square").font(.system(size: 20, weight: .medium)).foregroundColor(rememberMe ? .plagitTeal : .plagitTertiary).contentTransition(.symbolEffect(.replace))
                        Text(L10n.rememberMe).font(PlagitFont.caption()).foregroundColor(rememberMe ? .plagitCharcoal : .plagitSecondary)
                    }.frame(minHeight: 44).contentShape(Rectangle())
                }.buttonStyle(.plain)
                Spacer()
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Primary Actions

    private var primaryActions: some View {
        VStack(spacing: PlagitSpacing.md) {
            Button { performLogin() } label: {
                Group { if isLoading { ProgressView().tint(.white) } else { Text(L10n.signIn) } }
                    .font(PlagitFont.subheadline())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlagitSpacing.lg)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.plagitTeal, Color.plagitTealDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.plagitTeal.opacity(0.18), radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
            }
            .disabled(email.isEmpty || password.isEmpty || isLoading)
            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)

            Button { showSignUp = true } label: {
                Text(L10n.createBusinessAccount)
                    .font(PlagitFont.subheadline())
                    .foregroundColor(.plagitTeal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlagitSpacing.lg)
                    .background(
                        Capsule().fill(Color.plagitTealLight)
                    )
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Helper Text

    private var helperText: some View {
        VStack(spacing: PlagitSpacing.lg) {
            Button { showForgotPassword = true } label: {
                Text(L10n.forgotPassword)
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitTeal)
            }

            HStack(spacing: PlagitSpacing.xs) {
                Text(L10n.lookingForWork)
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)

                Button { showCandidateFlow = true } label: {
                    Text(L10n.switchToCandidate)
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitTeal)
                }
            }
        }
    }

    // MARK: - Login

    private func performLogin() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true; errorMessage = nil
        Task {
            do {
                try await BusinessAuthService.shared.login(
                    email: email, password: password, rememberMe: rememberMe
                )
            } catch let error as APIError {
                errorMessage = error.errorDescription ?? L10n.apiError("invalid credentials")
            } catch {
                errorMessage = L10n.apiError(error.localizedDescription)
            }
            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BusinessAuthView()
    }
    .preferredColorScheme(.light)
}
