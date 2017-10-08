//
//  Util.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/07.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    class func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)!
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    class func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }

}
