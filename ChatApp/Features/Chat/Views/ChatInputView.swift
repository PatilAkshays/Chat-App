import SwiftUI

struct ChatInputView: View {
    @Binding var text: String
    let send: () -> Void
    let typingChanged: (Bool) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Button {} label: {
                Image(systemName: "photo")
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Attach image")

            TextField("Message", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.roundedBorder)
                .onChange(of: text) { newValue in
                    typingChanged(!newValue.isEmpty)
                }

            Button(action: send) {
                Image(systemName: "paperplane.fill")
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.borderedProminent)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityLabel("Send message")
        }
        .padding(12)
        .background(.bar)
    }
}

struct TypingIndicatorView: View {
    var body: some View {
        HStack {
            Text("Typing...")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemBackground), in: Capsule())
            Spacer()
        }
    }
}
