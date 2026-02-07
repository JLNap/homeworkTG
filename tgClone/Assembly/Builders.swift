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
    static func build(chat: ChatList) -> UIViewController {
        
        let presenter = ChatPresenter(chat: chat)
        let viewController = ChatViewController()
        
        viewController.configure(with: presenter, chatModel: chat)
        presenter.view = viewController
        
        return viewController
    }
}

// MARK: - No action
final class NoActionBuilder {
    static func build() {
        print("no action")
    }
}
