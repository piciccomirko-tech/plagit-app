//
//  HomeView.swift
//  Plagit
//
//  Ultra-Premium Home Screen
//

import SwiftUI

struct HomeView: View {
    @State private var selectedContentTab = 0
    @State private var showCreateMenu = false
    @State private var insightPulse = false
    @Namespace private var tabAnimation

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.plagitBackground
                .ignoresSafeArea()

            // Main scrollable content
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Top Header
                    headerSection

                    // 2. Hero Welcome
                    heroSection
                        .padding(.top, PlagitSpacing.xs)

                    // 3. Stats Cards
                    statsSection
                        .padding(.top, PlagitSpacing.sectionGap)

                    // 4. Quick Actions
                    quickActionsSection
                        .padding(.top, PlagitSpacing.sectionGap)

                    // 5. Content Tabs
                    contentTabsSection
                        .padding(.top, PlagitSpacing.xxxl)

                    // 6. Suggested Matches
                    suggestedMatchesSection
                        .padding(.top, PlagitSpacing.sectionGap)

                    // 7. Feed
                    feedSection
                        .padding(.top, PlagitSpacing.xxl)

                    // Bottom spacer for tab bar
                    Spacer()
                        .frame(height: 96)
                }
            }

            // 8. Bottom Navigation
            bottomNavigationBar

            // Create menu overlay
            if showCreateMenu {
                createMenuOverlay
            }
        }
    }

    // MARK: - 1. Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            // Plagit logo mark
            HStack(spacing: PlagitSpacing.sm) {
                RoundedRectangle(cornerRadius: PlagitRadius.sm)
                    .fill(Color.plagitTeal)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("P")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )

                Text("plagit")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.plagitCharcoal)
            }

            Spacer()

            // Right icons
            HStack(spacing: PlagitSpacing.xl) {
                // Notification bell
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.plagitCharcoal)

                    // Badge
                    Circle()
                        .fill(Color.plagitUrgent)
                        .frame(width: 7, height: 7)
                        .offset(x: 2, y: -2)
                }

                // Chat icon
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 19, weight: .regular))
                    .foregroundColor(.plagitCharcoal)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.xxl)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - 2. Hero Welcome

    private var heroSection: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: PlagitSpacing.xl) {
                // Top row with greeting and avatar
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                        Text("Welcome back, Mirko")
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.plagitTeal)
                            .textCase(.uppercase)
                            .tracking(1.4)

                        Text("Your next opportunity\nis waiting for you")
                            .font(PlagitFont.displayLarge())
                            .foregroundColor(.plagitCharcoal)
                            .lineSpacing(4)
                    }

                    Spacer()

                    // Profile avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.plagitTeal, Color.plagitTealDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 54, height: 54)

                        Text("MP")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        // Online indicator
                        Circle()
                            .fill(Color.plagitOnline)
                            .frame(width: 13, height: 13)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 19, y: 19)
                    }
                }

                Text("Find jobs, get discovered by employers, and land your next role.")
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitSecondary)
                    .lineSpacing(3)

                // Micro-insight
                HStack(spacing: PlagitSpacing.sm) {
                    Circle()
                        .fill(Color.plagitOnline)
                        .frame(width: 6, height: 6)
                        .opacity(insightPulse ? 1.0 : 0.4)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: insightPulse)

                    Text("3 employers viewed your profile this week")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitTeal)
                }
                .onAppear { insightPulse = true }
            }
            .padding(PlagitSpacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
            )
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 3. Stats Cards

    private var statsSection: some View {
        HStack(spacing: PlagitSpacing.md) {
            StatCard(number: "8", label: "Jobs For You", icon: "briefcase", color: .plagitTeal)
            StatCard(number: "3", label: "Applied", icon: "paperplane", color: .plagitAmber)
            StatCard(number: "28", label: "Profile Views", icon: "eye", color: .plagitIndigo)
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 4. Quick Actions

    private var quickActionsSection: some View {
        HStack(spacing: PlagitSpacing.md) {
            // Primary action - solid teal
            QuickActionButton(
                title: "Find Jobs",
                icon: "magnifyingglass",
                style: .primary
            )

            // Secondary actions
            QuickActionButton(
                title: "Quick Apply",
                icon: "doc.text",
                style: .secondary
            )

            QuickActionButton(
                title: "My CV",
                icon: "person.crop.circle",
                style: .secondary
            )
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 5. Content Tabs

    private var contentTabsSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(["For You", "Latest", "Activity"].enumerated()), id: \.offset) { index, title in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedContentTab = index
                        }
                    } label: {
                        VStack(spacing: PlagitSpacing.md) {
                            Text(title)
                                .font(PlagitFont.subheadline())
                                .foregroundColor(selectedContentTab == index ? .plagitCharcoal : .plagitTertiary)

                            // Indicator
                            ZStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)

                                if selectedContentTab == index {
                                    Rectangle()
                                        .fill(Color.plagitTeal)
                                        .frame(width: 28, height: 2)
                                        .clipShape(Capsule())
                                        .matchedGeometryEffect(id: "tabIndicator", in: tabAnimation)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)

            Rectangle()
                .fill(Color.plagitDivider)
                .frame(height: 1)
        }
    }

    // MARK: - 6. Recommended Jobs

    private var suggestedMatchesSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text("Recommended for You")
                    .font(PlagitFont.sectionTitle())
                    .foregroundColor(.plagitCharcoal)

                Spacer()

                HStack(spacing: 4) {
                    Text("See All")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.plagitTeal)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.md) {
                    ForEach(SampleData.recommendedJobs) { job in
                        RecommendedJobCard(job: job)
                    }
                }
                .padding(.horizontal, PlagitSpacing.xl)
            }
        }
    }

    // MARK: - 7. Feed

    private var feedSection: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ForEach(SampleData.feedPosts) { post in
                FeedCardView(post: post)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 8. Bottom Navigation Bar

    private var bottomNavigationBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.plagitDivider.opacity(0.5))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                BottomTabItem(icon: "house.fill", label: "Home", isActive: true)
                BottomTabItem(icon: "briefcase", label: "Jobs", isActive: false)

                // Center Create button
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        showCreateMenu.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.plagitTeal, Color.plagitTealDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .shadow(color: Color.plagitTeal.opacity(0.25), radius: 10, y: 3)

                        Image(systemName: showCreateMenu ? "xmark" : "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(showCreateMenu ? 90 : 0))
                    }
                    .offset(y: -6)
                }
                .frame(maxWidth: .infinity)

                BottomTabItem(icon: "bubble.left.and.bubble.right", label: "Messages", isActive: false)
                BottomTabItem(icon: "person.crop.circle", label: "Profile", isActive: false)
            }
            .padding(.horizontal, PlagitSpacing.md)
            .padding(.top, PlagitSpacing.sm)
            .padding(.bottom, PlagitSpacing.xxl)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: - Create Menu Overlay

    private var createMenuOverlay: some View {
        ZStack(alignment: .bottom) {
            // Dimmed background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        showCreateMenu = false
                    }
                }

            // Menu items
            VStack(spacing: PlagitSpacing.md) {
                CreateMenuItem(icon: "briefcase.fill", title: "Apply for Job", subtitle: "Browse open positions")
                CreateMenuItem(icon: "person.crop.circle", title: "Improve Profile", subtitle: "Stand out to employers")
                CreateMenuItem(icon: "doc.fill", title: "Upload CV", subtitle: "Get discovered faster")
                CreateMenuItem(icon: "camera.fill", title: "Add Story", subtitle: "Show your experience")
            }
            .padding(PlagitSpacing.xl)
            .padding(.bottom, 96)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xxl)
                    .fill(Color.plagitCardBackground)
                    .ignoresSafeArea(edges: .bottom)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let number: String
    let label: String
    let icon: String
    let color: Color

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(color)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(color.opacity(0.10))
                )

            Spacer().frame(height: PlagitSpacing.xs)

            // Number
            Text(number)
                .font(PlagitFont.statNumber())
                .foregroundColor(.plagitCharcoal)

            // Label
            Text(label)
                .font(PlagitFont.statLabel())
                .foregroundColor(.plagitSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PlagitSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.lg)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Quick Action Button

