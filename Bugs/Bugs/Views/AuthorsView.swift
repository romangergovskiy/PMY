import SwiftUI

struct AuthorsView: View {

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(
                    systemImage: "person.2.fill",
                    title: "Авторы",
                    subtitle: "Участники проекта"
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

                List(Authors.all) { author in
                    AuthorRow(author: author)
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Palette.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Row

private struct AuthorRow: View {
    let author: Author

    var body: some View {
        HStack(spacing: 14) {
            Image(author.photoName)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay {
                    Circle().stroke(Palette.gold.opacity(0.7), lineWidth: 2)
                }

            Text(author.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Palette.ink)

            Spacer()
        }
        .padding(14)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
    }
}

#Preview {
    AuthorsView()
}
