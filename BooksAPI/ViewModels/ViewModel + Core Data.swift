//
//  ViewModel + Core Data.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 03.07.2023.
//

//import CoreData
//
//extension ViewModel {
//    func loadCategoriesFromCoreData() {
//            let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
//
//            do {
//                let categories = try viewContext.fetch(fetchRequest)
//                self.categories = categories.compactMap { $0.name }
//            } catch {
//                print("Failed to load categories from Core Data: \(error)")
//            }
//        }
//
//    private func saveCategoriesToCoreData(_ categories: [Category]) {
//            let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
//
//            do {
//                let existingCategories = try viewContext.fetch(fetchRequest)
//
//                for category in existingCategories {
//                    viewContext.delete(category)
//                }
//
//                for categoryData in categories {
//                    let category = CategoryEntity(context: viewContext)
//                    category.name = categoryData.listName
//                    category.listNameEncoded = categoryData.listNameEncoded
//                }
//
//                try viewContext.save()
//            } catch {
//                print("Failed to save categories to Core Data: \(error)")
//            }
//        }
//    }
