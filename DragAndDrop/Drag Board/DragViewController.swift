//
//  ImagesViewController.swift
//  DragAndDrop
//
//  Created by Ravi Tyagi on 11/07/17.
//  Copyright © 2017 Xebia. All rights reserved.
//

import UIKit

class DragViewController: UIViewController {
    
    var dropPoint = CGPoint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "BackgroundPattern"))

        // Set a paste configuration
        pasteConfiguration = UIPasteConfiguration(forAccepting: UIImage.self)
        
        view.addInteraction(UIDragInteraction(delegate: self))
        
        view.addInteraction(UIDropInteraction(delegate: self))
        
    }
    
    @IBAction func next(_ sender: UIBarButtonItem) {
    }
    

}


extension DragViewController: UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let point = session.location(in: interaction.view!)
        
        if let imageView = imageView(at: point) {
            
            let itemProvider = NSItemProvider(object: imageView.image!)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            
            // We set the `localObject` property to the index of the model object
            // so that when performing a drop we can animate it differently from
            // drag items coming from other applications.
            dragItem.localObject = imageView
            return [dragItem]
            
        }
        
        return []
    }
    
    
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        let imageView = item.localObject as! UIImageView
        return UITargetedDragPreview(view: imageView)
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        
        animator.addCompletion { position in
            if position == .end {
                self.fade(session.items, alpha: 0.4)
            }
            
        }
    }
    
}



extension DragViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        let operation: UIDropOperation
        if session.localDragSession == nil {
            operation = .copy
        } else {
            operation = .move
        }
        
        return UIDropProposal(operation: operation)
    }
    
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if session.localDragSession == nil {
            // find the drop point where the user lifted up the fingure
            dropPoint = session.location(in: interaction.view!)
            
            for dragItem in session.items {
                loadImage(dragItem.itemProvider, center: dropPoint)
            }
        }
        else {
            
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, previewForDropping item: UIDragItem, withDefault defaultPreview: UITargetedDragPreview) -> UITargetedDragPreview? {
        
        // Check for the item whether the item is coming from local drag or external drag
        
        // Item is coming from other application
        if item.localObject == nil {
            return nil
        }
        else {
            
            dropPoint = defaultPreview.view.center
            let target = UIDragPreviewTarget(container: view, center: dropPoint)
            
            return defaultPreview.retargetedPreview(with: target)
        }
        
    }
    
    
    func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem, willAnimateDropWith animator: UIDragAnimating) {
        
        animator.addAnimations {
            self.fade([item])
        }
        
        let center = dropPoint
        
        animator.addCompletion {  _ in
            
            if let localView =  item.localObject  as? UIImageView {
                localView.center = center
                localView.alpha = 1.0
            }
            
        }
    }
}



extension DragViewController {
    
    func imageView(at point: CGPoint) -> UIImageView? {
        if let hitTestView = view?.hitTest(point, with: nil) as? UIImageView {
            return hitTestView
        }
        return nil
    }
    
    /// Asynchronously loads an image from the given item provider and
    /// displays it it in the image view.
    private func loadImage(_ itemProvider: NSItemProvider, center: CGPoint) {
        itemProvider.loadObject(ofClass: UIImage.self) { object, error in
            DispatchQueue.main.async {
                let image = object as! UIImage
                let imageView = self.resizedImageView(image: image)
                imageView.center = center
                
            }
        }
    }
    
    
    private func fade(_ items: [UIDragItem], alpha: CGFloat = 0.0) {
        for dragItem in items  {
            if let imageView = dragItem.localObject as? UIImageView {
                imageView.alpha = alpha
            }
        }
    }
    
    
    /// Creates a new image view with the given image and
    /// scales it down if it exceeds a maximum size.
    private func resizedImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        
        var size = image.size
        let longestSide = max(size.width, size.height)
        let maxLength: CGFloat = 200
        var scaleFactor: CGFloat = 1
        
        // If the given image exceeds `maxLength`,
        // we resize the image view to match that length
        // while preserving the original aspect ratio.
        if longestSide > maxLength {
            scaleFactor = maxLength / longestSide
        }
        
        size = CGSize(width: round(size.width * scaleFactor), height: round(size.height * scaleFactor))
        imageView.frame.size = size
        
        view.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }
    
    
}
