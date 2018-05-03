//
//  MessageComposerViewController.swift
//  MVVMMessageComposer
//
//  Created by Prime, Colden on 4/26/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import UIKit
import Intrepid
import SwiftSpinner
import IQKeyboardManagerSwift

protocol MessageComposerViewControllerDelegate: class {
    func messageComposerViewController(_ viewController: MessageComposerViewController, didFinishWithMessage: Message?)
}

class MessageComposerViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!

    weak var delegate: MessageComposerViewControllerDelegate?
    var sender: User!
    var recipient: User!

    var sendButtonBackgroundColor: UIColor {
        // TODO: Insert logic controlling button color based on message state
        if let text = messageTextView.text, !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            return UIColor.blue
        } else {
            return  UIColor.blue.withAlphaComponent(0.33)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Connect initial UI to VM logic

        titleLabel.text = "To: \(recipient.name)"
        characterCountLabel.text = "0/140"
        messageTextView.text = ""
        placeholderLabel.text = "Type message..."
        sendButton.backgroundColor = sendButtonBackgroundColor
        sendButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageTextView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageTextView.resignFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        messageTextView.keyboardDistanceFromTextField = (sendButton.frameMaxY + 10) - messageTextView.frameMaxY
    }

    @IBAction func sendButtonClicked(_ sender: Any) {
        messageTextView.resignFirstResponder()

        // TODO: Use VM to send and save message

        SwiftSpinner.show("Sending message...")
        let message = messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        MessagingRestClient.shared.send(message, from: self.sender, to: self.recipient) { [weak self] result in
            guard let strongSelf = self else { return }
            if let message = result.value {
                SwiftSpinner.hide()
                MessagingDataStorage.shared.save(message)
                strongSelf.delegate?.messageComposerViewController(strongSelf, didFinishWithMessage: message)
            } else {
                SwiftSpinner.show("Send failed...")
                After(0.5) {
                    SwiftSpinner.hide()
                    self?.messageTextView.becomeFirstResponder()
                }
            }
        }
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        delegate?.messageComposerViewController(self, didFinishWithMessage: nil)
    }
}

extension MessageComposerViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // TODO: Defer decision to VM

        guard let beforeText = textView.text else {
            return text.count <= 140
        }
        let afterText = (beforeText as NSString).replacingCharacters(in: range, with: text)
        return afterText.count <= 140
    }

    func textViewDidChange(_ textView: UITextView) {
        // TODO: Insert Logic to update VM
        // TODO: Observe changes to VM in order to keep UI up-to-date

        characterCountLabel.text = "\((textView.text ?? "").count)/140"
        placeholderLabel.isHidden = !(textView.text ?? "").isEmpty
        if let text = textView.text, !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            sendButton.backgroundColor = sendButtonBackgroundColor
            sendButton.isEnabled = true
        } else {
            sendButton.backgroundColor = sendButtonBackgroundColor
            sendButton.isEnabled = false
        }
    }
}

