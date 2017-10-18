//
//  Server.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import UIKit

private let weatherAppDevApiURL = URL(string: "https://api.openweathermap.org")
private let weatherAppDotComApiURL = URL(string: "https://api.openweathermap.org")

struct Server: Codable {
    
    enum Key: String {
        case serverEnviromentKey = "_ServerEnviromentKey"
    }
    
    /// the current URL
    let url: URL?
    
    /// the name for the server
    let name: String
    
    /// the version of the current server
    let version: Int

    /// the available servers
    static var servers: [Server] {
        return [
            Server(name: "Development", url: weatherAppDevApiURL),
            Server(name: "Production", url: weatherAppDotComApiURL)
        ]
    }

    /// Returns a instance of the development server
    static var development: Server {
        return Server(name: "Development", url: weatherAppDevApiURL)
    }

    /// The default server is initialized with the
    /// production URL
    static var production: Server {
        return Server(name: "Production", url: weatherAppDotComApiURL)
    }

    /// Returns the current URL with the api path
    var apiEndPoint: URL? {
        return url?.appendingPathComponent("data/2.5")
    }

    /// the protection space for the current server
    var protectionSpace: URLProtectionSpace? {
        guard
            /// the server url
            let url = url,

            /// the url host
            let host = url.host else { return nil }

        return URLProtectionSpace(host: host,
                                  port: url.port ?? 0,
                                  protocol: url.scheme,
                                  realm: nil,
                                  authenticationMethod: nil)
    }
    
    // MARK: Initialization
    
    init(name: String, url: URL?, version: Int = 1) {
        self.name = name
        self.url = url
        self.version = version
    }
    
    // MARK: Class methods

    /// Returns the current server enabled
    static func current(userDefaultsStorable: UserDefaultsStorable = UserDefaults.standard) -> Server {
        guard
            /// the data
            let data = userDefaultsStorable.object(forKey: Key.serverEnviromentKey.rawValue) as? Data,

            /// the current server
            let server = try? JSONDecoder().decode(Server.self, from: data) else { return Server.development }

        return server
    }

    /// store the current server in the user default
    static func set(_ server: Server, userDefaultStorable: UserDefaultsStorable = UserDefaults.standard) {
        let data = try? JSONEncoder().encode(server)
        userDefaultStorable.set(data, forKey: Key.serverEnviromentKey.rawValue)
    }
}

extension Server: Equatable {

    static func == (lhs: Server, rhs: Server) -> Bool {
        return lhs.apiEndPoint == rhs.apiEndPoint && lhs.name == rhs.name && lhs.version == rhs.version
    }
}
