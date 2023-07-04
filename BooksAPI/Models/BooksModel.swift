//
//  BooksModel.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 04.07.2023.
//

import Foundation

struct BookResponse: Codable {
    let status: String
    let results: BookResults
    
    private enum CodingKeys: String, CodingKey {
        case status
        case results
    }
}

struct BookResults: Codable {
    let listName: String
    let listNameEncoded: String
    let books: [Book]
    
    private enum CodingKeys: String, CodingKey {
        case listName = "list_name"
        case listNameEncoded = "list_name_encoded"
        case books
    }
}

struct Book: Codable {
    let rank: Int
    let title: String
    let author: String
    let publisher: String
    let bookImage: String
    
    private enum CodingKeys: String, CodingKey {
        case rank
        case title
        case author
        case publisher
        case bookImage = "book_image"
    }
}
