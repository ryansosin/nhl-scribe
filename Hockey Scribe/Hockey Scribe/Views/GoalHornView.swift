import SwiftUI
import WebKit

struct GoalHornView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var showNextButton = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            YouTubePlayer(videoID: team.youtubeVideoID)
                .ignoresSafeArea()

            VStack {
                Spacer()

                if showNextButton {
                    Button("Next Team!") {
                        appState.markCurrentTeamCompleted()
                        appState.currentGoalie = nil
                        appState.currentTeam = nil
                        appState.sessionPhase = .home
                    }
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .frame(width: 280, height: 84)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .yellow.opacity(0.5), radius: 16, y: 6)
                    .padding(.bottom, 48)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showNextButton = true
                }
            }
        }
    }
}

private struct YouTubePlayer: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let web = WKWebView(frame: .zero, configuration: config)
        web.backgroundColor = .black
        web.scrollView.isScrollEnabled = false
        web.isOpaque = true

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
          * { margin:0; padding:0; background:#000; }
          iframe { width:100vw; height:100vh; border:none; }
        </style>
        </head>
        <body>
        <iframe src="https://www.youtube.com/embed/\(videoID)?autoplay=1&playsinline=1&controls=0&rel=0&modestbranding=1"
                allow="autoplay" allowfullscreen>
        </iframe>
        </body>
        </html>
        """
        web.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
