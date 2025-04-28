//
//  StartView.swift
//  TaleWeaver
//
//  Created by Matt Freestone on 4/27/25.
//

import SwiftUI

struct StartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Story.createdAt, ascending: false)],
        animation: .default)
    private var stories: FetchedResults<Story>
    
    @State private var showingNewStorySheet = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Header
                    Text("TaleWeaver")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search stories...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    // Stories list
                    if stories.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No stories yet")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text("Tap the + button to create your first story")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(stories) { story in
                                NavigationLink(destination: Text("Story Detail View")) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(story.title ?? "Untitled")
                                            .font(.headline)
                                        
                                        Text(story.content?.prefix(100) ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                        
                                        HStack {
                                            Text(story.createdAt ?? Date(), style: .date)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            .onDelete(perform: deleteStories)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewStorySheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingNewStorySheet) {
                Text("New Story Sheet")
            }
        }
    }
    
    private func deleteStories(offsets: IndexSet) {
        withAnimation {
            offsets.map { stories[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    StartView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 