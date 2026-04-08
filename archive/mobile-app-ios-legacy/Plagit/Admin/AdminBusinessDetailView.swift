//
//  AdminBusinessDetailView.swift
//  Plagit
//
//  Premium Admin Business Detail / Moderation Screen
//

import SwiftUI

struct AdminBusinessDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bizStatus = "Active"
    @State private var showDestructiveAlert = false
    @State private var destructiveTitle = ""
    @State private var destructiveMessage = ""
    @State private var destructiveAction: (() -> Void)?
    @State private var showNoteSheet = false
    @State private var savedNotes: [(text: String, date: String)] = []
    @State private var showJobDetail = false
    @State private var showReports = false
    @State private var showDocDetail = false
    @State private var selectedDocIndex = 0

    @State private var documents: [(name: String, icon: String, status: String)] = [
        ("Trade License", "doc.text.fill", "Verified"),
        ("Business Registration", "building.columns", "Verified"),
        ("Owner ID / Signatory", "person.text.rectangle", "Pending"),
        ("Address Proof", "mappin.and.ellipse", "Verified"),
        ("VAT Certificate", "doc.viewfinder", "Missing")
    ]

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerCard.padding(.top, PlagitSpacing.xs)
                        businessInfoCard.padding(.top, PlagitSpacing.sectionGap)
                        documentsCard.padding(.top, PlagitSpacing.sectionGap)
                        activityCard.padding(.top, PlagitSpacing.sectionGap)
                        moderationCard.padding(.top, PlagitSpacing.sectionGap)
                        postedJobsCard.padding(.top, PlagitSpacing.sectionGap)
                        adminActionsCard.padding(.top, PlagitSpacing.sectionGap)
                        if !savedNotes.isEmpty { adminNotesCard.padding(.top, PlagitSpacing.sectionGap) }
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showJobDetail) { AdminJobDetailView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showReports) { AdminReportsView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showDocDetail) {
            BusinessDocDetailView(
                documentName: documents[selectedDocIndex].name,
                documentIcon: documents[selectedDocIndex].icon,
                documentStatus: Binding(get: { documents[selectedDocIndex].status }, set: { documents[selectedDocIndex].status = $0 })
            ).navigationBarHidden(true)
        }
        .sheet(isPresented: $showNoteSheet) { BizNoteSheetView(savedNotes: $savedNotes, isPresented: $showNoteSheet) }
        .alert(destructiveTitle, isPresented: $showDestructiveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm", role: .destructive) { destructiveAction?() }
        } message: { Text(destructiveMessage) }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Business Detail").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - 1. Header
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.xl) {
            HStack(alignment: .top) {
                ZStack(alignment: .bottomTrailing) {
                    Circle().fill(LinearGradient(colors: [Color(hue: 0.55, saturation: 0.45, brightness: 0.90), Color(hue: 0.55, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 64, height: 64)
                        .overlay(Text("NR").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(.white))
                    if bizStatus == "Active" {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 16)).foregroundColor(.plagitVerified)
                            .background(Circle().fill(.white).frame(width: 14, height: 14)).offset(x: 2, y: 2)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: PlagitSpacing.sm) {
                    statusPill(bizStatus)
                    Text("Restaurant").font(PlagitFont.micro()).foregroundColor(.plagitIndigo).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2).background(Capsule().fill(Color.plagitIndigo.opacity(0.08)))
                }
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Nobu Restaurant").font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                HStack(spacing: PlagitSpacing.lg) {
                    iconLabel(icon: "mappin", text: "Dubai, UAE")
                    iconLabel(icon: "calendar", text: "Since Jan 2025")
                }
                HStack(spacing: PlagitSpacing.sm) {
                    Text("4 active jobs").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Spacer()
                    HStack(spacing: PlagitSpacing.sm) {
                        ProgressView(value: 0.90).tint(Color.plagitOnline).frame(width: 60)
                        Text("90% trust").font(PlagitFont.micro()).foregroundColor(.plagitOnline)
                    }
                }
                .padding(.top, PlagitSpacing.xs)
            }
        }
        .padding(PlagitSpacing.xxl).background(card).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 2. Business Info
    private var businessInfoCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Business Information").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            VStack(spacing: 0) {
                infoRow(icon: "building.2", label: "Legal Name", value: "Nobu Hospitality LLC")
                div; infoRow(icon: "fork.knife", label: "Business Type", value: "Restaurant — Fine Dining")
                div; infoRow(icon: "envelope", label: "Email", value: "admin@nobu-dubai.com")
                div; infoRow(icon: "phone", label: "Phone", value: "+971 4 123 4567")
                div; infoRow(icon: "mappin", label: "City", value: "Dubai")
                div; infoRow(icon: "globe", label: "Country", value: "United Arab Emirates")
                div; infoRow(icon: "link", label: "Website", value: "noburestaurants.com")
                div; infoRow(icon: "doc.text", label: "License Status", value: "Valid")
                div; infoRow(icon: "number", label: "Tax Registration", value: "TRN-2024-00456")
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
        .padding(PlagitSpacing.xxl).background(card).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 3. Documents
    private var documentsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Verification & Documents").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            VStack(spacing: 0) {
                ForEach(Array(documents.enumerated()), id: \.offset) { index, doc in
                    docRow(index: index, name: doc.name, icon: doc.icon, status: doc.status)
                    if index < documents.count - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1) }
                }
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
        .padding(PlagitSpacing.xxl).background(card).padding(.horizontal, PlagitSpacing.xl)
    }

    private func docRow(index: Int, name: String, icon: String, status: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 20)
            Text(name).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            Spacer()
            docBadge(status)
            if status != "Missing" {
                Button { selectedDocIndex = index; showDocDetail = true } label: {
                    Text("View").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md + 2)
    }

    private func docBadge(_ s: String) -> some View {
        let c: Color = { switch s { case "Verified": return .plagitOnline; case "Pending": return .plagitAmber; case "Missing": return .plagitUrgent; case "Rejected": return .plagitUrgent; default: return .plagitTertiary } }()
        return Text(s).font(PlagitFont.micro()).foregroundColor(c).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2).background(Capsule().fill(c.opacity(0.08)))
    }

    // MARK: - 4. Activity
    private var activityCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Business Activity").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: PlagitSpacing.md), GridItem(.flexible(), spacing: PlagitSpacing.md), GridItem(.flexible(), spacing: PlagitSpacing.md)], spacing: PlagitSpacing.md) {
                miniStat(n: "12", l: "Jobs Posted", c: .plagitTeal)
                miniStat(n: "4", l: "Active Now", c: .plagitIndigo)
                miniStat(n: "28", l: "Total Hires", c: .plagitOnline)
            }
            VStack(spacing: 0) {
                infoRow(icon: "arrow.up.right", label: "Response Rate", value: "92%")
                div; infoRow(icon: "flag", label: "Reports", value: "0")
                div; infoRow(icon: "clock", label: "Last Active", value: "2 hours ago")
                div; infoRow(icon: "star", label: "Platform Trust", value: "High")
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
        .padding(PlagitSpacing.xxl).background(card).padding(.horizontal, PlagitSpacing.xl)
    }

    private func miniStat(n: String, l: String, c: Color) -> some View {
        VStack(spacing: PlagitSpacing.xs) {
            Text(n).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text(l).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
        }.frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
    }

    // MARK: - 5. Moderation
    private var moderationCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Moderation & Flags").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: "shield.checkered").font(.system(size: 13, weight: .medium)).foregroundColor(.plagitOnline)
                    .frame(width: 28, height: 28).background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitOnline.opacity(0.10)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("No active flags").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text("This business has no moderation warnings").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("Moderation Timeline").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                timeRow(color: .plagitTeal, text: "Business registered on platform", time: "Jan 2025")
                timeRow(color: .plagitOnline, text: "Trade license verified — auto-approved", time: "Jan 2025")
                timeRow(color: .plagitTeal, text: "First job posted — Senior Chef", time: "Feb 2025")
                timeRow(color: .plagitOnline, text: "All documents verified", time: "Mar 2025")
            }
            .padding(.top, PlagitSpacing.sm)
        }
        .padding(PlagitSpacing.xxl).background(card).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 6. Posted Jobs
    private var postedJobsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text("Posted Jobs").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Spacer()
                Text("4 active").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
            }

            VStack(spacing: 0) {
                jobRow(title: "Senior Chef", status: "Active", applicants: 12, date: "Mar 18")
                Rectangle().fill(Color.plagitDivider).frame(height: 1)
                jobRow(title: "Bar Manager", status: "Active", applicants: 6, date: "Mar 20")
                Rectangle().fill(Color.plagitDivider).frame(height: 1)
                jobRow(title: "Sous Chef", status: "Active", applicants: 8, date: "Mar 15")
                Rectangle().fill(Color.plagitDivider).frame(height: 1)
                jobRow(title: "Waitstaff", status: "Closed", applicants: 15, date: "Feb 28")
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
        .padding(PlagitSpacing.xxl).background(card).padding(.horizontal, PlagitSpacing.xl)
    }

    private func jobRow(title: String, status: String, applicants: Int, date: String) -> some View {
        Button { showJobDetail = true } label: {
            HStack(spacing: PlagitSpacing.md) {
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        Text(status).font(PlagitFont.micro()).foregroundColor(status == "Active" ? .plagitOnline : .plagitTertiary)
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2).background(Capsule().fill((status == "Active" ? Color.plagitOnline : Color.plagitTertiary).opacity(0.08)))
                    }
                    Text("\(applicants) applicants · Posted \(date)").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
            }
            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md + 2)
        }
    }

    // MARK: - 7. Admin Actions
    private var adminActionsCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Admin Actions").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            VStack(spacing: PlagitSpacing.md) {
                if bizStatus == "Active" {
                    actionBtn(icon: "xmark.circle", label: "Restrict Account", fg: .plagitAmber, bg: Color.plagitAmber.opacity(0.08)) {
                        confirm(t: "Restrict Account", m: "This will restrict the business from posting new jobs until review is complete.") { withAnimation { bizStatus = "Restricted" } }
                    }
                    actionBtn(icon: "nosign", label: "Suspend Business", fg: .plagitUrgent, bg: Color.plagitUrgent.opacity(0.08)) {
                        confirm(t: "Suspend Business", m: "This will suspend the business account, hide all job listings, and freeze active applications.") { withAnimation { bizStatus = "Suspended" } }
                    }
                }
                if bizStatus == "Under Review" {
                    actionBtn(icon: "checkmark.seal", label: "Verify Business", fg: .white, bg: Color.plagitOnline) { withAnimation { bizStatus = "Active" } }
                    actionBtn(icon: "doc.badge.arrow.up", label: "Request Documents", fg: .plagitTeal, bg: Color.plagitTealLight) {}
                }
                if bizStatus == "Suspended" || bizStatus == "Restricted" {
                    actionBtn(icon: "arrow.counterclockwise", label: "Reopen Account", fg: .white, bg: Color.plagitTeal) { withAnimation { bizStatus = "Active" } }
                }

                HStack(spacing: PlagitSpacing.md) {
                    actionBtn(icon: "note.text", label: "Add Note", fg: .plagitTeal, bg: Color.plagitTealLight) { showNoteSheet = true }
                    actionBtn(icon: "flag", label: "View Reports", fg: .plagitTeal, bg: Color.plagitTealLight) { showReports = true }
                }
            }
        }
        .padding(PlagitSpacing.xxl).background(card).padding(.horizontal, PlagitSpacing.xl)
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
        .padding(PlagitSpacing.xxl).background(card).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Helpers
    private func confirm(t: String, m: String, a: @escaping () -> Void) {
        destructiveTitle = t; destructiveMessage = m; destructiveAction = a; showDestructiveAlert = true
    }
    private func actionBtn(icon: String, label: String, fg: Color, bg: some ShapeStyle, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon).font(.system(size: 13, weight: .medium))
                Text(label).font(PlagitFont.captionMedium())
            }.foregroundColor(fg).frame(maxWidth: .infinity).padding(.vertical, 10).background(Capsule().fill(bg))
        }
    }
    private func statusPill(_ s: String) -> some View {
        let c: Color = { switch s { case "Active": return .plagitOnline; case "Under Review": return .plagitAmber; case "Suspended": return .plagitUrgent; case "Restricted": return .plagitAmber; default: return .plagitTertiary } }()
        return Text(s).font(PlagitFont.micro()).foregroundColor(c).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3).background(Capsule().fill(c.opacity(0.08)))
    }
    private func iconLabel(icon: String, text: String) -> some View {
        HStack(spacing: PlagitSpacing.xs) { Image(systemName: icon).font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary); Text(text).font(PlagitFont.caption()).foregroundColor(.plagitTertiary) }
    }
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 20)
            Text(label).font(PlagitFont.body()).foregroundColor(.plagitSecondary); Spacer()
            Text(value).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md + 2)
    }
    private func timeRow(color: Color, text: String, time: String) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            Circle().fill(color).frame(width: 6, height: 6).padding(.top, 7)
            VStack(alignment: .leading, spacing: 2) { Text(text).font(PlagitFont.caption()).foregroundColor(.plagitSecondary); Text(time).font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }
        }
    }
    private var div: some View { Rectangle().fill(Color.plagitDivider).frame(height: 1) }
    private var card: some View { RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY) }
}

