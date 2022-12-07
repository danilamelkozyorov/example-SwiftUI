//
//  CustomActivitiesNetwork.swift
//  Life Worth Living
//
//  Created by GLZVSKI on 21.11.2022.
//

import Foundation

class CustomActivitiesNetwork: NetworkService {
    
    static func getAreas(completion: @escaping (Result<DataResponse, Error>) -> Void) {        
        let parameters = "{\"query\":\"query areas {\\n  areas {\\n    name\\n    categories {\\n      activities {\\n        name\\n      }\\n      name\\n    }\\n  }\\n}\\n\",\"variables\":{}}"
        
        if let request = Self.createRequest(parameters) {
            Self.sendRequest(request: request, groupQueue: DispatchGroup(), completion)
        }
    }
    
    static func getCustomActivities(groupQueue: DispatchGroup, completion: @escaping (Result<DataResponse, Error>) -> Void) {
        guard let userId = userId else { return }
        
        let parameters = "{\"query\":\"query MyQuery {\\n  user(userId: \\\"\(userId)\\\") {\\n    customActivities {\\n      categoryName\\n      id\\n      isArchived\\n      lastChangeDate\\n      name\\n      originalName\\n    }\\n  }\\n}\\n\",\"variables\":{}}"
        
        if let request = Self.createRequest(parameters) {
            Self.sendRequest(request: request, groupQueue: DispatchGroup(), completion)
        }
    }
    
    static func updateCustomActivity(activity: CustomActivity, groupQueue: DispatchGroup, completion: @escaping (Result<DataResponse, Error>) -> Void) {
        let parameters = "{\"query\":\"mutation MyMutation {\\n  updateCustomActivity(\\n      customActivity: {\\n          oldName: \\\"\(activity.oldName ?? "")\\\", \\n          newName: \\\"\(activity.name ?? "")\\\", \\n          categoryName: \\\"\(activity.categoryName ?? "")\\\", \\n          originalName: \\\"\(activity.originalName ?? "")\\\", \\n          isArchived: \(activity.isArchived)\\n          }\\n          ) {\\n    ... on UpdateCustomActivitySuccess {\\n      status\\n      success\\n      message\\n    }\\n    ... on UpdateCustomActivityFailed {\\n      status\\n      success\\n      message\\n    }\\n  }\\n}\\n\",\"variables\":{}}"
        
        if let request = Self.createRequest(parameters) {
            Self.sendRequest(request: request, groupQueue: DispatchGroup(), completion)
        }
    }
    
    static func addCustomActivity(activity: CustomActivity, groupQueue: DispatchGroup, completion: @escaping (Result<DataResponse, Error>) -> Void) {
        let parameters = "{\"query\":\"mutation MyMutation {\\n  addCustomActivity(\\n    customActivity: {\\n      name: \\\"\(activity.name ?? "")\\\", \\n      categoryName: \\\"\(activity.categoryName ?? "")\\\", \\n      originalName: \\\"\(activity.originalName ?? "")\\\", \\n      isArchived: false\\n    }\\n  ) {\\n    ... on CreateCustomActivitySuccess {\\n      status\\n      success\\n      message\\n    }\\n    ... on CreateCustomActivityFailed {\\n      status\\n      success\\n      message\\n    }\\n  }\\n}\",\"variables\":{}}"
        
        if let request = Self.createRequest(parameters) {
            Self.sendRequest(request: request, groupQueue: DispatchGroup(), completion)
        }
    }
}
