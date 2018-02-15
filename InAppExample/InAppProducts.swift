//
//  InAppProducts.swift
//  InAppExample
//
//  Created by Italo Henrique Queiroz on 08/02/18.
//  Copyright © 2018 Italo Henrique Queiroz. All rights reserved.
//

import Foundation

public struct InAppProducts {
    
    public static let TirarAds = "TirarAds"
    public static let Consumable1 = "Consumable1"
    fileprivate static let productIds: Set<String> = [InAppProducts.TirarAds,InAppProducts.Consumable1]
    public static let store: IAPHelper = IAPHelper(productsIds: InAppProducts.productIds)
}
