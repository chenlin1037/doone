import SwiftData
import SwiftUI

struct PartnerManagementView: View {
    @Query(sort: \Partner.sortOrder) private var partners: [Partner]
    @StateObject private var viewModel: PartnerManagementViewModel
    @Environment(\.editMode) private var editMode

    init(modelContext: ModelContext) {
        _viewModel = StateObject(
            wrappedValue: PartnerManagementViewModel(modelContext: modelContext)
        )
    }

    private var displayedPartners: [Partner] {
        viewModel.filteredPartners(from: partners)
    }

    var body: some View {
        NavigationStack{
            List {
                if displayedPartners.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: viewModel.isSearching ? "magnifyingglass" : "person.slash")
                            .font(.system(size: 50))
                            .foregroundStyle(.secondary)
                        
                        Text(viewModel.isSearching ? "未找到匹配的伴侣" : "还没有添加任何伴侣")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        if !viewModel.isSearching {
                            Text("点击右上角 + 添加新伴侣")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(displayedPartners) { partner in
                        HStack(spacing: 12) {
                            Text(partner.name)
                            
                            Spacer()
                            
                            // 编辑按钮
                            Button {
                                viewModel.startEditing(partner)
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundStyle(Color.appTheme)
                                    .imageScale(.large)
                            }
                            .buttonStyle(.plain)
                            
                            // 删除按钮
                            Button {
                                if let index = displayedPartners.firstIndex(where: {
                                    $0.id == partner.id
                                }) {
                                    viewModel.deletePartners(
                                        displayedPartners,
                                        at: IndexSet(integer: index)
                                    )
                                }
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundStyle(.red)
                                    .imageScale(.large)
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isSearching)
                            .opacity(viewModel.isSearching ? 0.3 : 1.0)
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        
                    }
                    .onMove { source, destination in
                        viewModel.movePartners(
                            displayedPartners,
                            from: source,
                            to: destination
                        )
                    }
                    .moveDisabled(viewModel.isSearching)
                }
            }
        }
        .navigationTitle("伴侣管理")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "搜索伴侣")
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

        // 添加伴侣 Alert
        .alert("添加伴侣", isPresented: $viewModel.showAddAlert) {
            TextField("输入伴侣名称", text: $viewModel.newPartnerName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button("取消", role: .cancel) {
                viewModel.newPartnerName = ""
            }

            Button("添加") {
                viewModel.addPartner()
            }
            .disabled(
                viewModel.newPartnerName
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            )
        } message: {
            Text("请输入新伴侣的名称")
        }

        // 编辑伴侣 Alert（与 Location 完全一致）
        .alert(
            "编辑伴侣",
            isPresented: Binding(
                get: { viewModel.editingPartner != nil },
                set: { if !$0 { viewModel.cancelEdit() } }
            )
        ) {
            TextField("伴侣名称", text: $viewModel.editingPartnerName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button("取消", role: .cancel) {
                viewModel.cancelEdit()
            }

            Button("保存") {
                viewModel.saveEdit()
            }
            .disabled(
                viewModel.editingPartnerName
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            )
        } message: {
            Text("修改伴侣名称")
        }
        .environment(\.editMode, .constant(.active))
    }
}
