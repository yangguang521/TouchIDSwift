//
//  HomeTableViewCell.swift
//  TouchIDSwift
//
//  Created by PC on 2018/12/12.
//  Copyright © 2018 PC. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    var rightSwitch = UISwitch()
    var isHideRightSwitch: Bool = false {
        didSet {
            
        }
    }
    
    var rightSwitchAction: ((_ isOn: Bool) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        rightSwitch.addTarget(self, action: #selector(switchValueChanged(theSwitch:)), for: UIControl.Event.valueChanged)
        contentView.addSubview(rightSwitch)
        rightSwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: rightSwitch, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: rightSwitch, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -20))
    }

    @objc fileprivate func switchValueChanged(theSwitch: UISwitch) {
        rightSwitchAction?(theSwitch.isOn)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
