import SwiftUI
import CoreData

struct CharacterCustomizationView: View {
    @ObservedObject var viewModel: CharacterViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var avatarURL: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Character Image")) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Text("Select Image")
                            Spacer()
                            if selectedImage != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Customize Character")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveCharacter()
                }
            )
            .sheet(isPresented: $showingImagePicker) {
                CharacterImagePicker(image: $selectedImage)
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveCharacter() {
        guard !name.isEmpty else {
            alertMessage = "Please enter a name for the character"
            showingAlert = true
            return
        }
        
        // Use the viewModel to create the character
        viewModel.createCharacter(name: name, description: description, avatarURL: avatarURL)
        dismiss()
    }
}

struct CharacterCustomizationView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let viewModel = CharacterViewModel(context: context)
        return CharacterCustomizationView(viewModel: viewModel)
    }
} 