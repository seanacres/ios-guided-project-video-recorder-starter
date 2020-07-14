//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    lazy private var player: AVPlayer = AVPlayer()
    private var playerView: VideoPlayerView!
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!


	override func viewDidLoad() {
		super.viewDidLoad()

		// Resize camera preview to fill the entire screen
		cameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
        setUpCamera()
	}
    
    override func viewDidAppear(_ animated: Bool) {
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    
    func playMovie(url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        
        if playerView == nil {
            playerView = VideoPlayerView()
            playerView.player = player
            
            var topRect = view.bounds
            topRect.size.width /= 4
            topRect.size.height /= 4
            topRect.origin.y = view.layoutMargins.top
            
            playerView.frame = topRect
            view.addSubview(playerView)
        }
        
        player.play()
        
    }
    
    private func setUpCamera() {
        let camera = bestCamera()
        let microphone = bestMicrophone()
        
        captureSession.beginConfiguration()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            preconditionFailure("No input device")
        }
        
        guard let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
            preconditionFailure("No input device")
        }
        
        guard captureSession.canAddInput(cameraInput) else {
            preconditionFailure("This session can't use this type of input: \(cameraInput)")
        }
        
        captureSession.addInput(cameraInput)
        
        guard captureSession.canAddInput(microphoneInput) else {
                   preconditionFailure("This session can't use this type of input: \(microphoneInput)")
               }
               
        captureSession.addInput(microphoneInput)
               
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        guard captureSession.canAddOutput(fileOutput) else {
            preconditionFailure("Cannot add movie output")
        }
        
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        preconditionFailure("No camera available")
    }
    
    private func bestMicrophone() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        
        preconditionFailure()
    }


    @IBAction func recordButtonPressed(_ sender: Any) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
	}
	
	/// Creates a new file URL in the documents directory
	private func newRecordingURL() -> URL {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]

		let name = formatter.string(from: Date())
		let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
		return fileURL
	}
    
    func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("error saving video \(error)")
        }
        
        playMovie(url: outputFileURL)
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}


