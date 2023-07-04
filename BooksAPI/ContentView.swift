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
            .navigationTitle("Categories")
        }
    }
}

struct BooksView: View {
    @ObservedObject var viewModel: ViewModel
    let category: Category

    var body: some View {
        List(viewModel.categoryBooks[category.listNameEncoded] ?? [], id: \.rank) { book in
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
            }
        }
        .onAppear {
            viewModel.selectedCategory = category
            viewModel.fetchBooksIfNeeded()
        }
        .navigationTitle(category.listName)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
