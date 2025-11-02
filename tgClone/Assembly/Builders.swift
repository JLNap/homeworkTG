//
//  ChatListBuilder.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit

// MARK: - Chat List Builder
final class ChatListBuilder {
    static func build() -> UIViewController {
        let networkManager = ChatNetworkManager.shared
        let router = ChatListRouter()
        let presenter = ChatListPresenter(networkManager: networkManager, router: router)
        let viewController = ChatListViewController()
        
        viewController.configure(with: presenter)
        presenter.view = viewController
        router.viewController = viewController
        
        return viewController
    }
}

// MARK: - Chat Builder
final class ChatBuilder {
    static func build(with messages: [MessageModel], chatModel: ChatListModel) -> UIViewController {
        let presenter = ChatPresenter(messages: messages)
        let viewController = ChatViewController()
        
        viewController.configure(with: presenter, chatModel: chatModel)
        presenter.view = viewController
        
        return viewController
    }
    
    static func build(with messages: [MessageModel]) -> UIViewController {
        let mockChatModel = ChatListModel(
            name: "Unknown Chat",
            avatar: "",
            messages: messages,
            isPinned: false
        )
        
        return build(with: messages, chatModel: mockChatModel)
    }
}

// MARK: - No action
final class NoActionBuilder {
    static func build() {
        print("no action")
    }
}
