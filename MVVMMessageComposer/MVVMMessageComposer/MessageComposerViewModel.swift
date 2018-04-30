//
//  MessageComposerViewModel.swift
//  MVVMMessageComposer
//
//  Created by Prime, Colden on 4/27/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import Foundation
import Intrepid

class MessageComposerViewModel {
    static let placeholderText = "Type message..."
    static let maxCharacterCount = 140

    let sender: User
    let recipient: User
    let restClient: RestClient

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

    init(sender: User, recipient: User, restClient: RestClient = MessagingRestClient.shared) {
        self.sender = sender
        self.recipient = recipient
        self.restClient = restClient
    }

    func didUpdateMessageText(_ text: String) {
        messageText = text
    }

    func shouldChangeText(in range: NSRange, replacementText text: String) -> Bool {
        let afterText = (messageText as NSString).replacingCharacters(in: range, with: text)
        return afterText.count <= 140
    }

    func send(_ completion: @escaping (Result<Message>) -> Void) {
        restClient.send(messageText, from: sender, to: recipient) { result in
            if let message = result.value {
                MessagingDataStorage.shared.save(message)
            }
            completion(result)
        }
    }
}
