//
//  CandidateRootView.swift
//  Plagit
//
//  Root navigation for the candidate flow. Handles session restore,
//  authentication gating, and the branded loading splash.
//

import SwiftUI

struct CandidateRootView: View {
    @Environment(\.dismiss) private var dismiss
    private var auth = CandidateAuthService.shared
    @State private var wasAuthenticated = false

    var body: some View {
        Group {
            if auth.isRestoring {
                splashView
            } else if auth.isAuthenticated {
                HomeView()
                    .navigationBarHidden(true)
            } else {
                CandidateAuthView()
                    .navigationBarHidden(true)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: auth.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: auth.isRestoring)
        .onChange(of: auth.isAuthenticated) { _, newValue in
            if wasAuthenticated && !newValue {
                // User logged out — pop back to EntryView
                dismiss()
            }
            wasAuthenticated = newValue
        }
        .task { await auth.restoreSession() }
        .onAppear {
            LocationManager.shared.onLocationAcquired = { lat, lng in
                Task { try? await CandidateAPIService.shared.updateProfile(latitude: lat, longitude: lng) }
            }
        }
    }

    private var splashView: some View {
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
    }
}
