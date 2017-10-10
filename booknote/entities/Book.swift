//
//  Book.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit

class Book: NSObject {

    private let amazonJson:NSDictionary?
    private let rakutenJson:NSDictionary?
    private let googleJson:NSDictionary?
    
    var isbn:String!
    
    init(amazonJson:NSDictionary){
        self.amazonJson = amazonJson
        self.rakutenJson = nil
        self.googleJson = nil
        
        super.init()
        
        print("--- createBook from amazon -----")
//        print(amazonJson)
    }
    
    init(rakutenJson:NSDictionary){
        self.amazonJson = nil
        self.googleJson = nil
        self.rakutenJson = rakutenJson
        super.init()
        
        print("--- createBook from rakuten -----")
//        print(rakutenJson)
    }
    
    init(googleJson:NSDictionary){
        self.amazonJson = nil
        self.googleJson = googleJson
        self.rakutenJson = nil
        super.init()
        
        print("--- createBook from google -----")
//        print(googleJson)
    }
    
    func isValid()->Bool{
        if let json = amazonJson{
            if json["ASIN"] != nil{
                return true
            }
        }
        
        if let json = rakutenJson{
            if json.object(forKey: "isbn") != nil{
                return true
            }
        }
        
        if let json = googleJson{
            if json.object(forKey: "volumeInfo") != nil{
                return true
            }
        }
        
        return false
        
    }
    
    var author:String{
        get{
            if let json = amazonJson, let attributes = json["ItemAttributes"] as? NSDictionary{
                
                if let ar = attributes["Author"] as? [String], let val = ar.first {
                    return val
                }else if let val = attributes["Author"] as? String{
                    return val
                }
            }
            
            if let json = rakutenJson{
                if let val = json.object(forKey: "author") as? String{
                    return val
                }
            }
            
            if let json = googleJson{
                if let volume = json.object(forKey: "volumeInfo") as? NSDictionary
                    , let val = volume.object(forKey: "authors") as? [String]{
                    return val.joined(separator: "/")
                }
            }
            
            return "author not found"
        }
    }
    
    var title:String{
        get{
            if let json = amazonJson, let attributes = json["ItemAttributes"] as? NSDictionary{
                if let val = attributes["Title"] as? String{
                    return val
                }
            }
            
            if let json = rakutenJson{
                if let val = json.object(forKey: "title") as? String{
                    return val
                }
            }
            
            if let json = googleJson{
                if let volume = json.object(forKey: "volumeInfo") as? NSDictionary
                    , let val = volume.object(forKey: "title") as? String{
                    return val
                }
            }
            
            return "title not found"
        }
    }
    
    var publisher:String{
        get{
            
            if let json = amazonJson, let attributes = json["ItemAttributes"] as? NSDictionary{
                if let val = attributes["Publisher"] as? String{
                    return val
                }
            }
            
            if let json = rakutenJson{
                if let val = json.object(forKey: "publisherName") as? String{
                    return val
                }
            }
            
            if let json = googleJson{
                if let volume = json.object(forKey: "volumeInfo") as? NSDictionary
                    , let val = volume.object(forKey: "publisher") as? String{
                    return val
                }
            }
            
            return ""
        }
    }
    
    var releaseDate:String{
        get{
            
            if let json = amazonJson, let attributes = json["ItemAttributes"] as? NSDictionary{
                if let val = attributes["PublicationDate"] as? String{
                    return val
                }
            }

            
            if let json = rakutenJson{
                if let val = json.object(forKey: "salesDate") as? String{
                    return val
                }
            }
            
            if let json = googleJson{
                if let volume = json.object(forKey: "volumeInfo") as? NSDictionary
                    , let val = volume.object(forKey: "publishedDate") as? String{
                    return val
                }
            }
            
            return "2017/10/08"
        }
    }
    
    var mediumImageUrl:String?{
        get{
            
            if let json = amazonJson, let image = json["MediumImage"] as? NSDictionary{
                if let val = image["URL"] as? String{
                    return val
                }
            }
            
            if let json = rakutenJson{
                if let val = json.object(forKey: "mediumImageUrl") as? String{
                    return val
                }
            }
            
            if let json = googleJson{
                if let volume = json.object(forKey: "volumeInfo") as? NSDictionary
                    , let val = volume.object(forKey: "imageLinks") as? NSDictionary, let url = val.object(forKey:"thumbnail") as? String{
                    return url
                }
            }
            
            return nil
        }
    }
}
