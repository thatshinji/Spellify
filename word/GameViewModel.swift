import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var currentWord: Word
    @Published var maskedLetters: [String] = []
    @Published var userInputs: [String] = []
    @Published var revealedIndices: Set<Int> = []
    @Published var gameState: GameState = .playing
    @Published var score: Int = 0
    @Published var shakeTrigger: Bool = false
    
    enum GameState: Equatable {
        case playing
        case success
        case failure
    }
    
    init() {
        // Initialize with a temporary random word
        let word = WordRepository.shared.getRandomWord()
        self.currentWord = word
        
        // Setup initial game state directly to ensure self is fully initialized
        // Logic duplicated conceptually from startNewGame to safely init
        let fullWord = Array(word.english)
        let length = fullWord.count
        let maskCount = max(1, Int(Double(length) * 0.5))
        var indicesToMask = Set<Int>()
        while indicesToMask.count < maskCount {
            indicesToMask.insert(Int.random(in: 0..<length))
        }
        
        self.revealedIndices = Set(0..<length).subtracting(indicesToMask)
        self.maskedLetters = fullWord.map { String($0) }
        
        // Initialize user inputs
        var initialInputs = Array(repeating: "", count: length)
        for index in self.revealedIndices {
            initialInputs[index] = String(fullWord[index])
        }
        self.userInputs = initialInputs
    }
    
    func startNewGame() {
        currentWord = WordRepository.shared.getRandomWord()
        setupLevel()
    }
    
    // Setup the level ensuring some letters are masked
    private func setupLevel() {
        let fullWord = Array(currentWord.english)
        let length = fullWord.count
        
        // Decide how many letters to mask (e.g., 40-60%)
        let maskCount = max(1, Int(Double(length) * 0.5))
        var indicesToMask = Set<Int>()
        
        while indicesToMask.count < maskCount {
            indicesToMask.insert(Int.random(in: 0..<length))
        }
        
        revealedIndices = Set(0..<length).subtracting(indicesToMask)
        
        maskedLetters = fullWord.map { String($0) }
        userInputs = Array(repeating: "", count: length)
        
        // Fill user inputs for revealed indices
        for index in revealedIndices {
            userInputs[index] = String(fullWord[index])
        }
        
        gameState = .playing
    }
    
    func checkAnswer() {
        let fullWord = currentWord.english.lowercased()
        let userAnswer = userInputs.joined().lowercased()
        
        if userAnswer == fullWord {
            gameState = .success
            score += 10
        } else {
            // Check if all filled but wrong, or just incomplete?
            // For now, if filled and wrong, trigger shake
             if !userInputs.contains("") {
                 withAnimation {
                     shakeTrigger.toggle()
                 }
             }
        }
    }
    
    func isIndexReadOnly(_ index: Int) -> Bool {
        return revealedIndices.contains(index)
    }
    
    func nextWord() {
        withAnimation {
            startNewGame()
        }
    }
}
