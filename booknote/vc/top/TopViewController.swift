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
    private let addButton = UIButton()
        
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
        
        addButton.frame = CGRect(x: 0, y: windowHeight()-54, width: windowWidth(), height: 54)
        addButton.setTitle("追加", for: .normal)
        addButton.setTitleColor(UIColor.white, for: .normal)
        addButton.backgroundColor = UIColor.blue
        addButton.addTarget(self, action: #selector(TopViewController.tapButton), for: .touchUpInside)
        
        view.addSubview(addButton)
    }
    
    @objc private dynamic func tapButton(){
        
        self.addButton.isEnabled = false
        self.addButton.backgroundColor = UIColor.gray
        
        BarcodeReader.sharedInstance.show { (book) in
            self.addButton.isEnabled = true
            self.addButton.backgroundColor = UIColor.blue
            
            guard let book = book else{
                return
            }
            
            print("selected Book")
            print(book.title)
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
