//
//  ChatPresenter.swift
//  tgClone
//
//  Created by Андрей Чучупал on 24.10.2025.
//

import UIKit

// MARK: - Chat Presenter Protocol

protocol ChatPresenterProtocol: AnyObject {
    var view: ChatViewProtocol? { get set }
    func viewDidLoad()
    func didTapAttachment()
    func didSendMessage(_ text: String)
    func didTapVoice()
    func didTapSticker()
}

// MARK: - Chat Presenter

final class ChatPresenter: ChatPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: ChatViewProtocol?
    private var messages: [MessageModel]
    
    // MARK: - Initialization
    
    init(messages: [MessageModel]) {
        self.messages = messages
    }
}

// MARK: - Lifecycle

extension ChatPresenter {
    func viewDidLoad() {
        view?.displayMessages(messages)
    }
}

// MARK: - Message Actions

extension ChatPresenter {
    func didSendMessage(_ text: String) {
        let newMessage = MessageModel(role: .user, text: text, date: Date())
        messages.append(newMessage)
        view?.displayMessages(messages)
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
