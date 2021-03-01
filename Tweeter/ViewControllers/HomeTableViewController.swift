//  HomeTableViewController.swift
//  Twitter
//
//  Created by Favian Flores on 2/22/21.
//  Copyright © 2021 Dan. All rights reserved.

import UIKit

class HomeTableViewController: UITableViewController {
	var tweetArray: [NSDictionary] = []
	var numberOfTweets: Int!
	var oldestTweetInTable: Int!
	let myRefreshControl = UIRefreshControl()

	override func viewDidLoad() {
		super.viewDidLoad()
		loadTweets()
		myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
		tableView.refreshControl = myRefreshControl
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		loadTweets()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweetArray.count
	}

	override func tableView(
		_ tableView: UITableView,
		cellForRowAt indexPath: IndexPath
	) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: "TweetCell",
			for: indexPath
		) as! TweetTableViewCell
		let tweet = tweetArray[indexPath.row]
		let user = tweet["user"] as! NSDictionary
		cell.usernameLabel.text = user["screen_name"] as? String
		cell.tweetLabel.text = tweet["text"] as? String
		cell.setFavorite(tweet["favorited"] as! Bool)
		cell.setRetweet(tweet["retweeted"] as! Bool)
		cell.tweetID = tweet["id"] as! Int

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

	override func tableView(
		_ tableView: UITableView,
		willDisplay cell: UITableViewCell,
		forRowAt indexPath: IndexPath
	) {
		if indexPath.row + 1 == tweetArray.count {
			loadMoreTweets()
		}
	}

	@objc func loadTweets() {
		numberOfTweets = 20
		let APIURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
		let params = ["count": numberOfTweets!, "include_entities": true] as [String: Any]
		TwitterAPICaller.client?.getDictionariesRequest(
			url: APIURL,
			parameters: params,
			success: { (tweets: [NSDictionary]) in
				self.tweetArray.removeAll()
				for tweet in tweets {
					self.tweetArray.append(tweet)
				}
				self.tableView.reloadData()
				self.myRefreshControl.endRefreshing()
				let lastTweet = tweets.last!
				self.oldestTweetInTable = (lastTweet["id"] as! Int)
			}, failure: { error in
				print(error.localizedDescription)
				self.myRefreshControl.endRefreshing()
			}
		)
	}

	func loadMoreTweets() {
		let APIURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
		let params = ["count": numberOfTweets!, "max_id": oldestTweetInTable!, "include_entities": true] as [String: Any]
		TwitterAPICaller.client?.getDictionariesRequest(
			url: APIURL,
			parameters: params,
			success: { (tweets: [NSDictionary]) in
				for tweet in tweets {
					self.tweetArray.append(tweet)
				}
				self.tableView.reloadData()
				let lastTweet = tweets.last!
				self.oldestTweetInTable = (lastTweet["id"] as! Int)
			}, failure: { error in
				print(error.localizedDescription)
			}
		)
	}

	@IBAction func onLogoutButton(_ sender: UIBarButtonItem) {
		TwitterAPICaller.client?.logout()
		UserDefaults.standard.setValue(false, forKey: "loggedIn")
		self.dismiss(animated: true, completion: nil)
	}
}
