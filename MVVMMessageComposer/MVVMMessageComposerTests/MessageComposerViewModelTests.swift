//
//  MessageComposerViewModelTests.swift
//  MVVMMessageComposerTests
//
//  Created by Prime, Colden on 4/27/18.
//  Copyright © 2018 Intrepid Pursuits. All rights reserved.
//

import XCTest
@testable import MVVMMessageComposer

class MessageComposerViewModelTests: XCTestCase {
    let sender = User(id: UUID().uuidString, email: "alice@example.com", name: "Alice")
    let recipient = User(id: UUID().uuidString, email: "bob@example.com", name: "Bob")
    lazy var viewModel = MessageComposerViewModel(sender: sender, recipient: recipient)

    func testTitle() {
        XCTAssertEqual(viewModel.title, "To: \(viewModel.recipient.name)")
    }

    func testPlaceholder() {
        XCTAssertEqual(viewModel.placeholderTitle, MessageComposerViewModel.placeholderText)
    }

    func testMessageText() {
        XCTAssertEqual(viewModel.messageText, "")
    }

    func testCharacterCount() {
        XCTAssertEqual(viewModel.characterCount, "0/\(MessageComposerViewModel.maxCharacterCount)")
    }

    func testIsSendButtonEnabled() {
        XCTAssertEqual(viewModel.isSendButtonEnabled, false)
    }
}
