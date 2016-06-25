//
//  SignUpViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 6/25/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit
import OnePasswordExtension

final class SignUpViewController: SessionsViewController {
	
	// MARK: - Properties
	
	let usernameTextField: UITextField = {
		let textField = TextField()
		textField.keyboardType = .ASCIICapable
		textField.placeholder = "username"
		textField.returnKeyType = .Next
		textField.autocapitalizationType = .None
		textField.autocorrectionType = .No
		return textField
	}()
	
	
	// MARK: - UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Sign up for Canvas"
		submitButton.setTitle("Sign Up", forState: .Normal)
		
		let logInText = self.dynamicType.secondaryButtonText(title: "Already have an account? Log in.", emphasizedRange: NSRange(location: 25, length: 6))
		footerButton.setAttributedTitle(logInText, forState: .Normal)
		footerButton.addTarget(self, action: #selector(logIn), forControlEvents: .TouchUpInside)
	}
	
	
	// MARK: - SessionsViewController
	
	override var textFields: [UITextField] {
		var fields = super.textFields
		fields.insert(usernameTextField, atIndex: 0)
		return fields
	}
		
	
	// MARK: - Actions
	
	override func onePassword(sender: AnyObject?) {
//		OnePasswordExtension.sharedExtension().findLoginForURLString("https://usecanvas.com", forViewController: self, sender: sender) { [weak self] loginDictionary, _ in
//			if let username = loginDictionary?[AppExtensionUsernameKey] as? String {
//				self?.usernameTextField.text = username
//			}
//			
//			if let password = loginDictionary?[AppExtensionPasswordKey] as? String {
//				self?.passwordTextField.text = password
//			}
//			
//			self?.submit()
//		}
	}
	
	override func submit() {
//		guard let username = usernameTextField.text, password = passwordTextField.text
//			where !username.isEmpty && !password.isEmpty
//			else { return }
//		
//		loading = true
//		
//		let client = AuthorizationClient(clientID: config.canvasClientID, clientSecret: config.canvasClientSecret, baseURL: config.environment.baseURL)
//		client.createAccessToken(username: username, password: password) { [weak self] in
//			switch $0 {
//			case .Success(let account):
//				dispatch_async(dispatch_get_main_queue()) {
//					if let this = self where this.webCredential == nil {
//						SharedWebCredentials.add(domain: "usecanvas.com", account: username, password: password)
//					}
//					
//					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//					AccountController.sharedController.currentAccount = account
//					Analytics.track(.LoggedIn)
//				}
//			case .Failure(let errorMessage):
//				dispatch_async(dispatch_get_main_queue()) { [weak self] in
//					self?.loading = false
//					self?.passwordTextField.becomeFirstResponder()
//					
//					let alert = UIAlertController(title: errorMessage, message: nil, preferredStyle: .Alert)
//					alert.addAction(UIAlertAction(title: LocalizedString.Okay.string, style: .Cancel, handler: nil))
//					self?.presentViewController(alert, animated: true, completion: nil)
//				}
//			}
//		}
	}
	
	@objc private func forgotPassword() {
		let URL = NSURL(string: "https://usecanvas.com/password-reset")!
		UIApplication.sharedApplication().openURL(URL)
	}
	
	@objc private func logIn() {
		navigationController?.popViewControllerAnimated(true)
	}
}

