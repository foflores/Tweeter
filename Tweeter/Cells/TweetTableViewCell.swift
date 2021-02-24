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

	override func awakeFromNib() {
		super.awakeFromNib()
		profileImage.layer.cornerRadius = 25
	}
}
