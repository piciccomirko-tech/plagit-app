//
//  MatchFeedbackView.swift
//  Plagit
//
//  Post-match feedback: was the match relevant, role accurate, job type correct?
//  Shown as a sheet after viewing a match profile.
//

import SwiftUI

struct MatchFeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    let matchId: String
    let isBusiness: Bool
    @State private var wasRelevant: Bool?
    @State private var roleAccurate: Bool?
    @State private var jobTypeAccurate: Bool?
    @State private var isSending = false
    @State private var sent = false

    var body: some View {
        VStack(spacing: PlagitSpacing.xxl) {
            Spacer().frame(height: PlagitSpacing.lg)

            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.plagitDivider)
                .frame(width: 36, height: 5)

            VStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "star.bubble")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.plagitTeal)

                Text("Quick Feedback")
                    .font(PlagitFont.headline())
                    .foregroundColor(.plagitCharcoal)

                Text("Help us improve your matches")
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)
            }

            VStack(spacing: PlagitSpacing.lg) {
                feedbackRow("Was this match relevant?", selection: $wasRelevant)
                feedbackRow("Was the role accurate?", selection: $roleAccurate)
                feedbackRow("Was the job type correct?", selection: $jobTypeAccurate)
            }
            .padding(.horizontal, PlagitSpacing.xl)

            if sent {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.plagitOnline)
                    Text("Thanks for your feedback!").font(PlagitFont.bodyMedium()).foregroundColor(.plagitOnline)
                }
                .padding(.top, PlagitSpacing.md)
            }

            HStack(spacing: PlagitSpacing.lg) {
                Button { dismiss() } label: {
                    Text("Skip")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PlagitSpacing.md)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
                }

                Button { submitFeedback() } label: {
                    Group {
                        if isSending { ProgressView().tint(.white) }
                        else { Text("Submit") }
                    }
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(hasAnyAnswer ? Color.plagitTeal : Color.plagitTeal.opacity(0.4)))
                }
                .disabled(!hasAnyAnswer || isSending)
            }
            .padding(.horizontal, PlagitSpacing.xl)

            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    private var hasAnyAnswer: Bool {
        wasRelevant != nil || roleAccurate != nil || jobTypeAccurate != nil
    }

    private func feedbackRow(_ question: String, selection: Binding<Bool?>) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
            Text(question)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)

            HStack(spacing: PlagitSpacing.md) {
                feedbackButton("Yes", isSelected: selection.wrappedValue == true, color: .plagitOnline) {
                    selection.wrappedValue = true
                }
                feedbackButton("No", isSelected: selection.wrappedValue == false, color: .plagitUrgent) {
                    selection.wrappedValue = false
                }
                Spacer()
            }
        }
        .padding(PlagitSpacing.lg)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
    }

    private func feedbackButton(_ label: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.xs) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .medium))
                Text(label).font(PlagitFont.captionMedium())
            }
            .foregroundColor(isSelected ? color : .plagitSecondary)
            .padding(.horizontal, PlagitSpacing.lg)
            .padding(.vertical, PlagitSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.1) : Color.plagitCardBackground)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? color.opacity(0.3) : Color.plagitBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func submitFeedback() {
        isSending = true
        Task {
            do {
                let path = isBusiness ? "/business/feedback" : "/candidate/feedback"
                var dict: [String: Any] = ["match_id": matchId]
                if let v = wasRelevant { dict["was_relevant"] = v }
                if let v = roleAccurate { dict["role_accurate"] = v }
                if let v = jobTypeAccurate { dict["job_type_accurate"] = v }
                try await APIClient.shared.requestVoid(.POST, path: path, body: JSONBody(dict))
                sent = true
                try? await Task.sleep(nanoseconds: 1_200_000_000)
                dismiss()
            } catch {
                dismiss()
            }
            isSending = false
        }
    }
}
