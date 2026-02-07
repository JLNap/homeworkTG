//
//  ChatPresenter.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit
import CoreData

// MARK: - Chat Presenter Protocol

protocol ChatPresenterProtocol: AnyObject {
    var view: ChatViewProtocol? { get set }
    func viewDidLoad()
    func didTapAttachment()
    func didSendMessage(_ text: String, role: String)
    func didTapVoice()
    func didTapSticker()
}

// MARK: - Chat Presenter

final class ChatPresenter: ChatPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: ChatViewProtocol?
    private var messages: [Chat] = []
    private let currentChat: ChatList
    
    // MARK: - Initialization
    
    init(chat: ChatList) {
        self.currentChat = chat
    }
}

// MARK: - Lifecycle

extension ChatPresenter {
    func viewDidLoad() {
        fetchMessages()
    }
    
    private func fetchMessages() {
        self.messages = CoreDataManager.shared.fetchMessages(for: currentChat)
        view?.displayMessages(messages)
    }
}
// MARK: - Message Actions

extension ChatPresenter {
    func didSendMessage(_ text: String, role: String) {
        guard !text.isEmpty else { return }
        
        CoreDataManager.shared.createMessage(text: text, role: role, for: currentChat)
        fetchMessages()
        
        view?.updateScrollContent()
    }
}

// MARK: - Input Actions

extension ChatPresenter {
    func didTapAttachment() {
        print("Attachment tapped")
    }
    
    func didTapVoice() {
        print("Voice message tapped")
    }
    
    func didTapSticker() {
        print("Sticker tapped")
    }
}
