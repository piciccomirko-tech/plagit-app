//
//  AdminJobDetailView.swift
//  Plagit
//
//  Premium Admin Job Detail / Moderation Screen
//

import SwiftUI

struct AdminJobDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var jobStatus = "Active"
    @State private var showDestructiveAlert = false
    @State private var destructiveTitle = ""
    @State private var destructiveMessage = ""
    @State private var destructiveAction: (() -> Void)?
    @State private var showNoteSheet = false
    @State private var savedNotes: [(text: String, date: String)] = []
    @State private var showApplications = false
    @State private var showReports = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerCard.padding(.top, PlagitSpacing.xs)
                        jobInfoCard.padding(.top, PlagitSpacing.sectionGap)
                        descriptionCard.padding(.top, PlagitSpacing.sectionGap)
                        businessSummaryCard.padding(.top, PlagitSpacing.sectionGap)
                        applicationsSnapshot.padding(.top, PlagitSpacing.sectionGap)
                        moderationCard.padding(.top, PlagitSpacing.sectionGap)
                        adminActionsCard.padding(.top, PlagitSpacing.sectionGap)
                        if !savedNotes.isEmpty {
                            adminNotesCard.padding(.top, PlagitSpacing.sectionGap)
                        }
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showApplications) {
            AdminApplicationsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showReports) {
            AdminReportsView().navigationBarHidden(true)
        }
        .sheet(isPresented: $showNoteSheet) {
            JobNoteSheetView(savedNotes: $savedNotes, isPresented: $showNoteSheet)
        }
        .alert(destructiveTitle, isPresented: $showDestructiveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm", role: .destructive) { destructiveAction?() }
        } message: { Text(destructiveMessage) }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text("Job Detail").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - 1. Header Card

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xl) {
            HStack(alignment: .top) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hue: 0.55, saturation: 0.45, brightness: 0.90), Color(hue: 0.55, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 54, height: 54)
                    .overlay(Text("NR").font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.white))

                Spacer()

                statusPill(jobStatus)
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Senior Chef").font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text("Nobu Restaurant").font(PlagitFont.bodyMedium()).foregroundColor(.plagitSecondary)

                HStack(spacing: PlagitSpacing.lg) {
                    iconLabel(icon: "mappin", text: "Dubai, UAE")
                    iconLabel(icon: "clock", text: "Full-time")
                    iconLabel(icon: "briefcase.fill", text: "Chef")
                }

                HStack(spacing: PlagitSpacing.lg) {
                    Text("$5,500/mo").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    Text("·").foregroundColor(.plagitTertiary)
                    Text("Posted Mar 18, 2026").font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                }

                HStack(spacing: PlagitSpacing.sm) {
                    Text("12 applicants").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)

                    Spacer()

                    HStack(spacing: PlagitSpacing.sm) {
                        ProgressView(value: 0.85).tint(Color.plagitTeal).frame(width: 60)
                        Text("85% quality").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                    }
                }
                .padding(.top, PlagitSpacing.xs)
            }
        }
        .padding(PlagitSpacing.xxl)
        .background(card)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 2. Job Info

    private var jobInfoCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Job Information").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            VStack(spacing: 0) {
                infoRow(icon: "tag", label: "Category", value: "Fine Dining")
                div
                infoRow(icon: "doc.text", label: "Contract", value: "Permanent")
                div
                infoRow(icon: "clock", label: "Shift Pattern", value: "Evenings & Weekends")
                div
                infoRow(icon: "banknote", label: "Salary", value: "$5,500/mo")
                div
                infoRow(icon: "briefcase", label: "Experience", value: "3+ years required")
                div
                infoRow(icon: "globe", label: "Languages", value: "English required")
                div
                infoRow(icon: "calendar", label: "Start Date", value: "Immediate")
                div
                infoRow(icon: "airplane", label: "Visa Support", value: "Yes")
                div
                infoRow(icon: "house", label: "Accommodation", value: "Provided")
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
        .padding(PlagitSpacing.xxl)
        .background(card)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 3. Description

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Job Description").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            Text("We are looking for a talented and passionate Senior Chef to join our Dubai team. You will lead kitchen operations for private dining and premium events, working closely with our executive team to deliver world-class culinary experiences.")
                .font(PlagitFont.body()).foregroundColor(.plagitSecondary).lineSpacing(5)

            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Key Responsibilities").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                bulletRow("Lead kitchen operations for private dining and events")
                bulletRow("Develop seasonal tasting menus with executive team")
                bulletRow("Manage and train junior kitchen staff")
                bulletRow("Ensure food safety and quality standards")
            }
            .padding(.top, PlagitSpacing.sm)

            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Requirements").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                bulletRow("3+ years in fine dining or luxury hospitality")
                bulletRow("Strong background in Japanese or fusion cuisine")
                bulletRow("Fluent in English")
                bulletRow("Food safety certification")
            }
            .padding(.top, PlagitSpacing.sm)

            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Benefits").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                checkRow("Visa sponsorship and relocation support")
                checkRow("Staff accommodation provided")
                checkRow("Daily meals during shifts")
                checkRow("Performance bonuses")
                checkRow("Health insurance")
            }
            .padding(.top, PlagitSpacing.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PlagitSpacing.xxl)
        .background(card)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 4. Business Summary

    private var businessSummaryCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Business Summary").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            HStack(spacing: PlagitSpacing.md) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hue: 0.55, saturation: 0.45, brightness: 0.90), Color(hue: 0.55, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .overlay(Text("NR").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.xs) {
                        Text("Nobu Restaurant").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 10)).foregroundColor(.plagitVerified)
                        Text("Verified").font(PlagitFont.micro()).foregroundColor(.plagitVerified)
                    }
                    Text("Dubai, UAE · 4 active jobs").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }
                Spacer()
            }

            VStack(spacing: 0) {
                infoRow(icon: "shield.checkered", label: "Trust Score", value: "High")
                div
                infoRow(icon: "briefcase", label: "Active Jobs", value: "4")
                div
                infoRow(icon: "flag", label: "Previous Flags", value: "None")
                div
                infoRow(icon: "person.badge.plus", label: "On Platform Since", value: "Jan 2025")
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
        .padding(PlagitSpacing.xxl)
        .background(card)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 5. Applications Snapshot

    private var applicationsSnapshot: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Applications").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: PlagitSpacing.md), GridItem(.flexible(), spacing: PlagitSpacing.md), GridItem(.flexible(), spacing: PlagitSpacing.md), GridItem(.flexible(), spacing: PlagitSpacing.md)], spacing: PlagitSpacing.md) {
                miniStat(number: "12", label: "Total", color: .plagitTeal)
                miniStat(number: "4", label: "Shortlisted", color: .plagitIndigo)
                miniStat(number: "2", label: "Interview", color: .plagitOnline)
                miniStat(number: "3", label: "Rejected", color: .plagitTertiary)
            }

            Button { showApplications = true } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "doc.text").font(.system(size: 13, weight: .medium))
                    Text("View All Applications").font(PlagitFont.captionMedium())
                }
                .foregroundColor(.plagitTeal).frame(maxWidth: .infinity).padding(.vertical, 10)
                .background(Capsule().fill(Color.plagitTealLight))
            }
        }
        .padding(PlagitSpacing.xxl)
        .background(card)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func miniStat(number: String, label: String, color: Color) -> some View {
        VStack(spacing: PlagitSpacing.xs) {
            Text(number).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PlagitSpacing.md)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
    }

    // MARK: - 6. Moderation & Flags

    private var moderationCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Moderation & Flags").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: "shield.checkered").font(.system(size: 13, weight: .medium)).foregroundColor(.plagitOnline)
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitOnline.opacity(0.10)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("No active flags").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text("This job listing has passed all automated checks").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }
                Spacer()
            }

            VStack(spacing: 0) {
                infoRow(icon: "flag", label: "Reports", value: "0")
                div
                infoRow(icon: "exclamationmark.triangle", label: "Flags", value: "None")
                div
                infoRow(icon: "clock", label: "Last Reviewed", value: "Mar 20, 2026")
                div
                infoRow(icon: "checkmark.circle", label: "Auto-Check", value: "Passed")
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))

            // Timeline
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Moderation Timeline").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                timeRow(color: .plagitTeal, text: "Job posted by Nobu Restaurant", time: "Mar 18")
                timeRow(color: .plagitOnline, text: "Auto-approved — passed quality checks", time: "Mar 18")
                timeRow(color: .plagitTeal, text: "First application received", time: "Mar 19")
            }
            .padding(.top, PlagitSpacing.sm)
        }
        .padding(PlagitSpacing.xxl)
        .background(card)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 7. Admin Actions

    private var adminActionsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Admin Actions").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            VStack(spacing: PlagitSpacing.md) {
                // Status-dependent primary
                if jobStatus == "Active" || jobStatus == "Under Review" {
                    actionBtn(icon: "eye.slash", label: "Hide Job", fg: .plagitUrgent, bg: Color.plagitUrgent.opacity(0.08)) {
                        confirm(title: "Hide Job", msg: "This will remove the job from all candidate searches. The business will be notified.") {
                            withAnimation { jobStatus = "Hidden" }
                        }
                    }
                }

                if jobStatus == "Active" {
                    actionBtn(icon: "xmark.circle", label: "Suspend Listing", fg: .plagitUrgent, bg: Color.plagitUrgent.opacity(0.08)) {
                        confirm(title: "Suspend Listing", msg: "This will suspend the job listing and freeze all active applications.") {
                            withAnimation { jobStatus = "Suspended" }
                        }
                    }
                }

                if jobStatus == "Under Review" {
                    actionBtn(icon: "checkmark.circle", label: "Approve Job", fg: .white, bg: Color.plagitOnline) {
                        withAnimation { jobStatus = "Active" }
                    }
                }

                if jobStatus == "Hidden" || jobStatus == "Suspended" {
                    actionBtn(icon: "arrow.counterclockwise", label: "Reopen Job", fg: .white, bg: Color.plagitTeal) {
                        withAnimation { jobStatus = "Active" }
                    }
                }

                // Always available
                HStack(spacing: PlagitSpacing.md) {
                    actionBtn(icon: "note.text", label: "Add Note", fg: .plagitTeal, bg: Color.plagitTealLight) {
                        showNoteSheet = true
                    }
                    actionBtn(icon: "flag", label: "View Reports", fg: .plagitTeal, bg: Color.plagitTealLight) {
                        showReports = true
                    }
                }
            }
        }
        .padding(PlagitSpacing.xxl)
        .background(card)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 8. Admin Notes

    private var adminNotesCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Admin Notes").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            VStack(spacing: PlagitSpacing.sm) {
                ForEach(Array(savedNotes.enumerated()), id: \.offset) { _, note in
                    HStack(alignment: .top, spacing: PlagitSpacing.md) {
                        Circle().fill(Color.plagitAmber).frame(width: 6, height: 6).padding(.top, 7)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(note.text).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            Text("Added \(note.date) by Admin").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PlagitSpacing.xxl)
        .background(card)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Helpers

    private func confirm(title: String, msg: String, action: @escaping () -> Void) {
        destructiveTitle = title; destructiveMessage = msg; destructiveAction = action; showDestructiveAlert = true
    }

    private func actionBtn(icon: String, label: String, fg: Color, bg: some ShapeStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon).font(.system(size: 13, weight: .medium))
                Text(label).font(PlagitFont.captionMedium())
            }.foregroundColor(fg).frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(Capsule().fill(bg))
        }
    }

    private func statusPill(_ s: String) -> some View {
        let c: Color = { switch s { case "Active": return .plagitOnline; case "Under Review": return .plagitAmber; case "Hidden": return .plagitTertiary; case "Suspended": return .plagitUrgent; default: return .plagitTertiary } }()
        return Text(s).font(PlagitFont.micro()).foregroundColor(c).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3).background(Capsule().fill(c.opacity(0.08)))
    }

    private func iconLabel(icon: String, text: String) -> some View {
        HStack(spacing: PlagitSpacing.xs) {
            Image(systemName: icon).font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary)
            Text(text).font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 20)
            Text(label).font(PlagitFont.body()).foregroundColor(.plagitSecondary)
            Spacer()
            Text(value).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
        }
        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md + 2)
    }

    private var div: some View { Rectangle().fill(Color.plagitDivider).frame(height: 1) }

    private var card: some View {
        RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
    }

    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            Circle().fill(Color.plagitTeal).frame(width: 6, height: 6).padding(.top, 7)
            Text(text).font(PlagitFont.body()).foregroundColor(.plagitSecondary)
        }
    }

    private func checkRow(_ text: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTeal)
            Text(text).font(PlagitFont.body()).foregroundColor(.plagitSecondary)
        }
    }

    private func timeRow(color: Color, text: String, time: String) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            Circle().fill(color).frame(width: 6, height: 6).padding(.top, 7)
            VStack(alignment: .leading, spacing: 2) {
                Text(text).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                Text(time).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            }
        }
    }
}

