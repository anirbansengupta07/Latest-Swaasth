//
//  DynamicHeight.swift
//  HMS
//
//  Created by Anirban Sengupta on 25/10/24.
//

import SwiftUI
struct DynamicHeightTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false // Disable scrolling to allow dynamic height
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            let newSize = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: .infinity))
            if height != newSize.height {
                height = newSize.height // Update height to content height
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DynamicHeightTextEditor
        
        init(_ parent: DynamicHeightTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text // Update the bound text
        }
    }
}
