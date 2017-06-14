//
//  FirstViewController.swift
//  Bars
//
//  Created by Mariano Latorre on 13/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import UIKit

class BarsViewController: BaseViewController {
    
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
    func showError(error: String){
        self.present(errorMessage: error)
    }
}

extension BarsViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "barCell", for: indexPath) as! BarTableViewCell
        
        cell.name?.text = BarViewModel.dataSource?[indexPath.row].name ?? ""
        cell.distance?.text = "Distance: \(BarViewModel.dataSource?[indexPath.row].distance ?? 0.0) Km"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BarViewModel.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        barViewModel.openGoogleMaps(item:indexPath.row)
    }
}
