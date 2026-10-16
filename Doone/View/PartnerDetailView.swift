import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct PartnerDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var partner: Partner

    var body: some View {
        Form {
            Section {
                TextField("名称", text: $partner.name)
            }
        }
        .navigationTitle(partner.name)
    }
}
