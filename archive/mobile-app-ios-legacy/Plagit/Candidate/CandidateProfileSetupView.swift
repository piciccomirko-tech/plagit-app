//
//  CandidateProfileSetupView.swift
//  Plagit
//
//  Premium Candidate Profile Setup / Onboarding Screen
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct CandidateProfileSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentRole = ""
    @State private var jobType = ""

    // 3-level hospitality picker state
    @State private var hCategoryId = ""
    @State private var hSubcategoryId = ""
    @State private var hRoleId = ""
    @State private var showCategoryPicker = false
    @State private var location = ""
    @State private var experience = "Select"
    @State private var languages = ""
    @State private var selectedLanguages: Set<String> = []
    @State private var showLanguagePicker = false
    @State private var startDate = "Immediately"
    @State private var availableToRelocate = false
    @State private var bio = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showDashboard = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isUploadingPhoto = false
    @State private var uploadedPhotoUrl: String?
    @State private var showCVPicker = false
    @State private var cvFileName: String?
    @State private var showStartDateMenu = false
    @State private var showWelcome = false
    @State private var showCVParsePicker = false
    @State private var isParsingCV = false
    @State private var cvExtractedData: CandidateAPIService.CVExtractedData?
    @State private var cvParseError: String?
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case role, location, languages, bio
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

                    photoUpload
                        .padding(.top, PlagitSpacing.xxl)

                    detailsCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    cvUploadCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    availabilityCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    bioCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    completeButton
                        .padding(.top, PlagitSpacing.xxl)

                    skipButton
                        .padding(.top, PlagitSpacing.lg)

                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showDashboard) {
            HomeView().navigationBarHidden(true)
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "plagit_show_candidate_welcome") {
                UserDefaults.standard.removeObject(forKey: "plagit_show_candidate_welcome")
                showWelcome = true
            }
        }
        .alert(L10n.t("welcome_title"), isPresented: $showWelcome) {
            Button("OK") {}
        } message: {
            Text(L10n.t("welcome_candidate_body"))
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView(selected: $selectedLanguages) {
                languages = Language.storageString(from: selectedLanguages)
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            HospitalityCategoryPicker(
                selectedCategoryId: $hCategoryId,
                selectedSubcategoryId: $hSubcategoryId,
                selectedRoleId: $hRoleId
            )
        }
        .sheet(item: $cvExtractedData) { data in
            CVReviewView(extractedData: data) { reviewed in
                // Apply reviewed fields to the form
                if !reviewed.location.isEmpty { location = reviewed.location }
                if !reviewed.role.isEmpty { currentRole = reviewed.role }
                if !reviewed.experience.isEmpty { experience = reviewed.experience }
                if !reviewed.languages.isEmpty {
                    languages = reviewed.languages
                    selectedLanguages = Set(reviewed.languages.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
                }
                if !reviewed.bio.isEmpty { bio = reviewed.bio }
                if !reviewed.jobType.isEmpty { jobType = reviewed.jobType }

                // Save to backend
                do {
                    _ = try await CandidateAPIService.shared.updateProfile(
                        name: reviewed.name.isEmpty ? nil : reviewed.name,
                        phone: reviewed.phone.isEmpty ? nil : reviewed.phone,
                        location: reviewed.location.isEmpty ? nil : reviewed.location,
                        role: reviewed.role.isEmpty ? nil : reviewed.role,
                        experience: reviewed.experience.isEmpty ? nil : reviewed.experience,
                        languages: reviewed.languages.isEmpty ? nil : reviewed.languages,
                        jobType: reviewed.jobType.isEmpty ? nil : reviewed.jobType,
                        bio: reviewed.bio.isEmpty ? nil : reviewed.bio
                    )
                } catch {
                    await MainActor.run { errorMessage = "Failed to save profile: \(error.localizedDescription)" }
                }
            }
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

            Text(L10n.t("complete_your_profile"))
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
        VStack(spacing: PlagitSpacing.lg) {
            Text("Choose how you want to set up your profile.")
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, PlagitSpacing.xxl)

            // Option 2: Upload CV
            Button { showCVParsePicker = true } label: {
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitTealLight).frame(width: 40, height: 40)
                        Image(systemName: "doc.text.magnifyingglass").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitTeal)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upload CV").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        Text("Upload your CV to pre-fill your profile automatically and save time.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(2)
                    }
                    Spacer()
                    if isParsingCV {
                        VStack(spacing: 4) {
                            ProgressView().tint(.plagitTeal)
                            Text("Reading Your CV").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                        }
                    } else {
                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
                    }
                }
                .padding(PlagitSpacing.lg)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitTeal.opacity(0.2), lineWidth: 1))
            }
            .disabled(isParsingCV)
            .padding(.horizontal, PlagitSpacing.xl)
            .fileImporter(
                isPresented: $showCVParsePicker,
                allowedContentTypes: [.pdf, UTType(filenameExtension: "doc") ?? .data, UTType(filenameExtension: "docx") ?? .data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    let name = url.lastPathComponent
                    guard url.startAccessingSecurityScopedResource() else { errorMessage = "Cannot access file"; return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    guard let data = try? Data(contentsOf: url) else { errorMessage = "Could not read file"; return }
                    guard data.count <= 5_000_000 else { errorMessage = "File exceeds 5 MB limit"; return }
                    cvFileName = name
                    Task { await parseCVData(data: data, fileName: name) }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }

            // CV error / partial extraction state
            if let err = cvParseError {
                VStack(spacing: PlagitSpacing.sm) {
                    Text(err).font(PlagitFont.caption()).foregroundColor(.plagitAmber).multilineTextAlignment(.center)
                    Text("If anything is missing, you can complete it manually.").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }.padding(.horizontal, PlagitSpacing.xxl)
            }

            // Supported formats
            Text("Supported formats: PDF, DOC, DOCX").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)

            // Divider with Option 1: Fill Manually
            HStack(spacing: PlagitSpacing.md) {
                Rectangle().fill(Color.plagitDivider).frame(height: 1)
                Text("or").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                Rectangle().fill(Color.plagitDivider).frame(height: 1)
            }.padding(.horizontal, PlagitSpacing.xxl)

            // Option 1: Fill Manually label
            VStack(spacing: 2) {
                Text("Fill Manually").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                Text("Enter your details yourself and complete your profile step by step.").font(PlagitFont.micro()).foregroundColor(.plagitTertiary).multilineTextAlignment(.center)
            }.padding(.horizontal, PlagitSpacing.xxl)
        }
    }

    // MARK: - Photo Upload

    private var photoUpload: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            VStack(spacing: PlagitSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.plagitSurface)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.plagitTeal.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        )

                    if isUploadingPhoto {
                        ProgressView().tint(.plagitTeal)
                    } else if uploadedPhotoUrl != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.plagitOnline)
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.plagitTeal)
                    }
                }

                Text(uploadedPhotoUrl != nil ? L10n.t("change_photo") : L10n.t("add_photo"))
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitTeal)
            }
        }
        .disabled(isUploadingPhoto)
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await handlePhotoSelection(item) }
        }
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.yourDetails)
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

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
                Text(L10n.t("job_type"))
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitSecondary)

                ChipSelectorView(
                    options: PlagitJobType.allCases.map { ChipOption(value: $0.rawValue, label: $0.label, icon: $0.icon) },
                    selected: $jobType
                )
            }

            VStack(spacing: 0) {
                inputRow(icon: "mappin", placeholder: "Location (e.g. London, UK)", text: $location, field: .location)
                divider
                inputRow(icon: "clock", placeholder: "Years of Experience (e.g. 5 years)", text: $experience, field: .languages)
                divider
                // Languages — tappable to open picker
                Button { showLanguagePicker = true } label: {
                    HStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "globe").font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 20)
                        Text(languages.isEmpty ? "Select languages" : Language.displayLabel(from: languages))
                            .font(PlagitFont.body())
                            .foregroundColor(languages.isEmpty ? .plagitTertiary : .plagitCharcoal)
                            .lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary)
                    }
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md + 2)
                }
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

    // MARK: - CV Upload Card

    private var cvUploadCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.t("your_cv"))
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            Button { showCVPicker = true } label: {
                HStack(spacing: PlagitSpacing.md) {
                    Image(systemName: cvFileName != nil ? "doc.fill" : "doc.badge.plus")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.plagitTeal)
                        .frame(width: 34, height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: PlagitRadius.md)
                                .fill(Color.plagitTealLight)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(cvFileName ?? L10n.t("upload_your_cv"))
                            .font(PlagitFont.bodyMedium())
                            .foregroundColor(.plagitCharcoal)
                            .lineLimit(1)

                        Text(cvFileName != nil ? "Tap to change" : "PDF, DOC — Max 5 MB")
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)
                    }

                    Spacer()

                    if cvFileName != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.plagitOnline)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.plagitTertiary)
                    }
                }
                .padding(PlagitSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(Color.plagitSurface)
                )
            }
            .fileImporter(
                isPresented: $showCVPicker,
                allowedContentTypes: [.pdf, UTType(filenameExtension: "doc") ?? .data, UTType(filenameExtension: "docx") ?? .data],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    let name = url.lastPathComponent
                    guard url.startAccessingSecurityScopedResource() else {
                        errorMessage = "Cannot access file"; return
                    }
                    defer { url.stopAccessingSecurityScopedResource() }
                    guard let data = try? Data(contentsOf: url) else {
                        errorMessage = "Could not read file"; return
                    }
                    guard data.count <= 5_000_000 else {
                        errorMessage = "File exceeds 5 MB limit"; return
                    }
                    cvFileName = name
                    Task {
                        do {
                            let base64 = data.base64EncodedString()
                            _ = try await CandidateAPIService.shared.uploadCV(base64Data: base64, fileName: name)
                        } catch {
                            await MainActor.run { errorMessage = "CV upload failed" }
                        }
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
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

    // MARK: - Availability Card

    private var availabilityCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.t("availability"))
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            VStack(spacing: 0) {
                Menu {
                    ForEach(["Immediately", "Within 1 week", "Within 2 weeks", "Within 1 month", "Flexible"], id: \.self) { option in
                        Button(option) { startDate = option }
                    }
                } label: {
                    availabilityRow(icon: "calendar", label: "Start Date", value: startDate)
                        .contentShape(Rectangle())
                }
            }
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(Color.plagitSurface)
            )

            Toggle(isOn: $availableToRelocate) {
                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "globe.americas.fill").font(.system(size: 12)).foregroundColor(.plagitIndigo)
                    Text(L10n.t("open_to_relocation")).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                }
            }.tint(.plagitIndigo)
        }
        .padding(PlagitSpacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func availabilityRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTeal)
                .frame(width: 20)

            Text(label)
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)

            Spacer()

            Text(value)
                .font(PlagitFont.bodyMedium())
                .foregroundColor(.plagitCharcoal)
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.md + 2)
    }

    // MARK: - Bio Card

    private var bioCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.sm) {
                Text(L10n.t("about_you"))
                    .font(PlagitFont.headline())
                    .foregroundColor(.plagitCharcoal)

                Text(L10n.t("optional"))
                    .font(PlagitFont.micro())
                    .foregroundColor(.plagitTertiary)
                    .padding(.horizontal, PlagitSpacing.sm)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.plagitDivider))
            }

            ZStack(alignment: .topLeading) {
                if bio.isEmpty {
                    Text("Write a short intro about yourself...")
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitTertiary)
                        .padding(.horizontal, PlagitSpacing.lg)
                        .padding(.vertical, PlagitSpacing.md)
                }

                TextEditor(text: $bio)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitCharcoal)
                    .scrollContentBackground(.hidden)
                    .focused($focusedField, equals: .bio)
                    .padding(.horizontal, PlagitSpacing.md)
                    .padding(.vertical, PlagitSpacing.sm)
                    .onChange(of: bio) { _, newValue in
                        if newValue.count > 300 { bio = String(newValue.prefix(300)) }
                    }
            }
            .frame(minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(Color.plagitSurface)
            )

            HStack {
                Spacer()
                Text("\(bio.count) / 300")
                    .font(PlagitFont.micro())
                    .foregroundColor(bio.count >= 280 ? .plagitAmber : .plagitTertiary)
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

    // MARK: - CV Parse

    private func parseCVData(data: Data, fileName: String) async {
        isParsingCV = true
        cvParseError = nil
        do {
            let mimePrefix: String
            if fileName.lowercased().hasSuffix(".pdf") { mimePrefix = "data:application/pdf;base64," }
            else if fileName.lowercased().hasSuffix(".docx") { mimePrefix = "data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64," }
            else { mimePrefix = "data:application/octet-stream;base64," }
            let base64 = mimePrefix + data.base64EncodedString()

            let result = try await CandidateAPIService.shared.parseCV(base64Data: base64, fileName: fileName)

            if let error = result.parseError, !error.isEmpty {
                cvParseError = error
            }

            if let extracted = result.extracted,
               (extracted.firstName != nil || extracted.role != nil || extracted.location != nil) {
                cvExtractedData = extracted
            } else if cvParseError == nil {
                cvParseError = "We couldn't read your CV. Please try again with a clearer file or complete your profile manually."
            }
        } catch {
            cvParseError = "We couldn't read your CV. Please try again with a clearer file or complete your profile manually."
        }
        isParsingCV = false
    }

    // MARK: - Complete Button

    private var completeButton: some View {
        VStack(spacing: PlagitSpacing.sm) {
            if let msg = errorMessage {
                Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
            }

            Button { saveProfile() } label: {
                Group {
                    if isLoading { ProgressView().tint(.white) }
                    else { Text(L10n.completeProfile) }
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
            .disabled(isLoading)
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Skip

    private var skipButton: some View {
        Button { showDashboard = true } label: {
            Text(L10n.t("skip_for_now"))
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitTeal)
        }
    }

    private func saveProfile() {
        isLoading = true; errorMessage = nil
        Task {
            do {
                _ = try await CandidateAPIService.shared.updateProfile(
                    name: nil,
                    phone: nil,
                    location: location.isEmpty ? nil : location,
                    role: !hRoleId.isEmpty ? hRoleId : (currentRole.isEmpty ? nil : currentRole),
                    experience: experience.isEmpty ? nil : experience,
                    languages: languages.isEmpty ? nil : languages,
                    startDate: startDate,
                    jobType: jobType.isEmpty ? nil : jobType,
                    bio: bio.isEmpty ? nil : bio,
                    availableToRelocate: availableToRelocate
                )
                showDashboard = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Photo Handler

    @MainActor
    private func handlePhotoSelection(_ item: PhotosPickerItem) async {
        isUploadingPhoto = true
        errorMessage = nil
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                errorMessage = "Could not load image"; isUploadingPhoto = false; return
            }
            guard let uiImage = UIImage(data: data) else {
                errorMessage = "Invalid image format"; isUploadingPhoto = false; return
            }
            var quality: CGFloat = 0.5
            var jpeg = uiImage.jpegData(compressionQuality: quality)
            while let j = jpeg, j.count > 750_000, quality > 0.1 {
                quality -= 0.1
                jpeg = uiImage.jpegData(compressionQuality: quality)
            }
            guard let finalJpeg = jpeg else {
                errorMessage = "Could not compress image"; isUploadingPhoto = false; return
            }
            let base64 = "data:image/jpeg;base64," + finalJpeg.base64EncodedString()
            uploadedPhotoUrl = try await CandidateAPIService.shared.uploadPhoto(base64Data: base64)
        } catch {
            errorMessage = "Photo upload failed"
        }
        isUploadingPhoto = false
        selectedPhoto = nil
    }

    // MARK: - Helpers

    private func inputRow(icon: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTeal)
                .frame(width: 20)

            TextField(placeholder, text: text)
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
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CandidateProfileSetupView()
    }
    .preferredColorScheme(.light)
}
