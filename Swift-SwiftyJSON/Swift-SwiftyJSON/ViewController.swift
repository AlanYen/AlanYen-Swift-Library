//
//  ViewController.swift
//  Swift-SwiftyJSON
//
//  Created by Alan Yen on 2017/6/7.
//  Copyright © 2017年 Alan-App. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class ViewController: UITableViewController {
    
    var jsonData: Data? = nil
    var jsonString: String? = nil
    var json: JSON = JSON.null

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let file = Bundle.main.path(forResource: "SwiftyJSONTests", ofType: "json") {
            do {
                self.jsonString = try String(contentsOf: URL(fileURLWithPath: file))
                self.jsonData = try Data(contentsOf: URL(fileURLWithPath: file))
                let json = JSON(data: self.jsonData!)
                self.json = json
            } catch {
                self.json = JSON.null
            }
        } else {
            self.json = JSON.null
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            jSONSerialization()
        }
        else if indexPath.row == 1 {
            jSONInitialization()
        }
        else if indexPath.row == 2 {
            jSONSubscript()
        }
        else if indexPath.row == 3 {
            jSONLoop()
        }
        else if indexPath.row == 4 {
            jSONOptionalGetter()
        }
        else if indexPath.row == 5 {
            jSONNonOptionalGetter()
        }
        else if indexPath.row == 6 {
            jSONSetter()
        }
        else if indexPath.row == 7 {
            jSONRawObjec()
        }
        else if indexPath.row == 8 {
            jSONExistence()
        }
        else if indexPath.row == 9 {
            jSONLiteralConvertibles()
        }
        else if indexPath.row == 10 {
            alamofire()
        }
    }
    
    func jSONSerialization() {
        
        if let statusesArray = try? JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as? [[String: Any]],
            let user = statusesArray?[0]["user"] as? [String: Any],
            let username = user["name"] as? String {
            // Finally we got the username
            print(username)
        }
        
        if let JSONObject = try? JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as? [[String: Any]],
            let username = (JSONObject?[0]["user"] as? [String: Any])?["name"] as? String {
            // There's our username
            print(username)
        }
        
        let json = JSON(data: jsonData!)
        if let username = json[0]["user"]["name"].string {
            // Now you got your value
            print(username)
        }
        
        if let username = json[999999]["wrong_key"]["wrong_name"].string {
            // Calm down, take it easy, the ".string" property still produces the correct 
            // Optional String type with safety
            print(username)
        }
        else {
            // Print the error
            print(json[999999]["wrong_key"]["wrong_name"])
        }
    }
    
    func jSONInitialization() {
        
        // let json = JSON(data: jsonData!)
        let json = JSON(self.jsonString!)
        // let json = JSON(someObject)
        print(json)
        
        if let dataFromString = self.jsonString!.data(using: .utf8, allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            print(json)
        }
    }
    
    func jSONSubscript() {
        
        // Getting a double from a JSON Array
        let doubleName = self.json[0].double
        print(type(of: doubleName))
        
        // Getting an array of string from a JSON Array
        let arrayNames = self.json.arrayValue.map({$0["user"]["name"].stringValue})
        print(type(of: arrayNames))
        print(arrayNames)
        
        // Getting a string from a JSON Dictionary
        let nonOptionalName = self.json[0]["user"]["name"].stringValue
        print(type(of: nonOptionalName))
        
        // Getting a string using a path to the element
        let path: [JSONSubscriptType] = [0,"user","name"]
        var optionalName = self.json[path].string
        print(type(of: optionalName))
        
        // Just the same
        optionalName = self.json[0]["user"]["name"].string
        print(type(of: optionalName))

        // Alternatively
        optionalName = self.json[0,"user","name"].string
        print(type(of: optionalName))
        
        // With a hard way
        optionalName = self.json[].string
        print(type(of: optionalName))
    }
    
    func jSONLoop() {
        
        //If json is .Dictionary
        for (key, _): (String, JSON) in self.json {
            // Do something you want
            print(key)
        }
        
        // The first element is always a String, even if the JSON is an Array
        
        // If json is .Array
        // The `index` is 0..<json.count's string value
        for (index, _): (String, JSON) in self.json {
            // Do something you want
            print(index)
        }
    }
    
    func jSONOptionalGetter() {
        
        // NSNumber
        if let id = self.json[0]["user"]["favourites_count"].number {
            // Do something you want
            print(id)
        } else {
            // Print the error
            print(self.json[0]["user"]["favourites_count"].error ?? "")
        }
        
        // String
        if let id = self.json[0]["user"]["name"].string {
            // Do something you want
            print(id)
        } else {
            // Print the error
            print(self.json["user"]["name"])
        }
        
        // Bool
        if let id = self.json[0]["user"]["is_translator"].bool {
            // Do something you want
            print(id)
        } else {
            // Print the error
            print(self.json["user"]["is_translator"])
        }
        
        //Int
        if let id = self.json[0]["user"]["id"].int {
            // Do something you want
            print(id)
        } else {
            // Print the error
            print(self.json[0]["user"]["id"])
        }
    }
    
    func jSONNonOptionalGetter() {
        
        // Non-optional getter is named xxxValue
        
        // If not a Number or nil, return 0
        let id: Int = self.json["id"].intValue
        print(id)
        
        //If not a String or nil, return ""
        let name: String = self.json["name"].stringValue
        print(name)
        
        //If not an Array or nil, return []
        let list: Array<JSON> = self.json["list"].arrayValue
        print(list)
        
        //If not a Dictionary or nil, return [:]
        let user: Dictionary<String, JSON> = self.json["user"].dictionaryValue
        print(user)
    }
    
    func jSONSetter() {
        
        var json = self.json
        json["testname"] = JSON("new-name")
        json[0] = JSON(1)
        
        json["testid"].int =  1234567890
        json["testcoordinate"].double =  8766.766
        json["testname"].string =  "Jack"
        json.arrayObject = [1,2,3,4]
        json.dictionaryObject = ["name":"Jack", "age":25]
    }
    
    func jSONRawObjec() {
        
        let jsonObject: Any = self.json.object
        print(type(of: jsonObject))
        print(jsonObject)
        
        let jsonRawValue: Any = self.json.rawValue
        print(type(of: jsonRawValue))
        print(jsonRawValue)
        
        // convert the JSON to raw NSData
        if let data = try? self.json.rawData() {
            // Do something you want
            print(type(of: data))
            print(data)
        }
        
        // convert the JSON to a raw String
        if let string = self.json.rawString() {
            // Do something you want
            print(type(of: string))
            print(string)
        }
    }
    
    func jSONExistence() {
        
        // shows you whether value specified in JSON or not
        if self.json["name"].exists() {
           print(self.json["name"].stringValue)
        }
    }
    
    func jSONLiteralConvertibles() {
        
        // StringLiteralConvertible
        let json01: JSON = "I'm a json"
        print(type(of: json01))
        print(json01)
        
        // IntegerLiteralConvertible
        let json02: JSON = 12345
        print(type(of: json02))
        print(json02)
        
        // BooleanLiteralConvertible
        let json03: JSON = true
        print(type(of: json03))
        print(json03)
        
        // FloatLiteralConvertible
        let json04: JSON = 2.8765
        print(type(of: json04))
        print(json04)
        
        // DictionaryLiteralConvertible
        let json05: JSON = ["I":"am", "a":"json"]
        print(type(of: json05))
        print(json05)
        
        // ArrayLiteralConvertible
        let json06: JSON = ["I", "am", "a", "json"]
        print(type(of: json06))
        print(json06)
        
        // NilLiteralConvertible
        let json07: JSON = JSON.null
        print(type(of: json07))
        print(json07)
        
        // With subscript in array
        var json08: JSON = [1,2,3]
        json08[0] = 100
        json08[1] = 200
        json08[2] = 300
        json08[999] = 300 // Don't worry, nothing will happen
        print(type(of: json08))
        print(json08)
        
        // With subscript in dictionary
        var json09: JSON =  ["name": "Jack", "age": 25]
        json09["name"] = "Mike"
        json09["age"] = "25" // It's OK to set String
        json09["address"] = "L.A." // Add the "address": "L.A." in json
        print(type(of: json09))
        print(json09)
        
        // Array & Dictionary
        var json10: JSON =  ["name": "Jack", "age": 25, "list": ["a", "b", "c", ["what": "this"]]]
        json10["list"][3]["what"] = "that"
        json10["list",3,"what"] = "that"
        let path: [JSONSubscriptType] = ["list",3,"what"]
        json10[path] = "that"
        print(type(of: json09))
        print(json09)
        
        // With other JSON objects
        let user: JSON = ["username" : "Steve", "password": "supersecurepassword"]
        let auth01: JSON = [
            "user": user.object, // use user.object instead of just user
            "apikey": "supersecretapitoken"
        ]
        print(type(of: auth01))
        print(auth01)
        
        var testJSON: JSON = ["I":"am", "a":"json"]
        if let _ = try? testJSON.merge(with: user) {
            print(type(of: testJSON))
            print(testJSON)
            if let representation = testJSON.rawString([.castNilToNSNull: true]) {
                print(type(of: representation))
                print(representation)
            }
        }
    }
    
    func alamofire() {
        
        SVProgressHUD.show()
        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                print(json["headers"]["User-Agent"])
            case .failure(let error):
                print(error)
            }
            SVProgressHUD.dismiss()
        }
    }
}
