//
//  MainTabBarController.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tabBar.tintColor = BUTTON_DEEP_BLUE
        initializeTabs()
    }
    
    private func initializeTabs() {
        let lookupTab = SurveyIDViewController()
        lookupTab.tabBarItem = UITabBarItem(title: "SurveyLex Demo", image: #imageLiteral(resourceName: "search"), tag: 0)
        viewControllers = [lookupTab].map {
            return UINavigationController(rootViewController: $0)
        }
    }

}
