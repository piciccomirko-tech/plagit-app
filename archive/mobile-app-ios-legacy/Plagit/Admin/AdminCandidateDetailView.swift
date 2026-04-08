//
//  AdminCandidateDetailView.swift
//  Plagit
//
//  Premium Admin Candidate Detail / Review Screen — Fully Functional
//

import SwiftUI

struct AdminCandidateDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var candidateStatus = "Verified"  // "Verified", "Pending Review", "Suspended", "New"
    @State private var showAddNoteSheet = false
    @State private var showSuspendAlert = false
    @State private var showApplications = false
    @State private var showDocumentDetail = false
    @State private var selectedDocIndex = 0
    @State private var savedNotes: [(text: String, date: String)] = []

    // Document statuses (mutable for approve/reject)
    @State private var documents: [(name: String, icon: String, status: String)] = [
        ("ID / Passport", "person.text.rectangle", "Verified"),
        ("Visa / Work Permit", "doc.viewfinder", "Verified"),
        ("CV / Resume", "doc.fill", "Verified"),
        ("Certificates", "scroll", "Pending"),
        ("Right to Work", "checkmark.shield", "Missing")
    ]

    private var missingDocCount: Int {
        documents.filter { $0.status == "Missing" || $0.status == "Pending" }.count
    }

    private var profileCompletion: Double {
        let verified = documents.filter { $0.status == "Verified" }.count
        return Double(verified) / Double(documents.count)
    }

    private var completionHint: String {
        let missing = documents.filter { $0.status == "Missing" }.count
        let pending = documents.filter { $0.status == "Pending" }.count
        if missing == 0 && pending == 0 { return "Profile complete" }
        if missing > 0 { return "\(missing) document missing" }
        return "\(pending) document pending"
    }

    var body: some View {
        ZStack {
            Color.plagitBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Fixed top bar (outside scroll)
                topBar
                    .background(Color.plagitBackground)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        candidateSummaryCard
                            .padding(.top, PlagitSpacing.xs)

                    profileInfoCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    workHistoryCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    documentsCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    cvCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    platformActivityCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    flagsCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    adminActionsCard
                        .padding(.top, PlagitSpacing.sectionGap)

                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showApplications) {
            AdminCandidateApplicationsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showDocumentDetail) {
            AdminDocumentDetailView(
                documentName: documents[selectedDocIndex].name,
                documentIcon: documents[selectedDocIndex].icon,
                documentStatus: Binding(
                    get: { documents[selectedDocIndex].status },
                    set: { documents[selectedDocIndex].status = $0 }
                )
            ).navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddNoteSheet) {
            AddNoteSheetView(savedNotes: $savedNotes, isPresented: $showAddNoteSheet)
        }
        .alert("Suspend Account", isPresented: $showSuspendAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Suspend", role: .destructive) {
                withAnimation { candidateStatus = "Suspended" }
            }
        } message: {
            Text("Are you sure you want to suspend Elena Rossi? They will lose access to the platform until reactivated.")
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

            Text("Candidate Detail")
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)

            Spacer()

            Button { } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.plagitCharcoal)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Candidate Summary

    private var candidateSummaryCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xl) {
            HStack(alignment: .top) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: 0.52, saturation: 0.45, brightness: 0.90),
                                    Color(hue: 0.52, saturation: 0.55, brightness: 0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .overlay(
                            Text("ER")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )

                    if candidateStatus == "Verified" {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.plagitVerified)
                            .background(Circle().fill(.white).frame(width: 14, height: 14))
                            .offset(x: 2, y: 2)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: PlagitSpacing.sm) {
                    statusPill(candidateStatus, color: statusColor(candidateStatus))
                    accountPill(candidateStatus == "Suspended" ? "Suspended" : "Active")
                }
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Elena Rossi")
                    .font(PlagitFont.displayMedium())
                    .foregroundColor(.plagitCharcoal)

                HStack(spacing: PlagitSpacing.sm) {
                    Text("Executive Chef")
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitSecondary)

                    Text("Full-time")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)
                        .padding(.horizontal, PlagitSpacing.sm)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.plagitTealLight))
                }

                HStack(spacing: PlagitSpacing.lg) {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "mappin")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.plagitTertiary)
                        Text("Milan, Italy")
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitTertiary)
                    }

                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "clock")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.plagitTertiary)
                        Text("15 years experience")
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitTertiary)
                    }
                }

                // Profile completion with hint
                HStack(spacing: PlagitSpacing.sm) {
                    ProgressView(value: profileCompletion)
                        .tint(missingDocCount == 0 ? Color.plagitTeal : Color.plagitAmber)
                        .frame(width: 80)

                    Text("\(Int(profileCompletion * 100))% complete")
                        .font(PlagitFont.micro())
                        .foregroundColor(missingDocCount == 0 ? .plagitTeal : .plagitAmber)

                    Text("·")
                        .foregroundColor(.plagitTertiary)

                    Text(completionHint)
                        .font(PlagitFont.micro())
                        .foregroundColor(missingDocCount == 0 ? .plagitOnline : .plagitAmber)
                }
                .padding(.top, PlagitSpacing.xs)
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

    // MARK: - Profile Info

    private var profileInfoCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Profile Information")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            VStack(spacing: 0) {
                infoRow(icon: "globe", label: "Languages", value: "Italian, English, French")
                divider
                infoRow(icon: "calendar", label: "Availability", value: "Available immediately")
                divider
                infoRow(icon: "clock", label: "Shift Preference", value: "Flexible")
                divider
                infoRow(icon: "briefcase", label: "Experience", value: "15 years — Fine Dining")
            }
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md)
                    .fill(Color.plagitSurface)
            )

            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("About")
                    .font(PlagitFont.bodyMedium())
                    .foregroundColor(.plagitCharcoal)

                Text("Passionate Executive Chef with 15 years of experience in Michelin-starred fine dining. Specialized in Italian and fusion cuisine with a focus on seasonal ingredients. Open to international relocation.")
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitSecondary)
                    .lineSpacing(4)
            }
            .padding(.top, PlagitSpacing.sm)
        }
        .padding(PlagitSpacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Work History

    private var workHistoryCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Work History")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            VStack(spacing: 0) {
                workRow(title: "Executive Chef", company: "The Dorchester", location: "London, UK", period: "2020 – Present")
                divider
                workRow(title: "Head Chef", company: "Ristorante Cracco", location: "Milan, IT", period: "2016 – 2020")
                divider
                workRow(title: "Sous Chef", company: "Four Seasons Hotel", location: "Florence, IT", period: "2012 – 2016")
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

    private func workRow(title: String, company: String, location: String, period: String) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
            Text(title)
                .font(PlagitFont.bodyMedium())
                .foregroundColor(.plagitCharcoal)

            HStack(spacing: PlagitSpacing.xs) {
                Text(company)
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)

                Text("·")
                    .foregroundColor(.plagitTertiary)

                Text(location)
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)
            }

            Text(period)
                .font(PlagitFont.micro())
                .foregroundColor(.plagitTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.md)
    }

    // MARK: - Documents

    private var documentsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Documents")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            VStack(spacing: 0) {
                ForEach(Array(documents.enumerated()), id: \.offset) { index, doc in
                    documentRow(index: index, name: doc.name, icon: doc.icon, status: doc.status)

                    if index < documents.count - 1 {
                        Rectangle().fill(Color.plagitDivider).frame(height: 1)
                    }
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

    private func documentRow(index: Int, name: String, icon: String, status: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTeal)
                .frame(width: 20)

            Text(name)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)

            Spacer()

            docStatusBadge(status)

            if status != "Missing" {
                Button {
                    selectedDocIndex = index
                    showDocumentDetail = true
                } label: {
                    Text("View")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.md + 2)
    }

    private func docStatusBadge(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "Verified": return .plagitOnline
            case "Pending": return .plagitAmber
            case "Missing": return .plagitUrgent
            default: return .plagitTertiary
            }
        }()

        return Text(status)
            .font(PlagitFont.micro())
            .foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm)
            .padding(.vertical, 2)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    // MARK: - CV

    private var cvCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("CV / Resume")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.plagitTeal)
                    .frame(width: 34, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: PlagitRadius.md)
                            .fill(Color.plagitTealLight)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Elena_Rossi_CV.pdf")
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)

                    Text("Updated 1 week ago · 2.4 MB")
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitSecondary)
                }

                Spacer()

                Button {} label: {
                    Text("Review CV")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitTeal)
                        .padding(.horizontal, PlagitSpacing.md)
                        .padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(Color.plagitTealLight))
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

    // MARK: - Platform Activity

    private var platformActivityCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Platform Activity")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: PlagitSpacing.md),
                GridItem(.flexible(), spacing: PlagitSpacing.md),
                GridItem(.flexible(), spacing: PlagitSpacing.md)
            ], spacing: PlagitSpacing.md) {
                activityStat(number: "5", label: "Applications", icon: "doc.text", color: .plagitTeal)
                activityStat(number: "2", label: "Interviews", icon: "calendar", color: .plagitIndigo)
                activityStat(number: "8", label: "Messages", icon: "bubble.left", color: .plagitAmber)
            }

            VStack(spacing: 0) {
                infoRow(icon: "clock", label: "Last Active", value: "2 hours ago")
                divider
                infoRow(icon: "person.badge.plus", label: "Joined", value: "Mar 15, 2025")
                divider
                infoRow(icon: "eye", label: "Profile Views", value: "142 this month")
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

    private func activityStat(number: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: PlagitSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color)

            Text(number)
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            Text(label)
                .font(PlagitFont.micro())
                .foregroundColor(.plagitSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PlagitSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.md)
                .fill(Color.plagitSurface)
        )
    }

    // MARK: - Flags / Notes (functional)

    private var flagsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Admin Notes & Flags")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            // Status row
            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: savedNotes.isEmpty ? "shield.checkered" : "note.text")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(savedNotes.isEmpty ? .plagitOnline : .plagitAmber)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: PlagitRadius.sm)
                            .fill((savedNotes.isEmpty ? Color.plagitOnline : Color.plagitAmber).opacity(0.10))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(savedNotes.isEmpty ? "No active flags" : "\(savedNotes.count) admin note\(savedNotes.count > 1 ? "s" : "")")
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)

                    Text(savedNotes.isEmpty ? "This account has no warnings or moderation notes" : "Last note added recently")
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitSecondary)
                }

                Spacer()
            }

            // Saved notes
            if !savedNotes.isEmpty {
                VStack(spacing: PlagitSpacing.sm) {
                    ForEach(Array(savedNotes.enumerated()), id: \.offset) { _, note in
                        HStack(alignment: .top, spacing: PlagitSpacing.md) {
                            Circle()
                                .fill(Color.plagitAmber)
                                .frame(width: 6, height: 6)
                                .padding(.top, 7)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.text)
                                    .font(PlagitFont.caption())
                                    .foregroundColor(.plagitSecondary)

                                Text("Added \(note.date) by Admin")
                                    .font(PlagitFont.micro())
                                    .foregroundColor(.plagitTertiary)
                            }
                        }
                    }
                }
            }

            // Verification history
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Verification History")
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitCharcoal)

                HStack(alignment: .top, spacing: PlagitSpacing.md) {
                    Circle()
                        .fill(Color.plagitOnline)
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Identity verified — Mar 20, 2025")
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)

                        Text("Verified by Admin (auto-review)")
                            .font(PlagitFont.micro())
                            .foregroundColor(.plagitTertiary)
                    }
                }
            }
            .padding(.top, PlagitSpacing.sm)
        }
        .padding(PlagitSpacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Admin Actions (status-aware)

    private var adminActionsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Admin Actions")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            VStack(spacing: PlagitSpacing.md) {
                // Primary row — status-dependent
                HStack(spacing: PlagitSpacing.md) {
                    if candidateStatus == "Pending Review" || candidateStatus == "New" {
                        Button { withAnimation { candidateStatus = "Verified" } } label: {
                            actionLabel(icon: "checkmark.seal", text: "Verify", fg: .white, bg: Color.plagitTeal)
                        }
                    }

                    if candidateStatus == "Suspended" {
                        Button { withAnimation { candidateStatus = "Verified" } } label: {
                            actionLabel(icon: "arrow.counterclockwise", text: "Reactivate", fg: .white, bg: Color.plagitOnline)
                        }
                    }

                    if candidateStatus == "Verified" || candidateStatus == "Pending Review" || candidateStatus == "New" {
                        Button { showSuspendAlert = true } label: {
                            actionLabel(icon: "xmark.circle", text: "Suspend", fg: .plagitUrgent, bg: Color.plagitUrgent.opacity(0.08))
                        }
                    }
                }

                // Secondary row — always visible
                HStack(spacing: PlagitSpacing.md) {
                    Button { showAddNoteSheet = true } label: {
                        actionLabel(icon: "note.text", text: "Add Note", fg: .plagitTeal, bg: Color.plagitTealLight)
                    }

                    Button { showApplications = true } label: {
                        actionLabel(icon: "doc.text", text: "View Applications", fg: .plagitTeal, bg: Color.plagitTealLight)
                    }
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

    private func actionLabel(icon: String, text: String, fg: Color, bg: some ShapeStyle) -> some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
            Text(text)
                .font(PlagitFont.captionMedium())
        }
        .foregroundColor(fg)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Capsule().fill(bg))
    }

    // MARK: - Add Note Sheet

    // MARK: - Helpers

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Verified": return .plagitOnline
        case "Pending Review": return .plagitAmber
        case "Suspended": return .plagitUrgent
        case "New": return .plagitTeal
        default: return .plagitTertiary
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
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
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitCharcoal)
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.md + 2)
    }

    private func statusPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(PlagitFont.micro())
            .foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    private func accountPill(_ text: String) -> some View {
        let color: Color = text == "Suspended" ? .plagitUrgent : .plagitTeal
        return Text(text)
            .font(PlagitFont.micro())
            .foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    private var divider: some View {
        Rectangle().fill(Color.plagitDivider).frame(height: 1)
    }
}

