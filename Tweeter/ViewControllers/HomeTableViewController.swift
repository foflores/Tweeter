//  HomeTableViewController.swift
//  Twitter
//
//  Created by Favian Flores on 2/22/21.
//  Copyright © 2021 Dan. All rights reserved.

import UIKit

class HomeTableViewController: UITableViewController {
	var tweetArray: [NSDictionary] = []
	var numberOfTweets: Int!
	let myRefreshControl = UIRefreshControl()

	override func viewDidLoad() {
		super.viewDidLoad()
		loadTweets()
		myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
		tableView.refreshControl = myRefreshControl
	}

	@objc func loadTweets() {
		numberOfTweets = 20
		let APIURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
		let params = ["count": numberOfTweets!]
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
			}, failure: { error in
				print(error.localizedDescription)
				self.myRefreshControl.endRefreshing()
			}
		)
	}

	func loadMoreTweets() {
		let APIURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
		numberOfTweets += 20
		let params = ["count": numberOfTweets!]
		TwitterAPICaller.client?.getDictionariesRequest(
			url: APIURL,
			parameters: params,
			success: { (tweets: [NSDictionary]) in
				self.tweetArray.removeAll()
				for tweet in tweets {
					self.tweetArray.append(tweet)
				}
				self.tableView.reloadData()
			}, failure: { error in
				print(error.localizedDescription)
			}
		)
	}

	@IBAction func onLogoutButton(_ sender: Any) {
		TwitterAPICaller.client?.logout()
		UserDefaults.standard.setValue(false, forKey: "loggedIn")
		self.dismiss(animated: true, completion: nil)
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

		let imageURL = URL(string: (user["profile_image_url_https"] as? String)!)
		let data = try? Data(contentsOf: imageURL!)
		if let profileImage = data {
			cell.profileImage.image = UIImage(data: profileImage)
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
}
