//
//  PicProcess.swift
//  myARApp
//
//  Created by Tianyu Xu on 2024/6/14.
//
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import Foundation

func processImage(inputImage: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: inputImage) else {
        return nil
    }
    
    let context = CIContext()
    
    guard let blackAndWhiteImage = applyBlackAndWhite(inputImage: ciImage),
          let denoisedImage = applyDenoise(inputImage: blackAndWhiteImage),
          let enhancedImage = applyEnhancements(inputImage: denoisedImage) else {
        return nil
    }
    
    if let cgImage = context.createCGImage(enhancedImage, from: enhancedImage.extent) {
        return UIImage(cgImage: cgImage)
    }
    return nil
}

func applyBlackAndWhite(inputImage: CIImage) -> CIImage? {
    let filter = CIFilter.photoEffectMono()
    filter.inputImage = inputImage
    return filter.outputImage
}

func applyDenoise(inputImage: CIImage) -> CIImage? {
    let filter = CIFilter.noiseReduction()
    filter.inputImage = inputImage
    filter.noiseLevel = 0.02
    filter.sharpness = 0.4
    return filter.outputImage
}

func applyEnhancements(inputImage: CIImage) -> CIImage? {
    // 调整对比度和亮度
    let colorControlsFilter = CIFilter.colorControls()
    colorControlsFilter.inputImage = inputImage
    colorControlsFilter.contrast = 1.2
    colorControlsFilter.brightness = 0.1
    
    guard let colorControlsOutput = colorControlsFilter.outputImage else {
        return nil
    }
    
    // 锐化图像
    let sharpenFilter = CIFilter.sharpenLuminance()
    sharpenFilter.inputImage = colorControlsOutput
    sharpenFilter.sharpness = 0.7
    
    guard let sharpenOutput = sharpenFilter.outputImage else {
        return nil
    }
    
    // 增加细节
    let unsharpMaskFilter = CIFilter.unsharpMask()
    unsharpMaskFilter.inputImage = sharpenOutput
    unsharpMaskFilter.intensity = 0.5
    unsharpMaskFilter.radius = 2.5
    
    return unsharpMaskFilter.outputImage
}

