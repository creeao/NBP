//
//  ViewController.swift
//  SB
//
//  Created by Eryk Chrustek on 30/03/2020.
//  Copyright © 2020 Eryk Chrustek. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var indicatorTable: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    //Odświeżanie danych
    @IBAction func refreshData(_ sender: Any) {
        
        self.indicatorTable.startAnimating()
        
        self.tableView.reloadData()
        
        indicatorTable.stopAnimating()
        indicatorTable.hidesWhenStopped = true
        
    }
    
    var valuesOfTable = [Table]()
   
    var numberOfRows : Int = 0
    
    @IBOutlet weak var changeTable: UISegmentedControl!
   
    @IBAction func viewTable(_ sender: Any) {
        
        let segmentedControl = sender as! UISegmentedControl
        
        if segmentedControl.selectedSegmentIndex == 0
        {
             getJSON(tableName: "a") {}
        } else if segmentedControl.selectedSegmentIndex == 1 {
            getJSON(tableName: "b") {}
        } else if segmentedControl.selectedSegmentIndex == 2 {
             getJSON(tableName: "c") {}
        }
    }
    
    func getJSON(tableName : String ,completed: @escaping () -> ()) {

        let url = URL(string: "https://api.nbp.pl/api/exchangerates/tables/\(tableName)?format=json")
        
        URLSession.shared.dataTask(with: url!) {( data,response,error ) in
            
            do {
                
                self.valuesOfTable = try JSONDecoder().decode([Table].self, from: data!)
                
                self.numberOfRows = self.valuesOfTable[0].rates.count
                
                DispatchQueue.main.sync {
                completed()

                return self.tableView.reloadData()
                    
                }

            } catch {
                print("Error")
            }
            
        }.resume()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getJSON(tableName: "a") { self.numberOfRows = 35 }
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    //Ilośc wierszy do wyświetlenia
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63.0; //Nie potrafiłem zmienić w TBC bar
    }
    
    //Wypełnienie komórek, literując po nich
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StyleOfCall") as! TableViewCell

        //Kolor tła komórki
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(named: "SelectedCell") 
        cell.selectedBackgroundView = bgColorView
        
        indicatorTable.stopAnimating()
        indicatorTable.hidesWhenStopped = true
        
        for _ in self.valuesOfTable {

            cell.currencyName?.text = valuesOfTable[0].rates[indexPath.row].currency.capitalized
            cell.currencyCode?.text = valuesOfTable[0].rates[indexPath.row].code
            cell.dateAdd?.text = valuesOfTable[0].effectiveDate
            
            if valuesOfTable[0].rates[indexPath.row].mid != nil {
               cell.currencyValue?.text = String(format: "%.3f", valuesOfTable[0].rates[indexPath.row].mid!)
            } else {
                cell.currencyValue?.text = String(format: "%.3f", valuesOfTable[0].rates[indexPath.row].bid!)
            }

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)

    }
    //Preprzesłanie danych do ekranu waluty
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CurrencyViewController {
            let valueToSecondView : Any = valuesOfTable[0].rates[(tableView.indexPathForSelectedRow?.row)!]
            let toTableInfo : Any = valuesOfTable[0]
            
            destination.tableInfo = toTableInfo as? Table
            
            destination.secondView = valueToSecondView as? Rates

        }
    }
}
