//
//  ViewController.swift
//  TouchIDSwift
//
//  Created by PC on 2017/8/17.
//  Copyright © 2017年 PC. All rights reserved.


import UIKit
import LocalAuthentication
class ViewController: UIViewController {
    fileprivate var homeTableView: UITableView!
    fileprivate let touchIDTitleArray = ["开启或关闭指纹","点击验证指纹"]
    fileprivate let faceIDTitleArray = ["开启或关闭面容","点击验证面容"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        creatTableView()
    }
    
    fileprivate func creatTableView() {
        homeTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), style: .grouped)
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        self.view.addSubview(homeTableView)
    }
    
    //Mark: - 处理指纹/面容
    fileprivate func handleFeaturesUtilAuthentication(type: DeviceSupportType, switchIsOn: Bool, fail: @escaping () -> ()) {
        FeaturesUtil.shared.handleFeaturesAuthenticationResult(successBlock: {
            //验证成功
            if switchIsOn {
                //打开指纹/面容
                if type == .touchID {
                    UserDefaults.standard.setValue("TurnOnTouchIDValue", forKey: "TurnOnTouchIDKey")
                    UserDefaults.standard.synchronize()
                }else if type == .faceID {
                    UserDefaults.standard.setValue("TurnOnFaceIDValue", forKey: "TurnOnFaceIDKey")
                    UserDefaults.standard.synchronize()
                }
            }else {
                //关闭指纹/面容
                if type == .touchID {
                    UserDefaults.standard.removeObject(forKey: "TurnOnTouchIDKey")
                }else if type == .faceID {
                    UserDefaults.standard.removeObject(forKey: "TurnOnFaceIDKey")
                }
            }
        }, failBlock: {
            //验证失败
            fail()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "指纹" : "面容"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? touchIDTitleArray.count : faceIDTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //具体视需求改
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as! HomeTableViewCell
        cell.accessoryType = indexPath.row == 0 ? .none : .disclosureIndicator
        cell.textLabel?.text = indexPath.section == 0 ? touchIDTitleArray[indexPath.row] : faceIDTitleArray[indexPath.row]
        cell.rightSwitch.isHidden = !(indexPath.row == 0)
        //是否打开了指纹/面容
        cell.rightSwitch.isOn = indexPath.section == 0 ? FeaturesUtil.shared.isTurnOnTouchID() : FeaturesUtil.shared.isTurnOnFaceID()
        //rightSwitch的变化
        cell.rightSwitchAction = { [weak cell] (isOn) in
            if indexPath.row == 0 {
                //先判断是否支持
                if indexPath.section == 0 {
                    if FeaturesUtil.shared.currentSuportType != .touchID {
                        cell?.rightSwitch.isOn = false
                        FeaturesUtil.shared.showAlertController(message: "该设备不支持指纹！")
                        return
                    }
                }else if indexPath.section == 1 {
                    if FeaturesUtil.shared.currentSuportType != .faceID {
                        cell?.rightSwitch.isOn = false
                        FeaturesUtil.shared.showAlertController(message: "该设备不支持面容！")
                        return
                    }
                }
                //处理指纹和面容
                self.handleFeaturesUtilAuthentication(type: indexPath.section == 0 ? .touchID:.faceID, switchIsOn: isOn, fail: {
                    DispatchQueue.main.async {
                        cell?.rightSwitch.isOn = !isOn
                    }
                })
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            //先判断是否支持
            if indexPath.section == 0 {
                if FeaturesUtil.shared.currentSuportType == .touchID {
                    if !FeaturesUtil.shared.isTurnOnTouchID() {
                        FeaturesUtil.shared.showAlertController(message: "请先打开指纹！")
                        return
                    }
                }else {
                    FeaturesUtil.shared.showAlertController(message: "该设备不支持指纹！")
                    return
                }
            }else if indexPath.section == 1 {
                if FeaturesUtil.shared.currentSuportType == .faceID {
                    if !FeaturesUtil.shared.isTurnOnFaceID() {
                        FeaturesUtil.shared.showAlertController(message: "请先打开面容！")
                        return
                    }
                }else {
                    FeaturesUtil.shared.showAlertController(message: "该设备不支持面容！")
                    return
                }
            }
            //面容
            FeaturesUtil.shared.handleFeaturesAuthenticationResult(successBlock: {
                //验证成功
                FeaturesUtil.shared.showAlertController(message: indexPath.section == 0 ? "指纹验证成功！" : "面容验证成功！")
            }) {
                //验证失败
                FeaturesUtil.shared.showAlertController(message: indexPath.section == 0 ? "指纹验证失败！" : "面容验证失败！")
            }
        }
    }
}


