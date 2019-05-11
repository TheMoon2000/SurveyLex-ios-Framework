//
//  SurveyLexTests.swift
//  SurveyLexTests
//
//  Created by Jia Rui Shan on 2019/5/9.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import SurveyLex

class QuestionElementsTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRadioGroup() {
        let questionInput = """
        {
          "type": "radiogroup",
          "choices": ["Yes", "No"],
          "title": "This is a radio group demo",
          "isRequired": true
        }
        """
        let jsonData = JSON(parseJSON: questionInput)
        let radioQuestion = RadioGroup(json: jsonData)
        print(radioQuestion)
        XCTAssertEqual(radioQuestion.type, .radioGroup)
        XCTAssertEqual(radioQuestion.choices, ["Yes", "No"])
        XCTAssertTrue(radioQuestion.isRequired)
    }
    
    func testTextQuestion() {
        let textQuestionInput = """
        {
          "fragmentId": "16261722-43fe-11e9-8a24-cd4ab4d0c054",
          "type": "TEXT_SURVEYJS",
          "data": {
            "surveyjs": {
              "questions": [
                {"type": "text", "title": "Name"},
                {"type": "text", "title": "Email"},
                {"type": "text", "title": "Location"},
                {"type": "text", "title": "LinkedIn URL"},
                {"type": "text", "title": "GitHub URL"}
              ]
            }
          }
        }
        """
        let jsonData = JSON(parseJSON: textQuestionInput)
        let fragment = Fragment(json: jsonData)
        print(fragment)
        XCTAssertEqual(fragment.questions.map {($0 as! Text).title},
                       ["Name", "Email", "Location", "LinkedIn URL", "GitHub URL"])
    }
    
    func testConsent() {
        let fragmentInput = """
        {
          "fragmentId": "16261721-43fe-11e9-8a24-cd4ab4d0c054",
          "type": "CONSENT",
          "data": {
            "title": "Consent Title",
            "consentText": "Consent information goes in here...",
            "prompt": "Consent prompt"
            }
        }
        """
        let jsonData = JSON(parseJSON: fragmentInput)
        let fragment = Fragment(json: jsonData)
        print(fragment)
        
        let consentForm = fragment.questions[0] as! Consent
        XCTAssertEqual(consentForm.title, "Consent Title")
    }
    
    func testAudioQuestion() {
        let fragmentInput = """
        {
          "fragmentId": "536ff9f0-62b9-11e9-a454-f5b21638e785",
          "type": "AUDIO_STANDARD",
          "data": {
            "prompt": "How are you today?",
            "isRequired": true
          }
        }
        """
        let jsonData = JSON(parseJSON: fragmentInput)
        let fragment = Fragment(json: jsonData)
        print(fragment)
        XCTAssertEqual(fragment.questions[0].type, .audio)
        XCTAssertTrue(fragment.questions[0].isRequired)
    }
    
    func testRatingType1() {
        let questionInput = """
        {
          "type": "rating",
          "rateValues": [
            {"value": "1 Ineffective", "text": "1 Ineffective"},
            2,
            3,
            4,
            {"value": "5 Effective", "text": "5 Effective"}
          ],
          "title": "Did you feel effective today?",
          "isRequired": true
        }
        """
        let jsonData = JSON(parseJSON: questionInput)
        
        let ratingQuestion = Rating(json: jsonData)
        let rateValues = ratingQuestion.options.map {$0.value}
        let displayed = ratingQuestion.options.map {$0.text}
        print(ratingQuestion)
        
        XCTAssertEqual(rateValues, ["1 Ineffective", "2", "3", "4", "5 Effective"])
        XCTAssertEqual(displayed,
                       ["1 Ineffective", "2", "3", "4", "5 Effective"])
        XCTAssertTrue(ratingQuestion.isRequired)
    }
    
    func testRatingType2() {
        let questionInput = """
        {
          "type": "rating",
          "rateValues": [
            {"value": "No", "text": "Not at all"},
            {"value": "Not Really", "text": "Not Really"},
            {"value": "Somewhat", "text": "Somewhat"},
            {"value": "Mostly", "text": "Mostly"},
            {"value": "Yes", "text": "Yes! Absolutely"}
          ],
          "title": "Did you do what you planned on doing?",
          "isRequired": true
        }
        """
        let jsonData = JSON(parseJSON: questionInput)
        
        let ratingQuestion = Rating(json: jsonData)
        let rateValues = ratingQuestion.options.map {$0.value}
        let displayed = ratingQuestion.options.map {$0.text}
        print(ratingQuestion)
        
        XCTAssertEqual(rateValues, ["No", "Not Really", "Somewhat", "Mostly", "Yes"])
        XCTAssertEqual(displayed, ["Not at all", "Not Really", "Somewhat", "Mostly", "Yes! Absolutely"])
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
