//
//  ClearStateWidgetsBundle.swift
//  ClearStateWidgets
//
//  Created by Abhideep Maity on 15/01/26.
//

import WidgetKit
import SwiftUI

@main
struct ClearStateWidgetsBundle: WidgetBundle {
    var body: some Widget {
        ClearStateWidgets()
        ClearStateWidgetsControl()
        ClearStateWidgetsLiveActivity()
    }
}
