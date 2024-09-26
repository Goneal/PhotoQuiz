//
//  ContentView.swift
//  Quiz App
//
//  Created by Geovani Oneal on 8/10/24.
//

import SwiftUI
import AVFoundation

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var gameManager = GameManager()

    var body: some View {
        NavigationView {
            LandingPage()
        }
        .environmentObject(gameManager)
    }
}

// MARK: - Landing Page
struct LandingPage: View {
    @State private var showSettings = false
    @State private var logoOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                Color.black.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: geometry.size.height * 0.05) {
                    Image("PhotoQuiz-Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                        .offset(y: logoOffset)

                    NavigationLink(destination: GameIndex()) {
                        Text("Start")
                            .padding(20)
                            .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.08)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(25)
                    }

                    Button("Settings") {
                        showSettings = true
                    }
                    .padding(20)
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.08)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(25)

                    Spacer()
                }
                .padding(.bottom, geometry.size.height * 0.05)
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("difficulty") private var difficulty = "Medium"
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("gameLockEnabled") private var gameLockEnabled = true
    @AppStorage("hintsEnabled") private var hintsEnabled = true
    @AppStorage("timerEnabled") private var timerEnabled = true
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        NavigationView {
            Form {
                Picker("Difficulty", selection: $difficulty) {
                    Text("Easy").tag("Easy")
                    Text("Medium").tag("Medium")
                    Text("Hard").tag("Hard")
                }

                Toggle("Sound Effects", isOn: $soundEnabled)
                Toggle("Lock Games", isOn: $gameLockEnabled)
                    .onChange(of: gameLockEnabled) { newValue in
                        gameManager.setGameLock(enabled: newValue)
                    }

                Toggle("Enable Hints", isOn: $hintsEnabled)
                Toggle("Enable Timer", isOn: $timerEnabled)
            }
            .navigationTitle("Settings")
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            gameManager.gameLockEnabled = gameLockEnabled
        }
    }
}

// MARK: - Game Index
struct GameIndex: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showSettings = false
    @State private var selectedGame: Game?

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                List {
                    ForEach(gameManager.games) { game in
                        NavigationLink(destination: QuizGame(game: game)) {
                            GameRowView(game: game)
                        }
                        .disabled(gameManager.gameLockEnabled && !game.isUnlocked)
                        .listRowBackground(Color.clear)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .background(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                           startPoint: .top,
                                           endPoint: .bottom))
            }
        }
        .navigationTitle("Quiz Games")
        .navigationBarItems(trailing: Button(action: {
            showSettings = true
        }) {
            Image(systemName: "gear")
                .foregroundColor(.black)
        })
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - Game Row View
struct GameRowView: View {
    @EnvironmentObject var gameManager: GameManager
    let game: Game

