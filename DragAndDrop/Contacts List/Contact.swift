//
//  Contact.swift
//  DragAndDrop
//
//  Created by Ravi Tyagi on 17/07/17.
//  Copyright © 2017 Xebia. All rights reserved.
//

import UIKit
import ContactsUI
import MobileCoreServices

enum ContactError: Error {
    case invalidTypeIdentifier
    case vCardSerializationFailed
}

final class Contact: NSObject, NSCoding, NSItemProviderReading {

    private(set) var name: String = ""
    private(set) var image: UIImage?
    private(set) var mobileNo: String?
    
    init(name: String) {
        self.name = name
    }
    
    init?(name: String, imageName: String, mobile: String? = nil) {
        guard let image = UIImage(named: imageName) else {
            return nil
        }
        self.image = image
        self.name = name
        self.mobileNo = mobile
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        name =   aDecoder.decodeObject(forKey: "name") as! String
        mobileNo = aDecoder.decodeObject(forKey: "mobileNo") as? String
        image = aDecoder.decodeObject(forKey: "image") as? UIImage
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(mobileNo, forKey: "mobileNo")
        aCoder.encode(image, forKey: "image")
    }
    
    func setContact(with data: Data) throws  {
        do {
            let vCard = try CNContactVCardSerialization.contacts(with: data).first!
            if let imageData = vCard.imageData {
                image = UIImage(data: imageData)
            }
            name = vCard.givenName
            mobileNo = vCard.phoneNumbers.first?.value.stringValue
            
        }
        catch _ {
            throw ContactError.vCardSerializationFailed
        }
    }
    
    
    func createVCard() -> Data {
        let vCard = CNMutableContact()
        vCard.givenName = name
        
        if let mobileNo = mobileNo {
            let mobileNoValue =  CNLabeledValue<CNPhoneNumber>(label: CNLabelHome, value: CNPhoneNumber(stringValue: mobileNo))
            
            vCard.phoneNumbers = [mobileNoValue]
        }
        if let picture = image {
            let pictueBase64 = UIImagePNGRepresentation(picture)!.base64EncodedString()
            let base64Fomatted =  "PHOTO;BASE64;ENCODING=b;TYPE=PNG\(pictueBase64)"
            let data = base64Fomatted.data(using: .utf8)
            vCard.imageData = data
        }
        
        // Create VCard from the our custom
        let vCardData = try! CNContactVCardSerialization.data(with: [vCard])
        
        
        return vCardData
    }
    
    
    // MARK: NSItemProviderReading
    
    // It can read data from this model object
    // It creates the model object from the raw data
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        
        return [kUTTypeVCard as String, kUTTypeUTF8PlainText as String]
    }
    
    required init(itemProviderData data: Data, typeIdentifier: String) throws {
        super.init()
        
        switch typeIdentifier {
        case kUTTypeVCard as NSString as String:
            try self.setContact(with: data)
            
        case kUTTypeUTF8PlainText as NSString as String:
            self.name = String(data: data, encoding: .utf8)!
            
        default:
            throw ContactError.invalidTypeIdentifier
            
        }
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Contact {
        return try Contact(itemProviderData: data, typeIdentifier: typeIdentifier)
    }
    
}


// MARK: NSItemProviderWriting


extension Contact: NSItemProviderWriting {
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeVCard as String, kUTTypeUTF8PlainText as String]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        switch typeIdentifier {
        case kUTTypeVCard as NSString as String:
            completionHandler(createVCard(), nil)
            
            
        case kUTTypeUTF8PlainText as NSString as String:
            completionHandler(name.data(using: .utf8)!, nil)
            
        default:
            completionHandler(nil, ContactError.invalidTypeIdentifier)
            
        }
        
        return nil
    }
    
    
}


//extension NSCoder {
//     func _decodeObject<ResultObjectType>(forKey key: String) -> ResultObjectType where ResultObjectType : NSObject {
//        if let decodedObject =  ) as? ResultObjectType {
//            return decodedObject
//        } else {
//            fatalError("Unable to decode object for key \(key)")
//        }
//    }
//}

