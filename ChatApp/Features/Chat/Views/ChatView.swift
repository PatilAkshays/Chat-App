import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                LoadingView(title: "Loading messages")
            } else if viewModel.messages.isEmpty {
                EmptyStateView(title: "No messages", message: "Send the first message in this conversation.", retryTitle: "Retry", retry: viewModel.retry)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            if viewModel.isLoadingOlderMessages {
                                ProgressView()
                                    .padding(.vertical, 8)
                            }
                            ForEach(viewModel.messages) { message in
                                MessageCell(message: message, isCurrentUser: message.senderId == "current-user")
                                    .id(message.id)
                                    .task {
                                        if message.id == viewModel.messages.first?.id {
                                            await viewModel.loadOlderMessages()
                                        }
                                    }
                            }
                            if viewModel.isTyping {
                                TypingIndicatorView()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let id = viewModel.messages.last?.id {
                            withAnimation { proxy.scrollTo(id, anchor: .bottom) }
                        }
                    }
                }
            }

            ChatInputView(text: $viewModel.inputText, send: viewModel.send, typingChanged: viewModel.updateTyping)
        }
        .navigationTitle(viewModel.conversation.displayUser?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .top) {
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