// MARK: - Business Document Detail
struct BusinessDocDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let documentName: String
    let documentIcon: String
    @Binding var documentStatus: String
    @State private var showRejectAlert = false
    @State private var showConfirmation = false
    @State private var confirmationMessage = ""

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
                    Spacer(); Text("Document Review").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg).background(Color.plagitBackground)

                ScrollView {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        if showConfirmation {
                            HStack(spacing: PlagitSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitOnline)
                                Text(confirmationMessage).font(PlagitFont.captionMedium()).foregroundColor(.plagitOnline); Spacer()
                            }.padding(PlagitSpacing.lg).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitOnline.opacity(0.08)))
                            .padding(.horizontal, PlagitSpacing.xl).transition(.opacity)
                        }

                        // Doc info
                        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                            Text("Document Information").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                            HStack(spacing: PlagitSpacing.md) {
                                Image(systemName: documentIcon).font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 48, height: 48)
                                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitTealLight))
                                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                    Text(documentName).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                    let c: Color = documentStatus == "Verified" ? .plagitOnline : documentStatus == "Pending" ? .plagitAmber : .plagitUrgent
                                    Text(documentStatus).font(PlagitFont.micro()).foregroundColor(c).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2).background(Capsule().fill(c.opacity(0.08)))
                                }; Spacer()
                            }
                            VStack(spacing: 0) {
                                infoR("File Type", documentName.contains("ID") ? "Image / PDF" : "PDF")
                                Rectangle().fill(Color.plagitDivider).frame(height: 1)
                                infoR("Upload Date", documentStatus == "Missing" ? "Not uploaded" : "Uploaded Feb 15, 2025")
                                Rectangle().fill(Color.plagitDivider).frame(height: 1)
                                infoR("Business", "Nobu Restaurant")
                            }.background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
                        }.padding(PlagitSpacing.xxl).background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)).padding(.horizontal, PlagitSpacing.xl)

                        // Actions
                        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                            Text("Admin Actions").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                            VStack(spacing: PlagitSpacing.md) {
                                if documentStatus != "Verified" && documentStatus != "Missing" {
                                    Button { withAnimation { documentStatus = "Verified"; showBanner("Document approved") } } label: {
                                        HStack(spacing: PlagitSpacing.sm) { Image(systemName: "checkmark.circle").font(.system(size: 13, weight: .medium)); Text("Approve").font(PlagitFont.captionMedium()) }
                                            .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 10).background(Capsule().fill(Color.plagitOnline))
                                    }
                                }
                                if documentStatus != "Missing" {
                                    Button { showRejectAlert = true } label: {
                                        HStack(spacing: PlagitSpacing.sm) { Image(systemName: "xmark.circle").font(.system(size: 13, weight: .medium)); Text("Reject").font(PlagitFont.captionMedium()) }
                                            .foregroundColor(.plagitUrgent).frame(maxWidth: .infinity).padding(.vertical, 10).background(Capsule().fill(Color.plagitUrgent.opacity(0.08)))
                                    }
                                }
                                Button { withAnimation { documentStatus = "Pending"; showBanner("New upload requested") } } label: {
                                    HStack(spacing: PlagitSpacing.sm) { Image(systemName: "arrow.up.doc").font(.system(size: 13, weight: .medium)); Text("Request New Upload").font(PlagitFont.captionMedium()) }
                                        .foregroundColor(.plagitTeal).frame(maxWidth: .infinity).padding(.vertical, 10).background(Capsule().fill(Color.plagitTealLight))
                                }
                            }
                        }.padding(PlagitSpacing.xxl).background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)).padding(.horizontal, PlagitSpacing.xl)

                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }.padding(.top, PlagitSpacing.xs)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Reject Document", isPresented: $showRejectAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reject", role: .destructive) { withAnimation { documentStatus = "Pending"; showBanner("Document rejected") } }
        } message: { Text("The business will need to upload a new version.") }
    }

    private func showBanner(_ msg: String) { confirmationMessage = msg; withAnimation { showConfirmation = true }; DispatchQueue.main.asyncAfter(deadline: .now() + 3) { withAnimation { showConfirmation = false } } }
    private func infoR(_ l: String, _ v: String) -> some View {
        HStack { Text(l).font(PlagitFont.body()).foregroundColor(.plagitSecondary); Spacer(); Text(v).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal) }
            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md + 2)
    }
}

