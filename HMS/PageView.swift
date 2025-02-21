//
//  PageView.swift
//  HMS
//


import SwiftUI

struct PageView: View {
    
    var page: Page
    
    var body: some View {
        VStack(spacing:20){
            Image("\(page.imageUrl)")
                .resizable()
                
//                .ignoresSafeArea()
                .scaledToFit()
//                .padding()
//                .frame(width: .infinity,height: .infinity)
            
            Text(page.name)
                .font(.title)
            
            Text(page.description)
                .font(.subheadline)
                .frame(width: 300)
             
        }
        
    }
}

struct PageView_Previews: PreviewProvider{
    static var previews: some View{
        PageView(page: Page.samplePage)
    }
}
