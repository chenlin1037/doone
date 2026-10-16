import Combine
import Foundation
import SwiftData

final class LocationManagementViewModel: ObservableObject {
    @Published var newLocationName: String = ""
    @Published var searchText: String = ""
    @Published var showAddAlert: Bool = false
    @Published var editingLocation: LocationPreset?
    @Published var editingLocationName: String = ""

    private let defaultLocationNames: [String] = ["酒店", "公园", "他家", "我家", "车上"]
    private var modelContext: ModelContext

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        seedDefaultsIfNeeded()
        ensureSortOrderInitializedIfNeeded()
    }

    func addLocation() {
        let trimmed = newLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let descriptor = FetchDescriptor<LocationPreset>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        
        guard !existing.contains(where: { $0.name == trimmed }) else {
            newLocationName = ""
            return
        }

        let nextOrder = (existing.map { $0.sortOrder }.max() ?? -1) + 1

        let location = LocationPreset(name: trimmed, sortOrder: nextOrder)
        modelContext.insert(location)
        save()
        newLocationName = ""
    }

    func startEditing(_ location: LocationPreset) {
        editingLocation = location
        editingLocationName = location.name
    }

    func saveEdit() {
        let trimmed = editingLocationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let location = editingLocation else {
            cancelEdit()
            return
        }

        // 检查是否与其他地点重名
        let descriptor = FetchDescriptor<LocationPreset>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        
        let isDuplicate = existing.contains { existingLocation in
            existingLocation.id != location.id && existingLocation.name == trimmed
        }
        
        guard !isDuplicate else {
            cancelEdit()
            return
        }

        location.name = trimmed
        save()
        cancelEdit()
    }

    func cancelEdit() {
        editingLocation = nil
        editingLocationName = ""
    }

    func deleteLocations(_ locations: [LocationPreset], at offsets: IndexSet) {
        for index in offsets {
            let location = locations[index]
            modelContext.delete(location)
        }
        
        reorderAfterDeletion(remaining: locations, deleted: offsets)
        save()
    }

    func filteredLocations(from locations: [LocationPreset]) -> [LocationPreset] {
        let trimmedKeyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let sorted = locations.sorted { $0.sortOrder < $1.sortOrder }

        guard !trimmedKeyword.isEmpty else {
            return sorted
        }

        return sorted.filter { location in
            location.name.localizedCaseInsensitiveContains(trimmedKeyword)
        }
    }

    func moveLocations(_ locations: [LocationPreset], from source: IndexSet, to destination: Int) {
        guard !isSearching else { return }

        var reordered = locations
        reordered.move(fromOffsets: source, toOffset: destination)

        for (index, location) in reordered.enumerated() {
            location.sortOrder = index
        }
        save()
    }

    // MARK: - Private Methods

    private func seedDefaultsIfNeeded() {
        let descriptor = FetchDescriptor<LocationPreset>()
        guard let existing = try? modelContext.fetch(descriptor), existing.isEmpty else {
            return
        }

        for (index, name) in defaultLocationNames.enumerated() {
            let location = LocationPreset(name: name, sortOrder: index)
            modelContext.insert(location)
        }
        save()
    }

    private func ensureSortOrderInitializedIfNeeded() {
        let descriptor = FetchDescriptor<LocationPreset>()
        guard let existing = try? modelContext.fetch(descriptor), !existing.isEmpty else {
            return
        }

        let allZero = existing.allSatisfy { $0.sortOrder == 0 }
        guard allZero else { return }

        let sortedByName = existing.sorted { lhs, rhs in
            lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

        for (index, location) in sortedByName.enumerated() {
            location.sortOrder = index
        }
        save()
    }

    private func reorderAfterDeletion(remaining: [LocationPreset], deleted: IndexSet) {
        let remainingItems = remaining.enumerated().filter { !deleted.contains($0.offset) }.map { $0.element }
        
        for (index, location) in remainingItems.enumerated() {
            location.sortOrder = index
        }
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("保存地点失败: \(error)")
        }
    }
}