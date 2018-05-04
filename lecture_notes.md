# Testing Notes



## Unit Testing Guidelines

__Note: These are unit-testing specific__

* Tests should be independent
  * "The actions of one test should not affect the outcome of another"
* Tests should not crash
  * "Follows previous rule"
* Tests should run quickly
  * "Ensures you'll run your tests often"
* Tests should be deterministically
  * "Tests should not fail intermittently"
* Tests should be readable
  * "Tests should double as code documentation"



## UI Notes

* Title, Message Text Field
  * Character Count and Send Button update with message being entered
* Send button sends message to recipient



## MVC Notes

* VC accesses Models
* VC accesses Views
* VC accesses Services
* Functions we might want to test can contain all of these
* Nothing is tested
* This is why we introduced MVVM as a department



## Stubbed MVVM

* We'll start our demo with the Message Composer VM Stubbed out
* VC references VM instead



## TDD

### Testing.title



### Testing .isSendButtonEnabled




### Testing .characterCount




### Testing .shouldChangeText




### Testing .send




#### Setup Mocking/Spying/DI




#### Test




## Unit Testing Guidelines Recap

* Tests should be independent
  * Clear Mocks Between Tests
* Tests should run quickly
  * Mocks allow dependency testing to run quickly
  * Everything else should run quickly by default
  * MVVM ensures you
* Tests should be deterministically
  * Mocks allow dependency testing to run quickly
* Tests should be readable
  * Break tests out into logical pieces
  * Limit number of asserts they contain
