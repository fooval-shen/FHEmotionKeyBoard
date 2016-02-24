//
//  MQEmotionAttachment.swift
//  meiqu
//
//  Created by shenfh on 16/2/16.
//  Copyright © 2016年 com.meiqu.com. All rights reserved.
//

import UIKit

public class MQEmotionAttachment: NSTextAttachment {
    
    init(emotionname:String,emotionImage:UIImage,width:CGFloat = 15) {
       super.init(data: nil, ofType: nil)
        self.mqEmotionName = emotionname
        self.image = emotionImage
        self.bounds = CGRect(x: 0, y: -2, width: width+3, height: width+3)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var mqEmotionName:String?
}
