//
//  ContactListViewController.swift
//  DragAndDrop
//
//  Created by Ravi Tyagi on 17/07/17.
//  Copyright © 2017 Xebia. All rights reserved.
//

import UIKit

class ContactListViewController: UITableViewController, UITableViewDropDelegate, UITableViewDragDelegate {
    
    var list: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        list = [
            Contact(name: "Alex", imageName: "Donald", mobile: "+919654300219"),
            Contact(name: "Dave", imageName: "Penguin", mobile: "+91876897983"),
            Contact(name: "Mahi", imageName: "Cute"),
            Contact(name: "Oliver", imageName: "Tiger"),
            Contact(name: "Jack", imageName: "Donald", mobile: "+91889912345"),
            Contact(name: "Harry", imageName: "Cute"),
            Contact(name: "Jacob", imageName: "Penguin", mobile: "+919956435821"),
            Contact(name: "Michael", imageName: "Donald"),
            Contact(name: "Robert", imageName: "Tiger")
            
            ].compactMap{ $0 }
        
        
        
//        tableView.rowHeight = 100
        tableView.tableFooterView = UIView()
        
        tableView.dropDelegate = self
        tableView.dragDelegate = self
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListCell
        
        let item = list[indexPath.row]
        cell.titleLabel?.text = item.name
        cell.imgView?.image = item.image
        cell.mobileNoLabel.text = item.mobileNo ?? ""
        
        return cell
    }
    
    
    // MARK: UITableViewDropDelegate
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        
        guard let insertIndexPath = coordinator.destinationIndexPath else { return }
        
        let dropItems = coordinator.items
        dropItems.forEach {  dropItem in
            let itemProvider = dropItem.dragItem.itemProvider
            // Can load contact
            if itemProvider.canLoadObject(ofClass: Contact.self) {
                // Load the contact
                itemProvider.loadObject(ofClass: Contact.self) { object, error in
                    
                    DispatchQueue.main.async {
                        if let contact = object as? Contact {
                            self.list.insert(contact, at: insertIndexPath.row)
                            tableView.insertRows(at: [insertIndexPath], with: .bottom)
                        }
                        else {
                            // Dispaly Error
                            self.displayError(error!)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: UITableViewDragDelegate
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        // Create Item Provider for our contact
        let contact  =  list[indexPath.row]
        let itemProvider = NSItemProvider(object:  contact)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    
}



extension ContactListViewController {
    
    func displayError(_ error: Error) {
        DispatchQueue.main.async {
            let message = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            message.addAction(cancelAction)
            self.present(message, animated: true, completion: nil)
        }
    }
    
}
