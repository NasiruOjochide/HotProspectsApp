//
//  MeView.swift
//  HotProspectsApp
//
//  Created by Danjuma Nasiru on 02/03/2023.
//

import SwiftUI

struct MeView: View {
    
    @StateObject var viewModel = MeViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $viewModel.name)
                    .textContentType(.name)
                    .font(.title)
                
                TextField("Email address", text: $viewModel.emailAddress)
                    .textContentType(.emailAddress)
                    .font(.title)
                
                Image(uiImage: viewModel.qrCode)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        Button {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: viewModel.qrCode)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
            }
            .navigationTitle("Your code")
            .onAppear { viewModel.updateCode() }
            .onChange(of: viewModel.name) { _ in viewModel.updateCode() }
            .onChange(of: viewModel.emailAddress) { _ in viewModel.updateCode() }
        }
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
