//
//  MeViewModel.swift
//  HotProspectsApp
//
//  Created by Danjuma Nasiru on 09/09/2023.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import SwiftUI

@MainActor class MeViewModel: ObservableObject {
    
    @Published var name = "Anonymous"
    @Published var emailAddress = "you@yoursite.com"
    @Published var qrCode = UIImage()
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