// MARK: - Admin Candidate Applications (rich)

private struct CandidateApp: Identifiable {
    let id = UUID()
    let role: String
    let company: String
    let location: String
    let employmentType: String
    let salary: String
    let appliedDate: String
    let lastUpdated: String
    let status: String
}

struct AdminCandidateApplicationsView: View {
    @Environment(\.dismiss) private var dismiss

    private let apps: [CandidateApp] = [
        CandidateApp(role: "Senior Chef", company: "Nobu Restaurant", location: "Dubai, UAE", employmentType: "Full-time", salary: "$5,500/mo", appliedDate: "Mar 22", lastUpdated: "Updated 1h ago", status: "Interviewing"),
        CandidateApp(role: "Head Chef", company: "The Ritz London", location: "London, UK", employmentType: "Full-time", salary: "£45–55k", appliedDate: "Mar 20", lastUpdated: "Updated yesterday", status: "In Review"),
        CandidateApp(role: "Sous Chef", company: "Four Seasons", location: "Paris, FR", employmentType: "Full-time", salary: "€3,800/mo", appliedDate: "Mar 15", lastUpdated: "Updated 3d ago", status: "Applied"),
        CandidateApp(role: "Executive Chef", company: "The Dorchester", location: "London, UK", employmentType: "Full-time", salary: "£60–70k", appliedDate: "Mar 10", lastUpdated: "Closed Mar 18", status: "Rejected"),
        CandidateApp(role: "Head Chef", company: "Dishoom Soho", location: "London, UK", employmentType: "Full-time", salary: "£50k", appliedDate: "Feb 28", lastUpdated: "Offer sent Mar 12", status: "Accepted")
    ]

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.plagitCharcoal)
                            .frame(width: 36, height: 36)
                    }
                    Spacer()
                    Text("Candidate Applications")
                        .font(PlagitFont.subheadline())
                        .foregroundColor(.plagitCharcoal)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.lg)
                .padding(.bottom, PlagitSpacing.lg)

                ScrollView {
                    VStack(spacing: PlagitSpacing.lg) {
                        ForEach(apps) { app in
                            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                                HStack(spacing: PlagitSpacing.sm) {
                                    Text(app.role)
                                        .font(PlagitFont.bodyMedium())
                                        .foregroundColor(.plagitCharcoal)

                                    appStatusPill(app.status)
                                }

                                Text("\(app.company) · \(app.location)")
                                    .font(PlagitFont.caption())
                                    .foregroundColor(.plagitSecondary)

                                HStack(spacing: PlagitSpacing.sm) {
                                    Text(app.employmentType)
                                        .font(PlagitFont.captionMedium())
                                        .foregroundColor(.plagitCharcoal)

                                    Text("·")
                                        .foregroundColor(.plagitTertiary)

                                    Text(app.salary)
                                        .font(PlagitFont.captionMedium())
                                        .foregroundColor(.plagitTeal)
                                }

                                HStack(spacing: PlagitSpacing.sm) {
                                    Text("Applied \(app.appliedDate)")
                                        .font(PlagitFont.micro())
                                        .foregroundColor(.plagitTertiary)

                                    Text("·")
                                        .foregroundColor(.plagitTertiary)

                                    Text(app.lastUpdated)
                                        .font(PlagitFont.micro())
                                        .foregroundColor(.plagitTertiary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(PlagitSpacing.xl)
                            .background(
                                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                                    .fill(Color.plagitCardBackground)
                                    .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
                            )
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.sectionGap)
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func appStatusPill(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "Interviewing": return .plagitIndigo
            case "In Review": return .plagitAmber
            case "Applied": return .plagitTeal
            case "Accepted": return .plagitOnline
            case "Rejected": return .plagitTertiary
            default: return .plagitTertiary
            }
        }()

        return Text(status)
            .font(PlagitFont.micro())
            .foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.08)))
    }
}

