//
//  mysql.swift
//  
//
//  Created by xuyazhong on 2016/10/26.
//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import MySQL

let testHost = "127.0.0.1"
let testUser = "root"
// PLEASE change to whatever your actual password is before running these tests
let testPassword = "chinaren"
let testSchema = "instagram"

func fetchData(success:((String)->Void), failed:((String)->Void)) {
    
    var result = ""
    let dataMysql = MySQL() // 创建一个MySQL连接实例
    
    let connected = dataMysql.connect(host: testHost, user: testUser, password: testPassword, db: testSchema)
    
    guard connected else {
        // 验证一下连接是否成功
        print(dataMysql.errorMessage())
        result = dataMysql.errorMessage()
        failed(result)
        return
    }
    
    defer {
        dataMysql.close() //这个延后操作能够保证在程序结束时无论什么结果都会自动关闭数据库连接
    }
    
    let a1 = dataMysql.query(statement: "SET NAMES 'UTF8'");
    let a2 = dataMysql.query(statement: "SET CHARACTER SET UTF8");
    let a3 = dataMysql.query(statement: "SET CHARACTER_SET_RESULTS='UTF8'");
    guard a1 else {
        failed("a1 failed")
        return
    }
    guard a2 else {
        failed("a2 failed")
        return
    }
    guard a3 else {
        failed("a3 failed")
        return
    }
    let querySuccess = dataMysql.query(statement: "SELECT name, passwd FROM user")
    // 确保查询完成
    guard querySuccess else {
        failed("query failed")
        return
    }
    
    // 在当前会话过程中保存查询结果
    let results = dataMysql.storeResults()! //因为上一步已经验证查询是成功的，因此这里我们认为结果记录集可以强制转换为期望的数据结果。当然您如果需要也可以用if-let来调整这一段代码。
    
    var ary = [[String: String]]()
    // let scoreArray: [String:Any] = ["1st Place": 300, "2nd Place": 230.45, "3rd Place": 150]
    // let encoded = try scoreArray.jsonEncodedString()
    results.forEachRow { row in
        var v1 = ""
        var v2 = ""
        if let name = row[0] {
            v1 = name
        }
        if let passwd = row[1] {
            v2 = passwd
        }
        ary.append(["name":v1,"passwd":v2])
    }
    Log.debug(message: "array \(ary)")
    let encoded = try! ary.jsonEncodedString()
    Log.debug(message: "json \(encoded)")
    success(encoded)
    //success("123567 234567")
}
