//
//  CandidateRealProfileView.swift
//  Plagit
//
//  Real candidate profile page backed by GET/PUT /candidate/profile.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct CandidateRealProfileView: View {
    @Environment(\.dismiss) private var dismiss

    private var sub = SubscriptionManager.shared
    @State private var showSubscription = false
    @State private var profile: CandidateProfileDTO?
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isUploadingPhoto = false

    // CV upload state
    @State private var showCVPicker = false
    @State private var isParsingCV = false
    @State private var cvExtractedData: CandidateAPIService.CVExtractedData?
    @State private var cvError: String?

    // Edit state
    @State private var isEditing = false
    @State private var editName = ""
    @State private var editPhone = ""
    @State private var editLocation = ""
    @State private var editRole = ""
    @State private var editExperience = ""
    @State private var editLanguages = ""
    @State private var selectedCandLanguages: Set<String> = []
    @State private var showCandLanguagePicker = false
    @State private var editAvailableToRelocate = false

    // 3-level hospitality picker state
    @State private var hCategoryId = ""
    @State private var hSubcategoryId = ""
    @State private var hRoleId = ""
    @State private var showCategoryPicker = false
    @State private var isSaving = false
    @State private var saveError: String?

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground).zIndex(1)

                if isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        Button { Task { await load() } } label: { Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else if let p = profile {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.sectionGap) {
                            heroCard(p)
                            subscriptionCard
                            profileStrengthCard(p)
                            if isEditing { editForm } else { detailSections(p) }
                            logoutSection
                            Spacer().frame(height: PlagitSpacing.xxxl)
                        }
                        .padding(.top, PlagitSpacing.xs)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCandLanguagePicker) {
            LanguagePickerView(selected: $selectedCandLanguages) {
                editLanguages = Language.storageString(from: selectedCandLanguages)
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
                    await load()
                } catch {
                    await MainActor.run { saveError = "Failed to save: \(error.localizedDescription)" }
                }
            }
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
                guard url.startAccessingSecurityScopedResource() else { cvError = "Cannot access file"; return }
                defer { url.stopAccessingSecurityScopedResource() }
                guard let data = try? Data(contentsOf: url) else { cvError = "Could not read file"; return }
                guard data.count <= 5_000_000 else { cvError = "File exceeds 5 MB limit"; return }
                Task { await parseCVFromProfile(data: data, fileName: name) }
            case .failure(let error):
                cvError = error.localizedDescription
            }
        }
        .navigationDestination(isPresented: $showSubscription) {
            CandidateSubscriptionView().navigationBarHidden(true)
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do {
            profile = try await CandidateAPIService.shared.fetchProfile()
            populateEditFields()
        } catch { loadError = L10n.apiError(error.localizedDescription) }
        isLoading = false
    }

    private func populateEditFields() {
        guard let p = profile else { return }
        editName = p.name; editPhone = p.phone ?? ""; editLocation = p.location ?? ""
        editRole = p.role ?? ""; editExperience = p.experience ?? ""; editLanguages = p.languages ?? ""
        selectedCandLanguages = Language.parseCodes(from: p.languages)
        // Try to resolve stored role into picker state
        if let roleId = p.role, !roleId.isEmpty, HospitalityCatalog.role(id: roleId) != nil {
            // Role is a catalog ID — find its category and subcategory
            for cat in HospitalityCatalog.all {
                for sub in cat.subcategories {
                    if sub.roles.contains(where: { $0.id == roleId }) {
                        hCategoryId = cat.id; hSubcategoryId = sub.id; hRoleId = roleId
                        return
                    }
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text(L10n.profile).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button {
                if isEditing { Task { await saveProfile() } } else { isEditing = true }
            } label: {
                if isSaving {
                    ProgressView().tint(.plagitTeal)
                } else {
                    Text(isEditing ? L10n.save : L10n.edit).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Hero

    private func heroCard(_ p: CandidateProfileDTO) -> some View {
        VStack(spacing: PlagitSpacing.xl) {
            HStack(alignment: .top, spacing: PlagitSpacing.lg) {
                // Avatar with photo picker
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        ProfileAvatarView(photoUrl: p.photoUrl, initials: p.initials, hue: p.avatarHue, size: 72, verified: p.isVerified, countryCode: AppLocaleManager.shared.countryCode)

                        if isUploadingPhoto {
                            Circle().fill(.black.opacity(0.4)).frame(width: 72, height: 72)
                            ProgressView().tint(.white)
                        } else {
                            ZStack {
                                Circle().fill(Color.plagitTeal).frame(width: 24, height: 24)
                                Image(systemName: "camera.fill").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                            }.offset(x: 4, y: 4)
                        }
                    }
                }
                .onChange(of: selectedPhoto) { _, item in
                    guard let item else { return }
                    Task { await handlePhotoSelection(item) }
                }
                .contextMenu {
                    if p.photoUrl != nil && !p.photoUrl!.isEmpty {
                        Button(role: .destructive) { Task { await removePhoto() } } label: {
                            Label(L10n.removePhoto, systemImage: "trash")
                        }
                    }
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(p.name).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                        if sub.isCandidatePremium {
                            HStack(spacing: 3) {
                                Image(systemName: "crown.fill").font(.system(size: 9, weight: .bold))
                                Text("PRO").font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().fill(LinearGradient(colors: [Color.plagitAmber, Color.plagitAmber.opacity(0.8)], startPoint: .leading, endPoint: .trailing)))
                        }
                    }
                    if let role = p.role, !role.isEmpty {
                        // Show resolved name if it's a catalog ID, otherwise show raw value
                        let displayRole = HospitalityCatalog.role(id: role)?.name ?? role
                        Text(displayRole).font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                    }
                    if let loc = p.location, !loc.isEmpty {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "mappin").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal)
                            Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitTeal)
                        }
                    }
                }
                Spacer()
            }

            HStack(spacing: PlagitSpacing.md) {
                if sub.isCandidatePremium { badge("Premium", .plagitAmber) }
                if p.isVerified { badge(L10n.verified, .plagitVerified) }
                badge(L10n.verificationStatus(p.verificationStatus), p.verificationStatus == "verified" ? .plagitOnline : .plagitAmber)
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func badge(_ text: String, _ color: Color) -> some View {
        Text(text).font(PlagitFont.micro()).foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    // MARK: - Profile Strength

    private func profileStrengthCard(_ p: CandidateProfileDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack {
                Text(L10n.profileStrength).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                Spacer()
                Text("\(p.profileStrength)%").font(PlagitFont.bodyMedium()).foregroundColor(.plagitTeal)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.plagitSurface).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(Color.plagitTeal).frame(width: geo.size.width * Double(p.profileStrength) / 100.0, height: 6)
                }
            }.frame(height: 6)

            // CV Upload option when profile is incomplete
            if p.profileStrength < 100 {
                Button { showCVPicker = true } label: {
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.plagitTeal)
                        if isParsingCV {
                            Text("Reading Your CV...").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                            ProgressView().tint(.plagitTeal).scaleEffect(0.8)
                        } else {
                            Text("Upload CV").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                        }
                        Spacer()
                        if !isParsingCV {
                            Text("Auto-fill your profile").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.lg)
                    .padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitTealLight))
                    .overlay(RoundedRectangle(cornerRadius: PlagitRadius.md).stroke(Color.plagitTeal.opacity(0.2), lineWidth: 1))
                }
                .disabled(isParsingCV)

                if let err = cvError {
                    Text(err).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Subscription Card

    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            if sub.isCandidatePremium {
                // Active premium
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.plagitAmber.opacity(0.2), Color.plagitAmber.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                        Image(systemName: "crown.fill").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitAmber)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.t("current_plan")).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                        Text(sub.currentPlan.displayName).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    }

                    Spacer()

                    Text(sub.currentPlan == .candidateAnnual ? L10n.t("annual_plan") : L10n.t("monthly_plan"))
                        .font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Capsule().fill(Color.plagitAmber.opacity(0.1)))
                }

                if let exp = sub.expiryDate {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "calendar").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary)
                        Text("\(L10n.t("renews_on")) \(exp.formatted(date: .abbreviated, time: .omitted))")
                            .font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                    }
                }

                Divider().padding(.vertical, PlagitSpacing.xs)

                Button { showSubscription = true } label: {
                    HStack {
                        Image(systemName: "gearshape").font(.system(size: 13, weight: .medium))
                        Text(L10n.t("manage_subscription"))
                    }
                    .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.sm)
                }
            } else {
                // Free plan — upsell
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        Circle().fill(Color.plagitSurface).frame(width: 40, height: 40)
                        Image(systemName: "crown").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitTertiary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.t("current_plan")).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                        Text(L10n.t("free_plan")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    }

                    Spacer()
                }

                Button { showSubscription = true } label: {
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "crown.fill").font(.system(size: 12, weight: .medium))
                        Text(L10n.t("unlock_candidate_premium"))
                    }
                    .font(PlagitFont.captionMedium()).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .leading, endPoint: .trailing)))
                }

                Button {
                    Task { await sub.restorePurchases() }
                } label: {
                    HStack(spacing: PlagitSpacing.sm) {
                        if sub.restoreInProgress {
                            ProgressView().tint(.plagitTeal).controlSize(.small)
                        }
                        Text(L10n.t("restore_purchases")).font(PlagitFont.caption()).foregroundColor(.plagitTeal)
                    }
                }
                .disabled(sub.restoreInProgress)
                .frame(maxWidth: .infinity)

                if let result = sub.restoreResult {
                    switch result {
                    case .success:
                        Text(L10n.t("restore_success")).font(PlagitFont.caption()).foregroundColor(.plagitOnline)
                    case .nothingToRestore:
                        Text(L10n.t("restore_nothing")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    case .error(let msg):
                        Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
                    }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Detail Sections

    private func detailSections(_ p: CandidateProfileDTO) -> some View {
        VStack(spacing: PlagitSpacing.sectionGap) {
            infoCard(L10n.details, [
                ("mappin", L10n.basedIn, p.location ?? L10n.notSet),
                ("clock", L10n.experience, p.experience ?? L10n.notSet),
                ("globe", L10n.languages, Language.profileLabel(from: p.languages).isEmpty ? (p.languages ?? L10n.notSet) : Language.profileLabel(from: p.languages)),
                ("checkmark.shield", L10n.verification, L10n.verificationStatus(p.verificationStatus)),
            ])

            infoCard(L10n.contact, [
                ("envelope", L10n.email, p.email),
                ("phone", L10n.phone, p.phone ?? L10n.notSet),
            ])
        }
    }

    private func infoCard(_ title: String, _ rows: [(String, String, String)]) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(title).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            ForEach(rows, id: \.1) { icon, label, value in
                HStack(spacing: PlagitSpacing.md) {
                    Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        Text(value).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    }
                    Spacer()
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Edit Form

    private var editForm: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.editProfile).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            editField(L10n.name, text: $editName)
            editField(L10n.phone, text: $editPhone, keyboard: .phonePad)
            editField(L10n.location, text: $editLocation)

            // Category & Role picker
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text("Category & Role").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                HospitalityCategoryButton(
                    categoryId: hCategoryId,
                    subcategoryId: hSubcategoryId,
                    roleId: hRoleId
                ) { showCategoryPicker = true }
            }

            editField(L10n.experience, text: $editExperience)
            Button { showCandLanguagePicker = true } label: {
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(L10n.languages).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Text(editLanguages.isEmpty ? L10n.selectLanguages : Language.displayLabel(from: editLanguages))
                        .font(PlagitFont.body()).foregroundColor(editLanguages.isEmpty ? .plagitTertiary : .plagitCharcoal).lineLimit(2)
                }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
            }

            Toggle(isOn: $editAvailableToRelocate) {
                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "globe.americas.fill").font(.system(size: 12)).foregroundColor(.plagitIndigo)
                    Text("Open to Relocation / Travel").font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                }
            }.tint(.plagitIndigo)

            if let err = saveError {
                Text(err).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
            }

            Button { isEditing = false; populateEditFields() } label: {
                Text(L10n.cancel).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func editField(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            TextField(label, text: text)
                .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                .keyboardType(keyboard)
                .padding(PlagitSpacing.md)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
        }
    }

    // MARK: - Logout

    private var logoutSection: some View {
        Button {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                CandidateAuthService.shared.logout()
            }
        } label: {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 14, weight: .medium))
                Text(L10n.signOut)
            }
            .font(PlagitFont.bodyMedium()).foregroundColor(.plagitUrgent)
            .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitUrgent.opacity(0.06)))
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Save

    @MainActor
    private func handlePhotoSelection(_ item: PhotosPickerItem) async {
        isUploadingPhoto = true
        saveError = nil
        do {
            // Load image data from picker
            guard let data = try await item.loadTransferable(type: Data.self) else {
                saveError = L10n.t("err_load_image")
                isUploadingPhoto = false
                return
            }

            // Convert to UIImage, then compress to JPEG
            guard let uiImage = UIImage(data: data) else {
                saveError = L10n.t("err_invalid_image")
                isUploadingPhoto = false
                return
            }

            // Try compression levels until under 1MB base64
            var quality: CGFloat = 0.5
            var jpeg = uiImage.jpegData(compressionQuality: quality)
            while let j = jpeg, j.count > 750_000, quality > 0.1 {
                quality -= 0.1
                jpeg = uiImage.jpegData(compressionQuality: quality)
            }

            guard let finalJpeg = jpeg else {
                saveError = L10n.t("err_compress_image")
                isUploadingPhoto = false
                return
            }

            let base64 = "data:image/jpeg;base64," + finalJpeg.base64EncodedString()

            // Upload to backend
            _ = try await CandidateAPIService.shared.uploadPhoto(base64Data: base64)

            // Reload profile to get fresh photo_url from server
            profile = try await CandidateAPIService.shared.fetchProfile()
        } catch {
            saveError = L10n.t("err_photo_upload")
        }
        isUploadingPhoto = false
        selectedPhoto = nil
    }

    @MainActor
    private func removePhoto() async {
        isUploadingPhoto = true
        do {
            _ = try await CandidateAPIService.shared.uploadPhoto(base64Data: "")
            profile = try await CandidateAPIService.shared.fetchProfile()
        } catch { saveError = L10n.t("err_remove_photo") }
        isUploadingPhoto = false
    }

    // MARK: - CV Parse

    private func parseCVFromProfile(data: Data, fileName: String) async {
        isParsingCV = true
        cvError = nil
        do {
            let mimePrefix: String
            if fileName.lowercased().hasSuffix(".pdf") { mimePrefix = "data:application/pdf;base64," }
            else if fileName.lowercased().hasSuffix(".docx") { mimePrefix = "data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64," }
            else { mimePrefix = "data:application/octet-stream;base64," }
            let base64 = mimePrefix + data.base64EncodedString()

            let result = try await CandidateAPIService.shared.parseCV(base64Data: base64, fileName: fileName)

            if let error = result.parseError, !error.isEmpty {
                cvError = error
            }

            if let extracted = result.extracted,
               (extracted.firstName != nil || extracted.role != nil || extracted.location != nil) {
                cvExtractedData = extracted
            } else if cvError == nil {
                cvError = "We couldn't read your CV. Please try again or edit your profile manually."
            }
        } catch {
            cvError = "We couldn't read your CV. Please try again or edit your profile manually."
        }
        isParsingCV = false
    }

    private func saveProfile() async {
        isSaving = true; saveError = nil
        do {
            profile = try await CandidateAPIService.shared.updateProfile(
                name: editName.isEmpty ? nil : editName,
                phone: editPhone.isEmpty ? nil : editPhone,
                location: editLocation.isEmpty ? nil : editLocation,
                role: !hRoleId.isEmpty ? hRoleId : (editRole.isEmpty ? nil : editRole),
                experience: editExperience.isEmpty ? nil : editExperience,
                languages: editLanguages.isEmpty ? nil : editLanguages,
                availableToRelocate: editAvailableToRelocate
            )
            isEditing = false
        } catch { saveError = L10n.apiError(error.localizedDescription) }
        isSaving = false
    }
}
