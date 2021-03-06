LLaunchScreen
==============
[![LLaunchScreen CI](https://github.com/internetWei/LLaunchScreen/workflows/LLaunchScreen%20CI/badge.svg)](https://github.com/internetWei/LLaunchScreen/actions)&nbsp;&nbsp; [![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/internetWei/LLaunchScreen/blob/master/LICENSE)&nbsp;&nbsp; [![CocoaPods](https://img.shields.io/badge/pod-0.1.1-blue)](http://cocoapods.org/pods/LLaunchScreen)&nbsp;&nbsp; [![Platform](https://img.shields.io/badge/platform-ios-lightgrey)](https://www.apple.com/nl/ios)&nbsp;&nbsp; [![Support](https://img.shields.io/badge/support-iOS%209%2B-blue)](https://www.apple.com/nl/ios)

Automatically fix iPhone startup diagram display abnormality, 1 line of code to modify the launch screen

[中文介绍](https://github.com/internetWei/LLaunchScreen/blob/master/README_CN.md)

[Click to visit OC version](https://github.com/internetWei/LLDynamicLaunchScreen)

Features
==============
- Automatically repair the abnormal display of the launch screen map
- 1 line of code to modify the launch screen diagram
- Compatible with systems below iOS13

Demo
==============
| Dynamic modification  | Fix exception |
| :-------------: | :-------------: |
| ![demo.gif](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/Resources/demo.gif)  | ![repair.gif](https://github.com/internetWei/LLDynamicLaunchScreen/blob/master/Resources/Repair.gif)  |

Premiss
==============
Due to the limitations of the Swift language, some initialization operations need to be performed manually:
1. Please execute `LLaunchScreen.finishLaunching()` first, and then return to `application(_ , didFinishLaunchingWithOptions :)`
2. Please call `LLaunchScreen.backupSystemLaunchImage()` before modifying the logic of the startup diagram

Usage
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

Installation
==============
### CocoaPods
1. Add pod 'LLaunchScreen' to your Podfile
2. Run pod install --repo-update
3. import LLaunchScreen

### Manually
1. Download all the files in the LLaunchScreen subdirectory
2. Add (drag and drop) the LLaunchScreen folder to your project

Requirements
==============
The project supports iOS 9.0 and Xcode 10.0 at least. If you want to use it on lower systems, please contact the author.

Note
==============
* The replacement image size is recommended to be consistent with the screen size.
* After updating the APP, the default startup diagram will be displayed when the APP is opened for the first time. This is caused by system limitations and cannot be resolved temporarily.
* You can modify the iPad launch screen diagram, but it is not perfect, and subsequent versions will adapt

Contact
==============
If you have better improvements, please pull reqeust me

If you have any better comments, please create one [Issue](https://github.com/internetWei/LLaunchScreen/issues)

The author can be contacted by this email`internetwei@foxmail.com`

[LLaunchScreen设计思路](https://internetwei.github.io/2021/03/02/LLDynamicLaunchScreen%20%E8%AE%BE%E8%AE%A1%E6%80%9D%E8%B7%AF/)

To Do List
==============
* [ ] Improve iPad launch screen repair and replacement
* [ ] Support Carthage

License
==============
LLaunchScreen is released under the MIT license. See LICENSE file for details.
