//
//  ContentView.swift
//  TaleWeaver
//
//  Created by Matt Freestone on 4/27/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let persistenceController = PersistenceController.shared
    
    // Create the view model
    @StateObject private var viewModel: StoryViewModel
    
    init() {
        let repository = StoryRepository(context: persistenceController.container.viewContext)
        let openAIService = OpenAIService(apiKey: Configuration.openAIAPIKey)
        _viewModel = StateObject(wrappedValue: StoryViewModel(repository: repository, openAIService: openAIService))
    }
    
    var body: some View {
        StoryListView(viewModel: viewModel)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}

#Preview {
    ContentView()
}
