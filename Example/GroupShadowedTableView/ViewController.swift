//
//  ViewController.swift
//  GroupShadowedTableView
//
//  Created by chouheiwa on 11/27/2018.
//  Copyright (c) 2018 chouheiwa. All rights reserved.
//

import UIKit
import GroupShadowedTableView

class ViewController: UIViewController {
    @IBOutlet weak var tableView: GroupShadowedTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // setup groupDataSource
        tableView.groupDataSource = self
        // setup groupDelegate
        tableView.groupDelegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: GroupShadowedTableViewDelegate, GroupShadowedTableViewDataSource {
    func groupTableView(_ groupTableView: GroupShadowedTableView, cellForRowAt indexPath: IndexPath, currentTableView: UITableView, realIndexPath: IndexPath) -> UITableViewCell {
        let cell = currentTableView.dequeueReusableCell(withIdentifier: "cell", for: realIndexPath)
        
        return cell
    }
    
    func groupTableView(_ tableView: GroupShadowedTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func groupTableView(_ groupTableView: GroupShadowedTableView, numberOfRowsIn section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: GroupShadowedTableView) -> Int {
        return 2
    }
    
    
}


