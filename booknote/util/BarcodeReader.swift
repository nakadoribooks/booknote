//
//  BarcodeReader.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/08.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SWXMLHash

typealias BarcodeReaderDidSelected = (_ ean13String:String?)->()

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    
    func urlAWSQueryEncoding() -> String {
        var allowedCharacters = CharacterSet.alphanumerics
        allowedCharacters.insert(charactersIn: "-")
        if let ret = self.addingPercentEncoding(withAllowedCharacters: allowedCharacters ) {
            return ret
        }
        return ""
    }
    
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        var result: [CUnsignedChar]
        if let ckey = key.cString(using: String.Encoding.utf8), let cdata = self.cString(using: String.Encoding.utf8) {
            result = Array(repeating: 0, count: Int(algorithm.digestLength))
            CCHmac(algorithm.HMACAlgorithm, ckey, ckey.count-1, cdata, cdata.count-1, &result)
        } else {
            fatalError("Nil returned when processing input strings as UTF8")
        }
        
        return Data(bytes: result, count: result.count).base64EncodedString()
    }
}

class BarcodeReader: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    static let sharedInstance = BarcodeReader()
    private let viewController = UIViewController()
    private var callback:BarcodeReaderDidSelected?
    private let session = AVCaptureSession()
    
    override private init(){
        super.init()
        
        let device = AVCaptureDevice.default(for: .video)
        let input = try? AVCaptureDeviceInput(device: device!)
        session.addInput(input!)
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13,AVMetadataObject.ObjectType.ean8]
    }
    
    private func foundEan13String(ean13String:String){
        callback?(ean13String)
        callback = nil
        session.stopRunning()
        
        viewController.dismiss(animated: true) {
            if let sublayers = self.viewController.view.layer.sublayers{
                for sublayer in sublayers{
                    sublayer.removeFromSuperlayer()
                }
            }
        }
    }
    
    private var timestamp: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }
    
    // MARK public
    
    func show(callback:@escaping BarcodeReaderDidSelected){
        self.callback = callback
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.frame = viewController.view.bounds
        layer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(layer)
        
        session.startRunning()
        
        Global.rootViewController().present(viewController, animated: true) {
            
        }
    }
    
    // MARK AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print(metadataObjects)
        for meta in metadataObjects{
            if meta.type == .ean8{
                
            }else if meta.type == .ean13{
                print("ean13")
                if let readableObject = meta as? AVMetadataMachineReadableCodeObject
                , let ean13String = readableObject.stringValue{
                    if ean13String.hasPrefix("9"){
                        foundEan13String(ean13String: ean13String)
                    }
                }
            }
        }
    }
}
