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
    var viewModel: MessageComposerViewModel!

    var sendButtonBackgroundColor: UIColor {
        return viewModel.isSendButtonEnabled ? UIColor.blue : UIColor.blue.withAlphaComponent(0.33)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = viewModel.title
        characterCountLabel.text = viewModel.characterCount
        messageTextView.text = viewModel.messageText
        placeholderLabel.text = viewModel.placeholderTitle
        sendButton.backgroundColor = sendButtonBackgroundColor
        sendButton.isEnabled = viewModel.isSendButtonEnabled
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
        SwiftSpinner.show("Sending message...")
        let message = messageTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        MessagingRestClient.shared.send(message, from: viewModel.sender, to: viewModel.recipient) { [weak self] result in
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
        return viewModel.shouldChangeText(in: range, replacementText: text)
    }

    func textViewDidChange(_ textView: UITextView) {
        viewModel.didUpdateMessageText(textView.text ?? "")

        characterCountLabel.text = "\((textView.text ?? "").count)/140"
        placeholderLabel.isHidden = !(textView.text ?? "").isEmpty
        if let text = textView.text, !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            sendButton.backgroundColor = UIColor.blue
            sendButton.isEnabled = true
        } else {
            sendButton.backgroundColor = UIColor.blue.withAlphaComponent(0.33)
            sendButton.isEnabled = false
        }
    }
}
