//
//  MainViewController.swift
//  SpeechRecognizer
//
//  Created by bighiung on 2024/2/26.
//

import UIKit
import Speech

class MainViewController: UIViewController, SpeechRecognizerDelegate {

    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var startResumeButton: UIButton!

    @IBOutlet weak var clearButton: UIButton!

    private let speechRecognizer = SpeechRecognizer()

    private var resultStrings = [String]()

    private var presentationString: String {
        var totalString = ""
        for str in self.resultStrings {
            totalString.append(str)
            totalString.append("\n\n")
        }
        return totalString
    }

    private var lastResultString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configUI()
    }

    private func configUI() {
        startResumeButton.setTitle("暂停语音识别", for: .selected)
        speechRecognizer.delegate = self
        clearButton.addTarget(self, action: #selector(clearHistoryResults), for: .touchUpInside)
    }

}

extension MainViewController {

    @IBAction func startStopButtonClicked(_ sender: Any) {
        if speechRecognizer.available {
            switch speechRecognizer.currentStatus {
            case .running:
                pause()
            case .notStarted, .pause:
                start()
            case .interrupted:
                self.view.showToast(message: "当前语音识别因为不可抗力暂时中断，无法立即恢复")
            default:
                break
            }
        } else {
            // Inform user that speech recognizer may not available because of autorization
            self.view.showToast(message: "当前语音识别不可用，可能需要你打开授权！")
        }
    }

    @IBAction func clearHistoryResults(_ sender: Any) {
        resultStrings.removeAll(keepingCapacity: true)
        adjustUI()
    }

    func start() {
        speechRecognizer.startRecognizing()
        adjustUI()
    }

    func pause() {
        speechRecognizer.pause()
        adjustUI()
    }
    
    func adjustUI() {
        startResumeButton.isSelected = speechRecognizer.isRunning
        let displayString = presentationString + "\n" + lastResultString
        textView.text = displayString
    }
    
    func recordLastResult() {
        if lastResultString.count > 0 {
            resultStrings.append(lastResultString)
        }
        lastResultString = ""
    }
}

extension MainViewController {

    func resultGenerated(recognizer: SpeechRecognizer,
                         latestText: String) {
        guard latestText.count > 0 else { return }
        lastResultString = latestText
        adjustUI()
    }

    func onError(recognizer: SpeechRecognizer) {
        self.view.showToast(message: "语音识别出现故障，暂时终止！")
        adjustUI()
    }

    func speechAuthorizationStatusChanged(recognizer: SpeechRecognizer,
                                          authorizationStatus: SpeechRecogAuthStatus) {

    }

    func onPause(recognizer: SpeechRecognizer) {
        adjustUI()
    }

    func onInterrupted(recognizer: SpeechRecognizer) {
        self.view.showToast(message: "语音识别暂时中断")
        recordLastResult()
        adjustUI()
    }

    func onRecoverFromInterruption(recognizer: SpeechRecognizer) {
        recordLastResult()
        adjustUI()
    }

}
