//
//  ContentView.swift
//  MPIrisTrackerExample
//
//  Created by Yuki Yamato on 2021/05/05.
//

import SwiftUI
import Resolver

struct ContentView: View {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    @ObservedObject var irisTrackController: IrisTrackController = Resolver.resolve()

    var body: some View {
        VStack {
            if irisTrackController.annotatedImage != nil {
                Image(uiImage: UIImage(cgImage: irisTrackController.annotatedImage!))
                    .resizable()
                    .scaledToFit()
            }

        }
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .onAppear() {
            appDelegate.tracker.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
