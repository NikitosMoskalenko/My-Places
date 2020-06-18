//
//  MyPlacesTableView.swift
//  MyPlaces
//
//  Created by Nikita Moskalenko on 6/3/20.
//  Copyright © 2020 Nikita Moskalenko. All rights reserved.
//

import UIKit
import RealmSwift

final class MyPlacesTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Private properties
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<PlaceCellModel>!
    private var revestSorting = true
    private var filterPlaces: Results<PlaceCellModel>!
    private var searchBarIsEmpty: Bool {
        guard let searchBarText = searchController.searchBar.text else { return false }
        return searchBarText.isEmpty
    }
    private var isFilttering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmantedControllFilter: UISegmentedControl!
    @IBOutlet weak var sortingButton: UIBarButtonItem!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(PlaceCellModel.self)
        setupSerchController()
    }
    
    //MARK: - @IBAction
     
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceTableViewTableViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortAction(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reverstSorting(_ sender: Any) {
        revestSorting.toggle()
        
        if revestSorting == true {
            sortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            sortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    
    // MARK: - Private methods
    
    private func sorting() {
        if segmantedControllFilter.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: revestSorting)
        } else {
            places = places.sorted(byKeyPath: "title", ascending: revestSorting)
        }
        
        tableView.reloadData()
    }
    
    private func setupSerchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: PlaceCellModel
            if isFilttering {
                place = filterPlaces[indexPath.row]
            } else {
                place = places[indexPath.row ]
            }
            let editingPlaceViewController = segue.destination as? NewPlaceTableViewTableViewController
            editingPlaceViewController?.editingCellPlace = place
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFilttering {
            return filterPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var place = PlaceCellModel()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCel", for: indexPath) as? PlaceTableViewCell
            else {
            return UITableViewCell()
        }
        
        if isFilttering {
            place = filterPlaces[indexPath.row]
        } else {
            place = places[indexPath.row ]
        }
        cell.placeTitle.text = place.title
        cell.placeLocation.text = place.location
        cell.typeOfPlace.text = place.type
        cell.cellRatingControl.rating = Int(place.rating)
        
        cell.placePhoto.image = UIImage(data: place.imageData!)
        cell.placePhoto.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        cell.placePhoto.translatesAutoresizingMaskIntoConstraints = false
        cell.placePhoto.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 15).isActive = true
        cell.placePhoto.heightAnchor.constraint(equalToConstant: 65).isActive = true
        cell.placePhoto.widthAnchor.constraint(equalToConstant: 65).isActive = true
        cell.placePhoto.layer.cornerRadius = 65 / 2
        cell.placePhoto.clipsToBounds = true
        cell.placePhoto.contentMode = .scaleAspectFill

        return cell
    }
        
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        guard editingStyle == .delete else { return }
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .left)
        StorageManager.deletedPlace(param: place)
        tableView.endUpdates()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Extensions

extension MyPlacesTableView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filrtContent(for: searchController.searchBar.text!)
    }
    
    private func filrtContent(for searchText: String) {
        filterPlaces = places.filter("title CONTAINS[c]  %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
