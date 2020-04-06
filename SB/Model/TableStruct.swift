//
//  TableStruct.swift
//  SB
//
//  Created by Eryk Chrustek on 05/04/2020.
//  Copyright © 2020 Eryk Chrustek. All rights reserved.
//

import UIKit

//Struktura ekranu głównego

struct Table : Decodable {
    let table : String
    let effectiveDate : String
    let rates : [Rates]
}

struct Rates : Decodable {
    var currency : String
    let code : String
    let mid : Float?
    let bid : Float?
    let ask : Float?
    let table : String?
    
}
