import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("openAIAPIKey") private var apiKey: String = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var characterViewModel: CharacterViewModel
    @State private var showingCharacterEditor = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _characterViewModel = StateObject(wrappedValue: CharacterViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    SecureField("OpenAI API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Character Customization")) {
                    NavigationLink(destination: CharacterListView(viewModel: characterViewModel)) {
                        Label("Manage Characters", systemImage: "person.2")
                    }
                    
                    Button(action: { showingCharacterEditor = true }) {
                        Label("Create New Character", systemImage: "person.badge.plus")
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCharacterEditor) {
                CharacterEditorView(viewModel: characterViewModel)
            }
        }
    }
}

#Preview {
    SettingsView()
} 