//
//  FilterModel.swift
//  Scanner
//
//  Created by Nick Molargik on 12/12/22.
//

import Foundation
import SwiftUI

class FilterModel {
    @Published var selectedNatures = Set<String>()
    @Published var selectedNaturesString = [String]()
    @Published var notificationNatures = Set<String>()
    @Published var notificationNaturesString = [String]()
    @AppStorage("notificationNatures") var notificationNaturesUD = String()
    @AppStorage("useLocation") var useLocation = false
    @AppStorage("useDate") var useDate = false
    @AppStorage("useNature") var useNature = false
    @AppStorage("radius") var radius = 0.0
    @AppStorage("dateFrom") var dateFrom = String()
    @AppStorage("dateTo") var dateTo = String()
    @AppStorage("selectedNatures") var selectedNaturesUD = String()
}
