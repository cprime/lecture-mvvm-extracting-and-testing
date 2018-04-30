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
    let restClient = MockRestClient()
    lazy var viewModel = MessageComposerViewModel(sender: sender, recipient: recipient, restClient: restClient)

    override func tearDown() {
        restClient.capturedSendArguments.removeAll()
    }

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

    func testSendWithSuccess() {
        let text = "Hello, World!"
        let date = Date()
        let message = Message(id: "message_1", senderId: sender.id, recipientId: recipient.id, text: text, date: date)
        restClient.stubbedSendResult = .success(message)

        viewModel.didUpdateMessageText(text)
        let expectation = XCTestExpectation(description: "Send Message")
        viewModel.send { result in
            expectation.fulfill()
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(result.value?.text, text)
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(restClient.capturedSendArguments.count, 1)
        XCTAssertEqual(restClient.capturedSendArguments.first?.text, text)
        XCTAssertEqual(restClient.capturedSendArguments.first?.sender.id, sender.id)
        XCTAssertEqual(restClient.capturedSendArguments.first?.recipient.id, recipient.id)
    }

    func testSendWithFailure() {
        let text = "Hello, World!"
        restClient.stubbedSendResult = .failure(MessagingRestClient.RestError.unknown)

        viewModel.didUpdateMessageText(text)
        let expectation = XCTestExpectation(description: "Send Message")
        viewModel.send { result in
            expectation.fulfill()
            XCTAssertTrue(result.isFailure)
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(restClient.capturedSendArguments.count, 1)
        XCTAssertEqual(restClient.capturedSendArguments.first?.text, text)
        XCTAssertEqual(restClient.capturedSendArguments.first?.sender.id, sender.id)
        XCTAssertEqual(restClient.capturedSendArguments.first?.recipient.id, recipient.id)
    }
}
