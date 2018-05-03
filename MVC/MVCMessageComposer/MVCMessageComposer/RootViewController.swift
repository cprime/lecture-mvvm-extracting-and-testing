//
//  RootViewController.swift
//  MVCMessageComposer
//
//  Created by Prime, Colden on 4/26/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import UIKit
import SwiftSpinner

class RootViewController: UIViewController {
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var sentCountLabel: UILabel!

    var contacts = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        SwiftSpinner.show("Login in...")
        MessagingRestClient.shared.login(email: "jane.doe@example.com", password: "12345") { [weak self] result in
            if let user = result.value {
                MessagingDataStorage.shared.currentUser = user
                MessagingRestClient.shared.getContacts({ result in
                    SwiftSpinner.show("Fetching contacts...")
                    if let contacts = result.value {
                        SwiftSpinner.hide()
                        contacts.forEach({ MessagingDataStorage.shared.save($0) })
                        self?.contacts = contacts
                        if let contact = contacts.first {
                            self?.sendMessageButton.setTitle("Send Message to \(contact.name)", for: .normal)
                        }
                    } else {
                        fatalError("Download failed...")
                    }
                })
            } else {
                fatalError("Authentication failed...")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSentMessageCount()
    }

    func updateSentMessageCount() {
        var sendCount: Int {
            if let currentUser = MessagingDataStorage.shared.currentUser, let contact = contacts.first {
                return MessagingDataStorage.shared.getConversationBetween(currentUser, and: contact).count
            } else {
                return 0
            }
        }
        sentCountLabel.text = "\(sendCount) messages sent"
    }

    @IBAction func sendMessageButtonClicked(_ sender: Any) {
        guard let currentUser = MessagingDataStorage.shared.currentUser, let contact = self.contacts.first else {
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "MessageComposerViewController") as! MessageComposerViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        vc.sender = currentUser
        vc.recipient = contact
        present(vc, animated: true, completion: nil)
    }
}

extension RootViewController: MessageComposerViewControllerDelegate {
    func messageComposerViewController(_ viewController: MessageComposerViewController, didFinishWithMessage: Message?) {
        updateSentMessageCount()
        viewController.dismiss(animated: true, completion: nil)
    }
}
