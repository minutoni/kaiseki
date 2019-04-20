//
//  ViewController.swift
//  kaiseki
//
//  Created by 所　紀彦 on 2019/04/20.
//  Copyright © 2019 所　紀彦. All rights reserved.
//

import UIKit
import Speech


class ViewController: UIViewController ,SFSpeechRecognitionTaskDelegate{

    @IBOutlet var textView: UITextView!
    @IBOutlet var recordButton: UIButton!
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))!
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private let audioEngine = AVAudioEngine()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        recordButton.isEnabled = false
        }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            // 利用可能になったら、録音ボタンを有効にする
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
            recordButton.backgroundColor = UIColor.blue
        } else {
            // 利用できないなら、録音ボタンは無効にする
            recordButton.isEnabled = false
            recordButton.setTitle("現在、使用不可", for: .disabled)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:   // 許可OK
                    self.recordButton.isEnabled = true
                    self.recordButton.backgroundColor = UIColor.blue
                case .denied:       // 拒否
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("録音許可なし", for: .disabled)
                case .restricted:   // 限定
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("このデバイスでは無効", for: .disabled)
                case .notDetermined:// 不明
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("録音機能が無効", for: .disabled)
                }
            }
        }
        
        
        speechRecognizer.delegate = self as? SFSpeechRecognizerDelegate // デリゲート先になる
        
        

    }
    
    
    
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            // 音声エンジン動作中なら停止
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
            recordButton.backgroundColor = UIColor.lightGray
            return
        }
        // 録音を開始する
        try! startRecording()
        recordButton.setTitle("認識を完了する", for: [])
        recordButton.backgroundColor = UIColor.red
    }

    private func startRecording() throws{
        //ここに録音する処理を記述
        if let recognitionTask = recognitionTask {
            //既存タスクがあればキャンセルしてリセット
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record)
        try audioSession.setMode(AVAudioSession.Mode.measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("リクエスト生成エラー")}
        
        recognitionRequest.shouldReportPartialResults = true
        
         let inputNode = audioEngine.inputNode
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            var isFinal = false
        
        
        if let result = result{
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
        if Error.self != nil || isFinal{
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("start recording", for: [])
                self.recordButton.backgroundColor = UIColor.blue
                
        }
        }
                
                audioEngine.prepare() //オーディオエンジン準備
                try audioEngine.start() //オーディオエンジン開始
                
                textView.text = "(認識中、、、そのまま話し続けてください)"
        }
    
}
    



