import SwiftUI

struct StickerBookView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(allNHLTeams) { team in
                            StickerCell(
                                team: team,
                                isCompleted: appState.completedTeamIDs.contains(team.id)
                            )
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Sticker Book")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}

private struct StickerCell: View {
    let team: NHLTeam
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(team.primarySwiftUIColor)
                        .overlay(
                            Circle()
                                .strokeBorder(team.secondarySwiftUIColor, lineWidth: 3)
                        )

                    Text(team.id)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 2)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 2)
                        )

                    Text(team.id)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.25))
                }
            }
            .aspectRatio(1, contentMode: .fit)

            if isCompleted {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
            } else {
                Spacer().frame(height: 12)
            }
        }
    }
}

#Preview {
    StickerBookView()
        .environmentObject({
            let s = AppState()
            s.completedTeamIDs = ["BOS", "TOR", "NYR", "MTL", "CHI", "DET"]
            return s
        }())
}
