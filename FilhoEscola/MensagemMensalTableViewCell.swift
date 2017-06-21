//
//  MensagemMensalTableViewCell.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 06/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import FSCalendar

protocol MensagemMensalTableViewCellDelegate {
    func onOpenCalendarTapped(_ model: MensagemCellModel)
}

class MensagemMensalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var centerView: UIView!
    
    fileprivate weak var calendar: FSCalendar!
    
    fileprivate var model: MensagemCellModel?
    fileprivate var delegate: MensagemMensalTableViewCellDelegate?
    
    static var height: CGFloat {
        return 340
    }
    
    static var nibName: String {
        return "MensagemMensalTableViewCell"
    }
    
    static var reusableCellIdentifier: String {
        return "MensagemMensalTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: centerView.bounds.size.width, height: centerView.bounds.size.height))
        calendar.delegate = self
        calendar.dataSource = self
        calendar.backgroundColor = UIColor.white
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        centerView.addSubview(calendar)
        self.calendar = calendar
    }
    
    func popular(_ model: MensagemCellModel, owner delegate: MensagemMensalTableViewCellDelegate, allowsSelection: Bool = false) {
        self.model = model
        self.delegate = delegate
        self.calendar.allowsSelection = allowsSelection
        self.calendar.reloadData()
    }
    
    @IBAction func onAbrirTapped() {
        if let model = self.model, let delegate = self.delegate {
            delegate.onOpenCalendarTapped(model)
        }
    }
}

extension MensagemMensalTableViewCell: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
}

extension MensagemMensalTableViewCell: FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if let model = self.model {
            if model.contains(forKey: date) {
                return UIColor.white
            }
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if let model = self.model {
            if model.contains(forKey: date) {
                return #colorLiteral(red: 0.9982196689, green: 0.3983421922, blue: 0, alpha: 1)
            }
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if let model = self.model {
            if let mensagens = model.mensagens(forKey: date) {
                if mensagens.count > 1 {
                    return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
                }
            }
        }
        return nil
    }
}

extension MensagemMensalTableViewCell: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if let model = self.model {
            if let mensagens = model.mensagens(forKey: date) {
                return mensagens.count
            }
        }
        return 0
    }
}
