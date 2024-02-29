//
//  SpeechRecognizerConstants.swift
//  SpeechRecognizer
//
//  Created by bighiung on 2024/2/27.
//

import Foundation
import Speech

enum SpeechRecogAuthStatus {
    case denied
    case notDetermined
    case authorized
    case restricted
    
    static func fromSFStatus(_ authStatus: SFSpeechRecognizerAuthorizationStatus) -> SpeechRecogAuthStatus {

        switch authStatus {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            break
        }
        return .notDetermined

    }

}

enum SpeechRecognizerStatus {
    case pause
    case notStarted
    case running
    case interrupted
    case starting
}
