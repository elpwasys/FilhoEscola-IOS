//
//  MensagemCalendarViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 18/05/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import FSCalendar

class MensagemCalendarViewController: UIViewController {

    @IBOutlet weak var centerView: UIView!
    fileprivate weak var calendar: FSCalendar!
    
    fileprivate var model: MensagemCellModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.create()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    static func create(_ model: MensagemCellModel) -> MensagemCalendarViewController {
        let controller = MensagemCalendarViewController(nibName: "MensagemCalendarViewController", bundle: nil)
        return controller
    }
    
    private func create() {
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: centerView.bounds.size.width, height: centerView.bounds.size.height))
        //calendar.delegate = self
        //calendar.dataSource = self
        calendar.backgroundColor = UIColor.white
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        centerView.addSubview(calendar)
        self.calendar = calendar
    }
}
