//
//  HomeView.swift
//  Heron_RecipeApp
//
//  Created by Luci Feinberg on 11/13/24.
//


import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Recipe Finder")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Use this app to scan your fridge or pantry, identify ingredients, and find recipes you can make right now!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Link to CameraView
            NavigationLink(destination: CameraView()) {
                Text("Open Camera")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            
            // Link to ReceiptScannerContainerView
            NavigationLink(destination: ReceiptScannerContainerView()) {
                Text("Scan Receipt")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .navigationTitle("Home")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
