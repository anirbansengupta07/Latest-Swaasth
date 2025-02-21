//
//  OnBoarding.swift
//  HMS
//


import SwiftUI

struct OnBoarding: View {
    @Binding var isOnboardingCompleted: Bool
    @State private var  PageIndex = 0
    private let pages: [Page] = Page.samplePages
    private let dotAppearance = UIPageControl.appearance()
    
    var body: some View {
        TabView(selection:  $PageIndex){
            ForEach(pages){
                page in VStack{
                    Spacer()
                    PageView(page: page)
                    Spacer()
                    if page == pages.last{
                        Button("Sign Up", action: goToZero)
                            .buttonStyle(.bordered )
                    }
                    else{
                        Button("Next",action:incrementPage)
                    }
                    Spacer()
                }
                .tag(page.tag)
            }
        }
        .animation(.easeInOut,value: PageIndex)
        .tabViewStyle(.page )
        .indexViewStyle(.page(backgroundDisplayMode: .interactive))
        .onAppear{
            dotAppearance.currentPageIndicatorTintColor = .black
            dotAppearance.pageIndicatorTintColor = .gray
        }
               
    }
    func incrementPage(){
        PageIndex += 1
    }
    func goToZero(){
        isOnboardingCompleted = true
                            UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
    }
}

//#Preview {
//    OnBoarding(isOnboardingCompleted: false)
//}
