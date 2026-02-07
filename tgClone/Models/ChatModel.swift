//
//  ChatModel.swift
//  tgClone
//
//  Created by Андрей Чучупал on 22.10.2025.
//

import Foundation

enum ChatRoles {
    case user, friend
}

struct ChatListModel: Hashable {
    let id = UUID()
    let name: String
    let avatar: String
    let messages: [MessageModel]
    let isPinned: Bool
}

struct MessageModel: Hashable {
    let role: ChatRoles
    let text: String
    let date: Date
}
