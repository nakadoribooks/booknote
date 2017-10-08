//
//  TopViewController.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit

class TopViewController: BaseViewController {

    private let label = UILabel()
    private let sv = UIScrollView()
    private let button = UIButton(frame:CGRect(x: 20, y: AloeDevice.windowHeight() - 50 - 20, width: AloeDevice.windowWidth() - 40, height: 50))
        
    deinit {
        print("TopViewController.deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        sv.frame = self.view.frame
        view.addSubview(sv)
        sv.addSubview(label)
        
        label.font = UIFont.systemFont(ofSize: 22.0)
        
        button.setTitle("写す", for: .normal)
        button.setTitle("解析中", for: .disabled)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.blue
        button.addTarget(self, action: #selector(TopViewController.tapButton), for: .touchUpInside)
        
        view.addSubview(button)
    }
    
    @objc private dynamic func tapButton(){
        
        self.button.isEnabled = false
        self.button.backgroundColor = UIColor.gray
        
        BarcodeReader.sharedInstance.show { (ean13String) in
            
            self.button.isEnabled = true
            self.button.backgroundColor = UIColor.blue
            
            guard let ean13String = ean13String else{
                return
            }
            
            let amazon = Amazon.sharedInstance
            amazon.findBook(isbn: ean13String) { (book) in
                print("----------- found book ------------")
                print("author", book.author)
                print("title", book.title)
            }
        }
        
//        ImagePicker.sharedInstance.show(callback: { (image) in
//
//            guard let image = image else {
//                self.button.isEnabled = true
//                self.button.backgroundColor = UIColor.blue
//                print("no image")
//                return ;
//            }
//
//            self.label.text = ""
//            self.sv.contentSize.height = 0
//
//            CloudVision.sharedInstance.getText(image: image) { (string) in
//                print("string", string)
//
//                let text = string.replacingOccurrences(of: "\n", with: "")
//                self.label.frame = CGRect(x: 10, y: 30, width: AloeDevice.windowWidth() - 20, height: 10000)
//                self.label.numberOfLines = 0
//                self.label.attributedText = AloeUI.attributedText(text, lineHeight: 1.1)
//                self.label.sizeToFit()
//                self.sv.contentSize.height = self.label.frame.size.height + self.label.frame.origin.y + 10 + 70
//
//                self.button.isEnabled = true
//                self.button.backgroundColor = UIColor.blue
//            }
//
//        }, sourceType: .photoLibrary)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
