//
//  GroupTableViewCell.swift
//  GroupedShadowTableView
//
//  Created by 吴迪 on 2018/11/27.
//  Copyright © 2018 chouheiwa. All rights reserved.
//

import UIKit

class GroupedTableViewCell: UITableViewCell {
    var numberOfRows: ((GroupedTableViewCell,Int) -> Int)?
    var heightForRow: ((GroupedTableViewCell,IndexPath) -> CGFloat)?
    var cellForRow: ((GroupedTableViewCell,IndexPath) -> UITableViewCell)?
    var didSelectRow: ((GroupedTableViewCell,IndexPath) -> Void)?
    
    
    var currentSection: Int = 0
    
    let baseTableView = UITableView(frame: CGRect.zero, style: .plain)
    
    var showSeparator: Bool = true
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
        baseTableView.frame = bounds.insetBy(dx: 15, dy: 0)
        
        baseTableView.delegate = self
        baseTableView.dataSource = self
        
        baseTableView.isScrollEnabled = false
        baseTableView.separatorStyle = .none
        
        contentView.addSubview(baseTableView)
        
        baseTableView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        baseTableView.frame = bounds
        
        setShadow(8, to: baseTableView, with: true, opacity: 0.6)
    }
    
    private func setShadow(_ cornerRaidus: CGFloat,to view: UIView,with shadow:Bool,opacity: CGFloat) {
        view.layer.cornerRadius = cornerRaidus
        
        if shadow {
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowOpacity = Float(opacity)
            layer.shadowOffset = CGSize(width: 14, height: 0)
            layer.shadowRadius = 4
            layer.shouldRasterize = false
            layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: cornerRaidus).cgPath
        }
        
        layer.masksToBounds = !shadow
    }
    
}

extension GroupedTableViewCell:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let number = numberOfRows?(self,currentSection) else {return 0}
        
        return number
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = cellForRow?(self,IndexPath(row: indexPath.row, section: currentSection)) else { return UITableViewCell() }
        
        return cell
    }
    
    
    enum CellType {
        case onlyOne
        case top
        case bottom
        case other
        
        init?(totalCount: Int,currentSection: Int) {
            guard totalCount > currentSection else { return nil }
            if totalCount == 1 && currentSection == 0 { self = .onlyOne; return }
            else if currentSection == 0 { self = .top; return }
            else if currentSection == totalCount - 1 { self = .bottom; return}
            else { self = .other}
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var number = 0
        
        if let numberOfRows = numberOfRows { number = numberOfRows(self,currentSection) }
        
        let cornerRadius: CGFloat = 8.0
        
        cell.backgroundColor = .clear
        
        let layer = CAShapeLayer()
        
        let backgroundLayer = CAShapeLayer()
        
        let pathRef = CGMutablePath()
        
        let bounds = cell.bounds
        
        guard let type = CellType(totalCount: number, currentSection: indexPath.row) else {return}
        
        var needSeparator = false
        
        switch type {
        case .top:
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY),radius: cornerRadius)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            
            needSeparator = true
            break
        case .onlyOne:
            pathRef.addRoundedRect(in: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
            break
        case .bottom:
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY),radius: cornerRadius)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            break
        case .other:
            pathRef.addRect(bounds)
            needSeparator = true
            break
        }
        
        print("\(indexPath) type:\(type)")
        
        layer.path = pathRef
        
        backgroundLayer.path = pathRef
        
        layer.fillColor = UIColor.white.cgColor
        
        if showSeparator && needSeparator {
            let lineLayer = CALayer()
            
            let lineHeight = 1.0 / UIScreen.main.scale
            
            lineLayer.frame = CGRect(x: separatorInset.left, y: bounds.size.height - lineHeight, width: bounds.size.width - (separatorInset.left + separatorInset.right), height: lineHeight)
            
            lineLayer.backgroundColor = tableView.separatorColor?.cgColor
            
            layer.addSublayer(lineLayer)
        }
        
        let roundView = UIView(frame: bounds)
        roundView.layer.insertSublayer(layer, at: 0)
        roundView.backgroundColor = .clear
        cell.backgroundView = roundView
        
        let selectedBackgroundView = UIView(frame: cell.bounds)
        backgroundLayer.fillColor = UIColor.groupTableViewBackground.cgColor
        selectedBackgroundView.layer.insertSublayer(backgroundLayer, at: 0)
        selectedBackgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = selectedBackgroundView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow?(self,IndexPath(row: indexPath.row, section: currentSection))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let result = heightForRow?(self,IndexPath(row: indexPath.row, section: currentSection)) else {
            return 0
        }
        return result
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


fileprivate extension CGRect {
    var midX: CGFloat {
        return size.width / 2 + origin.x
    }
    
    var midY: CGFloat {
        return size.height / 2 + origin.y
    }
    
    var minX: CGFloat {
        return origin.x
    }
    
    var minY: CGFloat {
        return origin.y
    }
    
    var maxX: CGFloat {
        return size.width + origin.x
    }
    
    var maxY: CGFloat {
        return size.height + origin.y
    }
}