// MARK: - Business Note Sheet
struct BizNoteSheetView: View {
    @Binding var savedNotes: [(text: String, date: String)]
    @Binding var isPresented: Bool
    @State private var noteText = ""
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { noteText = ""; isPresented = false } label: { Text("Cancel").font(PlagitFont.body()).foregroundColor(.plagitTeal) }
                Spacer(); Text("Add Admin Note").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
                Text("Cancel").font(PlagitFont.body()).opacity(0)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xl).padding(.bottom, PlagitSpacing.lg)
            Rectangle().fill(Color.plagitDivider).frame(height: 1)
            VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                Text("Add a moderation note for this business.").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                ZStack(alignment: .topLeading) {
                    if noteText.isEmpty { Text("Enter admin note...").font(PlagitFont.body()).foregroundColor(.plagitTertiary).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md) }
                    TextEditor(text: $noteText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal).scrollContentBackground(.hidden).padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                }.frame(minHeight: 120).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
                Button {
                    let t = noteText.trimmingCharacters(in: .whitespaces); guard !t.isEmpty else { return }
                    savedNotes.insert((text: t, date: "Just now"), at: 0); noteText = ""; isPresented = false
                } label: {
                    Text("Save Note").font(PlagitFont.subheadline()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                        .background(Capsule().fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing)))
                }
                Spacer()
            }.padding(PlagitSpacing.xxl)
        }.background(Color.plagitBackground).presentationDetents([.medium])
    }
}

#Preview { NavigationStack { AdminBusinessDetailView() }.preferredColorScheme(.light) }
