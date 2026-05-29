import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showStickerBook = false
    @State private var showDevMenu = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 48) {
                Spacer()

                Text("Hockey Scribe")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("Hi, \(appState.childName)! 🏒")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))

                Spacer()

                Button(action: {
                    appState.pickNextTeam()
                }) {
                    Text("PLAY")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 320, height: 120)
                        .background(Color.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .yellow.opacity(0.5), radius: 20, y: 8)
                }

                Button(action: { showStickerBook = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Sticker Book")
                            .foregroundColor(.white)
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .frame(width: 320, height: 80)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }

                Spacer()

                Text("\(appState.completedTeamIDs.count) / 32 teams")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 24)
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: { showDevMenu = true }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(20)
                    }
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showStickerBook) {
            StickerBookView()
                .environmentObject(appState)
        }
        .onReceive(appState.$openStickerBookOnHome) { shouldOpen in
            if shouldOpen {
                showStickerBook = true
                appState.openStickerBookOnHome = false
            }
        }
        .alert("Developer Menu", isPresented: $showDevMenu) {
            Button("Reset App", role: .destructive) {
                UserDefaults.standard.removeObject(forKey: "childName")
                UserDefaults.standard.removeObject(forKey: "completedTeamIDs")
                appState.childName = ""
                appState.completedTeamIDs = []
                appState.sessionPhase = .home
            }
            Button("Complete 31 Teams") {
                let ids = Set(allNHLTeams.filter { $0.id != "DET" }.map(\.id))
                appState.completedTeamIDs = ids
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose an option")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
