//
//  FeaturesUtil.swift
//  TouchIDSwift
//
//  Created by PC on 2018/12/7.
//  Copyright © 2018 PC. All rights reserved.
//

import UIKit
import LocalAuthentication

enum DeviceSupportType {
    //设备什么也不支持
    case none
    //设备支持指纹
    case touchID
    //设备支持面容
    case faceID
}

class FeaturesUtil: NSObject {
    //单例
    static let shared = FeaturesUtil()
    //LAContext
    fileprivate let context = LAContext()
    //当前设备支持的类型(默认都不支持)
    var currentSuportType = DeviceSupportType.none
    
    fileprivate override init() {
        super.init()
        /// 判断当前设备支持的类型
        currentSuportType = judgeDeviceSupportType()
        /// alert右侧按钮，错误一次后出现。如果不要右侧按钮，直接赋值“”
        context.localizedFallbackTitle = "验证密码"
        /// alert左侧按钮
        /// if #available(iOS 10.0, *) {
        ///    context.localizedCancelTitle = "取消"
        /// }
        /// 最大时间
        /// if #available(iOS 9.0, *) {
        ///    context.touchIDAuthenticationAllowableReuseDuration = 1*60
        /// }
    }
    
    //MARK: - 当前系统版本号
    func currentSystemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    //MARK: - 判断app是否开启了指纹
    func isTurnOnTouchID() -> Bool {
        return self.currentSuportType == .touchID && UserDefaults.standard.string(forKey: "TurnOnTouchIDKey") == "TurnOnTouchIDValue"
    }
    
    //MARK: - 判断app是否开启面容
    func isTurnOnFaceID() -> Bool {
        return self.currentSuportType == .faceID && UserDefaults.standard.string(forKey: "TurnOnFaceIDKey") == "TurnOnFaceIDValue"
    }
    
