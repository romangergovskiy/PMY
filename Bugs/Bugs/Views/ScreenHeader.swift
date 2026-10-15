import SwiftUI

struct ScreenHeader: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Palette.gold)
                .frame(width: 56, height: 56)
                .background(Palette.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(Palette.ink)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Palette.muted)
            }

            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}
