//
//  RecordingDelegate.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/14.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

protocol RecordingDelegate {
    func didBeginRecording(_ sender: RecordButton)
    func didFinishRecording(_ sender: RecordButton, duration: Double)
    func didFailToRecord(_ sender: RecordButton, error: Recorder.Error)
}
