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
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(team.primarySwiftUIColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(team.secondarySwiftUIColor, lineWidth: 3)
                        )

                    Image(team.logoAssetName)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 2)
                        )

                    Image(team.logoAssetName)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .colorMultiply(.white)
                        .opacity(0.15)
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
