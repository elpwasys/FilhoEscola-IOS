//
//  WebViewController.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 15/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import UIKit

fileprivate enum Scheme: String {
    case initialize = "initialize"
    case imageOpen = "image.open"
    case imageUpload = "image.upload"
    case toastShow = "toast.show"
    case progressShow = "progress.show"
    case progressHide = "progress.hide"
}

class WebViewController: DrawerViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var drawerButton: UIBarButtonItem!
    
    var link: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        drawerButton.target = revealViewController()
        drawerButton.action = #selector(SWRevealViewController.revealToggle(_:))
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
                button.tintColor = UIColor.black
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
}

extension WebViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else {
            return false
        }
        if let scheme = url.scheme {
            switch scheme {
            case Scheme.toastShow.rawValue:
                if let message = self.getArgs(scheme) {
                    self.showMessage(message)
                }
                return false
            case Scheme.imageOpen.rawValue:
                
                return false
            case Scheme.imageUpload.rawValue:
                
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
