import SwiftUI

// MARK: - Placeholder Views

struct AccoladesView: View {
    var body: some View {
        Text("Personal Accolades")
            .font(.largeTitle)
            .padding()
    }
}

struct PublicServerView: View {
    var body: some View {
        Text("Public Server")
            .font(.largeTitle)
            .padding()
    }
}

struct ComingSoonView: View {
    var body: some View {
        Text("Coming Soon")
            .font(.largeTitle)
            .padding()
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.largeTitle)
            .padding()
    }
}

// MARK: - Main ContentView

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MainDashboardView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            GameListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Games")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(.black)
    }
}

// MARK: - Main Dashboard

struct MainDashboardView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 24) {
                // Top Bar
                HStack {
                    Text("Par6")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.leading)
                    Spacer()
                    Text("Wordle Golf")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.green)
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                            .padding(.trailing)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 12)
                .background(Color.white)
                
                // Quadrants as floating putting greens (now buttons)
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        NavigationLink(destination: AccoladesView()) {
                            PuttingGreenBox {
                                VStack {
                                    Text("Personal Accolades")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("🏆 Games Won: 0")
                                        .foregroundColor(.white)
                                    Text("⛳ Best Score: -")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                        NavigationLink(destination: ScorecardView()) {
                            PuttingGreenBox {
                                VStack {
                                    Text("Current Scorecards")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("Tap to add today's score")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    HStack(spacing: 20) {
                        NavigationLink(destination: PublicServerView()) {
                            PuttingGreenBox {
                                VStack {
                                    Text("Public Server")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("Join a public game!")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                        NavigationLink(destination: ComingSoonView()) {
                            PuttingGreenBox {
                                VStack {
                                    Text("Coming Soon")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}

// MARK: - Putting Green Box

struct PuttingGreenBox<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.8), Color("PuttingGreenDark", bundle: nil)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.green.opacity(0.3), radius: 10, x: 0, y: 6)
            content
                .padding()
        }
        .frame(width: 160, height: 160)
    }
}

// MARK: - Scorecard Model

struct DailyScore: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let score: Int
}

struct PlayerScore: Identifiable, Codable {
    var id = UUID()
    var userID: String
    var playerName: String
    var scores: [DailyScore]
}

struct Game: Identifiable, Codable {
    var id = UUID()
    var startDate: Date
    var players: [PlayerScore]
}

// MARK: - MultiPlayerScorecardStore

class MultiPlayerScorecardStore: ObservableObject {
    @Published var currentGame: Game?
    private let key = "current_golf_game"

    init() {
        load()
    }

    func startNewGame(startDate: Date, playerInfos: [(userID: String, name: String)]) {
        let players = playerInfos.map { PlayerScore(userID: $0.userID, playerName: $0.name, scores: []) }
        currentGame = Game(startDate: startDate, players: players)
        save()
    }

    func startNewGame(startDate: Date, playerNames: [String]) {
        let players = playerNames.map { name in
            let userID = (name == "Your Name") ? myUserID : UUID().uuidString
            return PlayerScore(userID: userID, playerName: name, scores: [])
        }
        currentGame = Game(startDate: startDate, players: players)
        save()
    }

    func addPlayer(userID: String, name: String) {
        guard var game = currentGame else { return }
        if !game.players.contains(where: { $0.userID == userID }) {
            game.players.append(PlayerScore(userID: userID, playerName: name, scores: []))
            currentGame = game
            save()
        }
    }

    func addScore(for userID: String, date: Date, score: Int) {
        guard var game = currentGame,
              let idx = game.players.firstIndex(where: { $0.userID == userID }) else { return }
        game.players[idx].scores.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        game.players[idx].scores.append(DailyScore(date: date, score: score))
        game.players[idx].scores.sort { $0.date < $1.date }
        currentGame = game
        save()
    }

    func scoreExists(for player: String, date: Date) -> Bool {
        guard let game = currentGame,
              let idx = game.players.firstIndex(where: { $0.playerName == player }) else { return false }
        return game.players[idx].scores.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func overwriteScore(for player: String, date: Date, score: Int) {
        guard var game = currentGame,
              let idx = game.players.firstIndex(where: { $0.playerName == player }) else { return }
        game.players[idx].scores.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        game.players[idx].scores.append(DailyScore(date: date, score: score))
        game.players[idx].scores.sort { $0.date < $1.date }
        currentGame = game
        save()
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Game.self, from: data) {
            currentGame = decoded
        }
    }

    func save() {
        if let game = currentGame,
           let data = try? JSONEncoder().encode(game) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - Scorecard View

struct ScorecardView: View {
    @StateObject private var store = MultiPlayerScorecardStore()
    @AppStorage("myUsername") private var myUsername: String = ""
    @State private var showUsernameSheet = false
    @State private var selectedPlayer: String = ""
    @State private var shareText = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var pendingScore: Int?
    @State private var pendingDate: Date?
    @State private var pendingPlayer: String?
    @State private var showOverwriteAlert = false
    @State private var showNewGameSheet = false
    @State private var newPlayerNames = ""

    var body: some View {
        VStack(spacing: 16) {
            if let game = store.currentGame {
                let holeDates = holeDates(for: game)
                // Scorecard Table
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Date").bold().frame(width: 90)
                            ForEach(holeDates, id: \.self) { date in
                                Text(shortDate(date))
                                    .frame(width: 60)
                                    .font(.caption)
                            }
                        }
                        ForEach(game.players) { player in
                            HStack {
                                Text(player.userID) // Show userID instead of playerName
                                    .bold()
                                    .foregroundColor(player.userID == myUserID ? .blue : .primary)
                                ForEach(holeDates, id: \.self) { date in
                                    if let score = player.scores.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                                        Text(scoreString(score.score))
                                            .frame(width: 60)
                                            .font(.headline)
                                    } else {
                                        Text("-")
                                            .frame(width: 60)
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                Divider().padding(.vertical, 8)

                Text("Paste your NYT Games share string below to update a scorecard:")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Picker("", selection: $selectedPlayer) {
                    ForEach(game.players.map { $0.userID }, id: \.self) { userID in
                        Text(userID).tag(userID)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal)

                TextEditor(text: $shareText)
                    .frame(height: 80)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .cornerRadius(8)
                    .padding(.horizontal)

                Button("Upload Score") {
                    guard !selectedPlayer.isEmpty else {
                        alertMessage = "Please select a player first."
                        showingAlert = true
                        return
                    }
                    if let (score, date) = parseNYTShareString(shareText) {
                        if store.scoreExists(for: selectedPlayer, date: date) {
                            pendingScore = score
                            pendingDate = date
                            pendingPlayer = selectedPlayer
                            showOverwriteAlert = true
                        } else {
                            store.addScore(for: myUsername, date: date, score: score)
                            alertMessage = "Scorecard updated!"
                            showingAlert = true
                        }
                    } else {
                        alertMessage = "Could not parse the NYT Games share string. Please check your input."
                        showingAlert = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.bottom)

                // Show winner if all players have 18 scores
                if game.players.allSatisfy({ $0.scores.count == 18 }) {
                    let winner = game.players.min(by: { $0.scores.map(\.score).reduce(0, +) < $1.scores.map(\.score).reduce(0, +) })
                    if let winner = winner {
                        Text("🏆 Winner: \(winner.playerName) (\(winner.scores.map(\.score).reduce(0, +)))")
                            .font(.title2)
                            .foregroundColor(.green)
                            .padding(.top)
                    }
                }
            }
        }
        .onAppear {
            if myUsername.isEmpty {
                showUsernameSheet = true
            }
            if store.currentGame == nil {
                showNewGameSheet = true
            }
        }
        .sheet(isPresented: $showUsernameSheet) {
            VStack(spacing: 24) {
                Text("Enter Your Username")
                    .font(.title)
                TextField("Username", text: $myUsername)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button("Save") {
                    if !myUsername.trimmingCharacters(in: .whitespaces).isEmpty {
                        showUsernameSheet = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(myUsername.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
        .sheet(isPresented: $showNewGameSheet, onDismiss: {
            if store.currentGame == nil {
                showNewGameSheet = true
            }
        }) {
            VStack(spacing: 24) {
                Text("Start a New Game")
                    .font(.title)
                Text("Enter user IDs separated by commas:")
                TextField("e.g. 12345, 67890, abcde", text: $newPlayerNames)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button("Start Game") {
                    let ids = newPlayerNames
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    if !ids.isEmpty {
                        // Use myUsername for this device, others as entered
                        let playerInfos = ids.map { id in
                            (userID: id == myUsername ? myUsername : id, name: id)
                        }
                        store.startNewGame(startDate: Date(), playerInfos: playerInfos)
                        selectedPlayer = myUsername
                        showNewGameSheet = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding()
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Overwrite score for this date?", isPresented: $showOverwriteAlert) {
            Button("Overwrite", role: .destructive) {
                if let score = pendingScore, let date = pendingDate, let player = pendingPlayer {
                    store.overwriteScore(for: player, date: date, score: score)
                    alertMessage = "Score overwritten!"
                    showingAlert = true
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("A score for this date already exists for this player. Do you want to overwrite it?")
        }
        .padding()
    }

    func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    func scoreString(_ score: Int) -> String {
        if score > 0 { return "+\(score)" }
        if score == 0 { return "E" }
        return "\(score)"
    }

    /// Returns (golf score, date) from NYT share string
    func parseNYTShareString(_ text: String) -> (Int, Date)? {
        // Updated regex to allow for commas in the puzzle number
        let pattern = #"Wordle (\d{1,3}(?:,\d{3})*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let puzzleRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        // Remove commas before converting to Int
        let puzzleNumberString = text[puzzleRange].replacingOccurrences(of: ",", with: "")
        guard let puzzleNumber = Int(puzzleNumberString) else {
            return nil
        }
        // Use the extension for the base date at noon UTC
        let calendar = Calendar(identifier: .gregorian)
        guard let baseDate = calendar.dateAtNoonUTC(year: 2021, month: 6, day: 20) else {
            return nil
        }
        // Add (puzzleNumber - 1) days
        guard let puzzleDate = calendar.date(byAdding: .day, value: puzzleNumber - 1, to: baseDate) else {
            return nil
        }
        // Parse the score
        let lines = text
            .components(separatedBy: .newlines)
            .filter { $0.filter { $0 == "🟩" || $0 == "🟨" || $0 == "⬛" || $0 == "⬜" }.count == 5 }
        for (index, line) in lines.enumerated() {
            if line.filter({ $0 == "🟩" }).count == 5 {
                let golfScore = (index + 1) - 4
                return (golfScore, puzzleDate)
            }
        }
        return nil
    }
}

// MARK: - Date Extensions

extension Date {
    func atNoonUTC() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let comps = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: comps.day, hour: 12))!
    }
}

extension Calendar {
    func dateAtNoonUTC(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 12 // prevents timezone drift
        components.minute = 0
        components.second = 0
        var cal = self
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal.date(from: components)
    }
}

// MARK: - Placeholder Views for Tabs

let myUserID: String = {
    if let id = UserDefaults.standard.string(forKey: "myUserID") {
        return id
    } else {
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: "myUserID")
        return newID
    }
}()



func holeDates(for game: Game) -> [Date] {
    (0..<18).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: game.startDate) }
}


