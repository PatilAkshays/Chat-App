import SwiftUI

struct ContentView: View {
    var body: some View {
        AppRootView(container: DIContainer(useMocks: true))
    }
}

#Preview {
    ContentView()
}
