//
//  TrueStateWidgetsBundle.swift
//  TrueStateWidgets
//
//  Created by Abhideep Maity on 15/01/26.
//

import WidgetKit
import SwiftUI

@main
struct TrueStateWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TrueStateWidgets()
        TrueStateWidgetsControl()
        TrueStateWidgetsLiveActivity()
    }
}
