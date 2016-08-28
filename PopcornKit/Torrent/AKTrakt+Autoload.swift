//
//  AKTrakt+Autoload.swift
//  PopcornKit


import Foundation
import AKTrakt

/// Extends Trakt to create an autoload
extension Trakt {
    static private var loaded: Trakt?
    
    static func autoload() -> Trakt {
        if Trakt.loaded == nil {
            Trakt.loaded = Trakt(clientId: "594eb196444be3f55c121d4eba69f6779d3600a130094cefafb1e131d1541fc8",
                                 clientSecret: "0b42ce84e61540b04ee25e87e6cbf544f8f6ba8fea30a32ef1a4c031690e3a7d",
                                 applicationId: 10163)
        }
        return Trakt.loaded!
    }
}
