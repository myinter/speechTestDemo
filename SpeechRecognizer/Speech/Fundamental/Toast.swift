//
//  Toast.swift
//  SpeechRecognizer
//
//  Created by bighiung on 2024/2/26.
//

import UIKit


extension UIView {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let width = self.frame.size.width
        let height = self.frame.size.height
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 12)
        toastLabel.text = "  \(message)  "
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        toastLabel.frame = CGRectMake(0.0, 0.0, width * 0.618, 44.0)
        toastLabel.sizeToFit()
        toastLabel.center = CGPoint(x: width / 2.0, y: height / 2.0)
        self.addSubview(toastLabel)

        UIView.animate(withDuration: duration, delay: 0.2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
