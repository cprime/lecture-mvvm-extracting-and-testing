//
//  MessageComposerViewModel.swift
//  MVVMMessageComposer
//
//  Created by Prime, Colden on 4/27/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation

class MessageComposerViewModel {
    static let placeholderText = "Type message..."
    static let maxCharacterCount = 140

    let sender: User
    let recipient: User

    var title: String {
        return "To: \(recipient.name)"
    }

    var placeholderTitle: String {
        return MessageComposerViewModel.placeholderText
    }

    var isPlaceholderHidden: Bool {
        return !messageText.isEmpty
    }

    var characterCount: String {
        return "\(messageText.count)/\(MessageComposerViewModel.maxCharacterCount)"
    }

    private(set) var messageText = ""

    var isSendButtonEnabled: Bool {
        return !messageText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }

    init(sender: User, recipient: User) {
        self.sender = sender
        self.recipient = recipient
    }

    func didUpdateMessageText(_ text: String) {
        messageText = text
    }

    func shouldChangeText(in range: NSRange, replacementText text: String) -> Bool {
        let afterText = (messageText as NSString).replacingCharacters(in: range, with: text)
        return afterText.count <= 140
    }
}
