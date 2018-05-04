# Extracting a `ViewModel` and Testing

### Testing .title

```
func testTitle() {
    XCTAssertEqual(viewModel.title, "To: \(viewModel.recipient.name)")
}
```

```
return "To: \(recipient.name)"
```

### Testing .isSendButtonEnabled

```
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

    let fullLengthMessage = (0..<MessageComposerViewModel.maxCharacterCount).map({ _ in "_"}).joined()
    viewModel.updateMessageText(fullLengthMessage)
    XCTAssertEqual(viewModel.isSendButtonEnabled, true)
}
```

```
return !messageText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
```

### Testing .characterCount

```
func testCharacterCount() {
    XCTAssertEqual(viewModel.characterCount, "0/\(MessageComposerViewModel.maxCharacterCount)")
}

func testCharacterCountAfterUpdatingMessageText() {
    viewModel.updateMessageText("")
    XCTAssertEqual(viewModel.characterCount, "0/\(MessageComposerViewModel.maxCharacterCount)")

    viewModel.updateMessageText("1")
    XCTAssertEqual(viewModel.characterCount, "1/\(MessageComposerViewModel.maxCharacterCount)")

    let fullLengthMessage = (0..<MessageComposerViewModel.maxCharacterCount).map({ _ in "_"}).joined()
    viewModel.updateMessageText(fullLengthMessage)
    XCTAssertEqual(viewModel.characterCount, "\(MessageComposerViewModel.maxCharacterCount)/\(MessageComposerViewModel.maxCharacterCount)")
}
```

```
return "\(messageText.count)/\(MessageComposerViewModel.maxCharacterCount)"
```

### Testing .shouldChangeText

```
func testShouldChangeTextWhenUpdatedTextIsLessThanLimit() {
    viewModel.updateMessageText("")
    XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: "1"), true)

    viewModel.updateMessageText("123")
    XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: "1"), true)

    let fullLengthMessage = (0..<MessageComposerViewModel.maxCharacterCount).map({ _ in "_"}).joined()
    viewModel.updateMessageText(fullLengthMessage)
    XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 1), replacementText: "1"), true)
}

func testShouldChangeTextWhenUpdatedTextIsGreaterThanLimit() {
    let fullLengthMessage = (0..<MessageComposerViewModel.maxCharacterCount).map({ _ in "_"}).joined()

    viewModel.updateMessageText("1")
    XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: 0, length: 0), replacementText: fullLengthMessage), false)

    viewModel.updateMessageText(fullLengthMessage)
    XCTAssertEqual(viewModel.shouldChangeText(in: NSRange(location: MessageComposerViewModel.maxCharacterCount, length: 0), replacementText: "1"), false)
}
```

```
let afterText = (messageText as NSString).replacingCharacters(in: range, with: text)
return afterText.count <= MessageComposerViewModel.maxCharacterCount
```

### Testing .send

Enable MessageingRestClient for mocking by creating a swift protocol in `MessagingRestClient.swift`

```
protocol RestClient {
    func send(_ text: String, from sender: User, to recipient: User, completion: @escaping (Result<Message>) -> Void)
}
```

Enable ViewModel to use this protocol instead of the concrete version in `MessageComposerViewModel`

```
let restClient: RestClient
```

Inject via init and use concrete version as default arg

```
restClient: RestClient = MessagingRestClient.shared
```

Create mock version of RestClient for testing purposes

```
import Foundation
import Intrepid
@testable import MVVMMessageComposer

class MockRestClient: RestClient {
    var capturedSendArguments = [(text: String, sender: User, recipient: User)]()
    var stubbedSendResult: Result<Message> = .failure(MessagingRestClient.RestError.unknown)
    func send(_ text: String, from sender: User, to recipient: User, completion: @escaping (Result<Message>) -> Void) {
        capturedSendArguments.append((text: text, sender: sender, recipient: recipient))
        DispatchQueue.main.async {
            completion(self.stubbedSendResult)
        }
    }
}
```

Inject the mocked version in the test

```
let restClient = MockRestClient()
lazy var viewModel = MessageComposerViewModel(sender: sender, recipient: recipient, restClient: restClient)

override func tearDown() {
    restClient.capturedSendArguments.removeAll()
}
```

Now we are ready to test without making networking calls.

Test Inputs:

```
func testSendTrimsMessage() {
    let trimmedText = "Hello, World!"
    let textWithLeadingAndTrailingWhitespace = "  \(trimmedText)  "

    viewModel.updateMessageText(textWithLeadingAndTrailingWhitespace)
    viewModel.send { _ in }

    XCTAssertEqual(restClient.capturedSendArguments.count, 1)
    XCTAssertEqual(restClient.capturedSendArguments.first?.text, trimmedText)
    XCTAssertEqual(restClient.capturedSendArguments.first?.sender.id, sender.id)
    XCTAssertEqual(restClient.capturedSendArguments.first?.recipient.id, recipient.id)
}
```

Test success:

```
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
    }
    wait(for: [expectation], timeout: 1.0)
}
```

Test Failure:
```
func testSendWithFailure() {
    let text = "Hello, World!"
    restClient.stubbedSendResult = .failure(MessagingRestClient.RestError.unknown)

    viewModel.updateMessageText(text)
    let expectation = XCTestExpectation(description: "Send Message")
    viewModel.send { result in
        expectation.fulfill()
        XCTAssertTrue(result.isFailure)
    }
    wait(for: [expectation], timeout: 1.0)
}
```

Then make it work:

```
let text = messageText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
restClient.send(text, from: sender, to: recipient) { result in
    // TODO: Save On-Success
    completion(result)
}
```
