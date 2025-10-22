//
//  TagChipView.swift
//  Reminder
//
//  Created by Petriashvili Kirill on 13.10.2025.
//

import SwiftUI

struct TagChipsView<Content: View, Tag: Equatable>: View where Tag: Hashable {
    var spacing: CGFloat
    var animation: Animation
    var tags: [Tag]
    var showControlTag: Bool = true
    @ViewBuilder var content: (Tag, Bool) -> Content
    var didChangeSelection: ([Tag]) -> Void
    @State private var selectedTags: [Tag] = []
    
    init(
        spacing: CGFloat = 8,
        animation: Animation = .easeInOut(duration: 0.2),
        tags: [Tag],
        selectedTags: [Tag]? = nil,
        showControlTag: Bool = true,
        @ViewBuilder content: @escaping (Tag, Bool) -> Content,
        didChangeSelection: @escaping ([Tag]) -> Void
    ) {
        self.spacing = spacing
        self.animation = animation
        self.tags = tags
        self.content = content
        self.didChangeSelection = didChangeSelection
        self.showControlTag = showControlTag
        self._selectedTags = State(initialValue: selectedTags ?? tags)
    }
    
    @State private var controlTagState: ControlTagState = .clearAll
        
    private enum ControlTagState {
        case selectAll
        case clearAll
            
        var label: String {
            switch self {
            case .selectAll: return "Все"
            case .clearAll: return "Сбросить"
            }
        }
            
        var icon: String {
            switch self {
            case .selectAll: return "checkmark.circle.fill"
            case .clearAll: return "xmark.circle.fill"
            }
        }
            
        var backgroundColor: Color {
            switch self {
            case .selectAll: return .green
            case .clearAll: return .secondary
            }
        }
    }
    
    var body: some View {
        CustomChipLayout(spacing: spacing) {
            ForEach(tags, id: \.self) { tag in
                chipView(for: tag)
            }
            
            // Управляющий тег (всегда в конце)
            if showControlTag {
                controlTagView
            }
        }
        .onAppear {
            updateControlTagState()
            didChangeSelection(selectedTags)
        }
        .onChange(of: selectedTags) {
            updateControlTagState()
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
    
    private func handleControlTagTap() {
        withAnimation(animation) {
            switch controlTagState {
            case .selectAll:
                // Выбираем все теги
                selectedTags = tags
            case .clearAll:
                // Сбрасываем все теги
                selectedTags.removeAll()
            }
        }
        didChangeSelection(selectedTags)
    }
        
    private func updateControlTagState() {
        withAnimation(animation) {
            if selectedTags.count > 0 {
                // Все теги выбраны - показываем "Сбросить"
                controlTagState = .clearAll
            } else {
                // Не все теги выбраны - показываем "Все"
                controlTagState = .selectAll
            }
        }
    }
    
    private func selectAllTags() {
        selectedTags = tags
        didChangeSelection(selectedTags)
    }
        
    private func clearAllTags() {
        selectedTags.removeAll()
        didChangeSelection(selectedTags)
    }
    
    private var controlTagView: some View {
        HStack(spacing: 8) {
            Text(controlTagState.label)
                .font(.caption)
                .foregroundStyle(.white)
            
            Image(systemName: controlTagState.icon)
                .font(.caption)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(controlTagState.backgroundColor.gradient)
        )
        .contentShape(.rect)
        .onTapGesture {
            handleControlTagTap()
        }
    }
}

fileprivate struct CustomChipLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        let height = maxHeight(proposal: proposal, subviews: subviews)
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
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
