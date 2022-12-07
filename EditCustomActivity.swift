
import SwiftUI

struct EditCustomActivity: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        LoadingView(isShowing: $viewModel.isLoadView) {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    ScrollView(showsIndicators: false) {
                        ActivityNameView(viewModel: viewModel)
                        editSaveWarningView
                        editSelectCategoryView
                        EditCategoriesDropDownList(viewModel: viewModel)
                        Spacer()
                    }
                    EditArchiveSectionView(viewModel: viewModel)
                }
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16))
                
                editDimmedBackgroundView
                EditIsActiveArchiveView(viewModel: viewModel)
            }
        }
        .alert(isPresented: $viewModel.message.showMessage) {
            Alert(
                title: Text(viewModel.message.title),
                message: Text(viewModel.message.description ?? ""),
                dismissButton: .default(Text("OK")) {
                    if viewModel.isArchived {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .navigationBarTitle("Edit custom activity", displayMode: .inline)
        .onAppear {
            viewModel.isLoadView = true
            viewModel.getCategories()
        }
    }
    
    private var editSelectCategoryView: some View {
        HStack {
            Text("Select a category")
                .font(.life.bold(size: 18))
                .foregroundColor(.contentTwo)
                .padding(.top, 32)
            Spacer()
        }
    }
    
    private var editSaveWarningView: some View {
        BaseWarningView(
            cancelAction: .constant(true),
            icon: "save",
            textLabel: "Previous journals will keep the original name."
        )
    }
    
    private var editDimmedBackgroundView: some View {
        Color.black
            .opacity(viewModel.isActiveArchive ? 0.5 : 0)
            .animation(.spring())
            .edgesIgnoringSafeArea(.all)
    }
}

struct EditArchiveSectionView: View {
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                BaseLightButtonView(
                    title: "Archive",
                    width: 168,
                    icon: "Archive"
                ) { viewModel.isActiveArchive.toggle() }
                
                BaseButtonView(titleName: "Save") {
                    viewModel.updateCustomActivity()
                }
            }
        }
    }
}

struct EditCategoriesDropDownList: View {
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundColor(.backgroundThree)
        
        ForEach(0 ..< viewModel.categories.count, id: \.self) { index in
            let isSelected = viewModel.selectedCategory == viewModel.categories[index].name
            
            EditAllCategoriesView(
                objArea: viewModel.categories[index],
                isSelected: isSelected,
                index: index,
                isActive: viewModel.selectedCategory == viewModel.categories[index].name,
                viewModel: viewModel
            )
        }
    }
}

struct EditAllCategoriesView: View {
    let objArea: Area
    let isSelected: Bool
    let index: Int
    @State var isActive: Bool
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
                        EditCategoryView(objCategory: objArea.categories?[index] ?? Category(), viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct EditIsActiveArchiveView: View {
    @ObservedObject var viewModel: CustomActivityViewModel
    
    var body: some View {
        BottomSheetView(
            title: "Archive \(viewModel.customActivityTitle)",
            isOpen: $viewModel.isActiveArchive,
            maxHeight: 240
        ) {
            VStack(spacing: 40) {
                Text("The previous journals will stay intact.")
                    .font(.life.regular(size: 14))
                    .foregroundColor(.contentTwo)

                HStack {
                    BaseLightButtonView(title: "Cancel", width: 168) {
                        viewModel.isActiveArchive.toggle()
                    }
                    BaseButtonView(titleName: "Archive") {
                        viewModel.isActiveArchive.toggle()
                        viewModel.addToArchive()
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 15))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct EditCategoryView: View {
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
