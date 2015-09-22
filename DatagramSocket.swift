//
//  DatagramSocket.swift
//  SocketTest
//
//  Created by WHM on 15/9/21.
//  Copyright (c) 2015年 wansir. All rights reserved.
//

import Foundation

@asmname("datagramsocket") func c_datagramsocket(host:UnsafePointer<Int8>,port:Int32) -> Int32
@asmname("datagramsocket_send") func c_datagramsocket_send(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32,ip:UnsafePointer<Int8>,port:Int32) -> Int32
@asmname("datagramsocket_get_server_ip") func c_datagramsocket_get_server_ip(host:UnsafePointer<Int8>,ip:UnsafePointer<Int8>) -> Int32
@asmname("socket_close") func c_datagramsocket_close(fd:Int32) -> Int32
@asmname("datagramsocket_recive") func c_datagramsocket_recive(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32,ip:UnsafePointer<Int8>,port:UnsafePointer<Int32>) -> Int32






public class DatagramSocket:connect{
    override init() {
        super.init()
        bind()
    }
    override init(port: Int) {
        super.init(port: port)
        bind()
    }
    public override init(addr: String,port: Int){
        super.init(addr: addr, port: port)
        bind()
    }
    public func bind(){
        let fd = c_datagramsocket(self.addr, Int32(self.port))
        if fd != -1{
            self.fd = fd
        }
    }

    //TODO add multycast and boardcast
    public func recv(packet: DatagramPacket) -> Int{
        if let fd = self.fd{
            var remoteip : [Int8] = [Int8](count:16,repeatedValue:0x0)
            var remoteport : Int32=0
            var dataLen: Int32 = c_datagramsocket_recive(fd,packet.data,Int32(packet.data.count), &remoteip, &remoteport)
            packet.port = Int(remoteport)
            packet.addr = String(CString: remoteip, encoding: NSUTF8StringEncoding)
            return Int(dataLen)
        }
        return -1
    }
    
    
    public func send(packet: DatagramPacket) -> Int{
        if let fd = self.fd,addr = packet.addr,port = packet.port{
            return Int(c_datagramsocket_send(fd,packet.data,Int32(packet.data.count),addr,Int32(port)))
        }else{
            return -1
        }
    }
    
    public func close()->(Bool,String){
        if let fd:Int32=self.fd{
            c_datagramsocket_close(fd)
            self.fd=nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
}
