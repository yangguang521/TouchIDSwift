//
//  ShowHUD.swift
//  TouchIDSwift
//
//  Created by PC on 2018/12/14.
//  Copyright © 2018 PC. All rights reserved.
//

import UIKit

class ShowHUD: NSObject {
    //显示提示文字
    static func showText(msg: String?) {
        if let msgInfo = msg, let window = UIApplication.shared.keyWindow {
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            hud.animationType = .fade
            hud.label.text = msgInfo
            hud.label.textAlignment = .center
            hud.label.textColor = UIColor.white
            hud.label.numberOfLines = 0
            hud.contentColor = UIColor.white
            hud.sizeToFit()
            hud.mode = .text
            hud.bezelView.color = UIColor.black
            hud.bezelView.backgroundColor = UIColor.black
            hud.bezelView.style = .solidColor
            hud.mode = .customView
            hud.margin = 10.0
            hud.hide(animated: true, afterDelay: 2)
            hud.removeFromSuperViewOnHide = true
        }
    }
}
