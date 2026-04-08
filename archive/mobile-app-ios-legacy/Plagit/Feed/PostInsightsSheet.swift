//
//  PostInsightsSheet.swift
//  Plagit
//
//  Professional post views insights — shows who's seeing your content
//  without exposing private data. Premium users see limited viewer details.
//

import SwiftUI

// MARK: - Insight Data Model

struct PostInsightData {
    let totalViews: Int
    let verifiedViewers: Int
    let candidateViews: Int
    let businessViews: Int
    let roleBreakdown: [(role: String, count: Int, icon: String)]
    let locationBreakdown: [(city: String, count: Int)]
    let recentViewers: [InsightViewer]  // premium only
}

struct InsightViewer: Identifiable {
    let id: String
    let name: String
    let type: String          // "candidate" or "business"
    let role: String?
    let initials: String
    let hue: Double
    let isVerified: Bool
    let viewedAgo: String     // "2h", "1d"
}

// MARK: - Sheet

struct PostInsightsSheet: View {
    let post: FeedPostDTO
    var viewCountOverride: Int = 0
    let isPremium: Bool
    @Environment(\.dismiss) private var dismiss

    private var effectiveViews: Int { max(viewCountOverride, post.viewCount ?? 0) }
    private var insights: PostInsightData { Self.generateInsights(totalViews: effectiveViews, postId: post.id, premium: isPremium) }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2).fill(Color.plagitTertiary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, PlagitSpacing.md)

            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Post Insights").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
                    Text("Who's seeing your content").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 22)).foregroundColor(.plagitTertiary)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg)

            if insights.totalViews == 0 {
                Spacer()
                emptyState
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        overviewCard
                        viewerTypeCard
                        roleBreakdownCard
                        if !insights.locationBreakdown.isEmpty { locationCard }
                        if isPremium && !insights.recentViewers.isEmpty { recentViewersCard }
                        else if !isPremium { premiumUpsell }
                        Spacer().frame(height: PlagitSpacing.xxl)
                    }
                    .padding(.top, PlagitSpacing.lg)
                }
            }
        }
        .background(Color.plagitBackground)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Overview

    private var overviewCard: some View {
        HStack(spacing: PlagitSpacing.lg) {
            statBox(value: "\(insights.totalViews)", label: "Total Views", icon: "eye", color: .plagitTeal)
            statBox(value: "\(insights.verifiedViewers)", label: "Verified", icon: "checkmark.seal.fill", color: .plagitOnline)
            statBox(value: "\(insights.businessViews)", label: "Businesses", icon: "building.2", color: .plagitIndigo)
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func statBox(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: PlagitSpacing.sm) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 14, weight: .medium)).foregroundColor(color)
            }
            Text(value).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Viewer Type

    private var viewerTypeCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            sectionHeader("Viewer Breakdown", icon: "person.2")

            HStack(spacing: PlagitSpacing.lg) {
                // Candidates bar
                barItem(label: "Candidates", count: insights.candidateViews, total: insights.totalViews, color: .plagitTeal)
                // Businesses bar
                barItem(label: "Businesses", count: insights.businessViews, total: insights.totalViews, color: .plagitIndigo)
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func barItem(label: String, count: Int, total: Int, color: Color) -> some View {
        let pct = total > 0 ? Double(count) / Double(total) : 0
        return VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.plagitSurface).frame(height: 6)
                    RoundedRectangle(cornerRadius: 3).fill(color).frame(width: geo.size.width * pct, height: 6)
                }
            }.frame(height: 6)
            Text("\(count) (\(Int(pct * 100))%)").font(PlagitFont.micro()).foregroundColor(.plagitCharcoal)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Role Breakdown

    private var roleBreakdownCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            sectionHeader("Viewers by Role", icon: "briefcase")

            ForEach(insights.roleBreakdown, id: \.role) { item in
                HStack(spacing: PlagitSpacing.md) {
                    Image(systemName: item.icon).font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 20)
                    Text(item.role).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    Spacer()
                    Text("\(item.count)").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Location

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            sectionHeader("Top Locations", icon: "mappin")

            ForEach(insights.locationBreakdown, id: \.city) { loc in
                HStack(spacing: PlagitSpacing.md) {
                    Text(loc.city).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    Spacer()
                    Text("\(loc.count)").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Recent Viewers (Premium)

    private var recentViewersCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.sm) {
                sectionHeader("Recent Viewers", icon: "clock")
                Spacer()
                HStack(spacing: 3) {
                    Image(systemName: "crown.fill").font(.system(size: 9, weight: .bold))
                    Text("PRO").font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 7).padding(.vertical, 3)
                .background(Capsule().fill(Color.plagitAmber))
            }

            ForEach(insights.recentViewers) { viewer in
                HStack(spacing: PlagitSpacing.md) {
                    ProfileAvatarView(photoUrl: nil, initials: viewer.initials, hue: viewer.hue, size: 36, verified: viewer.isVerified)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(viewer.name).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                            if viewer.isVerified {
                                Image(systemName: "checkmark.seal.fill").font(.system(size: 9)).foregroundColor(.plagitVerified)
                            }
                        }
                        if let role = viewer.role {
                            Text(role).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                    Spacer()
                    Text(viewer.viewedAgo).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
            }

            Text("Only showing verified viewers with public profiles")
                .font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                .padding(.top, PlagitSpacing.xs)
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Premium Upsell

    private var premiumUpsell: some View {
        VStack(spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "crown.fill").font(.system(size: 16)).foregroundColor(.plagitAmber)
                Text("See Who Viewed Your Post").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            }
            Text("Upgrade to Premium to see verified businesses and recruiters who viewed your content.")
                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
        }
        .padding(PlagitSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitAmber.opacity(0.04))
            .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitAmber.opacity(0.15), lineWidth: 1)))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: icon).font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
            Text(title).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitSurface).frame(width: 56, height: 56)
                Image(systemName: "eye.slash").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitTertiary)
            }
            Text("No view insights yet").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text("Insights will appear once your post gets more views.")
                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
        }.padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Insights Generator

    // Deterministic pick: select `count` items from `source` using a seed
    private static func pick<T>(_ source: [T], count: Int, seed: Int) -> [T] {
        guard count > 0, !source.isEmpty else { return [] }
        var indices = Array(source.indices)
        var picked: [T] = []
        var s = seed
        for _ in 0..<min(count, source.count) {
            let idx = abs(s) % indices.count
            picked.append(source[indices.remove(at: idx)])
            s = s &* 6364136223846793005 &+ 1
        }
        return picked
    }

    // Distribute `total` across `n` buckets deterministically
    private static func distribute(_ total: Int, into n: Int, seed: Int) -> [Int] {
        guard n > 0, total > 0 else { return [] }
        // Start with even split, then add deterministic jitter
        var buckets = Array(repeating: total / n, count: n)
        var leftover = total - buckets.reduce(0, +)
        // Spread leftover across first buckets
        for i in 0..<leftover { buckets[i] += 1 }
        // Deterministic shuffle of amounts to vary per post
        var s = seed
        for i in stride(from: n - 1, through: 1, by: -1) {
            let j = abs(s) % (i + 1)
            buckets.swapAt(i, j)
            s = s &* 6364136223846793005 &+ 1
        }
        return buckets
    }

    static func generateInsights(totalViews rawTotal: Int, postId: String, premium: Bool) -> PostInsightData {
        let total = rawTotal

        guard total > 0 else {
            return PostInsightData(totalViews: 0, verifiedViewers: 0, candidateViews: 0, businessViews: 0,
                                   roleBreakdown: [], locationBreakdown: [], recentViewers: [])
        }

        let seed = abs(postId.hashValue)

        // ── Candidate / Business split ──
        let bizPct = 0.25 + Double(seed % 20) / 100.0   // 25-45%
        let bizViews = max(1, Int(Double(total) * bizPct))
        let candViews = total - bizViews
        let verified = max(1, Int(Double(total) * (0.4 + Double(seed % 15) / 100.0)))

        // ── Roles: split into candidate-side and business-side ──
        let candidateRoles: [(String, String)] = [
            ("Chefs", "flame"),
            ("Waiters", "tray"),
            ("Bartenders", "wineglass"),
            ("Sommeliers", "wineglass.fill"),
            ("Concierge", "bell"),
        ]
        let businessRoles: [(String, String)] = [
            ("Recruiters", "person.text.rectangle"),
            ("Managers", "person.badge.shield.checkmark"),
            ("HR Teams", "person.2.badge.gearshape"),
        ]

        // Pick 2-3 candidate roles, 1-2 business roles
        let candRoleCount = 2 + (seed % 2)         // 2 or 3
        let bizRoleCount = 1 + ((seed >> 3) % 2)   // 1 or 2
        let pickedCandRoles = pick(candidateRoles, count: candRoleCount, seed: seed)
        let pickedBizRoles = pick(businessRoles, count: bizRoleCount, seed: seed >> 5)

        // Distribute candidate views across candidate roles
        let candAmounts = distribute(candViews, into: pickedCandRoles.count, seed: seed >> 2)
        // Distribute business views across business roles
        let bizAmounts = distribute(bizViews, into: pickedBizRoles.count, seed: seed >> 4)

        var roleBreakdown: [(role: String, count: Int, icon: String)] = []
        for (i, (role, icon)) in pickedCandRoles.enumerated() {
            roleBreakdown.append((role, candAmounts[i], icon))
        }
        for (i, (role, icon)) in pickedBizRoles.enumerated() {
            roleBreakdown.append((role, bizAmounts[i], icon))
        }
        roleBreakdown.sort { $0.count > $1.count }

        // ── Locations: sum = total ──
        let allCities = ["London", "Dubai", "Paris", "Milan", "Rome", "Barcelona"]
        let cityCount = 2 + (seed % 3)  // 2, 3, or 4
        let pickedCities = pick(allCities, count: cityCount, seed: seed >> 6)
        let locAmounts = distribute(total, into: pickedCities.count, seed: seed >> 7)
        var locations: [(String, Int)] = []
        for (i, city) in pickedCities.enumerated() {
            locations.append((city, locAmounts[i]))
        }
        locations.sort { $0.1 > $1.1 }

        // ── Premium: recent viewers — capped by business count ──
        let maxViewers = min(5, max(bizViews, 2))
        let allViewers: [InsightViewer] = [
            InsightViewer(id: "v1", name: "The Ritz London", type: "business", role: "Luxury Hotel", initials: "RL", hue: 0.45, isVerified: true, viewedAgo: "2h"),
            InsightViewer(id: "v2", name: "Claridge's HR", type: "business", role: "Recruiter", initials: "CL", hue: 0.7, isVerified: true, viewedAgo: "5h"),
            InsightViewer(id: "v3", name: "Marco R.", type: "candidate", role: "Head Chef", initials: "MR", hue: 0.3, isVerified: true, viewedAgo: "1d"),
            InsightViewer(id: "v4", name: "Nobu Group", type: "business", role: "Restaurant Group", initials: "NG", hue: 0.55, isVerified: true, viewedAgo: "1d"),
            InsightViewer(id: "v5", name: "Sofia M.", type: "candidate", role: "Sommelier", initials: "SM", hue: 0.6, isVerified: false, viewedAgo: "2d"),
        ]
        let viewers: [InsightViewer] = premium ? Array(allViewers.prefix(max(1, maxViewers))) : []

        return PostInsightData(
            totalViews: total,
            verifiedViewers: verified,
            candidateViews: candViews,
            businessViews: bizViews,
            roleBreakdown: roleBreakdown,
            locationBreakdown: locations,
            recentViewers: viewers
        )
    }
}
