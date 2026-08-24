import SwiftUI

struct AppRootView: View {
    @StateObject private var coordinator: AppCoordinator

    init(container: DIContainer) {
        _coordinator = StateObject(wrappedValue: AppCoordinator(container: container))
    }

    var body: some View {
        Group {
            switch coordinator.flow {
            case .launching:
                LoadingView(title: "Starting ChatApp")
            case .auth:
                AuthFlowView(coordinator: coordinator.authCoordinator)
            case .main:
                MainFlowView(appCoordinator: coordinator)
            }
        }
        .task {
            coordinator.start()
        }
    }
}
