//
//  RadioCircle.swift
//  SurveyLex
//
//  Created by Jia Rui Shan on 2019/5/15.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class RadioCircle: UIView {
    
    var selected = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
//        let bg = UIBezierPath(rect: bounds)
//        if selected {
//            SELECTION.setFill()
//        } else {
//            UIColor.white.setFill()
//        }
//        bg.fill()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let boundary = UIBezierPath(arcCenter: center, radius: bounds.midX - 2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        boundary.lineWidth = 1.5
        tintColor.setStroke()
        boundary.stroke()
        
        
        if selected {
            let inner = UIBezierPath(arcCenter: center, radius: bounds.midX - 6, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            tintColor.setFill()
            inner.fill()
        }
    }

}
