import SwiftUI

struct SettingsView: View {
    let logout: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Button(role: .destructive, action: logout) {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                Section("App") {
                    Label("Push notifications enabled after permission", systemImage: "bell")
                    Label("Offline cache powered by Core Data", systemImage: "externaldrive")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