enum QuickActionStyle {
    case primary
    case secondary
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let style: QuickActionStyle

    @State private var isPressed = false

    var body: some View {
        Button {} label: {
            VStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))

                Text(title)
                    .font(PlagitFont.captionMedium())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PlagitSpacing.xl)
            .foregroundColor(style == .primary ? .white : .plagitTeal)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.lg)
                    .fill(style == .primary
                          ? AnyShapeStyle(LinearGradient(
                              colors: [Color.plagitTeal, Color.plagitTealDark],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                          ))
                          : AnyShapeStyle(Color.plagitTealSubtle)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlagitRadius.lg)
                    .stroke(
                        style == .secondary ? Color.plagitTeal.opacity(0.15) : Color.clear,
                        lineWidth: 0.5
                    )
            )
            .shadow(
                color: style == .primary ? Color.plagitTeal.opacity(0.18) : Color.clear,
                radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY
            )
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Recommended Job Card

struct RecommendedJobCard: View {
    let job: RecommendedJob

    var body: some View {
        HStack(spacing: PlagitSpacing.md) {
            // Company avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: job.avatarHue, saturation: 0.45, brightness: 0.90),
                                Color(hue: job.avatarHue, saturation: 0.55, brightness: 0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(job.initials)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )

                if job.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.plagitVerified)
                        .background(Circle().fill(.white).frame(width: 11, height: 11))
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text(job.jobTitle)
                    .font(PlagitFont.bodyMedium())
                    .foregroundColor(.plagitCharcoal)

                HStack(spacing: PlagitSpacing.xs) {
                    Text("\(job.company) · \(job.location)")
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitSecondary)

                    if job.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.plagitVerified)
                    }
                }

                Text(job.salary)
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitCharcoal)

                HStack(spacing: PlagitSpacing.xs) {
                    Text(job.employmentType)
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)

                    if !job.tag.isEmpty {
                        Text(job.tag)
                            .font(PlagitFont.micro())
                            .foregroundColor(.plagitAmber)
                            .padding(.horizontal, PlagitSpacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color.plagitAmber.opacity(0.10))
                            )
                    }
                }
            }

            Spacer()

            // CTA button
            Button {} label: {
                Text("Apply")
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.lg)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.plagitTealLight)
                    )
            }
        }
        .padding(PlagitSpacing.lg)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.lg)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        )
    }
}

