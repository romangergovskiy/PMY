import Foundation

struct Player: Equatable {
    var fullName: String
    var gender: Gender
    var course: Int
    var difficulty: Int
    var birthDate: Date
    var zodiacSign: ZodiacSign

    var detailsText: String {
        [
            "ФИО: \(fullName)",
            "Пол: \(gender.title)",
            "Курс: \(course)",
            "Уровень сложности: \(difficulty)",
            "Дата рождения: \(Self.dateFormatter.string(from: birthDate))",
            "Знак зодиака: \(zodiacSign.title)"
        ].joined(separator: "\n")
    }

    // MARK: - Formatting

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
}
