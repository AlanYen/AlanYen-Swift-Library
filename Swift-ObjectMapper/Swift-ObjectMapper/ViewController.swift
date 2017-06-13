//
//  ViewController.swift
//  Swift-ObjectMapper
//
//  Created by Alan Yen on 2017/6/12.
//  Copyright © 2017年 Alan-App. All rights reserved.
//

import UIKit
import ObjectMapper

struct Context: MapContext {
    var importantMappingInfo = "Info that I need during mapping"
}

class User: Mappable {

    var username: String?
    var age: Int?
    var weight: Double!
    var bestFriend: User?        // User对象
    var friends: [User]?         // Users数组
    var birthday: Date?
    var array: [AnyObject]?
    var dictionary: [String : AnyObject] = [:]
    var id: Int?
    
    init() {
    }
    
    required init?(map: Map) {
        
        // ObjectMapper 通過 Mappable 協議中的 init?(map: Map) 方法來初始化創建對象。
        // 我們可以利用這個方法，在對象序列化之前驗證 JSON 合法性。
        // 在不符合的條件時，返回 nil 阻止映射發生。
        // 檢查JSON中是否有"username"屬性
        if map.JSON["username"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        username    <- map["username"]
        age         <- map["age"]
        weight      <- map["weight"]
        bestFriend  <- map["best_friend"]
        friends     <- map["friends"]
        birthday    <- (map["birthday"], DateTransform())
        array       <- map["arr"]
        dictionary  <- map["dict"]
        
        if let context = map.context as? Context {
            // 使用上下文來做相關的映射決策
            print(context.importantMappingInfo)
        }
        
        /*
        let transform = TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
            // 將值從 String? 變換為 Int?
            return Int(value!)
        }, toJSON: { (value: Int?) -> String? in
            // 將值從 Int? 變換為 String?
            if let value = value {
                return String(value)
            }
            return nil
        })
         
         id <- (map["id"], transform)

         */
        
        id <- (map["id"], TransformOf<Int, String>(fromJSON: { Int($0!) },
                                                   toJSON: { $0.map { String($0) } }))
    }
}

// 交通工具
class Vehicle: StaticMappable {
    // 類型
    var type: String?
    
    // 獲取映射對象
    class func objectForMapping(map: Map) -> BaseMappable? {
        if let type: String = map["type"].value() {
            switch type {
            case "car":
                return Car()
            case "bus":
                return Bus()
            default:
                return Vehicle()
            }
        }
        return nil
    }
    
    init() {
    }
    
    func mapping(map: Map) {
        type <- map["type"]
    }
}

// 小汽車
class Car: Vehicle {
    // 名字
    var name: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name <- map["name"]
    }
}

// 公車
class Bus: Vehicle {
    // 費用
    var fee: Int?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        fee <- map["fee"]
    }
}

class DistanceDescription: Mappable {
    
    var distance: Int?
    var distance2: Int?
    var distance3: Int?
    var type: String?
    var appName: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        distance  <- map["distance.value"]
        distance2 <- map["distanceArray.0.value"]
        distance3 <- map["distance.value", nested: false]
        type      <- map["type"]
        appName   <- map["com.hangge.info->com.hangge.name", delimiter: "->"]
    }
}

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reference:
        // http://www.hangge.com/blog/cache/detail_1673.html
        
        title = "ObjectMapper"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 0) {
            if indexPath.row == 0 {
                modelToDictionry()
            }
            else if indexPath.row == 1 {
                modelArrayToDictionaryArray()
            }
            else if indexPath.row == 2 {
                dictionryToModel()
            }
            else if indexPath.row == 3 {
                dictionryArrayToModelArray()
            }
            else if indexPath.row == 4 {
                modelToString()
            }
            else if indexPath.row == 5 {
                modelArrayToStringArray()
            }
            else if indexPath.row == 6 {
                stringToModel()
            }
            else if indexPath.row == 7 {
                stringArrayToModelArray()
            }
            else if indexPath.row == 8 {
                validateValue()
            }
        }
        else if (indexPath.section == 1) {
            if indexPath.row == 0 {
                staticMappableExample()
            }
        }
        else if (indexPath.section == 2) {
            if indexPath.row == 0 {
                easyMappingOfNestedObjects()
            }
            else if indexPath.row == 1 {
                customTransforms()
            }
            else if indexPath.row == 2 {
                genericObjects()
            }
            else if indexPath.row == 3 {
                mappingContext()
            }
        }
    }
}

