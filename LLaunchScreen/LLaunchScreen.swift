//
//  LLaunchScreen.swift
//  LLaunchScreen
//
//  Created by LL on 2021/1/31.
//

import UIKit


public enum LLaunchScreenType: String {
    case verticalLight
    case horizontalLight
    
    @available(iOS 13.0, *)
    case verticalDark
    case horizontalDark
}


/// 一个标识符，用于存储/读取启动图的具体名称(An identifier for storing/reading the name of the launch screen diagram)
private let launchImageInfoIdentifer = "launchImageInfoIdentifier"
/// 一个标识符，用于存储/读取启动图的修改记录(An identifier, used to store/read the launch screen diagram modification record)
private let launchImageModifyIdentifer = "launchImageModifyIdentifer"
/// 一个标识符，用于存储/读取新版本记录(An identifier for storing/reading new version records)
private let launchImageVersionIdentifer = "launchImageVersionIdentifer"
/// 一个标识符，true表示将`restoreAsBefore`方法延迟执行(An identifier, true means delaying the execution of the `restoreAsBefore` func)
private var launchImage_restoreAsBefore = false
/// 一个标识符，true表示将`repairException`方法延迟执行(An identifier, true means delaying the execution of the `repairException` func)
private var launchImage_repairException = false


public class LLaunchScreen: NSObject {
    
    
    // MARK: - Public
    
    /**
     自定义暗黑系启动图的校验规则(Customize the verification rules of the dark style launch screen)
     
     默认情况下，`LLaunchScreen`通过获取图片最右上角1×1像素单位的RGB值来判断该图片是不是暗黑系图片；
     如果您需要修改它，请在APP启动时实现它。(default, `LLaunchScreen` judges whether the picture is a dark picture by obtaining the RGB value of the 1×1 pixel unit in the upper right corner of the picture; If you need to modify it, please implement it when the APP starts.)
     */
    public static var hasDarkImageBlock: (_ image: UIImage) -> Bool = { $0.hasDarkImage }
    
    
    /**
     获取指定模式下的本地启动图(Get the local launch screen diagram in the specified mode)
          
     当您的APP不支持深色/横屏时，尝试获取启动图会返回nil。(When your APP does not support dark/horizontal launch screen, try to get the launch image and it will return nil)
     
     - parameter type: 需要获取的启动图类型(The type of launch image that needs to be obtained)
     */
    public class func launchImage(from type: LLaunchScreenType) -> UIImage? {
        
        self.initializeSwift()
        
        var originImage: UIImage?
        
        self.launchImageCustomBlock { (tmpDirectory) in
            let launchImageInfo = launchScreenInfo(forKey: launchImageInfoIdentifer)
            let imageName = launchImageInfo[type.rawValue]
            if imageName == nil { return }
            
            let fullPath = tmpDirectory.appending("/\(imageName!)")
            originImage = UIImage.init(contentsOfFile: fullPath)
        }
        
        return originImage
    }
    

    /// 将所有启动图恢复为默认启动图(Restore all launch screen to the initial state)
    public class func restoreAsBefore() {
        
        if doesExistsOriginLaunchImage {
            self.replaceLaunchImage(replaceImage: nil, type: .verticalLight, quality: 0.8, validation: nil)
            self.replaceLaunchImage(replaceImage: nil, type: .horizontalLight, quality: 0.8, validation: nil)
            if #available(iOS 13.0, *) {
                self.replaceLaunchImage(replaceImage: nil, type: .verticalDark, quality: 0.8, validation: nil)
                self.replaceLaunchImage(replaceImage: nil, type: .horizontalDark, quality: 0.8, validation: nil)
            }
            
            // 删除自定义的启动图(Delete customized launch Image)
            try? FileManager.default.removeItem(atPath: customLaunchImageFullBackupPath)
            
