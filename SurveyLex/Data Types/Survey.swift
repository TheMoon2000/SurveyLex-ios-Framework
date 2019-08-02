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
public class Survey: CustomStringConvertible {
    
    /// Used for storing cached surveys.
    static var cached = [String : SurveyData]()
    
    /// The NeuroLex SurveyLex API URL prefix.
    private static let BASE_URL = "https://api.neurolex.ai/1.0/object/surveys/taker/"
    
    /// The survey ID as a uuid string.
    private(set) var surveyID = ""
    
    /// Whether a `URLSession` task is already running.
    private var isAlreadyLoading = false
    
    /// The view controller that will present the survey when `present()` is called.
    public var targetVC: UIViewController?
    
    /// The data content of the survey.
    private(set) var surveyData: SurveyData?
    
    /// Whether the survey data is loaded from cache.
    private var loadedFromCache = false
    
    /// Optional delegate that handles survey responses.
    public var delegate: SurveyResponseDelegate?
    
    // MARK: - Environment variables
    
    /// Whether multiple choice / checkbox menus are allowed to collapse once expanded.
    public var allowMenuCollapse = false
    
    /// Whether the current survey element has higher opacity relative to other items.
    public var visibilityDifferentiation = true
    
    /// Whether the current instance creates a session and counts as a view toward the survey statistics. If set to false (i.e. stealth mode), the user's interactions with this survey will not be sent to the server.
    public var isSubmissionMode = true
    
    /// Whether a landing page is shown the first time the survey is opened.
    public var showLandingPage = true
    
    /// Whether the navigation menu is shown at the bottom of every page.
    public var showNavigationMenu = true
    
    /// The user can go to another page by specifying the page number.
    public var allowJumping = false
    
    /// Whether incomplete sessions are cached.
    public var useCache = true
    
    /// The color scheme of the survey.
    public var theme: Theme = .blue
    
    // MARK: Survey class implementation
    
    /**
     Initializes a local `Survey` front-end by providing a JSON data source. **This constructor is only used for debugging and is not recommended**.
    
     - Parameters:
        - json: The input json source object to display.
        - target: The UIViewController that will present the survey.
     */
    public init(json: JSON, target: UIViewController) throws {
        self.surveyData = try SurveyData(json: json, theme: theme)
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
        
        if useCache, let cache = Survey.cached[surveyID] {
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
                self.surveyData = try SurveyData(json: json, theme: self.theme, landingPage: self.showLandingPage)
                debugMessage("Survey <\(self.surveyID)> is loaded from the server.")
                Survey.cached[self.surveyID] = self.surveyData
                
                // Depending on whether there is a logo, we call the completion handler at different times
                if let logoURL = json.dictionary?["logoUrl"]?.url {
                    self.loadImage(logoURL: logoURL) { completion() }
                } else {
                    DispatchQueue.main.async {
                        completion()
                    }
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
    
    /// Loads the logo image of a survey using the provided URL.
    private func loadImage(logoURL: URL, completion: @escaping (() -> ())) {
        let task = CUSTOM_SESSION.dataTask(with: logoURL) {
            data, response, error in
            
            guard error == nil else {
                debugMessage("The provided logo image at \(logoURL) could not be downloaded. Error message: '\(error!.localizedDescription)'")
                return
            }
            
            if let image = UIImage(data: data!) {
                self.surveyData?.logo = image
            } else {
                debugMessage("The provided logo image at \(logoURL) could not be read.")
            }
            
            DispatchQueue.main.async { completion() }
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
        
        if isSubmissionMode && !loadedFromCache {
            createSession()
        } else if loadedFromCache {
            debugMessage("Same session (id=\(surveyData!.sessionID)) used for the relaunched survey.")
        }
    }
    
    /// Create a session at the beginning of the survey.
    private func createSession() {
        let dateString = ISO8601DateFormatter().string(from: Date())
        
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
    
    /// A color theme for the survey.
    public struct Theme {
        
        /// The color used for text-based questions and the pressed-state of most buttons.
        var dark: UIColor
        
        /// The main color used for button colors, controls and hyperlinks.
        var medium: UIColor
        
        /// The color used for disabled controls and others.
        var light: UIColor
        
        /// The background color for some views, such as the highlight color for choices in a multiple choice question.
        var highlight: UIColor
        
        // Presets
        /// A predefined dblue theme (also the default theme).
        public static let blue = Theme(
            dark: UIColor(red: 79/255, green: 144/255, blue: 240/255, alpha: 1),
            medium: UIColor(red: 104/255, green: 165/255, blue: 245/255, alpha: 1),
            light: UIColor(red: 165/255, green: 204/255, blue: 252/255, alpha: 1),
            highlight: UIColor(red: 232/255, green: 242/255, blue: 1, alpha: 1)
        )
        
        /// A predefined green theme.
        public static let green = Theme(
            dark: UIColor(red: 62/255, green: 184/255, blue: 71/255, alpha: 1),
            medium: UIColor(red: 80/255, green: 192/255, blue: 92/255, alpha: 1),
            light: UIColor(red: 157/255, green: 228/255, blue: 160/255, alpha: 1),
            highlight: UIColor(red: 230/255, green: 1, blue: 232/255, alpha: 1)
        )
        
        /// A predefined cyan theme.
        public static let cyan = Theme(
            dark: UIColor(red: 75/255, green: 201/255, blue: 168/255, alpha: 1),
            medium: UIColor(red: 116/255, green: 217/255, blue: 186/255, alpha: 1),
            light: UIColor(red: 182/255, green: 237/255, blue: 224/255, alpha: 1),
            highlight: UIColor(red: 229/255, green: 1, blue: 251/255, alpha: 1)
        )
        
        /// A predefined purple theme.
        public static let purple = Theme(
            dark: UIColor(red: 149/255, green: 132/255, blue: 235/255, alpha: 1),
            medium: UIColor(red: 168/255, green: 153/255, blue: 250/255, alpha: 1),
            light: UIColor(red: 200/255, green: 196/255, blue: 252/255, alpha: 1),
            highlight: UIColor(red: 229/255, green: 228/255, blue: 1, alpha: 1)
        )
        
        /// A predefined orange theme.
        public static let orange = Theme(
            dark: UIColor(red: 242/255, green: 174/255, blue: 17/255, alpha: 1),
            medium: UIColor(red: 248/255, green: 191/255, blue: 59/255, alpha: 1),
            light: UIColor(red: 1, green: 221/255, blue: 154/255, alpha: 1),
            highlight: UIColor(red: 1, green: 245/255, blue: 223/255, alpha: 1)
        )
        
        /// Create a new color theme for surveys.
        public init(dark: UIColor, medium: UIColor, light: UIColor, highlight: UIColor) {
            self.dark = dark
            self.medium = medium
            self.light = light
            self.highlight = highlight
        }
    }
    
    public var description: String {
        if surveyData != nil {
            return "Survey <\(surveyID)> with data: \(surveyData!.description)"
        } else if surveyID != "" {
            return "Empty Survey object <\(surveyID)>"
        } else {
            return "Empty Survey object"
        }
    }
}
