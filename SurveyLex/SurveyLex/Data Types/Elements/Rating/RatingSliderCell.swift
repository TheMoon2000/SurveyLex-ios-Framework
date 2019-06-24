//
//  RatingSliderCell.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/6/20.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RatingSliderCell: SurveyElementCell {
    
    let grayColor = UIColor(white: 0.85, alpha: 1)
    let sideMargins: CGFloat = 30
    
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
        }
    }

    init(ratingQuestion: Rating) {
        super.init()
        
        self.ratingQuestion = ratingQuestion
        
        title = makeTextView()
        slider = makeSlider()
        caption = makeCaption()
        addTicks()
        
        sliderChanged()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.attributedText = TextFormatter.formatted(ratingQuestion.title,
                                                          type: .title)
        textView.textColor = .gray
        textView.textAlignment = .left
        textView.isUserInteractionEnabled = false
        textView.dataDetectorTypes = .link
        textView.linkTextAttributes[.foregroundColor] = BLUE_TINT
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                      constant: 30).isActive = true
        textView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor,
                                       constant: 30).isActive = true
        textView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor,
                                        constant: -30).isActive = true
        return textView
    }
    
    private func makeSlider() -> UISlider {
        let slider = UISlider()
        slider.maximumTrackTintColor = .clear
        slider.minimumTrackTintColor = .clear
        slider.maximumValue = 100
        slider.value = 50
        slider.thumbTintColor = DARKER_TINT
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        
        slider.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: sideMargins).isActive = true
        slider.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -sideMargins).isActive = true
        slider.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
//        slider.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        
        slider.isContinuous = true
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderPressed), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderLifted), for: .touchUpInside)
        
        return slider
    }
    
    private func addTicks() {
        
        let segmentCount = CGFloat(ratingQuestion.options.count) - 1
        let thumbWidth = slider.thumbRect(forBounds: slider.bounds,
                                          trackRect: slider.trackRect(forBounds: slider.bounds), value: 50).width
        
        let track = UIView()
        track.backgroundColor = grayColor
        track.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(track, belowSubview: slider)
        
        track.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
        track.leftAnchor.constraint(equalTo: slider.leftAnchor,
                                    constant: thumbWidth / 2).isActive = true
        track.rightAnchor.constraint(equalTo: slider.rightAnchor,
                                     constant: -thumbWidth / 2).isActive = true
        track.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
        
        
        func makeTickmark() -> UIView {
            let tick = UIView()
            tick.backgroundColor = grayColor
            tick.translatesAutoresizingMaskIntoConstraints = false
            return tick
        }
        
        for i in 0..<ratingQuestion.options.count {
            let tickmark = makeTickmark()
            insertSubview(tickmark, belowSubview: slider)
            
            tickmark.widthAnchor.constraint(equalToConstant: 1.1).isActive = true
            tickmark.heightAnchor.constraint(equalToConstant: 12).isActive = true
            
            tickmark.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
            
            /*
             Pseudocode:
             tick.centerX = [slider.right - (sideMargins + thumbWidth)] * i / segmentCount + sideMargins + thumbWidth / 2
             */
            
            NSLayoutConstraint(item: tickmark,
                               attribute: .centerX,
                               relatedBy: .equal,
                               toItem: slider,
                               attribute: .right,
                               multiplier: max(.leastNormalMagnitude, CGFloat(i) / segmentCount),
                               constant: sideMargins + thumbWidth / 2 - (sideMargins + thumbWidth) * CGFloat(i) / segmentCount).isActive = true
    
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
        label.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                      constant: -12).isActive = true
        
        return label
    }
    

    @objc private func sliderChanged() {
        let segment: Float = 100.0 / (Float(ratingQuestion.options.count) - 1)
        slider.value = round(slider.value / segment) * segment
        if slider.value != currentValue {
            currentValue = slider.value
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    @objc private func sliderPressed() {
        surveyPage?.focus(cell: self)
        slider.thumbTintColor = BLUE_TINT
    }
    
    @objc private func sliderLifted() {
        ratingQuestion.completed = true
        surveyPage?.focusedRow += 1
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override func focus() {
        super.focus()
        title.textColor = .black
        UIView.performWithoutAnimation {
            slider.thumbTintColor = ratingQuestion.completed ? BLUE_TINT : .lightGray
        }
    }
    
    override func unfocus() {
        super.unfocus()
        title.textColor = .gray
        UIView.performWithoutAnimation {
            slider.thumbTintColor = ratingQuestion.completed ? DISABLED_BLUE : grayColor
            slider.alpha = 1.0
        }
    }
    
}
