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
    
    private let api = "https://api.nytimes.com/svc/books/v3/lists/names.json?api-key=YEYTgOtQHNwUYXxESD0BclfGDwqLmCe9"
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
                guard let name = categoryEntity.name,
                      let nameEncoded = categoryEntity.nameEncoded else {
                    return nil
                }
                return Category(listName: name, listNameEncoded: nameEncoded)
            }
        } catch {
            print("Failed to load categories from Core Data: \(error)")
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
        guard let url = URL(string: api) else {
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
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print("Error decoding JSON: \(error)")
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
            print("Failed to save categories to Core Data: \(error)")
        }
    }
}
