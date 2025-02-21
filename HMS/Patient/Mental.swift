import Foundation
import SwiftUI
import GoogleGenerativeAI

struct MentalHealthSurveyView: View {
    @State private var currentQuestionIndex = 0
    @State private var progress: Float = 0.0
    @State private var answers: [String?] = Array(repeating: nil, count: questions.count)
    @State private var customAnswer: String = "" // For text field input on the first question
    @State private var showAIResponse = false // Flag to show AI response view
    @State private var isGeminiLoading = false
    @State private var surveyStarted = false // New state to control the start of the survey
    @State private var geminiResponse: LocalizedStringKey = "How can I help you?"
   
    
    let model = GenerativeModel(name: "gemini-pro", apiKey: DocAI2.default)
    
    // Questions for the survey
    static let questions = [
        "How have you been feeling emotionally over the past two weeks?",    // General Mood and Emotional State
        "How often have you felt fatigued or low on energy recently?",       // Energy Levels
        "How would you describe your sleep over the past two weeks?",        // Sleep Patterns
        "How frequently have you felt overwhelmed or stressed?",             // Stress Levels
        "Have you been feeling anxious or worried about things?",            // Anxiety and Worry
        "Have you had difficulty concentrating on tasks or felt distracted?",// Concentration and Focus
        "Have you been avoiding social interactions or activities?",         // Social Interaction
        "Have you experienced feelings of hopelessness?",                    // Feelings of Hopelessness
        "Have you been feeling bad about yourself or like a failure?",       // Self-worth
        "Have you had thoughts of harming yourself or others?"               // Thoughts of Self-Harm or Harm to Others
    ]
    
    // Options corresponding to each question
    static let answerOptions: [[String]] = [
        ["Very Good", "Good", "Neutral", "Bad", "Very Bad"],                 // For General Mood
        ["Never", "Rarely", "Sometimes", "Often", "Always"],                 // For Energy Levels
        ["Very Restful", "Somewhat Restful", "Neutral", "Poor", "Very Poor"],// For Sleep Patterns
        ["Never", "Rarely", "Sometimes", "Often", "Always"],                 // For Stress Levels
        ["Never", "Rarely", "Sometimes", "Often", "Always"],                 // For Anxiety
        ["Never", "Rarely", "Sometimes", "Often", "Always"],                 // For Concentration
        ["Never", "Rarely", "Sometimes", "Often", "Always"],                 // For Social Interaction
        ["Never", "Rarely", "Sometimes", "Often", "Always"],                 // For Hopelessness
        ["Never", "Rarely", "Sometimes", "Often", "Always"],                 // For Self-worth
        ["Never", "Rarely", "Sometimes", "Often", "Always"]                  // For Self-Harm
    ]
    
