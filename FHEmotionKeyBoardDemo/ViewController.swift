//
//  ViewController.swift
//  FHEmotionKeyBoardDemo
//
//  Created by shenfh on 16/2/19.
//  Copyright © 2016年 shenfh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var fhTextField:UITextView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let toolView = FHKeyboardToolView.addToView(self.view)
        toolView.textInputView = fhTextField
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
//        fhTextField.becomeFirstResponder()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private var fhShow:Bool = false
    @IBAction func ButtonAction(sender:AnyObject?){
        
//        if fhShow {
//           fhTextField.FHSwitchToDefaultKeyboard()
//            
//        } else {
//            fhTextField.FHSwitchToEmotionKeyboard()
//        }
//        fhShow = !fhShow
//       print("\(fhTextField.FHEmoticonText())")
    }

    @IBAction func BackgroundViewAction(sender:AnyObject?){
        self.view.endEditing(true)
    }
}

