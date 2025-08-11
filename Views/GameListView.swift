import SwiftUI

struct GameListView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: GameDetailView()) {
                    Text("Today's Wordle Golf")
                }
                NavigationLink(destination: GameDetailView()) {
                    Text("Yesterday's Wordle Golf")
                }
            }
            .navigationTitle("Games")
        }
    }
}

struct GameListView_Previews: PreviewProvider {
    static var previews: some View {
        GameListView()
    }
}