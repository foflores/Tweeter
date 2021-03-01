//
//  TweetViewController.swift
//  Tweeter
//
//  Created by Favian Flores on 2/24/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {
	@IBOutlet weak var tweetTextView: UITextView!
	@IBOutlet weak var characterCountLabel: UILabel!
	@IBOutlet weak var profileImage: UIImageView!

	override func viewDidLoad() {
		super.viewDidLoad()
		tweetTextView.becomeFirstResponder()
		tweetTextView.delegate = self
		profileImage.layer.cornerRadius = 25
		updateProfileImage()
	}

	@IBAction func onCancelButton(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func onTweetButton(_ sender: UIBarButtonItem) {
		if !tweetTextView.text.isEmpty {
			TwitterAPICaller.client?.postTweet(
				tweetString: tweetTextView.text,
				success: { self.dismiss(animated: true, completion: nil) },
				failure: { error in
					print(error.localizedDescription)
					self.dismiss(animated: true, completion: nil)
				}
			)
		} else {
			self.dismiss(animated: true, completion: nil)
		}
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		let characterLimit = 280
		let newText = NSString(string: tweetTextView.text!).replacingCharacters(in: range, with: text)
		characterCountLabel.text = "Characters Remaining: " + String(characterLimit - newText.count)
		return newText.count < characterLimit
	}

	func updateProfileImage() {
		TwitterAPICaller.client?.getUserInfo(
			success: { data in
				let imageURL = URL(string: data["profile_image_url_https"] as! String)
				let data = try? Data(contentsOf: imageURL!)
				if let profilePic = data {
					self.profileImage.image = UIImage(data: profilePic)
				}
			}, failure: { error in
				print(error)
			}
		)
	}
}
