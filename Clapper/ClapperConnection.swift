//
//  ClapperConnection.swift
//  Clapper
//
//  Created by Jack Cook on 4/16/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

class ClapperConnection: HTTPConnection {
    
    override func supportsMethod(method: String!, atPath path: String!) -> Bool {
        guard let url = NSURL(string: "a://a.a/\(path)") else {
            return super.supportsMethod(method, atPath: path)
        }
        
        return method == "GET" && url.pathComponents![1] == "clap"
    }
    
    override func httpResponseForMethod(method: String!, URI path: String!) -> protocol<NSObjectProtocol, HTTPResponse>! {
        print("[\(method)] \(path)")
        
        guard let url = NSURL(string: "a://a.a/\(path)") else {
            return super.httpResponseForMethod(method, URI: path)
        }
        
        if method == "GET" && url.pathComponents![1] == "clap" {
            print("clap")
            let response = "success".dataUsingEncoding(NSUTF8StringEncoding)
            return HTTPDataResponse(data: response)
        }
        
        return super.httpResponseForMethod(method, URI: path)
    }
}