// MARK: - Admin Document Detail

struct AdminDocumentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let documentName: String
    let documentIcon: String
    @Binding var documentStatus: String
    @State private var showRejectAlert = false
    @State private var confirmationMessage = ""
    @State private var showConfirmation = false

    private var fileType: String {
        documentName.contains("CV") ? "PDF" : "Image / PDF"
    }

    private var uploadDate: String {
        documentStatus == "Missing" ? "Not uploaded" : "Uploaded Mar 18, 2025"
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.plagitCharcoal)
                                .frame(width: 36, height: 36)
                        }
                        Spacer()
                        Text("Document Review")
                            .font(PlagitFont.subheadline())
                            .foregroundColor(.plagitCharcoal)
                        Spacer()
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.lg)
                    .padding(.bottom, PlagitSpacing.lg)

                    // Confirmation banner
                    if showConfirmation {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plagitOnline)

                            Text(confirmationMessage)
                                .font(PlagitFont.captionMedium())
                                .foregroundColor(.plagitOnline)

                            Spacer()
                        }
                        .padding(PlagitSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: PlagitRadius.md)
                                .fill(Color.plagitOnline.opacity(0.08))
                        )
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.top, PlagitSpacing.xs)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Document preview
                    if documentStatus != "Missing" {
                        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                            Text("Document Preview")
                                .font(PlagitFont.headline())
                                .foregroundColor(.plagitCharcoal)

                            ZStack {
                                RoundedRectangle(cornerRadius: PlagitRadius.md)
                                    .fill(Color.plagitSurface)
                                    .frame(height: 180)

                                VStack(spacing: PlagitSpacing.md) {
                                    Image(systemName: documentName.contains("CV") ? "doc.text.fill" : "photo")
                                        .font(.system(size: 36, weight: .light))
                                        .foregroundColor(.plagitTertiary)

                                    Text(documentName.contains("CV") ? "PDF Preview" : "Image Preview")
                                        .font(PlagitFont.caption())
                                        .foregroundColor(.plagitTertiary)
                                }
                            }

                            Button {} label: {
                                HStack(spacing: PlagitSpacing.sm) {
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("Open Full Document")
                                        .font(PlagitFont.captionMedium())
                                }
                                .foregroundColor(.plagitTeal)
                            }
                        }
                        .padding(PlagitSpacing.xxl)
                        .background(
                            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                                .fill(Color.plagitCardBackground)
                                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
                        )
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.top, PlagitSpacing.xs)
                    }

                    // Document info card
                    VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                        Text("Document Information")
                            .font(PlagitFont.headline())
                            .foregroundColor(.plagitCharcoal)

                        // File icon + name
                        HStack(spacing: PlagitSpacing.md) {
                            Image(systemName: documentIcon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.plagitTeal)
                                .frame(width: 48, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                                        .fill(Color.plagitTealLight)
                                )

                            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                Text(documentName)
                                    .font(PlagitFont.bodyMedium())
                                    .foregroundColor(.plagitCharcoal)

                                docBadge(documentStatus)
                            }

                            Spacer()
                        }

                        VStack(spacing: 0) {
                            detailRow(label: "File Type", value: fileType)
                            Rectangle().fill(Color.plagitDivider).frame(height: 1)
                            detailRow(label: "Upload Date", value: uploadDate)
                            Rectangle().fill(Color.plagitDivider).frame(height: 1)
                            detailRow(label: "Candidate", value: "Elena Rossi")
                            Rectangle().fill(Color.plagitDivider).frame(height: 1)
                            detailRow(label: "File Size", value: documentStatus == "Missing" ? "—" : "1.8 MB")
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
                    .padding(.top, PlagitSpacing.xs)

                    // Admin notes
                    VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                        Text("Review Notes")
                            .font(PlagitFont.headline())
                            .foregroundColor(.plagitCharcoal)

                        HStack(spacing: PlagitSpacing.md) {
                            Image(systemName: "note.text")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.plagitTertiary)

                            Text(documentStatus == "Verified" ? "Document reviewed and approved by Admin." : documentStatus == "Missing" ? "Document has not been uploaded yet." : "Document uploaded, awaiting admin review.")
                                .font(PlagitFont.body())
                                .foregroundColor(.plagitSecondary)
                                .lineSpacing(3)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(PlagitSpacing.xxl)
                    .background(
                        RoundedRectangle(cornerRadius: PlagitRadius.xl)
                            .fill(Color.plagitCardBackground)
                            .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
                    )
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.sectionGap)

                    // Admin actions
                    VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                        Text("Admin Actions")
                            .font(PlagitFont.headline())
                            .foregroundColor(.plagitCharcoal)

                        VStack(spacing: PlagitSpacing.md) {
                            if documentStatus != "Verified" && documentStatus != "Missing" {
                                Button {
                                    withAnimation {
                                        documentStatus = "Verified"
                                        showBanner("Document approved successfully")
                                    }
                                } label: {
                                    HStack(spacing: PlagitSpacing.sm) {
                                        Image(systemName: "checkmark.circle")
                                            .font(.system(size: 13, weight: .medium))
                                        Text("Approve Document")
                                            .font(PlagitFont.captionMedium())
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color.plagitOnline))
                                }
                            }

                            if documentStatus != "Missing" {
                                Button { showRejectAlert = true } label: {
                                    HStack(spacing: PlagitSpacing.sm) {
                                        Image(systemName: "xmark.circle")
                                            .font(.system(size: 13, weight: .medium))
                                        Text("Reject Document")
                                            .font(PlagitFont.captionMedium())
                                    }
                                    .foregroundColor(.plagitUrgent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color.plagitUrgent.opacity(0.08)))
                                }
                            }

                            Button {
                                withAnimation {
                                    documentStatus = "Pending"
                                    showBanner("New upload requested from candidate")
                                }
                            } label: {
                                HStack(spacing: PlagitSpacing.sm) {
                                    Image(systemName: "arrow.up.doc")
                                        .font(.system(size: 13, weight: .medium))
                                    Text("Request New Upload")
                                        .font(PlagitFont.captionMedium())
                                }
                                .foregroundColor(.plagitTeal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Capsule().fill(Color.plagitTealLight))
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
                    .padding(.top, PlagitSpacing.sectionGap)

                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Reject Document", isPresented: $showRejectAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reject", role: .destructive) {
                withAnimation {
                    documentStatus = "Pending"
                    showBanner("Document rejected — candidate notified")
                }
            }
        } message: {
            Text("Are you sure you want to reject this document? The candidate will need to upload a new version.")
        }
    }

    private func showBanner(_ message: String) {
        confirmationMessage = message
        withAnimation { showConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { showConfirmation = false }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)
            Spacer()
            Text(value)
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitCharcoal)
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .padding(.vertical, PlagitSpacing.md + 2)
    }

    private func docBadge(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "Verified": return .plagitOnline
            case "Pending": return .plagitAmber
            case "Missing": return .plagitUrgent
            default: return .plagitTertiary
            }
        }()
        return Text(status)
            .font(PlagitFont.micro())
            .foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm)
            .padding(.vertical, 3)
            .background(Capsule().fill(color.opacity(0.08)))
    }
}

