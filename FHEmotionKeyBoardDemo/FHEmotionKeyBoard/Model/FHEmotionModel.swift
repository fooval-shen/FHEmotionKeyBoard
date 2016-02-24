//
//  FHEmotionModel.swift
//  FHEmotionKeyBoard
//
//  Created by shenfh on 16/2/19.
//  Copyright © 2016年 shenfh. All rights reserved.
//

import Foundation


public struct FHEmotionModel {
    public var emotionName:String = ""
    public var emotionPath:String = ""
}


public struct FHEmotionPackageModel {
   
    public init(name:String,path:String) {
        self.packageName = name
        self.packagePath = path
        loadEmotion()
    }
    
    public var packageName:String = ""
    public var packagePath:String = ""
    
    public var emotions           = [FHEmotionModel]()
    
    
    private mutating func loadEmotion() {
        if packagePath.isEmpty {
            fatalError("empty emotion package path")
        }
        emotions.removeAll()
        let plistFile = packagePath + "/Root.plist"
        if let dicValue = NSDictionary(contentsOfFile: plistFile) {
            if let emotionDic = dicValue.objectForKey("emotion") as? NSDictionary {
                for value in emotionDic{
                    emotions.append(FHEmotionModel(emotionName: "\(value.value)", emotionPath: "\(packagePath)/images/\(value.key).png"))
                    
                }
            }
            
        }
    }
}