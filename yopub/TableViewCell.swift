//
//  TableViewCell.swift
//  YoPub!
//
//  Created by Justin Platz on 5/20/15.
//  Copyright (c) 2015 ioJP. All rights reserved.
//

import UIKit


class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
