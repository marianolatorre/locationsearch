//
//  FirstViewController.swift
//  Bars
//
//  Created by Mariano Latorre on 14/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import UIKit

class BarsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var barViewModel : BarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        barViewModel = BarViewModel(withDelegate:self)
    }
}

extension BarsViewController : BarViewModelDelegate {
    func showBars(){
        tableView.reloadData()
    }
    func showError(message: String){
        self.show(errorMessage: message)
    }
}

extension BarsViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "barCell", for: indexPath) as! BarTableViewCell
        
        cell.name?.text = barViewModel.dataSource?[indexPath.row].name ?? ""
        cell.distance?.text = "Distance: \(barViewModel.dataSource?[indexPath.row].distance ?? 0.0) Km"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barViewModel.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        barViewModel.openGoogleMaps(item:indexPath.row)
    }
}
