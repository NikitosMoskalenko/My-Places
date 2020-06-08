//
//  ViewController.swift
//  MyPlaces
//
//  Created by Nikita Moskalenko on 6/3/20.
//  Copyright © 2020 Nikita Moskalenko. All rights reserved.
//

import UIKit

class MyPlacesTableView: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCel")
        cell?.textLabel?.text = "Cell"
        return cell!
    }
}


