import Foundation
import CocoaLumberjackSwift

open class DebugObserverFactory: ObserverFactory {
    public var delegate: DataAmountMesurable?
    public override init() {}

    override open func getObserverForTunnel(_ tunnel: Tunnel) -> Observer<TunnelEvent>? {
        let obs = DebugTunnelObserver()
        obs.delegate = delegate
        return obs
    }

    override open func getObserverForProxyServer(_ server: ProxyServer) -> Observer<ProxyServerEvent>? {
        return DebugProxyServerObserver()
    }

    override open func getObserverForProxySocket(_ socket: ProxySocket) -> Observer<ProxySocketEvent>? {
        return DebugProxySocketObserver()
    }

    override open func getObserverForAdapterSocket(_ socket: AdapterSocket) -> Observer<AdapterSocketEvent>? {
        return DebugAdapterSocketObserver()
    }

    open override func getObserverForRuleManager(_ manager: RuleManager) -> Observer<RuleMatchEvent>? {
        return DebugRuleManagerObserver()
    }
}

public protocol DataAmountMesurable {
    func data(_ data: Data)
}

open class DebugTunnelObserver: Observer<TunnelEvent> {
    var delegate: DataAmountMesurable?
    override open func signal(_ event: TunnelEvent) {
        var resData: Data? = nil
        switch event {
        case .adapterSocketWroteData(let data, by: _, on: _):
            resData = data
        case .adapterSocketReadData(let data, from: _, on: _):
            resData = data
        case .proxySocketWroteData(let data, by: _, on: _):
            resData = data
        case .proxySocketReadData(let data, from: _, on: _):
            resData = data
        default: break
        }
        guard let d = resData else {
            return
        }
        delegate?.data(d)
    }

}

open class DebugProxySocketObserver: Observer<ProxySocketEvent> {
    override open func signal(_ event: ProxySocketEvent) {
        switch event {
        case .errorOccured:
            DDLogError("\(event)")
        case .disconnected,
             .receivedRequest:
            DDLogInfo("\(event)")
        case .socketOpened,
             .askedToResponseTo,
             .readyForForward:
            DDLogVerbose("\(event)")
        case .disconnectCalled,
             .forceDisconnectCalled,
             .readData,
             .wroteData:
            DDLogDebug("\(event)")
        }
    }
}

open class DebugAdapterSocketObserver: Observer<AdapterSocketEvent> {
    override open func signal(_ event: AdapterSocketEvent) {
        switch event {
        case .errorOccured:
            DDLogError("\(event)")
        case .disconnected,
             .connected:
            DDLogInfo("\(event)")
        case .socketOpened,
             .readyForForward:
            DDLogVerbose("\(event)")
        case .disconnectCalled,
             .forceDisconnectCalled,
             .readData,
             .wroteData:
            DDLogDebug("\(event)")
        }
    }
}

open class DebugProxyServerObserver: Observer<ProxyServerEvent> {
    override open func signal(_ event: ProxyServerEvent) {
        switch event {
        case .started,
             .stopped:
            DDLogInfo("\(event)")
        case .newSocketAccepted,
             .tunnelClosed:
            DDLogVerbose("\(event)")
        }
    }
}

open class DebugRuleManagerObserver: Observer<RuleMatchEvent> {
    open override func signal(_ event: RuleMatchEvent) {
        switch event {
        case .ruleDidNotMatch, .dnsRuleMatched:
            DDLogVerbose("\(event)")
        case .ruleMatched:
            DDLogInfo("\(event)")
        }
    }
}
