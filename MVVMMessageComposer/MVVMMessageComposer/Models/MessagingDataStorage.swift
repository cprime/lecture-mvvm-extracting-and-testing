//
//  MessagingDataStorage.swift
//  MVVMMessageComposer
//
//  Created by Prime, Colden on 4/27/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid

class MessagingDataStorage {
    static let shared = MessagingDataStorage()

    private var users: [String:User] {
        didSet {
            let userJSON = try! JSONEncoder().encode(users)
            UserDefaults.standard.set(userJSON, forKey: "MessagingDataStorage_users")
        }
    }

    private var messages: [Message] {
        didSet {
            let messagesJSON = try! JSONEncoder().encode(messages)
            UserDefaults.standard.set(messagesJSON, forKey: "MessagingDataStorage_messages")
        }
    }

    var currentUser: User? {
        get {
            if let currentUserId = UserDefaults.standard.string(forKey: "MessagingDataStorage_currentUserId") {
                return users[currentUserId]
            } else {
                return nil
            }
        }
        set {
            if let currentUserId = newValue?.id {
                UserDefaults.standard.set(currentUserId, forKey: "MessagingDataStorage_currentUserId")
                users[currentUserId] = newValue
            } else {
                UserDefaults.standard.removeObject(forKey: "MessagingDataStorage_currentUserId")
            }
        }
    }

    init() {
        let jsonDecoder = JSONDecoder()
        if let usersJSONData = UserDefaults.standard.object(forKey: "MessagingDataStorage_users") as? Data,
            let users = try? jsonDecoder.decode([String:User].self, from: usersJSONData) {
            self.users = users
        } else {
            self.users = [:]
            UserDefaults.standard.removeObject(forKey: "MessagingDataStorage_users")
        }
        if let messagesJSONData = UserDefaults.standard.object(forKey: "MessagingDataStorage_messages") as? Data,
            let messages = try? jsonDecoder.decode([Message].self, from: messagesJSONData) {
            self.messages = messages
        } else {
            self.messages = []
            UserDefaults.standard.removeObject(forKey: "MessagingDataStorage_messages")
        }
    }

    func clearData() {
        currentUser = nil
        users = [:]
        messages = []
    }

    func getUsers() -> [User] {
        return users.values.ip_toArray()
    }

    func save(_ user: User) {
        users[user.id] = user
    }

    func getConversationBetween(_ userA: User, and userB: User) -> [Message] {
        return messages.filter({
            ($0.senderId == userA.id && $0.recipientId == userB.id) || ($0.senderId == userB.id && $0.recipientId == userA.id)
        })
    }

    func save(_ message: Message) {
        messages.append(message)
    }
}
