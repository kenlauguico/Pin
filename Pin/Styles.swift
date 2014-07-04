//
//  Styles.swift
//  Pin
//
//  Created by Ken on 6/21/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


// Cell Styles
var cellColors: UIColor[] = [
    UIColor(red: 25/255, green: 158/255, blue: 199/255, alpha: 1.0),
    UIColor(red: 64/255, green: 188/255, blue: 134/255, alpha: 1.0),
    UIColor(red: 236/255, green: 85/255, blue: 92/255, alpha: 1.0),
    UIColor(red: 252/255, green: 180/255, blue: 16/255, alpha: 1.0)
]

var cellImageSize: CGSize = CGSizeMake(120, 80)
var defaultFont: UIFont = UIFont(name: "HelveticaNeue-UltraLight", size: 28.0)

// Tooltip Styles
struct DefaultTooltipStyle {
  var color: UIColor = UIColor.whiteColor()
  var backgroundColor: UIColor = UIColor.blackColor()
  var font: UIFont = UIFont(name: "HelveticaNeue-Light", size: 14.0)
  
  func stylize(tooltip: CMPopTipView) {
    tooltip.backgroundColor = backgroundColor
    tooltip.textColor = color
    tooltip.textFont = font
    tooltip.borderWidth = 0
    tooltip.has3DStyle = false
    tooltip.hasShadow = false
  }
}

// Footer Styles
class DefaultFooterStyle {
  var backgroundColor: UIColor = UIColor.clearColor()
  
  class tagline {
    var font: UIFont = UIFont(name: "HelveticaNeue-Medium", size: 12)
    var color: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
    var alignment = NSTextAlignment.Center
    
    func stylize(label: UILabel) {
      label.font = font
      label.textColor = color
      label.textAlignment = alignment
    }
  }
  class version {
    var font: UIFont = UIFont(name: "HelveticaNeue-Light", size: 12)
    var color: UIColor = UIColor.whiteColor().colorWithAlphaComponent(0.6)
    var alignment = NSTextAlignment.Center
    
    func stylize(label: UILabel) {
      label.font = font
      label.textColor = color
      label.textAlignment = alignment
    }
  }
}