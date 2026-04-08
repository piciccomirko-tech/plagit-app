//
//  BusinessRootView.swift
//  Plagit
//
//  Root navigation for the business flow. Session restore, auth gating, splash.
//

import SwiftUI

struct BusinessRootView: View {
    private var auth = BusinessAuthService.shared

    var body: some View {
        Group {
            if auth.isRestoring {
                splashView
            } else if auth.isAuthenticated {
                BusinessHomeView()
                    .navigationBarHidden(true)
            } else {
                BusinessAuthView()
                    .navigationBarHidden(true)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: auth.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: auth.isRestoring)
        .task { await auth.restoreSession() }
        .onAppear {
            LocationManager.shared.onLocationAcquired = { lat, lng in
                Task { try? await BusinessAPIService.shared.updateProfile(companyName: nil, venueType: nil, location: nil, phone: nil, latitude: lat, longitude: lng) }
            }
        }
    }

    private var splashView: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image("PlagitLogo")
                    .resizable().scaledToFit()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                ProgressView().tint(.plagitTeal)
            }
        }
    }
}
