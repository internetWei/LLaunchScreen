//
//  Tests.swift
//  Tests
//
//  Created by LL on 2021/3/4.
//

import XCTest

class Tests: XCTestCase {
    
    /// 系统启动图路径(System launch image full path)
    func systemLaunchImagePath() -> String? {
        
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
    
    
    func isSnapShotSuffix(imageName: String) -> Bool {
        if imageName.hasSuffix(".ktx") { return true }
        if imageName.hasSuffix(".png") { return true }
        return false
    }
    
    
    func testMainFunction() throws {
        let fileManager = FileManager.default
        let systemDirectory = systemLaunchImagePath()
        guard fileManager.fileExists(atPath: systemDirectory ?? "") else {
            XCTFail("系统启动图文件夹路径不存在")
            return
        }
        
        let rootPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let tmpDirectory = rootPath! + "/LLDynamicLaunchScreen_tmp"
        
        if fileManager.fileExists(atPath: tmpDirectory) {
            try! fileManager.removeItem(atPath: tmpDirectory)
        }
                
        do {
            try fileManager.moveItem(atPath: systemDirectory!, toPath: tmpDirectory)
        } catch {
            XCTFail("启动图文件夹移动失败")
            return
        }
        
        var imageNameCheck = false
        for imageName in try! fileManager.contentsOfDirectory(atPath: tmpDirectory) {
            if isSnapShotSuffix(imageName: imageName) {
                imageNameCheck = true
                break
            }
        }
        
        try! fileManager.moveItem(atPath: tmpDirectory, toPath: systemDirectory!)
        XCTAssertTrue(imageNameCheck, "文件夹内没有合适的启动图")
    }
    
    
    func testInfoDictionary() throws {
        let infoDictionary = Bundle.main.infoDictionary
        let app_version: String = infoDictionary?["CFBundleShortVersionString"] as! String
        if app_version.isEmpty {
            XCTFail("版本号获取失败")
        }
    }

}
