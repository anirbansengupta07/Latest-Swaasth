import Foundation
import SwiftUI
import GoogleGenerativeAI

struct GeminiAIView: View {
    @State var userPrompt = ""
    @State var geminiResponse: LocalizedStringKey   = "How can I help you?"
    @State var isGeminiLoading = false
    @State var chat = "" // Make 'chat' a @State variable
    let model = GenerativeModel(name: "gemini-pro", apiKey: DocAI2.default)
    
    var body: some View {
        VStack {
            Text("Welcome to DocAI")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.customBlue)
                .padding(.top, 40)
            ZStack {
                ScrollView {
                    Text(geminiResponse)
                        .font(.title3)
                }
                .padding()
                
                if isGeminiLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .customBlue))
                        .scaleEffect(4)
                }
            }

            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.customBlue, lineWidth: 1)
                        .foregroundColor(Color.white) // Light gray background
                        .shadow(radius: 2) // Shadow
                    
                    TextField("What issues are you facing", text: $chat) // Use $chat to bind TextField to chat state
                        .font(.custom("Inter", size: 15))
                        .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59)) // Text color
                        .padding(.leading, 23)
                        .padding(.trailing, 0)
                        .padding(.vertical, 10) // Add padding vertically
                }
                .frame(height: 50) // Adjust height
                
                Button(action: {
                    generateResponse()
                }) {
                    Image(systemName: "paperplane.circle.fill") // Use system image for consistency
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .padding(.trailing, 10)
                        .foregroundColor(.customBlue) // Button color
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, -10)
            .padding(.horizontal, 20)
        }
    }
    
    func generateResponse() {
        isGeminiLoading = true
        geminiResponse = ""
        
        Task {
            do {
                let prompt = chat + "\nYou are my personalized AI doctor, here to provide comprehensive guidance for my health concerns. As my AI doctor, your primary role is to suggest which department to visit the nearest hospital based on my symptoms. Please ensure to provide a detailed response with appropriate spacing to make it easier for me to read and understand. Since I'm a normal patient, I don't require a response of more than 150 words, but I need precise answers such as general medications and home remedies."
                let result = try await model.generateContent(prompt)
                isGeminiLoading = false
                geminiResponse = LocalizedStringKey(result.text ?? "No response found")
                chat = "" // Clear the chat after the response
            } catch {
                geminiResponse = "Something went wrong\n\(error.localizedDescription)"
            }
        }
    }
}
