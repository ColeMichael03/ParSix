import SwiftUICore
struct MainDashboardScreen: View {
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Text("Par6")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
                Text("Wordle Golf")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                // Display score (replace with your score variable if needed)
                Text("Score: 0")
                    .font(.subheadline)
                    .padding(.trailing)
                // Placeholder for symmetry
                Text(" ")
                    .padding(.trailing)
            }
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            // Quadrants
            GeometryReader { geometry in
                let halfWidth = geometry.size.width / 2
                let halfHeight = geometry.size.height / 2
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Top Left: Personal Accolades
                        VStack {
                            Text("Personal Accolades")
                                .font(.headline)
                                .padding(.top)
                            Spacer()
                            // Add your accolades UI here
                            Text("🏆 Games Won: 0")
                            Text("⛳ Best Score: -")
                            Spacer()
                        }
                        .frame(width: halfWidth, height: halfHeight)
                        .background(Color(.systemGray5))
                        
                        // Top Right: Current Scorecards
                        VStack {
                            Text("Current Scorecards")
                                .font(.headline)
                                .padding(.top)
                            Spacer()
                            // Add your scorecard UI here
                            Text("No games yet")
                            Spacer()
                        }
                        .frame(width: halfWidth, height: halfHeight)
                        .background(Color(.systemGray4))
                    }
                    
                    HStack(spacing: 0) {
                        // Bottom Left: Public Server
                        VStack {
                            Text("Public Server")
                                .font(.headline)
                                .padding(.top)
                            Spacer()
                            // Add your public server UI here
                            Text("Join a public game!")
                            Spacer()
                        }
                        .frame(width: halfWidth, height: halfHeight)
                        .background(Color(.systemGray3))
                        
                        // Bottom Right: Placeholder
                        VStack {
                            Text("Coming Soon")
                                .font(.headline)
                                .padding(.top)
                            Spacer()
                        }
                        .frame(width: halfWidth, height: halfHeight)
                        .background(Color(.systemGray2))
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
