import SwiftUI
import UIKit

struct LetterInputView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var focusedIndex: Int? = 0 // Start focused on first input? Or nil. Let's default nil or 0. Logic sets it.
    // Actually, View init might need to set it?
    // Let's just use @State private var focusedIndex: Int?
    // Initial focus is handled by logic or user tap.
    @State private var focusedIndex: Int?
    
    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(0..<viewModel.userInputs.count, id: \.self) { index in
                let isRevealed = viewModel.isIndexReadOnly(index)
                let char = viewModel.userInputs[index]
                
                BackspaceTextField(
                    text: Binding(
                        get: { char },
                        set: { _ in } // Managed by coordination
                    ),
                    isFocused: focusedIndex == index,
                    isEditable: !isRevealed,
                    textColor: UIColor(textColor(for: index, isRevealed: isRevealed)),
                    onTextChange: { newValue in
                        if !isRevealed {
                           handleInput(newValue, at: index)
                        }
                    },
                    onBackspace: {
                        handleBackspace(at: index)
                    },
                    onFocus: {
                        focusedIndex = index
                    }
                )
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
            }
        }
        .onChange(of: viewModel.userInputs) {
            viewModel.checkAnswer()
        }
    }
    
    private func handleInput(_ newValue: String, at index: Int) {
        // Take the last character if multiple typed (paste case) or just the char
        let filtered = newValue.prefix(1).lowercased()
        
        // Update model
        viewModel.userInputs[index] = String(filtered)
        
        // Auto-advance focus
        // Auto-advance focus
        if !filtered.isEmpty {
            var nextIndex = index + 1
            while nextIndex < viewModel.userInputs.count && viewModel.isIndexReadOnly(nextIndex) {
                 nextIndex += 1
            }
            if nextIndex < viewModel.userInputs.count {
                // Async update to allow current field to finish processing
                // and view to settle before forcing focus change
                DispatchQueue.main.async {
                    self.focusedIndex = nextIndex
                }
            } else {
                DispatchQueue.main.async {
                    self.focusedIndex = nil // Dismiss
                }
            }
        }
    }
    
    private func handleBackspace(at index: Int) {
        // 1. Clear current field immediately
        viewModel.userInputs[index] = ""
        
        // 2. Move to previous editable field
        var prevIndex = index - 1
        while prevIndex >= 0 && viewModel.isIndexReadOnly(prevIndex) {
            prevIndex -= 1
        }
        
        if prevIndex >= 0 {
            // Async focus update
            DispatchQueue.main.async {
                self.focusedIndex = prevIndex
            }
        }
    }
    
    // MARK: - Style Helpers
    
    @Environment(\.colorScheme) var colorScheme

    private func bgColor(for index: Int, isRevealed: Bool) -> Color {
        if isRevealed {
            return colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)
        }
        return colorScheme == .dark ? Color.white.opacity(0.15) : Color.white
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
        return colorScheme == .dark ? Color.white.opacity(0.3) : Color.white.opacity(0.5)
    }
    
    private func textColor(for index: Int, isRevealed: Bool) -> Color {
        if isRevealed {
            return .secondary
        }
        return .primary
    }
}

// MARK: - Custom TextField for Backspace Detection
struct BackspaceTextField: UIViewRepresentable {
    @Binding var text: String
    var isFocused: Bool
    var isEditable: Bool
    var textColor: UIColor
    var onTextChange: (String) -> Void
    var onBackspace: () -> Void
    var onFocus: () -> Void
    
    func makeUIView(context: Context) -> CustomUITextField {
        let textField = CustomUITextField()
        textField.delegate = context.coordinator
        textField.onBackspace = onBackspace
        textField.textAlignment = .center
        if let descriptor = UIFont.systemFont(ofSize: 24, weight: .bold).fontDescriptor.withDesign(.monospaced) {
             textField.font = UIFont(descriptor: descriptor, size: 24)
        } else {
             textField.font = UIFont.monospacedSystemFont(ofSize: 24, weight: .bold)
        }
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .asciiCapable
        // textField.addTarget... removed (Strict Control)
        textField.tintColor = .systemBlue
        return textField
    }
    
