//
//  ViewController.swift
//  fixpoint_test
//
//  Created by 浅田智哉 on 2022/12/07.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource {
    
    var datalog: [String] = []
    var resultArray: [[String]] = []
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        datalog = loadCSV(fileName: "log")
    }
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let ServerLabel = cell.viewWithTag(1) as! UILabel
        let timeLabel = cell.viewWithTag(2) as! UILabel
        
        let result = resultArray[indexPath.row]
        ServerLabel.text = result[0]
        timeLabel.text = result[1] + "秒"
        
        return cell
    }

    //監視ログの読み込み
    func loadCSV(fileName: String) -> [String] {
        var dataArray: [String] = []
        if let csvBundle = Bundle.main.path(forResource: fileName, ofType: "csv") {
            do {
                let csvData = try String(contentsOfFile: csvBundle,encoding: .utf8)
                dataArray = csvData.components(separatedBy: "\n")
                //これがないと空の配列が最後につく
                dataArray.removeLast()
            } catch {
                print("読み込み失敗")
            }
        }
        return dataArray
    }
    
    
    @IBAction  func judgeResponse() {
        var brokenServer: [String] = []
        
        for data in datalog {
            let dataArray = data.components(separatedBy: ",")
            
            //応答結果を判定
            let response = dataArray[2]
            if response == "-" {
                //壊れているサーバーは記録する
                brokenServer.append(dataArray[1])
            }
        }
        calculateBrokenTime(brokenServerArray: brokenServer)
    }
    
    //2回壊れた際に対応できない
    func calculateBrokenTime(brokenServerArray: [String]) {
        
        for brokenServer in brokenServerArray {
            var brokenStartTime: Date!
            var brokenEndTime: Date!
            
            for data in datalog {
                let dataArray = data.components(separatedBy: ",")
                //壊れたと記録されたサーバーで、かつ応答結果が"-"である→壊れた時間
                if dataArray[1] == brokenServer && dataArray[2] == "-" {
                    brokenStartTime = stringToDate(dateString: dataArray[0], fromFormat: "YYYYMMDDHHmmss")
                //壊れたと記録されたサーバーで、すでに"-”の応答結果を受け取っているが、正常に応答している→復活した時間
                } else if dataArray[1] == brokenServer && brokenStartTime != nil && dataArray[2] != "-" {
                    brokenEndTime = stringToDate(dateString: dataArray[0], fromFormat: "YYYYMMDDHHmmss")
                    break
                }
            }
            
            //ダウン時間を算出
            if brokenStartTime != nil {
                if brokenEndTime != nil {
                    let calResult = brokenEndTime.timeIntervalSince(brokenStartTime)
                    let result = [brokenServer,String(calResult)]
                    resultArray.append(result)
                } else {
                    let result = [brokenServer,"測定不可"]
                    
                    
                    resultArray.append(result)
                }
            }
        }
        
        tableView.reloadData()
        
    }
    
    
    func stringToDate(dateString: String, fromFormat: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = fromFormat
        return formatter.date(from: dateString)
    }
    
   

}

