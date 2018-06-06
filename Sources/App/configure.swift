import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register defau
    var services = Services.default()
    
    /// Setting up HTTPServer
    let serverConfig = NIOServerConfig.default(hostname: "127.0.0.1")
    services.register(serverConfig)
    
    var middlewareConfig = MiddlewareConfig()
    middlewareConfig.use(ErrorMiddleware.self)
    middlewareConfig.use(SessionsMiddleware.self)
    services.register(middlewareConfig)
    
    ///Registering bot as a vapor service
    services.register(ExampleEchoBot.self)
    
    ///Registering vapor http router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}
