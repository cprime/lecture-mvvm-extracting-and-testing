//
//  MessageComposerViewModel.swift
//  MVVMMessageComposer
//
//  Created by Prime, Colden on 5/3/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid

class MessageComposerViewModel {
    static let placeholderText = "Type message..."
    static let maxCharacterCount = 140

    let sender: User
    let recipient: User

    var title: String {
        // TODO: "To: <recipient name>"
        return ""
    }

    var characterCount: String {
        // TODO: "<current-count>/<max-allowed>"
        return ""
    }

    private(set) var messageText: String = ""

    var placeholderTitle: String {
        return MessageComposerViewModel.placeholderText
    }

    var isPlaceholderHidden: Bool {
        // TODO: hidden if messageText is not empty
        return true
    }

    var isSendButtonEnabled: Bool {
        // TODO: enabled if a messageText is not empty after trimming whitespace
        return false
    }

    init(sender: User, recipient: User) {
        self.sender = sender
        self.recipient = recipient
    }

    func updateMessageText(_ text: String) {
        messageText = text
    }

    func shouldChangeText(in range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    func send(_ completion: @escaping (Result<Message>) -> Void) {
        // TODO: Send Message
        // TODO: Save On-Success

        // Temporary
        After(0.5) {
            completion(.failure(MessagingRestClient.RestError.unknown))
        }
    }

}
