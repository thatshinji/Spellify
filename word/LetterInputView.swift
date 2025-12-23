import SwiftUI

struct LetterInputView: View {
    @ObservedObject var viewModel: GameViewModel
    @FocusState private var focusedIndex: Int?
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.userInputs.count, id: \.self) { index in
                let isRevealed = viewModel.isIndexReadOnly(index)
                let char = viewModel.userInputs[index]
                
                TextField("", text: Binding(
                    get: { char },
                    set: { newValue in
                        // Only allow setting if not revealed and length is 1
                        if !isRevealed {
                            handleInput(newValue, at: index)
                        }
                    }
                ))
                .focused($focusedIndex, equals: index)
                .disabled(isRevealed)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .multilineTextAlignment(.center)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .frame(width: 44, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(bgColor(for: index, isRevealed: isRevealed))
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(borderColor(for: index), lineWidth: focusedIndex == index ? 2 : 1)
                )
                .foregroundColor(textColor(for: index, isRevealed: isRevealed))
            }
        }
        .onChange(of: viewModel.userInputs) {
            viewModel.checkAnswer()
        }
    }
    
    private func handleInput(_ newValue: String, at index: Int) {
        // Take the last character if multiple typed (paste case) or just the char
        let filtered = newValue.prefix(1).lowercased()
        viewModel.userInputs[index] = String(filtered)
        
        // Auto-advance focus
        if !filtered.isEmpty {
            var nextIndex = index + 1
            while nextIndex < viewModel.userInputs.count && viewModel.isIndexReadOnly(nextIndex) {
                nextIndex += 1
            }
            if nextIndex < viewModel.userInputs.count {
                focusedIndex = nextIndex
            } else {
                focusedIndex = nil // Dismiss keyboard if done
            }
        }
    }
    
    // MARK: - Style Helpers
    
    private func bgColor(for index: Int, isRevealed: Bool) -> Color {
        if isRevealed {
            return Color.black.opacity(0.05)
        }
        return Color.white
    }
    
    private func borderColor(for index: Int) -> Color {
        if focusedIndex == index {
            return Color.blue
        }
        if viewModel.gameState == .success {
            return Color.green
        }
        if viewModel.gameState == .failure {
            return Color.red
        }
        return Color.white.opacity(0.5)
    }
    
    private func textColor(for index: Int, isRevealed: Bool) -> Color {
        if isRevealed {
            return .secondary
        }
        return .primary
    }
}
