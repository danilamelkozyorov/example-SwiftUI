//
//  CustomActivityModel.swift
//  Life Worth Living
//
//  Created by Мелкозеров Данила on 27.10.2022.
//

import Foundation

struct CustomActivity: Codable {
    let categoryName: String?
    let name: String?
    let id: String?
    let isArchived: Bool?
    let lastChangeDate: String?
    let originalName: String?
    let userId: String?
    let oldName: String?
}