    var body: some View {
        HStack {
            Image(game.thumbnail)
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(game.name)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(game.description)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
            }

            Spacer()

            VStack {
                if gameManager.gameLockEnabled && !game.isUnlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.black.opacity(0.7))
                } else {
                    Text("High: \(gameManager.highScores[game.name] ?? 0)")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                ProgressView(value: Float(game.progress), total: 100)
                    .frame(width: 50)
                    .accentColor(.green)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Game Manager
class GameManager: ObservableObject {
    @Published var games: [Game]
    @Published var highScores: [String: Int] = [:]
    @Published var gameLockEnabled: Bool = true
    @Published var hintToggleEnabled: Bool = true
    var hintEnabled = true

    init() {
        self.gameLockEnabled = UserDefaults.standard.bool(forKey: "gameLockEnabled")

        self.games = [
            Game(name: "Animal Quiz",
                 description: "Identify animals",
                 thumbnail: "icons8-lion-96",
                 isUnlocked: true,
                 progress: 0,
                 easyQuestions: [
                    Question(
                        text: "Which image shows a dog?",
                        options: [
                            AnswerOption(name: "Dog", imageName: "pexels-valeriya-1805164"),
                            AnswerOption(name: "Cat", imageName: "pexels-kowalievska-1170986"),
                            AnswerOption(name: "Elephant", imageName: "pexels-pixabay-66898"),
                            AnswerOption(name: "Lion", imageName: "pexels-gareth-davies-230510-1598377")
                        ],
                        correctAnswerIndex: 0,
                        hint: "It's often called man's best friend"
                    )
                 ],
                 mediumQuestions: [],
                 hardQuestions: []),

            Game(name: "Landmark Quiz",
                 description: "Name landmarks",
                 thumbnail: "icons8-building-100",
                 isUnlocked: false,
                 progress: 0,
                 easyQuestions: [
                    Question(
                        text: "Which image shows the Eiffel Tower?",
                        options: [
                            AnswerOption(name: "Eiffel Tower", imageName: "pexels-42north-1287827"),
                            AnswerOption(name: "Big Ben", imageName: "pexels-danielbendig-912897"),
                            AnswerOption(name: "Tower of Tokyo", imageName: "pexels-berk-ozdemir-1761205-3779837")
                        ],
                        correctAnswerIndex: 0,
                        hint: "It's in Paris"
                    )
                 ],
                 mediumQuestions: [],
                 hardQuestions: []),

            Game(name: "Food Quiz",
                 description: "Name Foods",
                 thumbnail: "icons8-pizza-96",
                 isUnlocked: false,
                 progress: 0,
                 easyQuestions: [
                    Question(
                        text: "Which image shows Pizza Pie?",
                        options: [
                            AnswerOption(name: "Burger", imageName: "pexels-valeriya-1199957"),
                            AnswerOption(name: "Pizza", imageName: "pexels-vince-2147491"),
                            AnswerOption(name: "Sushi", imageName: "pexels-valeriya-1148086")
                        ],
                        correctAnswerIndex: 1,
                        hint: "It uses tomato sauce"
                    )
                 ],
                 mediumQuestions: [],
                 hardQuestions: [])
        ]

        self.setGameLock(enabled: self.gameLockEnabled)

        Task {
            await preloadImages()
        }
    }

    private func preloadImages() async {
        await withTaskGroup(of: Void.self) { group in
            for game in games {
                for question in game.easyQuestions + game.mediumQuestions + game.hardQuestions {
                    for option in question.options {
                        group.addTask {
                            if let image = UIImage(named: option.imageName) {
                                await ImageCache.shared.setImage(image, forKey: option.imageName)
                            }
                        }
                    }
                }
            }
        }
    }

    func setGameLock(enabled: Bool) {
        gameLockEnabled = enabled
        if !enabled {
            for i in 0..<games.count {
                games[i].isUnlocked = true
            }
        } else {
            games[0].isUnlocked = true
            for i in 1..<games.count {
                games[i].isUnlocked = games[i-1].progress >= 50
            }
        }
        objectWillChange.send()
    }

    func setHintToggle(enabled: Bool) {
        hintToggleEnabled = enabled
        if !enabled {
        } else {
            games[0].isUnlocked = true
            for i in 1..<games.count {
                games[i].isUnlocked = games[i-1].progress >= 50
            }
        }
        objectWillChange.send()
    }

    func updateHighScore(for game: String, score: Int) {
        highScores[game] = max(highScores[game] ?? 0, score)
    }

    func updateProgress(for gameName: String, score: Int) {
        if let index = games.firstIndex(where: { $0.name == gameName }) {
            games[index].progress = min(games[index].progress + score * 5, 100)
        }
        if gameLockEnabled {
            checkUnlocks()
        }
    }

    func checkUnlocks() {
        for i in 1..<games.count {
            if games[i-1].progress >= 50 {
                games[i].isUnlocked = true
            }
        }
    }
}

// MARK: - Game Model
struct Game: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let thumbnail: String
    var isUnlocked: Bool
    var progress: Int = 0
    let easyQuestions: [Question]
    let mediumQuestions: [Question]
    let hardQuestions: [Question]
}

// MARK: - Question Model
struct Question {
    let text: String
    let options: [AnswerOption]
    let correctAnswerIndex: Int
    let hint: String
}

// MARK: - Answer Option Model
struct AnswerOption: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
}

