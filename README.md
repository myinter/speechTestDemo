# speechTestDemo
A demo of a speech recognizer that can continue voice recognition after switching to the background will callin handling

Open the project file with XCode and run it directly without any third-party dependencies.

# iOS Speech Recognizer

## Features:

1. **Encapsulation of `SFSpeechRecognizer`:** The recognizer is wrapped to seamlessly integrate the recording functionality of `AVAudioEngine` with the speech recognition capabilities of `SFSpeechRecognizer`, enhancing user-friendliness.

2. **Unified State Changes and Exception Handling:** The state changes during the speech recognition process and exception handling are consolidated and handled uniformly, relieving the caller from the need to implement additional procedures.

3. **Automated Call Handling:** Streamlining incoming calls, the recognizer can automatically pause and resume both recording and speech recognition processes, ensuring a seamless user experience.

Video presentation:

https://github.com/myinter/speechTestDemo/assets/4507514/edda0cd7-6e6e-4eab-a266-f652b7e351bd

https://github.com/myinter/speechTestDemo/assets/4507514/b28ee898-3ec2-40b2-9685-f2cfa5616e99

