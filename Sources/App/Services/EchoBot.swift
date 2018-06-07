//
//  EchoBot.swift
//  EchoBot
//
//  Created by Givi Pataridze on 31.05.2018.
//

import Foundation
import Telegrammer
import Vapor

final class EchoBot: ServiceType {
    
    let bot: Bot
    var updater: Updater?
    var dispatcher: Dispatcher?
    
    /// Dictionary for user echo modes
    var userEchoModes: [Int64: Bool] = [:]
    
    static func makeService(for worker: Container) throws -> ExampleEchoBot {
        guard let token = Environment.get("TELEGRAM_BOT_TOKEN") else {
            throw CoreError(identifier: "Enviroment variables", reason: "Cannot find telegram bot token")
        }
        
        let settings = Bot.Settings(token: token, debugMode: true)
    
        /// Setting up webhooks https://core.telegram.org/bots/webhooks
        /// settings.webhooksIp = "127.127.0.1" ///Internal IP
        /// settings.webhooksPort = 8443 ///Internal Port
        /// settings.webhooksUrl = "https://127.127.0.1:8443/webhooks" ///External access url
        /// settings.webhooksPublicCert = "public.pem" ///Public key filename
        /// settings.webhooksPrivateKey = "private.pem" ///Private key filename
        
        return try ExampleEchoBot(settings: settings)
    }
    
    init(settings: Bot.Settings) throws {
        self.bot = try Bot(settings: settings)
        let dispatcher = try configureDispatcher()
        self.dispatcher = dispatcher
        self.updater = Updater(bot: bot, dispatcher: dispatcher)
    }
    
    func configureDispatcher() throws -> Dispatcher {
        ///Dispatcher - handle all incoming messages
        let dispatcher = Dispatcher(bot: bot)
        
        ///Creating and adding handler for command /echo
        let commandHandler = CommandHandler(commands: ["/echo"], callback: echoModeSwitch)
        dispatcher.add(handler: commandHandler)
        
        ///Creating and adding handler for ordinary text messages
        let echoHandler = MessageHandler(filters: Filters.text, callback: echoResponse)
        dispatcher.add(handler: echoHandler)
        
        return dispatcher
    }
}

extension ExampleEchoBot {
    ///Callback for Command handler, which send Echo mode status for user
    func echoModeSwitch(_ update: Update, _ updateQueue: Worker?, _ jobQueue: Worker?) throws {
        guard let message = update.message,
            let user = message.from else { return }
        
        var onText = ""
        if let on = userEchoModes[user.id] {
            onText = on ? "OFF" : "ON"
            userEchoModes[user.id] = !on
        } else {
            onText = "ON"
            userEchoModes[user.id] = true
        }
        
        let params = Bot.SendMessageParams(chatId: .chat(message.chat.id), text: "Echo mode turned \(onText)")
        try bot.sendMessage(params: params)
    }
    
    ///Callback for Message handler, which send echo message to user
    func echoResponse(_ update: Update, _ updateQueue: Worker?, _ jobQueue: Worker?) throws {
        guard let message = update.message,
            let user = message.from,
            let on = userEchoModes[user.id],
            on == true else { return }
        let params = Bot.SendMessageParams(chatId: .chat(message.chat.id), text: message.text!)
        try bot.sendMessage(params: params)
    }
}
