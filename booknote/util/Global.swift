//
//  Global.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit

func windowFrame()->CGRect{
    return AloeDevice.windowFrame()
}

func windowWidth()->CGFloat{
    return AloeDevice.windowWidth()
}

func windowHeight()->CGFloat{
    return AloeDevice.windowHeight()
}

class Global: NSObject {

    private static var _rootViewController:RootViewController!
    private static var _rootNavigationController:UINavigationController!
    
    static func setup(rootViewController:RootViewController, rootNavigationController:UINavigationController){
        _rootViewController = rootViewController
        _rootNavigationController = rootNavigationController
    }
    
    static func rootViewController()->RootViewController{
        return _rootViewController
    }
    
    static func rootNavigationController()->UINavigationController{
        return _rootNavigationController
    }
    
}
