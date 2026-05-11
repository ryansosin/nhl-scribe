import SwiftUI

/// Root router — swaps between name entry, home, and session screens.
struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if !appState.isNameEntered {
                Text("Name Entry — coming in Step 2")
                    .font(.largeTitle)
            } else {
                Text("Home Screen — coming in Step 3")
                    .font(.largeTitle)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
