//
//  ViewController.swift
//  TouchIDSwift
//
//  Created by PC on 2017/8/17.
//  Copyright © 2017年 LongPei. All rights reserved.
//

import UIKit
import LocalAuthentication
class ViewController: UIViewController {
    fileprivate let context = LAContext()
    fileprivate var error: Error?
    fileprivate var supportError: NSError?
    //指纹解锁iOS8之后才能用
    fileprivate var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initTouchID()
    }
    
    //是不是iOS8以后的系统
    fileprivate func isSupportTouchID() -> Bool {
        return systemVersion.compare("8.0") == .orderedAscending
    }
    
    //判断是否支持touchID
    fileprivate func initTouchID() {
        if isSupportTouchID() {
            //iOS8及以后的系统
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &supportError) {
                //可以使用指纹
                context.localizedFallbackTitle = ""
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "需要指纹解锁") { (success, error) in
                    if success {
                        print("解锁成功")
                    }else{
                        // 获取错误信息
                        print("解锁失败:" + (error?.localizedDescription)!)
                        let message =  self.errorMessageForLAErrorCode(error: error)
                        print(message)
                    }
                }
            }else {
                //不能使用指纹
                print("\n当前设备不支持TouchID的原因:" + (supportError?.localizedDescription ?? ""))
                print("message=" + errorMessageForLAErrorCode(error: supportError))
            }
        }else {
            //iOS8以前的系统
            print("当前的系统是:" + systemVersion + "\n当前设备不支持TouchID的原因:" + (supportError?.localizedDescription ?? ""))
        }
    }
    
    
    private func errorMessageForLAErrorCode(error: Error?) -> String {
        var message = ""
        if let laError = error as? LAError {
            switch laError.code {
                
                //case LAError.appCancel:
                //message = "Authentication was cancelled by application.授权取消"
                
            case .authenticationFailed:
                message = "The user failed to provide valid credentials.连续三次输入错误，身份验证失败"
                
                //case LAError.invalidContext:
                //   message = "The context is invalid"
                
            case .passcodeNotSet:
                message = "Passcode is not set on the device.用户未设置密码"
                
            case .systemCancel:
                message = "Authentication was cancelled by the system.系统取消授权"
                
                //case LAError.touchIDLockout:
                //   message = "Too many failed attempts.touchID锁定"
                
            case .touchIDNotAvailable:
                message = "TouchID is not available on the device.touchID不可用"
                
            case .userCancel:
                message = "The user did cancel.用户点击取消按钮"
                
            case .userFallback:
                message = "The user chose to use the fallback.用户点击输入密码"
                
            case .touchIDNotEnrolled:
                message = "The user chose to use the fallback.touchID未设置指纹"
                
            // Authentication was not successful, because there were too many failed biometry attempts and
            // biometry is now locked. Passcode is required to unlock biometry, e.g. evaluating
            // LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite.
            //iOS11用户多次尝试解锁皆失败,touchID会被锁,需要在设置中打开touchID,重新输入密码解锁,方可重新使用touchID
            //case LAError.biometryLockout:
            //message = "The user chose to use the fallback.touchID未设置指纹"
            
            default:
                message = "Did not find error code on LAError object"
            }
            
        }else{
            assertionFailure("转化error失败")
            message = "转化error失败"
        }
        
        return message
    }
    
    /*
     switch Int32((supportError?.code ?? 100)) {
     case kLAErrorSystemCancel:
     print("系统取消授权，如其他APP切入")
     case kLAErrorUserCancel:
     print("用户取消验证Touch ID")
     case kLAErrorAuthenticationFailed:
     print("授权失败")
     case kLAErrorPasscodeNotSet:
     print("系统未设置密码")
     case kLAErrorTouchIDNotAvailable:
     print("设备Touch ID不可用，例如未打开");
     case kLAErrorTouchIDNotEnrolled:
     print("设备Touch ID不可用，用户未录入");
     case kLAErrorUserFallback:
     print("用户选择输入密码，切换主线程处理");
     default:
     print("其他情况，切换主线程处理")
     }
     */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
