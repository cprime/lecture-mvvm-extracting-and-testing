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
    let dataStorage = MockDataStorage()
    lazy var viewModel = MessageComposerViewModel(sender: sender, recipient: recipient, restClient: restClient, dataStorage: dataStorage)

    override func tearDown() {
        restClient.capturedSendArguments.removeAll()
        dataStorage.messages.removeAll()
    }

    // MARK: Title

    func testTitle() {
        XCTAssertEqual(viewModel.title, "To: \(viewModel.recipient.name)")
    }

    // MARK: Placeholder

    func testPlaceholder() {
        XCTAssertEqual(viewModel.placeholderTitle, MessageComposerViewModel.placeholderText)
    }

    func testIsPlaceholderHidden() {
        XCTAssertEqual(viewModel.isPlaceholderHidden, false)
    }

    func testIsPlaceholderHiddenAfterUpdatingMessageText() {
        viewModel.updateMessageText("")
        XCTAssertEqual(viewModel.isPlaceholderHidden, false)

        viewModel.updateMessageText("1")
        XCTAssertEqual(viewModel.isPlaceholderHidden, true)
    }

    func testIsPlaceholderHiddenUpdatesAfterUpdatingMessageText() {
        var isPlaceholderHidden: Bool?
        viewModel.didUpdateIsPlaceholderHidden = {
            isPlaceholderHidden = $0
        }

        XCTAssertEqual(isPlaceholderHidden, false)

        viewModel.updateMessageText("1")
        XCTAssertEqual(isPlaceholderHidden, true)
    }

    // MARK: Message Text

    func testMessageText() {
        XCTAssertEqual(viewModel.messageText, "")

        viewModel.updateMessageText("1")
        XCTAssertEqual(viewModel.messageText, "1")
    }

    // MARK: Character Count

    func testCharacterCount() {
        XCTAssertEqual(viewModel.characterCount, "0/\(MessageComposerViewModel.maxCharacterCount)")
    }

    func testCharacterCountAfterUpdatingMessageText() {
        viewModel.updateMessageText("")
        XCTAssertEqual(viewModel.characterCount, "0/\(MessageComposerViewModel.maxCharacterCount)")

        viewModel.updateMessageText("1")
        XCTAssertEqual(viewModel.characterCount, "1/\(MessageComposerViewModel.maxCharacterCount)")

        viewModel.updateMessageText(fullLengthMessage)
        XCTAssertEqual(viewModel.characterCount, "\(MessageComposerViewModel.maxCharacterCount)/\(MessageComposerViewModel.maxCharacterCount)")
    }

    func testCharacterCountUpdatesAfterUpdatingMessageText() {
        var characterCount: String?
        viewModel.didUpdateCharacterCount = {
            characterCount = $0
        }

        XCTAssertEqual(characterCount, "0/\(MessageComposerViewModel.maxCharacterCount)")

        viewModel.updateMessageText("1")
        XCTAssertEqual(characterCount, "1/\(MessageComposerViewModel.maxCharacterCount)")
    }

    // MARK: Send Button

    func testIsSendButtonEnabled() {
        XCTAssertEqual(viewModel.isSendButtonEnabled, false)
    }

    func testIsSendButtonEnabledAfterUpdatingMessageText() {
        viewModel.updateMessageText("")
        XCTAssertEqual(viewModel.isSendButtonEnabled, false)

        viewModel.updateMessageText(" ")
        XCTAssertEqual(viewModel.isSendButtonEnabled, false)

        viewModel.updateMessageText("1")
        XCTAssertEqual(viewModel.isSendButtonEnabled, true)

        viewModel.updateMessageText(fullLengthMessage)
        XCTAssertEqual(viewModel.isSendButtonEnabled, true)
    }

    func testIsSendButtonEnabledUpdatesAfterUpdatingMessageText() {
        var isSendButtonEnabled: Bool?
        viewModel.didUpdateIsSendButtonEnabled = {
            isSendButtonEnabled = $0
        }

        XCTAssertEqual(isSendButtonEnabled, false)

        viewModel.updateMessageText("1")
        XCTAssertEqual(isSendButtonEnabled, true)
    }

    // MARK: ShouldChangeText

    func testShouldUpdateTextWhenUpdatedTextIsLessThanLimit() {
        viewModel.updateMessageText("")
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: "1"), true)

        viewModel.updateMessageText("123")
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: "1"), true)

        viewModel.updateMessageText(fullLengthMessage)
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 1), replacementText: "1"), true)
    }

    func testShouldUpdateTextWhenTextIsFullBut() {
        viewModel.updateMessageText("1")
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: fullLengthMessage), false)

        viewModel.updateMessageText(fullLengthMessage)
        XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: MessageComposerViewModel.maxCharacterCount, length: 0), replacementText: "1"), false)
    }

    // MARK: Sending

    func testSendWithSuccess() {
        let text = "Hello, World!"
        let date = Date()
        let message = Message(id: "message_1", senderId: sender.id, recipientId: recipient.id, text: text, date: date)
        restClient.stubbedSendResult = .success(message)

        viewModel.updateMessageText(text)
        let expectation = XCTestExpectation(description: "Send Message")
        viewModel.send { result in
            expectation.fulfill()
            XCTAssertTrue(result.isSuccess)
            XCTAssertEqual(result.value?.text, text)
            XCTAssertEqual(self.dataStorage.messages.count, 1)
            XCTAssertEqual(self.dataStorage.messages.first?.id, message.id)
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

        viewModel.updateMessageText(text)
        let expectation = XCTestExpectation(description: "Send Message")
        viewModel.send { result in
            expectation.fulfill()
            XCTAssertTrue(result.isFailure)
            XCTAssertEqual(self.dataStorage.messages.count, 0)
        }
        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(restClient.capturedSendArguments.count, 1)
        XCTAssertEqual(restClient.capturedSendArguments.first?.text, text)
        XCTAssertEqual(restClient.capturedSendArguments.first?.sender.id, sender.id)
        XCTAssertEqual(restClient.capturedSendArguments.first?.recipient.id, recipient.id)
    }
}
