//
//  AdminChangePasswordView.swift
//  Plagit
//
//  Admin — Change Password
//

import SwiftUI

struct AdminChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    @FocusState private var focusedField: Field?

    private enum Field { case new, confirm }

    private var passwordValid: Bool {
        newPassword.count >= 12
        && newPassword.range(of: "[A-Z]", options: .regularExpression) != nil
        && newPassword.range(of: "[a-z]", options: .regularExpression) != nil
        && newPassword.range(of: "[0-9]", options: .regularExpression) != nil
    }

    private var confirmMatch: Bool { newPassword == confirmPassword && !confirmPassword.isEmpty }
    private var canSubmit: Bool { passwordValid && confirmMatch && !isLoading }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        formCard
                        requirementsCard
                    }
                    .padding(.top, PlagitSpacing.lg)
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Password Changed", isPresented: $showSuccess) {
            Button("OK") { AdminAuthService.shared.logout() }
        } message: {
            Text("Your password has been updated. Please log in again with your new password.")
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.plagitCharcoal)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Text("Change Password")
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.xxl)
        .padding(.bottom, PlagitSpacing.lg)
        .background(Color.plagitBackground)
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.plagitTeal)
                Text("Update Password")
                    .font(PlagitFont.headline())
                    .foregroundColor(.plagitCharcoal)
            }

            passwordField("New Password", text: $newPassword, visible: $showNewPassword, field: .new)
            passwordField("Confirm New Password", text: $confirmPassword, visible: $showConfirmPassword, field: .confirm)

            if let errorMessage {
                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11, weight: .medium))
                    Text(errorMessage)
                        .font(PlagitFont.caption())
                }
                .foregroundColor(.plagitUrgent)
            }

            Button(action: submit) {
                HStack(spacing: PlagitSpacing.sm) {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    }
                    Text(isLoading ? "Changing..." : "Change Password")
                        .font(PlagitFont.bodyMedium())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, PlagitSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(canSubmit ? Color.plagitTeal : Color.plagitTeal.opacity(0.35))
                )
            }
            .disabled(!canSubmit)
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Requirements Card

    private var requirementsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "checkmark.shield")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.plagitSecondary)
                Text("Password Requirements")
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitSecondary)
            }

            requirementRow("At least 12 characters", met: newPassword.count >= 12)
            requirementRow("One uppercase letter (A-Z)", met: newPassword.range(of: "[A-Z]", options: .regularExpression) != nil)
            requirementRow("One lowercase letter (a-z)", met: newPassword.range(of: "[a-z]", options: .regularExpression) != nil)
            requirementRow("One number (0-9)", met: newPassword.range(of: "[0-9]", options: .regularExpression) != nil)
            requirementRow("Passwords match", met: confirmMatch)
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitSurface)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Helpers

    private func passwordField(_ placeholder: String, text: Binding<String>, visible: Binding<Bool>, field: Field) -> some View {
        HStack(spacing: PlagitSpacing.sm) {
            Group {
                if visible.wrappedValue {
                    TextField(placeholder, text: text)
                } else {
                    SecureField(placeholder, text: text)
                }
            }
            .font(PlagitFont.body())
            .foregroundColor(.plagitCharcoal)
            .focused($focusedField, equals: field)
            .textContentType(.password)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            Button {
                visible.wrappedValue.toggle()
            } label: {
                Image(systemName: visible.wrappedValue ? "eye.slash" : "eye")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.plagitTertiary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(PlagitSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.sm)
                .fill(Color.plagitSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PlagitRadius.sm)
                .stroke(focusedField == field ? Color.plagitTeal : Color.plagitBorder, lineWidth: 1)
        )
    }

    private func requirementRow(_ text: String, met: Bool) -> some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(met ? .plagitOnline : .plagitTertiary)
            Text(text)
                .font(PlagitFont.caption())
                .foregroundColor(met ? .plagitCharcoal : .plagitTertiary)
        }
    }

    private func submit() {
        errorMessage = nil
        isLoading = true
        focusedField = nil

        Task {
            do {
                try await AdminAuthService.shared.changePassword(
                    newPassword: newPassword
                )
                showSuccess = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack { AdminChangePasswordView() }
        .preferredColorScheme(.light)
}
