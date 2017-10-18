//
//  UIStoryboard+Additions.swift
//  WeatherApp
//
//  Created by Jorge Orjuela on 10/18/17.
//

import UIKit

extension UIStoryboard: StoryboardHandlerType {
    
    enum StoryboardName: String {
        case main = "Main"
    }
    
    // MARK: Initialization
    
    convenience init(storyBoardName: StoryboardName, bundle: Bundle? = nil) {
        self.init(name: storyBoardName.rawValue, bundle: bundle)
    }
    
    // MARK: Instance methods
    
    func instantiateViewController<T: UIViewController>() -> T where T: StoryboardIdentifiable {
        guard let viewController = instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("No view controller found")
        }
        
        return viewController
    }
}
