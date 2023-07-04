//
//  BookEntity+CoreDataProperties.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 04.07.2023.
//
//

import Foundation
import CoreData


extension BookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var publisher: String?
    @NSManaged public var bookImage: String?
    @NSManaged public var rank: Int32
    @NSManaged public var categoryListNameEncoded: String?
    @NSManaged public var bookDescription: String?
    @NSManaged public var amazonProductURL: String?
}

extension BookEntity : Identifiable {

}
