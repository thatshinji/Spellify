import SwiftUI

struct WordCardView: View {
    let word: Word
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            // Part of speech badge
            Text(word.partOfSpeech)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.gradient)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                )
            
            // Chinese Definition
            Text(word.chinese)
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            // Phonetic
            Text(word.phonetic)
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .background(
            ZStack {
                // Frosted Glass Base
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                // Specular Highlight (Reflection) for Liquid effect
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.1 : 0.2),
                                .clear,
                                .white.opacity(colorScheme == .dark ? 0.05 : 0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(colorScheme == .dark ? 0.6 : 0.8),
                            .white.opacity(colorScheme == .dark ? 0.1 : 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    ZStack {
        Color.teal.ignoresSafeArea()
        WordCardView(word: Word(english: "example", chinese: "例子", partOfSpeech: "n.", phonetic: "/ɪɡˈzæmpl/"))
            .padding()
    }
}
