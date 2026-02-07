//
//  ChatListPresenter.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit

protocol ChatListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectChat(at index: Int)
    func didRequestContextMenu(for index: Int) -> ChatList
    func handleSwipeAction(_ action: SwipeAction, at index: Int)
    func didTapCompose()
    func didSelectTab(at index: Int)
    func didSearchTextChange(_ text: String)
}

enum SwipeAction {
    case mute, delete, archive, unread, pin
}

final class ChatListPresenter: ChatListPresenterProtocol {
    
    weak var view: ChatListViewProtocol?
    private let networkManager: ChatNetworkManagerProtocol
    private let router: ChatListRouterProtocol
    private var chats: [ChatList] = []
    
    init(networkManager: ChatNetworkManagerProtocol, router: ChatListRouterProtocol) {
        self.networkManager = networkManager
        self.router = router
    }
    
    private func loadChats() {
        self.chats = CoreDataManager.shared.fetchChatLists()
        view?.showChats(chats)
    }
}

extension ChatListPresenter {
    func viewDidLoad() {
        loadChats()
    }
}

extension ChatListPresenter {
    func didSelectChat(at index: Int) {
        let selectedChat = chats[index]
        router.navigateToChat(chat: selectedChat)
    }
    
    func didRequestContextMenu(for index: Int) -> ChatList {
        return chats[index]
    }
}

extension ChatListPresenter {
    func handleSwipeAction(_ action: SwipeAction, at index: Int) {
        let chat = chats[index]
        switch action {
        case .mute:
            print("Mute chat: \(chat.name ?? "")")
        case .delete:
            CoreDataManager.shared.deleteChatList(chat)
            chats.remove(at: index)
            view?.showChats(chats)
        case .archive:
            print("Archive chat: \(chat.name ?? "")")
        case .unread:
            print("Mark as unread: \(chat.name ?? "")")
        case .pin:
            CoreDataManager.shared.togglePin(for: chat)
            loadChats()
        }
    }
    
    func didTapCompose() {
        router.presentNewChat { [weak self] in
            self?.loadChats()
        }
    }
    
    func didSelectTab(at index: Int) {
        
    }
    
    func didSearchTextChange(_ text: String) {
        
    }
}
