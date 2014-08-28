//
//  RegisterViewController.swift
//  Pin
//
//  Created by Ken on 6/21/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


class RegisterViewController: UITableViewController, UITextFieldDelegate {
  
  enum RegistrationCellTypes: Int {
    case PhoneTextbox = 0
    case Button
  }

  var cellPlaceholders: [NSString] = [
    "Enter your phone number",
    "GO"
  ]

  var userPhone: NSString! = nil
  var userTextBox: UITextField!
  var phoneTextBox: SHSPhoneTextField!
  let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate


  override func viewDidLoad() {
    super.viewDidLoad()

    if (appDelegate.sendingFrom != nil) {
      performSegueWithIdentifier("toMain", sender: nil)
    }

    tableView.backgroundColor = UIColor.clearColor()
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
  }
  
  
  override func viewDidAppear(animated: Bool) {
    if !TourGuide().seenPhoneTip {
      var delayedTip = NSTimer.scheduledTimerWithTimeInterval(TourGuide().tipDelay, target: self, selector: "showTour", userInfo: nil, repeats: false)
      NSRunLoop.currentRunLoop().addTimer(delayedTip, forMode: NSRunLoopCommonModes)
    }
  }

  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }

  
  //#pragma mark - UITextFieldDelegate
  func textFieldDidEndEditing(textField: UITextField!) {
    if textField == phoneTextBox {
      userPhone = phoneTextBox.phoneNumber()
    }
  }

  
  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    if textField == userTextBox {
      phoneTextBox.resignFirstResponder()
    }
    return false
  }


  //#pragma mark - UITableViewDataSource
  override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
    let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")

    DefaultCellStyle().stylize(cell)
    cell.backgroundColor = cellColors[indexPath.row % cellColors.count]

    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width*2)


    if let currentCell = RegistrationCellTypes.fromRaw(indexPath.row) {
      var textBoxFrame = CGRectMake(0, 0, cell.bounds.size.width, cellImageSize.height)

      switch currentCell {
      case .PhoneTextbox:
        phoneTextBox = SHSPhoneTextField(frame: textBoxFrame)

        if NSTimeZone.localTimeZone().name == "America/Sao_Paulo" {
          phoneTextBox.formatter.setDefaultOutputPattern("+## (##) ####-####")
        } else {
          phoneTextBox.formatter.setDefaultOutputPattern("+# (###) ###-####")
        }

        phoneTextBox.font = DefaultCellStyle.title().font
        phoneTextBox.textColor = DefaultCellStyle.title().color
        phoneTextBox.textAlignment = DefaultCellStyle.title().alignment
        phoneTextBox.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        phoneTextBox.backgroundColor = UIColor.clearColor()
        phoneTextBox.keyboardType = UIKeyboardType.PhonePad
        phoneTextBox.placeholder = cellPlaceholders[indexPath.row].lowercaseString
        phoneTextBox.adjustsFontSizeToFitWidth = true
        phoneTextBox.delegate = self

        cell.addSubview(phoneTextBox)

      case .Button:
        cell.textLabel.text = cellPlaceholders[indexPath.row].lowercaseString

      }
    }

    return cell
  }

  
  override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    closeKeyboard()

    if indexPath.row == RegistrationCellTypes.Button.toRaw() {
      if userPhone == nil || userPhone == "" { return }
      var currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
      var loader: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)

      loader.center = CGPointMake(currentCell.frame.width/2, currentCell.frame.height/2)
      loader.startAnimating()

      // change cell to a loader
      currentCell.textLabel.text = ""
      currentCell.addSubview(loader)

      appDelegate.sendingFrom = "+\(userPhone)"
      performSegueWithIdentifier("toMain", sender: nil)

    }
  }

  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  
  override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
    return cellImageSize.height
  }

  
  override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
    return cellPlaceholders.count
  }
}


//#pragma mark - Private Methods -
extension RegisterViewController {
  
  func closeKeyboard() {
    phoneTextBox.resignFirstResponder()
  }
  
  
  func showTour() {
    var tooltip = CMPopTipView(message: TourGuide.tip.phone)
    DefaultTooltipStyle().stylize(tooltip)

    UIView.animateWithDuration(0, delay: 2, options: nil, animations: {}, completion: { done in
      tooltip.presentPointingAtView(self.phoneTextBox, inView: self.view, animated: true)
      TourGuide().setSeen(TGTip.phone)
    })
  }
}