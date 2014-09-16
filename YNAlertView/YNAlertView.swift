//
//  YNAlertView.swift
//  YNAlertView
//
//  Created by Tommy on 14/9/15.
//  Copyright (c) 2014年 xu_yunan@163.com. All rights reserved.
//

import Foundation
import UIKit

enum YNAlertViewStyle : Int {
    case Default
    case PlainTextInput
}

typealias YNAction = ()->Void

class YNAlertView: UIView {
    
    var title: String? {
        set {
            if newValue != nil {
                if titleLabel == nil {
                    titleLabel = self.initialTitleLabel()
                    self.addSubview(titleLabel!)
                }
                
                titleLabel!.text = newValue
                let newSize = sizeWithFont(titleFont, maxWidth:titleLabel!.frame.size.width, text: newValue)
                let titleFrame = titleLabel!.frame
                titleLabel!.frame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y, titleFrame.size.width, newSize.height)
            }
        }
        get {
            return self.title
        }
    }
    
    var message: String? {
        set {
            if newValue != nil {
                if messageLabel == nil {
                    messageLabel = self.initialMessageLabel()
                    self.addSubview(messageLabel!)
                }
                
                messageLabel!.text = newValue
                let newSize = sizeWithFont(messageFont, maxWidth:messageLabel!.frame.size.width, text: newValue)
                let messageFrame = messageLabel!.frame
                messageLabel!.frame = CGRectMake(messageFrame.origin.x, messageFrame.origin.y, messageFrame.size.width, newSize.height)
            }
        }
        get {
            return self.message
        }
    }
    
    let alertWidth: CGFloat = 270.0
    let buttonHeight: CGFloat = 44.0
    let windowFrame = UIScreen.mainScreen().bounds
    let lineColorHex: UInt = 0xCCCCCC
    
    let kPaddingTop: CGFloat = 20.0
    let kPaddingLeft: CGFloat = 20.0
    let kPaddingRight: CGFloat = 20.0
    let kPaddingBottom: CGFloat = 20.0
    
    var titleLabel: UILabel?
    var messageLabel: UILabel?
    let titleFont = UIFont.systemFontOfSize(17)
    let messageFont = UIFont.systemFontOfSize(13)
    
    var buttons = [UIButton]()
    var actions = [YNAction]()
    var alertViewWindow: YNAlertViewWindow!
    var alertViewStyle: YNAlertViewStyle?

    init(title: String?, message: String?) {
        super.init(frame: CGRectZero)
        self.title = title
        self.message = message
        
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialTitleLabel() -> UILabel {
        let maxWidthOfContent = alertWidth - kPaddingLeft - kPaddingRight
        let titleFrame = CGRectMake(kPaddingLeft, kPaddingTop, maxWidthOfContent, 20)
        
        titleLabel = UILabel(frame: titleFrame)
        titleLabel?.textAlignment = NSTextAlignment.Center
        titleLabel?.font = titleFont
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        // titleLabel?.backgroundColor = UIColor.redColor()
        
        return titleLabel!
    }
    
    func initialMessageLabel() -> UILabel {
        var messageLabelY: CGFloat = kPaddingTop
        if let titleLabel = self.titleLabel {
            messageLabelY += titleLabel.frame.size.height
        }
        
        let maxWidthOfContent = alertWidth - kPaddingLeft - kPaddingRight
        let messageFrame = CGRectMake(kPaddingLeft, messageLabelY, maxWidthOfContent, 18)
        
        messageLabel = UILabel(frame: messageFrame)
        messageLabel?.textAlignment = NSTextAlignment.Center
        messageLabel?.font = messageFont
        messageLabel?.numberOfLines = 0
        messageLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        // messageLabel?.backgroundColor = UIColor.greenColor()
        
        return messageLabel!
    }
    
    func setup() {
        self.frame = CGRectMake(0.0, 0.0, alertWidth, 0.0)
        self.center = CGPointMake(windowFrame.size.width/2, windowFrame.size.height/2)
        self.backgroundColor = UIColorFromRGB(0xFFFFFF)
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = true
        
        alertViewStyle = YNAlertViewStyle.Default
    }

    func addButton(title: String?, action:YNAction) {
        let button = UIButton()
        
        button.setTitle(title, forState: UIControlState.Normal)
        button.setTitleColor(UIColorFromRGB(0x1062FF), forState: UIControlState.Normal)
        button.setBackgroundImage(imageWithColor(UIColorFromRGB(0xE6E6E6)), forState: UIControlState.Highlighted)   // 230 230 230
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        button.addTarget(self, action: Selector("buttonClicked:"), forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = buttons.count
        buttons.append(button)
        actions.append(action)
        self.addSubview(button)
        
        refreshButtonFrame()
    }
    
    func buttonClicked(sender: AnyObject) {
        let button = sender as UIButton
        let action = actions[button.tag]
        action()
        dismiss()
    }
    
    func show() {
        if alertViewWindow == nil {
            alertViewWindow = YNAlertViewWindow(frame: windowFrame)
        }
        
        if alertViewWindow.hidden {
            alertViewWindow.hidden = false
        }
        
        alertViewWindow.addSubview(self)
        alertViewWindow.makeKeyAndVisible()

        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
        alertViewWindow.alpha = 0
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            self.alertViewWindow.alpha = 1
        }, completion: nil)
    }
        
    func dismiss() {
        self.removeFromSuperview()
        alertViewWindow.alpha = 1
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.alertViewWindow.alpha = 0
        }) { (completion) -> Void in
            self.alertViewWindow.hidden = true
            self.alertViewWindow.alpha = 1
        }
    }

    func refreshButtonFrame() {
        let count = buttons.count
        let contentHeight = heightOfTopContent()
        resetFrame(count, contentHeight: contentHeight)
        
        if count == 1 {
            let firstButton =  buttons[0] as UIButton
            var buttonFrame = CGRectMake(0.0, contentHeight, self.frame.size.width, buttonHeight)
            firstButton.frame = buttonFrame
        } else if count == 2 {
            let firstButton =  buttons[0] as UIButton
            var buttonFrame = CGRectMake(0.0, contentHeight, self.frame.size.width/2, buttonHeight)
            firstButton.frame = buttonFrame
            
            let secondButton =  buttons[1] as UIButton
            buttonFrame = CGRectMake(self.frame.size.width/2, contentHeight, self.frame.size.width/2, buttonHeight)
            secondButton.frame = buttonFrame
        } else {
            for (index, button) in enumerate(buttons) {
                let frame: CGRect = CGRectMake(
                    0.0,
                    self.frame.size.height - self.buttonHeight * CGFloat(count - index),
                    self.frame.size.width,
                    self.buttonHeight)
                
                button.frame = frame
            }
        }
        
        self.setNeedsDisplay()
    }

    func heightOfTopContent() -> CGFloat {
        let paddingHeight = kPaddingTop + kPaddingBottom
        var contentHeight = paddingHeight
        
        if let titleLabel = self.titleLabel {
            contentHeight += titleLabel.frame.size.height
        }
        
        if let messageLabel = self.messageLabel {
            contentHeight += messageLabel.frame.size.height
        }
        
        switch alertViewStyle! {
        case YNAlertViewStyle.Default:
            return contentHeight
        case YNAlertViewStyle.PlainTextInput:
            return paddingHeight + 0    // UITextFiled height
        default:
            return paddingHeight
        }
    }
    
    func resetFrame(count: Int, contentHeight: CGFloat) {
        if count == 1 || count == 2 {
            self.frame = CGRectMake(0.0, 0.0, self.frame.size.width, contentHeight + buttonHeight)
            self.center = CGPointMake(windowFrame.size.width/2, windowFrame.size.height/2)
        } else {
            self.frame = CGRectMake(0.0, 0.0, self.frame.size.width, contentHeight + CGFloat(count - 1) * buttonHeight)
            self.center = CGPointMake(windowFrame.size.width/2, windowFrame.size.height/2)
        }
    }
   
    override func drawRect(rect: CGRect) {
        let context: CGContextRef = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, 0.5)
        CGContextSetStrokeColorWithColor(context, UIColorFromRGB(lineColorHex).CGColor)
        
        if buttons.count == 2 {
            // Horizontal line
            let horizontalLineY = rect.size.height-buttonHeight
            CGContextMoveToPoint(context, 0.0, horizontalLineY)
            CGContextAddLineToPoint(context, rect.size.width, horizontalLineY)
            // Vertical line
            CGContextMoveToPoint(context, rect.size.width/2, horizontalLineY)
            CGContextAddLineToPoint(context, rect.size.width/2, rect.size.height)
        } else {
            // Horizontal line
            for (var i=0; i<buttons.count; i++) {
                let horizontalLineY = self.frame.size.height - buttonHeight * CGFloat(buttons.count - i)
                CGContextMoveToPoint(context, 0.0, horizontalLineY)
                CGContextAddLineToPoint(context, rect.size.width, horizontalLineY)
            }
        }
        
        CGContextStrokePath(context)
    }
    
    // http://stackoverflow.com/questions/18897896/replacement-for-deprecated-sizewithfont-in-ios-7
    func sizeWithFont(font: UIFont, maxWidth: CGFloat, text: String?) -> CGSize {
        if let text = text {
            let content = text as NSString
            let rect = content.boundingRectWithSize(
                CGSizeMake(maxWidth, CGFloat.max),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: [NSFontAttributeName: font],
                context: nil)
            return rect.size
        }
        return CGSizeZero
    }
    
    // Helper function to convert from RGB to UIColor
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        
        UIGraphicsBeginImageContext(rect.size);
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

// Background window
class YNAlertViewWindow: UIWindow {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


