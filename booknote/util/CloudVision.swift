//
//  CloudVision.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/07.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import SwiftyJSON
import PromiseKit

class CloudVision: NSObject {

    static let sharedInstance = CloudVision()
    
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(Config.GCP_ID)")!
    }
    
    private override init(){
        
    }
    
    func getText(image:UIImage, callback:@escaping (_ text:String)->()){
        let imageString = Util.base64EncodeImage(image)
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageString
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async {
            
            let session = URLSession.shared
            let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                // Use SwiftyJSON to parse results
                let json = JSON(data: data)
                let errorObj: JSON = json["error"]
                
                // Check for errors
                if (errorObj.dictionaryValue != [:]) {
                    print("Error code \(errorObj["code"]): \(errorObj["message"])")
                } else {
                    // Parse the response
                    let responses: JSON = json["responses"][0]
                    let textAnotations:JSON = responses["textAnnotations"][0]
                    
                    // Update UI on the main thread
                    DispatchQueue.main.async(execute: {
                        callback(textAnotations["description"].stringValue)
                    })
                }
            }
            
            task.resume()
        }
    }
    
    private func analyzeResults(_ dataToParse: Data) {
        
        
        
    }

}
