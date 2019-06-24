//
//  EditableTextCell.swift
//  Auth Demo
//
//  Created by Jia Rui Shan on 2019/2/13.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

/// An special type of UITextViewCell that has enhanced functionality
class EditableTextCell: UITableViewCell, UITextFieldDelegate {
    
    private var rightConstraint: NSLayoutConstraint?
    
    var textField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.clearButtonMode = .whileEditing
        field.textContentType = .init(rawValue: "")
        field.returnKeyType = .next
        return field
    }()
    
    var returnHandler: (() -> ())?
    var completionHandler: (() -> ())?
    var changeHandler: (() -> ())?
    
    var status: StatusIcon = .none {
        didSet {
            if let r = rightConstraint {
                r.isActive = false
                textField.removeConstraint(r)
            }
            
            var inset: CGFloat = -15
            
            switch status {
            case .none:
                self.accessoryType = .none
                self.accessoryView = nil
                break
            case .tick:
                inset = -43
                self.accessoryView = UIImageView(image: #imageLiteral(resourceName: "check"))
            case .fail:
                inset = -43
                self.accessoryView = UIImageView(image: #imageLiteral(resourceName: "cross"))
            case .loading:
                inset = -43
                let spinner = UIActivityIndicatorView(style: .gray)
                spinner.startAnimating()
                self.accessoryView = spinner
            case .disconnected:
                inset = -43
                self.accessoryView = UIImageView(image: #imageLiteral(resourceName: "disconnected"))
            case .info:
                inset = -42
                self.accessoryType = .detailButton
            }
            
            rightConstraint = textField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: inset)
            rightConstraint?.isActive = true
        }
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        self.addSubview(textField)
        
        textField.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).isActive = true
        textField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        

        rightConstraint = textField.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15)
        rightConstraint?.isActive = true
        
        self.textField.tintColor = self.tintColor
        self.tintColor = BUTTON_TINT
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnHandler?()
        return true
    }
    
    var originalText = ""
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        originalText = textField.text!
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if originalText != textField.text! || originalText.isEmpty {
            completionHandler?()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if accessoryType != .detailButton {
            status = .none
        }
        return true
    }
    
    @objc private func textDidChange() {
        changeHandler?()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            textField.becomeFirstResponder()
        }
    }

}

extension EditableTextCell {
    enum StatusIcon {
        case none, loading, tick, fail, disconnected, info
    }
}
