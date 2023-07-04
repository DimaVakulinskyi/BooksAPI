//
//  ContentView.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 03.07.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.categories, id: \.listName) { category in
                NavigationLink(destination: BooksView(viewModel: viewModel, category: category)) {
                    Text(category.listName)
                }
            }
            .onAppear {
                viewModel.loadCategoriesFromCoreData()
            }
            .navigationTitle(Text(LocalizedStringKey("categories_text")))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
