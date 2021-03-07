LLaunchScreen
==============
[![LLaunchScreen CI](https://github.com/internetWei/LLaunchScreen/workflows/LLaunchScreen%20CI/badge.svg)](https://github.com/internetWei/LLaunchScreen/actions)&nbsp;&nbsp; [![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/LLaunchScreen/blob/master/LICENSE)&nbsp;&nbsp; [![CocoaPods](https://img.shields.io/badge/pod-0.1.1-blue)](http://cocoapods.org/pods/LLaunchScreen)&nbsp;&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![blog](https://img.shields.io/badge/blog-budo-blue)](https://internetwei.github.io/)

自动修复iPhone启动图显示异常，1行代码修改启动图

[OC版本](https://github.com/internetwei/LLDynamicLaunchScreen)

特性
==============
- 自动修复启动图显示异常
- 1行代码修改启动图
- 兼容iOS13以下系统

Demo
==============
| 动态修改启动图  | 修复启动图异常 |
| :-------------: | :-------------: |
| ![demo.gif](https://gitee.com/internetWei/lldynamic-launch-screen/raw/master/Resources/demo.gif)  | ![repair.gif](https://gitee.com/internetWei/lldynamic-launch-screen/raw/master/Resources/Repair.gif)  |

前提
==============
由于Swift语言的限制，有些初始化操作需要您手动执行:
1. 请在`application(_ , didFinishLaunchingWithOptions :)`方法返回前执行`LLaunchScreen.finishLaunching()`
2. 请在修改启动图的逻辑前调用`LLaunchScreen.backupSystemLaunchImage()`

用法
==============
```swift
// 将所有启动图恢复为默认启动图(Restore all launch screen to the initial state)
LLaunchScreen.restoreAsBefore()

// 替换指定类型启动图(Replace the specified type of launch Image)
LLaunchScreen.replaceLaunchImage(replaceImage: replaceImage, type: .verticalLight, quality: 0.8, validation: nil)

// 自定义暗黑系启动图的校验规则，请写在finishLaunching()方法前(Customize the verification rules of the dark style launch screen, Please write before finishLaunching() method)
LLaunchScreen.hasDarkImageBlock = {
    
}

// 获取指定模式下的本地启动图(Get the local launch screen diagram in the specified mode)
LLaunchScreen.launchImage(from: .verticalLight)
```

安装
==============
### CocoaPods
1. 在 Podfile 中添加 pod 'LLaunchScreen'
2. 执行 pod install --repo-update
3. import LLaunchScreen

### 手动安装
1. 下载`LLaunchScreen`文件夹内的所有内容
2. 将`LLaunchScreen`文件夹添加(拖放)到你的工程

系统要求
==============
该项目最低支持iOS9.0和Xcode10.0，如果想在更低系统上使用可以联系作者

注意点
==============
* 替换图片的尺寸建议和屏幕物理分辨率保持一致
* APP更新版本后，第一次打开APP会显示默认启动图，这是系统限制，暂时没办法解决
* 可以修改iPad启动图，但是并不完美，后续版本会适配

联系作者
==============
如果你有更好的改进，please pull reqeust me

如果你有任何更好的意见，请创建一个[Issue](https://gitee.com/internetWei/LLaunchScreen/issues)

可以通过此邮箱联系作者`internetwei@foxmail.com`

[LLaunchScreen设计思路](https://internetwei.github.io/2021/03/02/LLDynamicLaunchScreen%20%E8%AE%BE%E8%AE%A1%E6%80%9D%E8%B7%AF/)


待办事项
==============
* [ ] 完善iPad的启动图修复与替换
* [ ] 支持Carthage

许可证
==============
LLaunchScreen 使用 MIT 许可证，详情见 LICENSE 文件
