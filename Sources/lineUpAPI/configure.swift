import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.mysql(
        hostname: "127.0.0.1",
        port: 3306,
        username: "root",
        password: "",
        database: "line_up",
        tlsConfiguration: nil
    ), as: .mysql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateReservation())
    
    // register routes
    try routes(app)
}
