import UIKit
import WebKit

final class WebControllerIOS: UIViewController, WKNavigationDelegate, WebController {
    
    @IBOutlet private weak var webView: WebViewWrapperIOS?
    @IBOutlet private weak var preloader: UIActivityIndicatorView?
    @IBOutlet private weak var hostname: UIBarButtonItem?
    
    private var currentRequest: URLRequest?
    private var onResult: ((WebControllerResult) -> ())?
    var onDismiss: (() -> ())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
        webView?.layer.cornerRadius = 0
        webView?.clipsToBounds = true
        webView?.layer.borderWidth = 0 / UIScreen.main.nativeScale
        webView?.layer.borderColor = UIColor.lightGray.cgColor
        webView?.webView.navigationDelegate = self
        preloader?.color = .lightGray
        preloader?.hidesWhenStopped = true
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func load(urlRequest: URLRequest, onResult: @escaping (WebControllerResult) -> ()) {
        self.currentRequest = urlRequest
        self.onResult = onResult
        
        DispatchQueue.main.sync {
            preloader?.startAnimating()
            loadCurrentRequest()
        }
    }
    
    func reload() {
        loadCurrentRequest()
    }
    
    private func loadCurrentRequest() {
        guard let currentRequest = currentRequest else {
            return
        }
        
        webView?.webView.load(currentRequest)
    }
    
    func goBack() {
        webView?.webView.goBack()
    }
    
    func dismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        onResult?(.error(.authorizationCancelled))
    }
    
    @IBAction func hostnamePressed(_ sender: Any) {
        reload()
    }
    
    @IBAction func reloadPressed(_ sender: Any) {
        webView?.webView.reload()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation?) {
        preloader?.stopAnimating()
        onResult?(.response(webView.url))
//        hostname?.title = webView.url?.host
        
//        let label = UILabel()
//        label.text = webView.url?.host
//        label.textColor = .white
//        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
//        hostname?.customView = label
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: Error) {
        onResult?(.error(.webControllerError(error)))
    }
}