    var body: some View {
        if !surveyStarted {
            // Show the introduction page before the survey starts
            VStack {
                Spacer()
                
                Text("Let's see how you have been feeling lately")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    surveyStarted = true // Start the survey
                }) {
                    Text("Take a Quick Assessment")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.customBlue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        } else if showAIResponse {
            // Show the AI response
            VStack {
                ScrollView {
                    if isGeminiLoading {
                        ZStack {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(2)  // Adjust scale to make it bigger
                                    .padding()
                                
                                Text("Fetching your results...")
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                                    .padding()
                            }
                        }
                        .padding(.top, 250)
                    } else {
                        Text(geminiResponse)
                            .font(.title3)
                            .padding()
                    }
                }
                Spacer()
            }
            .onAppear(perform: generateMentalHealthResponse) // Generate AI response on response view display
        } else {
            // Main Survey View
            VStack {
                // Progress Bar
                ProgressView(value: progress)
                    .tint(.customBlue)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()

                // Current Question
                Text(Self.questions[currentQuestionIndex])
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()

                // First Question: Text Field for custom answer
                if currentQuestionIndex == 0 {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.customBlue, lineWidth: 1)
                            .foregroundColor(Color.white) // Light gray background
                            .shadow(radius: 2) // Shadow
                        
                        TextField("Type your answer here", text: $customAnswer)
                            .font(.custom("Inter", size: 15))
                            .foregroundColor(Color(red: 0.03, green: 0.3, blue: 0.59)) // Text color
                            .padding(.leading, 23)
                            .padding(.trailing, 0)
                            .padding(.vertical, 10) // Add padding vertically
                        
                    }
                    .frame(height: 50)
                } else {
                    // For the remaining questions, display the corresponding answer options as buttons
                    ForEach(Self.answerOptions[currentQuestionIndex], id: \.self) { option in
                        Button(action: {
                            selectAnswer(option)
                        }) {
                            Text(option)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(answers[currentQuestionIndex] == option ? Color.blue.opacity(0.6) : Color.blue.opacity(0.2)) // Change color when selected
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    Button(action: previousQuestion) {
                        Text("Previous")
                            .padding()
//                            .foregroundColor(.customBlue)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .disabled(currentQuestionIndex == 0) // Disable when on the first question
                    
                    Spacer()

                    Button(action: {
                        if currentQuestionIndex == Self.questions.count - 1 {
                            showAIResponse = true // Show AI response on the last question
                        } else {
                            nextQuestion()
                        }
                    }) {
                        Text(currentQuestionIndex == Self.questions.count - 1 ? "Done" : "Next")
                            .padding()
//                            .foregroundColor(.customBlue)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .disabled(shouldDisableNextButton()) // Disable when no answer is provided
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    // Function to handle answer selection for questions 2-10
    private func selectAnswer(_ answer: String) {
        answers[currentQuestionIndex] = answer
        updateProgress()
    }

    private func nextQuestion() {
        if currentQuestionIndex == 0 {
            answers[currentQuestionIndex] = customAnswer.isEmpty ? nil : customAnswer
        }
        
        if let _ = answers[currentQuestionIndex] {
            if currentQuestionIndex < Self.questions.count - 1 {
                currentQuestionIndex += 1
                updateProgress()
            }
        }
    }

    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }

    private func updateProgress() {
        progress = Float(currentQuestionIndex + 1) / Float(Self.questions.count)
    }

    private func shouldDisableNextButton() -> Bool {
        if currentQuestionIndex == 0 {
            return customAnswer.isEmpty
        } else {
            return answers[currentQuestionIndex] == nil
        }
    }
    
    private func generateMentalHealthResponse() {
        isGeminiLoading = true
        geminiResponse = ""
        
        Task {
            do {
                let mentalHealthCondition = inferMentalHealthCondition(from: answers.compactMap { $0 })
                let prompt = "Based on the patient's survey responses: \(mentalHealthCondition). Please provide recommendations for improving their mental health along with a diagnosis which gives them an idea about what stage of their problem they are on along with telling them the respective department they need to visit in the hospital."
                let result = try await model.generateContent(prompt)
                isGeminiLoading = false
                geminiResponse = LocalizedStringKey(result.text ?? "No response found")
            } catch {
                geminiResponse = "Something went wrong\n\(error.localizedDescription)"
                isGeminiLoading = false
            }
        }
    }
    
    private func inferMentalHealthCondition(from answers: [String]) -> String {
        var severeCount = 0
        var moderateCount = 0
        
        for answer in answers {
            if answer == "Very Bad" || answer == "Always" || answer == "Very Poor" {
                severeCount += 1
            } else if answer == "Bad" || answer == "Often" || answer == "Poor" {
                moderateCount += 1
            }
        }
        
        if severeCount > 3 {
            return "The patient shows signs of severe mental health issues."
        } else if moderateCount > 3 {
            return "The patient shows signs of moderate mental health issues."
        } else {
            return "The patient's mental health seems to be in a manageable state."
        }
    }
}

struct MentalHealthSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        MentalHealthSurveyView()
    }
}
