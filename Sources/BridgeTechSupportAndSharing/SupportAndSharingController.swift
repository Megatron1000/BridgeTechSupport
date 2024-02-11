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

public protocol BridgeTechSupportControllerDelegate: AnyObject {
    func bridgeTechSupportController(_ bridgeTechSupportController: BridgeTechSupportController,
                                     didPerformAction action: BridgeTechSupportController.Action)
}

// MARK: BridgeTechSupportController

public class BridgeTechSupportController: NSResponder {
    
    public enum Action: Int, CustomStringConvertible {
        case openCompanyWebsite
        case emailSupport
        case joinMailingList
        case openTwitter
        case openDeveloperOnMacAppStore
        case writeAReview
        case privacyPolicy
        case termsOfUse
        
        var title: String {
            switch self {
                
            case .openCompanyWebsite:
                return "Open Support Website"
                
            case .emailSupport:
                return "Email Support"
                
            case .joinMailingList:
                return "Join Mailing List"
                
            case .openTwitter:
                return "Open Twitter Profile"
                
            case .openDeveloperOnMacAppStore:
                return "View More Developer Apps"
                
            case .writeAReview:
                return "Write a Review"
                
            case .privacyPolicy:
                return "Privacy Policy"
                
            case .termsOfUse:
                return "Terms of Use"
                
            }
            
        }
        
        public var description: String {
            return title
        }
        
    }
    
    private enum Link {
        case companyWebsite
        case mailingListWebsite
        case twitterProfile
        case developerAppStore
        case writeReview(appStoreID: String)
        case appListing(appStoreID: String)
        case terms
        case privacyPolicy
        
        var url: URL {
            switch self {
                
            case .companyWebsite:
                return URL(string:"https://www.bridgetech.io")!
                
            case .mailingListWebsite:
                return URL(string:"https://www.bridgetech.io/mailinglist.html")!
                
            case .twitterProfile:
                return URL(string:"https://twitter.com/MarkBridgesApps")!
                
            case .developerAppStore:
                return URL(string:"macappstore://itunes.apple.com/us/developer/bridgetechsolutionslimited/id497840921?mt=8#")!
                
            case .writeReview(let appStoreID):
                return URL(string:"macappstore://itunes.apple.com/app/id\(appStoreID)?action=write-review")!
                
            case .appListing(let appStoreID):
                return URL(string:"macappstore://itunes.apple.com/app/id\(appStoreID)?ls=1&mt=12")!
                
            case .terms:
                return URL(string: "https://app.termly.io/document/terms-and-conditions/d7403a4e-b18c-492b-bd65-a17ed1545185")!
                
            case .privacyPolicy:
                return URL(string: "https://www.bridgetech.io/PrivacyPolicy.html")!
            }
            
        }
    }
    
    let appStoreID: String
    let appName: String
    let setAppSafe: Bool
    
    public weak var delegate: BridgeTechSupportControllerDelegate?
    
    public init(appStoreID: String, appName: String, setAppSafe: Bool = false, delegate: BridgeTechSupportControllerDelegate?) {
        self.appStoreID = appStoreID
        self.appName = appName
        self.delegate = delegate
        self.setAppSafe = setAppSafe
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
        if !setAppSafe {
            menu.addItem(makeMenuItem(forAction: .joinMailingList))
        }
        menu.addItem(NSMenuItem.separator())
        if !setAppSafe {
            menu.addItem(makeMenuItem(forAction: .writeAReview))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(makeMenuItem(forAction: .openTwitter))
            menu.addItem(makeMenuItem(forAction: .openDeveloperOnMacAppStore))
            menu.addItem(NSMenuItem.separator())
        }
        menu.addItem(makeMenuItem(forAction: .privacyPolicy))
        menu.addItem(makeMenuItem(forAction: .termsOfUse))
        
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
                alert.messageText = "Email Support"
                alert.informativeText = "Please contact support on support@bridgetech.io"
                alert.runModal()
            }
            guard let service = NSSharingService(named: .composeEmail) else {
                return
            }
            service.recipients = ["support@bridgetech.io"]
            service.subject = "\(appName) - Help, Support & Feedback"
            service.perform(withItems: ["Hi"])
            presentFallBackAlert()
            
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
        case .joinMailingList:
            NSWorkspace.shared.open(Link.mailingListWebsite.url)
            
        case .privacyPolicy:
            NSWorkspace.shared.open(Link.privacyPolicy.url)
            
        case .termsOfUse:
            NSWorkspace.shared.open(Link.terms.url)
        }
        
        delegate?.bridgeTechSupportController(self, didPerformAction: action)
    }
    
}
