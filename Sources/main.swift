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

// Register your own routes and handlers

var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
    request, response in
    //{"code":"0","msg":"create house success","data":{"house_id":34358}}
    fetchData(success:({array in
        response.setHeader(.contentType, value: "text/json;charset=utf8")
        response.setBody(string: "{\"code\":\"0\",\"data\":\(array)}")
        response.completed()
    }), failed:({ msg in
         Log.debug(message: "failed \(msg)")
        response.setHeader(.contentType, value: "text/json")
        response.appendBody(string:"{\"code\":\"500\",\"msg\":\"failed\",\"data\":{\"errorCode\":\"123\"}}")
        response.completed()
    }))
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
