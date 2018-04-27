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
    let fullLengthMessage = (0..<MessageComposerViewModel.maxCharacterCount).map({ _ in "_"}).joined()
    let sender = User(id: UUID().uuidString, email: "alice@example.com", name: "Alice")
    let recipient = User(id: UUID().uuidString, email: "bob@example.com", name: "Bob")
    lazy var viewModel = MessageComposerViewModel(sender: sender, recipient: recipient)

    func testTitle() {
        XCTAssertEqual(viewModel.title, "To: \(viewModel.recipient.name)")
    }

    func testPlaceholder() {
        XCTAssertEqual(viewModel.placeholderTitle, MessageComposerViewModel.placeholderText)
    }

    func testIsPlaceholderHidden() {
        XCTAssertEqual(viewModel.isSendButtonEnabled, false)
    }

    func testIsPlaceholderHiddenAfterUpdatingMessageText() {
        viewModel.didUpdateMessageText("")
        XCTAssertEqual(viewModel.isPlaceholderHidden, false)

        viewModel.didUpdateMessageText("1")
        XCTAssertEqual(viewModel.isPlaceholderHidden, true)
    }

    func testMessageText() {
        XCTAssertEqual(viewModel.messageText, "")
    }

    func testCharacterCount() {
        XCTAssertEqual(viewModel.characterCount, "0/\(MessageComposerViewModel.maxCharacterCount)")
    }

    func testCharacterCountAfterUpdatingMessageText() {
        viewModel.didUpdateMessageText("")
        XCTAssertEqual(viewModel.characterCount, "0/\(MessageComposerViewModel.maxCharacterCount)")

        viewModel.didUpdateMessageText("1")
        XCTAssertEqual(viewModel.characterCount, "1/\(MessageComposerViewModel.maxCharacterCount)")

        viewModel.didUpdateMessageText(fullLengthMessage)
        XCTAssertEqual(viewModel.characterCount, "\(MessageComposerViewModel.maxCharacterCount)/\(MessageComposerViewModel.maxCharacterCount)")
    }

    func testIsSendButtonEnabled() {
        XCTAssertEqual(viewModel.isSendButtonEnabled, false)
    }

    func testIsSendButtonEnabledAfterUpdatingMessageText() {
        viewModel.didUpdateMessageText("")
        XCTAssertEqual(viewModel.isSendButtonEnabled, false)

        viewModel.didUpdateMessageText(" ")
        XCTAssertEqual(viewModel.isSendButtonEnabled, false)

        viewModel.didUpdateMessageText("1")
        XCTAssertEqual(viewModel.isSendButtonEnabled, true)

        viewModel.didUpdateMessageText(fullLengthMessage)
        XCTAssertEqual(viewModel.isSendButtonEnabled, true)
    }

    func testShouldUpdateTextWhenUpdatedTextIsLessThanLimit() {
        viewModel.didUpdateMessageText("")
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: "1"), true)

        viewModel.didUpdateMessageText("123")
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: "1"), true)

        viewModel.didUpdateMessageText(fullLengthMessage)
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 1), replacementText: "1"), true)
    }

    func testShouldUpdateTextWhenTextIsFullBut() {
        viewModel.didUpdateMessageText("1")
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: fullLengthMessage), false)

        viewModel.didUpdateMessageText(fullLengthMessage)
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: MessageComposerViewModel.maxCharacterCount, length: 0), replacementText: "1"), false)
    }
}
