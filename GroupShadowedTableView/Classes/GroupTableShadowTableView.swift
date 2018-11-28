//
//  GroupTableShadowTableView.swift
//  GroupedShadowTableView
//
//  Created by 吴迪 on 2018/11/27.
//  Copyright © 2018 chouheiwa. All rights reserved.
//

import UIKit

@objc public protocol GroupShadowedTableViewDelegate {
    @objc optional func groupTableView(_ tableView: GroupShadowedTableView, didSelectRowAt indexPath: IndexPath)
    
    func groupTableView(_ tableView: GroupShadowedTableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
    @objc optional func groupTableView(_ tableView: GroupShadowedTableView, heightForFooterAt section: Int) -> CGFloat
    
    @objc optional func groupTableView(_ tableView: GroupShadowedTableView, heightForHeaderAt section: Int) -> CGFloat
    
    @objc optional func groupTableView(_ tableView: GroupShadowedTableView, canSelectRowAt indexPath: IndexPath) -> Bool
}

@objc public protocol GroupShadowedTableViewDataSource {
    @objc optional func numberOfSections(in tableView: GroupShadowedTableView) -> Int
    
    func groupTableView(_ groupTableView: GroupShadowedTableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    func groupTableView(_ groupTableView: GroupShadowedTableView,numberOfRowsIn section: Int) -> Int
}


public class GroupShadowedTableView: UITableView {
    weak var groupDelegate: GroupShadowedTableViewDelegate?
    weak var groupDataSource: GroupShadowedTableViewDataSource?
    
    var showSeparator: Bool = true
    
    private var selectedCell: GroupedTableViewCell?
    
    private var classDic: [String:AnyClass] = [:]
    private var nibDic: [String:UINib] = [:]
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        
        
    }
    
    private func setupUI() {
        
        separatorStyle = .none
        
        self.register(GroupedTableViewCell.classForCoder(), forCellReuseIdentifier: "GroupTableViewCell")
        self.delegate = self
        self.dataSource = self
        
    }
    
    override public func deselectRow(at indexPath: IndexPath, animated: Bool) {
        guard let selectedCell = selectedCell else { return }
        selectedCell.baseTableView.deselectRow(at: IndexPath(row: indexPath.row, section: 0), animated: animated)
    }
}

extension GroupShadowedTableView: UITableViewDelegate,UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let number = groupDataSource?.numberOfSections?(in: self) else { return 0 }
        
        return number
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard groupDataSource?.groupTableView(self, numberOfRowsIn: section) != nil else {
            return 0
        }
        
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableViewCell") as? GroupedTableViewCell else { return UITableViewCell() }
        
        cell.currentSection = indexPath.section
        
        cell.showSeparator = showSeparator
        
        for (key,value) in classDic {
            cell.baseTableView.register(value, forCellReuseIdentifier: key)
        }
        
        for (key,value) in nibDic {
            cell.baseTableView.register(value, forCellReuseIdentifier: key)
        }
        
        cell.cellForRow = { [weak self] (basicCell,indexPath) in
            guard let `self` = self else {return UITableViewCell()}
            
            guard let cell = self.groupDataSource?.groupTableView(self, cellForRowAt: indexPath) else {return UITableViewCell()}
            
            return cell
        }
        
        cell.numberOfRows = { [weak self] (basicCell,section) in
            guard let `self` = self else {return 0}
            
            guard let number = self.groupDataSource?.groupTableView(self, numberOfRowsIn: section)  else {return 0}
            
            return number
        }
        
        cell.heightForRow = { [weak self] (basicCell,indexPath) in
            guard let `self` = self else {return 0}
            
            guard let height = self.groupDelegate?.groupTableView(self, heightForRowAt: indexPath)  else {return 0}
            
            return height
        }
        
        cell.didSelectRow = { [weak self] (basicCell,indexPath) in
            guard let `self` = self else {return}
            
            self.selectedCell = cell
            
            self.groupDelegate?.groupTableView?(self, didSelectRowAt: indexPath)
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var numberOfRows = 0
        
        if let numberOfRow = groupDataSource?.groupTableView(self, numberOfRowsIn: indexPath.section) {
            numberOfRows = numberOfRow
        }
        
        var totalHeight:CGFloat = 0
        
        for index in 0..<numberOfRows {
            if let height = groupDelegate?.groupTableView(self, heightForRowAt: IndexPath(row: index, section: indexPath.section)) {
                totalHeight += height
            }
        }
        
        return totalHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let height = groupDelegate?.groupTableView?(self, heightForFooterAt: section) else { return 0 }
        
        return height
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let height = groupDelegate?.groupTableView?(self, heightForHeaderAt: section) else {
            return 0
        }
        return height
    }

}
