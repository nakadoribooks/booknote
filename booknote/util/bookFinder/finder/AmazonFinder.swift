//
//  Amazon.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
import XMLDictionary

enum AmazonFinderError: Error {
    case Network
    case Server(Int)
    case Unknown(String)
}

class AmazonFinder: NSObject, IBookFinder {

    static let sharedInstance = AmazonFinder()
    
    override private init(){
        super.init()
    }
    
    private static let MaxRetryCount:Int = 5
    
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
    
    private func _find(isbn:String, callback:@escaping (_ book:Book?)->(), tryCount:Int=0){
        let url = amazonUrl(isbn: isbn)
        Alamofire.request(url).response(){ response in
            print("loaded amazon try", tryCount)
            
            let parser = XMLDictionaryParser()
            guard let xml = parser.dictionary(with: response.data!) else{
                print("fail xml")
                callback(nil)
                return
            }
            
            guard let items = xml["Items"] as? NSDictionary else{
                print("not found")
                if tryCount == AmazonFinder.MaxRetryCount{
                    callback(nil)
                    return
                }
                
                AloeThread.wait(0.5, proc: {
                    self._find(isbn: isbn, callback: callback, tryCount: tryCount + 1)
                })
                return;
            }
            
            let itemList = items.object(forKey: "Item")
            var item:NSDictionary = [:]
            if let arr = itemList as? [NSDictionary], let  val = arr.first{
                item = val
            }else if let val = itemList as? NSDictionary{
                item = val
            }else{
                print("not found")
                callback(nil)
                return
            }
            
            let book = Book(amazonJson:item)
            book.isbn = isbn
            if book.isValid(){
                callback(book)
                return
            }
            
            if tryCount == AmazonFinder.MaxRetryCount{
                callback(nil)
                return
            }
            
            AloeThread.wait(0.5, proc: {
                self._find(isbn: isbn, callback: callback, tryCount: tryCount + 1)
            })
        }
    }
    
    func findBook(isbn:String)->Promise<Book>{
        
        return Promise(resolvers: { (resolve, reject) in
            _find(isbn: isbn, callback: { (book) in
                guard let book = book else{
                    reject(AmazonFinderError.Network)
                    return
                }
                
                resolve(book)
            })
        })
    }
    
}
