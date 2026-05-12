import SwiftUI

struct NameEntryView: View {
    @EnvironmentObject var appState: AppState
    @State private var nameInput: String = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ZStack {
            // Ice-rink blue background
            Color(hex: "0A2D5E")
                .ignoresSafeArea()

            VStack(spacing: 48) {

                // Hockey puck icon
                Text("🏒")
                    .font(.system(size: 120))

                // Headline
                Text("What's your name?")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Name field
                TextField("Type your name here", text: $nameInput)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(Color.white)
                    .cornerRadius(24)
                    .foregroundColor(Color(hex: "0A2D5E"))
                    .frame(maxWidth: 600)
                    .focused($fieldFocused)
                    .onAppear { fieldFocused = true }
                    .submitLabel(.done)
                    .onSubmit { saveName() }

                // Let's Play button
                Button(action: saveName) {
                    Text("Let's Play! 🎉")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: "0A2D5E"))
                        .padding(.vertical, 22)
                        .padding(.horizontal, 56)
                        .background(Color(hex: "FFB81C"))
                        .cornerRadius(28)
                }
                .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: nameInput)
            }
            .padding(48)
        }
    }

    private func saveName() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        appState.childName = trimmed
    }
}

#Preview {
    NameEntryView()
        .environmentObject(AppState())
}
