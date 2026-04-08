//
//  ServiceProviderSignUpView.swift
//  Plagit
//
//  Registration form for hospitality service providers.
//  Simple onboarding: required fields + optional extras.
//

import SwiftUI

struct ServiceProviderSignUpView: View {
    @Environment(\.dismiss) private var dismiss

    // Required fields
    @State private var businessName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var location = ""
    @State private var description = ""
    @State private var selectedCategoryId = ""
    @State private var selectedSubcategoryId = ""
    @State private var showCategoryPicker = false

    // Optional fields
    @State private var website = ""
    @State private var socialLink = ""

    // State
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name, email, phone, location, description, website, social
    }

    private var canSubmit: Bool {
        !businessName.trimmingCharacters(in: .whitespaces).isEmpty
        && email.contains("@") && email.contains(".")
        && !phone.trimmingCharacters(in: .whitespaces).isEmpty
        && !selectedCategoryId.isEmpty
    }

    var body: some View {
        ZStack {
            Color.plagitBackground
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar
                    introText.padding(.top, PlagitSpacing.xl)
                    formCard.padding(.top, PlagitSpacing.sectionGap)

                    if let msg = errorMessage {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.plagitUrgent)
                            Text(msg)
                                .font(PlagitFont.caption())
                                .foregroundColor(.plagitUrgent)
                                .lineLimit(2)
                        }
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.top, PlagitSpacing.md)
                    }

                    submitButton.padding(.top, PlagitSpacing.xxl)
                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCategoryPicker) {
            ServiceCategoryPicker(
                selectedCategoryId: $selectedCategoryId,
                selectedSubcategoryId: $selectedSubcategoryId
            )
        }
        .alert("Registration Submitted", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your business \"\(businessName)\" is now listed with a free profile. Upgrade to a premium plan for higher visibility and more features.")
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
            Text("Register Business")
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
        Text("List your hospitality service and get discovered by hotels, restaurants, and event planners.")
            .font(PlagitFont.body())
            .foregroundColor(.plagitSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Business Details")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            // Required fields
            VStack(spacing: 0) {
                inputRow(icon: "building.2", placeholder: "Business Name *", text: $businessName, field: .name)
                divider
                inputRow(icon: "envelope", placeholder: "Email *", text: $email, field: .email, keyboard: .emailAddress)
                divider
                inputRow(icon: "phone", placeholder: "Phone *", text: $phone, field: .phone, keyboard: .phonePad)
                divider
                inputRow(icon: "mappin", placeholder: "Address / Location", text: $location, field: .location)
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))

            // Service Category picker
            ServiceCategoryButton(
                categoryId: selectedCategoryId,
                subcategoryId: selectedSubcategoryId
            ) { showCategoryPicker = true }

            // Description
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text("Service Description")
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitSecondary)
                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text("Describe your services, experience, and what makes you stand out...")
                            .font(PlagitFont.body())
                            .foregroundColor(.plagitTertiary)
                            .padding(.horizontal, 5).padding(.vertical, 8)
                    }
                    TextEditor(text: $description)
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitCharcoal)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
                .padding(PlagitSpacing.md)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
            }

            // Optional fields
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Optional")
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitTertiary)

                VStack(spacing: 0) {
                    inputRow(icon: "globe", placeholder: "Website", text: $website, field: .website, keyboard: .URL)
                    divider
                    inputRow(icon: "camera", placeholder: "Instagram / Social Link", text: $socialLink, field: .social)
                }
                .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
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
                .foregroundColor(.plagitAmber)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
                .keyboardType(keyboard)
                .autocapitalization(keyboard == .emailAddress || keyboard == .URL ? .none : .words)
                .focused($focusedField, equals: field)
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.md + 2)
    }

    private var divider: some View {
        Rectangle().fill(Color.plagitDivider).frame(height: 1)
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button { submitRegistration() } label: {
            Group {
                if isLoading { ProgressView().tint(.white) }
                else { Text("Register Business") }
            }
            .font(PlagitFont.subheadline())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, PlagitSpacing.lg)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [Color.plagitAmber, Color.plagitAmber.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            )
            .shadow(color: Color.plagitAmber.opacity(0.18), radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        }
        .disabled(!canSubmit || isLoading)
        .opacity(canSubmit ? 1.0 : 0.6)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func submitRegistration() {
        guard canSubmit else { return }
        isLoading = true; errorMessage = nil
        // TODO: Replace with real API call — POST /services/register
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // simulate network
            isLoading = false
            showSuccess = true
        }
    }
}
