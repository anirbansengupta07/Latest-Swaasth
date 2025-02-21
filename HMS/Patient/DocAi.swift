import SwiftUI
import GoogleGenerativeAI

struct WelcomeDocAiView: View {
    @State private var isLoading = false
    @State private var isSuggestionsSheetVisible = false
    @State private var chatbotResponse: String = ""
//    @State var userPrompt = ""
//    @State var geminiResponse = "How can I help you?"
//    @State var isGeminiLoading = false
    let apiKey = "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"
    @State private var chat = ""
    
//    let model = GenerativeModel(name: "gemini-pro", apiKey:  DocAI2.default)

    var body: some View {        /* GeometryReader { geometry in
            VStack {
                // Welcome text
                Text("Welcome to DocAi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                // Scrollable area for AI response
                ScrollView {
                    VStack(alignment: .leading) {
                        if !chatbotResponse.isEmpty {
                            Text(chatbotResponse)
                                .font(.body)
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                        }

                        if isLoading {
                            ProgressView("Fetching AI response...")
                                .padding(.top, 10)
                        }
                    }
                }
                .frame(maxHeight: geometry.size.height * 0.7) // Limit the scrollable response area

                Spacer()

                // Input field and submit button fixed at the bottom
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.customBlue, lineWidth: 1)
                            .foregroundColor(Color.black)
                            .shadow(radius: 2)
                            
                        TextField("What health issues are you facing?", text: $chat)
                            .font(.custom("Inter", size: 15))
                            .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59))
                            .padding(.leading, 15)
                            .padding(.vertical, 10)
                    }
                    .frame(height: 50)

                    Button(action: {
                        sendPromptToChatGPT(prompt: chat)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10) // Rounded background for the button
                                .fill(Color.customBlue) // Custom blue color fill
                                .frame(width: 50, height: 50) // Square frame for the button
                                .shadow(radius: 5) // Shadow for depth

                            Image(systemName: "paperplane.fill") // Changed to "paperplane.fill" for a filled icon
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25) // Icon size
                                .foregroundColor(.white) // White icon color
                        }
                    }
                    .padding(.leading, 10)

                }
                .padding(.horizontal, 20)
                .padding(.bottom, 45) // Padding at the bottom of the screen
            }
            .edgesIgnoringSafeArea(.bottom) // Ensure the HStack doesn't go behind the safe area on iPhones
            .sheet(isPresented: $isSuggestionsSheetVisible) {
                RecipeDisplayPage(chatbotResponse: chatbotResponse)
            }
        }*/
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color.white) // Light gray background
                    .shadow(radius: 2) // Shadow
                
                TextField("What issues are you facing", text: $chat)
                    .font(.custom("Inter", size: 15))
                    .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59)) // Text color
                    .padding(.leading, 23)
                    .padding(.trailing, 0)
                    .padding(.vertical, 10) // Add padding vertically
            }
            .frame(height: 50) // Adjust height
            
            Button(action: {
                sendPromptToChatGPT(prompt: chat)
            }) {
                Image(systemName: "paperplane.circle.fill") // Use system image for consistency
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .padding(.trailing, 10)
                    .foregroundColor(.blue) // Button color
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top,-10)
        .padding(.horizontal, 20) // Add horizontal padding
        .sheet(isPresented: $isSuggestionsSheetVisible) {
            RecipeDisplayPage(chatbotResponse: chatbotResponse)
        }
    }

    // Function to send the prompt to ChatGPT
    private func sendPromptToChatGPT(prompt: String) {
        isLoading = true
        isSuggestionsSheetVisible = false

        let prompt = chat + "\nYou are my personalized AI doctor, here to provide comprehensive guidance for my health concerns. As my AI doctor, your primary role is to suggest which department to visit at Infyhealth hospital based on my symptoms. Please ensure to provide a detailed response with appropriate spacing to make it easier for me to read and understand."

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [["role": "user", "content": prompt]]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                isLoading = false
            }

            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

                if !decodedResponse.choices.isEmpty {
                    let chatbotResponse = decodedResponse.choices[0].message.content
                    DispatchQueue.main.async {
                        self.chatbotResponse = chatbotResponse
                        self.isSuggestionsSheetVisible = true
                    }
                } else {
                    print("Empty response choices")
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }.resume()
    }
}

struct RecipeDisplayPage: View {
    var chatbotResponse: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("DocAi")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 20)

                ForEach(chatbotResponse.components(separatedBy: "\n"), id: \.self) { step in
                    if !step.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        RecipeStepView(step: step)
                            .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("DocBot", displayMode: .inline)
    }
}

struct RecipeStepView: View {
    var step: String

    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 10))
                .padding(.trailing, 5)

            Text(step)
                .font(.body)
                .foregroundColor(.black)

            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct Choice: Codable {
    let text: String
}

struct ChatGPTResponse: Decodable {
    let choices: [ChatGPTChoice]
}

struct ChatGPTChoice: Decodable {
    let message: ChatGPTMessage
}

struct ChatGPTMessage: Decodable {
    let role: String
    let content: String
}

struct ChatGPTErrorResponse: Decodable {
    let error: ChatGPTError
}

struct ChatGPTError: Decodable {
    let message: String
    let type: String
    let param: String?
    let code: String
}

//#Preview(body: WelcomeDocAiView)