// Mark: 使用ObjectMapper实现模型转换1（JSON与Model的相互转换）

extension ViewController {
    
    func modelToDictionry() {
        
        // Returns the JSON Dictionary for the object() {
        
        let lilei = User()
        lilei.username = "李雷"
        lilei.age = 18
        
        let meimei = User()
        meimei.username = "梅梅"
        meimei.age = 17
        meimei.bestFriend = lilei
        
        let meimeiDic:[String: Any] = meimei.toJSON()
        print(meimeiDic)
    }
    
    func modelArrayToDictionaryArray() {
        
        let lilei = User()
        lilei.username = "李雷"
        lilei.age = 18
        
        let meimei = User()
        meimei.username = "梅梅"
        meimei.age = 17
        
        let users = [lilei, meimei]
        let usersArray:[[String: Any]]  = users.toJSON()
        print(usersArray)
    }
    
    func dictionryToModel() {
        
        let meimeiDic: [String: Any] = ["age": 17, "username": "梅梅",
                                        "best_friend": ["age": 18, "username": "李雷"]]
        
        // Usage-1
        if let meimei = User(JSON: meimeiDic) { // Optional
            print(type(of: meimei))
            print(meimei)
        }
        
        // Usage-2
        if let meimei = Mapper<User>().map(JSON: meimeiDic) {
            print(type(of: meimei))
            print(meimei)
        }
    }
    
    func dictionryArrayToModelArray() {
        
        let usersArray = [["age": 17, "username": "梅梅"],
                          ["age": 18, "username": "李雷"]]
        
        let users: [User] = Mapper<User>().mapArray(JSONArray: usersArray)
        print(type(of: users))
        print(users)
        
        let age = users[0].age!
        print(age)
    }
    
    func modelToString() {
        
        let lilei = User()
        lilei.username = "李雷"
        lilei.age = 18
        
        let meimei = User()
        meimei.username = "梅梅"
        meimei.age = 17
        meimei.bestFriend = lilei
        
        let meimeiJSON: String = meimei.toJSONString()!
        print(meimeiJSON)
    }
    
    func modelArrayToStringArray() {
        
        let lilei = User()
        lilei.username = "李雷"
        lilei.age = 18
        
        let meimei = User()
        meimei.username = "梅梅"
        meimei.age = 17
        
        let users = [lilei, meimei]
        let json:String  = users.toJSONString()!
        print(json)
    }
    
    func stringToModel() {
        
        let meimeiJSON: String = "{\"age\":17,\"username\":\"梅梅\",\"best_friend\":{\"age\":18,\"username\":\"李雷\"}}"
        
        if let meimei = User(JSONString: meimeiJSON) {
            print(type(of: meimei))
            print(meimei)
        }
        
        if let meimei = Mapper<User>().map(JSONString: meimeiJSON) {
            print(type(of: meimei))
            print(meimei)
        }
    }
    
    func stringArrayToModelArray() {
        
        let json = "[{\"age\":18,\"username\":\"李雷\"},{\"age\":17,\"username\":\"梅梅\"}]"
        
        let users: [User] = Mapper<User>().mapArray(JSONString: json)!
        print(type(of: users))
        print(users)
        
        let age = users[0].age!
        print(age)
    }
    
