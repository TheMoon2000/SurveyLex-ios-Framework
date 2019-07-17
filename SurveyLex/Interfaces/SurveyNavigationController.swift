//
//  SurveyNavigationController.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//


import UIKit

/// A UINavigationController wrapper, allowing full customization of the navigation bar.
class SurveyNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor(white: 1, alpha: 1)
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
    }

}
