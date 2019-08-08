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
let RECORDING = UIColor(red: 0.99, green: 0.4, blue: 0.4, alpha: 1)
let RECORDING_PRESSED = UIColor(red: 0.95, green: 0.36, blue: 0.36, alpha: 1)

// MARK: API URLS

/// The URL to the API that is responsible for creating a session. A session should be created before any response is submitted to the server. The POST data should be of the type `application/json`.
let API_SESSION = URL(string: "https://api.neurolex.ai/1.0/object/sessions")!

/// The URL to the API that is responsible for receiving most types of questions. Every call to this API should deliver a user's response for one page (a.k.a. fragment) of a survey in a given session. The POST data should be of the type `application/json`.
let API_RESPONSE = URL(string: "https://api.neurolex.ai/1.0/object/responses")!

/// The URL to the API that is responsible for receiving the .WAV audio data in a survey. The POST data should be of the type `multipart/form-data`.
let API_AUDIO_SAMPLE = URL(string: "https://api.neurolex.ai/1.0/collector/sample")!

/// The URL prefix for SurveyLex surveys.
let SURVEY_URL_PREFIX = "https://app.surveylex.com/surveys"

let AUDIO_CACHE_DIR = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("SurveyLex", isDirectory: true)

// MARK: Environment variables

// These constants are now environment variables in `Survey` class, but their default fallback values are preserved in this file.
let UNFOCUSED_ALPHA: CGFloat = 0.3
let SIDE_PADDING: CGFloat = 20.0

/// A global constant setting the minimum allowed duration (in seconds) for any audio question.
let MIN_RECORDING_LENGTH = 3.0

/// A global constant setting the minimum allowed max length (in seconds) for any audio question. This constant needs to be greater than `MIN_RECORDING_LENGTH`.
let MIN_MAX_RECORDING_LENGTH = 5.0

/// How wide the separator lines are.
let SEPARATOR_WIDTH: CGFloat = 90.0

/// Whether debug statements are printed to the console.
let DEBUG_MODE = true

// MARK: - Extensions and other constants

extension UITextView {
    
    func format(as type: TextFormatter.TextType, theme: Survey.Theme) {
        self.isEditable = false
        self.isScrollEnabled = false
        self.textAlignment = .left
        self.textDragInteraction?.isEnabled = false
        self.attributedText = TextFormatter.formatted(text, type: type)
        self.dataDetectorTypes = .link
        self.linkTextAttributes[.foregroundColor] = theme.medium
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

extension CGFloat {
    static let tinyPositive: CGFloat = 0.000001
}

extension Data {
    mutating func append(string: String) {
        let data = string.data(using: .utf8)!
        append(data)
    }
}

/// Display a debug message.
func debugMessage(_ msg: String) {
    if DEBUG_MODE {
        print(msg)
    }
}

// MARK: - Custom notifications

/// A notification that is triggered when a fragment finished upload
let FRAGMENT_UPLOAD_COMPLETE = Notification.Name.init(rawValue: "Fragment upload completed")

/// A notification that is triggered when a fragment failed to upload
let FRAGMENT_UPLOAD_FAIL = Notification.Name.init("Fragment upload failed")

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
