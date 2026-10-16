import Combine
import Foundation
import SwiftData

final class PartnerManagementViewModel: ObservableObject {
    @Published var newPartnerName: String = ""
    @Published var searchText: String = ""
    @Published var showAddAlert: Bool = false
    @Published var editingPartner: Partner?
    @Published var editingPartnerName: String = ""

    private let defaultPartnerNames: [String] = ["宝贝"]
    private var modelContext: ModelContext

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        seedDefaultsIfNeeded()
        ensureSortOrderInitializedIfNeeded()
    }

    func addPartner() {
        let trimmed = newPartnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let descriptor = FetchDescriptor<Partner>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []

        guard !existing.contains(where: { $0.name == trimmed }) else {
            newPartnerName = ""
            return
        }

        let nextOrder = (existing.map { $0.sortOrder }.max() ?? -1) + 1

        let partner = Partner(name: trimmed, sortOrder: nextOrder)
        modelContext.insert(partner)
        save()
        newPartnerName = ""
    }

    func deletePartners(_ partners: [Partner], at offsets: IndexSet) {
        let remaining = partners.enumerated().filter { !offsets.contains($0.offset) }.map { $0.element }

        for index in offsets {
            modelContext.delete(partners[index])
        }
        for (index, partner) in remaining.enumerated() {
            partner.sortOrder = index
        }
        save()
    }

    func startEditing(_ partner: Partner) {
        editingPartner = partner
        editingPartnerName = partner.name
    }

    func saveEdit() {
        let trimmed = editingPartnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let partner = editingPartner else {
            cancelEdit()
            return
        }

        // 检查是否与其它伴侣重名
        let descriptor = FetchDescriptor<Partner>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []

        let isDuplicate = existing.contains { existingPartner in
            existingPartner.id != partner.id && existingPartner.name == trimmed
        }
        guard !isDuplicate else {
            cancelEdit()
            return
        }

        partner.name = trimmed
        save()
        cancelEdit()
    }

    func cancelEdit() {
        editingPartner = nil
        editingPartnerName = ""
    }

    func filteredPartners(from partners: [Partner]) -> [Partner] {
        let trimmedKeyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let sorted = partners.sorted { $0.sortOrder < $1.sortOrder }

        guard !trimmedKeyword.isEmpty else {
            return sorted
        }

        return sorted.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedKeyword)
        }
    }

    func movePartners(_ partners: [Partner], from source: IndexSet, to destination: Int) {
        guard !isSearching else { return }

        var reordered = partners
        reordered.move(fromOffsets: source, toOffset: destination)

        for (index, partner) in reordered.enumerated() {
            partner.sortOrder = index
        }

        save()
    }

    private func seedDefaultsIfNeeded() {
        let descriptor = FetchDescriptor<Partner>()
        guard let existing = try? modelContext.fetch(descriptor), existing.isEmpty else {
            return
        }

        for (index, name) in defaultPartnerNames.enumerated() {
            let partner = Partner(name: name, sortOrder: index)
            modelContext.insert(partner)
        }
        save()
    }

    private func ensureSortOrderInitializedIfNeeded() {
        let descriptor = FetchDescriptor<Partner>()
        guard let existing = try? modelContext.fetch(descriptor), !existing.isEmpty else {
            return
        }

        let allZero = existing.allSatisfy { $0.sortOrder == 0 }
        guard allZero else { return }

        let sortedByName = existing.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }

        for (index, partner) in sortedByName.enumerated() {
            partner.sortOrder = index
        }
        save()
    }

    private func reorderAfterDeletion(remaining: [Partner], deleted: IndexSet) {
        let remainingItems = remaining
            .enumerated()
            .filter { !deleted.contains($0.offset) }
            .map { $0.element }

        for (index, partner) in remainingItems.enumerated() {
            partner.sortOrder = index
        }
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("保存伴侣失败: \(error)")
        }
    }
}
