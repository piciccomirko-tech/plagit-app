//
//  BusinessInsightsView.swift
//  Plagit
//
//  Business Insights / Analytics Screen
//

import SwiftUI

struct BusinessInsightsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
                    }
                    Spacer()
                    Text("Insights").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        // Profile Views
                        insightCard(title: "Profile Views", number: "48", change: "+12 this week", icon: "eye", color: .plagitIndigo)

                        // Job Performance
                        insightCard(title: "Job Performance", number: "3", change: "Active jobs", icon: "briefcase.fill", color: .plagitTeal)

                        // Applicant Activity
                        insightCard(title: "Applicant Activity", number: "12", change: "New this week", icon: "person.2", color: .plagitAmber)

                        // Interview Rate
                        insightCard(title: "Interview Rate", number: "67%", change: "Of shortlisted candidates", icon: "calendar", color: .plagitOnline)

                        // Response Time
                        insightCard(title: "Avg Response Time", number: "2.4h", change: "Faster than 80% of businesses", icon: "clock", color: .plagitTeal)

                        // Top Sources
                        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                            Text("Top Performing Job").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

                            HStack(spacing: PlagitSpacing.md) {
                                Circle().fill(LinearGradient(colors: [Color(hue: 0.55, saturation: 0.45, brightness: 0.90), Color(hue: 0.55, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 40, height: 40)
                                    .overlay(Text("NR").font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(.white))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Senior Chef").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                    Text("12 applicants · 48 views · 3 interviews").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                                }
                                Spacer()
                            }
                        }
                        .padding(PlagitSpacing.xxl)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                        .padding(.horizontal, PlagitSpacing.xl)
                    }
                    .padding(.top, PlagitSpacing.xs)
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func insightCard(title: String, number: String, change: String, icon: String, color: Color) -> some View {
        HStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(color.opacity(0.10)).frame(width: 48, height: 48)
                Image(systemName: icon).font(.system(size: 18, weight: .medium)).foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text(title).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                Text(number).font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text(change).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
            }

            Spacer()
        }
        .padding(PlagitSpacing.xxl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }
}

#Preview {
    NavigationStack { BusinessInsightsView() }.preferredColorScheme(.light)
}
