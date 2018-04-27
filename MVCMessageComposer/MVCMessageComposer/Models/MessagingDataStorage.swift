//
//  MessagingDataStorage.swift
//  MVCMessageComposer
//
//  Created by Prime, Colden on 4/27/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid

class MessagingDataStorage {
    static let shared = MessagingDataStorage()

    private var currentUser: User?
    private var users = [String:User]()
    private var messages = [Message]()

    func setCurrentUser(_ user: User) {
        currentUser = user
        users[user.id] = user
    }

    func getCurrentUser(_ completion: @escaping (User?) -> Void) {
        Main { [weak self] in
            completion(self?.currentUser)
        }
    }

    func getUsers(_ completion: @escaping ([User]) -> Void) {
        Main { [weak self] in
            completion(self?.users.values.ip_toArray() ?? [])
        }
    }

    func getConversationBetween(_ userA: User, and userB: User, _ completion: @escaping ([Message]) -> Void) {
        Main { [weak self] in
            completion(self?.messages.filter({
                ($0.senderId == userA.id && $0.recipientId == userB.id) || ($0.senderId == userB.id && $0.recipientId == userA.id)
            }) ?? [])
        }
    }

    func save(_ message: Message) {
        messages.append(message)
    }
}
