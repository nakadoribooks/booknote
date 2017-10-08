//
//  ImagePicker.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit

typealias ImagePickerDidSelected = (_ image:UIImage?)->()
typealias ImagePickerDidCancel = ()->()
typealias ImagePickerCallback = (selected:ImagePickerDidSelected, canceled:ImagePickerDidCancel)

class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    static let sharedInstance = ImagePicker()
    private var callback:ImagePickerDidSelected? = nil
    private let imagePicker = UIImagePickerController()
    
    private override init(){
        super.init()
        imagePicker.delegate = self
    }
    
    func show(callback:@escaping ImagePickerDidSelected , sourceType:UIImagePickerControllerSourceType = .camera){
        print("1")
        self.callback = callback
        print("2")
        imagePicker.sourceType = sourceType
        print("3")
        
        if sourceType == .camera{
            print("5")
            imagePicker.cameraOverlayView = createCameraOverlay()
            print("6")
        }
        
        print("7")
        Global.rootViewController().present(imagePicker, animated: true) {
            print("8")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        callback?(nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        callback?(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func createCameraOverlay()->UIView{
        let overlay = UIView()
        overlay.frame = CGRect(x: 0, y: 100, width: AloeDevice.windowWidth(), height: AloeDevice.windowHeight() - 300)
        var line = UIView(frame: CGRect(x: 50, y: 0, width: 3, height: overlay.frame.size.height))
        line.backgroundColor = UIColor.red
        overlay.addSubview(line)
        
        line = UIView(frame: CGRect(x: (overlay.frame.size.width / 2.0) - 2.5, y: 0, width: 3, height: overlay.frame.size.height))
        line.backgroundColor = UIColor.red
        overlay.addSubview(line)
        
        line = UIView(frame: CGRect(x: overlay.frame.size.width - 50 - 5, y: 0, width: 3, height: overlay.frame.size.height))
        line.backgroundColor = UIColor.red
        overlay.addSubview(line)
        
        return overlay
    }
    
}
