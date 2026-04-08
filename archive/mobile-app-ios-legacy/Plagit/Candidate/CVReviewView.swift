//
//  CVReviewView.swift
//  Plagit
//
//  Review screen for CV-extracted profile data.
//  Shows extracted fields, allows editing, then saves to profile.
//

import SwiftUI

struct CVReviewView: View {
    @Environment(\.dismiss) private var dismiss
    let extractedData: CandidateAPIService.CVExtractedData
    var onSave: (CVReviewView.ReviewedFields) async -> Void

    struct ReviewedFields {
        var name: String
        var phone: String
        var location: String
        var role: String
        var experience: String
        var languages: String
        var bio: String
        var jobType: String
        var email: String
        var skills: String
        var certifications: String
    }

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var location = ""
    @State private var role = ""
    @State private var experience = ""
    @State private var languages = ""
    @State private var skills = ""
    @State private var certifications = ""
    @State private var bio = ""
    @State private var jobType = "Full-time"
    @State private var isSaving = false

    private let jobTypes = ["Full-time", "Part-time", "Contract", "Freelance", "Temporary", "Flexible"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: PlagitSpacing.xl) {

                        // Header
                        VStack(spacing: PlagitSpacing.sm) {
                            ZStack {
                                Circle().fill(Color.plagitOnline.opacity(0.1)).frame(width: 56, height: 56)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(.plagitOnline)
                            }
                            Text("We extracted the details below from your CV. Please review, edit if needed, and confirm before saving.")
                                .font(PlagitFont.caption())
                                .foregroundColor(.plagitSecondary)
                                .multilineTextAlignment(.center)
                            Text("Nothing will be saved until you confirm.")
                                .font(PlagitFont.micro())
                                .foregroundColor(.plagitTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, PlagitSpacing.lg)

                        // Fields
                        fieldCard("Personal Details") {
                            editField("First Name", text: $firstName, icon: "person")
                            editField("Last Name", text: $lastName, icon: "person")
                            editField("Phone Number", text: $phone, icon: "phone", keyboard: .phonePad)
                            editField("Location", text: $location, icon: "mappin")
                        }

                        fieldCard("Professional") {
                            editField("Job Role", text: $role, icon: "briefcase")
                            editField("Years of Experience", text: $experience, icon: "clock")

                            // Job type picker
                            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                HStack(spacing: PlagitSpacing.xs) {
                                    Image(systemName: "person.badge.clock").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                                    Text("Job Type").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                                }
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: PlagitSpacing.sm) {
                                        ForEach(jobTypes, id: \.self) { type in
                                            let active = jobType == type
                                            Button { jobType = type } label: {
                                                Text(type)
                                                    .font(PlagitFont.captionMedium())
                                                    .foregroundColor(active ? .white : .plagitSecondary)
                                                    .fixedSize()
                                                    .padding(.horizontal, PlagitSpacing.md)
                                                    .padding(.vertical, PlagitSpacing.sm)
                                                    .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        fieldCard("Languages & Skills") {
                            editField("Languages", text: $languages, icon: "globe")
                            editField("Skills", text: $skills, icon: "star")
                            editField("Certifications", text: $certifications, icon: "rosette")
                        }

                        if !bio.isEmpty {
                            fieldCard("About") {
                                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                    HStack(spacing: PlagitSpacing.xs) {
                                        Image(systemName: "text.alignleft").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                                        Text("Bio").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                                    }
                                    TextEditor(text: $bio)
                                        .font(PlagitFont.body())
                                        .foregroundColor(.plagitCharcoal)
                                        .frame(minHeight: 60)
                                        .scrollContentBackground(.hidden)
                                }
                            }
                        }

                        // Edit note
                        Text("You can edit any extracted field before saving.")
                            .font(PlagitFont.micro())
                            .foregroundColor(.plagitTertiary)
                            .frame(maxWidth: .infinity)

                        // Save button
                        Button {
                            Task {
                                isSaving = true
                                let fullName = [firstName, lastName].map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }.joined(separator: " ")
                                await onSave(ReviewedFields(
                                    name: fullName,
                                    phone: phone.trimmingCharacters(in: .whitespaces),
                                    location: location.trimmingCharacters(in: .whitespaces),
                                    role: role.trimmingCharacters(in: .whitespaces),
                                    experience: experience.trimmingCharacters(in: .whitespaces),
                                    languages: languages.trimmingCharacters(in: .whitespaces),
                                    bio: bio.trimmingCharacters(in: .whitespaces),
                                    jobType: jobType,
                                    email: email.trimmingCharacters(in: .whitespaces),
                                    skills: skills.trimmingCharacters(in: .whitespaces),
                                    certifications: certifications.trimmingCharacters(in: .whitespaces)
                                ))
                                isSaving = false
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: PlagitSpacing.sm) {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Image(systemName: "checkmark").font(.system(size: 14, weight: .semibold))
                                    Text("Save to Profile")
                                }
                            }
                            .font(PlagitFont.bodyMedium())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PlagitSpacing.lg)
                            .background(Capsule().fill(Color.plagitTeal))
                        }
                        .disabled(isSaving)
                        .padding(.top, PlagitSpacing.sm)

                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                    .padding(.horizontal, PlagitSpacing.xl)
                }
            }
            .navigationTitle("Review Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitSecondary)
                }
            }
            .onAppear { prefill() }
        }
    }

    // MARK: - Prefill from extracted data

    private func prefill() {
        let d = extractedData
        firstName = d.firstName ?? ""
        lastName = d.lastName ?? ""
        email = d.email ?? ""
        phone = d.phone ?? ""
        location = d.location ?? ""
        role = d.role ?? ""
        experience = d.experience ?? ""
        languages = d.languages ?? ""
        skills = d.skills ?? ""
        certifications = d.certifications ?? ""
        bio = d.bio ?? ""
    }

    // MARK: - Helpers

    private func fieldCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            content()
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
    }

    private func editField(_ placeholder: String, text: Binding<String>, icon: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
            HStack(spacing: PlagitSpacing.xs) {
                Image(systemName: icon).font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                Text(placeholder).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            }
            TextField(placeholder, text: text)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
                .keyboardType(keyboard)
                .padding(.horizontal, PlagitSpacing.md)
                .padding(.vertical, PlagitSpacing.md)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
    }
}
