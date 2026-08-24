import SwiftUI

struct ChatListCell: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(user: conversation.displayUser, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(conversation.displayUser?.name ?? "Unknown User")
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    if let date = conversation.lastMessage?.createdAt {
                        Text(date.chatTimestamp)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack(spacing: 8) {
                    Text(conversation.lastMessage?.text ?? "Image")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Color.accentColor, in: Capsule())
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
