//
//  TaleWeaverApp.swift
//  TaleWeaver
//
//  Created by Matt Freestone on 4/27/25.
//

import SwiftUI

@main
struct TaleWeaverApp: App {
    let persistenceController = PersistenceController.shared
    
    // Create the view model at the app level
    @StateObject private var viewModel: StoryViewModel
    
    init() {
        let repository = StoryRepository(context: persistenceController.container.viewContext)
        let openAIService = OpenAIService(apiKey: Configuration.openAIAPIKey)
        _viewModel = StateObject(wrappedValue: StoryViewModel(repository: repository, openAIService: openAIService))
    }
    
    var body: some Scene {
        WindowGroup {
            StoryListView(viewModel: viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
