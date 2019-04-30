//    MIT License
//
//    Copyright (c) 2018 Mark Bridges
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation
import AppKit

// MARK: BridgeTechSupportControllerDelegate

public protocol BridgeTechSupportControllerDelegate: class {
    func bridgeTechSupportController(_ bridgeTechSupportController: BridgeTechSupportController,
                                     didPerformAction action: BridgeTechSupportController.Action)
}

// MARK: BridgeTechSupportController

public class BridgeTechSupportController: NSResponder {
    
    public enum Action: Int, CustomStringConvertible {
        case openCompanyWebsite
        case emailSupport
        case openTwitter
        case openDeveloperOnMacAppStore
        case writeAReview
        
        var title: String {
            switch self {
                
            case .openCompanyWebsite:
                return "Open Support Website"
                
            case .emailSupport:
                return "Email Support"
                
            case .openTwitter:
                return "Open Twitter Profile"
                
            case .openDeveloperOnMacAppStore:
                return "View More Developer Apps"
                
            case .writeAReview:
                return "Write a Review"
                
            }
            
        }
        
        public var description: String {
            return title
        }
        
    }
    
    private enum Link {
        case companyWebsite
        case twitterProfile
        case developerAppStore
        case writeReview(appStoreID: String)
        case appListing(appStoreID: String)
        
        var url: URL {
            switch self {
                
            case .companyWebsite:
                return URL(string:"http://www.bridgetech.io")!
                
            case .twitterProfile:
                return URL(string:"https://twitter.com/MarkBridgesApps")!
                
            case .developerAppStore:
                return URL(string:"macappstore://itunes.apple.com/us/developer/bridgetechsolutionslimited/id497840921?mt=8#")!
                
            case .writeReview(let appStoreID):
                return URL(string:"macappstore://itunes.apple.com/app/id\(appStoreID)?action=write-review")!
                
            case .appListing(let appStoreID):
                return URL(string:"macappstore://itunes.apple.com/app/id\(appStoreID)?ls=1&mt=12")!
            }
            
        }
    }
    
    let appStoreID: String
    let appName: String
    
    public weak var delegate: BridgeTechSupportControllerDelegate?
    
    public init(appStoreID: String, appName: String, delegate: BridgeTechSupportControllerDelegate?) {
        self.appStoreID = appStoreID
        self.appName = appName
        self.delegate = delegate
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeMenuItem(forAction action: Action) -> NSMenuItem {
        let menuItem = NSMenuItem(title: action.title,
                                  action: #selector(performAction(_:)),
                                  keyEquivalent: "")
        menuItem.tag = action.rawValue
        menuItem.target = self
        return menuItem
    }
    
    // MARK:
    
    public func addToMenu(of application: NSApplication) {
        
        let menuItem = NSMenuItem(title: "Support",
                                  action: nil,
                                  keyEquivalent: "")
        
        let menu = NSMenu(title: "Support")
        menuItem.submenu = menu
        
        menu.addItem(makeMenuItem(forAction: .openCompanyWebsite))
        menu.addItem(makeMenuItem(forAction: .emailSupport))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(makeMenuItem(forAction: .writeAReview))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(makeMenuItem(forAction: .openTwitter))
        menu.addItem(makeMenuItem(forAction: .openDeveloperOnMacAppStore))
        
        application.mainMenu?.addItem(menuItem)
        application.nextResponder = self
    }
    
    // MARK: Actions
    
    @objc public func performAction(_ sender: Any?) {
        
        guard
            let menutItem = sender as? NSMenuItem,
            let action = Action(rawValue: menutItem.tag) else {
                fatalError("Unkown tag")
        }
        
        switch action {
            
        case .openCompanyWebsite:
            NSWorkspace.shared.open(Link.companyWebsite.url)
            
        case .emailSupport:
            
            func presentFallBackAlert() {
                let alert = NSAlert()
                alert.messageText = "Unable To Launch Mail Client"
                alert.informativeText = "Please contact support on support@bridgetech.io"
                alert.runModal()
            }
            guard let service = NSSharingService(named: .composeEmail) else {
                presentFallBackAlert()
                return
            }
            service.recipients = ["support@bridgetech.io"]
            service.subject = "\(appName) - Help, Support & Feedback"
            if service.canPerform(withItems: ["Hi"]) {
                service.perform(withItems: ["Hi"])
            } else {
                presentFallBackAlert()
            }
            
        case .openTwitter:
            NSWorkspace.shared.open(Link.twitterProfile.url)
            
        case .openDeveloperOnMacAppStore:
            NSWorkspace.shared.open(Link.developerAppStore.url)
            
        case .writeAReview:
            if #available(iOS 10.14, *) {
                NSWorkspace.shared.open(Link.writeReview(appStoreID: appStoreID).url)
            } else {
                // Best we can do is go to the App Store listing page on earlier versions
                NSWorkspace.shared.open(Link.appListing(appStoreID: appStoreID).url)
            }
        }
        
        delegate?.bridgeTechSupportController(self, didPerformAction: action)
    }
    
}
