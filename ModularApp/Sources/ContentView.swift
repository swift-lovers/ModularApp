import SwiftUI
import CoreUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
        }
    }
}

// MARK: - Home Tab

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Welcome to ModularApp")
                    .font(Theme.titleFont)

                Text("This app demonstrates modular iOS architecture with RepoSync.")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.secondaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                PrimaryButton(title: "Get Started") {
                    print("Button tapped!")
                }
                .padding(.horizontal, 32)
            }
            .navigationTitle("Home")
        }
    }
}

// MARK: - Settings Tab

struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Modules") {
                    Label("CoreNetwork", systemImage: "network")
                    Label("CoreUI", systemImage: "paintbrush")
                    Label("Feature-Home", systemImage: "house")
                }
                Section("About") {
                    Label("Version 1.0.0", systemImage: "info.circle")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
