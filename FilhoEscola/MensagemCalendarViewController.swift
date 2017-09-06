//
//  MensagemAlunoViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 08/08/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import FSCalendar

class MensagemCalendarViewController: AppViewController {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    var aluno: AlunoModel?
    
    fileprivate lazy var entries = [(key: Date, value: [MensagemModel])]()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = { [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }
}

// MARK: Custom
extension MensagemCalendarViewController {
    
    fileprivate func prepare() {
        self.prepareEntries()
        self.prepareCalendar()
        self.prepareTableView()
        self.preapareNavigationBar()
        self.view.addGestureRecognizer(self.scopeGesture)
    }
    
    fileprivate func prepareEntries() {
        if let aluno = self.aluno {
            self.title = aluno.nome
            if let mensagens = aluno.mensagens {
                var dictionary = [Date: [MensagemModel]]()
                for mensagem in mensagens {
                    let key = mensagem.data!
                    var value = dictionary[key]
                    if value == nil {
                        value = [MensagemModel]()
                    }
                    value!.append(mensagem)
                    dictionary[key] = value!
                }
                if !dictionary.isEmpty {
                    self.entries = dictionary.sorted { $0.0.key < $0.1.key }
                }
            }
        }
    }
    
    fileprivate func prepareCalendar() {
        self.calendar.delegate = self
        self.calendar.dataSource = self
        self.calendar.allowsMultipleSelection = false
        ShadowUtils.applyBottom(self.calendar)
    }
    
    fileprivate func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.tableView.register(UINib(nibName: MensagemTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: MensagemTableViewCell.reusableCellIdentifier)
        self.tableView.register(UINib(nibName: MensagemCalendarHeaderView.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: MensagemCalendarHeaderView.reusableCellIdentifier)
    }
    
    fileprivate func dateToScroll() {
        if let section = self.tableView.indexPathsForVisibleRows?[0].section {
            let key = entries[section].key
            self.calendar.select(key)
        }
    }
    
    fileprivate func entriesHasKey(_ key: Date) -> Bool {
        return self.entries.index { return $0.key == key } != nil
    }
    
    fileprivate func preapareNavigationBar() {
        
    }
}

// MARK: UITableViewDelegate
extension MensagemCalendarViewController: UITableViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.dateToScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.dateToScroll()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MensagemTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = entries[section].key
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MensagemCalendarHeaderView.reusableCellIdentifier) as! MensagemCalendarHeaderView
        header.prepare(key)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return MensagemCalendarHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let aluno = self.aluno {
            let mensagem = entries[indexPath.section].value[indexPath.row]
            let modal = ModalViewController.create(aluno: aluno, mensagem: mensagem, owner: self)
            modal.delegate = self
            self.presentDialogViewController(modal)
        }
    }
}

// MARK: UITableViewDataSource
extension MensagemCalendarViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MensagemTableViewCell.reusableCellIdentifier, for: indexPath) as! MensagemTableViewCell
        let model = entries[indexPath.section].value[indexPath.row]
        cell.prepare(model)
        return cell
    }
}

// MARK: FSCalendarDataSource
extension MensagemCalendarViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        var should = false
        for entry in entries {
            if date == entry.key {
                should = true
                break
            }
        }
        return should
    }
}

// MARK: FSCalendarDelegateAppearance
extension MensagemCalendarViewController: FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if let section = (self.entries.index { return $0.key == date }) {
            return "\(entries[section].value.count)"
        }
        return nil;
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
        if let selectedDate = self.calendar.selectedDate, selectedDate == date {
            return Color.white
        }
        return Color.grey800
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let section = (self.entries.index { return $0.key == date }) {
            let indexPath = IndexPath(row: 0, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if let _ = (self.entries.index { return $0.key == date }) {
            return Color.orange500
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if let _ = (self.entries.index { return $0.key == date }) {
            return Color.white
        }
        return nil
    }
}

// MARK: ModalViewControllerDelegate
extension MensagemCalendarViewController: ModalViewControllerDelegate {
    
    func didRead(mensagem: MensagemModel) {
        for (section, entry) in entries.enumerated() {
            for (row, value) in entry.value.enumerated() {
                if value === mensagem {
                    mensagem.status = .lida
                    let indexPath = IndexPath(row: row, section: section)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    break
                }
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate
extension MensagemCalendarViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            }
        }
        return shouldBegin
    }
}
