//
//  Test.swift
//  lineUpAPI
//
//  Created by Canessane Ramya on 29/10/2026.
//

import JWT
import Fluent
import Testing
import VaporTesting
@testable import lineUpAPI

@Suite("Tests des ateliers")
struct WorkshopControllerTests {
    
    func createCategory(_ app: Application, name: String = "Voix") async throws -> lineUpAPI.Category {
        let category = lineUpAPI.Category(nameCategory: name)
        try await category.save(on: app.db)
        return category
    }
    
    func createWorkshop(_ app: Application, name: String, category: lineUpAPI.Category, subscribers: Int = 0) async throws -> Workshop {
        let workshop = Workshop(
            nameWorkshop: name,
            startTimeWorkshop: Date().addingTimeInterval(3600),
            endTimeWorkshop: Date().addingTimeInterval(7200),
            capacityMaxWorkshop: 10,
            descriptionWorkshop: "Une description",
            categoryID: try category.requireID()
        )
        workshop.subscribersNbWorkshop = subscribers
        try await workshop.save(on: app.db)
        return workshop
    }
    
    func createToken(_ app: Application, role: UserRole) async throws -> String {
        let user = User(
            name: "User test",
            email: "\(UUID().uuidString)@test.com",
            passwordHash: "",
            role: role
        )
        try await user.save(on: app.db)
        let payload = UserPayload(id: try user.requireID())
        return try await app.jwt.keys.sign(payload)
    }
    
    // Des données de modification VALIDES. Dans chaque test d'erreur,
    // on modifie UN SEUL champ de cet objet pour le rendre invalide.
    func validInput(categoryID: UUID) -> CreateWorkshopDTO {
        CreateWorkshopDTO(
            nameWorkshop: "Nouveau nom",
            startTimeWorkshop: Date().addingTimeInterval(10_000),
            endTimeWorkshop: Date().addingTimeInterval(20_000),
            capacityMaxWorkshop: 20,
            descriptionWorkshop: "Nouvelle description",
            categoryID: categoryID
        )
    }
    
    @Test("La liste est vide au départ")
    func emptyList() async throws {
        try await withApp(configure: configure) { app in
            try await app.testing().test(.GET, "workshops") { res in
                #expect(res.status == .ok)
                let workshops = try res.content.decode([Workshop].self)
                #expect(workshops.isEmpty)
            }
        }
    }
    
