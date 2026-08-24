import SwiftUI

struct MessageCell: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .bottom) {
            if isCurrentUser { Spacer(minLength: 48) }
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if let imageURL = message.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 180, height: 130)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 130)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure:
                            Image(systemName: "photo")
                                .frame(width: 180, height: 130)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                if let text = message.text, !text.isEmpty {
                    Text(text)
                        .font(.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .foregroundStyle(isCurrentUser ? .white : .primary)
                        .background(isCurrentUser ? Color.accentColor : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                }
                HStack(spacing: 4) {
                    Text(message.createdAt.chatTimestamp)
                    if isCurrentUser {
                        Image(systemName: iconName)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            if !isCurrentUser { Spacer(minLength: 48) }
        }
    }

    private var iconName: String {
        switch message.status {
        case .sending:
            return "clock"
        case .sent:
            return "checkmark"
        case .delivered:
            return "checkmark.circle"
        case .read:
            return "checkmark.circle.fill"
        case .failed:
            return "exclamationmark.circle"
        }
    }
}
