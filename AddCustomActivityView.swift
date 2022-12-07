
import SwiftUI

struct AddCustomActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = CustomActivityViewModel()

    var body: some View {
        LoadingView(isShowing: $viewModel.isLoadView) {
            VStack(alignment: .leading) {
                ScrollView(showsIndicators: false) {
                    ActivityNameView(viewModel: viewModel)
                    addCategoryNameView
                    AddCategoriesDropDownList(viewModel: viewModel)
                }
                Spacer()
                if viewModel.selectedGroup == nil {
                    addNoneSelectedCategoryView
                }
                SaveButtonView(viewModel: viewModel)
            }
            .onReceive(viewModel.$isDismiss) { changes in
                if changes {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alert(isPresented: $viewModel.success.showMessage) {
            Alert(
                title: Text(viewModel.success.title),
                message: Text(viewModel.success.description ?? ""),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
        .navigationBarTitle("Add a custom activity", displayMode: .inline)
        .onAppear {
            viewModel.isLoadView = true
            viewModel.getCategories()
        }
    }
    
    private var addCategoryNameView: some View {
        HStack {
            Text("Select a category")
                .font(.life.bold(size: 18))
                .foregroundColor(.contentTwo)
                .padding(.top, 32)
            Spacer()
        }
    }
    
    private var addNoneSelectedCategoryView: some View {
        BaseWarningView(
            cancelAction: .constant(true),
            icon: "IncorrectIcon",
            textLabel: "Please select a category to continue."
        )
        .frame(height: 40)
    }
}

struct SaveButtonView: View {
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        Button(
            action: {
                viewModel.addCustomActivity()
                viewModel.isDismiss.toggle()
            },
            label: {
                Text("Save")
                    .font(.life.bold(size: 16))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 65)
            }
        )
        .foregroundColor(Color.backgroundTwo)
        .background(
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous
            ).fill(
                viewModel.selectedGroup == nil
                ? Color.buttonDisabledColor
                : Color.buttonColor
            )
        )
        .disabled(viewModel.selectedGroup == nil)
        .alert(isPresented: $viewModel.error.showMessage) {
            Alert(
                title: Text(viewModel.error.title),
                message: Text(viewModel.error.description ?? "")
            )
        }
    }
}

struct ActivityNameView: View {
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity name")
                .font(.life.bold(size: 16))
                .foregroundColor(.contentTwo)
            
            TextField("", text: $viewModel.customActivityTitle)
                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.backgroundThree, lineWidth: 2)
                )
        }
    }
}

struct AddCategoriesDropDownList: View {
    @State private var isActive = false
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundColor(.backgroundThree)
        
        ForEach(0 ..< viewModel.categories.count, id: \.self) { index in
            let isSelected = viewModel.categories[index].isSelected ?? false

            AllCategoriesView(objArea: viewModel.categories[index], isSelected: isSelected, index: index, viewModel: viewModel)
        }
    }
}

struct AllCategoriesView: View {
    let objArea: Area
    let isSelected: Bool
    let index: Int
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    if isSelected {
                        viewModel.closeAllAreas()
                    } else {
                        viewModel.closeAllAreas()
                        viewModel.selectedCategory = objArea.name ?? ""
                        viewModel.categories[index].isSelected = true
                    }
                } label: {
                    Image ("DownArrowIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 10)
                        .rotationEffect(.degrees(isSelected ? 0 : -90))
                    
                    Text(objArea.name ?? "Title")
                        .font(.life.bold(size: 16))
                        .accentColor(.contentTwo)
                    Spacer()
                }
                .padding(EdgeInsets(top: 8, leading: 4, bottom: 16, trailing: 4))
                .overlay(Rectangle()
                    .frame(width: nil, height: 2, alignment: .leading)
                    .foregroundColor(.backgroundThree), alignment: .bottom)
            }
            
            if isSelected {
                VStack {
                    ForEach(0 ..< (objArea.categories?.count ?? 0), id: \.self) { index in
                        CategoryView(objCategory: objArea.categories?[index] ?? Category(), viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct CategoryView: View {
    let objCategory: Category
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    viewModel.selectedGroup = objCategory.name ?? ""
                } label: {
                    Text(objCategory.name ?? "Title")
                        .font(.life.regular(size: 16))
                        .accentColor(.contentTwo)
                    Spacer()
                    if viewModel.selectedGroup == objCategory.name {
                        Image("checkIcon")
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 4, bottom: 16, trailing: 4))
                .overlay(Rectangle()
                    .frame(width: nil, height: 1, alignment: .leading)
                    .foregroundColor(.backgroundThree), alignment: .bottom)
            }
            .padding(.leading, 20)
        }
    }
}
