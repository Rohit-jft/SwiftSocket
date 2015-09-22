
import Foundation

@asmname("socket_connect") func c_socket_connect(host:UnsafePointer<Int8>,port:Int32,timeout:Int32) -> Int32
@asmname("socket_close") func c_socket_close(fd:Int32) -> Int32
@asmname("socket_send") func c_socket_send(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32) -> Int32
@asmname("socket_read") func c_socket_read(fd:Int32,buff:UnsafePointer<UInt8>,len:Int32) -> Int32
@asmname("socket_listen") func c_socket_listen(addr:UnsafePointer<Int8>,port:Int32)->Int32
@asmname("socket_accept") func c_socket_accept(onsocketfd:Int32,ip:UnsafePointer<Int8>,port:UnsafePointer<Int32>) -> Int32

public class connect{
    var addr:String
    var port:Int
    var fd:Int32?
    init(){
        self.addr = "0.0.0.0"
        self.port = 0
    }
    init(port: Int){
        self.addr = "0.0.0.0"
        self.port = port
    }
    init(addr: String,port: Int){
        self.addr = addr
        self.port = port
    }
}

public class Socket:connect{
    override init() {
        super.init()
    }
    //禁用
    private override init(port: Int) {
        super.init(port: port)
    }
    override init(addr: String, port: Int) {
        super.init(addr: addr, port: port)
        var result = connect(15)
        println(result.1)
    }
    private func connect(timeout: Int)->(Bool,String){
        var result_fd = c_socket_connect(self.addr,Int32(self.port),Int32(timeout))
        if result_fd > 0{
            self.fd = result_fd
            return (true,"connect success")
        }else{
            switch result_fd{
            case -1:
                return (false,"qeury server fail")
            case -2:
                return (false,"connection closed")
            case -3:
                return (false,"connect timeout")
            default:
                return (false,"unknow err.")
            }
        }
    }
    /*
    * close socket
    * return success or fail with message
    */
    public func close()->(Bool,String){
        if let fd = self.fd{
            c_socket_close(fd)
            self.fd = nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
    /*
    * send data
    * return success or fail with message
    */
    public func send(data: [UInt8])->(Bool,String){
        if let fd = self.fd{
            var sendsize = c_socket_send(fd,data, Int32(data.count))
            if Int(sendsize) == data.count{
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
    * send string
    * return success or fail with message
    */
    public func send(str: String)->(Bool,String){
        if let fd = self.fd{
            var sendsize = c_socket_send(fd, str, Int32(strlen(str)))
            if sendsize==Int32(strlen(str)){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
    *
    * send nsdata
    */
    public func send(data: NSData)->(Bool,String){
        if let fd = self.fd{
            var buff:[UInt8] = [UInt8](count:data.length,repeatedValue:0)
            data.getBytes(&buff, length: data.length)
            var sendsize = c_socket_send(fd, buff, Int32(data.length))
            if sendsize == Int32(data.length){
                return (true,"send success")
            }else{
                return (false,"send error")
            }
        }else{
            return (false,"socket not open")
        }
    }
    /*
    * read data with expect length
    * return success or fail with message
    */
    public func read(expectlen:Int)->[UInt8]?{
        if let fd = self.fd{
            var buff:[UInt8] = [UInt8](count:expectlen,repeatedValue:0)
            var readLen = c_socket_read(fd, &buff, Int32(expectlen))
            if readLen<=0{
                return nil
            }
            var rs = buff[0...Int(readLen-1)]
            var data:[UInt8] = Array(rs)
            return data
        }
       return nil
    }
}

public class SocketServer:connect{
    override init(port: Int) {
        super.init(port: port)
        listen()
    }
    override init(addr: String, port: Int) {
        super.init(addr: addr, port: port)
        listen()
    }

    private func listen()->(Bool,String){
        var fd = c_socket_listen(self.addr, Int32(self.port))
        if fd>0{
            self.fd = fd
            return (true,"listen success")
        }else{
            return (false,"listen fail")
        }
    }
    public func accept()->Socket?{
        if let serverfd = self.fd{
            var buff:[Int8] = [Int8](count:16,repeatedValue:0)
            var port:Int32 = 0
            var clientfd = c_socket_accept(serverfd, &buff,&port)
            if clientfd<0{
                return nil
            }
            var socket: Socket = Socket()
            socket.fd = clientfd
            socket.port = Int(port)
            if let addr = String(CString: buff, encoding: NSUTF8StringEncoding){
               socket.addr = addr
            }
            return socket
        }
        return nil
    }
    public func close()->(Bool,String){
        if let fd = self.fd{
            c_socket_close(fd)
            self.fd=nil
            return (true,"close success")
        }else{
            return (false,"socket not open")
        }
    }
}


