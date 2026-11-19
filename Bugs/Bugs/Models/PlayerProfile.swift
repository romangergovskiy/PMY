import Foundation
import SwiftData

@Model
final class PlayerProfile {
    @Attribute(.unique) var id: UUID
    var fullName: String
    var genderRawValue: String
    var course: Int
    var difficulty: Int
    var birthDate: Date
    var zodiacRawValue: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \GameRecord.player)
    var records: [GameRecord] = []

    var gender: Gender {
        Gender(rawValue: genderRawValue) ?? .male
    }

    var zodiacSign: ZodiacSign {
        ZodiacSign(rawValue: zodiacRawValue) ?? .aries
    }

    init(
        id: UUID = UUID(),
        fullName: String,
        gender: Gender,
        course: Int,
        difficulty: Int,
        birthDate: Date,
        zodiacSign: ZodiacSign,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.fullName = fullName
        self.genderRawValue = gender.rawValue
        self.course = course
        self.difficulty = difficulty
        self.birthDate = birthDate
        self.zodiacRawValue = zodiacSign.rawValue
        self.createdAt = createdAt
    }
}
