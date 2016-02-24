//
//  FHKeyboardToolView.swift
//  FHEmotionKeyBoardDemo
//
//  Created by shenfh on 16/2/23.
//  Copyright © 2016年 shenfh. All rights reserved.
//

import UIKit

private let FHKeyboardToolViewHeight:CGFloat = 40
private let FHDefaultPadding:CGFloat = -7

@IBDesignable
public class FHKeyboardToolView:UIView {
    
    public class func addToView(view:UIView)->FHKeyboardToolView {
        let toolView = FHKeyboardToolView()       
        toolView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolView)
        let views = ["toolView":toolView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
       toolView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[toolView(\(FHKeyboardToolViewHeight))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        toolView.vOldConstraint = NSLayoutConstraint(item: toolView, attribute: .BottomMargin, relatedBy: .Equal, toItem: view, attribute: .BottomMargin, multiplier: 1, constant: FHDefaultPadding)
        view.addConstraint(toolView.vOldConstraint!)
        return toolView
    }
    
    init(){
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, FHKeyboardToolViewHeight))
        prepareUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepareUI()
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    private func prepareUI(){
        self.backgroundColor = UIColor.FHRGBColor(0xf4f4f6, alpha: 1)
        
        self.addSubview(emotionButton)
        emotionButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[emotionButton(35)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["emotionButton":emotionButton]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[emotionButton(35)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["emotionButton":emotionButton]))
        self.addConstraint(NSLayoutConstraint(item: emotionButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardWillShowActon:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardWillHidenActon:", name: UIKeyboardWillHideNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "KeyboardWillWillChangeFrameActon:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    // MARK: public var
    public weak var textInputView:UITextView?
    public var vOldConstraint:NSLayoutConstraint?
  
    //MARK: pravate var
    private lazy var emotionButton:UIButton = {
       let emotionButton = UIButton()
        emotionButton.setImage(UIImage(named: "board_emoji"), forState: .Normal)
        emotionButton.addTarget(self, action: "FHEmotionButtonAction:", forControlEvents: .TouchUpInside)
        return emotionButton
    }()
    
    @objc private func FHEmotionButtonAction(button:UIButton){
        guard let textInputView = textInputView else {
            return
        }
        
        guard textInputView.inputView == nil  else {
            button.setImage(UIImage(named: "board_emoji"), forState: .Normal)
            textInputView.FHSwitchToDefaultKeyboard()
            return
        }
        button.setImage(UIImage(named: "board_system"), forState: .Normal)
        textInputView.FHSwitchToEmotionKeyboard()
    }
    
    @objc private func KeyboardWillShowActon(notifition:NSNotification){
        guard let userinfo = notifition.userInfo else {
            return
        }
        guard let superView = self.superview else {
            return
        }
       
        guard let frameEnd = userinfo[UIKeyboardFrameEndUserInfoKey] as?NSValue else {
            return
        }
        guard let duration = userinfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else {
            return
        }
        
        let keyboardFrame = frameEnd.CGRectValue()
        self.vOldConstraint?.constant = -keyboardFrame.height + FHDefaultPadding
        UIView.animateWithDuration(duration) { () -> Void in
            superView.layoutIfNeeded()
        }
        
    }
    
    @objc private func KeyboardWillHidenActon(notifition:NSNotification){
        guard let superView = self.superview else {
            return
        }
        guard let userinfo = notifition.userInfo else {
            return
        }
        guard let constraints = self.vOldConstraint else {
            return
        }
        guard let duration = userinfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else {
            return
        }
        constraints.constant = FHDefaultPadding
        UIView.animateWithDuration(duration) { () -> Void in
            superView.layoutIfNeeded()
        }
    }
//    @objc private func KeyboardWillWillChangeFrameActon(notifition:NSNotification){
//            print("\(notifition)")
//    }
}
