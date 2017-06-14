//
//  ViewController.swift
//  Swift-RealmSwift
//
//  Created by Alan Yen on 2017/6/13.
//  Copyright © 2017年 Alan-App. All rights reserved.
//

import UIKit
import RealmSwift

// 消費類型
class ConsumeType: Object {
    // 類型名
    dynamic var name = ""
}

// 消費條目
class ConsumeItem:Object {
    // 條目名
    dynamic var name = ""
    // 金額
    dynamic var cost = 0.00
    // 時間
    dynamic var date = Date()
    // 所屬消費類別
    dynamic var type:ConsumeType?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dformatter = DateFormatter()
    var consumeItems: Results<ConsumeItem>? // 保存從數據庫中查詢出來的結果集
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reference:
        // http://www.hangge.com/blog/cache/detail_891.html
        
        // 什麼是Realm
        // Realm 於2014 年7月發佈，是一個跨平台的移動數據庫引擎，專門為移動應用的數據持久化而生。其目的是要取代 Core Data 和 SQLite。
        // 2，關於Realm，你要知道下面幾點：
        //（1）使用簡單，大部分常用的功能（比如插入、查詢等）都可以用一行簡單的代碼輕鬆完成，學習成本低。
        //（2）Realm 不是基於 Core Data，也不是基於 SQLite 封裝構建的。它有自己的數據庫存儲引擎。
        //（3）Realm 具有良好的跨平台特性，可以在 iOS 和 Android 平台上共同使用。代碼可以使用 Swift 、 Objective-C 以及 Java 語言來編寫。
        //（4）Realm 還提供了一個輕量級的數據庫查看工具（Realm Browser）。你也可以用它進行一些簡單的編輯操作（比如插入和刪除操作）
        // 3，支持的類型
        // (1）Realm 支持以下的屬性類型：Bool、Int8、Int16、Int32、Int64、Double、Float、String、Date（精度到秒）以及Data.
        //（2）也可以使用 List<object> 和 Object 來建立諸如一對多、一對一之類的關係模型，此外 Object 的子類也支持此功能。
        
        title = "RealmSwift"
        
        setup()
        initializeData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        
        dformatter.dateFormat = "MM月dd日 HH:mm"
        tableView.tableFooterView = UIView()
    }
}

extension ViewController {
    
    @IBAction func createData(sender: UIBarButtonItem) {
        initializeData()
        
    }
    
    @IBAction func deleteData(sender: UIBarButtonItem) {
        deleteAllData()
    }
}

extension ViewController {
    
    func deleteAllData() {
        
        // 使用默認的數據庫
        let realm = try! Realm() // if an error was thrown, CRASH!

        try! realm.write {
            realm.deleteAll()
            self.consumeItems = nil
            self.tableView.reloadData()
        }
    }
    
    func initializeData() {
        
        // 使用默認的數據庫
        let realm = try! Realm() // if an error was thrown, CRASH!
        
        // 查詢所有的消費記錄
        consumeItems = realm.objects(ConsumeItem.self)
        
        // 已經有記錄的話就不插入了
        if let count = consumeItems?.count,
            count > 0 {
            
            print(count)
            
            // 查詢花費超過10元的消費記錄(使用斷言字符串查詢)
            consumeItems = realm.objects(ConsumeItem.self).filter("cost > 10")
            
            // 查詢花費超過10元的購物記錄(使用 NSPredicate 查詢)
            // let predicate = NSPredicate(format: "type.name = '購物' AND cost > 10")
            // consumeItems = realm.objects(ConsumeItem.self).filter(predicate)
            
            // 使用鏈式查詢
            // consumeItems = realm.objects(ConsumeItem.self).filter("cost > 10").filter("type.name = '購物'")
            
            // 查詢花費超過10元的消費記錄,並按升序排列
            // consumeItems = realm.objects(ConsumeItem.self).filter("cost > 10").sorted(byProperty: "cost")
            
            tableView.reloadData()
            
            return
        }
        
        // 創建兩個消費類型
        let type1 = ConsumeType()
        type1.name = "購物"
        let type2 = ConsumeType()
        type2.name = "娛樂"
        
        // 創建三個消費記錄
        let item1 = ConsumeItem(value: ["買一台電腦",5999.00,Date(),type1]) //可使用數組創建
        
        let item2 = ConsumeItem()
        item2.name = "看一場電影"
        item2.cost = 30.00
        item2.date = Date(timeIntervalSinceNow: -36000)
        item2.type = type2
        
        let item3 = ConsumeItem()
        item3.name = "買一包泡麵"
        item3.cost = 2.50
        item3.date = Date(timeIntervalSinceNow: -72000)
        item3.type = type1
        
        // 數據持久化操作（類型記錄也會自動添加的）
        try! realm.write {
            realm.add(item1)
            realm.add(item2)
            realm.add(item3)
        }
        
        // 打印出數據庫地址
        print(realm.configuration.fileURL!)
        
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consumeItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = consumeItems![indexPath.row]
        cell.textLabel?.text = item.name + " ￥" + String(format: "%.1f", item.cost)
        cell.detailTextLabel?.text = dformatter.string(from: item.date)
        return cell
    }
}