// MARK: Quiz Game Operations
struct QuizGame: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("difficulty") private var difficulty = "Medium"
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hintsEnabled") private var hintsEnabled = true

    let game: Game
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var isCorrect = false
    @State private var timeRemaining = 15
    @State private var timer: Timer?
    @State private var showHint = false
    @State private var selectedAnswer: Int?
    @State private var hintsEnabledForGame: Bool
    @State private var audioPlayer: AVAudioPlayer?
    @AppStorage("timerEnabled") private var timerEnabled = true

    init(game: Game) {
        self.game = game
        _hintsEnabledForGame = State(initialValue: UserDefaults.standard.bool(forKey: "hintsEnabled"))

        if let soundURL = Bundle.main.url(forResource: "wrong_answer", withExtension: "mp3") {
            do {
                _audioPlayer = State(initialValue: try AVAudioPlayer(contentsOf: soundURL))
            } catch {
                print("Failed to initialize audio player: \(error)")
            }
        }
    }

    var questions: [Question] {
        switch difficulty {
        case "Easy": return game.easyQuestions
        case "Hard": return game.hardQuestions
        default: return game.mediumQuestions
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    GameNameText(text: game.name)
                        .padding(.top)

                    if currentQuestion < questions.count {
                        Text(questions[currentQuestion].text)
                            .font(.headline)
                            .padding()

                        let gridItemSize = calculateGridItemSize(for: geometry)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: gridItemSize.width ), spacing: -70)], spacing: 15) {
                            ForEach(questions[currentQuestion].options.indices, id: \.self) { index in
                                Button(action: { checkAnswer(index) }) {
                                    Image(questions[currentQuestion].options[index].imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: gridItemSize.width - 100 , height: gridItemSize.height - 150 )
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(borderColor(for: index), lineWidth: 4)
                                        )
                                }
                                .disabled(showFeedback)
                            }
                        }
                        .padding(.horizontal)
                        .shadow(color: .gray, radius: 4, x: 2, y: 5)
                        .cornerRadius(25)

                        VStack {
                            HStack {
                                HStack {
                                    Text("")
                                    Spacer()
                                    Toggle("", isOn: $hintsEnabledForGame)
                                        .labelsHidden()
                                }
                                .frame(width: 150)

                                Button("Show Hint") {
                                    showHint = true
                                }

                                if hintsEnabledForGame && !showFeedback {

                                } else {
                                    Button("") {
                                        showHint = true
                                    }
                                    .disabled(showHint)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)

                            if showHint && hintsEnabledForGame {
                                Text(questions[currentQuestion].hint)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .transition(.opacity)
                            }
                        }
                        .frame(height: 80)

                        if showFeedback {
                            Text(feedbackMessage)
                                .foregroundColor(isCorrect ? .green : .red)
                                .padding()
                                .transition(.scale)

                            Button("Next Question") {
                                withAnimation {
                                    nextQuestion()
                                }
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    } else {
                        gameOver
                    }

                    Text("Score: \(score)")
                        .font(.system(size: 34))
                        .padding()

                    if timerEnabled {
                        Text("Time: \(timeRemaining)")
                            .font(.caption)
                            .foregroundColor(timeRemaining < 5 ? .red : .primary)
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: startGame)
        .onDisappear(perform: endGame)
        .background(Color(hex: 0xfcd200))
    }

    var gameOver: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 330, height: 250)
                .cornerRadius(18)

            VStack {
                Text("Game Over!")
                Text("Your score: \(score)/\(questions.count)")

                if score > (gameManager.highScores[game.name] ?? 0) {
                    Text("New High Score!")
                        .foregroundColor(.green)
                        .font(.custom("", size: 12))
                }

                Button("Play Again") {
                    withAnimation {
                        startGame()
                    }
                }
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Back to Games") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
            .padding(120)
        }
    }

    func borderColor(for index: Int) -> Color {
        if showFeedback {
            if index == questions[currentQuestion].correctAnswerIndex {
                return .green
            } else if index == selectedAnswer {
                return .red
            }
        }
        return .clear
    }

    func startGame() {
        currentQuestion = 0
        score = 0
        startTimer()
    }

    func endGame() {
        timer?.invalidate()
        gameManager.updateHighScore(for: game.name, score: score)
        gameManager.updateProgress(for: game.name, score: score)
    }

    func startTimer() {
        if timerEnabled {
            timeRemaining = 15
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.checkAnswer(nil)
                }
            }
        }
    }

    func checkAnswer(_ selectedIndex: Int?) {
        timer?.invalidate()
        selectedAnswer = selectedIndex
        isCorrect = selectedIndex == questions[currentQuestion].correctAnswerIndex
        if isCorrect {
            score += 1
            feedbackMessage = "Correct!"
        } else {
            feedbackMessage = "Wrong. The correct answer was \(questions[currentQuestion].options[questions[currentQuestion].correctAnswerIndex].name)."
            if soundEnabled {
                playWrongAnswerSound()
            }
        }
        showFeedback = true
    }

    func playWrongAnswerSound() {
        audioPlayer?.play()
    }

    func nextQuestion() {
        currentQuestion += 1
        showFeedback = false
        showHint = false
        selectedAnswer = nil
        if currentQuestion < questions.count {
            startTimer()
        } else {
            endGame()
        }
    }
}

// MARK: - Image Cache
actor ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()

    private init() {
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    func getImage(named: String) -> UIImage? {
        cache.object(forKey: named as NSString)
    }

    func setImage(_ image: UIImage, forKey: String) {
        cache.setObject(image, forKey: forKey as NSString)
    }
}

// MARK: - Cached Image View
struct CachedImage: View {
    let imageName: String
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.gray
            }
        }
        .onAppear {
            Task {
                if let image = await ImageCache.shared.getImage(named: imageName) {
                    self.image = image
                } else if let image = UIImage(named: imageName) {
                    await ImageCache.shared.setImage(image, forKey: imageName)
                    self.image = image
                }
            }
        }
    }
}

//MARK: Custom text style for game names
struct GameNameText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.custom("", size: 32))
            .foregroundColor(.black)
    }
}

// MARK: - Preview of App
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//MARK: Custom Colors
let customYellow = Color(red: 252/255, green: 207/255, blue: 0.0)

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

let customBlue = Color(hex: 0x4A90E2)

extension Color {
    static let customPurple = Color(red: 0.5, green: 0.0, blue: 0.5)
    static let customOrange = Color(hex: 0xFFA500)
}

//MARK: Calculates grid Size
private func calculateGridItemSize(for geometry: GeometryProxy) -> CGSize {
    let width = (geometry.size.width - 60) / 2
    let height = width * (3/2)
    return CGSize(width: width, height: height)
}
