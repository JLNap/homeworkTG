//
//  CoreDataManager.swift
//  tgClone
//
//  Created by Андрей Чучупал on 07.02.2026.
//


import UIKit
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data Save Error: \(error)")
            }
        }
    }
    
    func createChatList(name: String, avatar: String?, isPinned: Bool) {
        let chatList = ChatList(context: context)
        chatList.id = UUID()
        chatList.name = name
        chatList.avatar = avatar
        chatList.isPinned = isPinned
        chatList.lastMessageDate = Date()
        
        save()
    }
    
    func createMessage(text: String, role: String, for chatList: ChatList) {
        let message = Chat(context: context)
        message.id = UUID()
        message.text = text
        message.role = role
        message.date = Date()
        
        chatList.addToChat(message)
        
        chatList.lastMessageDate = Date()
        
        save()
    }
    
    func fetchChatLists() -> [ChatList] {
        let request: NSFetchRequest<ChatList> = ChatList.fetchRequest()
        
        let sortPinned = NSSortDescriptor(key: "isPinned", ascending: false)
        let sortDate = NSSortDescriptor(key: "lastMessageDate", ascending: false)
        request.sortDescriptors = [sortPinned, sortDate]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Ошибка загрузки чатов: \(error)")
            return []
        }
    }
    
    func fetchMessages(for chatList: ChatList) -> [Chat] {
        
        guard let messagesSet = chatList.chat as? Set<Chat> else { return [] }
        
        let sortedMessages = messagesSet.sorted { msg1, msg2 in
            return (msg1.date ?? Date()) < (msg2.date ?? Date())
        }
        
        return sortedMessages
    }
    
    func togglePin(for chatList: ChatList) {
        chatList.isPinned.toggle()
        save()
    }
    
    func deleteChatList(_ chatList: ChatList) {
        context.delete(chatList)
        save()
    }
    
    func deleteMessage(_ message: Chat) {
        context.delete(message)
        save()
    }
}
