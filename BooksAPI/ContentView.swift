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
            List(viewModel.categories.indices, id: \.self) { index in
                Text(viewModel.categories[index].listName)
            }
            .onAppear {
                viewModel.loadCategoriesFromCoreData()
            }
            .navigationTitle("Categories")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
