//
//  FHEmotionExtensionView.swift
//  FHEmotionKeyBoardDemo
//
//  Created by shenfh on 16/2/22.
//  Copyright © 2016年 shenfh. All rights reserved.
//

import UIKit

extension UITextView {
    public func FHSwitchToEmotionKeyboard(block:EmotionKeyboardBlock? = nil){
        let keyboard             = FHEmotionKeyboardView(block: block)
        keyboard.FHTextInputView = self
        self.inputView           = keyboard
        self.reloadInputViews()
        if !self.isFirstResponder() {
            self.becomeFirstResponder()
        }
    }
    
    public func FHSwitchToDefaultKeyboard(){
        self.inputView = nil
        self.reloadInputViews()
        if !self.isFirstResponder() {
            self.becomeFirstResponder()
        }
    }
    
    
    public func FHInsertEmoticon(model: FHEmotionModel){
        if model.emotionPath.isEmpty{
            insertText(model.emotionName)
            return
        }
        let image = UIImage(contentsOfFile: model.emotionPath)
        if image == nil {
            insertText(model.emotionName)
            return
        }
        var  height:CGFloat = 15
        if self.font != nil {
            height = (self.font?.lineHeight)!
        }
        
        let attachment = MQEmotionAttachment(emotionname: model.emotionName, emotionImage: image!, width: height)
        
        let attrString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
            attrString.addAttribute(NSFontAttributeName, value: font!, range: NSRange(location: 0, length: 1))
        
        let attrM = NSMutableAttributedString(attributedString: attributedText!)
        let sRange = self.selectedRange
        attrM.replaceCharactersInRange(sRange, withAttributedString: attrString)
        attributedText = attrM
        
        self.selectedRange = NSRange(location: sRange.location + 1, length: 0)
        
        NSNotificationCenter.defaultCenter().postNotificationName(UITextViewTextDidChangeNotification, object: self)
        delegate?.textViewDidChange?(self)
    }

    
    public func FHEmoticonText() -> String {
        var fhText = ""
        attributedText.enumerateAttributesInRange(NSRange(location: 0, length: attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (result, range, _) -> Void in
            if let attachment = result["NSAttachment"] as? MQEmotionAttachment{
                fhText += attachment.mqEmotionName ?? ""
            } else {
                let str = (self.attributedText.string as NSString).substringWithRange(range)
                fhText += str
            }
        }
        return fhText
    }
}

extension UIColor {
    public class func FHRGBColor(rgbValue:Int32,alpha:CGFloat) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: alpha);
    }
}
