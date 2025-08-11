import SwiftUI

struct GameDetailView: View {
    var body: some View {
        VStack {
            Text("Game Details")
                .font(.largeTitle)
                .padding()
            // Add more game detail UI here
            Spacer()
        }
    }
}

struct GameDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GameDetailView()
    }
}