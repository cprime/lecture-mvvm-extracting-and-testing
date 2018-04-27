//
//  MessagingRestClient.swift
//  MVCMessageComposer
//
//  Created by Prime, Colden on 4/26/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid

class MessagingRestClient {
    enum RestError: Error {
        case unknown
    }

    static let shared = MessagingRestClient()

    func send(_ text: String, from sender: User, to recipient: User, completion: @escaping (Result<Message>) -> Void) {
        After(0.5) {
            let message = Message(id: UUID().uuidString, senderId: sender.id, recipientId: recipient.id, text: text, date: Date())
            Main {
                completion(.success(message))
            }
        }
    }
}
