import SwiftUI
import CoreData

struct UserCharacterEditorViewNew: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CharacterViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var avatarURL = ""
    @State private var showingImagePicker = false
    @State private var showingFullScreenImage = false
    @State private var selectedImage: UIImage?
    @State private var isGeneratingAvatar = false
    
    var character: Character?
    
    init(character: Character? = nil) {
        self.character = character
        _viewModel = StateObject(wrappedValue: CharacterViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Character Details")) {
                    TextField("Name", text: $name)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Avatar")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .onTapGesture {
                                showingFullScreenImage = true
                            }
                    } else if !avatarURL.isEmpty {
                        AsyncImage(url: URLUtils.createURL(from: avatarURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .onTapGesture {
                                        showingFullScreenImage = true
                                    }
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    HStack {
                        Button("Select Image") {
                            showingImagePicker = true
                        }
                        
                        Spacer()
                        
                        Button("Generate Avatar") {
                            generateAvatar()
                        }
                        .disabled(isGeneratingAvatar)
                    }
                }
            }
            .navigationTitle(character == nil ? "New Character" : "Edit Character")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCharacter()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .sheet(isPresented: $showingFullScreenImage) {
                if let url = URL(string: avatarURL) {
                    FullScreenImageView(imageURL: url)
                }
            }
            .onAppear {
                if let character = character {
                    name = character.name ?? ""
                    description = character.characterDescription ?? ""
                    avatarURL = character.avatarURL ?? ""
                }
            }
        }
    }
    
    private func generateAvatar() {
        isGeneratingAvatar = true
        Task {
            do {
                let characterId = character?.id?.uuidString ?? UUID().uuidString
                let url = try await OpenAIService.shared.generateCharacterAvatar(
                    description: description,
                    characterId: characterId
                )
                await MainActor.run {
                    avatarURL = url
                    isGeneratingAvatar = false
                }
            } catch {
                print("Error generating avatar: \(error)")
                isGeneratingAvatar = false
            }
        }
    }
    
    private func saveCharacter() {
        if let character = character {
            character.name = name
            character.characterDescription = description
            character.avatarURL = avatarURL
            character.isUserCharacter = true
        } else {
            let newCharacter = Character(context: viewContext)
            newCharacter.id = UUID()
            newCharacter.name = name
            newCharacter.characterDescription = description
            newCharacter.avatarURL = avatarURL
            newCharacter.isUserCharacter = true
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving character: \(error)")
        }
    }
} 