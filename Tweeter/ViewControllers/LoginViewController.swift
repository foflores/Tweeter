//
//  LoginViewController.swift
//  Twitter
//
//  Created by Favian Flores on 2/22/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if UserDefaults.standard.bool(forKey: "loggedIn") {
			performSegue(withIdentifier: "loginToHome", sender: self)
		}
	}

	@IBAction func onLoginButton(_ sender: Any) {
		let authURL = "https://api.twitter.com/oauth/request_token"
		TwitterAPICaller.client?.login(
			url: authURL,
			success: {
				self.performSegue(withIdentifier: "loginToHome", sender: self)
				UserDefaults.standard.setValue(true, forKey: "loggedIn")
			},
			failure: { _ in print("Login Unsuccessful") }
		)
	}
}
