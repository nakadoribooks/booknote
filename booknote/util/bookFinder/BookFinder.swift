//
//  BookFinder.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/10.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import PromiseKit

class BookFinder: NSObject {

    static let sharedInstance = BookFinder()
    
    override private init(){
        super.init()
    }
    
    private func finder()->IBookFinder{
//        return AmazonFinder.sharedInstance
//        return RakutenFinder.sharedInstance
        return GoogleFinder.sharedInstance
    }
    
    func findBook(isbn:String)->Promise<Book>{
        
//        return finder().findBook(isbn: isbn)
        
        print("find book ", isbn)
        
        return Promise(resolvers: { (resolve, reject) in
            
            AmazonFinder.sharedInstance.findBook(isbn: isbn).then(execute: { (book) -> Void in
                print("found amazon")
                resolve(book)
            }).catch(execute: { (error) in
                GoogleFinder.sharedInstance.findBook(isbn: isbn).then(execute: { (book) -> Void in
                    print("found Google")
                    resolve(book)
                }).catch(execute: { (error) in
                    RakutenFinder.sharedInstance.findBook(isbn: isbn).then(execute: { (book) -> Void in
                        print("found Rakuten")
                        resolve(book)
                    }).catch(execute: { (error) in
                        print("not found")
                        reject(error)
                    })
                })
            })
        })
    }
}
