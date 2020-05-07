//
//  CurrencyViewController.swift
//  SB
//
//  Created by Eryk Chrustek on 02/04/2020.
//  Copyright © 2020 Eryk Chrustek. All rights reserved.
//

import UIKit

class CurrencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var result : Between?
    
    var numberOfRows : Int = 0
    
    func getJSON(completed: @escaping () -> ()) {

        let code = secondView?.code
        let table = tableInfo!.table

        let url = URL(string: "https://api.nbp.pl/api/exchangerates/rates/\(table)/\(code!)/\(startDate)/\(endDate)?format=json")

        URLSession.shared.dataTask(with: url!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
            print("sth wrong")
                return
            }

            do {
                self.result = try JSONDecoder().decode(Between.self, from: data)

                self.numberOfRows = self.result!.rates.count

                DispatchQueue.main.sync {
                completed()
                    
                return self.tableView.reloadData()
                }
            }
            catch {
                print("failed")
            }

            }).resume()
      
    }
    
    //Ilość wierszy
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        
        return numberOfRows
    }
    
    //Wypełnienie komórki
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StyleOfCallBetween") as! DateMidViewCell

        for _ in self.result!.rates {
            cell.effectiveDate?.text = result?.rates[indexPath.row].effectiveDate

            if result?.rates[indexPath.row].mid != nil {
                cell.midValue?.text = String(format: "%.4f", result?.rates[indexPath.row].mid ?? 0.0)
            } else {
                cell.midValue?.text = String(format: "%.4f", result?.rates[indexPath.row].bid ?? 0.0)
            }
        }
        
        return cell
        
    }
    
    //Powrót do ekrangu głównego
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    //Odświeżanie danych
    @IBAction func refreshButton(_ sender: Any) {
        
        self.indicator.startAnimating()
        
        getJSON() {
            self.numberOfRows = self.numberOfRows
        }
        
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
    
    @IBOutlet weak var nameOfRow: UINavigationItem!

    @IBOutlet weak var datePicker: UIDatePicker!
    
    let dateFormatter = DateFormatter()
    
    var secondView : Rates?
    
    var tableInfo : Table?
    
    var startDate = "startDate"
    
    var endDate = "endDate"
    
    
    //Pierwszy picker, niwelujący potrzebę filtrowania poprzez buttona
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {

        startDate = dateFormatter.string(from: sender.date)
        view.endEditing(true)
        self.indicator.startAnimating()

        getJSON() {
            self.numberOfRows = self.numberOfRows
        }
    }
    
    //To co wyżej
    @IBAction func SecondDatePickerValueChanged(_ sender: Any) {

        endDate = dateFormatter.string(from: (sender as AnyObject).date)
        view.endEditing(true)

        getJSON() {
            self.numberOfRows = self.numberOfRows
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameOfRow.title = secondView?.currency.capitalized
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        
        startDate = dateString
        endDate = dateString
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        datePicker.datePickerMode = .date
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
}
