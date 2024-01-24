//
//  ContentView.swift
//  MaskingPractice
//
//  Created by 김인섭 on 1/8/24.
//

import SwiftUI
import QuickLook

struct ContentView: View {
     @StateObject var viewModel = DocumentManager()
  
     var body: some View {
         
         Button {
             viewModel.showEditor = true
         } label: {
             Text("Open Image Editor")
         }
         .onAppear {
             viewModel.onAppear()
         }
         .sheet(isPresented: $viewModel.showEditor, content: {
             QuickLookController(url: DocumentManager.fileURL)
         })
     }
}

class DocumentManager: NSObject, ObservableObject {
    
    static let documentsDirectory = FileManager
        .default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first!
    
    static var fileURL: URL {
        Self.documentsDirectory.appendingPathComponent("test.png")
    }
    
    var originalURL: URL {
        Bundle.main.url(forResource: "document", withExtension: "png")!
    }
    
    @Published var showEditor = false
    
    func onAppear() {
        do {
            if FileManager.default.fileExists(atPath: Self.fileURL.path) {
                try FileManager.default.removeItem(at: Self.fileURL)
            }
            try FileManager.default.copyItem(at: originalURL, to: Self.fileURL)
        } catch {
            print(error)
        }
    }
}

struct QuickLookController: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) var presentationMode
    var url: URL

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return UINavigationController(rootViewController: controller)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        var parent: QuickLookController

        init(_ parent: QuickLookController) {
            self.parent = parent
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            parent.url as QLPreviewItem
        }

        func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
            .createCopy
        }
        
        func previewControllerWillDismiss(_ controller: QLPreviewController) {
            
        }
        
        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            
        }
        
        func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem, at modifiedContentsURL: URL) {
            do {
                if FileManager.default.fileExists(atPath: DocumentManager.fileURL.path()) {
                    try FileManager.default.removeItem(at: DocumentManager.fileURL)
                }
                try FileManager.default.copyItem(at: modifiedContentsURL, to: DocumentManager.fileURL)
            } catch {
                print(error)
            }
        }
    }
}
