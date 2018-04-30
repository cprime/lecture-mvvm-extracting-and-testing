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
    let dataStorage: DataStorage

    var didUpdateCharacterCount: ((String) -> Void)? {
        didSet {
            didUpdateCharacterCount?(characterCount)
        }
    }

    var didUpdateIsPlaceholderHidden: ((Bool) -> Void)? {
        didSet {
            didUpdateIsPlaceholderHidden?(isPlaceholderHidden)
        }
    }

    var didUpdateIsSendButtonEnabled: ((Bool) -> Void)? {
        didSet {
            didUpdateIsSendButtonEnabled?(isSendButtonEnabled)
        }
    }

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

    private(set) var messageText = "" {
        didSet {
            didUpdateCharacterCount?(characterCount)
            didUpdateIsPlaceholderHidden?(isPlaceholderHidden)
            didUpdateIsSendButtonEnabled?(isSendButtonEnabled)
        }
    }

    var isSendButtonEnabled: Bool {
        return !messageText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
    }

    init(sender: User, recipient: User, restClient: RestClient = MessagingRestClient.shared, dataStorage: DataStorage = MessagingDataStorage.shared) {
        self.sender = sender
        self.recipient = recipient
        self.restClient = restClient
        self.dataStorage = dataStorage
    }

    func didUpdateMessageText(_ text: String) {
        messageText = text
    }

    func shouldChangeText(in range: NSRange, replacementText text: String) -> Bool {
        let afterText = (messageText as NSString).replacingCharacters(in: range, with: text)
        return afterText.count <= 140
    }

    func send(_ completion: @escaping (Result<Message>) -> Void) {
        restClient.send(messageText, from: sender, to: recipient) { [weak self] result in
            if let message = result.value {
                self?.dataStorage.save(message)
            }
            completion(result)
        }
    }
}
