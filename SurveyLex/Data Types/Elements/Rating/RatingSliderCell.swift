//
//  RatingSliderCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// A subclass of `SurveyElementCell` that displays a rating question.
class RatingSliderCell: SurveyElementCell {
    
    /// The left and right insets.
    let sideMargins: CGFloat = 25
    
    
    override var completed: Bool {
        return ratingQuestion.completed
    }
    
    /// Custom gray color used for the ticks and the track.
    let grayColor = UIColor(white: 0.85, alpha: 1)
    
    /// The text view for the title of the rating question.
    var title: UITextView!
    var slider: UISlider!
    var caption: UILabel!
    var ratingQuestion: Rating!
    var currentValue: Float = 50.0 {
        didSet {
            let segmentLength = 100.0 / Float(ratingQuestion.options.count - 1)
            let index = Int(round(currentValue / segmentLength))
            let option = ratingQuestion.options[index]
            caption.text = option.text
            ratingQuestion.selectionString = option.text
            ratingQuestion.sliderValue = currentValue
           
            // Tell the fragment page controller that its information needs to be uploaded again
            surveyPage.uploaded = false
        }
    }
    
    
    // MARK: UI Setup

    init(ratingQuestion: Rating) {
        super.init()
                
        self.ratingQuestion = ratingQuestion
        
        title = {
            let textView = UITextView()
            textView.text = ratingQuestion.title
            textView.format(as: .title, theme: ratingQuestion.theme)
            textView.textColor = .black
            textView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(textView)
            
            textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                          constant: 20).isActive = true
            textView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                           constant: SIDE_PADDING).isActive = true
            textView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                            constant: -SIDE_PADDING).isActive = true
            return textView
        }()
        
        slider = makeSlider()
        caption = makeCaption()
        addTicks()
        
        currentValue = ratingQuestion.sliderValue
    }
    
    
    private func makeSlider() -> UISlider {
        let slider = UISlider()
        slider.maximumTrackTintColor = .clear
        slider.minimumTrackTintColor = .clear
        slider.maximumValue = 100
        slider.value = ratingQuestion.sliderValue
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        
        slider.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: sideMargins).isActive = true
        slider.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -sideMargins).isActive = true
        slider.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderPressed), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderLifted), for: [.touchUpInside, .touchUpOutside])
        
        return slider
    }
    
    private func addTicks() {
        
        let ticks = UIView()
        ticks.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(ticks, belowSubview: slider)
        ticks.leftAnchor.constraint(equalTo: slider.leftAnchor).isActive = true
        ticks.rightAnchor.constraint(equalTo: slider.rightAnchor).isActive = true
        ticks.topAnchor.constraint(equalTo: slider.topAnchor).isActive = true
        ticks.bottomAnchor.constraint(equalTo: slider.bottomAnchor).isActive = true
        
        let segmentCount = CGFloat(ratingQuestion.options.count) - 1
        let thumbWidth = slider.thumbRect(forBounds: slider.bounds,
                                          trackRect: slider.trackRect(forBounds: slider.bounds), value: 0).width - 4
        
        let track = UIView()
        track.backgroundColor = grayColor
        track.translatesAutoresizingMaskIntoConstraints = false
        ticks.addSubview(track)
        
        track.heightAnchor.constraint(equalToConstant: 2).isActive = true
        track.leftAnchor.constraint(equalTo: slider.leftAnchor,
                                    constant: thumbWidth / 2).isActive = true
        track.rightAnchor.constraint(equalTo: slider.rightAnchor,
                                     constant: -thumbWidth / 2).isActive = true
        track.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
        
        // Ticks
        
        func makeTickmark() -> UIView {
            let tick = UIView()
            tick.backgroundColor = grayColor
            tick.translatesAutoresizingMaskIntoConstraints = false
            ticks.addSubview(tick)
                
            tick.widthAnchor.constraint(equalToConstant: 2).isActive = true
            tick.heightAnchor.constraint(equalToConstant: 12).isActive = true
            tick.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
            
            return tick
        }
        
        for i in 0..<ratingQuestion.options.count {
            let tickmark = makeTickmark()
            
            
            //  Pseudocode:
            //  tick.centerX = (slider.right - thumbWidth) * i / segmentCount + thumbWidth / 2
            
            
            //  Note: The `multiplier` property cannot be zero, so we need to use a sufficiently small but positive number instead.
            
            NSLayoutConstraint(item: tickmark,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: ticks,
                               attribute: .right,
                               multiplier: max(.tinyPositive,
                                               CGFloat(i) / segmentCount),
                               constant: -thumbWidth * CGFloat(i) / segmentCount + thumbWidth / 2).isActive = true
    
        }
    }
    
    
    private func makeCaption() -> UILabel {
        let label = UILabel()
        label.text = "No rating is given."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: slider.bottomAnchor,
                                   constant: 15).isActive = true
        let bottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        bottomConstraint.priority = .init(999)
        bottomConstraint.isActive = true
        
        return label
    }
    
    // MARK: Control handlers
    
    @objc private func sliderChanged() {
        let segment: Float = 100.0 / (Float(ratingQuestion.options.count) - 1)
        slider.value = round(slider.value / segment) * segment
        if slider.value != currentValue {
            currentValue = slider.value
            UISelectionFeedbackGenerator().selectionChanged()
            
            // Tell the fragment that its information needs to be uploaded again
            surveyPage.uploaded = false
        }
    }
    
    @objc private func sliderPressed() {
        surveyPage.focus(cell: self)
        UISelectionFeedbackGenerator().selectionChanged()
        
        // First press requires special handling
        if slider.thumbTintColor! == .lightGray {
            let segmentLength = 100.0 / Float(ratingQuestion.options.count - 1)
            let index = Int(round(currentValue / segmentLength))
            let option = ratingQuestion.options[index]
            caption.text = option.text
            slider.thumbTintColor = ratingQuestion.theme.medium
        }
    }
    
    @objc private func sliderLifted() {
        if !ratingQuestion.completed {
            ratingQuestion.completed = true
            let _ = !ratingQuestion.parentView!.toNext(from: self)
        }
    }
    
    // MARK: Customized focus/unfocus visual effects
    
    override func focus() {
        super.focus()
        UIView.performWithoutAnimation {
            slider.thumbTintColor = ratingQuestion.completed ? ratingQuestion.theme.medium : .lightGray
        }
    }
    
    override func unfocus() {
        super.unfocus()
        if autofocus {
            UIView.performWithoutAnimation {
                slider.thumbTintColor = ratingQuestion.completed ? ratingQuestion.theme.light : grayColor
                slider.alpha = 1.0
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
