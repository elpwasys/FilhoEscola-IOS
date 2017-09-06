//
//  AlunoListViewController.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 07/08/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import UIKit
import RxSwift
import TOCropViewController

class AlunoListViewController: DrawerViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var model: AlunoModel? // USED IN TO SET THUMBNAIL
    fileprivate var models = [AlunoModel]()
    fileprivate var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if models.isEmpty {
            self.carregar()
        } else {
            self.tableView.reloadData()
        }
    }
}

// MARK: Custom
extension AlunoListViewController {
    
    func carregar() {
        self.iniciarAsyncTask()
    }
    
    fileprivate func prepare() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = AlunoTableViewCell.separatorInset
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: AlunoTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: AlunoTableViewCell.reusableCellIdentifier)
    }
    
    fileprivate func selectSourceType() {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet
            )
            let camera = UIAlertAction(
                title: TextUtils.localized(forKey: "Label.Camera"),
                style: UIAlertActionStyle.default,
                handler: { action in
                    self.openSourceType(.camera)
                }
            )
            camera.setValue(UIImage(named: "Camera_36"), forKey: "image")
            
            let biblioteca = UIAlertAction(
                title: TextUtils.localized(forKey: "Label.Galeria"),
                style: UIAlertActionStyle.default,
                handler: { action in
                    self.openSourceType(.photoLibrary)
                }
            )
            biblioteca.setValue(UIImage(named: "Library_36"), forKey: "image")
            
            alert.addAction(biblioteca)
            alert.addAction(camera)
            alert.addAction(
                UIAlertAction(
                    title: TextUtils.localized(forKey: "Label.Cancelar"),
                    style: UIAlertActionStyle.cancel,
                    handler: { action in
                        self.model = nil
                    }
                )
            )
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func openSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: Async Task methods
extension AlunoListViewController {
    
    fileprivate func iniciarAsyncTask() {
        self.showActivityIndicator()
        let observable = AlunoService.Async.listar(sync: true)
        prepare(for: observable).subscribe(
            onNext: { models in
                self.iniciarDidLoadAsyncTask(models)
            },
            onError: { error in
                self.hideActivityIndicator()
                self.handle(error)
            },
            onCompleted: {
                self.hideActivityIndicator()
            }
        ).addDisposableTo(disposableBag)
    }
    
    fileprivate func atualizarAsynTask(_ image: UIImage, for key: AlunoKey) {
        self.showActivityIndicator()
        let observable = AlunoService.Async.atualizar(image: image, for: key)
        prepare(for: observable).subscribe(
            onNext: { model in
                self.atualizarDidCompleteAsyncTask(model)
            },
            onError: { error in
                self.hideActivityIndicator()
                self.handle(error)
            },
            onCompleted: {
                self.hideActivityIndicator()
            }
        ).addDisposableTo(disposableBag)
    }
}

// MARK: Did load async task methods
extension AlunoListViewController {
    
    fileprivate func iniciarDidLoadAsyncTask(_ models: [AlunoModel]) {
        self.models = models
        self.tableView.reloadData()
    }
    
    fileprivate func atualizarDidCompleteAsyncTask(_ model: AlunoModel) {
        self.model = nil
        if let index = models.index(where: { return $0.key == model.key }) {
            models[index] = model
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

// MARK: UITableViewDelegate
extension AlunoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "Scene.MensagemCalendar") as! MensagemCalendarViewController
        controller.aluno = model
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AlunoTableViewCell.height
    }
}

// MARK: UITableViewDataSource
extension AlunoListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlunoTableViewCell.reusableCellIdentifier, for: indexPath) as! AlunoTableViewCell
        cell.delegate = self
        let model = models[indexPath.row]
        cell.prepare(model)
        return cell
    }
}

// MARK: AlunoTableViewCellDelegate
extension AlunoListViewController: AlunoTableViewCellDelegate {
    
    func onThumbnailTapped(_ cell: AlunoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            self.model = models[indexPath.row] // CURRENT MODEL
            self.selectSourceType()
        }
    }
}

// MARK: UINavigationControllerDelegate
extension AlunoListViewController: UINavigationControllerDelegate {
    
}

// MARK: UIImagePickerControllerDelegate
extension AlunoListViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        self.model = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let controller = TOCropViewController(croppingStyle: .circular, image: image)
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: TOCropViewControllerDelegate
extension AlunoListViewController: TOCropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.model = nil
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        if let key = model?.key {
            self.atualizarAsynTask(image, for: key)
        }
    }
}
