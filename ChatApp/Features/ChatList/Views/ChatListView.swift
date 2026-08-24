import SwiftUI

struct ChatListView: View {
    @StateObject var viewModel: ChatListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView(title: "Loading conversations")
            } else if viewModel.isEmpty {
                EmptyStateView(title: "No conversations", message: "Start a conversation or adjust your search.", retryTitle: "Retry", retry: viewModel.retry)
            } else {
                List(viewModel.filteredConversations) { conversation in
                    ChatListCell(conversation: conversation)
                        .contentShape(Rectangle())
                        .onTapGesture { viewModel.open(conversation) }
                }
                .listStyle(.plain)
                .refreshable { await viewModel.refresh() }
                .searchable(text: $viewModel.searchText, prompt: "Search users")
            }
        }
        .navigationTitle("Chats")
        .overlay(alignment: .bottom) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
        .onAppear { viewModel.load() }
    }
}
