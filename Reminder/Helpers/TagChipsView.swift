//
//  TagChipView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 13.10.2025.
//

import SwiftUI

struct TagChipsView<Content: View, Tag: Equatable>: View where Tag: Hashable {
    var spacing: CGFloat = 10
    var animation: Animation = .easeInOut(duration: 0.2)
    var tags: [Tag]
    @ViewBuilder var content: (Tag, Bool) -> Content
    var didChangeSelection: ([Tag]) -> Void
    @State private var selectedTags: [Tag] = []
    
    var body: some View {
        CustomChipLayout(spacing: spacing) {
            ForEach(tags, id: \.self) { tag in
                chipView(for: tag)
            }
        }
    }
    
    private func chipView(for tag: Tag) -> some View {
        let isSelected = selectedTags.contains(tag)
        
        return content(tag, isSelected)
            .contentShape(.rect)
            .onTapGesture {
                handleTagTap(tag)
            }
    }
    
    private func handleTagTap(_ tag: Tag) {
        withAnimation(animation) {
            if selectedTags.contains(tag) {
                selectedTags.removeAll { $0 == tag }
            } else {
                selectedTags.append(tag)
            }
        }
        
        didChangeSelection(selectedTags)
    }
}

fileprivate struct CustomChipLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        let height = maxHeight(proposal: proposal, subviews: subviews)
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        
        for subview in subviews {
            let fitSize = subview.sizeThatFits(proposal)
            
            if (origin.x + fitSize.width) > bounds.maxX {
                origin.x = bounds.minX
                origin.y += fitSize.height + spacing
            }
            
            subview.place(at: origin, proposal: proposal)
            origin.x += fitSize.width + spacing
        }
    }
    
    private func maxHeight(proposal: ProposedViewSize, subviews: Subviews) -> CGFloat {
        var origin: CGPoint = .zero
        let maxWidth = proposal.width ?? 0
        
        for subview in subviews {
            let fitSize = subview.sizeThatFits(proposal)
            
            if (origin.x + fitSize.width) > maxWidth {
                origin.x = 0
                origin.y += fitSize.height + spacing
            }
            
            origin.x += fitSize.width + spacing
            
            if subview == subviews.last {
                origin.y += fitSize.height
            }
        }
            
        return origin.y
    }
}
