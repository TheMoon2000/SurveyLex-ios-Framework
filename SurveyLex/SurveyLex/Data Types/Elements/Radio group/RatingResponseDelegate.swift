//
//  RatingResponseDelegate.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A set of required methods that handle a rating event.
protocol RatingResponseDelegate {
    func didSelectRow(row: Int)
}
