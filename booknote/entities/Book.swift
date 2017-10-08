//
//  Book.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import SWXMLHash

class Book: NSObject {

    private let xml:XMLIndexer
    
    init(xml:XMLIndexer){
        self.xml = xml
        super.init()
    }
    
    var author:String{
        get{
            let author = xml["ItemAttributes"]["Author"]
            if let val = author.element?.text{
                return val
            }
            
            if let val = author[0].element?.text{
                return val
            }
            
            return "author not found"
        }
    }
    
    var title:String{
        get{
            let title = xml["ItemAttributes"]["Title"]
            if let val = title.element?.text{
                return val
            }
            
            return "title not found"
        }
    }
    
    
}
