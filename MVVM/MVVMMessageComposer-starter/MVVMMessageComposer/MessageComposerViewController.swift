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

    func updateUI() {
        titleLabel.text = viewModel.title

        messageTextView.text = viewModel.messageText
        characterCountLabel.text = viewModel.characterCount

        placeholderLabel.text = viewModel.placeholderTitle
        placeholderLabel.isHidden = viewModel.isPlaceholderHidden

        sendButton.isEnabled = viewModel.isSendButtonEnabled
        sendButton.backgroundColor = viewModel.isSendButtonEnabled ? UIColor.blue : UIColor.blue.withAlphaComponent(0.33)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
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
        viewModel.send { [weak self] result in
            guard let strongSelf = self else { return }
            if let message = result.value {
                SwiftSpinner.hide()
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
        viewModel.updateMessageText(textView.text ?? "")
        updateUI()
    }
}
