//
//  ChatListPresenter.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit

// MARK: - Chat List Protocol

protocol ChatListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectChat(at index: Int)
    func didRequestContextMenu(for index: Int) -> ChatListModel
    func handleSwipeAction(_ action: SwipeAction, at index: Int)
    func didTapCompose()
    func didSelectTab(at index: Int)
    func didSearchTextChange(_ text: String)
}

// MARK: - Swipe Actions

enum SwipeAction {
    case mute, delete, archive, unread, pin
}

// MARK: - Chat List Presenter

final class ChatListPresenter: ChatListPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: ChatListViewProtocol?
    private let networkManager: ChatNetworkManagerProtocol
    private let router: ChatListRouterProtocol
    private var chats: [ChatListModel] = []
    
    // MARK: - Initialization
    
    init(networkManager: ChatNetworkManagerProtocol, router: ChatListRouterProtocol) {
        self.networkManager = networkManager
        self.router = router
    }
}

// MARK: - Lifecycle

extension ChatListPresenter {
    func viewDidLoad() {
        view?.showLoading()
        networkManager.fetchChatList { [weak self] result in
            self?.view?.hideLoading()
            switch result {
            case .success(let chats):
                self?.chats = chats
                self?.view?.showChats(chats)
            case .failure(let error):
                self?.view?.showError(error.localizedDescription)
            }
        }
    }
}

// MARK: - Navigation

extension ChatListPresenter {
    func didSelectChat(at index: Int) {
        let selectedChat = chats[index]
        
        networkManager.fetchMessages(for: selectedChat.name) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.router.navigateToChat(with: messages, chatModel: selectedChat)
            case .failure(let error):
                self?.view?.showError(error.localizedDescription)
            }
        }
    }
    
    func didRequestContextMenu(for index: Int) -> ChatListModel {
        return chats[index]
    }
}

// MARK: - User Actions

extension ChatListPresenter {
    func handleSwipeAction(_ action: SwipeAction, at index: Int) {
        let chat = chats[index]
        switch action {
        case .mute:
            print("Mute chat: \(chat.name)")
        case .delete:
            print("Delete chat: \(chat.name)")
        case .archive:
            print("Archive chat: \(chat.name)")
        case .unread:
            print("Mark as unread: \(chat.name)")
        case .pin:
            print("Pin chat: \(chat.name)")
        }
    }
    
    func didTapCompose() {
        
    }
    
    func didSelectTab(at index: Int) {
        
    }
    
    func didSearchTextChange(_ text: String) {
        
    }
}
