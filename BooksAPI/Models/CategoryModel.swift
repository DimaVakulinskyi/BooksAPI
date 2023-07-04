//
//  Model.swift
//  BooksAPI
//
//  Created by Дмитро Вакулінський on 03.07.2023.
//

import Foundation

struct Response: Codable {
    let results: [Category]

    private enum CodingKeys: String, CodingKey {
        case results
    }
}

struct Category: Codable {
    let listName: String
    let listNameEncoded: String

    private enum CodingKeys: String, CodingKey {
        case listName = "list_name"
        case listNameEncoded = "list_name_encoded"
    }
}
