//
//  OnboardView.swift
//  PolyuSell
//
//  Created by HUAHUA on 22/10/2026.
//

import SwiftUI

struct OnboardView: View {
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Polyu Sell")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                NavigationLink( destination: LoginView()) {
                    Text("Get Start")
                        .font(.title3.bold())
                        .padding()
                        .padding(.horizontal, 30)
                        .background(.white, in: .rect(cornerRadius: 30))
                }
            }
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack{
                    Rectangle()
                        .fill(.red)
                    Group{
                        
                        
                    }
                    .blur(radius: 6)
                }
                
            )
        }
    }
}
