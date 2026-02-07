//
//  ChatNetworkManagerProtocol.swift
//  tgClone
//
//  Created by Андрей Чучупал on 23.10.2025.
//


import Foundation

protocol ChatNetworkManagerProtocol {
    func fetchChatList(completion: @escaping (Result<[ChatListModel], Error>) -> Void)
    func fetchMessages(for chatId: String, completion: @escaping (Result<[MessageModel], Error>) -> Void)
}

final class ChatNetworkManager: ChatNetworkManagerProtocol {
    static let shared = ChatNetworkManager()
    
    private init() {}
    
    func fetchChatList(completion: @escaping (Result<[ChatListModel], Error>) -> Void) {
            MockDataService.shared.fetchChatList(completion: completion)
    }
    
    func fetchMessages(for chatId: String, completion: @escaping (Result<[MessageModel], Error>) -> Void) {
        MockDataService.shared.fetchMessages(for: chatId, completion: completion)
    }
}

// MARK: - Mock Data Service
final class MockDataService: ChatNetworkManagerProtocol {
    static let shared = MockDataService()
    
    private init() {}
    
    private let mockChatList: [ChatListModel] = [
        ChatListModel(
            name: "firstriend",
            avatar: "ava1",
            messages: [
                MessageModel(role: .friend, text: "Первый чат", date: Date()),
                MessageModel(role: .user, text: "Тест огромных сообщенийТест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений  ", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date()),
                MessageModel(role: .friend, text: "Конец первого чата", date: Date())
            ],
            isPinned: true
        ),
        ChatListModel(
            name: "secondriend",
            avatar: "ava2",
            messages: [
                MessageModel(role: .friend, text: "Второй чат", date: Date()),
                MessageModel(role: .user, text: "Тест огромных сообщенийТест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений  ", date: Date()),
                MessageModel(role: .friend, text: "Конец второго чата", date: Date())
            ],
            isPinned: false
        ),
        ChatListModel(
            name: "thirdFriend",
            avatar: "ava3",
            messages: [
                MessageModel(role: .friend, text: "Третий чат", date: Date()),
                MessageModel(role: .user, text: "Тест огромных сообщенийТест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений Тест огромных сообщений  ", date: Date()),
                MessageModel(role: .friend, text: "Конец третьего чата", date: Date())
            ],
            isPinned: false
        )
    ]
    
    func fetchChatList(completion: @escaping (Result<[ChatListModel], Error>) -> Void) {
        DispatchQueue.main.async {
            completion(.success(self.mockChatList))
        }
    }
    
    func fetchMessages(for chatId: String, completion: @escaping (Result<[MessageModel], Error>) -> Void) {
        DispatchQueue.main.async{
            if let chat = self.mockChatList.first(where: { $0.name == chatId }) {
                completion(.success(chat.messages))
            } else {
                completion(.failure(NetworkError.chatNotFound))
            }
        }
    }
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case noData
    case chatNotFound
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No data received"
        case .chatNotFound:
            return "Chat not found"
        case .invalidResponse:
            return "Invalid response"
        }
    }
}
