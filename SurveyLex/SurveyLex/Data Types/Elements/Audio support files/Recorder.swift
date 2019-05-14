// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import Foundation
import AVFoundation

class Recorder: NSObject, AVAudioRecorderDelegate {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioFilename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var audioPlayer:AVAudioPlayer!
    var metertimer : Timer? = nil
    var hasMicPermission: Bool = false
    
    init(filename: String) {
        super.init()
        self.recordingSession = AVAudioSession.sharedInstance()
        self.audioFilename = audioFilename.appendingPathComponent(filename + ".m4a")
        self.createRecorder()
        do {
            try self.recordingSession.setCategory(AVAudioSession.Category.record)
            try self.recordingSession.setActive(true)
        } catch {
            // failed to record!
            print("failed to record")
        }
    }
    
    func startRecording(enabledAccess: @escaping (Bool) -> ()) {
        // first we declare the closure to start recording
        let record = { () -> Void in
            self.audioRecorder.record()
            self.audioRecorder.isMeteringEnabled = true;
            self.metertimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateAudioMeter), userInfo: nil, repeats: true);
        }
        
        // then we check if we have mic permission
        if (!self.hasMicPermission){
            // if not, we ask it
            requestPermission(completion:{(allowed: Bool) -> Void in
                if (!allowed) {
                    // if permission wasn't given, we let the webapp now
                    self.hasMicPermission = false
                    enabledAccess(false)
                } else {
                    // if permission was given, we start recording
                    if (self.createRecorder()) {
                        self.hasMicPermission = true
                        record()
                        enabledAccess(true)
                    }
                }
            })
        } else {
            // if we have permission, then we start capturing
            record()
            enabledAccess(true)
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        // first we show the permissions popup
        recordingSession.requestRecordPermission() {allowed in
            DispatchQueue.main.async {
                completion(allowed)
            }
        }
    }
    
    func stopRecording() {
        self.audioRecorder.stop()
        self.metertimer?.invalidate()
    }
    
    func stopPlayingCapture() {
        self.audioPlayer.stop()
    }
    
    private func createRecorder() -> Bool {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: self.audioFilename, settings: settings)
        } catch {
            return false
        }
        
        self.audioRecorder.delegate = self
        return true
    }
    
    /*
    func playCapture() {
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try audioPlayer = AVAudioPlayer(contentsOf: self.audioFilename!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            self.webView?.evaluateJavaScript("nativemsgs('errorplaying')")
        }
    }*/
    
    @objc private func updateAudioMeter() {
        self.audioRecorder.updateMeters()
        let dBLevel = self.audioRecorder.averagePower(forChannel: 0)
        let peaklevel = self.audioRecorder.peakPower(forChannel: 0)
    }
    
    internal func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            do {
                let data: NSData = try NSData(contentsOfFile: self.audioFilename.path)
                // Convert swift dictionary into encoded json
                let encodedData = data.base64EncodedString(options: .endLineWithLineFeed)
            } catch {
                // failed to record!
            }
        }
    }
}