    @Test("POST crée un atelier et répond 200 avec l'atelier créé")
    func createWorkshopSuccess() async throws {
        try await withApp(configure: configure) { app in
            // Arrange : préparer
            let category = try await createCategory(app)
            let token = try await createToken(app, role: .staff)
            let input = CreateWorkshopDTO(
                nameWorkshop: "Atelier test",
                startTimeWorkshop: Date().addingTimeInterval(3600),
                endTimeWorkshop: Date().addingTimeInterval(7200),
                capacityMaxWorkshop: 10,
                descriptionWorkshop: "Une description",
                categoryID: try #require(category.id)
            )
            
            // Act : agir
            try await app.testing().test(.POST, "workshops", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                // Assert : vérifier
                #expect(res.status == .ok)
                let workshop = try res.content.decode(WorkshopDTO.self)
                #expect(workshop.name == "Atelier test")
                #expect(workshop.capacityMax == 10)
                #expect(workshop.description == "Une description")
                #expect(workshop.category.id == category.id)
                #expect(workshop.category.categoryName == "Voix")
            })
        }
    }
    
    @Test("Une catégorie inconnue répond 404")
    func createWorkshopUnknownCategory() async throws {
        try await withApp(configure: configure) { app in
            // Arrange
            let token = try await createToken(app, role: .staff)
            let input = CreateWorkshopDTO(
                nameWorkshop: "Atelier test",
                startTimeWorkshop: Date().addingTimeInterval(3600),
                endTimeWorkshop: Date().addingTimeInterval(7200),
                capacityMaxWorkshop: 10,
                descriptionWorkshop: "Une description",
                categoryID: UUID()
            )
            
            // Act + Assert
            try await app.testing().test(.POST, "workshops", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .notFound)
                #expect(res.body.string.contains("Catégorie introuvable"))
            })
        }
    }
    
    @Test("Une heure de fin avant l'heure de début répond 400")
    func createWorkshopEndBeforeStart() async throws {
        try await withApp(configure: configure) { app in
            // Arrange
            let category = try await createCategory(app)
            let token = try await createToken(app, role: .staff)
            let input = CreateWorkshopDTO(
                nameWorkshop: "Atelier test",
                startTimeWorkshop: Date().addingTimeInterval(7200),   // début dans 2h
                endTimeWorkshop: Date().addingTimeInterval(3600),     // fin dans 1h : AVANT le début
                capacityMaxWorkshop: 10,
                descriptionWorkshop: "Une description",
                categoryID: try #require(category.id)
            )
            
            // Act + Assert
            try await app.testing().test(.POST, "workshops", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .badRequest)
                #expect(res.body.string.contains("L'heure de fin doit être après l'heure de début"))
            })
        }
    }
    
    @Test("Une capacité supérieure à 0 est acceptée")
    func createWorkshopValidCapacity() async throws {
        try await withApp(configure: configure) { app in
            // Arrange
            let category = try await createCategory(app)
            let token = try await createToken(app, role: .staff)
            let input = CreateWorkshopDTO(
                nameWorkshop: "Atelier test",
                startTimeWorkshop: Date().addingTimeInterval(3600),
                endTimeWorkshop: Date().addingTimeInterval(7200),
                capacityMaxWorkshop: 1,
                descriptionWorkshop: "Une description",
                categoryID: try #require(category.id)
            )
            
            // Act + Assert
            try await app.testing().test(.POST, "workshops", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let workshop = try res.content.decode(WorkshopDTO.self)
                #expect(workshop.capacityMax == 1)
            })
        }
    }
    
    @Test("Une capacité de 0 ou négative répond 400", arguments: [0, -1, -10])
    func createWorkshopInvalidCapacity(capacity: Int) async throws {
        try await withApp(configure: configure) { app in
            // Arrange
            let category = try await createCategory(app)
            let token = try await createToken(app, role: .staff)
            let input = CreateWorkshopDTO(
                nameWorkshop: "Atelier test",
                startTimeWorkshop: Date().addingTimeInterval(3600),
                endTimeWorkshop: Date().addingTimeInterval(7200),
                capacityMaxWorkshop: capacity,
                descriptionWorkshop: "Une description",
                categoryID: try #require(category.id)
            )
            
            // Act + Assert
            try await app.testing().test(.POST, "workshops", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .badRequest)
                #expect(res.body.string.contains("La capacité doit être supérieure à 0"))
            })
        }
    }
    
    @Test("La liste renvoie tous les ateliers avec leur catégorie")
    func indexReturnsWorkshops() async throws {
        try await withApp(configure: configure) { app in
            // Arrange : deux ateliers dans deux catégories différentes
            let voix = try await createCategory(app, name: "Voix")
            let impro = try await createCategory(app, name: "Impro")
            _ = try await createWorkshop(app, name: "Atelier A", category: voix)
            _ = try await createWorkshop(app, name: "Atelier B", category: impro)
            
            // Act + Assert : route publique, pas de token
            try await app.testing().test(.GET, "workshops") { res in
                #expect(res.status == .ok)
                let workshops = try res.content.decode([WorkshopDTO].self)
                #expect(workshops.count == 2)
                
                let a = try #require(workshops.first { $0.name == "Atelier A" })
                let b = try #require(workshops.first { $0.name == "Atelier B" })
                #expect(a.category.categoryName == "Voix")
                #expect(b.category.categoryName == "Impro")
            }
        }
    }
    
    @Test("GET /workshops/:id renvoie le bon atelier avec sa catégorie")
    func getWorkshopByIDSuccess() async throws {
        try await withApp(configure: configure) { app in
            // Arrange : deux ateliers, pour vérifier qu'on récupère le bon
            let impro = try await createCategory(app, name: "Impro")
            let danse = try await createCategory(app, name: "Danse")
            let workshopA = try await createWorkshop(app, name: "Atelier A", category: impro)
            _ = try await createWorkshop(app, name: "Atelier B", category: danse)
            let id = try workshopA.requireID()
            
            // Act + Assert : route publique, pas de token
            try await app.testing().test(.GET, "workshops/\(id)") { res in
                #expect(res.status == .ok)
                let workshop = try res.content.decode(WorkshopDTO.self)
                #expect(workshop.id == id)
                #expect(workshop.name == "Atelier A")
                #expect(workshop.category.categoryName == "Impro")
            }
        }
    }
    
    @Test("Un atelier inconnu répond 404")
    func getWorkshopByIDUnknown() async throws {
        try await withApp(configure: configure) { app in
            // Act + Assert : UUID() n'existe forcément pas dans une base vide
            try await app.testing().test(.GET, "workshops/\(UUID())") { res in
                #expect(res.status == .notFound)
                #expect(res.body.string.contains("Workshop introuvable"))
            }
        }
    }
    
    @Test("Un id qui n'est pas un UUID répond 400")
    func getWorkshopByIDInvalid() async throws {
        try await withApp(configure: configure) { app in
            // Act + Assert
            try await app.testing().test(.GET, "workshops/pas-un-uuid") { res in
                #expect(res.status == .badRequest)
                #expect(res.body.string.contains("Entrez un id valide"))
            }
        }
    }
    
    @Test("PUT modifie l'atelier et répond 200 avec les nouvelles valeurs")
    func updateWorkshopSuccess() async throws {
        try await withApp(configure: configure) { app in
            // Arrange : un atelier "Impro", qu'on va passer en "Danse"
            let impro = try await createCategory(app, name: "Impro")
            let danse = try await createCategory(app, name: "Danse")
            let workshop = try await createWorkshop(app, name: "Ancien nom", category: impro)
            let id = try workshop.requireID()
            let token = try await createToken(app, role: .staff)
            let input = validInput(categoryID: try #require(danse.id))
            
            // Act + Assert : la réponse contient les nouvelles valeurs
            try await app.testing().test(.PUT, "workshops/\(id)", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .ok)
                let updated = try res.content.decode(WorkshopDTO.self)
                #expect(updated.id == id)
                #expect(updated.name == "Nouveau nom")
                #expect(updated.capacityMax == 20)
                #expect(updated.description == "Nouvelle description")
                #expect(updated.category.categoryName == "Danse")
            })
            
            // La modification est bien enregistrée : on relit l'atelier
            try await app.testing().test(.GET, "workshops/\(id)") { res in
                let reread = try res.content.decode(WorkshopDTO.self)
                #expect(reread.name == "Nouveau nom")
                #expect(reread.category.categoryName == "Danse")
            }
        }
    }
    
    @Test("Un atelier inconnu répond 404")
    func updateWorkshopUnknown() async throws {
        try await withApp(configure: configure) { app in
            // Arrange : aucun atelier créé
            let category = try await createCategory(app)
            let token = try await createToken(app, role: .staff)
            let input = validInput(categoryID: try #require(category.id))
            
            // Act + Assert
            try await app.testing().test(.PUT, "workshops/\(UUID())", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .notFound)
                #expect(res.body.string.contains("Workshop introuvable"))
            })
        }
    }
    
    @Test("Une catégorie inconnue répond 400")
    func updateWorkshopUnknownCategory() async throws {
        try await withApp(configure: configure) { app in
            // Arrange : ATTENTION, ici c'est 400 et non 404 comme pour le POST
            let category = try await createCategory(app)
            let workshop = try await createWorkshop(app, name: "Atelier", category: category)
            let token = try await createToken(app, role: .staff)
            let input = validInput(categoryID: UUID())
            
            // Act + Assert
            try await app.testing().test(.PUT, "workshops/\(try workshop.requireID())", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .badRequest)
                #expect(res.body.string.contains("Catégorie introuvable"))
            })
        }
    }
    
    @Test("Une heure de fin avant l'heure de début répond 400")
    func updateWorkshopEndBeforeStart() async throws {
        try await withApp(configure: configure) { app in
            // Arrange
            let category = try await createCategory(app)
            let workshop = try await createWorkshop(app, name: "Atelier", category: category)
            let token = try await createToken(app, role: .staff)
            var input = validInput(categoryID: try #require(category.id))
            input.endTimeWorkshop = input.startTimeWorkshop.addingTimeInterval(-3600)   // ← fin AVANT le début
            
            // Act + Assert
            try await app.testing().test(.PUT, "workshops/\(try workshop.requireID())", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .badRequest)
                #expect(res.body.string.contains("L'heure de fin doit être après l'heure de début"))
            })
        }
    }
    
    @Test("Une capacité inférieure au nombre d'inscrits répond 409")
    func updateWorkshopCapacityBelowSubscribers() async throws {
        try await withApp(configure: configure) { app in
            // Arrange : 5 inscrits, on essaie de mettre la capacité à 3
            let category = try await createCategory(app)
            let workshop = try await createWorkshop(app, name: "Atelier", category: category, subscribers: 5)
            let token = try await createToken(app, role: .staff)
            var input = validInput(categoryID: try #require(category.id))
            input.capacityMaxWorkshop = 3
            
            // Act + Assert
            try await app.testing().test(.PUT, "workshops/\(try workshop.requireID())", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
                try req.content.encode(input)
            }, afterResponse: { res in
                #expect(res.status == .conflict)
                #expect(res.body.string.contains("La capacité ne peut pas être inférieure au nombre d'inscrits"))
            })
        }
    }
    
    @Test("DELETE répond 204, puis l'atelier n'existe plus")
    func deleteWorkshopSuccess() async throws {
        try await withApp(configure: configure) { app in
            // Arrange
            let category = try await createCategory(app)
            let workshop = try await createWorkshop(app, name: "Atelier", category: category)
            let id = try workshop.requireID()
            let token = try await createToken(app, role: .staff)

            // Act + Assert 1 : la suppression répond 204
            try await app.testing().test(.DELETE, "workshops/\(id)", beforeRequest: { req in
                req.headers.bearerAuthorization = .init(token: token)
            }, afterResponse: { res in
                #expect(res.status == .noContent)
            })

            // Assert 2 : on relit, l'atelier a vraiment disparu
            try await app.testing().test(.GET, "workshops/\(id)") { res in
                #expect(res.status == .notFound)
            }
        }
    }
}
