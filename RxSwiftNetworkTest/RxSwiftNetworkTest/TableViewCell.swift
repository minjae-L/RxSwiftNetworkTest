//
//  TableViewCell.swift
//  RxSwiftNetworkTest
//
//  Created by 이민재 on 7/1/24.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
