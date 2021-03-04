//
//  ProfileViewController.swift
//  Tweeter
//
//  Created by Favian Flores on 2/28/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var screenNameLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var followersLabel: UILabel!
	@IBOutlet weak var followingLabel: UILabel!
	@IBOutlet weak var tweetsLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!

	var tweetArray: [NSDictionary] = []
	var oldestTweetInTable = -1
	var noMoreTweets = false

	override func viewDidLoad() {
		super.viewDidLoad()
		profileImage.layer.cornerRadius = 40
		loadUserData()
		loadUserTweets()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(loadUserTweets), for: .valueChanged)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweetArray.count
	}

	func tableView(
		_ tableView: UITableView,
		willDisplay cell: UITableViewCell,
		forRowAt indexPath: IndexPath
	) {
		if indexPath.row + 1 == tweetArray.count && !noMoreTweets {
			loadMoreUserTweets()
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "UserTweetCell",
			for: indexPath
		) as! TweetTableViewCell
		let tweet = tweetArray[indexPath.row]
		let user = tweet["user"] as! NSDictionary
		cell.usernameLabel.text = user["name"] as? String
		cell.tweetLabel.text = tweet["text"] as? String
		cell.setFavorite(tweet["favorited"] as! Bool)
		cell.setRetweet(tweet["retweeted"] as! Bool)
		cell.tweetID = tweet["id"] as! Int

		let screennameLabel = "@" + (user["screen_name"] as! String)
		let fullDatePostedLabel = tweet["created_at"] as! String
		let dateArray = fullDatePostedLabel.split(separator: " ")
		let datePostedLabel = " | " + dateArray[1] + " " + dateArray[2]
		cell.infoLabel.text = String(screennameLabel + datePostedLabel)

		let imageURL = URL(string: (user["profile_image_url_https"] as? String)!)
		let data = try? Data(contentsOf: imageURL!)
		if let profileImage = data {
			cell.profileImage.image = UIImage(data: profileImage)
		}

		let entities = tweet["entities"] as! NSDictionary
		if let media = entities["media"] as? [NSDictionary] {
			let mediaURL = URL(string: (media[0]["media_url_https"] as? String)!)
			let mediaData = try? Data(contentsOf: mediaURL!)
			if let mediaImageData = mediaData {
				cell.mediaImage.image = UIImage(data: mediaImageData)
			} else {
				cell.mediaImage.image = nil
			}
		} else {
			cell.mediaImage.image = nil
		}
		return cell
	}

	@IBAction func onLogoutButton(_ sender: UIBarButtonItem) {
		TwitterAPICaller.client?.logout()
		UserDefaults.standard.setValue(false, forKey: "loggedIn")
		self.dismiss(animated: true, completion: nil)
	}

	func loadUserData() {
		TwitterAPICaller.client?.getUserInfo(
			success: { data in
				let imageURL = URL(string: data["profile_image_url_https"] as! String)
				let pic = try? Data(contentsOf: imageURL!)
				if let profilePic = pic {
					self.profileImage.image = UIImage(data: profilePic)
				}

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

	@objc func loadUserTweets() {
		let APIURL = "https://api.twitter.com/1.1/statuses/user_timeline.json"
		let params = ["count": 20, "include_rts": true] as [String: Any]
		TwitterAPICaller.client?.getDictionariesRequest(
			url: APIURL,
			parameters: params,
			success: { (tweets: [NSDictionary]) in
				self.tweetArray.removeAll()
				for tweet in tweets {
					self.tweetArray.append(tweet)
				}
				self.tableView.reloadData()
				self.tableView.refreshControl?.endRefreshing()
				let lastTweet = tweets.last!
				self.oldestTweetInTable = (lastTweet["id"] as! Int)
			}, failure: { error in
				print(error.localizedDescription)
				self.tableView.refreshControl?.endRefreshing()
			}
		)
	}

	func loadMoreUserTweets() {
		let APIURL = "https://api.twitter.com/1.1/statuses/user_timeline.json"
		let params = ["count": 20, "include_rts": true, "max_id": oldestTweetInTable] as [String: Any]
		TwitterAPICaller.client?.getDictionariesRequest(
			url: APIURL,
			parameters: params,
			success: { (tweets: [NSDictionary]) in
				let lastTweet = tweets.last!
				if lastTweet["id"] as! Int == self.oldestTweetInTable {
					self.noMoreTweets = true
					self.tableView.refreshControl?.endRefreshing()
					return
				}
				for tweet in tweets {
					self.tweetArray.append(tweet)
				}
				self.tableView.reloadData()
				self.tableView.refreshControl?.endRefreshing()
				self.oldestTweetInTable = (lastTweet["id"] as! Int)
			}, failure: { error in
				print(error.localizedDescription)
				self.tableView.refreshControl?.endRefreshing()
			}
		)
	}
}
