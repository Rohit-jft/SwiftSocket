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
    convenience init(receive: [UInt8]){
        self.init(send: receive,addr: nil,port: nil)
    }
    init(send: [UInt8],addr: String?,port: Int?){
        var remoteip = [Int8](count:16,repeatedValue:0)
        self.data = send
        if let a = addr{
            if 0 == c_datagramsocket_get_server_ip(a, remoteip){
                if let ip = String(CString: remoteip, encoding: NSUTF8StringEncoding){
                    self.addr = ip
                    self.port = port
                }
            }else{
                println("地址解析错误")
            }
        }else{
            self.addr = addr
            self.port = port
        }
    }
    public func reset(){
        data.removeAll(keepCapacity: false)
        addr = nil
        port = nil
    }
}
