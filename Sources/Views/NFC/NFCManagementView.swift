import SwiftUI

struct NFCManagementView: View {
    @EnvironmentObject var app: AppState
    @State private var nickname: String = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(app.tags) { tag in
                        VStack(alignment: .leading) {
                            Text(tag.nickname)
                            Text(tag.uid).font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .onDelete { idx in
                        app.tags.remove(atOffsets: idx)
                        app.saveAll()
                    }
                }
                HStack {
                    TextField("Nickname", text: $nickname).textFieldStyle(.roundedBorder)
                    Button("Add NFC Chip") {
                        // In MVP scaffold, create a mock UID so the UI flows
                        let uid = UUID().uuidString.prefix(8)
                        app.tags.append(NFCTag(nickname: nickname.isEmpty ? "Tag" : nickname, uid: String(uid)))
                        nickname = ""
                        app.saveAll()
                    }
                }.padding()
            }
            .navigationTitle("NFC Chips")
        }
    }
}