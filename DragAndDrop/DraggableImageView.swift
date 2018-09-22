//
//  DraggableImageView.swift
//  DragAndDrop
//
//  Created by Ravi Tyagi on 10/07/17.
//  Copyright © 2017 Xebia. All rights reserved.
//

import UIKit

class DraggableImageView: UIImageView {
    
    override init(image: UIImage?) {
        super.init(image: image)
        setupDrag()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupDrag()
    }
    
    
    private func setupDrag() {
        isUserInteractionEnabled = true
        addInteraction(UIDragInteraction(delegate: self))
    }
    

}



extension DraggableImageView : UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: self as! NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    
    func dragPreviewForItem(_ item: UIDragItem) -> UITargetedDragPreview {
        let previewView = UIImageView(image: image)
        let convertedFrame = previewView.convert(previewView.frame, to: window)
        
        previewView.frame =  convertedFrame
        
        let target = UIDragPreviewTarget(container: window!, center: previewView.center)
        let parameters = UIDragPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: previewView.bounds, cornerRadius:20)
        
        return UITargetedDragPreview(view: previewView, parameters: parameters, target: target)
    }
    
}
