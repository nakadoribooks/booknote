//
//  Amazon.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash
import PromiseKit

class Amazon: NSObject {

    static let sharedInstance = Amazon()
    
    override private init(){
        super.init()
    }
    
    private func amazonUrl(isbn:String)->String{
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        let timestamp = formatter.string(from: Date())
        
        var args:[String] = [
            "AWSAccessKeyId=\(Config.AMAZON_ACCESS_KEY)"
            , "AssociateTag=shimoigi-22"
            , "IdType=ISBN"
            , "ItemId=\(isbn)"
            , "Operation=ItemLookup"
            , String(format: "ResponseGroup=%@", "ItemAttributes,Images,EditorialReview".urlAWSQueryEncoding())
            , "SearchIndex=Books"
            , "Service=AWSECommerceService"
        ]
        args.append(String(format: "Timestamp=%@", timestamp.urlAWSQueryEncoding()))
        var params: String = ""
        for arg in args {
            params += (params.count == 0 ? "": "&") + arg
        }
        let signTarget = String(format: "GET\nwebservices.amazon.co.jp\n/onca/xml\n%@", params)
        let signature = signTarget.hmac(algorithm: .SHA256, key: Config.AMAZON_SECRET_KEY)
        
        let ret = String(format: "?%@&Signature=%@", params, signature.urlAWSQueryEncoding())
        
        let url = "https://webservices.amazon.co.jp/onca/xml\(ret)"
        
        return url
    }
    
    func findBook(isbn:String, callback:@escaping (_ book:Book)->()){
        let url = amazonUrl(isbn: isbn)
        print(isbn)
        print(url)
        
        Alamofire.request(url).response{ response in
            print("loaded amazon")
            let xml = SWXMLHash.parse(response.data!)
            let lookupResponse = xml["ItemLookupResponse"]
            let items = lookupResponse["Items"]
            let item = items["Item"]
            
            print(xml)
            
//            print("---- xml -----")
//            print(xml)
//
//            print("---- ItemLookupResponse -----")
//            print(lookupResponse)
//
//            print("---- Items -----")
//            print(items)
//
//            print("---- item -----")
//            print(item)
            
            let book = Book(xml: item)
            callback(book)
        }
    }
    
}
