//
//  UnsupportedPage.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/7/23.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A generic survey page used as a fallback to display unsupported fragment types.
class UnsupportedPage: UIViewController, SurveyPage {
    
    // MARK: - Protocol requirements
    
    var fragmentData: Fragment!
    
    var surveyViewController: SurveyViewController?
    
    var completed: Bool = false
    
    var unlocked = true
    
    var uploaded = true
    
    var needsReupload = false
    
    var navigationMenu: FragmentMenu!
    
    var fixScreen: Bool {
        return false
    }
    
    // MARK: - Custom instance variables
    
    private var canvas: UIScrollView!
    private var content: UITextView!
    
    // MARK: - UI setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        canvas = {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.showsHorizontalScrollIndicator = false
            view.addSubview(scrollView)
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            
            return scrollView
        }()

        content = {
            let label = UITextView()
            label.text = fragmentData.fragmentSource.description
            label.font = .systemFont(ofSize: 16)
            label.isScrollEnabled = false
            label.isEditable = false
            label.translatesAutoresizingMaskIntoConstraints = false
            canvas.addSubview(label)
            
            label.topAnchor.constraint(equalTo: canvas.topAnchor, constant: 30).isActive = true
            label.bottomAnchor.constraint(equalTo: canvas.bottomAnchor, constant: -30).isActive = true
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.transition(with: surveyViewController!.navigationMenu,
                          duration: 0.3,
                          options: .curveEaseInOut,
                          animations: {
                              self.surveyViewController?.navigationMenu.alpha = 1.0
                          },
                          completion: nil)
        
        navigationMenu.enableUserInteractions(true)
    }
    
    func uploadResponse() {}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
