import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct TestView: View {
    @State private var image: UIImage? = nil
    private var originalImage: UIImage?
    
    init() {
        // 加载原始图片
        self.originalImage = UIImage(named: "1.jpg")
    }
    
    var body: some View {
        VStack {
            Button(action: {
                if let originalImage = originalImage {
                    if let processedImage = processImage(inputImage: originalImage) {
                        image = processedImage
                    }
                }
            }) {
                Image(systemName: "cross.fill")
                    .font(.largeTitle)
            }
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 1000, height: 800)
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 500, height: 500)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    TestView()
}

