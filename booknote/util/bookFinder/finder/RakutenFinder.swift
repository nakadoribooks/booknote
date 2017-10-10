//
//  RakutenFinder.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/10.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire

enum RakutenFinderError: Error {
    case Network
    case Server(Int)
    case Unknown(String)
}

class RakutenFinder: NSObject, IBookFinder {

    static let sharedInstance = RakutenFinder()
    
    private static let API_ROOT = "https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404"
    
    override private init(){
        super.init()
    }
    
    private func createUrl(isbn:String)->String{
        return "\(RakutenFinder.API_ROOT)?applicationId=\(Config.RAKUTEN_APP_ID)&format=json&formatVersion=2&isbn=\(isbn)"
    }
    
    func findBook(isbn: String) -> Promise<Book> {
        return Promise(resolvers: { (resolve, reject) in
            let url = createUrl(isbn: isbn)
            print("url", url)
            Alamofire.request(url, method: .get).responseJSON { response in
                
                guard let json = response.result.value as? NSDictionary
                    , let items = json.object(forKey: "Items") as? [NSDictionary]
                    , let item = items.first else{
                    reject(RakutenFinderError.Unknown("fail json"))
                    return
                }
                
                let book = Book(rakutenJson: item)
                book.isbn = isbn
                
                resolve(book)
            }
        })
    }
}