    func validateValue() {
        
        let json = "[{\"age\":18,\"username\":\"李雷\"},{\"age\":17}]"
        let users:[User] = Mapper<User>().mapArray(JSONString: json)!
        print(users.count)
        // 運行結果如下，可以看到生成的數組中只有 1 個對象，
        // 這是由於另一個對象的 username 為空，因此被過濾掉了。
    }
}

// Mark: 使用ObjectMapper實現模型轉換2（StaticMappable協議）

extension ViewController {
    
    func staticMappableExample() {
        
        let JSON = [["type": "car", "name": "奇瑞QQ"],
                    ["type": "bus", "fee": 2],
                    ["type": "vehicle"]]
        
        let vehicles = Mapper<Vehicle>().mapArray(JSONArray: JSON)
        print("交通工具數量：\(vehicles.count)")
        if let car = vehicles[0] as? Car {
            print("小汽車名字：\(car.name!)")
        }
        if let bus = vehicles[1] as? Bus {
            print("公車費用：\(bus.fee!) 元")
        }
    }
}

// Mark: 使用ObjectMapper實現模型轉換3（高級用法）

extension ViewController {
    
    func easyMappingOfNestedObjects() {
    
        let json1: String = "{\"type\":\"S1\",\"distance\":{\"text\":\"102 ft\",\"value\":31}}"
        if let distanceDes = DistanceDescription(JSONString: json1) {
            print(distanceDes.distance!)
            print(distanceDes.type!)
        }
        
        let json2: String = "{\"type\":\"S1\",\"distanceArray\":[{\"text\":\"104 ft\",\"value\":32},{\"text\":\"102 ft\",\"value\":31}]}"
        if let distanceDes = DistanceDescription(JSONString: json2) {
            print(distanceDes.distance2!)
            print(distanceDes.type!)
        }
        
        let json3: String = "{\"type\":\"S1\",\"distance.value\":31}"
        if let distanceDes = DistanceDescription(JSONString: json3) {
            print(distanceDes.distance3!)
            print(distanceDes.type!)
        }
        
        let json4: String = "{\"type\":\"S1\",\"com.hangge.info\":{\"com.hangge.name\":\"航歌\"}}"
        if let distanceDes = DistanceDescription(JSONString: json4) {
            print(distanceDes.appName!)
            print(distanceDes.type!)
        }
    }
    
    func customTransforms() {
        
        let lilei = User()
        lilei.username = "李雷"
        lilei.birthday = Date()
        
        print(lilei.toJSONString()!)
        
        let json = "{\"id\":\"1234\",\"username\":\"梅梅\"}"
        let meimei: User = Mapper<User>().map(JSONString: json)!
        print(type(of: meimei))
        print(meimei.id!)
    }
    
    func genericObjects() {
        
        // ObjectMapper 同樣支持泛型類，只要這個泛型類型實現 Mappable 協議。下面是一個簡單的樣例：
        class Result<T: Mappable>: Mappable {
            var result: T?
            
            required init?(map: Map){
            }
            
            func mapping(map: Map) {
                result <- map["result"]
            }
        }
        
        // let result = Mapper<Result<User>>().map(JSON)
    }
    
    func mappingContext() {
        
        // Map 對象在映射的時候，可以傳遞一個可選的 MapContext 對象。
        // 這個開發人員可以利用這個對象在映射的時候傳遞一些信息，
        // 然後 Map 對象內部通過上下文來做出相關的映射的決策，比如：哪些需要映射、如何映射等。
        // 該功能只需創建一個實現 MapContext 協議（這是一個空協議）的對象，並在 Mapper 初始化期間將其傳遞即可。
        
        let meimeiJSON: String = "{\"age\":17,\"username\":\"梅梅\",\"best_friend\":{\"age\":18,\"username\":\"李雷\"}}"
        let context = Context()
        let meimei = Mapper<User>(context: context).map(JSONString: meimeiJSON)
        print(type(of: meimei))
        print(type(of: meimei))
    }
}

