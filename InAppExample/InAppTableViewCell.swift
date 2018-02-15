//
//  InAppTableViewCell.swift
//  InAppExample
//
//  Created by Italo Henrique Queiroz on 08/02/18.
//  Copyright © 2018 Italo Henrique Queiroz. All rights reserved.
//

import UIKit
import StoreKit
class InAppTableViewCell: UITableViewCell {

    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBAction func pay(_ sender: Any) {
        payButtonPressed?(product!)
    }
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    var payButtonPressed: ((_ product: SKProduct) -> ())?
   
    
    var product: SKProduct? {
        didSet{
            guard let product = product else {return}
            self.productName.text = product.localizedTitle
            InAppTableViewCell.priceFormatter.locale = product.priceLocale
            self.buyButton.setTitle(InAppTableViewCell.priceFormatter.string(from: product.price), for: .normal)
                buyButton.isEnabled = false
            if InAppProducts.store.isProductPurchased(product.productIdentifier){
                buyButton.tintColor = UIColor.lightGray
            }else if IAPHelper.canMakePayments() {
                buyButton.isEnabled = true
            }else {
                buyButton.tintColor = UIColor.lightGray
                buyButton.setTitle("Not Aviable", for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
