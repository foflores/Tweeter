//
//  ProfileViewController.swift
//  Tweeter
//
//  Created by Favian Flores on 2/28/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var bannerImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var screenNameLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var followersLabel: UILabel!
	@IBOutlet weak var followingLabel: UILabel!
	@IBOutlet weak var tweetsLabel: UILabel!


	override func viewDidLoad() {
		super.viewDidLoad()
		profileImage.layer.cornerRadius = 40
		loadData()
	}

	@IBAction func onLogoutButton(_ sender: UIBarButtonItem) {
		TwitterAPICaller.client?.logout()
		UserDefaults.standard.setValue(false, forKey: "loggedIn")
		self.dismiss(animated: true, completion: nil)
	}

	func loadData() {
		TwitterAPICaller.client?.getUserInfo(
			success: { data in
				let imageURL = URL(string: data["profile_image_url_https"] as! String)
				let pic = try? Data(contentsOf: imageURL!)
				if let profilePic = pic {
					self.profileImage.image = UIImage(data: profilePic)
				}

				// imageURL = URL(string: data["profile_background_image_url_https"] as! String)
				// pic = try? Data(contentsOf: imageURL!)
				// if let profilePic = pic {
				//	self.bannerImage.image = UIImage(data: profilePic)
				// }

				self.nameLabel.text = data["name"] as? String
				self.screenNameLabel.text = "@" + (data["screen_name"] as! String)
				self.descriptionLabel.text = data["description"] as? String
				self.followingLabel.text = String(data["friends_count"] as! Int) + " Following"

				let followersCount = data["followers_count"] as! Int
				if followersCount == 1 {
					self.followersLabel.text = "1 Follower"
				} else {
					self.followersLabel.text = String(followersCount) + " Followers"
				}

				let tweetsCount = data["statuses_count"] as! Int
				if tweetsCount == 1 {
					self.tweetsLabel.text = "1 Tweet"
				} else {
					self.tweetsLabel.text = String(tweetsCount) + " Tweets"
				}
			}, failure: { error in
				print(error)
			}
		)
	}
}
