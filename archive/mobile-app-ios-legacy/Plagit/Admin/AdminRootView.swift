//
//  AdminRootView.swift
//  Plagit
//
//  Root view that switches between login and the admin area based on auth state.
//

import SwiftUI

struct AdminRootView: View {
    @State private var auth = AdminAuthService.shared

    var body: some View {
        Group {
            if auth.isRestoring {
                // Brief branded splash while validating the saved session
                ZStack {
                    Color.plagitBackground.ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image("PlagitLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        ProgressView()
                            .tint(.plagitTeal)
                    }
                }
            } else if auth.isAuthenticated {
                SuperAdminHomeView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button { auth.logout() } label: {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.plagitTertiary)
                            }
                        }
                    }
            } else {
                AdminLoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: auth.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: auth.isRestoring)
        .task { await auth.restoreSession() }
    }
}

#Preview {
    AdminRootView()
        .preferredColorScheme(.light)
}
