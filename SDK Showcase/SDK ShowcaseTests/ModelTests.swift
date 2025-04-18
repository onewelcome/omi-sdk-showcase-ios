//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Testing
@testable import SDK_Showcase

struct ModelTests {
    struct OptionTests {
        @Test func initialiationWithName() {
            let option = Option(name: "Test")
            #expect(option.name == "Test")
            #expect(option.logo == nil)
            #expect(option.id != nil)
        }
        @Test func initialiationWithNameAndLogo() {
            let option = Option(name: "Test", logo: "logo.png")
            #expect(option.name == "Test")
            #expect(option.logo == "logo.png")
            #expect(option.id != nil)
        }
        @Test func compare() {
            let option1 = Option(name: "Test1")
            let option2 = Option(name: "Test2")
            #expect(option1 != option2)
        }
        @Test func compare2() {
            let option1 = Option(name: "Test3")
            let option2 = Option(name: "Test3")
            #expect(option1 == option2)
        }
    }
    
    struct ActionTests {
        @Test func initialiationWithName() {
            let action = Action(name: "Test")
            #expect(action.name == "Test")
            #expect(action.defaultValue == nil)
            #expect(action.providedValue == nil)
            #expect(action.description == nil)
            #expect(action.id != nil)
        }
        @Test func initialiationWithNameAndDescription() {
            let action = Action(name: "Test", description: "description")
            #expect(action.name == "Test")
            #expect(action.defaultValue == nil)
            #expect(action.providedValue == nil)
            #expect(action.description == "description")
            #expect(action.id != nil)
        }
        @Test func initialiationWithNameAndDescriptionAndDefaultValue() {
            let action = Action(name: "Test", description: "description", defaultValue: true)
            #expect(action.name == "Test")
            #expect(action.defaultValue as! Bool == true)
            #expect(action.providedValue == nil)
            #expect(action.description == "description")
            #expect(action.id != nil)
        }
        @Test func initialiationWithNameAndDescriptionAndDefaultValue2() {
            let action = Action(name: "Test", description: "description", providedValue: "1", defaultValue: true)
            #expect(action.name == "Test")
            #expect(action.defaultValue as! Bool == true)
            #expect(action.providedValue as! String == "1")
            #expect(action.description == "description")
            #expect(action.id != nil)
        }
        @Test func compare() {
            let action1 = Action(name: "A1")
            let action2 = Action(name: "A2")
            #expect(action1 != action2)
        }
        @Test func compare2() {
            let action1 = Action(name: "A3")
            let action2 = Action(name: "A3")
            #expect(action1 == action2)
        }
        @Test func compare2b() {
            let action1 = Action(name: "A4", providedValue: nil, defaultValue: true)
            let action2 = Action(name: "A4", providedValue: "coś", defaultValue: false)
            #expect(action1 == action2)
        }

    }
}
