//
//  CandidateSignUpView.swift
//  Plagit
//
//  Premium Candidate Create Account Screen
//

import SwiftUI

struct CandidateSignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var currentRole = ""
    @State private var jobType = ""
    @State private var location = ""
    @State private var experience = ""
    @State private var languages = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showProfileSetup = false
    @FocusState private var focusedField: Field?

    // 3-level hospitality picker state
    @State private var hCategoryId = ""
    @State private var hSubcategoryId = ""
    @State private var hRoleId = ""
    @State private var showCategoryPicker = false

    enum Field: Hashable {
        case name, email, password, role, location, languages
    }

    var body: some View {
        ZStack {
            Color.plagitBackground
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar

                    introText
                        .padding(.top, PlagitSpacing.xl)

                    formCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    if let msg = errorMessage {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 13, weight: .medium)).foregroundColor(.plagitUrgent)
                            Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent).lineLimit(2)
                        }
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.top, PlagitSpacing.md)
                    }

                    createButton
                        .padding(.top, PlagitSpacing.xxl)

                    helperText
                        .padding(.top, PlagitSpacing.xxl)

                    privacyNote
                        .padding(.top, PlagitSpacing.lg)

                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCategoryPicker) {
            HospitalityCategoryPicker(
                selectedCategoryId: $hCategoryId,
                selectedSubcategoryId: $hSubcategoryId,
                selectedRoleId: $hRoleId
            )
        }
        .navigationDestination(isPresented: $showProfileSetup) {
            CandidateProfileSetupView()
                .navigationBarHidden(true)
        }
    }

    private var canSubmit: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        && email.contains("@") && email.contains(".")
        && password.count >= 8
    }

    private func performRegistration() {
        guard canSubmit else { return }
        isLoading = true; errorMessage = nil
        Task {
            do {
                try await CandidateAuthService.shared.register(
                    name: fullName.trimmingCharacters(in: .whitespaces),
                    email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                    password: password,
                    role: !hRoleId.isEmpty ? hRoleId : (currentRole.isEmpty ? nil : currentRole),
                    location: location.isEmpty ? nil : location,
                    experience: experience.isEmpty ? nil : experience,
                    languages: languages.isEmpty ? nil : languages,
                    jobType: jobType.isEmpty ? nil : jobType
                )
                // App language stays as device language — no location override
                // Send welcome email once per account
                if !UserDefaults.standard.bool(forKey: "plagit_welcome_email_sent") {
                    UserDefaults.standard.set(true, forKey: "plagit_welcome_email_sent")
                    Task { try? await CandidateAPIService.shared.sendWelcomeEmail() }
                }
                // Flag for first-time welcome message
                UserDefaults.standard.set(true, forKey: "plagit_show_candidate_welcome")
                // After registration, go to profile setup to complete optional fields
                showProfileSetup = true
            } catch let error as APIError {
                errorMessage = error.errorDescription ?? L10n.t("err_registration_failed")
            } catch {
                errorMessage = L10n.apiError(error.localizedDescription)
            }
            isLoading = false
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

            Text(L10n.createAccount)
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.xxl)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Intro

    private var introText: some View {
        Text(L10n.regCandidateSub)
            .font(PlagitFont.body())
            .foregroundColor(.plagitSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.yourDetails)
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            VStack(spacing: 0) {
                inputRow(icon: "person", placeholder: L10n.fullName, text: $fullName, field: .name)
                divider
                inputRow(icon: "envelope", placeholder: L10n.emailAddress, text: $email, field: .email, keyboard: .emailAddress)
                divider
                secureRow(icon: "lock", placeholder: L10n.passwordPlaceholder, text: $password, field: .password)
                divider
                inputRow(icon: "mappin", placeholder: L10n.locationPlaceholder, text: $location, field: .location)
                divider
                inputRow(icon: "clock", placeholder: L10n.yearsExperience, text: $experience, field: .languages)
                divider
                inputRow(icon: "globe", placeholder: L10n.languagesPlaceholder, text: $languages, field: .languages)
            }
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(Color.plagitSurface)
            )

            // Category & Role picker
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Category & Role")
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitSecondary)

                HospitalityCategoryButton(
                    categoryId: hCategoryId,
                    subcategoryId: hSubcategoryId,
                    roleId: hRoleId
                ) { showCategoryPicker = true }
            }

            // Job type chips
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Job Type")
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitSecondary)

                ChipSelectorView(
                    options: PlagitJobType.allCases.map { ChipOption(value: $0.rawValue, label: $0.label, icon: $0.icon) },
                    selected: $jobType
                )
            }
        }
        .padding(PlagitSpacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func inputRow(icon: String, placeholder: String, text: Binding<String>, field: Field, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTeal)
                .frame(width: 20)

            TextField(placeholder, text: text)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
                .keyboardType(keyboard)
                .autocapitalization(keyboard == .emailAddress ? .none : .words)
                .focused($focusedField, equals: field)
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.md + 2)
    }

    private func secureRow(icon: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTeal)
                .frame(width: 20)

            SecureField(placeholder, text: text)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
                .focused($focusedField, equals: field)
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.md + 2)
    }

    // pickerRow removed — using inputRow for all fields

    private var divider: some View {
        Rectangle().fill(Color.plagitDivider).frame(height: 1)
    }

    // MARK: - Create Button

    private var createButton: some View {
        Button { performRegistration() } label: {
            Group {
                if isLoading { ProgressView().tint(.white) }
                else { Text(L10n.createAccount) }
            }
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
        .disabled(!canSubmit || isLoading)
        .opacity(canSubmit ? 1.0 : 0.6)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Helper Text

    private var helperText: some View {
        HStack(spacing: PlagitSpacing.xs) {
            Text(L10n.alreadyHaveAccount)
                .font(PlagitFont.caption())
                .foregroundColor(.plagitSecondary)

            Button { dismiss() } label: {
                Text(L10n.signIn)
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitTeal)
            }
        }
    }

    // MARK: - Privacy Note

    private var privacyNote: some View {
        Text(L10n.regTerms)
            .font(PlagitFont.micro())
            .foregroundColor(.plagitTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, PlagitSpacing.xxl)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CandidateSignUpView()
    }
    .preferredColorScheme(.light)
}
