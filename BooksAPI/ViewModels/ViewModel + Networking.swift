//
//  ViewModel + Networking.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 03.07.2023.
//

//import Network
//import Combine
//import Foundation
//
//extension ViewModel {
//    func startMonitoringNetwork() {
//        networkMonitor = NWPathMonitor()
//        let queue = DispatchQueue(label: "NetworkMonitor")
//        networkMonitor?.start(queue: queue)
//        
//        networkMonitor?.pathUpdateHandler = { [weak self] path in
//            DispatchQueue.main.async {
//                if path.status == .satisfied {
//                    self?.fetchCategoriesIfNeeded()
//                } else {
//                    self?.loadCategoriesFromCoreData()
//                }
//            }
//        }
//    }
//    
//    func fetchCategoriesIfNeeded() {
//        guard categories.isEmpty else { return }
//        fetchCategories()
//    }
//    
//    private func fetchCategories() {
//        guard let url = URL(string: api) else {
//            print("Invalid URL")
//            return
//        }
//        
//        URLSession.shared
//            .dataTaskPublisher(for: url)
//            .tryMap { data, response -> Data in
//                guard let httpResponse = response as? HTTPURLResponse,
//                      httpResponse.statusCode == 200 else {
//                    throw URLError(.badServerResponse)
//                }
//                return data
//            }
//            .decode(type: Response.self, decoder: JSONDecoder())
//            .map { $0.results }
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] completion in
//                if case let .failure(error) = completion {
//                    print("Error decoding JSON: \(error)")
//                }
//            } receiveValue: { [weak self] categories in
//                self?.categories = categories
//                self?.saveCategoriesToCoreData(categories)
//            }
//            .store(in: &cancellables)
//    }
//}
