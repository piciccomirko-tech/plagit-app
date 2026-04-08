//
//  ServiceCompanyProfileView.swift
//  Plagit
//
//  Detail view for a hospitality service provider.
//

import SwiftUI

struct ServiceCompanyProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let company: ServiceCompany

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        heroCard
                        aboutCard
                        detailsCard
                        contactCard
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                    .padding(.top, PlagitSpacing.xs)
                }
            }
        }
        .navigationBarHidden(true)
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
            Text("Company Profile")
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        VStack(spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.lg) {
                // Avatar
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.xl)
                        .fill(Color(hue: company.avatarHue, saturation: 0.15, brightness: 0.95))
                        .frame(width: 64, height: 64)
                    Text(company.initials)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hue: company.avatarHue, saturation: 0.6, brightness: 0.5))
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(company.name)
                            .font(PlagitFont.headline())
                            .foregroundColor(.plagitCharcoal)
                        if company.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.plagitVerified)
                        }
                    }
                    Text(company.subcategoryName)
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitTeal)
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.plagitTeal)
                        Text(company.location)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)
                    }
                }
                Spacer()
            }

            // Rating bar
            if let rating = company.rating {
                HStack(spacing: PlagitSpacing.lg) {
                    HStack(spacing: PlagitSpacing.xs) {
                        ForEach(0..<5) { i in
                            Image(systemName: Double(i) + 0.5 < rating ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(.plagitAmber)
                        }
                        Text(String(format: "%.1f", rating))
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.plagitCharcoal)
                    }
                    Text("\(company.reviewCount) reviews")
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitTertiary)
                    Spacer()
                    if !company.categoryName.isEmpty {
                        Text(company.categoryName)
                            .font(PlagitFont.micro())
                            .foregroundColor(.plagitAmber)
                            .padding(.horizontal, PlagitSpacing.sm)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.plagitAmber.opacity(0.1)))
                    }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - About

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Text("About")
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitSecondary)
            Text(company.description)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Details")
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitSecondary)

            detailRow(icon: "briefcase", label: "Category", value: company.categoryName)
            detailRow(icon: "tag", label: "Specialty", value: company.subcategoryName)
            detailRow(icon: "mappin", label: "Location", value: company.location)
            detailRow(icon: "checkmark.shield", label: "Verified", value: company.isVerified ? "Yes" : "Pending")
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTeal)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(PlagitFont.micro())
                    .foregroundColor(.plagitTertiary)
                Text(value)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitCharcoal)
            }
            Spacer()
        }
    }

    // MARK: - Contact

    private var contactCard: some View {
        VStack(spacing: PlagitSpacing.md) {
            Button {
                // TODO: implement messaging / contact flow
            } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 14, weight: .medium))
                    Text("Contact Company")
                }
                .font(PlagitFont.bodyMedium())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, PlagitSpacing.lg)
                .background(
                    Capsule().fill(
                        LinearGradient(colors: [Color.plagitAmber, Color.plagitAmber.opacity(0.85)], startPoint: .leading, endPoint: .trailing)
                    )
                )
            }

            Button {
                // TODO: implement phone call
            } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14, weight: .medium))
                    Text("Call")
                }
                .font(PlagitFont.bodyMedium())
                .foregroundColor(.plagitAmber)
                .frame(maxWidth: .infinity)
                .padding(.vertical, PlagitSpacing.lg)
                .background(
                    Capsule()
                        .fill(Color.plagitAmber.opacity(0.08))
                        .overlay(Capsule().stroke(Color.plagitAmber.opacity(0.3), lineWidth: 1))
                )
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }
}
