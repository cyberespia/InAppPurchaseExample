//
//  ViewController.swift
//  InAppExample
//
//  Created by Italo Henrique Queiroz on 08/02/18.
//  Copyright © 2018 Italo Henrique Queiroz. All rights reserved.
//

import UIKit
import StoreKit
class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl?
    var products = [SKProduct]()
    @IBAction func restore(_ sender: Any) {
        self.restoreTapped()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reload), for: .valueChanged)
        self.refreshControl = refreshControl
        self.tableView.addSubview(refreshControl)
        self.reload()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func reload(){
        InAppProducts.store.requestProducts(completionHandler: requestProducts)
    }
    
    func requestProducts(success: Bool, products: [SKProduct]?){
        self.products = []
        tableView.reloadData()
        if success {
            self.products = products!
            self.tableView.reloadData()
        }
        self.refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func restoreTapped() {
        InAppProducts.store.restorePurchases()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }

}

extension ViewController: UITableViewDelegate {
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InAppTableViewCell
        let product = products[indexPath.row]
        cell.product = product
        cell.payButtonPressed = { product in
            InAppProducts.store.buyProduct(product)
        }
        return cell
    }
    
}

