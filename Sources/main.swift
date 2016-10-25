//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import MySQL

// Create HTTP server.
let server = HTTPServer()

let testHost = "127.0.0.1"
let testUser = "root"
// PLEASE change to whatever your actual password is before running these tests
let testPassword = "chinaren"
let testSchema = "instagram"
func fetchData(success:(([String])->Void), failed:((String)->Void)) {

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
    
    let querySuccess = dataMysql.query(statement: "SELECT name, passwd FROM user")
    // 确保查询完成
    guard querySuccess else {
        failed("query failed")
        return
    }
    
    // 在当前会话过程中保存查询结果
    let results = dataMysql.storeResults()! //因为上一步已经验证查询是成功的，因此这里我们认为结果记录集可以强制转换为期望的数据结果。当然您如果需要也可以用if-let来调整这一段代码。
    
    var ary = [String]()
    
    results.forEachRow { row in
        var rest = "{"
        if let name = row[0] {
            rest += "\"name\":\"" + name + "\","
        } 
        if let passwd = row[1] {
            rest += "\"passwd\":\"" + passwd + "\"}"
        }
        
        ary.append(rest)
    }
    
    success(ary)
}

// Register your own routes and handlers

var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
    request, response in
    fetchData(success:({array in
        response.setHeader(.contentType, value: "text/json")
        let arr = array.map {
            $0
        }
        response.setBody(string: "\(rest)")
        response.completed()
    }), failed:({msg in
        response.setHeader(.contentType, value: "text/json")
        response.appendBody(string:"{\"code\":\"500\",\"msg\":\"failed\",\"data\":{\"errorCode\":\"123\"}}")
        response.completed()
    }))
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
    response.completed()
    }
)

var api1Routes = Routes()
api1Routes.add(method: .get, uri: "/api/v1", handler: {
    request, response in
    response.setHeader(.contentType, value: "text/json")
    response.appendBody(string:"{\"code\":\"0\",\"msg\":\"create house success\",\"data\":{\"house_id\":34358}}")
    response.completed()
    }
)

var api2Routes = Routes()
api2Routes.add(method: .get, uri: "/call2", handler: { request, response in
    response.setHeader(.contentType, value: "text/html")
    response.setBody(string: "程序接口API版本v2已经调用第二种方法")
    response.completed()
})
// Add the routes to the server.
server.addRoutes(routes)
server.addRoutes(api1Routes)
server.addRoutes(api2Routes)
// Set a listen port of 8181
server.serverPort = 8181

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
    // Launch the HTTP server.
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error thrown: \(err) \(msg)")
}
