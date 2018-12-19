# TouchIDSwift
主要就是系统的二个方法

1.判断是否支持touchID 

context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &supportError) {} 

2.判断是否解锁成功

context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "需要指纹识别/面容识别") { (success, error) in } 

![image](https://github.com/yangguang521/TouchIDSwift/blob/master/touchId.png)
