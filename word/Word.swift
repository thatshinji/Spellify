import Foundation

struct Word: Identifiable, Equatable {
    let id = UUID()
    let english: String
    let chinese: String
    let partOfSpeech: String
    let phonetic: String
}

class WordRepository {
    static let shared = WordRepository()
    
    private let words: [Word] = [
        Word(english: "algorithm", chinese: "算法", partOfSpeech: "n.", phonetic: "/ˈælɡərɪðəm/"),
        Word(english: "beautiful", chinese: "美丽的", partOfSpeech: "adj.", phonetic: "/ˈbjuːtɪfl/"),
        Word(english: "capture", chinese: "捕捉", partOfSpeech: "v.", phonetic: "/ˈkæptʃər/"),
        Word(english: "diamond", chinese: "钻石", partOfSpeech: "n.", phonetic: "/ˈdaɪəmənd/"),
        Word(english: "elegant", chinese: "优雅的", partOfSpeech: "adj.", phonetic: "/ˈelɪɡənt/"),
        Word(english: "freedom", chinese: "自由", partOfSpeech: "n.", phonetic: "/ˈfriːdəm/"),
        Word(english: "galaxy", chinese: "银河", partOfSpeech: "n.", phonetic: "/ˈɡæləksi/"),
        Word(english: "horizon", chinese: "地平线", partOfSpeech: "n.", phonetic: "/həˈraɪzn/"),
        Word(english: "inspire", chinese: "启发", partOfSpeech: "v.", phonetic: "/ɪnˈspaɪər/"),
        Word(english: "journey", chinese: "旅程", partOfSpeech: "n.", phonetic: "/ˈdʒɜːrni/")
    ]
    
    func getRandomWord() -> Word {
        return words.randomElement()!
    }
}
