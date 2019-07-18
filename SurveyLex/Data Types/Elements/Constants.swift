//
//  Constants.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: Colors

// These constants can only be changed through framework modification.
let BUTTON_LIGHT_TINT = UIColor(red: 0.75, green: 0.89, blue: 1, alpha: 1)
let BUTTON_DEEP_BLUE = UIColor(red: 0.49, green: 0.7, blue: 0.94, alpha: 1)
let BUTTON_TINT = UIColor(red: 0.7, green: 0.85, blue: 1, alpha: 1)
let BUTTON_PRESSED = UIColor(red: 0.39, green: 0.59, blue: 0.88, alpha: 1)
let RECORD_TINT = UIColor(red: 1, green: 0.51, blue: 0.5, alpha: 1)
let BLUE_TINT = UIColor(red: 0.43, green: 0.64, blue: 0.94, alpha: 1)
let DARKER_TINT = UIColor(red: 0.33, green: 0.56, blue: 0.94, alpha: 1)
let SELECTION = UIColor(red: 0.9, green: 0.95, blue: 1, alpha: 1)
let DISABLED_BLUE = UIColor(red: 0.65, green: 0.79, blue: 0.99, alpha: 1)
let RECORDING = UIColor(red: 0.99, green: 0.4, blue: 0.4, alpha: 1)
let RECORDING_PRESSED = UIColor(red: 0.93, green: 0.36, blue: 0.36, alpha: 1)

// MARK: API URLS

/// The URL to the API that is responsible for creating a session. A session should be created before any response is submitted to the server. The POST data should be of the type `application/json`.
let API_SESSION = URL(string: "https://api.neurolex.ai/1.0/object/sessions")!

/// The URL to the API that is responsible for receiving most types of questions. Every call to this API should deliver a user's response for one page (a.k.a. fragment) of a survey in a given session. The POST data should be of the type `application/json`.
let API_RESPONSE = URL(string: "https://api.neurolex.ai/1.0/object/responses")!

/// The URL to the API that is responsible for receiving the overview information for a specific audio sample. The POST data should be of the type `application/json`.
let API_SAMPLE = URL(string: "https://api.neurolex.ai/1.0/object/samples")!

/// The URL to the API that is responsible for receiving the .WAV audio data in a survey. The POST data should be of the type `multipart/form-data`.
let API_AUDIO_SAMPLE = URL(string: "https://api.neurolex.ai/1.0/collector/samples")!

// MARK: Environment variables

// These constants are now environment variables in `Survey` class, but their default fallback values are preserved in this file.
let UNFOCUSED_ALPHA: CGFloat = 0.3
let SIDE_PADDING: CGFloat = 20.0

// MARK: Extensions and other constants

extension UITextView {
    
    func format(as type: TextFormatter.TextType) {
        self.isEditable = false
        self.isScrollEnabled = false
        self.textAlignment = .left
        self.attributedText = TextFormatter.formatted(text, type: type)
        self.dataDetectorTypes = .link
        self.linkTextAttributes[.foregroundColor] = BLUE_TINT
        self.textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0.0
        self.backgroundColor = .clear
    }
}

/// Custom URLSessionConfiguration with no caching
let CUSTOM_SESSION: URLSession = {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    config.timeoutIntervalForRequest = 5.0
    return URLSession(configuration: config)
}()


// Attempted to generate a custom user agent string for iOS devices, but the server didn't accept this format, so the code below is not being used.
let userAgentMetadata: JSON = {
    let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    let appVersion = Bundle.main.infoDictionary![kCFBundleVersionKey as String] as! String
    let device = UIDevice.current.name
    let system = UIDevice.current.systemName
    let version = UIDevice.current.systemVersion
    
    let userAgentString = "\(appName)/\(appVersion) \(system)/\(version) (\(device))"
    return JSON(dictionaryLiteral: ("userAgent", ["ua": userAgentString]))
}()
