//
//  ViewController.swift
//  Swift-Alamofire
//
//  Created by Alan Yen on 2017/6/2.
//  Copyright © 2017年 Alan-App. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Alamofire"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func basicRequest() {
        
        SVProgressHUD.show()
        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // HTTP URL response
            print(response.data ?? "")     // server data
            print(response.result)         // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
            SVProgressHUD.dismiss()
        }
        
        debugPrint(request)
    }
    
    func basicRequestWithMethod() {
        
        SVProgressHUD.show()
        Alamofire.request("https://httpbin.org/get", method: .get).responseJSON { response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // HTTP URL response
            print(response.data ?? "")     // server data
            print(response.result)         // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
            SVProgressHUD.dismiss()
        }
        
        debugPrint(request)
    }
    
    func basicRequestWithParameters() {
        
        let parameters = ["foo": "bar"]
        
        SVProgressHUD.show()
        Alamofire.request("https://httpbin.org/get", parameters: parameters).responseJSON { response in
            print(response.request ?? "")  // original URL request
            print(response.response ?? "") // HTTP URL response
            print(response.data ?? "")     // server data
            print(response.result)         // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
            SVProgressHUD.dismiss()
        }
        
        debugPrint(request)
    }
    
    func basicRequestWithGlobalResponseQueue() {
        
        // Response Handler Queue
        // Response handlers by default are executed on the main dispatch queue. 
        // However, a custom dispatch queue can be provided instead.
        
        let utilityQueue = DispatchQueue.global(qos: .utility)
        SVProgressHUD.show()
        Alamofire.request("https://httpbin.org/get").responseJSON(queue: utilityQueue) { response in
            print("Executing response handler on utility queue")
            SVProgressHUD.dismiss()
        }
    }
    
    func downloadArrayData() {
        
        let urlString = "https://still-peak-69201.herokuapp.com/todo"
        var nameArray = [String]() // Array Type 1
        var idArray: Array<String> = [] // Array Type 2

        SVProgressHUD.show()
        Alamofire.request(urlString).responseJSON { response in
            print(response.request ?? "")  // 原始的 URL 要求
            print(response.response ?? "") // URL 回應
            print(response.data ?? "")     // 伺服器資料
            print(response.result)         // 回應的序列化結果
            
            if let jsonArray = response.result.value as? Array<[String: Any]> {
                // jsonArray ===> Swift.Array<Swift.Dictionary<Swift.String, Any>>
                for item in jsonArray {
                    // item ===> Swift.Dictionary<Swift.String, Any>
                    if let myName = item["name"] as? String,
                       let myId = item["_id"] as? String {
                        nameArray.append(myName)
                        idArray.append(myId)
                        debugPrint(myName, myId)
                    }
                }
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func responseManualValidation() {
        
        SVProgressHUD.show()
        Alamofire.request("https://httpbin.org/get")
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print(error)
                }
                SVProgressHUD.dismiss()
        }
    }
    
    func responseAutomaticValidation() {
        
        SVProgressHUD.show()
        Alamofire.request("https://httpbin.org/get")
            .validate()
            .responseData { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print(error)
                }
                SVProgressHUD.dismiss()
        }
    }
    
    func basicRequestWithURLEncodedParameters() {
        
        // All three of these calls are equivalent
        let parameters: Parameters = ["foo": "bar", "test": "s p a c e"]
        
        DispatchQueue.main.async() {
            print("encoding defaults to `URLEncoding.default`")
            SVProgressHUD.show()
            Alamofire.request("https://httpbin.org/get", parameters: parameters).responseJSON { response in
                print(response.request ?? "")  // 原始的 URL 要求
                SVProgressHUD.dismiss()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            print("encoding defaults to `URLEncoding.default`")
            SVProgressHUD.show()
            Alamofire.request("https://httpbin.org/get", parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                print(response.request ?? "")  // 原始的 URL 要求
                SVProgressHUD.dismiss()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6.0) {
            print("encoding defaults to `URLEncoding.methodDependent`")
            SVProgressHUD.show()
            Alamofire.request("https://httpbin.org/get", parameters: parameters, encoding: URLEncoding(destination: .methodDependent)).responseJSON { response in
                print(response.request ?? "")  // 原始的 URL 要求
                SVProgressHUD.dismiss()
            }
        }
        
        // https://httpbin.org/get?foo=bar
    }
    
    func basicRequestWithJSONEncodingParameters() {
        
        // Both calls are equivalent
        let parameters: Parameters = [
            "foo": [1,2,3],
            "bar": [
                "baz": "qux"
            ]
        ]
        
        DispatchQueue.main.async() {
            print("encoding defaults to `JSONEncoding.default`")
            SVProgressHUD.show()
            Alamofire.request("https://httpbin.org/post",
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default)
                .responseJSON { response in
                    print(response.request ?? "")  // 原始的 URL 要求
                    print(response.request ?? "")  // 原始的 URL 要求
                    if let body = response.request?.httpBody,
                        let str = String(data: body, encoding: .utf8) {
                        print("request body: \(str)")
                    }
                    SVProgressHUD.dismiss()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
            print("encoding defaults to `JSONEncoding(options: [])`")
            SVProgressHUD.show()
            Alamofire.request("https://httpbin.org/post",
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding(options: []))
                .responseJSON { response in
                    print(response.request ?? "")  // 原始的 URL 要求
                    if let body = response.request?.httpBody,
                        let str = String(data: body, encoding: .utf8) {
                        print("request body: \(str)")
                    }
                    SVProgressHUD.dismiss()
            }
        }
        
        // HTTP body: {"foo": [1, 2, 3], "bar": {"baz": "qux"}}
    }
    
    func basicRequestWithHTTPHeadres() {
    
        let headers: HTTPHeaders = [
            "Authorization": "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
            "Accept": "application/json"
        ]
        
        SVProgressHUD.show()
        Alamofire.request("https://httpbin.org/headers", headers: headers).responseJSON { response in
            debugPrint(response)
            SVProgressHUD.dismiss()
        }
    }
    
    func downloadFile() {
        
        // This will only work on macOS as is. Other platforms don't allow access to the filesystem 
        // outside of your app's sandbox.
        // To download files on other platforms, see the Download File Destination section.
    
        SVProgressHUD.show()
        Alamofire.download("https://httpbin.org/image/png").responseData { response in
            if let data = response.result.value,
                let image = UIImage(data: data) {
                print(image.size)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func downloadFileDestination() {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("pig.png")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        SVProgressHUD.show()
        Alamofire.download("https://httpbin.org/image/png", to: destination).response { response in
            
            if response.error == nil,
                let imagePath = response.destinationURL?.path,
                let image = UIImage(contentsOfFile: imagePath) {
                print(image.size)
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func downloadFileWithProgress() {
        
        SVProgressHUD.show()
        Alamofire.download("https://httpbin.org/image/png")
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData { response in
                if let data = response.result.value,
                    let image = UIImage(data: data) {
                    print(image.size)
                }
                SVProgressHUD.dismiss()
        }
    }

    // Mark: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            basicRequest()
        }
        else if indexPath.row == 1 {
            basicRequestWithMethod()
        }
        else if indexPath.row == 2 {
            basicRequestWithParameters()
        }
        else if indexPath.row == 3 {
            basicRequestWithGlobalResponseQueue()
        }
        else if indexPath.row == 4 {
            downloadArrayData()
        }
        else if indexPath.row == 5 {
            responseManualValidation()
        }
        else if indexPath.row == 6 {
            responseAutomaticValidation()
        }
        else if indexPath.row == 7 {
            basicRequestWithURLEncodedParameters()
        }
        else if indexPath.row == 8 {
            basicRequestWithJSONEncodingParameters()
        }
        else if indexPath.row == 9 {
            basicRequestWithHTTPHeadres()
        }
        else if indexPath.row == 10 {
            downloadFile()
        }
        else if indexPath.row == 11 {
            downloadFileDestination()
        }
        else if indexPath.row == 12 {
            downloadFileWithProgress()
        }
    }
}
