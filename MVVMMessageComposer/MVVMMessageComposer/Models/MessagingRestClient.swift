//
//  MessagingRestClient.swift
//  MVVMMessageComposer
//
//  Created by Prime, Colden on 4/26/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid

protocol RestClient {
    func send(_ text: String, from sender: User, to recipient: User, completion: @escaping (Result<Message>) -> Void)
}

class MessagingRestClient: RestClient {
    enum RestError: Error {
        case unknown
    }

    static let shared = MessagingRestClient()

    func login(email: String, password: String, completion: @escaping (Result<User>) -> Void) {
        After(0.5) {
            let user = User(id: UUID().uuidString, email: "jane.doe@example.com", name: "Jane Doe")
            Main {
                completion(.success(user))
            }
        }
    }

    func getContacts(_ completion: @escaping (Result<[User]>) -> Void) {
        After(0.5) {
            let contacts = [User(id: UUID().uuidString, email: "john.doe@example.com", name: "John Doe")]
            Main {
                completion(.success(contacts))
            }
        }
    }

    func send(_ text: String, from sender: User, to recipient: User, completion: @escaping (Result<Message>) -> Void) {
        After(0.5) {
            let message = Message(id: UUID().uuidString, senderId: sender.id, recipientId: recipient.id, text: text, date: Date())
            Main {
                completion(.success(message))
            }
        }
    }
}
