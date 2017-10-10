//
//  GoogleFinder.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/10.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import PromiseKit

enum GoogleFinderError: Error {
    case Network
    case Server(Int)
    case Unknown(String)
}

class GoogleFinder: NSObject, IBookFinder {

    static let sharedInstance = GoogleFinder()
    
    private static let API_ROOT = "https://www.googleapis.com/books/v1/volumes"
    
    private func createUrl(isbn:String)->String{
        return "\(GoogleFinder.API_ROOT)?q=isbn:\(isbn)"
    }
    
    func findBook(isbn: String) -> Promise<Book> {
        return Promise(resolvers: { (resolve, reject) in
            let url = createUrl(isbn: isbn)
            print("url", url)
            Alamofire.request(url, method: .get).responseJSON { response in
                
                guard let json = response.result.value as? NSDictionary
                    , let items = json.object(forKey: "items") as? [NSDictionary]
                    , let item = items.first else{
                        
                        reject(GoogleFinderError.Unknown("fail json"))
                        print(response.result.value)
                        return
                }
                
                let book = Book(googleJson: item)
                book.isbn = isbn
                
                resolve(book)
            }
        })
    }
    
}
