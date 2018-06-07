//
//  boot.swift
//  GithubUpdater
//
//  Created by Givi Pataridze on 02.06.2018.
//

import Vapor
import Telegrammer

public func boot(_ app: Application) throws {
    
    let botService = try app.make(EchoBot.self)
    
    /// Starting longpolling way to receive bot updates
    /// Or either use webhooks by calling `startWebhooks()` method instead
    _ = try botService.updater?.startLongpolling()
    
}
