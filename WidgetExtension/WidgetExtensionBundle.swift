//
//  WidgetExtensionBundle.swift
//  WidgetExtension
//
//  Created by Nick Molargik on 10/1/22.
//

import WidgetKit
import SwiftUI

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        
        if #available(iOS 16.1, *) {
            LatestLiveActivity()
        }
    }
}