            launchImage_restoreAsBefore = false
        } else {
            launchImage_restoreAsBefore = true
        }
    }
    
    
    /// 替换所有竖屏启动图(Replace all vertical launch Images)
    public class func replaceVerticalLaunchImage(replaceImage: UIImage?) {
        self.replaceLaunchImage(replaceImage: replaceImage, type: .verticalLight, quality: 0.8, validation: nil)
        if #available(iOS 13.0, *) {
            self.replaceLaunchImage(replaceImage: replaceImage, type: .verticalDark, quality: 0.8, validation: nil)
        }
    }
    
    
    /// 替换所有横屏启动图(Replace all horizontal launch Images)
    public class func replaceHorizontalLaunchImage(replaceImage: UIImage?) {
        self.replaceLaunchImage(replaceImage: replaceImage, type: .horizontalLight, quality: 0.8, validation: nil)
        if #available(iOS 13.0, *) {
            self.replaceLaunchImage(replaceImage: replaceImage, type: .horizontalDark, quality: 0.8, validation: nil)
        }
    }
    
    
    /**
     替换指定类型启动图(Replace the specified type of launch Image)
     
     - parameter replaceImage: 需要写入的图片，nil表示恢复为默认启动图(image to be written, nil means to restore to the default launch image)
     - parameter type: _
     - parameter quality: 图片压缩比例，默认为0.8(Image compression ratio, the default is 0.8)
     - parameter validation: 自定义校验回调，返回true表示替换，false表示不替换(Custom callback, return true to replace, false to not replace)
     - Returns: 替换结果(Result)
     */
    @discardableResult
    public class func replaceLaunchImage(replaceImage: UIImage?, type: LLaunchScreenType, quality: CGFloat, validation: ((UIImage, UIImage) -> Bool)?) -> Bool {
        
        self.initializeSwift()
        
        var replaceImage: UIImage! = replaceImage
        let isReplace = (replaceImage != nil)
        
        if replaceImage == nil {
            let fullPath = originLaunchImageFullBackupPath.appending("/\(type.rawValue).png")
            replaceImage = UIImage.init(contentsOfFile: fullPath)
            if replaceImage == nil { return false }
        }
        
        var isVertical = false
        if type == .verticalLight { isVertical = true }
        if #available(iOS 13.0, *) {
            if type == .verticalDark { isVertical = true }
        }
        
        // 调整图片尺寸和启动图一致(Adjust the image size to be the same as the launch image)
        replaceImage = replaceImage.resizeImage(isVertical: isVertical)
        
        let replaceImageData: Data! = replaceImage.jpegData(compressionQuality: quality)
        if replaceImageData == nil { return false }
        
        // 替换启动图(Replace launch image)
        var result = false
        result = self.launchImageCustomBlock { (tmpDirectory) in
            let launchImageInfo = launchScreenInfo(forKey: launchImageInfoIdentifer)
            let imageName: String! = launchImageInfo[type.rawValue]
                        
            if imageName == nil { return }
            
            let fullPath = tmpDirectory + "/" + imageName
            let originImage: UIImage! = UIImage.init(contentsOfFile: fullPath)
            if originImage == nil { return }
            
            let validationResult = validation == nil ? true : validation!(originImage, replaceImage)
            if validationResult == false { return }
            
            do {
                try replaceImageData.write(to: URL.init(fileURLWithPath: fullPath))
                result = true
            } catch {
                assert(false, "replae image write faile")
            }
        }
        if result == false { return false }
        
        // 备份replaceImage(Backup replaceImage)
        let customLaunchImageFullPath = customLaunchImageFullBackupPath + "/" + type.rawValue + ".png"
        if isReplace {
            try? replaceImageData.write(to: URL.init(fileURLWithPath: customLaunchImageFullPath))
        } else {
            try? FileManager.default.removeItem(atPath: customLaunchImageFullPath)
        }
        
        // 记录启动图修改信息(Record the launch image modification information)
        var modifyDictionary = launchScreenInfo(forKey: launchImageModifyIdentifer)
        modifyDictionary[type.rawValue] = isReplace ? "true" : "false"
        UserDefaults.standard.setValue(modifyDictionary, forKey: launchImageModifyIdentifer)
        
        return true
    }
    
        
    @objc public class func finishLaunching() {
        
        self.initializeSwift()
        
        self.launchImageIsNewVersion(identifier: "finishLaunching") {
            let modifyDictionary = launchScreenInfo(forKey: launchImageModifyIdentifer)
            
            // 当更新版本时恢复启动图为上次修改时的状态(When the version is updated, restore the launch image to the state when it was last modified)
            for (imageName, isModify) in modifyDictionary {
                if isModify.elementsEqual("true") {
                    let fullPath = customLaunchImageFullBackupPath + "/" + imageName + ".png"
                    self.replaceLaunchImage(replaceImage: UIImage.init(contentsOfFile: fullPath), type: LLaunchScreenType.init(rawValue: imageName)!, quality: 0.8, validation: nil)
                }
            }
        }
        
        self.repairException()
    }
    
    
    /// 备份启动图(Backup launch image)
    @objc public class func backupSystemLaunchImage() {
        
        self.launchImageIsNewVersion(identifier: NSStringFromSelector(#selector(backupSystemLaunchImage))) {
            
            var supportHorizontalScreen: Bool {
                get {
                    let t_array: Array<String>? = Bundle.main.infoDictionary!["UISupportedInterfaceOrientations"] as? Array<String>
                    
                    assert(t_array != nil, "UISupportedInterfaceOrientations get faild")
                    
                    if t_array!.contains("UIInterfaceOrientationLandscapeLeft") ||
                        t_array!.contains("UIInterfaceOrientationLandscapeRight")  {
                        return true
                    } else {
                        return false
                    }
                }
            }
            
            
            let backupPath = originLaunchImageFullBackupPath
            
            
            // 1.清空备份文件夹(Empty the backup folder)
            let t_array = try? FileManager.default.contentsOfDirectory(atPath: backupPath)
            for name in t_array ?? [] {
                let fullPath = backupPath + "/\(name)"
                try? FileManager.default.removeItem(atPath: fullPath)
            }
            
            
            // 2.生成启动图(create launch image)
            var verticalLightImage: UIImage? = nil
            var verticalDarkImage: UIImage? = nil
            var horizontalLightImage: UIImage? = nil
            var horizontalDarkImage: UIImage? = nil
            verticalLightImage = UIImage.createLaunchimageFromSnapshotStoryboard(isPortrait: true, isDark: false)
            if #available(iOS 13.0, *) {
                verticalDarkImage = UIImage.createLaunchimageFromSnapshotStoryboard(isPortrait: true, isDark: true)
            }
            if supportHorizontalScreen {
                horizontalLightImage = UIImage.createLaunchimageFromSnapshotStoryboard(isPortrait: false, isDark: false)
                if #available(iOS 13.0, *) {
                    horizontalDarkImage = UIImage.createLaunchimageFromSnapshotStoryboard(isPortrait: false, isDark: true)
                }
            }
            
            
            // 3.本地启动图路径(custom launch image full path)
            let verticalLightPath = backupPath.appending("/\(LLaunchScreenType.verticalLight.rawValue).png")
            let horizontalLightPath = backupPath.appending("/\(LLaunchScreenType.horizontalLight.rawValue).png")
            var verticalDarkPath: String? = nil
            var horizontalDarkPath: String? = nil
            if #available(iOS 13.0, *) {
                verticalDarkPath = backupPath.appending("/\(LLaunchScreenType.verticalDark).png")
                horizontalDarkPath = backupPath.appending("/\(LLaunchScreenType.horizontalDark).png")
            }
            
            
            if verticalLightImage != nil {
                try? verticalLightImage?.jpegData(compressionQuality: 0.8)?.write(to: URL.init(fileURLWithPath: verticalLightPath))
            }
            if verticalDarkImage != nil && verticalDarkPath != nil {
                try? verticalDarkImage?.jpegData(compressionQuality: 0.8)?.write(to: URL.init(fileURLWithPath: verticalDarkPath!))
            }
            if horizontalLightImage != nil {
                try? horizontalLightImage?.jpegData(compressionQuality: 0.8)?.write(to: URL.init(fileURLWithPath: horizontalLightPath))
            }
            if horizontalDarkImage != nil && horizontalDarkPath != nil {
                try? horizontalDarkImage?.jpegData(compressionQuality: 0.8)?.write(to: URL.init(fileURLWithPath: horizontalDarkPath!))
            }
            
            
            if launchImage_restoreAsBefore {
                self.repairException()
            }
            if launchImage_restoreAsBefore {
                self.restoreAsBefore()
            }
        }
    }
    
    
    // MARK: - Private
    private class func initializeSwift() {
        
        var modifyDictionary = launchScreenInfo(forKey: launchImageModifyIdentifer)
        // 首次安装APP时将启动图修改信息初始化(Initialize at first installation)
        if modifyDictionary.isEmpty {
            modifyDictionary[LLaunchScreenType.verticalLight.rawValue] = "false"
            modifyDictionary[LLaunchScreenType.horizontalLight.rawValue] = "false"
            if #available(iOS 13.0, *) {
                modifyDictionary[LLaunchScreenType.verticalDark.rawValue] = "false"
                modifyDictionary[LLaunchScreenType.horizontalDark.rawValue] = "false"
            }
        }
        
        let app_version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let old_app_version: String = UserDefaults.standard.object(forKey: "llaunchScreen_app_version_identifier") as? String ?? "default"
        // 判断是否升级版本(Determine whether the version number has been upgraded)
        if app_version.elementsEqual(old_app_version) == false {
            var versionDictionary = launchScreenInfo(forKey: launchImageVersionIdentifer)
            versionDictionary["finishLaunching"] = "true"
            versionDictionary["generateLaunchScreenInfo"] = "true"
            versionDictionary["backupSystemLaunchImage"] = "true"
            versionDictionary["repairException"] = "true"
            
            UserDefaults.standard.setValue(versionDictionary, forKey: launchImageVersionIdentifer)
            UserDefaults.standard.setValue(app_version, forKey: "llaunchScreen_app_version_identifier")
        }
        
        self.generateLaunchScreenInfo()
    }
    
    
    /// 生成启动图名称信息(Generate launch screen name information)
    private class func generateLaunchScreenInfo() {
        self.launchImageIsNewVersion(identifier: "generateLaunchScreenInfo") {
            self.launchImageCustomBlock { (tmpDirectory) in
                var infoDictionary: Dictionary<String, String> = [:]
                let contents = try? FileManager.default.contentsOfDirectory(atPath: tmpDirectory)
                
                for imageName in contents ?? [] {
                    if isSnapShotSuffix(imageName: imageName) == false { continue }
                    
                    let t_image = UIImage.init(contentsOfFile: tmpDirectory + "/" + imageName)
                    if t_image == nil { continue }
                    
                    if #available(iOS 13.0, *) {
                        let hasDarkImage = hasDarkImageBlock(t_image!)
                        
                        if t_image!.size.width < t_image!.size.height {
                            if hasDarkImage {// 竖屏深色启动图(Vertical dark launch image)
                                infoDictionary[LLaunchScreenType.verticalDark.rawValue] = imageName
                            } else {// 竖屏浅色启动图(Vertical light launch image)
                                infoDictionary[LLaunchScreenType.verticalLight.rawValue] = imageName
                            }
                        } else {
                            if hasDarkImage {// 横屏深色启动图(Horizontal dark launch image)
                                infoDictionary[LLaunchScreenType.horizontalDark.rawValue] = imageName
                            } else {// 横屏浅色启动图(Horizontal light launch image)
                                infoDictionary[LLaunchScreenType.horizontalLight.rawValue] = imageName
                            }
                        }
                        
                    } else {
                        if t_image!.size.width < t_image!.size.height {// 竖屏浅色启动图(Vertical light launch image)
                            infoDictionary[LLaunchScreenType.verticalLight.rawValue] = imageName
                        } else {// 横屏浅色启动图(Horizontal light launch image)
                            infoDictionary[LLaunchScreenType.horizontalLight.rawValue] = imageName
                        }
                    }
                }
                
                UserDefaults.standard.setValue(infoDictionary, forKey: launchImageInfoIdentifer)
            }
        }
    }
    
    
    /// 修复启动图显示异常(Fix the abnormal display of the launch screen)
    private class func repairException() {
        
        self.launchImageIsNewVersion(identifier: "repairException") {
            if doesExistsOriginLaunchImage {
                let modifyDictionary = launchScreenInfo(forKey: launchImageModifyIdentifer)
                
                for (imageName, isModify) in modifyDictionary {
                    if isModify.elementsEqual("false") {
                        self.replaceLaunchImage(replaceImage: nil, type: LLaunchScreenType(rawValue: imageName)!, quality: 0.8, validation: nil)
                    }
                }
                
                launchImage_repairException = false
            } else {
                launchImage_repairException = true
            }
        }
    }
    
    
    private class func launchImageIsNewVersion(identifier: String, block: () -> ()) {
        #if DEBUG
        block()
        #else
        var versionDictionary = launchScreenInfo(forKey: launchImageVersionIdentifer)
        
        let isNewVersion = versionDictionary[identifier] ?? ""
        if isNewVersion.elementsEqual("true") {
            block()
            versionDictionary[identifier] = "false"
            UserDefaults.standard.setValue(versionDictionary, forKey: launchImageVersionIdentifer)
        }
        #endif
    }
    
    
    /// 启动图备份路径(Launch image full backup path)
    private static var originLaunchImageFullBackupPath: String {
        return LLaunchScreen.createFolder(folderName: "origin_launchImage_backup_rootpath")
    }
    
    
    /// 用户启动图备份路径(User launch image full backup path)
    private class var customLaunchImageFullBackupPath: String {
        return LLaunchScreen.createFolder(folderName: "custom_launchImage_backup_rootpath")
    }
    
    
    /// 系统启动图路径(System launch image full path)
    private class var systemLaunchImagePath: String? {
        
        let bundleID: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String

        guard bundleID != nil else {
            assert(false, "get CFBundleIdentifier faild")
            return nil
        }
        
        let snapshotsPath: String
        if #available(iOS 13.0, *) {
            let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first ?? ""
            snapshotsPath = "\(libraryDirectory)/SplashBoard/Snapshots/\(bundleID!) - {DEFAULT GROUP}"
        } else {
            let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first ?? ""
            snapshotsPath = cacheDirectory + "/Snapshots/" + bundleID!
        }
        
        if FileManager.default.fileExists(atPath: snapshotsPath) { return snapshotsPath }
        
        return nil
    }
    
    
    private class var doesExistsOriginLaunchImage: Bool {
        
        let subArray = try? FileManager.default.contentsOfDirectory(atPath: originLaunchImageFullBackupPath)
        for obj in subArray ?? [] {
            if isSnapShotSuffix(imageName: obj) { return true }
        }
        
        return false
    }
    
    
    private class func isSnapShotSuffix(imageName: String) -> Bool {
        if imageName.hasSuffix(".ktx") { return true }
        if imageName.hasSuffix(".png") { return true }
        return false
    }
    
    
    private class func createFolder(folderName: String) -> String {
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!.appending("/LLaunchScreen")
        
        let fullPath = rootPath + "/" + folderName
        if FileManager.default.fileExists(atPath: fullPath) == false {
            do {
                try FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                assert(false, error.localizedDescription)
            }
        }
        
        return fullPath
    }
    
    
    @discardableResult
    private class func launchImageCustomBlock(block: (String) -> ()) -> Bool {
        
        // 获取系统启动图路径(get system launch image full path)
        let launchImageFullPath: String! = systemLaunchImagePath
        if launchImageFullPath == nil { return false }
        
        
        // 工作目录(get work directory)
        let tmpDirectory: String = {
            let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
            return rootPath!.appending("/LLaunchScreen_tmp")
        }()
        
        
        // 清理工作目录(clean of folders)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: tmpDirectory) {
            try? fileManager.removeItem(atPath: tmpDirectory)
        }
        
        
        do {
            try fileManager.moveItem(atPath: launchImageFullPath, toPath: tmpDirectory)
        } catch let error {
            assert(false, error.localizedDescription)
            return false
        }
        
        
        block(tmpDirectory)
        
        
        // 还原系统启动图(Restore)
        do {
            try fileManager.moveItem(atPath: tmpDirectory, toPath: launchImageFullPath)
        } catch let error {
            assert(false, error.localizedDescription)
            return false
        }
        
        
        // 删除工作文件夹(delete of folders)
        if fileManager.fileExists(atPath: tmpDirectory) {
            do {
                try fileManager.removeItem(atPath: tmpDirectory)
            } catch let error {
                assert(false, error.localizedDescription)
                return false
            }
        }
        
        return true
    }
    
    
    class func launchScreenInfo(forKey defaultName: String) -> Dictionary<String, String> {
        let userDefaults = UserDefaults.standard.object(forKey: defaultName) as? Dictionary<String, String>
        
        if userDefaults == nil { return [:] }
        
        return userDefaults!
    }
    
}



