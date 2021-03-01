//
//  TweetTableViewCell.swift
//  Twitter
//
//  Created by Favian Flores on 2/22/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var tweetLabel: UILabel!
	@IBOutlet weak var favoriteButton: UIButton!
	@IBOutlet weak var retweetButton: UIButton!
	@IBOutlet weak var mediaImage: UIImageView!

	var tweetID: Int = -1
	var favorited: Bool = false
	var retweeted: Bool = false

	override func awakeFromNib() {
		super.awakeFromNib()
		profileImage.layer.cornerRadius = 25
	}

	func setFavorite(_ isFavorited: Bool) {
		favorited = isFavorited
		if favorited {
			favoriteButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
		} else {
			favoriteButton.setImage(UIImage(named: "favor-icon"), for: UIControl.State.normal)
		}
	}

	func setRetweet(_ isRetweeted: Bool) {
		retweeted = isRetweeted
		if retweeted {
			retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: UIControl.State.normal)
		} else {
			retweetButton.setImage(UIImage(named: "retweet-icon"), for: UIControl.State.normal)
		}
	}

	@IBAction func onFavoriteButton(_ sender: UIButton) {
		if !favorited {
			TwitterAPICaller.client?.favoriteTweet(
				tweetID: tweetID,
				success: {
					self.setFavorite(true)
				}, failure: { error in
				print(error)
				}
			)
		} else {
			TwitterAPICaller.client?.unfavoriteTweet(
				tweetID: tweetID,
				success: {
					self.setFavorite(false)
				}, failure: { error in
				print(error)
				}
			)
		}
	}

	@IBAction func onRetweetButton(_ sender: UIButton) {
		if !retweeted {
			TwitterAPICaller.client?.retweet(
				tweetID: tweetID,
				success: {
					self.setRetweet(true)
				}, failure: { error in
					print(error)
				}
			)
		} else {
			TwitterAPICaller.client?.unretweet(
				tweetID: tweetID,
				success: {
					self.setRetweet(false)
				}, failure: { error in
					print(error)
				}
			)
		}
	}
}
