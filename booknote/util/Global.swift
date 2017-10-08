//
//  Global.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit

class Global: NSObject {

    private static var _rootViewController:RootViewController!
    
    static func setup(rootViewController:RootViewController){
        _rootViewController = rootViewController
    }
    
    static func rootViewController()->RootViewController{
        return _rootViewController
    }
    
}
