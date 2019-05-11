//
//  MainTabBarController.swift
//  Voice Capture Utility
//
//  Created by Jia Rui Shan on 2019/5/6.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tabBar.tintColor = BUTTON_DEEP_BLUE
        initializeTabs()
    }
    
    private func initializeTabs() {
        let recordTab = RecordViewController()
        recordTab.tabBarItem = UITabBarItem(title: "Record Demo", image: #imageLiteral(resourceName: "microphone_filled"), tag: 0)
        let lookupTab = SurveyIDViewController()
        lookupTab.tabBarItem = UITabBarItem(title: "Survey Lookup Demo", image: #imageLiteral(resourceName: "search"), tag: 1)
        viewControllers = [recordTab, lookupTab].map {
            return UINavigationController(rootViewController: $0)
        }
    }

}
