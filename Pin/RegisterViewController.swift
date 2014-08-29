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


// MARK: - UITableViewController Methods -

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

  
// MARK: - UITextFieldDelegate

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


// MARK: - UITableViewDataSource

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
        phoneTextBox.placeholder = cellPlaceholders[indexPath.row].lowercaseString
        createAndAddPhoneTextBox(cell)

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
      if !(isNumberValid(userPhone)) { return }
      var currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
      
      showLoaderInCell(currentCell)
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


// MARK: - Private Methods -

extension RegisterViewController {
  
  private func closeKeyboard() {
    phoneTextBox.resignFirstResponder()
  }
  
  
  private func showTour() {
    var tooltip = CMPopTipView(message: TourGuide.tip.phone)
    DefaultTooltipStyle().stylize(tooltip)

    UIView.animateWithDuration(0, delay: 2, options: nil, animations: {}, completion: { done in
      tooltip.presentPointingAtView(self.phoneTextBox, inView: self.view, animated: true)
      TourGuide().setSeen(TGTip.phone)
    })
  }


  private func isNumberValid(number: NSString!) -> Bool {
    return !(number == nil || number == "")
  }


  private func createAndAddPhoneTextBox(cell: UITableViewCell) {
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
    phoneTextBox.adjustsFontSizeToFitWidth = true
    phoneTextBox.delegate = self

    cell.addSubview(phoneTextBox)
  }


  private func showLoaderInCell(cell: UITableViewCell) {
    var loader: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)

    loader.center = CGPointMake(cell.frame.width/2, cell.frame.height/2)
    loader.startAnimating()

    cell.textLabel.text = ""
    cell.addSubview(loader)
  }

}