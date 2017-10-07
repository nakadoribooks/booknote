//
//  ViewController.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/07.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let imagePicekr = UIImagePickerController()
    private let label = UILabel()
    private let sv = UIScrollView()
    private let button = UIButton(frame:CGRect(x: 20, y: AloeDevice.windowHeight() - 50 - 20, width: AloeDevice.windowWidth() - 40, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sv.frame = self.view.frame
        view.addSubview(sv)
        sv.addSubview(label)
        
        imagePicekr.delegate = self
        imagePicekr.sourceType = .camera
        imagePicekr.cameraOverlayView = createCameraOverlay()
        
        button.setTitle("写す", for: .normal)
        button.setTitle("解析中", for: .disabled)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action: #selector(ViewController.tapButton), for: .touchUpInside)
        
        view.addSubview(button)
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
    
    @objc private dynamic func tapButton(){
        self.present(imagePicekr, animated: true) {
            self.button.isEnabled = false
            self.button.backgroundColor = UIColor.gray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("didFinishPickingMediaWithInfo")
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            button.isEnabled = true
            print("no image")
            return ;
        }
        
        picker.dismiss(animated: true) {
            
        }
        
        self.label.text = ""
        sv.contentSize.height = 0
        
        CloudVision.sharedInstance.getText(image: image) { (string) in
            print("string", string)
            
            let text = string.replacingOccurrences(of: "\n", with: "")
            self.label.frame = CGRect(x: 10, y: 30, width: AloeDevice.windowWidth() - 20, height: 10000)
            self.label.numberOfLines = 0
            self.label.font = UIFont.systemFont(ofSize: 18.0)
            self.label.attributedText = AloeUI.attributedText(text, lineHeight: 1.1)
            self.label.sizeToFit()
            self.sv.contentSize.height = self.label.frame.size.height + self.label.frame.origin.y + 10 + 70
            
            self.button.isEnabled = true
            self.button.backgroundColor = UIColor.blue
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.button.isEnabled = true
        self.button.backgroundColor = UIColor.blue
        
        picker.dismiss(animated: true) {
            
        }
    }
    
}

