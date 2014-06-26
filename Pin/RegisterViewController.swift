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
    
    var cellPlaceholders: NSString[] = [
        "Enter you phone number",
        "GO!"
    ]
    
    var userPhone: NSString? = nil
    var userTextBox: UITextField!
    var phoneTextBox: SHSPhoneTextField!
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if appDelegate.sendingFrom {
            performSegueWithIdentifier("toMain", sender: nil)
        }
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func closeKeyboard() {
        phoneTextBox.resignFirstResponder()
    }
    
    
    //#pragma mark - UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField!) {
        if textField == phoneTextBox {
            userPhone = phoneTextBox.phoneNumber()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if textField == userTextBox {
            phoneTextBox.becomeFirstResponder()
        }
        return false
    }
    
    
    //#pragma mark - UITableViewDataSource
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        cell.textColor = UIColor.whiteColor()
        cell.font = defaultFont
        cell.textAlignment = NSTextAlignment.Center
        cell.backgroundColor = cellColors[indexPath.row % cellColors.count]
        cell.textLabel.adjustsFontSizeToFitWidth = true
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width*2)
        
        
        if let currentCell = RegistrationCellTypes.fromRaw(indexPath.row) {
            var textBoxFrame = CGRectMake(0, 0, cell.bounds.size.width, cellImageSize.height)
            
            switch currentCell {
            case .PhoneTextbox:
                phoneTextBox = SHSPhoneTextField(frame: textBoxFrame)
                
                if NSLocale.currentLocale().localeIdentifier == "en_US" {
                    phoneTextBox.formatter.setDefaultOutputPattern("+# (###) ###-####")
                } else {
                    phoneTextBox.formatter.setDefaultOutputPattern("+## (##) ####-####")
                }
                
                phoneTextBox.font = defaultFont
                phoneTextBox.textColor = UIColor.whiteColor()
                phoneTextBox.textAlignment = NSTextAlignment.Center
                phoneTextBox.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
                phoneTextBox.backgroundColor = UIColor.clearColor()
                phoneTextBox.keyboardType = UIKeyboardType.PhonePad
                phoneTextBox.placeholder = cellPlaceholders[indexPath.row].uppercaseString
                phoneTextBox.adjustsFontSizeToFitWidth = true
                phoneTextBox.delegate = self
                
                cell.addSubview(phoneTextBox)

            case .Button:
                cell.text = cellPlaceholders[indexPath.row].uppercaseString
                
            }
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        closeKeyboard()
    
        if indexPath.row == RegistrationCellTypes.Button.toRaw() {
            if !userPhone || userPhone == "" { return }
            var currentCell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
            var loader: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            
            loader.center = CGPointMake(currentCell.frame.width/2, currentCell.frame.height/2)
            loader.startAnimating()
            
            // change cell to a loader
            currentCell.text = ""
            currentCell.addSubview(loader)
            
            appDelegate.sendingFrom = userPhone
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