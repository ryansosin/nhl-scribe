import SwiftUI

struct StickerAwardView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var logoScale: CGFloat = 0.1
    @State private var logoOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var labelOpacity: Double = 0
    @State private var shrinking = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(team.primarySwiftUIColor.opacity(0.25))
                        .frame(width: 320, height: 320)
                        .scaleEffect(shrinking ? 0.1 : 1.0)
                        .blur(radius: glowRadius)

                    Image(team.logoAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 260)
                        .scaleEffect(shrinking ? 0.05 : logoScale)
                        .opacity(shrinking ? 0 : logoOpacity)
                }

                VStack(spacing: 8) {
                    Text("New Sticker!")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)

                    Text(team.fullName)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(labelOpacity)
                .scaleEffect(shrinking ? 0.5 : 1.0)
                .opacity(shrinking ? 0 : labelOpacity)

                Spacer()

                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow.opacity(shrinking ? 1.0 : 0.3))
                    .scaleEffect(shrinking ? 1.4 : 1.0)
                    .padding(.bottom, 48)
            }
        }
        .onAppear { runAnimation() }
    }

    private func runAnimation() {
        // Logo bounces in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Glow pulses
        withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
            glowRadius = 30
        }
        withAnimation(.easeInOut(duration: 0.5).delay(1.1)) {
            glowRadius = 8
        }

        // Label fades in
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            labelOpacity = 1.0
        }

        // Logo shrinks into the sticker book icon
        withAnimation(.easeIn(duration: 0.5).delay(2.2)) {
            shrinking = true
        }

        // Navigate home
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.9) {
            appState.markCurrentTeamCompleted()
            appState.currentGoalie = nil
            appState.currentTeam = nil
            appState.tracingSnapshot = nil
            appState.sessionPhase = .home
        }
    }
}

#Preview {
    StickerAwardView(team: allNHLTeams[0])
        .environmentObject(AppState())
}