    //MARK: - 判断设备支持的生物识别类型
    fileprivate func judgeDeviceSupportType() -> DeviceSupportType {
        if #available(iOS 8.0, *) {
            /// LAPolicyDeviceOwnerAuthentication是iOS9之后的,没有录入指纹或者面容时,显示手机六位密码界面.是在指纹面容验证失败后(5次)第6次弹出锁屏密码验证，如果验证成功了就可以认定指纹或者面容成功了。
            /// LAPolicyDeviceOwnerAuthenticationWithBiometrics是iOS8之后的,没有l录入指纹或者面容时,报错指纹或者面容NotEnrolled.是失败5次后，第6次指纹或者面容就被锁定了，我们需要在第6次解锁指纹或者面容。
            /// 判断设备支持TouchID还是FaceID
            /// 只有调用了canEvaluatePolicy方法 才可使用biometryType，否则biometryType = LABiometryTypeNone 判断不了设备支持的类型
            var error: NSError?
            context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
            if #available(iOS 11.0, *) {
                /// 因为iPhoneX起始系统版本都已经是iOS11.0，所以iOS11.0系统版本下不需要再去判断是否支持faceID，直接走支持TouchID逻辑即可。
                switch context.biometryType {
                case .none: return .none
                case .touchID: return .touchID
                case .faceID: return .faceID
                default: return .none
                }
            }
            return .touchID
        }
        return .none
    }
    
    //MARK: - 验证并处理指纹/面容,NSFaceIDUsageDescription:使用面容必须加上描述
    func handleFeaturesAuthenticationResult(successBlock: @escaping () -> (), failBlock: @escaping() -> ()) {
        if currentSuportType == .touchID || currentSuportType == .faceID {
            let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
            //            if #available(iOS 9.0, *) {
            //                policy = LAPolicy.deviceOwnerAuthentication
            //            }
            var error: NSError?
            let localizedTitleReason = currentSuportType == .touchID ? "通过Home键验证已有手机指纹" : "通过脸部识别验证已有手机面容"
            if context.canEvaluatePolicy(policy, error: &error) {
                context.evaluatePolicy(policy, localizedReason: localizedTitleReason) { (isSuccess, accessError) in
                    if isSuccess {
                        /// 指纹/面容验证成功
                        successBlock()
                    }else {
                        /// 指纹/面容验证失败
                        if let err = accessError {
                            failBlock()
                            self.showErrorMessage(error: err as NSError)
                        }
                    }
                }
            }else {
                /// 指纹/面容不可用
                failBlock()
                self.showErrorMessage(error: error)
            }
        }else {
            /// 不支持指纹和面容
            self.showAlertController(message: "该设备不支持指纹和面容！")
        }
    }
    
    
    /*
     
     // Error codes
     #define kLAErrorAuthenticationFailed                       -1
     #define kLAErrorUserCancel                                 -2
     #define kLAErrorUserFallback                               -3
     #define kLAErrorSystemCancel                               -4
     #define kLAErrorPasscodeNotSet                             -5
     #define kLAErrorTouchIDNotAvailable                        -6
     #define kLAErrorTouchIDNotEnrolled                         -7
     #define kLAErrorTouchIDLockout                             -8
     #define kLAErrorAppCancel                                  -9
     #define kLAErrorInvalidContext                            -10
     #define kLAErrorNotInteractive                          -1004
     
     #define kLAErrorBiometryNotAvailable                        kLAErrorTouchIDNotAvailable
     #define kLAErrorBiometryNotEnrolled                         kLAErrorTouchIDNotEnrolled
     #define kLAErrorBiometryLockout                             kLAErrorTouchIDLockout
     
     */
    
    //MARK: - 显示错误消息
    fileprivate func showErrorMessage(error: NSError?) {
        guard let err = error else { return }
        //提示的错误消息
        var errorMessage: String = ""
        switch Int32(err.code) {
        case kLAErrorAuthenticationFailed:
            /// -1
            /// Authentication was not successful, because user failed to provide valid credentials.
            /// 指纹或面容不匹配
            print("LAErrorAuthenticationFailed")
            errorMessage = currentSuportType == .faceID ? "面容不匹配!":"指纹不匹配!"
            break
        case kLAErrorUserCancel:
            /// -2
            /// Authentication was canceled by user (e.g. tapped Cancel button).
            /// 用户取消了指纹或面容验证
            print("LAErrorUserCancel")
            errorMessage = currentSuportType == .faceID ? "您取消了面容验证!":"您取消了指纹验证!"
            break
        case kLAErrorUserFallback:
            /// -3
            /// Authentication was canceled, because the user tapped the fallback button (Enter Password).
            /// 用户选择了alert右侧的button验证  LAPolicyDeviceOwnerAuthentication:输入手机六位密码验证,LAPolicyDeviceOwnerAuthenticationWithBiometrics:自定义内容验证
            print("LAErrorUserFallback")
            errorMessage = currentSuportType == .faceID ? "您选择输入密码代替面容验证!":"您选择输入密码代替指纹验证!"
            break
        case kLAErrorSystemCancel:
            /// -4
            /// Authentication was canceled by system (e.g. another application went to foreground).
            /// 系统取消,其他应用进入前台,例如来电话等  系统取消授权，如其他APP切入
            print("LAErrorSystemCancel")
            errorMessage = currentSuportType == .faceID ? "系统取消授权验证!":"系统取消授权验证!"
            break
        case kLAErrorPasscodeNotSet:
            /// -5
            /// Authentication could not start, because passcode is not set on the device.
            /// 手机密码没有设置
            print("LAErrorPasscodeNotSet")
            errorMessage = currentSuportType == .faceID ? "您的手机密码没有设置!":"您的手机密码没有设置!"
            break
        case kLAErrorTouchIDNotAvailable:
            /// -6
            /// Authentication could not start, because Touch ID is not available on the device.
            /// 指纹或者面容不可用
            /// NS_ENUM_DEPRECATED(10_10, 10_13, 8_0, 11_0, "use LAErrorBiometryNotAvailable") = kLAErrorTouchIDNotAvailable,
            print("LAErrorTouchIDNotAvailable")
            errorMessage = currentSuportType == .faceID ? "请前往设置中，允许本APP访问面容!":"指纹不可用!"
            break
        case kLAErrorTouchIDNotEnrolled:
            /// -7
            /// Authentication could not start, because Touch ID has no enrolled fingers.
            /// 指纹或者面容没有录入
            /// NS_ENUM_DEPRECATED(10_10, 10_13, 8_0, 11_0, "use LAErrorBiometryNotEnrolled") = kLAErrorTouchIDNotEnrolled
            print("LAErrorTouchIDNotEnrolled")
            errorMessage = currentSuportType == .faceID ? "面容没有录入,请前往设置中录入面容!":"指纹没有录入,请前往设置中录入指纹!"
            break
        case kLAErrorTouchIDLockout:
            /// -8
            /// Authentication was not successful, because there were too many failed Touch ID attempts and
            /// Touch ID is now locked. Passcode is required to unlock Touch ID, e.g. evaluating
            /// LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite.
            /// 指纹或者面容被锁
            ///LAErrorTouchIDLockout NS_ENUM_DEPRECATED(10_11, 10_13, 9_0, 11_0, "use LAErrorBiometryLockout")
            print("LAErrorTouchIDLockout")
            errorMessage = currentSuportType == .faceID ? "面容被锁!":"指纹被锁!"
            break
        case kLAErrorAppCancel:
            /// -9
            /// Authentication was canceled by application (e.g. invalidate was called while
            /// authentication was in progress).
            /// NS_ENUM_AVAILABLE(10_11, 9_0) = kLAErrorAppCancel,
            print("LAErrorAppCancel")
            errorMessage = currentSuportType == .faceID ? "App取消了验证!":"App取消了验证!"
            break
        case kLAErrorInvalidContext:
            /// -10
            /// LAContext passed to this call has been previously invalidated.
            /// NS_ENUM_AVAILABLE(10_11, 9_0) = kLAErrorInvalidContext,
            print("LAErrorInvalidContext")
            errorMessage = currentSuportType == .faceID ? "LAErrorInvalidContext错误!":"LAErrorInvalidContext错误!"
            break
        case kLAErrorNotInteractive:
            /// -1004
            /// Authentication failed, because it would require showing UI which has been forbidden
            /// by using interactionNotAllowed property.
            print("LAErrorNotInteractive")
            errorMessage = currentSuportType == .faceID ? "LAErrorNotInteractive错误!":"LAErrorNotInteractive错误!"
            break
            
        default:
            print("default,切换主线程处理")
            errorMessage = currentSuportType == .faceID ? "面容验证出现错误!":"指纹验证出现错误!"
            break
            
        }
        //UIAlertController
        self.showAlertController(message: errorMessage)
    }
    
    
    func showAlertController(message: String?) {
        if #available(iOS 8.0, *) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let ensureAction = UIAlertAction(title: "确定", style: .default, handler: nil)
                alert.addAction(ensureAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