    func updateUIView(_ uiView: CustomUITextField, context: Context) {
        // Update text content
        if uiView.text != text {
            uiView.text = text
        }
        
        // Update visual props
        uiView.textColor = textColor
        uiView.isUserInteractionEnabled = isEditable
        uiView.onBackspace = onBackspace
        
        // Handle Focus
        if isFocused {
            // Force focus if not already focused
            if !uiView.isFirstResponder {
                // Must be on main thread, usually already is, but async helps break update cycles
                DispatchQueue.main.async {
                    uiView.becomeFirstResponder()
                }
            }
        } else {
            // Do not explicitly resign here to prevent keyboard flicker.
            // When another field becomes responder, this one will auto-resign.
            // If we need to dismiss keyboard completely, we can do it via global state or parent.
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: BackspaceTextField
        
        init(parent: BackspaceTextField) {
            self.parent = parent
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            // Not used with strict control, but kept for fallback or external changes? 
            // Actually, remove listener to avoid double call if we returned true somewhere.
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            // Ensure state matches reality
            // If the user tapped this field, we must update focusedIndex binding to this index
            // so that the SwiftUI state knows where we are.
             parent.onFocus()
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // BACKSPACE is handled by deleteBackward override in CustomUITextField. 
            // So this method handles INSERTION/REPLACEMENT.
            
            // If string is empty, it's a delete (or cut), but deleteBackward usually catches key press.
            // However, predictive text or paste might use this.
            
            if string.isEmpty {
                 // Deletion via menu/paste? Let process?
                 // Usually backspace key goes to deleteBackward.
                 // Let's allow empty to pass through or handle clear.
                 if range.length > 0 {
                     parent.onTextChange("") // Clear
                 }
                 return false
            }
            
            // Filtering: Take 1st char
            if let char = string.first {
                parent.onTextChange(String(char))
            }
            
            return false // We managed state update manually. View will update via binding.
        }
    }
}

class CustomUITextField: UITextField {
    var onBackspace: (() -> Void)?
    
    override func deleteBackward() {
        // User requested aggressive backspace:
        // Always trigger custom logic (Clear Current + Move Previous)
        // instead of just clearing current and waiting for next tap.
        onBackspace?()
        super.deleteBackward()
    }
    
    // Helper to ensure we can resign if needed externally, mostly handled by system
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var height: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var maxRowHeight: CGFloat = 0
        var rows: Int = 1
        
        for size in sizes {
            if currentRowWidth + size.width > width {
                // New Line
                height += maxRowHeight + spacing
                currentRowWidth = 0
                maxRowHeight = 0
                rows += 1
            }
            currentRowWidth += size.width + spacing
            maxRowHeight = max(maxRowHeight, size.height)
        }
        
        height += maxRowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var maxHeight: CGFloat = 0
        var rowStartIndex = 0
        
        for (index, size) in sizes.enumerated() {
            if x + size.width > bounds.maxX {
                // Formatting previous row to be centered
                centerRow(subviews: subviews, sizes: sizes, rowStartIndex: rowStartIndex, rowEndIndex: index, bounds: bounds, y: y, totalWidth: x - spacing - bounds.minX)
                
                // Move to new row
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
                rowStartIndex = index
            }
            
            subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        
        // Center last row
        centerRow(subviews: subviews, sizes: sizes, rowStartIndex: rowStartIndex, rowEndIndex: sizes.count, bounds: bounds, y: y, totalWidth: x - spacing - bounds.minX)
    }
    
    private func centerRow(subviews: Subviews, sizes: [CGSize], rowStartIndex: Int, rowEndIndex: Int, bounds: CGRect, y: CGFloat, totalWidth: CGFloat) {
        let availableWidth = bounds.width
        let offset = (availableWidth - totalWidth) / 2
        
        var x = bounds.minX + offset
        for index in rowStartIndex..<rowEndIndex {
            subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(sizes[index]))
            x += sizes[index].width + spacing
        }
    }
}
