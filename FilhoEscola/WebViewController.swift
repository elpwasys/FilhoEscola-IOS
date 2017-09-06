//
//  WebViewController.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 15/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

import SwiftMessages
import TOCropViewController

fileprivate enum Scheme: String {
    case dataUpdate = "data.update"
    case initialize = "initialize"
    case imageOpen = "image.open"
    case imageUpload = "image.upload"
    case toastShow = "toast.show"
    case message = "message"
    case progressShow = "progress.show"
    case progressHide = "progress.hide"
}

class WebViewController: DrawerViewController {

    @IBOutlet weak var webView: UIWebView!
    
    fileprivate var imagePicker: UIImagePickerController!
    
    var link: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        carregar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func carregar() {
        if let link = self.link {
            if let url = URL(string: "\(Config.mobileURL)/\(link)") {
                let request = URLRequest(url: url)
                webView.loadRequest(request)
            }
        }
    }
}

extension WebViewController {
    
    fileprivate func clear() {
        title = nil
        navigationItem.setLeftBarButtonItems([drawerButton], animated: true)
        navigationItem.setRightBarButtonItems(nil, animated: true)
    }
    
    fileprivate func initialize(_ model: ViewModel) {
        self.title = model.title
        if let toolbar = model.toolbar {
            if let buttons = toolbar.buttons {
                self.addBarButtonItem(buttons, position: .right)
            }
        }
    }
    
    fileprivate func initialize(_ model: MessageModel) {
        let message = App.Message()
        message.presentationStyle = .bottom
        message.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        message.duration = .forever
        message.dimMode = .gray(interactive: true)
        message.title = model.title
        message.content = model.content
        if let type = model.type {
            switch type {
            case .error:
                message.theme = .error
            case .success:
                message.theme = .success
            case .warning:
                message.theme = .warning
            default:
                break
            }
        }
        message.show(self)
    }
    
    fileprivate func addBarButtonItem(_ models: [ButtonModel], position: ButtonModel.Position) {
        var urls = [URL]()
        var resources = [String]()
        for model in models {
            resources.append(model.src!)
        }
        let observable = FileService.Async.load(resources: resources)
        prepare(for: observable)
            .subscribe(
                onNext: { url in
                    urls.append(url)
                },
                onError: { error in
                    
                },
                onCompleted: {
                    self.createBarButtonItem(urls: urls, models: models, position: position)
                }
            ).addDisposableTo(disposableBag)
    }
    
    private func createBarButtonItem(urls: [URL], models: [ButtonModel], position: ButtonModel.Position) {
        var items = [UIBarButtonItem]()
        for (index, url) in urls.enumerated() {
            let model = models[index]
            if let image = UIImage(contentsOfFile: url.path) {
                let button = UIButton(type: .custom)
                button.tag = model.id!
                button.addTarget(self, action: #selector(onTappedBarButtonItem(button:)), for: .touchUpInside)
                button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                button.tintColor = UIColor.white
                items.append(UIBarButtonItem(customView: button))
            }
        }
        if (position == .left) {
            items.insert(drawerButton, at: 0)
            navigationItem.setLeftBarButtonItems(items, animated: true)
        } else {
            navigationItem.setRightBarButtonItems(items, animated: true)
        }
    }
    
    func onTappedBarButtonItem(button: UIButton) {
        webView.stringByEvaluatingJavaScript(from: "Device.onTapped(\(button.tag))")
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
                        
                })
            )
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func openSourceType(_ sourceType: UIImagePickerControllerSourceType) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func upload(_ image: UIImage) {
        showActivityIndicator()
        let observable = FileService.Async.upload(image: image)
        prepare(for: observable)
            .subscribe(
                onNext: { model in
                    self.onUploadComplete(model: model)
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
    
    fileprivate func onUploadComplete(model: UploadResultModel) {
        if let json = model.toJSONString() {
            webView.stringByEvaluatingJavaScript(from: "Device.onUpload(\(json))")
        }
    }
}

extension WebViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else {
            return false
        }
        if let scheme = url.scheme {
            switch scheme {
            case Scheme.message.rawValue:
                if let json = self.getArgs(scheme) {
                    if let model = MessageModel(JSONString: json) {
                        self.initialize(model)
                    }
                }
                return false
            case Scheme.toastShow.rawValue:
                if let message = self.getArgs(scheme) {
                    self.handle(Trouble.any(message))
                }
                return false
            case Scheme.dataUpdate.rawValue:
                if let json = self.getArgs(scheme) {
                    if let model = Dispositivo(JSONString: json) {
                        Dispositivo.current = model
                    }
                }
                return false
            case Scheme.imageOpen.rawValue:
                return false
            case Scheme.imageUpload.rawValue:
                self.selectSourceType()
                return false
            case Scheme.initialize.rawValue:
                if let json = self.getArgs(scheme) {
                    if let model = ViewModel(JSONString: json) {
                        self.initialize(model)
                    }
                }
                return false
            case Scheme.progressShow.rawValue:
                self.showActivityIndicator()
                return false
            case Scheme.progressHide.rawValue:
                self.hideActivityIndicator()
                return false
            default:
                return true
            }
        }
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        clear()
        showActivityIndicator()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideActivityIndicator()
        let path = Bundle.main.path(forResource: "Device", ofType: "js")
        if let content = try? String(contentsOfFile: path!, encoding: .utf8) {
            webView.stringByEvaluatingJavaScript(from: content)
        }
        if let message = webView.stringByEvaluatingJavaScript(from: "Device.message"), TextUtils.isNotBlank(message) {
            showMessage(message);
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        hideActivityIndicator()
        self.handle(error)
    }
    
    private func getArgs(_ scheme: String) -> String? {
        return webView.stringByEvaluatingJavaScript(from: "Device.getArgs('\(scheme)')")
    }
}

extension WebViewController: UINavigationControllerDelegate {
    
}

extension WebViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let controller = TOCropViewController(croppingStyle: .circular, image: image)
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
    }
}

extension WebViewController: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: nil)
        self.upload(image)
    }
}
