//
//  ViewController.swift
//  LLaunchScreen
//
//  Created by LL on 2021/1/31.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    let alertLabel = UILabel.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "LLaunchScreen"
        self.view.backgroundColor = .white
        
        
        let screenWidth = UIScreen.main.bounds.size.width;
        
        let button = UIButton.init(type: .system)
        button.setTitle("Select photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.init(red: 14.0 / 255.0, green: 144.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        button.frame = CGRect.init(x: (screenWidth - 220) / 2.0, y: 150.0, width: 220.0, height: 80.0)
        button.addTarget(self, action: #selector(buttonEvent), for: .touchUpInside)
        self.view.addSubview(button)
        
        
        let button1 = UIButton.init(type: .system)
        button1.setTitle("Reset All(恢复如初)", for: .normal)
        button1.setTitleColor(.white, for: .normal)
        button1.backgroundColor = UIColor.init(red: 14.0 / 255.0, green: 144.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        button1.frame = CGRect.init(x: (screenWidth - 220) / 2.0, y: button.frame.maxY + 40.0, width: 220.0, height: 80.0)
        button1.addTarget(self, action: #selector(buttonEvent1), for: .touchUpInside)
        self.view.addSubview(button1)
        
        
        let button2 = UIButton.init(type: .system)
        button2.setTitle("Reset specified(恢复指定启动图)", for: .normal)
        button2.setTitleColor(.white, for: .normal)
        button2.titleLabel?.numberOfLines = 0
        button2.backgroundColor = UIColor.init(red: 14.0 / 255.0, green: 144.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        button2.frame = CGRect.init(x: (screenWidth - 220) / 2.0, y: button1.frame.maxY + 40.0, width: 220.0, height: 80.0)
        button2.addTarget(self, action: #selector(buttonEvent2), for: .touchUpInside)
        self.view.addSubview(button2)
        
        
        alertLabel.frame = CGRect.init(x: 0, y: 0, width: 200, height: 50)
        alertLabel.center = self.view.center
        alertLabel.textAlignment = .center
        alertLabel.backgroundColor = .black
        alertLabel.textColor = .white
        alertLabel.layer.cornerRadius = 5.0
        alertLabel.layer.masksToBounds = true
        alertLabel.numberOfLines = 0
        self.view.addSubview(alertLabel)
        alertLabel.isHidden = true
    }
    
    
    @objc func buttonEvent() {
        LLaunchScreen.backupSystemLaunchImage()
        
        let picker = UIImagePickerController.init()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    
    @objc func buttonEvent1() {
        LLaunchScreen.restoreAsBefore()
        self.showAlertView(text: "Success，APP is about to exit")
    }
    
    
    @objc func buttonEvent2() {
        let alert = UIAlertController.init(title: "Select LLaunchScreenType", message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "VerticalLight(竖屏浅色启动图)", style: .default) { (action) in
            let result = LLaunchScreen.replaceLaunchImage(replaceImage: nil, type: .verticalLight, quality: 0.8, validation: nil)
            if result {
                self.showAlertView(text: "Success，APP is about to exit")
            }
        }
        let action2 = UIAlertAction.init(title: "HorizontalLight(横屏浅色启动图)", style: .default) { (action) in
            let result = LLaunchScreen.replaceLaunchImage(replaceImage: nil, type: .horizontalLight, quality: 0.8, validation: nil)
            if result {
                self.showAlertView(text: "Success，APP is about to exit")
            }
        }
        let action3 = UIAlertAction.init(title: "VerticalDark(竖屏深色启动图)", style: .default) { (action) in
            if #available(iOS 13.0, *) {
                let result = LLaunchScreen.replaceLaunchImage(replaceImage: nil, type: .verticalDark, quality: 0.8, validation: nil)
                if result {
                    self.showAlertView(text: "Success，APP is about to exit")
                }
            } else {
                let alert = UIAlertController.init(title: "This feature is not supported in systems below iOS13", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction.init(title: "Sure", style: .cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
        let action4 = UIAlertAction.init(title: "HorizontalDark(横屏深色启动图)", style: .default) { (action) in
            if #available(iOS 13.0, *) {
                let result = LLaunchScreen.replaceLaunchImage(replaceImage: nil, type: .horizontalDark, quality: 0.8, validation: nil)
                if result {
                    self.showAlertView(text: "Success，APP is about to exit")
                }
            } else {
                let alert = UIAlertController.init(title: "This feature is not supported in systems below iOS13", message: nil, preferredStyle: .alert)
                let cancel = UIAlertAction.init(title: "Sure", style: .cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(action4)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showAlertView(text: String) {
        self.alertLabel.text = text
        self.alertLabel.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            exit(0)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let originImage: UIImage! = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        guard originImage != nil else {
            assert(false, "originImage is nil")
        }
        
        dismiss(animated: true) {
            let alert = UIAlertController.init(title: "Select LLaunchScreenType", message: nil, preferredStyle: .actionSheet)
            let action1 = UIAlertAction.init(title: "VerticalLight(竖屏浅色启动图)", style: .default) { (action) in
                let result = LLaunchScreen.replaceLaunchImage(replaceImage: originImage, type: .verticalLight, quality: 0.8, validation: nil)
                if result {
                    self.showAlertView(text: "Success，APP is about to exit")
                }
            }
            let action2 = UIAlertAction.init(title: "HorizontalLight(横屏浅色启动图)", style: .default) { (action) in
                let result = LLaunchScreen.replaceLaunchImage(replaceImage: originImage, type: .horizontalLight, quality: 0.8, validation: nil)
                if result {
                    self.showAlertView(text: "Success，APP is about to exit")
                }
            }
            let action3 = UIAlertAction.init(title: "VerticalDark(竖屏深色启动图)", style: .default) { (action) in
                if #available(iOS 13.0, *) {
                    let result = LLaunchScreen.replaceLaunchImage(replaceImage: originImage, type: .verticalDark, quality: 0.8, validation: nil)
                    if result {
                        self.showAlertView(text: "Success，APP is about to exit")
                    }
                } else {
                    let alert = UIAlertController.init(title: "This feature is not supported in systems below iOS13", message: nil, preferredStyle: .alert)
                    let cancel = UIAlertAction.init(title: "Sure", style: .cancel, handler: nil)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            let action4 = UIAlertAction.init(title: "HorizontalDark(横屏深色启动图)", style: .default) { (action) in
                if #available(iOS 13.0, *) {
                    let result = LLaunchScreen.replaceLaunchImage(replaceImage: originImage, type: .horizontalDark, quality: 0.8, validation: nil)
                    if result {
                        self.showAlertView(text: "Success，APP is about to exit")
                    }
                } else {
                    let alert = UIAlertController.init(title: "This feature is not supported in systems below iOS13", message: nil, preferredStyle: .alert)
                    let cancel = UIAlertAction.init(title: "Sure", style: .cancel, handler: nil)
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(action1)
            alert.addAction(action2)
            alert.addAction(action3)
            alert.addAction(action4)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

