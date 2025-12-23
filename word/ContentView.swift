//
//  ContentView.swift
//  word
//
//  Created by Li2 on 2025/12/24.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        ZStack {
            // Modern Background
            LinearGradient(
                colors: [Color(hex: "E0F7FA"), Color(hex: "E1BEE7")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Abstract Background blobs
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 120, y: 150)
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    Text("Word Learner")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("\(viewModel.score)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Card
                WordCardView(word: viewModel.currentWord)
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                    .id(viewModel.currentWord.id) // Force transition on change
                
                // Input
                LetterInputView(viewModel: viewModel)
                    .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger ? 1 : 0))
                
                Spacer()
                
                // Next Button (Only visible on success)
                Button {
                    viewModel.nextWord()
                } label: {
                    Text("Next Word")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 40)
                .opacity(viewModel.gameState == .success ? 1 : 0)
                .animation(.spring(), value: viewModel.gameState)
                
                Spacer()
            }
        }
    }
}

// MARK: - Animation Modifiers
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

// MARK: - Color Hex Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
