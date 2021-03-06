//
//  SBAResourceFinder.swift
//  BridgeAppSDK
//
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

public class SBAResourceFinder: NSObject {
    
    static let sharedResourceFinder = SBAResourceFinder()
    
    func sharedResourceDelegate() -> SBABridgeAppSDKDelegate? {
        return UIApplication.sharedApplication().delegate as? SBABridgeAppSDKDelegate
    }
    
    func pathForResource(resourceNamed: String, ofType: String) -> String? {
        if let resourceDelegate = self.sharedResourceDelegate(),
            let path = resourceDelegate.pathForResource(resourceNamed, ofType: ofType) {
                return path
        }
        else if let path = NSBundle.mainBundle().pathForResource(resourceNamed, ofType: ofType) {
            return path
        }
        else if let path = NSBundle(forClass: self.classForCoder).pathForResource(resourceNamed, ofType: ofType) {
            return path
        }
        return nil
    }
    
    public func imageNamed(named: String) -> UIImage? {
        if let resourceDelegate = self.sharedResourceDelegate(),
            let image = UIImage(named: named, inBundle: resourceDelegate.resourceBundle(), compatibleWithTraitCollection: nil) {
            return image
        }
        else if let image = UIImage(named: named) {
            return image
        }
        else if let image = UIImage(named: named, inBundle: NSBundle(forClass: self.classForCoder), compatibleWithTraitCollection: nil) {
            return image
        }
        return nil;
    }
    
    func dataNamed(resourceNamed: String, ofType: String) -> NSData? {
        return dataNamed(resourceNamed, ofType: ofType, bundle: nil)
    }
    
    func dataNamed(resourceNamed: String, ofType: String, bundle: NSBundle?) -> NSData? {
        if let path = bundle?.pathForResource(resourceNamed, ofType: ofType) ??
            self.pathForResource(resourceNamed, ofType: ofType) {
            return NSData(contentsOfFile: path)
        }
        return nil
    }
    
    public func htmlNamed(resourceNamed: String) -> String? {
        if let data = self.dataNamed(resourceNamed, ofType: "html"),
            let html = String(data: data, encoding: NSUTF8StringEncoding) {
            return importHTML(html)
        }
        return nil
    }
    
    func importHTML(input: String) -> String {
        
        // setup string
        var html = input
        func search(str: String, _ range: Range<String.Index>?) -> Range<String.Index>? {
            return html.rangeOfString(str, options: .CaseInsensitiveSearch, range: range, locale: nil)
        }
        
        // search for <import href="resourceName.html" /> and replace with contents of resource file
        var keepGoing = true
        while keepGoing {
            keepGoing = false
            if let startRange = search("<import", html.startIndex..<html.endIndex),
                let endRange = search("/>", startRange.endIndex..<html.endIndex),
                let hrefRange = search("href", startRange.endIndex..<endRange.endIndex),
                let fileStartRange = search("\"", hrefRange.endIndex..<endRange.endIndex),
                let fileEndRange = search(".html\"", fileStartRange.endIndex..<endRange.endIndex) {
                let resourceName = html.substringWithRange(fileStartRange.endIndex..<fileEndRange.startIndex)
                if let importText = htmlNamed(resourceName) {
                    keepGoing = true
                    html.replaceRange(startRange.startIndex..<endRange.endIndex, with: importText)
                }
            }
        }
        
        return html
    }
    
    func jsonNamed(resourceNamed: String) -> NSDictionary? {
        return jsonNamed(resourceNamed, bundle: nil)
    }
    
    func jsonNamed(resourceNamed: String, bundle: NSBundle?) -> NSDictionary? {
        do {
            if let data = self.dataNamed(resourceNamed, ofType: "json", bundle: bundle) {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
                return json as? NSDictionary
            }
        }
        catch let error as NSError {
            // Throw an assertion rather than throwing an exception (or rethrow)
            // so that production apps don't crash.
            assertionFailure("Failed to read json file: \(error)")
        }
        return nil
    }
    
    public func plistNamed(resourceNamed: String) -> NSDictionary? {
        if let path = self.pathForResource(resourceNamed, ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path) {
                return dictionary
        }
        return nil
    }
    
    public func urlNamed(resourceNamed: String, withExtension: String) -> NSURL? {
        if let resourceDelegate = self.sharedResourceDelegate(),
            let url = resourceDelegate.resourceBundle().URLForResource(resourceNamed, withExtension: withExtension)
            where url.checkResourceIsReachableAndReturnError(nil) {
                return url
        }
        else if let url = NSBundle.mainBundle().URLForResource(resourceNamed, withExtension: withExtension)
            where url.checkResourceIsReachableAndReturnError(nil) {
            return url
        }
        else if let url = NSBundle(forClass: self.classForCoder).URLForResource(resourceNamed, withExtension: withExtension)
            where url.checkResourceIsReachableAndReturnError(nil) {
                return url
        }
        return nil;
    }

}
