
import SwiftUI

struct CustomActivityView: View {
    @StateObject var viewModel = CustomActivityViewModel()
    
    var body: some View {
        LoadingView(isShowing: $viewModel.isLoadView) {
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    if viewModel.customActivityList.count == 0 {
                        if viewModel.isLoadView {
                            Spacer()
                            HStack(alignment: .center) {
                                Spacer()
                            }
                        } else {
                            Spacer()
                            CustomActivitiesStartScreen()
                            Spacer()
                        }
                    } else {
                        GroupedCustomActivitiesView(viewModel: viewModel)
                        
                        if viewModel.isCustomActivityLimit {
                            AddDisableView()
                        } else {
                            AddEnableView(viewModel: viewModel)
                        }
                        
                        Spacer()
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 15))
                .navigationBarTitle("Custom activity", displayMode: .inline)
                .onAppear {
//                    viewModel.isLoadView = true
                    viewModel.loadData()
                }
            }
        }
    }
}

struct CustomActivitiesStartScreen: View {
    @State private var isActive = false

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: -25) {
                HStack {
                    Text("Add a")
                    .font(.life.bold(size: 48))
                    .foregroundColor(Color.contentThree)
                    
                    Text("custom")
                        .font(.life.bold(size: 48))
                        .foregroundColor(Color.contentTwo)
                }

                Text("activity")
                    .font(.life.bold(size: 48))
                    .foregroundColor(Color.contentTwo)
            }

            HStack {
                Text("For the stuff you do often and it’s not in our database.")
                    .font(.life.regular(size: 14))
                    .foregroundColor(.contentThree)
                
                Spacer()
            }

            NavigationLink(destination: AddCustomActivityView(), isActive: $isActive) {
                BaseLightButtonView(title: "Add a custom activity", height: 40, icon: "plusButton") {
                    isActive.toggle()
                }
                .padding(EdgeInsets(top: 64, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
}

struct GroupedCustomActivitiesView: View {
    @State private var isTest = false
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        ForEach(viewModel.groupedCustomActivityList?.keys.sorted() ?? [], id: \.self) { key in
            VStack(alignment: .leading, spacing: 5) {
                Text(key)
                    .font(.life.bold(size: 16))
                    .foregroundColor(.contentTwo)
                
                NavigationLink(
                    destination: EditCustomActivity(viewModel: viewModel),
                    isActive: $isTest
                ) {}
                ForEach(0 ..< viewModel.customActivityList.count, id: \.self) { index in
                    if (key == viewModel.customActivityList[index].categoryName) {
                        BaseListButtonView(title: viewModel.customActivityList[index].name?.lowercased() ?? "") {
                            viewModel.customActivityTitle = viewModel.customActivityList[index].name?.lowercased() ?? "Title"
                            viewModel.selectedCategory = viewModel.customActivityList[index].categoryName
//                            viewModel.selectedGroup = viewModel.customActivityList[index].groupName
                            viewModel.customActivityOrigName = viewModel.customActivityList[index].originalName
                            viewModel.customActivityOldName = viewModel.customActivityList[index].name ?? "Title"
                            isTest.toggle()
                        }
                        .frame(height: 40)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct AddDisableView: View {
    var body: some View {
        VStack {
            disabledButtonView
            disableLabelView
        }
    }
    
    private var disabledButtonView: some View {
        BaseLightButtonView(title: "Add a custom activity", height: 40, icon: "plusButton") {}
            .disabled(true)
    }
    
    private var disableLabelView: some View {
        BaseWarningView(
            cancelAction: .constant(true),
            icon: "IncorrectIcon",
            textLabel: "You can have maximum of 10 custom activities."
        )
    }
}

struct AddEnableView: View {
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        NavigationLink(
            destination: AddCustomActivityView(),
            isActive: $viewModel.isActive
        ) {
            BaseLightButtonView(title: "Add a custom activity", height: 40, icon: "plusButton") {
                viewModel.isActive.toggle()
            }
        }
    }
}
