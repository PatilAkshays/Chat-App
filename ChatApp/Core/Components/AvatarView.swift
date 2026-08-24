import SwiftUI

struct AvatarView: View {
    let user: User?
    var size: CGFloat = 44

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.accentColor.opacity(0.18))
                .frame(width: size, height: size)
                .overlay {
                    Text(initials)
                        .font(.system(size: size * 0.36, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }

            if user?.isOnline == true {
                Circle()
                    .fill(Color.green)
                    .frame(width: size * 0.24, height: size * 0.24)
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
            }
        }
        .accessibilityLabel(user?.name ?? "Avatar")
    }

    private var initials: String {
        guard let name = user?.name else { return "?" }
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
    }
}
