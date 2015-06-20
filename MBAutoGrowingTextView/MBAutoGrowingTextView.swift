//
//  MBAutoGrowingTextView.swift
//  Demonstration
//
//  Created by 구범모 on 2015. 6. 20..
//  Copyright (c) 2015년 Matej Balantič. All rights reserved.
//

import UIKit

public class MBAutoGrowingTextView: UITextView {
    private weak var heightConstraint: NSLayoutConstraint?
    private weak var minHeightConstraint: NSLayoutConstraint?
    private weak var maxHeightConstraint: NSLayoutConstraint?
    
    // MARK: Initializers
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        associateConstraints()
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        associateConstraints()
    }
    
    // MARK: Constraints
    private func associateConstraints() {
        // Iterate through all text view's constraints and identify height, maximum hiehgt, and minimum height constraints.
        for constraint in constraints() as! [NSLayoutConstraint] {
            if constraint.firstAttribute == .Height {
                switch constraint.relation {
                case .Equal: heightConstraint = constraint
                case .LessThanOrEqual: maxHeightConstraint = constraint
                case .GreaterThanOrEqual: minHeightConstraint = constraint
                default: break
                }
            }
        }
    }
    
    // MARK: Autolayout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        assert(self.heightConstraint != nil,  "Unable to find height auto-layout constraint. MBAutoGrowingTextView needs a Auto-layout environment to function. Make sure you are using Auto Layout and that UITextView is enclosed in a view with valid auto-layout constraints.")
        
        // Keep track if height is changing
        var heightChanged = false
        
        // Calculate size needed for the text to be visible wihout scrolling
        var newHeight = intrinsicContentSize().height
        
        // Suggested min/max heights that will correctly fit each line of text
        let suggestedMinHeight = suggestedHeightFrom(minHeightConstraint?.constant)
        let suggestedMaxHeight = suggestedHeightFrom(maxHeightConstraint?.constant)
        
        println("New \(newHeight), Min \(suggestedMinHeight), Max \(suggestedMaxHeight)")
        
        // If there is any maximal height constraint set, make sure we consider that
        if maxHeightConstraint != nil {
            newHeight = newHeight > suggestedMaxHeight! ? suggestedMaxHeight! : newHeight
        }
        
        // If there is any minimal height constraint set, make sure we consider that
        if minHeightConstraint != nil {
            newHeight = newHeight > suggestedMinHeight! ? newHeight : suggestedMinHeight!
        }
        
        // Check if the height has changed
        heightChanged = newHeight != heightConstraint?.constant
        
        if heightChanged == true {
            heightConstraint?.constant = newHeight
            
            // Scroll view to cursor location
            if let selectedTextRange = selectedTextRange {
                let caretRect = caretRectForPosition(selectedTextRange.start)
                scrollRectToVisible(caretRect, animated: true)
            }
        }
    }
    
    public override func intrinsicContentSize() -> CGSize {
        
        // Height should be text view's content size
        var intrinsicContentSize = contentSize
        
        // Increment size by textContainerInset
        intrinsicContentSize.width += (textContainerInset.left + textContainerInset.right) / 2
        //        intrinsicContentSize.height += (textContainerInset.top + textContainerInset.bottom)
        
        println("Intrinsic: \(intrinsicContentSize.height)")
        return intrinsicContentSize
    }
    
    // Hiehgt that will properly fit all text
    private func suggestedHeightFrom(height: CGFloat?) -> CGFloat? {
        if let textViewHeight = height {
            // Text view padding
            let padding = textContainerInset.top + textContainerInset.bottom
            
            // Text height
            var textHeight = textViewHeight - padding
            
            // Amount that should be subtracted from height to correctly fit all lines
            let difference = textHeight % font.lineHeight
            textHeight -= difference
            
            println("Padding: \(padding), textHeight: \(textHeight), diff: \(difference), result: \(textHeight + padding)")
            
            return textHeight + padding
        } else {
            return nil
        }
    }
}
