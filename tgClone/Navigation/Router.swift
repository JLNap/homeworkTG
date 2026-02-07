//
//  ChatListRouterProtocol.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit

protocol ChatListRouterProtocol: AnyObject {
    func navigateToChat(chat: ChatList)
    func presentNewChat(completion: @escaping () -> Void)
    func noAction()
}

final class ChatListRouter: ChatListRouterProtocol {
    
    weak var viewController: UIViewController?
    
    func navigateToChat(chat: ChatList) {
        let chatVC = ChatBuilder.build(chat: chat)
        viewController?.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func presentNewChat(completion: @escaping () -> Void) {
        let newChatVC = NewChatViewController()
        newChatVC.onChatCreated = completion
        
        if let sheet = newChatVC.sheetPresentationController {
            
            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom { context in
                    return context.maximumDetentValue * 0.4
                }
                sheet.detents = [customDetent]
            } else {
                sheet.detents = [.medium()]
            }
            
            sheet.prefersGrabberVisible = true
        }
        
        viewController?.present(newChatVC, animated: true)
    }
    
    func noAction() {
        print("No action")
    }
}
