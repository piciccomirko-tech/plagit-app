//
//  BusinessRealScheduleInterviewView.swift
//  Plagit
//
//  Real schedule-interview form backed by POST /business/interviews.
//

import SwiftUI

struct BusinessRealScheduleInterviewView: View {
    var applicationId: String? = nil
    var candidateId: String? = nil
    let candidateName: String
    let jobTitle: String
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date().addingTimeInterval(3 * 24 * 3600)
    @State private var interviewType = "video_call"
    @State private var meetingLink = ""
    @State private var location = ""
    @State private var timezone = "UTC"
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var success = false

    private let types = [("video_call", "Video Call"), ("phone", "Phone"), ("in_person", "In Person")]
    private let timezones = ["UTC", "GST", "GMT", "CET", "EST", "PST"]

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        candidateCard
                        formCard
                        if let msg = errorMessage { Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent).padding(.horizontal, PlagitSpacing.xl) }
                        submitButton
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }.padding(.top, PlagitSpacing.lg)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Interview Scheduled", isPresented: $success) {
            Button("OK") { dismiss() }
        } message: { Text("Interview with \(candidateName) for \(jobTitle) has been scheduled. The candidate will be notified.") }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text("Schedule Interview").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
            Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private var candidateCard: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "person.fill").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitTeal)
            VStack(alignment: .leading, spacing: 2) {
                Text(candidateName).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("for \(jobTitle)").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }; Spacer()
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            DatePicker("Date & Time", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text("Interview Type").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                HStack(spacing: PlagitSpacing.sm) {
                    ForEach(types, id: \.0) { val, label in
                        Button { interviewType = val } label: {
                            Text(label).font(PlagitFont.captionMedium()).foregroundColor(interviewType == val ? .white : .plagitSecondary)
                                .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                                .background(Capsule().fill(interviewType == val ? Color.plagitTeal : Color.plagitSurface))
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text("Timezone").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                Picker("Timezone", selection: $timezone) { ForEach(timezones, id: \.self) { Text($0) } }.pickerStyle(.segmented)
            }

            if interviewType == "video_call" {
                field("Meeting Link", text: $meetingLink, placeholder: "https://meet.google.com/...")
            }
            if interviewType == "in_person" {
                field("Location", text: $location, placeholder: "e.g. 123 Main St, Dubai")
            }
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func field(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            TextField(placeholder, text: text).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                .padding(PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
        }
    }

    private var submitButton: some View {
        Button { schedule() } label: {
            Group { if isLoading { ProgressView().tint(.white) } else { Text("Send Interview Invite") } }
                .font(PlagitFont.subheadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                .background(Capsule().fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing)))
        }.disabled(isLoading).padding(.horizontal, PlagitSpacing.xl)
    }

    private func schedule() {
        isLoading = true; errorMessage = nil
        let formatter = ISO8601DateFormatter()
        let scheduledAt = formatter.string(from: date)
        Task {
            do {
                _ = try await BusinessAPIService.shared.scheduleInterview(
                    applicationId: applicationId, candidateId: candidateId,
                    scheduledAt: scheduledAt, timezone: timezone,
                    interviewType: interviewType,
                    location: interviewType == "in_person" ? (location.isEmpty ? nil : location) : nil,
                    meetingLink: interviewType == "video_call" ? (meetingLink.isEmpty ? nil : meetingLink) : nil)
                success = true
            } catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
}
