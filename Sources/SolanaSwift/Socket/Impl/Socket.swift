import Foundation

class Socket: NSObject, SolanaSocket {
    // MARK: - Properties
    var isConnected: Bool = false
    var urlSession: URLSession!
    var task: URLSessionWebSocketTask!
    var wsHeartBeat: Timer!
    
    // MARK: - Streams
    let subscribingResultsStream = SocketResponseStream<SubscribingResultResponse>()
    let accountInfoStream = SocketResponseStream<SocketAccountResponse>()
    let signatureInfoStream = SocketResponseStream<SocketSignatureResponse>()
    
    // MARK: - Subscriptions
    let subscriptionsStorage = SubscriptionsStorage()
    
    // MARK: - Initializers
    init(endpoint: String) {
        
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        self.task = urlSession.webSocketTask(with: .init(string: endpoint)!)
        
        defer { connect() }
    }
    
    deinit {
        task.cancel(with: .goingAway, reason: nil)
        clean()
        accountInfoStream.onFinish?()
        signatureInfoStream.onFinish?()
        subscribingResultsStream.onFinish?()
    }
    
    // MARK: - Methods
    func connect() {
        clean()
        task.resume()
    }
    
    func disconnect() {
        clean()
        isConnected = false
        task.cancel(with: .goingAway, reason: nil)
    }
    
    func addToObserving(account: SocketObservableAccount) async throws {
        // check if any subscription of account exists
        guard await !subscriptionsStorage.subscriptionExists(account: account)
        else { return /* already subscribed */ }
        
        // add account to observing list
        await subscriptionsStorage.insertObservableAccount(account)
        
        // add subscriptions
        let requestId = try await write(
            method: .init(.account, .subscribe),
            params: [
                account.pubkey,
                ["encoding":"base64", "commitment": "recent"]
            ]
        )
        
        let subscriptionId: UInt64
        for try await result in subscribingResultsStream where requestId == result.requestId {
            break
        }
        
        await subscriptionsStorage.insertSubscription(
            .init(
                entity: .account,
                id: subscriptionId,
                account: account.pubkey
            )
        )
    }
    
    func removeFromObserving(account: String) {
        <#code#>
    }
    
    func observeAllAccounts() -> SocketResponseStream<SocketAccountResponse> {
        <#code#>
    }
    
    func observe(account: String) -> SocketResponseStream<SocketAccountResponse> {
        <#code#>
    }
    
    func observe(signature: String) -> SocketResponseStream<SocketSignatureResponse> {
        <#code#>
    }
}

extension Socket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        // wipe old subscriptions
        unsubscribeAllObservingAccounts()
        
        // set status
        status.accept(.connected)
        
        // set heart beat
        wsHeartBeat?.invalidate()
        wsHeartBeat = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            // Ping server every 5s to prevent idle timeouts
            self?.ping()
        }
        
        // resubscribe
        subscribeToAllAccounts()
        
        // mark as connected
        isConnected = true
        
        // get new message
        Task {
            try await receiveNewMessage()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        
        clean()
        
        // mark as not connected
        isConnected = false
        
        // TODO: - Reopen?
    }
}
