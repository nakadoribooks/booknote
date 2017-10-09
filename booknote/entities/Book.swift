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
        
        print("--- createBook -----")
        print(xml)
    }
    
    func isValid()->Bool{
        return self.asin != nil
    }
    
    var asin:String?{
        get{
            let asin = xml["ASIN"]
            if let val = asin.element?.text{
                return val
            }
            
            return nil
        }
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
    
    var publisher:String{
        get{
            let publisher = xml["ItemAttributes"]["Publisher"]
            if let val = publisher.element?.text{
                return val
            }
            
            return "中通り出版"
        }
    }
    
    var releaseDate:String{
        get{
            let releaseDate = xml["ItemAttributes"]["PublicationDate"]
            if let val = releaseDate.element?.text{
                return val
            }
            
            return "2017/10/08"
        }
    }
    
    var mediumImageUrl:String?{
        get{
            let title = xml["MediumImage"]["URL"]
            if let val = title.element?.text{
                return val
            }
            
            print("image not found")
            print(xml["MediumImage"])
            
            return nil
        }
    }
    
    
}
