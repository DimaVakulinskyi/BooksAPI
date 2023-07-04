//
//  ContentView.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 03.07.2023.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct BookCell: View {
    let book: Book
    @ObservedObject private var viewModel: ViewModel
    @State private var imageData: Data?
    @State private var isShowingAmazonPage = false
    
    init(book: Book, viewModel: ViewModel) {
        self.book = book
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                Text(verbatim: String(format: NSLocalizedString("publisher_text", comment: ""), book.publisher))
                    .font(.subheadline)
                Text("Rank: \(book.rank)")
                    .font(.subheadline)
                Text("amazon_link_text")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        isShowingAmazonPage = true
                    }
            }
            Spacer()
            if let imageData = imageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                Image(systemName: "book")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }
        }
        .onAppear {
            viewModel.fetchImage(for: book) { data in
                self.imageData = data
            }
        }
        .sheet(isPresented: $isShowingAmazonPage) {
            NavigationView {
                WebView(url: URL(string: book.amazonProductURL)!)
                    .navigationBarItems(trailing: Button("close_button") {
                        isShowingAmazonPage = false
                    })
            }
        }
    }
}
