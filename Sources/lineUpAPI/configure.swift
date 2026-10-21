import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import Gatekeeper
import JWT

/// configures your application
func configure(_ app: Application) async throws {

    app.databases.use(.mysql(
        hostname: "127.0.0.1",
        port: 3306,
        username: "root",
        password: "",
        database: "line_up",
        tlsConfiguration: nil
    ), as: .mysql)


    // Clé utilisée pour signer et vérifier les tokens JWT
    guard let jwtSecret = Environment.get("JWT_SECRET") else {
        fatalError("JWT_SECRET manquant dans le fichier .env")
    }
    await app.jwt.keys.add(hmac: HMACKey(from:jwtSecret), digestAlgorithm: .sha256)


    // CORS configuration to change if needed. allowedOrigin might change for the access.
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS],
        allowedHeaders: [.accept, .authorization, .contentType, .origin],
        cacheExpiration: 800
    )

    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)

    /* Vapor installe déjà par défaut un ErrorMiddleware, qui transforme les erreurs (Abort(.notFound)…) en réponses JSON. Avec un simple use, votre CORS est ajouté après lui, donc plus près des routes. Quand une route lance une erreur, cette erreur remonte en sautant votre CORS. La réponse d'erreur part alors sans les en-têtes CORS.
     */
    app.middleware.use(corsMiddleware, at: .beginning)

    app.caches.use(.memory)
    app.gatekeeper.config = .init(maxRequests: 100, per: .minute)
    app.middleware.use(GatekeeperMiddleware())


    app.migrations.add(CreateCategory())
    app.migrations.add(CreateWorkshop())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateReservation())
    


    // Encodage et Décodage pour la DATE
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    ContentConfiguration.global.use(encoder: encoder, for: .json)
    ContentConfiguration.global.use(decoder: decoder, for: .json)

    try await app.autoMigrate()

    // register routes
    try routes(app)
}
