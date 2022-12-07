
import Foundation

class CustomActivityViewModel: ObservableObject {
    var isCustomActivityLimit: Bool  {
         customActivityList.count > 9
    }
    
    @Published var customActivityList: [CustomActivityStruct] = []
    @Published var groupedCustomActivityList: [String:[CustomActivityStruct]]?
    @Published var customActivity: CustomActivity?
    @Published var categories: [Area] = []

    @Published var isActive = false
    @Published var isDismiss = false
    @Published var isArchived = false
    @Published var isLoadView = false
    @Published var isSelected = false
    @Published var isActiveArchive = false

    @Published var customActivityId = ""
    @Published var customActivityTitle = ""
    @Published var selectedGroup: String?
    @Published var selectedCategory: String?
    @Published var customActivityOldName: String?
    @Published var customActivityOrigName: String?
    
    @Published var error = AlertModel(title: "Server error :(", description: "Repeat the request later.")
    @Published var success = AlertModel(title: "Request completed :)", description: "Data processed.")
    @Published var message = AlertModel(title: "Title", description: "Description")
    
    func validate() -> Bool {
        if customActivityTitle.isEmpty {
            error.title = "Your custom activity name is empty."
            error.showMessage.toggle()
            return false
        }

        if customActivityTitle.count > 40 {
            error.title = "Maximum length is 40 characters."
            error.showMessage.toggle()
            return false
        }
        customActivityTitle = customActivityTitle.lowercased()
        return true
    }
    
    func getCategories() {
        categories.removeAll()

        CustomActivitiesNetwork.getAreas { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async { [self] in
                    self.isLoadView = false
                    
                    guard let areas = result.data?.areas else { return }
                    categories.removeAll()
                    
                    areas.forEach { area in
                        categories.append(area)
                    }
                }
            case .failure(let error):
                print("🔴 LOG: STRANGE ERROR -> getAreas -> \(error.localizedDescription)")
            }
        }
    }
    
    func loadData() {
        getCustomActivityList()
        syncCustomActivities()
//        CustomActivityObject.deleteAll()
    }
    
    func getCustomActivityList() {
        customActivityList.removeAll()
        groupedCustomActivityList?.removeAll()
        
        var activitiesListFromRepository = CustomActivityObject.getAll().filter { $0.isArchived == false }
        activitiesListFromRepository = activitiesListFromRepository.filter { $0.name != nil }
        activitiesListFromRepository = activitiesListFromRepository.sorted { $0.name ?? "" > $1.name ?? "" }
        
        activitiesListFromRepository.forEach { activityObject in
            customActivityList.append(transformObjFromRepoToStruct(repositoryObject: activityObject))
        }
        
        self.groupedCustomActivityList = Dictionary(
            grouping: self.customActivityList,
            by: { $0.categoryName ?? "Default" }
        )
    }

    func addCustomActivity() {
        if !validate() { return }
        
        let activity = CustomActivityStruct(dateOfChange: nil,
                                            typeOfChange: .created,
                                            id: customActivityId,
                                            name: customActivityTitle,
                                            oldName: customActivityOldName,
                                            originalName: customActivityTitle,
                                            categoryName: selectedCategory,
                                            isArchived: isArchived,
                                            userId: nil)
        
        CustomActivityObject.create(activity)
        
        self.isDismiss = true
        loadData()
    }
    
    func updateCustomActivity() {
        if !validate() { return }
        
        let activity = CustomActivityStruct(dateOfChange: nil,
                                            typeOfChange: .updated,
                                            id: customActivityId,
                                            name: customActivityTitle,
                                            oldName: customActivityOldName,
                                            originalName: customActivityOrigName,
                                            categoryName: selectedCategory,
                                            isArchived: isArchived,
                                            userId: nil)
        
        CustomActivityObject.create(activity)
        
        loadData()
    }
    
    func addToArchive() {
        if !validate() { return }
        
        let activity = CustomActivityStruct(dateOfChange: nil,
                                            typeOfChange: .updated,
                                            id: customActivityId,
                                            name: customActivityTitle,
                                            oldName: customActivityOldName,
                                            originalName: customActivityOrigName,
                                            categoryName: selectedCategory,
                                            isArchived: true,
                                            userId: nil)
        
        CustomActivityObject.create(activity)
        
        loadData()
    }
    
    func syncCustomActivities() {
        SyncManager.instance.addSyncQueue(ObjectSync(
            dataModel: CustomActivityObject(),
            closure: {
                self.getCustomActivityList()
            }
        ))
        
        SyncManager.instance.startSync()
    }
    
    func transformObjFromRepoToStruct(repositoryObject: CustomActivityObject) -> CustomActivityStruct {
        let activityStruct = CustomActivityStruct(dateOfChange: repositoryObject.dateOfChange,
                                             typeOfChange: repositoryObject.typeOfChange,
                                             id: repositoryObject.id,
                                             name: repositoryObject.name,
                                             oldName: repositoryObject.oldName,
                                             originalName: repositoryObject.originalName,
                                             categoryName: repositoryObject.categoryName,
                                             isArchived: repositoryObject.isArchived,
                                             userId: repositoryObject.userId)
        
        return activityStruct
    }
    
    func closeAllAreas() {
        for (index, _) in categories.enumerated() {
            categories[index].isSelected = false
        }
    }
}
