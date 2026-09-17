import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .font(.system(size: 56))
                .foregroundStyle(.tint)

            Text("Hello, World!")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("ПМУ · Лабораторная работа №1")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
