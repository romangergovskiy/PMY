import Foundation

struct Author: Identifiable, Hashable {
    let name: String
    let photoName: String

    var id: String { name }
}

enum Authors {
    static let all: [Author] = [
        Author(name: "Роман Герговский", photoName: "author"),
        Author(name: "Данил Спектор", photoName: "spector")
    ]
}
