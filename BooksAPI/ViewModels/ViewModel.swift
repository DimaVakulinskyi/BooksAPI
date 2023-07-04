//
//  ViewModel.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 03.07.2023.
//

import Foundation
import Combine
import CoreData
import Network

class ViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var books: [Book] = []
    @Published var categoryBooks: [String: [Book]] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private var networkMonitor: NWPathMonitor?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init() {
        loadCategoriesFromCoreData()
        startMonitoringNetwork()
        fetchCategoriesIfNeeded()
    }
    
    func loadCategoriesFromCoreData() {
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let categories = try viewContext.fetch(fetchRequest)
            self.categories = categories.compactMap { categoryEntity in
                if let listName = categoryEntity.name, let listNameEncoded = categoryEntity.nameEncoded {
                    return Category(listName: listName, listNameEncoded: listNameEncoded)
                } else {
                    return nil
                }
            }
        } catch {
            print("Failed to load categories from Core Data: \(error)")
        }
    }
    
    func fetchBooksIfNeeded() {
        
        if let category = selectedCategory, categoryBooks[category.listNameEncoded] == nil {
            fetchBooksForSelectedCategory()
        }
    }
    
    private func startMonitoringNetwork() {
        networkMonitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor?.start(queue: queue)
        
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.fetchCategoriesIfNeeded()
                } else {
                    self?.loadCategoriesFromCoreData()
                }
            }
        }
    }
    
    private func fetchCategoriesIfNeeded() {
        guard categories.isEmpty else { return }
        fetchCategories()
    }
    
    private func fetchCategories() {
        guard let url = URL(string: "https://api.nytimes.com/svc/books/v3/lists/names.json?api-key=YEYTgOtQHNwUYXxESD0BclfGDwqLmCe9") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: Response.self, decoder: JSONDecoder())
            .map { $0.results }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] categories in
                self?.categories = categories
                self?.saveCategoriesToCoreData(categories)
            }
            .store(in: &cancellables)
    }
    
    private func saveCategoriesToCoreData(_ categories: [Category]) {
        let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        
        do {
            let existingCategories = try viewContext.fetch(fetchRequest)
            
            for category in existingCategories {
                viewContext.delete(category)
            }
            
            for categoryData in categories {
                let category = CategoryEntity(context: viewContext)
                category.name = categoryData.listName
                category.nameEncoded = categoryData.listNameEncoded
            }
            
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // "https://api.nytimes.com/svc/books/v3/lists/current/\(category.listNameEncoded).json?api-key=YEYTgOtQHNwUYXxESD0BclfGDwqLmCe9"
    
    func fetchBooksForSelectedCategory() {
        guard let category = selectedCategory else { return }
        
        guard let url = URL(string: "https://api.nytimes.com/svc/books/v3/lists/current/\(category.listNameEncoded).json?api-key=YEYTgOtQHNwUYXxESD0BclfGDwqLmCe9") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: BookResponse.self, decoder: JSONDecoder())
            .map { $0.results.books }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] books in
                self?.categoryBooks[category.listNameEncoded] = books // Save books to the dictionary using the category key
                self?.saveBooksToCoreData(books, forCategory: category) // Save books to Core Data for the specific category
            }
            .store(in: &cancellables)
    }
    
    
    private func loadBooksFromCoreData() {
        guard let category = selectedCategory else { return }
        
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        
        // Predicate to filter books by category listNameEncoded
        let predicate = NSPredicate(format: "categoryListNameEncoded == %@", category.listNameEncoded)
        fetchRequest.predicate = predicate
        
        do {
            let books = try viewContext.fetch(fetchRequest)
            self.books = books.compactMap { bookEntity in
                guard let title = bookEntity.title,
                      let author = bookEntity.author,
                      let publisher = bookEntity.publisher else {
                    return nil
                }
                let bookImage = bookEntity.bookImage ?? "" // Use an empty string if bookImage is nil
                return Book(rank: Int(bookEntity.rank), title: title, author: author, publisher: publisher, bookImage: bookImage)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveBooksToCoreData(_ books: [Book], forCategory category: Category) {
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        
        // Predicate to filter books by category listNameEncoded
        let predicate = NSPredicate(format: "categoryListNameEncoded == %@", category.listNameEncoded)
        fetchRequest.predicate = predicate
        
        do {
            let existingBooks = try viewContext.fetch(fetchRequest)
            
            for book in existingBooks {
                viewContext.delete(book)
            }
            
            for bookData in books {
                let book = BookEntity(context: viewContext)
                book.title = bookData.title
                book.author = bookData.author
                book.publisher = bookData.publisher
                book.bookImage = bookData.bookImage
                book.rank = Int32(bookData.rank)
                book.categoryListNameEncoded = category.listNameEncoded
            }
            
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
