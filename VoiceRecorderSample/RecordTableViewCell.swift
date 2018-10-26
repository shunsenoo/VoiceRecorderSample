//
//  RecordTableViewCell.swift
//  VoiceRecorderSample
//
//  Created by 駿妹尾 on H30/10/05.
//  Copyright © 平成30年 porme.inc. All rights reserved.
//

import UIKit


class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet var playButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
