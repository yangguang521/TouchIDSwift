//
//  Device.swift
//  TouchIDSwift
//
//  Created by PC on 2018/12/7.
//  Copyright © 2018 PC. All rights reserved.
//

import UIKit

class Device: NSObject {
    
}

// MARK: - 系统信息
extension Device {
    /// 系统版本号
    static var systemVersion: String  { return UIDevice.current.systemVersion }
    /// 比较版本号
    class func systemVersion(greater than: String) -> Bool { return systemVersion.compare(than, options: .numeric) != .orderedAscending }
    class func systemVersion(greater min: String, lesser max: String) -> Bool { return systemVersion(greater: min) && !systemVersion(greater: max) }
}
