import SwiftUI
import WebKit

struct GoalHornView: View {
    @EnvironmentObject var appState: AppState
    let team: NHLTeam

    @State private var showNextButton = false
    @State private var startupOverlay = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            YouTubePlayer(videoID: team.youtubeVideoID, startTime: team.youtubeStartTime)
                .ignoresSafeArea()

            // Swallow taps so they can't reach the iframe and trigger pause/controls.
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .allowsHitTesting(true)

            // Hide YouTube's startup overlay until the video is playing.
            Color.black
                .ignoresSafeArea()
                .opacity(startupOverlay ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: startupOverlay)
                .allowsHitTesting(false)
        }
        .safeAreaInset(edge: .bottom) {
            if showNextButton {
                Button("Get your sticker!") {
                    appState.sessionPhase = .stickerAward
                }
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.black)
                .frame(width: 280, height: 84)
                .background(Color.yellow)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .yellow.opacity(0.5), radius: 16, y: 6)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                startupOverlay = false
            }
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
    let startTime: Int

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let web = WKWebView(frame: .zero, configuration: config)
        web.scrollView.isScrollEnabled = false
        web.allowsLinkPreview = false
        web.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <style>
          html, body { margin:0; padding:0; background:#000; width:100%; height:100%; overflow:hidden; }
          iframe { position:fixed; top:0; left:0; width:100%; height:100%; border:none; }
        </style>
        </head>
        <body>
        <iframe src="https://www.youtube-nocookie.com/embed/\(videoID)?autoplay=1&playsinline=1&rel=0&modestbranding=1&enablejsapi=1&controls=0&start=\(startTime)"
                allow="autoplay; fullscreen" allowfullscreen>
        </iframe>
        </body>
        </html>
        """
        web.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
