//
//  XXInstallManager.swift
//  XXInstall
//
//  Created by zhaoyu on 2023/3/18.
//

import Foundation
import Starscream

public class XXInstallManager: NSObject {
    
    // 单例
    public static let instance = XXInstallManager()
    
    var socket: WebSocket!
    
    var url: String = ""
    
    // websocket 是否连接
    var isConnected = false
    
    // 心跳间隔
    var heartbeatInterval: TimeInterval = 5
    
    // 心跳定时器是否暂停
    var isHeartbeatTimerSuspended = true
    
    // 心跳超时
    //    var isHeartbeatTimeout = false
    
    // 心跳时间戳
    //    var heartbeatTimestamp: TimeInterval = 0
    
    lazy var heartbeatTimer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: heartbeatInterval, leeway: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            if !self.isHeartbeatTimerSuspended {
                self.sendHeartbeat()
            }
        }
        return timer
    }()
    
    // 是否打印
    public var enableLog = false
    
    private override init() {
        super.init()
    }
    
    deinit {
        socket.disconnect()
        destroyHeartbeatTimer()
    }
    
    public func startConnect(host: String){
        
        let xxBundleId = Bundle.main.bundleIdentifier ?? ""
        //        log("xxBundleId--\(xxBundleId)")
        
        let xxUuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        //        log("xxUuid--\(xxUuid)")
        
        //        let platform = UIDevice.current.systemName
        //        log("platform--\(platform)") // iOS
        
        let url = host + "?packageName=\(xxBundleId)&deviceId=\(xxUuid)&packageId=\(xxUuid)&platform=ios"
        log("url--\(url)")
        self.url = url
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 10
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func reconnect(){
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 10
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
}


extension XXInstallManager : WebSocketDelegate {
    
    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
        case .connected(let headers):
            handleConnectedEvent()
            log("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            handleDisConnectedEvent()
            log("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            log("Received text: \(string)")
        case .binary(let data):
            log("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            handleDisConnectedEvent()
        case .error(let error):
            log("error: reconnet")
            handleError(error)
            reconnect()
        }
    }
}

// MARK: - 心跳相关
extension XXInstallManager {
    
    // 发送心跳
    func sendHeartbeat(){
        if isConnected {
            //            updateHeartbeatTimestamp()
            //            socket.write(string: "\(heartbeatTimestamp)")
            socket.write(data: Data())
            log("send heartbeat")
        }else{
            socket.connect();
        }
    }
    
    // 定时器执行
    func resumeHeartbeatTimer() {
        if isHeartbeatTimerSuspended {
            isHeartbeatTimerSuspended = false
            heartbeatTimer.resume()
        }
    }
    
    // 定时器暂停
    func suspendHeartbeatTimer() {
        if !isHeartbeatTimerSuspended {
            isHeartbeatTimerSuspended = true
            heartbeatTimer.suspend()
        }
    }
    
    // 定时器销毁
    func destroyHeartbeatTimer() {
        heartbeatTimer.cancel()
        resumeHeartbeatTimer()
    }
    
    // 更新心跳时间戳
    //    func updateHeartbeatTimestamp() {
    //        heartbeatTimestamp = Date().timeIntervalSince1970 * 1_000
    //    }
    
    // 心跳超时
    //    private func handleHeartbeatTimeout() {
    //        isHeartbeatTimeout = true
    //    }
    
}

// MARK: - 连接相关
extension XXInstallManager {
    
    // socket 已连接
    func handleConnectedEvent(){
        isConnected = true
        resumeHeartbeatTimer()
    }
    
    // socket 断开连接
    func handleDisConnectedEvent(){
        isConnected = false
        suspendHeartbeatTimer()
    }
    
    // socket 重连机制
}

// MARK: - 发送消息
extension XXInstallManager {
    
    // 发送事件
    public func sendEvent(eventName: String){
        
        guard let data = eventName.data(using: .utf8) else { return }
        socket.write(data: data)
        
    }
}

// MARK: - 打印相关
extension XXInstallManager {
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            log("websocket encountered an error:-- \(e.message)")
        } else if let e = error {
            log("websocket encountered an error:== \(e.localizedDescription)")
        } else {
            log("websocket encountered an error")
        }
    }
    
    // debug 打印，release 不打印
    func log(
        _ log: @autoclosure () -> String = "",
        file: String = #file,
        line: Int = #line,
        function: String = #function)
    {
        if enableLog {
            debugPrint("\(function) at \((file as NSString).lastPathComponent)[\(line)]", log())
        }
    }
}


