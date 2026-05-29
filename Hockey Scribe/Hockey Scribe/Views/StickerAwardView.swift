import SwiftUI

struct StickerAwardView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var logoScale: CGFloat = 0.1
    @State private var logoOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var labelOpacity: Double = 0
    @State private var shrinking = false
    @State private var buttonsVisible = false
    @State private var openStickerBook = false

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
                .scaleEffect(shrinking ? 0.5 : 1.0)
                .opacity(shrinking ? 0 : labelOpacity)

                Spacer()

                if buttonsVisible {
                    VStack(spacing: 16) {
                        Button(" See my stickers! ") {
                            navigate(openStickerBook: true)
                        }
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .frame(width: 340, height: 84)
                        .background(Color.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .yellow.opacity(0.5), radius: 16, y: 6)

                        Button("Keep playing!") {
                            navigate(openStickerBook: false)
                        }
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 48)
                } else {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow.opacity(0.3))
                        .padding(.bottom, 48)
                        .opacity(buttonsVisible ? 0 : 1)
                }
            }
        }
        .onAppear { runAnimation() }
    }

    private func navigate(openStickerBook: Bool) {
        withAnimation(.easeIn(duration: 0.4)) {
            shrinking = true
            buttonsVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appState.markCurrentTeamCompleted()
            appState.currentGoalie = nil
            appState.currentTeam = nil
            appState.tracingSnapshot = nil
            appState.openStickerBookOnHome = openStickerBook
            appState.sessionPhase = .home
        }
    }

    private func runAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
            glowRadius = 30
        }
        withAnimation(.easeInOut(duration: 0.5).delay(1.1)) {
            glowRadius = 8
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
            labelOpacity = 1.0
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.6)) {
            buttonsVisible = true
        }
    }
}

#Preview {
    StickerAwardView(team: allNHLTeams[0])
        .environmentObject(AppState())
}
