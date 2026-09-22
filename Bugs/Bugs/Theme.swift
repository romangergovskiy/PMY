import SwiftUI

enum Palette {
    static let accent = Color(red: 0.09, green: 0.45, blue: 0.19)
    static let gold = Color(red: 0.76, green: 0.62, blue: 0.22)

    static let background = Color(uiColor: UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(red: 0.07, green: 0.10, blue: 0.08, alpha: 1)
        }
        return UIColor(red: 0.93, green: 0.95, blue: 0.91, alpha: 1)
    })

    static let card = Color(uiColor: UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(red: 0.12, green: 0.16, blue: 0.13, alpha: 1)
        }
        return UIColor.white
    })

    static let field = Color(uiColor: UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(red: 0.16, green: 0.22, blue: 0.17, alpha: 1)
        }
        return UIColor(red: 0.95, green: 0.96, blue: 0.93, alpha: 1)
    })

    static let ink = Color(uiColor: UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(red: 0.93, green: 0.95, blue: 0.91, alpha: 1)
        }
        return UIColor(red: 0.10, green: 0.16, blue: 0.12, alpha: 1)
    })

    static let muted = Color(uiColor: UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(red: 0.68, green: 0.74, blue: 0.69, alpha: 1)
        }
        return UIColor(red: 0.35, green: 0.42, blue: 0.36, alpha: 1)
    })
}