extension UIImage {
        
    var hasDarkImage: Bool {
        get {
            let RGBArr = self.pixelColor(from: CGPoint(x: self.size.width - 1, y: 1))
            
            guard RGBArr != nil else {
                assert(false, "RGBArr is nil")
                return false
            }
            
            
            var maxRGB: Double! = RGBArr!.first
            // 找到颜色的最大值(Get the maximum color)
            for number in RGBArr! {
                if maxRGB < number {
                    maxRGB = number
                }
            }
            
            
            if maxRGB >= 190 { return false }
            
            
            for number in RGBArr! {
                if number + 10 < maxRGB { return false }
            }
            
            return true
        }
    }
    
    
    func pixelColor(from point: CGPoint) -> Array<Double>? {
        
        guard CGRect(origin: CGPoint(x: 0, y: 0), size: self.size).contains(point) else {
            return nil
        }
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.size.width) * Int(point.y)) + Int(point.x)) * 4
        
        let red = Double(data[pixelInfo])
        let green = Double(data[pixelInfo+1])
        let blue = Double(data[pixelInfo+2])
        
        return [red, green, blue]
    }
    
    
    /// 调整图片尺寸与启动图保持一致(Adjust the image size to be consistent with the launch image)
    func resizeImage(isVertical: Bool) -> UIImage {
        
        let imageSize = CGSize.init(width: self.size.width * self.scale, height: self.size.height * self.scale)
        let contextSize = UIImage.contextSize(isVertical: isVertical)
        
        if imageSize.equalTo(contextSize) == false {
            UIGraphicsBeginImageContext(contextSize)
            let ratio = max((contextSize.width / self.size.width), (contextSize.height / self.size.height))
            let rect = CGRect.init(x: 0, y: 0, width: self.size.width * ratio, height: self.size.height * ratio)
            self.draw(in: rect)
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage!
        }
        
        return self
    }
    
    
    class func contextSize(isVertical: Bool) -> CGSize {
        
        let screenScale = UIScreen.main.scale
        let screenSize = UIScreen.main.bounds.size
        
        var width = min(screenSize.width, screenSize.height)
        var height = max(screenSize.width, screenSize.height)
        
        if isVertical == false {
            width = max(screenSize.width, screenSize.height)
            height = min(screenSize.width, screenSize.height)
        }
        
        return CGSize.init(width: width * screenScale, height: height * screenScale)
    }
    
    
    // 创建启动图(create launch image)
    class func createLaunchimageFromSnapshotStoryboard(isPortrait: Bool, isDark: Bool) -> UIImage? {
        
        var launchScreenName: String {
            get {
                let name = Bundle.main.infoDictionary!["UILaunchStoryboardName"]
                assert(name != nil, "get UILaunchStoryboardName faild")
                return name as! String
            }
        }
        
        
        let currentWindows = UIApplication.shared.windows;
        
        var interfaceStyleArray: Array<Any>! = []
        if #available(iOS 13.0, *) {
            for window in currentWindows {
                interfaceStyleArray.append(window.overrideUserInterfaceStyle)
                if isDark {
                    window.overrideUserInterfaceStyle = .dark
                } else {
                    window.overrideUserInterfaceStyle = .light
                }
            }
        }
        
        
        let storyboard = UIStoryboard.init(name: launchScreenName, bundle: nil)
        let launchImageVC = storyboard.instantiateInitialViewController()
        
        guard launchImageVC != nil else {
            assert(false, "launchImageVC faild")
            return nil
        }
        
        
        launchImageVC!.view.frame = UIScreen.main.bounds
        
        if isPortrait {
            if launchImageVC!.view.frame.size.width > launchImageVC!.view.frame.size.height {
                launchImageVC!.view.frame = CGRect.init(x: 0, y: 0, width: launchImageVC!.view.frame.size.height, height: launchImageVC!.view.frame.size.width)
            }
        } else {
            if launchImageVC!.view.frame.size.width < launchImageVC!.view.frame.size.height {
                launchImageVC?.view.frame = CGRect.init(x: 0, y: 0, width: launchImageVC!.view.frame.size.height, height: launchImageVC!.view.frame.size.width)
            }
        }
        
        launchImageVC!.view.setNeedsLayout()
        launchImageVC!.view.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(launchImageVC!.view.frame.size, false, UIScreen.main.scale)
        launchImageVC!.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let launchImage = UIGraphicsGetImageFromCurrentImageContext()
        if launchImage == nil { return nil }
        UIGraphicsEndImageContext()
        
        if #available(iOS 13.0, *) {
            for (index, interfaceStyle) in interfaceStyleArray.enumerated() {
                let window = currentWindows[index]
                window.overrideUserInterfaceStyle = interfaceStyle as! UIUserInterfaceStyle
            }
        }
        
        return launchImage!
    }
}
