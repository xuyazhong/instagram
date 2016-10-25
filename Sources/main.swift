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
let testSchema = "test"
func fetchData() -> String {

            var result = ""
            let dataMysql = MySQL() // 创建一个MySQL连接实例

            let connected = dataMysql.connect(host: testHost, user: testUser, password: testPassword)

            guard connected else {
                // 验证一下连接是否成功
                print(dataMysql.errorMessage())
                result = dataMysql.errorMessage()
                return result
            }

            defer {
                dataMysql.close() //这个延后操作能够保证在程序结束时无论什么结果都会自动关闭数据库连接
            }

            // 选择具体的数据Schema
            guard dataMysql.selectDatabase(named: testSchema) else {
                result = "数据库选择失败。错误代码：\(dataMysql.errorCode())       错误解释：\(dataMysql.errorMessage())"
                    Log.info(message: result)
                    return result
            }
            return "\(dataMysql.serverVersion())"
        }

// Register your own routes and handlers

var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
		request, response in
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
    let rest = fetchData()
    response.setBody(string: "程序接口API版本v2已经调用第二种方法\(rest)")
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
