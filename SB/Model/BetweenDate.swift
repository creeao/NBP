//
//  BetweenDate.swift
//  SB
//
//  Created by Eryk Chrustek on 05/04/2020.
//  Copyright © 2020 Eryk Chrustek. All rights reserved.
//

import UIKit

//Struktura ekranu waluty

struct Between : Decodable {
    let table : String
    let rates : [RatesBetween]
}

struct RatesBetween : Decodable {
    let effectiveDate : String
    let mid : Float?
    let bid : Float?
    let ask : Float?

}
