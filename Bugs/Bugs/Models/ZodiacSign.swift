import Foundation

enum ZodiacSign: String, CaseIterable, Identifiable {
    case aries
    case taurus
    case gemini
    case cancer
    case leo
    case virgo
    case libra
    case scorpio
    case sagittarius
    case capricorn
    case aquarius
    case pisces

    var id: String { rawValue }

    var imageName: String { rawValue }

    var title: String {
        switch self {
        case .aries:
            return "Овен"
        case .taurus:
            return "Телец"
        case .gemini:
            return "Близнецы"
        case .cancer:
            return "Рак"
        case .leo:
            return "Лев"
        case .virgo:
            return "Дева"
        case .libra:
            return "Весы"
        case .scorpio:
            return "Скорпион"
        case .sagittarius:
            return "Стрелец"
        case .capricorn:
            return "Козерог"
        case .aquarius:
            return "Водолей"
        case .pisces:
            return "Рыбы"
        }
    }

    // MARK: - Calculation

    static func from(birthDate: Date, calendar: Calendar = .current) -> ZodiacSign {
        let components = calendar.dateComponents([.month, .day], from: birthDate)
        let month = components.month ?? 1
        let day = components.day ?? 1
        let value = month * 100 + day

        switch value {
        case 321...419:
            return .aries
        case 420...520:
            return .taurus
        case 521...620:
            return .gemini
        case 621...722:
            return .cancer
        case 723...822:
            return .leo
        case 823...922:
            return .virgo
        case 923...1022:
            return .libra
        case 1023...1121:
            return .scorpio
        case 1122...1221:
            return .sagittarius
        case 1222...1231, 101...119:
            return .capricorn
        case 120...218:
            return .aquarius
        default:
            return .pisces
        }
    }
}
