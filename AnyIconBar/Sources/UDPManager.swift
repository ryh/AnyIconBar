import Foundation
import Network

class UDPManager {
    private var udpListener: NWListener?
    private let port: Int
    private let messageHandler: (String) -> Void

    init(port: Int, messageHandler: @escaping (String) -> Void) {
        self.port = port
        self.messageHandler = messageHandler
        setupUDPListener()
    }

    deinit {
        udpListener?.cancel()
    }

    private func setupUDPListener() {
        do {
            let parameters = NWParameters.udp
            udpListener = try NWListener(using: parameters, on: NWEndpoint.Port(rawValue: UInt16(port))!)

            udpListener?.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async {
                    switch state {
                    case .ready:
                        print("UDP listener ready on port \(self?.port ?? 0)")
                    case .failed(let error):
                        print("UDP listener failed: \(error)")
                    default:
                        break
                    }
                }
            }

            udpListener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }

            udpListener?.start(queue: .main)
        } catch {
            print("Failed to create UDP listener: \(error)")
        }
    }

    private func handleNewConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.receiveMessage(from: connection)
            default:
                break
            }
        }
        connection.start(queue: .main)
    }

    private func receiveMessage(from connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, error in
            if let data = data,
               let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DispatchQueue.main.async {
                    self?.messageHandler(message)
                }
            }

            if error == nil {
                // Continue receiving messages
                self?.receiveMessage(from: connection)
            }
        }
    }

    func stop() {
        udpListener?.cancel()
        udpListener = nil
    }
}