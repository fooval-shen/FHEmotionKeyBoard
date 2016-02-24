//
//  FHEmotionKeyboardView.swift
//  FHEmotionKeyBoard
//
//  Created by shenfh on 16/2/19.
//  Copyright © 2016年 shenfh. All rights reserved.
//

import UIKit


public let FHEmotinKeyboardHeight:CGFloat = 200.0
public let FHEmotionLines:UInt = 3
public let FHEmotionRows:UInt  = 8


public enum EmotionActionType {
    case SendButton
}

public typealias EmotionKeyboardBlock = ((type: EmotionActionType, object: AnyObject?) -> ())

public class FHEmotionKeyboardView:UIView {
    init(block:EmotionKeyboardBlock?){
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, FHEmotinKeyboardHeight))
        prepareUI()
        self.block = block
    }

    public required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        prepareUI()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func prepareUI(){
        self.backgroundColor = UIColor.whiteColor()
        self.addSubview(collectionView)
        self.addSubview(toolBar)
        self.addSubview(pageControl)
        self.addSubview(deleteButton)
        self.addSubview(sendButton)
        
        pageControl.translatesAutoresizingMaskIntoConstraints    = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints        = false
        deleteButton.translatesAutoresizingMaskIntoConstraints   = false
        sendButton.translatesAutoresizingMaskIntoConstraints     = false
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView" : collectionView]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolBar]-0-[sendButton(40)]-10-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["toolBar" : toolBar,"sendButton":sendButton]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[pageControl]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["pageControl":pageControl]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-[pageControl(30)]-0-[toolBar(40)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView" : collectionView, "toolBar": toolBar,"pageControl":pageControl]))
        
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[deleteButton(26)]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["deleteButton":deleteButton]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[deleteButton(30)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["deleteButton":deleteButton]))
        self.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .CenterY, relatedBy: .Equal, toItem: pageControl, attribute: .CenterY, multiplier: 1, constant: 0))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[sendButton(25)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["sendButton":sendButton]))
        self.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .CenterY, relatedBy: .Equal, toItem: toolBar, attribute: .CenterY, multiplier: 1, constant: 0))
        
        FHAddEmotionPackage("test1", path: NSBundle.mainBundle().pathForResource("emotion1", ofType: "bundle")!)
        FHAddEmotionPackage("test2", path: NSBundle.mainBundle().pathForResource("emotion2", ofType: "bundle")!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "FHTextViewDicChangeNotification:", name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    public func FHAddEmotionPackage(name:String,path:String) {
        if path.isEmpty {
            return
        }
        let model = FHEmotionPackageModel(name: name, path: path)
        FHEmotionPackages.append(model)
        
        var toolbarItems = toolBar.items ?? [UIBarButtonItem]()
        let button       = toolBarButton(name)
        button.tag       = toolbarItems.count + FHToolbarButtonTag
        toolbarItems.append(UIBarButtonItem(customView: button) )
        
        toolBar.items = toolbarItems
        
        if FHSelectedButton == nil {
            FHSelectToolbarButton(button)
            FHSetCurrentPage(NSIndexPath(forRow: 0, inSection: 0))
        }
    }
    
    // MARK: private func
    private func FHSelectToolbarButton(button:UIButton){
        FHSelectedButton?.selected = false
        button.selected = true
        FHSelectedButton = button
    }
    private func toolBarButton(text:String)->UIButton {
        let button = UIButton()
        button.setTitle(text, forState: UIControlState.Normal)
        button.sizeToFit()
        button.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
        button.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Selected)
        button.addTarget(self, action: "FHClickEmotionButton:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    private func FHSetCurrentPage(indexPath:NSIndexPath) {
        if let package:FHEmotionPackageModel = FHEmotionPackages[indexPath.section] {
            let count = package.emotions.count
            var pages = count/itemNums
            if (count % itemNums) != 0 {
                pages++
            }
            pageControl.numberOfPages = pages
            pageControl.currentPage   = indexPath.row / itemNums
        }
    }
    
    @objc private func FHClickEmotionButton(button: UIButton){
        if button.tag >= FHToolbarButtonTag {
            let indexPath = NSIndexPath(forItem: 0, inSection: button.tag - FHToolbarButtonTag)
            collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.Left)
             FHSetCurrentPage(indexPath)
            FHSelectToolbarButton(button)
        }
    }
    @objc private func FHEmotionDeleteButtonAction(button: UIButton){
        if let textView = self.FHTextInputView {
            textView.deleteBackward()
        }
    }
    @objc private func FHSendButtonAction(button:UIButton){
        if let textView = self.FHTextInputView {           
            self.block?(type: .SendButton,object: textView.FHEmoticonText())
        }
    }
    
    
    @objc private func FHTextViewDicChangeNotification(sender:AnyObject){
        if let notification = sender as? NSNotification {
            if notification.name == UITextViewTextDidChangeNotification {
                if let textView = self.FHTextInputView {
                    if textView.isEqual(notification.object) {
                        self.sendButton.enabled = textView.text.characters.count > 0
                        if self.sendButton.enabled {
                             sendButton.backgroundColor = UIColor.FHRGBColor(0xff407c,alpha: 1.0)
                        }else {
                             sendButton.backgroundColor = UIColor.grayColor()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: public var
    public weak var FHTextInputView:UITextView? {
        didSet{
            if let textView = FHTextInputView {
                sendButton.enabled             =  (textView.text != "")
                if self.sendButton.enabled {
                    sendButton.backgroundColor = UIColor.FHRGBColor(0xff407c,alpha: 1.0)
                }else {
                    sendButton.backgroundColor = UIColor.grayColor()
                }
            }
        }
    }
    public var block:EmotionKeyboardBlock?
   
    
    //MARK: private var
    private var FHEmotionPackages       = [FHEmotionPackageModel]()
    private let FHEmotionCellIdentifire = "FHEmotionCellID"
    private let FHToolbarButtonTag      = 0x0917
    private var FHSelectedButton:UIButton?
  
    
    private lazy var collectionView:UICollectionView = {
        var fhCollectionView =  UICollectionView(frame: CGRectZero, collectionViewLayout: FHEmoticonLayout())
         fhCollectionView.registerClass(FHEmocitonCell.self, forCellWithReuseIdentifier: self.FHEmotionCellIdentifire)
        fhCollectionView.backgroundColor = UIColor.whiteColor()
       
        fhCollectionView.dataSource = self
        fhCollectionView.delegate   = self
        return fhCollectionView
    }()
    
    
    /// toolBar
    private lazy var toolBar: UIToolbar = {
        var toolBar = UIToolbar()
        toolBar.backgroundColor = UIColor.whiteColor()
        toolBar.tintColor       = UIColor.clearColor()
       
        return toolBar
    }()
    
    private lazy var pageControl:UIPageControl = {
       var pageControl = UIPageControl()
        pageControl.numberOfPages                 = 0
        pageControl.pageIndicatorTintColor        = UIColor.grayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.greenColor()
        pageControl.backgroundColor               = UIColor.clearColor()
        pageControl.userInteractionEnabled        = false
        return pageControl
    }()
    private lazy var deleteButton:UIButton = {
       var deleteButton = UIButton()
        deleteButton.setImage(UIImage(named: "faceBoard_delete"), forState: .Normal)
        deleteButton.contentMode = .ScaleAspectFill
        deleteButton.addTarget(self, action: "FHEmotionDeleteButtonAction:", forControlEvents: .TouchUpInside)
        return deleteButton
    }()
    private lazy var sendButton:UIButton = {
        var sendButton = UIButton()
        sendButton.layer.cornerRadius  = 3
        sendButton.layer.masksToBounds = true
        sendButton.setAttributedTitle(NSAttributedString(string: "发送", attributes: [NSFontAttributeName:UIFont.systemFontOfSize(14),NSForegroundColorAttributeName:UIColor.whiteColor()]), forState: .Normal)       
        sendButton.addTarget(self, action: "FHSendButtonAction:", forControlEvents: .TouchUpInside)
        sendButton.backgroundColor = UIColor.grayColor()
        sendButton.enabled             = false
        
        return sendButton
    }()
    
    private lazy var itemNums:Int = {
       return Int(FHEmotionRows*FHEmotionLines)
    }()
    
    private class FHEmoticonLayout: UICollectionViewFlowLayout{
        override func prepareLayout(){
            let width  = collectionView!.bounds.width / CGFloat(FHEmotionRows)
            let height = collectionView!.bounds.height / CGFloat(FHEmotionLines)
            itemSize                = CGSize(width: width, height: height)
            scrollDirection         = UICollectionViewScrollDirection.Horizontal
            
            minimumInteritemSpacing = 0
            minimumLineSpacing      = 0
           
            collectionView?.showsHorizontalScrollIndicator = false
            collectionView?.pagingEnabled                  = true
        }
    }
    private class FHEmocitonCell: UICollectionViewCell {
        required  init?(coder aDecoder: NSCoder){
            fatalError("init(coder:) has not been implemented")
        }
        
        override init(frame: CGRect){
            super.init(frame: frame)
            prepareUI()
        }
        
        func FHSetImage(image:UIImage?) {
            emoticonButton.setImage(image, forState: .Normal)
        }
        private func prepareUI() {
            contentView.addSubview(emoticonButton)
            emoticonButton.frame                  = CGRect(x: 0, y: 0, width: 30, height: 30)
            emoticonButton.titleLabel?.font       = UIFont.systemFontOfSize(6)
            emoticonButton.userInteractionEnabled = false
            emoticonButton.setTitleColor(UIColor.redColor(), forState: .Normal)
            emoticonButton.backgroundColor        = UIColor.yellowColor()
        }
        private lazy var emoticonButton = UIButton()
    }
}

extension  FHEmotionKeyboardView:UICollectionViewDataSource,UICollectionViewDelegate {
    
    
    //MARK: UICollectionViewDataSource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return FHEmotionPackages.count
    }
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count:Int = FHEmotionPackages[section].emotions.count {
            if (count % itemNums) != 0 {
                return (count/itemNums)*itemNums + itemNums
            }
            return count
        }
        return 0
    }
   
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FHEmotionCellIdentifire, forIndexPath: indexPath) as? FHEmocitonCell{
            if let package:FHEmotionPackageModel = FHEmotionPackages[indexPath.section] {
                if  indexPath.row < package.emotions.count,
                    let emotion:FHEmotionModel = package.emotions[indexPath.row] {
                    cell.FHSetImage(UIImage(contentsOfFile: emotion.emotionPath))
                } else {
                    cell.FHSetImage(nil)
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    // MARK: UICollectionViewDelegate    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        let visibleIndex = collectionView.indexPathsForVisibleItems()
        if let indexPath = visibleIndex.first {
            if let button = toolBar.viewWithTag(indexPath.section + FHToolbarButtonTag)as?UIButton {
                FHSelectToolbarButton(button)
            }
            FHSetCurrentPage(indexPath)
        }
    }
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let package:FHEmotionPackageModel = FHEmotionPackages[indexPath.section] {
            if  indexPath.row < package.emotions.count,
                let emotion:FHEmotionModel = package.emotions[indexPath.row] {
                     if let textView = self.FHTextInputView {
                        textView.FHInsertEmoticon(emotion)
                    }
            }
        }
    }
}

