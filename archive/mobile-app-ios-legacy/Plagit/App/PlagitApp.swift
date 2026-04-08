//
//  PlagitApp.swift
//  Plagit
//
//  Created by Mirko Picicco on 16/03/2026.
//

import SwiftUI

@main
struct PlagitApp: App {

    init() {
        SubscriptionManager.shared.startListening()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack { EntryView() }
        }
    }
}
