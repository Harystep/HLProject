//
//  BaseTableViewCell.swift
//  ScenicCheck
//
//  Created by XinLiang on 2017/11/6.
//  Copyright © 2017年 xi-anyunjingzhiwei. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
