//
//  LaunchWebViewProtocol.swift
//  TempleTrip
//
//  Created by Ephraim Kunz on 4/6/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

import Foundation

@objc protocol LaunchWebViewProtocol {
    func launchWebView(_ url:URL) -> Void
    
    func displayHTML(_ html:NSString) ->Void
}
