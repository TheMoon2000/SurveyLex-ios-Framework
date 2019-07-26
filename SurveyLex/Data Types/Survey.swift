//
//  Survey.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

/// An interactive interface that presents a survey (powered by SurveyLex) for the user to fill.
public class Survey {
    
    /// The NeuroLex SurveyLex API URL prefix.
    private static let BASE_URL = "https://api.neurolex.ai/1.0/object/surveys/taker/"
    
    /// The survey ID as a uuid string.
    private(set) var surveyID = ""
    
    /// Whether a `URLSession` task is already running.
    private var isAlreadyLoading = false
    
    /// The view controller that will present the survey when `present()` is called.
    public var targetVC: UIViewController?
    private(set) var surveyData: SurveyData?
    
    /// Optional delegate that handles survey responses.
    public var delegate: SurveyResponseDelegate?
    
    // MARK: Environment variables
    
    /// Whether multiple choice / checkbox menus are allowed to collapse once expanded.
    public var allowMenuCollapse = false
    
    /// Whether the current survey element has higher opacity relative to others.
    public var autofocus = true
    
    /// Whether the current instance creates a session and counts as a view toward the survey statistics. If set to false, the user's interactions with this survey will not be submitted.
    public var submissionMode = true
    
    /// Whether the survey data is loaded from cache.
    private var loadedFromCache = false
    
    // MARK: Survey class implementation
    
    /**
     Initializes a new `Survey` front-end by providing a JSON data source. **This constructor is not recommended**.
    
     - Parameters:
        - json: The input json source object to display.
        - target: The UIViewController that will present the survey.
     */
    public init(json: JSON, target: UIViewController) throws {
        self.surveyData = try SurveyData(json: json)
        self.surveyID = self.surveyData!.surveyId
        self.targetVC = target
    }
    
    /**
     Initializes a new `Survey` by providing the SurveyLex survey ID.
     
     - Parameters:
        - surveyID: The identifier string associated with the survey (for lookup)
        - target: The view controller instance that will present the survey
    */
    public init(surveyID: String, target: UIViewController) {
        self.surveyID = surveyID
        self.targetVC = target
    }
    
    /**
     A private helper method that loads the survey JSON from the API and executes a block of code upon completion.
     - Parameters:
        - completion: The code that gets executed after the `URLRequest` has returned a response.
     */
    
    private func load(_ completion: @escaping () -> ()) {
        if isAlreadyLoading { return } // An instance is already running
        
        if let cache = SURVEY_CACHE[surveyID] {
            self.loadedFromCache = true
            self.surveyData = cache
            debugMessage("Survey <\(surveyID)> is loaded from cache.")
            completion()
            return
        }
        
        // If the if clause above did not run, then it must be the case that the survey data is loaded fresh from the server.
        self.loadedFromCache = false
        
        let address = Survey.BASE_URL + surveyID
        guard let lookupURL = URL(string: address) else {
            delegate?.surveyEncounteredError(self, error: .invalidRequest, message: nil)
            return
        }

        let urlRequest = URLRequest(url: lookupURL)
        
        let task = CUSTOM_SESSION.dataTask(with: urlRequest) {
            data, response, error in
            
            self.isAlreadyLoading = false
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.surveyEncounteredError(self, error: .connectionError, message: error!.localizedDescription)
                }
                return
            }
            
            do {
                let json = try JSON(data: data!)
                self.surveyData = try SurveyData(json: json) // Might be invalid
                debugMessage("Survey <\(self.surveyID)> is loaded from the server.")
                SURVEY_CACHE[self.surveyID] = self.surveyData
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                // Unable to parse JSON from url data, although connection to the server was established
                
                var msg: String?
                if let json = try? JSON(data: data!) {
                    msg = json.dictionary?["message"]?.string
                }
                DispatchQueue.main.async {
                    self.delegate?.surveyEncounteredError(self, error: .invalidRequest, message: msg)
                }
            }
        }
        
        task.resume()
    }
    
    /// Load (or reload if have been loaded previously) the survey but do not present it yet. *Requires internet connection*.
    public func load() {
        self.load { self.delegate?.surveyDidLoad(self) }
    }
    
    /// Load the survey and present it to the user when it is ready. *Requires internet connection*.
    public func loadAndPresent() {
        self.load {
            self.present()
        }
    }

    /// Present the survey to `target`, provided that is has been loaded from the server.
    public func present() {
        
        guard surveyData != nil else {
            debugMessage("`surveyData` unexpectedly found nil when trying to present survey!")
            delegate?.surveyEncounteredError(self, error: .invalidRequest, message: nil)
            return
        }
        
        guard surveyData!.fragments.count > 0 else {
            debugMessage("The survey contains 0 fragments, exiting..")
            delegate?.surveyEncounteredError(self, error: .emptySurvey, message: nil)
            return
        }
        
        // Initialize a new page controller
        let mySurvey = SurveyViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
        // Copy over the references
        mySurvey.survey = self
        mySurvey.surveyData = surveyData!
        
        let nav = SurveyNavigationController(rootViewController: mySurvey)
        self.targetVC?.present(nav, animated: true) {
            self.delegate?.surveyDidPresent(self)
        }
        
        if submissionMode && !loadedFromCache {
            createSession()
        } else if loadedFromCache {
            debugMessage("Same session (id=\(surveyData!.sessionID)) used for the relaunched survey.")
        }
    }
    
    /// Create a session at the beginning of the survey.
    private func createSession() {
        let dateString = ISO8601DateFormatter().string(from: surveyData!.startTime)
        
        var session = JSON()
        session.dictionaryObject?["startTime"] = dateString
        session.dictionaryObject?["sessionId"] = surveyData!.sessionID
        session.dictionaryObject?["surveyId"] = surveyData!.surveyId
//        session.dictionaryObject?["metadata"] = userAgentMetadata
        
        debugMessage("New survey launched with JSON: \(session)")
        
        var sessionRequest = URLRequest(url: API_SESSION)
        sessionRequest.httpMethod = "POST"
        sessionRequest.httpBody = try? session.rawData()
        sessionRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = CUSTOM_SESSION.dataTask(with: sessionRequest) {
            data, response, error in
            
            guard error == nil else {
                debugMessage("Session failed to create with error: \(error!.localizedDescription)")
                return
            }
        }
        
        task.resume()
    }
    
}


extension Survey {
    
    /// The response status of the survey.
    public enum Error : Int {
        
        /// An invalid survey ID or authorization header was provided.
        case invalidRequest = 1
        
        /// The user does not have a valid internet connection.
        case connectionError = 2
        
        /// The survey has no content.
        case emptySurvey = 3
    }
}
