import SwiftData
import SwiftUI

struct LocationManagementView: View {
    @Query(sort: \LocationPreset.sortOrder) private var locations: [LocationPreset]
    @StateObject private var viewModel: LocationManagementViewModel
    @Environment(\.editMode) private var editMode

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: LocationManagementViewModel(modelContext: modelContext))
    }

    private var displayedLocations: [LocationPreset] {
        viewModel.filteredLocations(from: locations)
    }

    var body: some View {
        NavigationStack {
            List {
                if displayedLocations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: viewModel.isSearching ? "magnifyingglass" : "mappin.slash")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        Text(viewModel.isSearching ? "未找到匹配的地点" : "还没有添加任何地点")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        if !viewModel.isSearching {
                            Text("点击右上角 + 添加新地点")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(displayedLocations) { location in
                        HStack(spacing: 12) {
                            // 地点名称
                            Text(location.name)
                            
                            Spacer()
                            
                            // 编辑按钮
                            Button {
                                viewModel.startEditing(location)
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundStyle(Color.appTheme)
                                    .imageScale(.large)
                            }
                            .buttonStyle(.plain)
                            
                            // 删除按钮
                            Button {
                                if let index = displayedLocations.firstIndex(where: { $0.id == location.id }) {
                                    viewModel.deleteLocations(displayedLocations, at: IndexSet(integer: index))
                                }
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundStyle(.red)
                                    .imageScale(.large)
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isSearching)
                            .opacity(viewModel.isSearching ? 0.3 : 1.0)
                            
                            // 拖动手柄
                            // Image(systemName: "line.3.horizontal")
                            //     .foregroundStyle(.secondary)
                            //     .imageScale(.medium)
                            //     .opacity(viewModel.isSearching ? 0.3 : 1.0)
                        }
                        .contentShape(Rectangle())
                    }
                    .onMove { source, destination in
                        viewModel.moveLocations(displayedLocations, from: source, to: destination)
                    }
                    .moveDisabled(viewModel.isSearching)
                }
            }
        }
        .navigationTitle("地点管理")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "搜索地点")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showAddAlert = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .alert("添加地点", isPresented: $viewModel.showAddAlert) {
            TextField("输入地点名称", text: $viewModel.newLocationName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button("取消", role: .cancel) {
                viewModel.newLocationName = ""
            }

            Button("添加") {
                viewModel.addLocation()
            }
            .disabled(viewModel.newLocationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("请输入新地点的名称")
        }
        .alert("编辑地点", isPresented: Binding(
            get: { viewModel.editingLocation != nil },
            set: { if !$0 { viewModel.cancelEdit() } }
        )) {
            TextField("地点名称", text: $viewModel.editingLocationName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button("取消", role: .cancel) {
                viewModel.cancelEdit()
            }

            Button("保存") {
                viewModel.saveEdit()
            }
            .disabled(viewModel.editingLocationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("修改地点名称")
        }
        // .confirmationAction(.destructive) {
        //     viewModel.deleteLocations(displayedLocations, at: IndexSet(integer: 0))
        // } message: {
        //     Text("确定删除吗？")
        // }

        .environment(\.editMode, .constant(.active))
    }
}
