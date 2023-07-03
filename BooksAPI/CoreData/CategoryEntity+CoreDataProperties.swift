//
//  CategoryEntity+CoreDataProperties.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 03.07.2023.
//
//

import Foundation
import CoreData


extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var nameEncoded: String?

}

extension CategoryEntity : Identifiable {

}
