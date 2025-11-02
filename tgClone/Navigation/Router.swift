//
//  ChatListRouterProtocol.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit

// MARK: - Router
protocol ChatListRouterProtocol: AnyObject {
    func navigateToChat(with messages: [MessageModel], chatModel: ChatListModel)
    func noAction()
}

final class ChatListRouter: ChatListRouterProtocol {
    weak var viewController: UIViewController?
    
    func navigateToChat(with messages: [MessageModel], chatModel: ChatListModel) {
        let chatVC = ChatBuilder.build(with: messages, chatModel: chatModel)
        viewController?.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func noAction() {
        NoActionBuilder.build()
    }
}
