import SwiftUI

@main
struct ChatAppApp: App {
    private let container = DIContainer(useMocks: true)

    var body: some Scene {
        WindowGroup {
            AppRootView(container: container)
        }
    }
}
