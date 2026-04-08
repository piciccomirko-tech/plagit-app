//
//  BusinessRealProfileView.swift
//  Plagit
//
//  Real business profile backed by GET/PUT /business/profile.
//

import SwiftUI
import PhotosUI

struct BusinessRealProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var profile: BusinessProfileDTO?
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var isEditing = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isUploadingPhoto = false
    @State private var editCompany = ""
    @State private var editVenue = ""
    @State private var editLocation = ""
    @State private var editPhone = ""
    @State private var editLanguages = ""
    @State private var selectedBizLanguages: Set<String> = []
    @State private var showBizLanguagePicker = false
    @State private var isSaving = false
    @State private var saveError: String?

    // 3-level hospitality picker state
    @State private var hCategoryId = ""
    @State private var hSubcategoryId = ""
    @State private var hRoleId = ""
    @State private var showCategoryPicker = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if isLoading { Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer(); VStack(spacing: PlagitSpacing.md) { Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary); Button { Task { await load() } } label: { Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) } }.padding(PlagitSpacing.xxl); Spacer()
                } else if let p = profile {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.sectionGap) {
                            heroCard(p)
                            if isEditing { editForm } else { detailSections(p) }
                            logoutButton
                            Spacer().frame(height: PlagitSpacing.xxxl)
                        }.padding(.top, PlagitSpacing.xs)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showBizLanguagePicker) {
            LanguagePickerView(selected: $selectedBizLanguages) {
                editLanguages = Language.storageString(from: selectedBizLanguages)
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            HospitalityCategoryPicker(
                selectedCategoryId: $hCategoryId,
                selectedSubcategoryId: $hSubcategoryId,
                selectedRoleId: $hRoleId
            )
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do { profile = try await BusinessAPIService.shared.fetchProfile(); populateEdit() } catch { loadError = error.localizedDescription }
        isLoading = false
    }
    private func populateEdit() {
        guard let p = profile else { return }
        editCompany = p.companyName; editVenue = p.venueType ?? ""; editLocation = p.businessLocation ?? ""; editPhone = p.phone ?? ""
        editLanguages = p.languages ?? ""
        selectedBizLanguages = Language.parseCodes(from: p.languages)
        // Parse venueType "categoryId:subcategoryId" format
        let parts = (p.venueType ?? "").split(separator: ":").map(String.init)
        hCategoryId = parts.count > 0 ? parts[0] : ""
        hSubcategoryId = parts.count > 1 ? parts[1] : ""
        // roleId is not stored in venueType — keep whatever was selected
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text(L10n.companyProfile).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
            Button { if isEditing { Task { await save() } } else { isEditing = true } } label: {
                if isSaving { ProgressView().tint(.plagitTeal) } else { Text(isEditing ? L10n.save : L10n.edit).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private func heroCard(_ p: BusinessProfileDTO) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.lg) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        ProfileAvatarView(photoUrl: p.photoUrl, initials: p.companyInitials, hue: p.avatarHue, size: 72, verified: p.isVerified, countryCode: p.countryCode)
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
                    if p.photoUrl != nil && !(p.photoUrl?.isEmpty ?? true) {
                        Button(role: .destructive) { Task { await removePhoto() } } label: { Label(L10n.removePhoto, systemImage: "trash") }
                    }
                }
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(p.companyName).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                        if p.isVerified { Image(systemName: "checkmark.seal.fill").font(.system(size: 12)).foregroundColor(.plagitVerified) }
                    }
                    if let vt = p.venueType, !vt.isEmpty {
                        let catId = vt.split(separator: ":").first.map(String.init)
                        Text(HospitalityCatalog.category(id: catId ?? "")?.name ?? vt)
                            .font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                    }
                    if let loc = p.businessLocation { HStack(spacing: PlagitSpacing.xs) { Image(systemName: "mappin").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal); Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitTeal) } }
                }; Spacer()
            }
            HStack(spacing: PlagitSpacing.md) {
                if p.isFeatured { badge(L10n.featured, .plagitAmber) }
                badge(p.status.capitalized, p.status == "active" ? .plagitOnline : .plagitTertiary)
            }
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func badge(_ text: String, _ color: Color) -> some View {
        Text(text).font(PlagitFont.micro()).foregroundColor(color).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3).background(Capsule().fill(color.opacity(0.08)))
    }

    private func detailSections(_ p: BusinessProfileDTO) -> some View {
        let countryLabel = CountryFlag.label(country: p.country, code: p.countryCode)
        let langLabel = Language.profileLabel(from: p.languages)

        // Resolve venueType from "categoryId:subcategoryId" to display path
        let venueParts = (p.venueType ?? "").split(separator: ":").map(String.init)
        let venueDisplay: String = {
            if venueParts.count >= 2 {
                return HospitalityCatalog.displayPath(categoryId: venueParts[0], subcategoryId: venueParts[1], roleId: nil)
            } else if let vt = p.venueType, !vt.isEmpty {
                // Legacy or plain-text value
                return HospitalityCatalog.category(id: vt)?.name ?? vt
            }
            return L10n.notSet
        }()

        return VStack(spacing: PlagitSpacing.sectionGap) {
            infoCard(L10n.businessDetails, [
                ("building.2", L10n.businessName, p.companyName),
                ("briefcase", "Category", venueDisplay),
                ("mappin", L10n.location, p.businessLocation ?? L10n.notSet),
                ("flag", L10n.country, countryLabel.isEmpty ? L10n.notSet : countryLabel),
                ("globe", L10n.languages, langLabel.isEmpty ? L10n.notSet : langLabel),
                ("checkmark.shield", L10n.verification, p.isVerified ? L10n.verified : L10n.pending),
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
                    VStack(alignment: .leading, spacing: 2) { Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary); Text(value).font(PlagitFont.body()).foregroundColor(.plagitCharcoal) }; Spacer()
                }
            }
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private var editForm: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.editProfile).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            editField(L10n.companyName, text: $editCompany)

            // Category & Role picker
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text("Category & Role").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                HospitalityCategoryButton(
                    categoryId: hCategoryId,
                    subcategoryId: hSubcategoryId,
                    roleId: hRoleId
                ) { showCategoryPicker = true }
            }

            editField(L10n.location, text: $editLocation)
            editField(L10n.phone, text: $editPhone, keyboard: .phonePad)
            // Languages picker
            Button { showBizLanguagePicker = true } label: {
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(L10n.languagesSpoken).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Text(editLanguages.isEmpty ? L10n.selectLanguages : Language.displayLabel(from: editLanguages))
                        .font(PlagitFont.body()).foregroundColor(editLanguages.isEmpty ? .plagitTertiary : .plagitCharcoal).lineLimit(2)
                }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
            }
            if let err = saveError { Text(err).font(PlagitFont.caption()).foregroundColor(.plagitUrgent) }
            Button { isEditing = false; populateEdit() } label: {
                Text(L10n.cancel).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
            }
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func editField(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            TextField(label, text: text).font(PlagitFont.body()).foregroundColor(.plagitCharcoal).keyboardType(keyboard)
                .padding(PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
        }
    }

    private var logoutButton: some View {
        Button { dismiss(); DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { BusinessAuthService.shared.logout() } } label: {
            HStack(spacing: PlagitSpacing.sm) { Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 14, weight: .medium)); Text(L10n.signOut) }
                .font(PlagitFont.bodyMedium()).foregroundColor(.plagitUrgent).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitUrgent.opacity(0.06)))
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    @MainActor
    private func handlePhotoSelection(_ item: PhotosPickerItem) async {
        isUploadingPhoto = true
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { isUploadingPhoto = false; return }
            var quality: CGFloat = 0.5
            var jpeg = uiImage.jpegData(compressionQuality: quality)
            while let j = jpeg, j.count > 750_000, quality > 0.1 { quality -= 0.1; jpeg = uiImage.jpegData(compressionQuality: quality) }
            guard let finalJpeg = jpeg else { isUploadingPhoto = false; return }
            let base64 = "data:image/jpeg;base64," + finalJpeg.base64EncodedString()
            _ = try await BusinessAPIService.shared.uploadPhoto(base64Data: base64)
            profile = try await BusinessAPIService.shared.fetchProfile()
        } catch { saveError = "Photo upload failed." }
        isUploadingPhoto = false; selectedPhoto = nil
    }

    @MainActor
    private func removePhoto() async {
        isUploadingPhoto = true
        do {
            _ = try await BusinessAPIService.shared.uploadPhoto(base64Data: "")
            profile = try await BusinessAPIService.shared.fetchProfile()
        } catch { saveError = "Could not remove photo." }
        isUploadingPhoto = false
    }

    private func save() async {
        isSaving = true; saveError = nil
        // Build venueType from category picker: "categoryId:subcategoryId"
        let resolvedVenue: String? = {
            if !hCategoryId.isEmpty {
                var v = hCategoryId
                if !hSubcategoryId.isEmpty { v += ":\(hSubcategoryId)" }
                return v
            }
            return editVenue.isEmpty ? nil : editVenue
        }()
        do {
            profile = try await BusinessAPIService.shared.updateProfile(
                companyName: editCompany.isEmpty ? nil : editCompany, venueType: resolvedVenue,
                location: editLocation.isEmpty ? nil : editLocation, phone: editPhone.isEmpty ? nil : editPhone,
                languages: editLanguages.isEmpty ? nil : editLanguages)
            isEditing = false
        } catch { saveError = error.localizedDescription }
        isSaving = false
    }
}
