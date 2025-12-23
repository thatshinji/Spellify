import SwiftUI

struct WordCardView: View {
    let word: Word
    
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
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .light) // Force light frosted look or adapt
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.5), lineWidth: 1)
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
