//
//  DatagramPacket.swift
//  SocketTest
//
//  Created by WHM on 15/9/21.
//  Copyright (c) 2015年 wansir. All rights reserved.
//

import Foundation

public class DatagramPacket{
    var data: [UInt8]
    var addr: String?
    var port: Int?
    convenience init(data: [UInt8]){
        self.init(data: data,addr: nil,port: nil)
    }
    init(data: [UInt8],addr: String?,port: Int?){
        var remoteip = [Int8](count:16,repeatedValue:0)
        self.data = data
        if let a = addr{
            if 0 == c_datagramsocket_get_server_ip(a, remoteip){
                if let ip = String(CString: remoteip, encoding: NSUTF8StringEncoding){
                    self.addr = ip
                    
                    self.port = port
                }
            }
        }else{
            self.addr = addr
            self.port = port
        }
    }
}
