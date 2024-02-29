//
//  SpeechRecognizer.swift
//  SpeechRecognizer
//
//  Created by bighiung on 2024/2/26.
//

import Foundation
import AVFoundation
import Speech
import CallKit

protocol SpeechRecognizerDelegate {
    
    func resultGenerated(recognizer: SpeechRecognizer,
                         latestText: String)

    func onError(recognizer: SpeechRecognizer)

    func onInterrupted(recognizer: SpeechRecognizer)

    func onRecoverFromInterruption(recognizer: SpeechRecognizer)

    func onPause(recognizer: SpeechRecognizer)

    func speechAuthorizationStatusChanged(recognizer: SpeechRecognizer,
                                          authorizationStatus: SpeechRecogAuthStatus)

}

class SpeechRecognizer: NSObject,
                            SFSpeechRecognizerDelegate,
                            CXCallObserverDelegate {

    private var workingStatus: SpeechRecognizerStatus = .notStarted

    public var currentStatus: SpeechRecognizerStatus {
        return workingStatus
    }

    public var isRunning: Bool {
        return workingStatus == .running
    }

    public var delegate: SpeechRecognizerDelegate?
    private(set) var available = false
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private let callObserver = CXCallObserver()
    private let resultBuffer = [String]()

    deinit {
        stopRecognizing()
    }

    init(lang: String = "zh_Hans_CN") {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        super.init()
        // Register notif for call in and call out
        callObserver.setDelegate(self,
                                 queue: .main)
        // Request authorization from user for voice recognization
        requestAuthorization()
    }

}

extension SpeechRecognizer {
    //MARK: - SFSpeechRecognizerDelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                          availabilityDidChange available: Bool) {
        if available {
            // Placeholder for future

        } else {
            stopRecognizing()
        }
    }
}

// Working status switching related methods
extension SpeechRecognizer {

    public func startRecognizing() {

            guard available else { return }
            guard workingStatus != .running else { return }

            workingStatus = .starting

            //
            recognitionTask?.cancel()
            self.recognitionTask = nil
    
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(.record, mode: .measurement, options: .allowBluetooth)
            try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

            guard let recognitionRequest = recognitionRequest else {
                #if DEBUG
                fatalError("SFSpeechAudioBufferRecognitionRequest creation failed,process cannot be continued")
                #endif
            }
    
            recognitionRequest.shouldReportPartialResults = true
            
            audioEngine = AVAudioEngine()
            // Adjust audioEngine
            audioEngine.reset()
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            func audioInputIsBusy(recordingFormat: AVAudioFormat) -> Bool {
                guard recordingFormat.sampleRate == 0 || recordingFormat.channelCount == 0 else {
                    return false
                }
                return true
            }

            if audioInputIsBusy(recordingFormat: recordingFormat) {
                tryStartAgainLater()
                return
            }

            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                recognitionRequest.append(buffer)
            }
            // Start audio engine
            audioEngine.prepare()
            try? audioEngine.start()

            // Start a recording and speech recognition process
            fireRecognizationTask()
    }

    private func tryStartAgainLater() {
        self.workingStatus = .starting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startRecognizing()
        }
    }

    public func stopRecognizing() {
        guard workingStatus != .notStarted else { return }
        // Stop audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        // End recognition request
        recognitionRequest?.endAudio()

        // Cancel recognition task
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil

        workingStatus = .notStarted

    }

    public func pause() {
        guard workingStatus == .running else { return }
        stopRecognizing()
        workingStatus = .pause
        self.delegate?.onPause(recognizer: self)
    }

    public func fireRecognizationTask() {
        // Make sure there was an identification request in pause
        guard let recognitionRequest = recognitionRequest else {
            return
        }
        // Under the status running,resume cannot be performed
        guard workingStatus != .running else { return }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in

            guard let self = self else { return }
            guard self.workingStatus == .running else { return }

            var isFinal = false

            if let result = result {
                // Output the result of recognization
                let text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                self.delegate?.resultGenerated(recognizer: self,
                                               latestText: text)
            }

            if error != nil || isFinal {
                // stop Recognizing
                self.stopRecognizing()
                if let _ = error {
                    if self.workingStatus == .running {
                        self.delegate?.onError(recognizer: self)
                    }
                }
            }

        })

        if workingStatus == .interrupted {
            self.delegate?.onRecoverFromInterruption(recognizer: self)
        }

        workingStatus = .running
        
    }

    private func interrupt() {
        guard workingStatus != .interrupted else { return }
        stopRecognizing()
        workingStatus = .interrupted
    }

}

// Permission authorization related methods
extension SpeechRecognizer {

    private func checkAuthorization() {

        let currentAuthorizationStatus = SFSpeechRecognizer.authorizationStatus()
        switch currentAuthorizationStatus {
        case .authorized:
            available = true
        case .denied, .restricted, .notDetermined:
            requestAuthorization()
            break
        @unknown default:
            break
        }

    }

    private func requestAuthorization() {

        SFSpeechRecognizer.requestAuthorization { [weak self] (authStatus) in

            guard let self = self else { return }

            switch authStatus {
            case .authorized:
                self.available = true
            case .denied, .restricted, .notDetermined:
                self.available = false
            @unknown default:
                break
            }

            self.delegate?.speechAuthorizationStatusChanged(recognizer: self,
                                                            authorizationStatus: SpeechRecogAuthStatus.fromSFStatus(authStatus))

        }
    }

}

// Listen for incoming calls and process them
extension SpeechRecognizer {

    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded {
            // If recording was previously enabled, restore recognition
            if workingStatus == .interrupted {
                DispatchQueue.main.async {
                    self.startRecognizing()
                }
            }
        } else {
            // Otherwise interrupts recognition
            DispatchQueue.main.async {
                self.interrupt()
                self.delegate?.onInterrupted(recognizer: self)
            }
        }

    }

}