// MARK: - Job Note Sheet

struct JobNoteSheetView: View {
    @Binding var savedNotes: [(text: String, date: String)]
    @Binding var isPresented: Bool
    @State private var noteText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { noteText = ""; isPresented = false } label: { Text("Cancel").font(PlagitFont.body()).foregroundColor(.plagitTeal) }
                Spacer()
                Text("Add Admin Note").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
                Spacer()
                Text("Cancel").font(PlagitFont.body()).opacity(0)
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xl).padding(.bottom, PlagitSpacing.lg)

            Rectangle().fill(Color.plagitDivider).frame(height: 1)

            VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                Text("Add a moderation note for this job listing.").font(PlagitFont.body()).foregroundColor(.plagitSecondary)

                ZStack(alignment: .topLeading) {
                    if noteText.isEmpty {
                        Text("Enter admin note...").font(PlagitFont.body()).foregroundColor(.plagitTertiary)
                            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
                    }
                    TextEditor(text: $noteText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        .scrollContentBackground(.hidden).padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                }
                .frame(minHeight: 120).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))

                Button {
                    let t = noteText.trimmingCharacters(in: .whitespaces); guard !t.isEmpty else { return }
                    savedNotes.insert((text: t, date: "Just now"), at: 0); noteText = ""; isPresented = false
                } label: {
                    Text("Save Note").font(PlagitFont.subheadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                        .background(Capsule().fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing)))
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
    NavigationStack { AdminJobDetailView() }.preferredColorScheme(.light)
}
