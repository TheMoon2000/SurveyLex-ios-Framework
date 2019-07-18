// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import Foundation
import AVFoundation

class Recorder: NSObject, AVAudioRecorderDelegate {

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioFilename: URL!
    var audioPlayer: AVAudioPlayer!
    var metertimer : Timer? = nil
    var hasMicPermission: Bool = false
    
    required init(fileURL: URL) {
        super.init()
        
        recordingSession = AVAudioSession.sharedInstance()
        audioFilename = fileURL
        createRecorder()
        
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
        if (!self.hasMicPermission) {
            // if not, we ask it
            requestPermission(completion:{(allowed: Bool) -> Void in
                if (!allowed) {
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
            AVSampleRateKey: 44000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        self.audioRecorder = try! AVAudioRecorder(url: self.audioFilename, settings: settings)
        
        self.audioRecorder.delegate = self
        return true
    }
    
    /// Playback the recording.
    func playCapture() {
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try audioPlayer = AVAudioPlayer(contentsOf: self.audioFilename!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("unable to play back")
        }
    }
    
    @objc private func updateAudioMeter() {
        self.audioRecorder.updateMeters()
        let dBLevel = self.audioRecorder.averagePower(forChannel: 0)
        let peaklevel = self.audioRecorder.peakPower(forChannel: 0)
    }
    
    /// All types of errors that could have occurred during an attempt to record an audio.
    enum Error {
        /// The app does not have permission to access the microphone.
        case micAccess
        
        /// The app is unable to write to the audio data to the designated path.
        case fileWrite
        
        /// Recording length was less than the minimum requirement.
        case tooShort
    }
}