// MARK: - Feed Card

struct FeedCardView: View {
    let post: FeedPost
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Author header
            HStack(spacing: PlagitSpacing.md) {
                // Avatar
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: post.avatarHue, saturation: 0.45, brightness: 0.90),
                                    Color(hue: post.avatarHue, saturation: 0.55, brightness: 0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(post.authorInitials)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )

                    if post.isOnline {
                        Circle()
                            .fill(Color.plagitOnline)
                            .frame(width: 11, height: 11)
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 1, y: 1)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: PlagitSpacing.xs) {
                        Text(post.authorName)
                            .font(PlagitFont.bodyMedium())
                            .foregroundColor(.plagitCharcoal)

                        if post.isVerified {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.plagitVerified)
                                Text("Verified")
                                    .font(PlagitFont.micro())
                                    .foregroundColor(.plagitVerified)
                            }
                        }
                    }

                    HStack(spacing: 4) {
                        Text(post.authorRole)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)

                        Text("·")
                            .foregroundColor(.plagitTertiary)

                        Text(post.authorCountry)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)

                        Text("·")
                            .foregroundColor(.plagitTertiary)

                        Text(post.timeAgo)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitTertiary)
                    }
                }

                Spacer()

                // More menu
                Button {} label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.plagitTertiary)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.xl)

            // Title
            Text(post.title)
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.lg)

            // Badges
            if !post.badges.isEmpty {
                HStack(spacing: PlagitSpacing.sm) {
                    ForEach(post.badges.prefix(2), id: \.self) { badge in
                        Text(badge)
                            .font(PlagitFont.micro())
                            .foregroundColor(badge == "Urgent" ? .plagitUrgent : .plagitTeal)
                            .lineLimit(1)
                            .padding(.horizontal, PlagitSpacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(
                                    (badge == "Urgent" ? Color.plagitUrgent : Color.plagitTeal).opacity(0.08)
                                )
                            )
                    }
                }
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.sm)
            }

            // Body
            Text(post.body)
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)
                .lineSpacing(4)
                .lineLimit(3)
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.sm)

            // Salary
            if !post.salary.isEmpty {
                Text(post.salary)
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.xs)
            }

            // Engagement stats
            HStack(spacing: PlagitSpacing.lg) {
                EngagementStat(icon: "heart", count: post.likes)
                EngagementStat(icon: "bubble.right", count: post.comments)
                EngagementStat(icon: "eye", count: post.views)

                Spacer()

                Button {} label: {
                    Image(systemName: "bookmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.plagitTertiary)
                }

                Button {} label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.plagitTertiary)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.lg)

            // Divider
            Rectangle()
                .fill(Color.plagitDivider)
                .frame(height: 1)
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.lg)

            // Action buttons
            HStack(spacing: PlagitSpacing.md) {
                FeedActionButton(label: post.primaryCTA, style: .primary)
                FeedActionButton(label: post.secondaryCTA, style: .secondary)
                FeedActionButton(label: post.tertiaryCTA, style: .secondary)
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.md)
            .padding(.bottom, PlagitSpacing.xl)
        }
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .scaleEffect(isPressed ? 0.985 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Engagement Stat

struct EngagementStat: View {
    let icon: String
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTertiary)

            Text("\(count)")
                .font(PlagitFont.caption())
                .foregroundColor(.plagitTertiary)
        }
    }
}

// MARK: - Feed Action Button

struct FeedActionButton: View {
    let label: String
    let style: QuickActionStyle

    var body: some View {
        Button {} label: {
            Text(label)
                .font(PlagitFont.captionMedium())
                .foregroundColor(style == .primary ? .white : .plagitTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(style == .primary ? Color.plagitTeal : Color.plagitTealLight)
                )
        }
    }
}

// MARK: - Bottom Tab Item

struct BottomTabItem: View {
    let icon: String
    let label: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: PlagitSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: isActive ? .medium : .regular))
                .foregroundColor(isActive ? .plagitTeal : .plagitTertiary)

            Text(label)
                .font(PlagitFont.tabLabel())
                .foregroundColor(isActive ? .plagitTeal : .plagitTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Create Menu Item

struct CreateMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        Button {} label: {
            HStack(spacing: PlagitSpacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.plagitTeal)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: PlagitRadius.md)
                            .fill(Color.plagitTealLight)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)

                    Text(subtitle)
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.lg)
                    .fill(Color.plagitSurface)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
