//
//  BusinessRealPostJobView.swift
//  Plagit
//
//  Real post-a-job form backed by POST /business/jobs.
//

import SwiftUI

struct BusinessRealPostJobView: View {
    @Environment(\.dismiss) private var dismiss
    var onJobCreated: (() -> Void)?
    @State private var title = ""
    @State private var location = ""
    @State private var employmentType = "Full-time"
    @State private var salary = ""
    @State private var category = ""
    @State private var jobDescription = ""
    @State private var requirements = ""
    @State private var isUrgent = false
    @State private var openToInternational = false
    @State private var numHires = 1
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var hasSpecificHours = false
    @State private var startTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @State private var endTime = Calendar.current.date(from: DateComponents(hour: 17, minute: 0)) ?? Date()
    @State private var seasonLabel = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var success = false

    // 3-level hospitality picker state
    @State private var hCategoryId = ""
    @State private var hSubcategoryId = ""
    @State private var hRoleId = ""
    @State private var showCategoryPicker = false

    private let types = PlagitJobType.allCases.map(\.rawValue)

    private var durationLabel: String {
        let diff = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate), to: Calendar.current.startOfDay(for: endDate)).day ?? 0
        let days = diff + 1 // inclusive: Apr 1 to Apr 2 = 2 days
        if days <= 1 { return "1 day" }
        if days < 7 { return "\(days) days" }
        if days == 7 { return "1 week" }
        if days < 14 { return "\(days) days" }
        if days == 14 { return "2 weeks" }
        if days < 30 { return "\(days / 7) weeks, \(days % 7) days" }
        let months = Calendar.current.dateComponents([.month], from: startDate, to: endDate).month ?? 0
        if months < 1 { return "1 month" }
        let remainDays = days - (months * 30)
        if remainDays <= 1 { return months == 1 ? "1 month" : "\(months) months" }
        return months == 1 ? "1 month, \(remainDays) days" : "\(months) months"
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        formCard
                        if let msg = errorMessage {
                            Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent).padding(.horizontal, PlagitSpacing.xl)
                        }
                        submitButton
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }.padding(.top, PlagitSpacing.lg)
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
        .alert("Job Posted", isPresented: $success) {
            Button("OK") { onJobCreated?(); dismiss() }
        } message: { Text("Your job '\(title)' is now live and visible to candidates.") }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text(L10n.t("post_a_job")).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
            Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            field("Job Title", text: $title, placeholder: "e.g. Senior Chef")
            field("Location", text: $location, placeholder: "e.g. Dubai, UAE")
            field("Salary", text: $salary, placeholder: "e.g. $5,500/mo")

            // Category & Role picker
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text(L10n.t("required_role")).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                HospitalityCategoryButton(
                    categoryId: hCategoryId,
                    subcategoryId: hSubcategoryId,
                    roleId: hRoleId
                ) { showCategoryPicker = true }
            }

            // Description
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text("Job Description").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                ZStack(alignment: .topLeading) {
                    if jobDescription.isEmpty {
                        Text("Describe the role, responsibilities, and what makes this job great...")
                            .font(PlagitFont.body()).foregroundColor(.plagitTertiary)
                            .padding(.horizontal, 5).padding(.vertical, 8)
                    }
                    TextEditor(text: $jobDescription)
                        .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        .frame(minHeight: 80).scrollContentBackground(.hidden)
                }
                .padding(PlagitSpacing.md)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
            }

            // Requirements
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text("Requirements").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                ZStack(alignment: .topLeading) {
                    if requirements.isEmpty {
                        Text("Skills, experience, certifications needed...")
                            .font(PlagitFont.body()).foregroundColor(.plagitTertiary)
                            .padding(.horizontal, 5).padding(.vertical, 8)
                    }
                    TextEditor(text: $requirements)
                        .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        .frame(minHeight: 60).scrollContentBackground(.hidden)
                }
                .padding(PlagitSpacing.md)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
            }

            // Urgent + Number of hires
            HStack(spacing: PlagitSpacing.lg) {
                Toggle(isOn: $isUrgent) {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "bolt.fill").font(.system(size: 12)).foregroundColor(.plagitAmber)
                        Text(L10n.t("urgent_hiring")).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    }
                }.tint(.plagitAmber)

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.t("hires_needed")).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Stepper("\(numHires)", value: $numHires, in: 1...20)
                        .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                }
            }

            // Job type chips
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text(L10n.t("job_type")).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                ChipSelectorView(
                    options: PlagitJobType.allCases.map { ChipOption(value: $0.rawValue, label: $0.label, icon: $0.icon) },
                    selected: $employmentType
                )
            }

            // International toggle
            Toggle(isOn: $openToInternational) {
                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "globe.americas.fill").font(.system(size: 12)).foregroundColor(.plagitIndigo)
                    Text(L10n.t("open_to_international")).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                }
            }.tint(.plagitIndigo)
        }
        .padding(PlagitSpacing.xl)
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
        Button { postJob() } label: {
            Group { if isLoading { ProgressView().tint(.white) } else { Text(L10n.t("publish_job")) } }
                .font(PlagitFont.subheadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                .background(Capsule().fill(title.isEmpty ? AnyShapeStyle(Color.plagitTeal.opacity(0.4)) : AnyShapeStyle(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing))))
        }
        .disabled(title.isEmpty || isLoading).padding(.horizontal, PlagitSpacing.xl)
    }

    private func postJob() {
        isLoading = true; errorMessage = nil
        Task {
            do {
                // Resolve category from picker or fallback to text field
                let resolvedCategory: String? = {
                    if !hRoleId.isEmpty { return hRoleId }
                    return category.isEmpty ? nil : category
                }()
                _ = try await BusinessAPIService.shared.createJob(
                    title: title, location: location.isEmpty ? nil : location,
                    employmentType: employmentType, salary: salary.isEmpty ? nil : salary,
                    category: resolvedCategory,
                    description: jobDescription.isEmpty ? nil : jobDescription,
                    requirements: requirements.isEmpty ? nil : requirements,
                    isUrgent: isUrgent, numHires: numHires,
                    openToInternational: openToInternational,
                    latitude: LocationManager.shared.latitude,
                    longitude: LocationManager.shared.longitude)
                success = true
            } catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }
}
