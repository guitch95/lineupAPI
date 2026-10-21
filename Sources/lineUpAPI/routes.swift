import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: AuthController())
    try app.register(collection: WorkshopController())
    try app.register(collection: UserController())
    try app.register(collection: CategoryController())
    try app.register(collection: ReservationController())
}
