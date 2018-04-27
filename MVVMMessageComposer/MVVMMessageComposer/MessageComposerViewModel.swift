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

    var characterCount: String {
        return "0/140"
    }

    private(set) var messageText = ""

    var isSendButtonEnabled: Bool {
        return false
    }

    init(sender: User, recipient: User) {
        self.sender = sender
        self.recipient = recipient
    }
}
