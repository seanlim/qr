//
//  QRContentView.swift
//  QR
//
//  Created by Sean Lim on 19/4/20.
//  Copyright © 2020 Sean Lim. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class QRContentView: UIView {
  var content: String? // Since we're using this to diff content views, maybe make this a hash?
  var webView: WKWebView?
  
  init(content: String, frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor(red: 0.07, green: 0.45, blue: 0.87, alpha: 0.50)
    self.updateCornerRadius()
    
    // Work with content
    self.content = content
    
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
    
    if matches.count != 0 {
      self.loadWebContent(matches[0].url!.absoluteString)
    }
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  public func updatePosition(_ bounds: CGRect) {
    self.frame = bounds
    self.updateCornerRadius()
  }
  
  private func updateCornerRadius() {
    self.layer.cornerRadius = 15.0
    self.layer.masksToBounds = true
  }
  
  private func loadWebContent(_ urlString: String) {
    webView = WKWebView()
    webView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    webView?.load(urlString)
    print(urlString)
    self.addSubview(webView!)
  }
}

extension WKWebView {
  func load(_ urlString: String) {
    if let url = URL(string: urlString) {
      // Convert to https
      var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
      comps.scheme = "https"
      let request = URLRequest(url: comps.url!)
      load(request)
    }
  }
}
