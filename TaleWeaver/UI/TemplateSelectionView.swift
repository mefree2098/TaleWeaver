import SwiftUI
import CoreData

struct TemplateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TemplateViewModel
    let onTemplateSelected: (StoryTemplate) -> Void
    
    @State private var searchText = ""
    // When this optional is non-nil SwiftUI will present the preview sheet.
    @State private var selectedTemplate: StoryTemplate?
    
    var filteredTemplates: [StoryTemplate] {
        if searchText.isEmpty {
            return viewModel.templates
        } else {
            return viewModel.templates.filter { template in
                template.name?.localizedCaseInsensitiveContains(searchText) == true ||
                template.templateDescription?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredTemplates) { template in
                    TemplateCard(template: template)
                        .onTapGesture {
                            // Present sheet by assigning the tapped template.
                            selectedTemplate = template
                        }
                }
            }
            .searchable(text: $searchText, prompt: "Search templates")
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Present a sheet whenever selectedTemplate is non-nil.
            .sheet(item: $selectedTemplate) { template in
                TemplatePreviewView(template: template) { chosen in
                    onTemplateSelected(chosen)
                    // Dismiss both the preview and this selection view.
                    dismiss()
                }
            }
        }
    }
}

struct TemplateCard: View {
    let template: StoryTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(template.name ?? "")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(template.templateDescription ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                Text("Template")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Template: \(template.name ?? "")")
        .accessibilityHint(template.templateDescription ?? "")
    }
}

struct TemplatePreviewView: View {
    let template: StoryTemplate
    let onSelect: (StoryTemplate) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var generatedPrompt: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(template.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(template.templateDescription ?? "")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("Example Prompt")
                        .font(.headline)
                    
                    Text(template.promptTemplate ?? "")
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    if !generatedPrompt.isEmpty {
                        Divider()
                        
                        Text("Generated Example")
                            .font(.headline)
                        
                        Text(generatedPrompt)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Template Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use Template") {
                        onSelect(template)
                    }
                }
            }
            .onAppear {
                // Generate an example prompt
                let tempVM = TemplateViewModel(context: PersistenceController.shared.container.viewContext)
                generatedPrompt = tempVM.generatePrompt(from: template, context: [:])
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = TemplateViewModel(context: context)
    
    return TemplateSelectionView(viewModel: viewModel) { _ in }
        .environment(\.managedObjectContext, context)
} 