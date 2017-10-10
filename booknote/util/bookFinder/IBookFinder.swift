//
//  IBookFinder.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/10.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import PromiseKit

protocol IBookFinder {
    func findBook(isbn:String)->Promise<Book>
}
