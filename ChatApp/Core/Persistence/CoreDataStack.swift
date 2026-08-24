import CoreData
import Foundation

@MainActor
protocol LocalStoreProtocol: AnyObject {
    func cachedConversations() async throws -> [Conversation]
    func cache(conversations: [Conversation]) async throws
    func cachedMessages(conversationId: String) async throws -> [Message]
    func cache(messages: [Message], conversationId: String) async throws
    func cache(users: [User]) async throws
}

@MainActor
final class CoreDataLocalStore: LocalStoreProtocol {
    private let container: NSPersistentContainer
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "ChatApp", managedObjectModel: model)
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        container.loadPersistentStores { _, error in
            if let error { assertionFailure("Core Data failed to load: \(error)") }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func cachedConversations() async throws -> [Conversation] {
        try fetchJSON(entityName: "CachedConversation").sorted { lhs, rhs in
            (lhs.lastMessage?.createdAt ?? .distantPast) > (rhs.lastMessage?.createdAt ?? .distantPast)
        }
    }

    func cache(conversations: [Conversation]) async throws {
        try upsertJSON(conversations, entityName: "CachedConversation")
    }

    func cachedMessages(conversationId: String) async throws -> [Message] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "CachedMessage")
        request.predicate = NSPredicate(format: "conversationId == %@", conversationId)
        let objects = try container.viewContext.fetch(request)
        return try objects.compactMap { object in
            guard let data = object.value(forKey: "payload") as? Data else { return nil }
            return try decoder.decode(Message.self, from: data)
        }.sorted { $0.createdAt < $1.createdAt }
    }

    func cache(messages: [Message], conversationId: String) async throws {
        let context = container.viewContext
        for message in messages {
            let object = try object(for: message.id, entityName: "CachedMessage") ?? NSEntityDescription.insertNewObject(forEntityName: "CachedMessage", into: context)
            object.setValue(message.id, forKey: "id")
            object.setValue(conversationId, forKey: "conversationId")
            object.setValue(try encoder.encode(message), forKey: "payload")
            object.setValue(message.createdAt, forKey: "updatedAt")
        }
        try saveIfNeeded()
    }

    func cache(users: [User]) async throws {
        try upsertJSON(users, entityName: "CachedUser")
    }

    private func fetchJSON<T: Decodable>(entityName: String) throws -> [T] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        let objects = try container.viewContext.fetch(request)
        return try objects.compactMap { object in
            guard let data = object.value(forKey: "payload") as? Data else { return nil }
            return try decoder.decode(T.self, from: data)
        }
    }

    private func upsertJSON<T: Encodable & Identifiable>(_ values: [T], entityName: String) throws where T.ID == String {
        let context = container.viewContext
        for value in values {
            let object = try object(for: value.id, entityName: entityName) ?? NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            object.setValue(value.id, forKey: "id")
            object.setValue(try encoder.encode(value), forKey: "payload")
            object.setValue(Date(), forKey: "updatedAt")
        }
        try saveIfNeeded()
    }

    private func object(for id: String, entityName: String) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try container.viewContext.fetch(request).first
    }

    private func saveIfNeeded() throws {
        let context = container.viewContext
        if context.hasChanges { try context.save() }
    }

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [
            makeEntity(name: "CachedConversation", includeConversationId: false),
            makeEntity(name: "CachedMessage", includeConversationId: true),
            makeEntity(name: "CachedUser", includeConversationId: false)
        ]
        return model
    }

    private static func makeEntity(name: String, includeConversationId: Bool) -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = name
        entity.managedObjectClassName = "NSManagedObject"

        let id = NSAttributeDescription()
        id.name = "id"
        id.attributeType = .stringAttributeType
        id.isOptional = false

        let payload = NSAttributeDescription()
        payload.name = "payload"
        payload.attributeType = .binaryDataAttributeType
        payload.isOptional = false

        let updatedAt = NSAttributeDescription()
        updatedAt.name = "updatedAt"
        updatedAt.attributeType = .dateAttributeType
        updatedAt.isOptional = false

        var properties = [id, payload, updatedAt]
        if includeConversationId {
            let conversationId = NSAttributeDescription()
            conversationId.name = "conversationId"
            conversationId.attributeType = .stringAttributeType
            conversationId.isOptional = false
            properties.append(conversationId)
        }
        entity.properties = properties
        return entity
    }
}
