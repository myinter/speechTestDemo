# speechTestDemo
A demo of a speech recognizer that can continue voice recognition after switching to the background will callin handling

# iOS Speech Recognizer

## Features:

1. **Encapsulation of `SFSpeechRecognizer`:** The recognizer is wrapped to seamlessly integrate the recording functionality of `AVAudioEngine` with the speech recognition capabilities of `SFSpeechRecognizer`, enhancing user-friendliness.

2. **Unified State Changes and Exception Handling:** The state changes during the speech recognition process and exception handling are consolidated and handled uniformly, relieving the caller from the need to implement additional procedures.

3. **Automated Call Handling:** Streamlining incoming calls, the recognizer can automatically pause and resume both recording and speech recognition processes, ensuring a seamless user experience.

