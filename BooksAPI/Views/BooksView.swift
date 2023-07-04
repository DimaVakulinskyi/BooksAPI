//
//  BookView.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 04.07.2023.
//

import SwiftUI

struct BooksView: View {
    @ObservedObject var viewModel: ViewModel
    let category: Category
    
    var body: some View {
        List(viewModel.categoryBooks[category.listNameEncoded] ?? [], id: \.rank) { book in
            BookCell(book: book, viewModel: viewModel)
        }
        .onAppear {
            viewModel.selectedCategory = category
            viewModel.fetchBooksIfNeeded()
        }
        .navigationTitle(category.listName)
    }
}