// MARK: - Add Note Sheet (separate struct for proper @Binding)

struct AddNoteSheetView: View {
    @Binding var savedNotes: [(text: String, date: String)]
    @Binding var isPresented: Bool
    @State private var noteText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    noteText = ""
                    isPresented = false
                } label: {
                    Text("Cancel")
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitTeal)
                }

                Spacer()

                Text("Add Admin Note")
                    .font(PlagitFont.subheadline())
                    .foregroundColor(.plagitCharcoal)

                Spacer()

                Text("Cancel").font(PlagitFont.body()).opacity(0)
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.xl)
            .padding(.bottom, PlagitSpacing.lg)

            Rectangle().fill(Color.plagitDivider).frame(height: 1)

            VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                Text("Add a moderation note for this candidate.")
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitSecondary)

                ZStack(alignment: .topLeading) {
                    if noteText.isEmpty {
                        Text("Enter admin note...")
                            .font(PlagitFont.body())
                            .foregroundColor(.plagitTertiary)
                            .padding(.horizontal, PlagitSpacing.lg)
                            .padding(.vertical, PlagitSpacing.md)
                    }

                    TextEditor(text: $noteText)
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitCharcoal)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, PlagitSpacing.md)
                        .padding(.vertical, PlagitSpacing.sm)
                }
                .frame(minHeight: 120)
                .background(
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(Color.plagitSurface)
                )

                Button {
                    let trimmed = noteText.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    savedNotes.insert((text: trimmed, date: "Just now"), at: 0)
                    noteText = ""
                    isPresented = false
                } label: {
                    Text("Save Note")
                        .font(PlagitFont.subheadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PlagitSpacing.lg)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Color.plagitTeal, Color.plagitTealDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        )
                }

                Spacer()
            }
            .padding(PlagitSpacing.xxl)
        }
        .background(Color.plagitBackground)
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AdminCandidateDetailView()
    }
    .preferredColorScheme(.light)
}
