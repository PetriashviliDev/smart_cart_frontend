//
//  AnimationExtensions.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 12.10.2025.
//

import SwiftUI

extension View {
    func slideInFromBottom() -> some View {
        self.modifier(SlideInFromBottomModifier())
    }
    
    func fadeIn() -> some View {
        self.modifier(FadeInModifier())
    }
    
    func scaleIn() -> some View {
        self.modifier(ScaleInModifier())
    }
}

struct SlideInFromBottomModifier: ViewModifier {
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isVisible ? 0 : 50)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    isVisible = true
                }
            }
    }
}

struct FadeInModifier: ViewModifier {
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    isVisible = true
                }
            }
    }
}

struct ScaleInModifier: ViewModifier {
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0.8)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isVisible = true
                }
            }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func shake(amount: CGFloat = 10) -> some View {
        self.modifier(ShakeEffect(amount: amount, animatableData: 0))
    }
}
