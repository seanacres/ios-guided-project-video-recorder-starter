//
//  ViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		requestPermissionAndShowCamera()
	}
    
    private func requestPermissionAndShowCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            requestVideoPermission()
        case .restricted:
            preconditionFailure("Video is disabled")
        case .denied:
            preconditionFailure("Tell the user they need to grant permissions")
        case .authorized:
            showCamera()
        @unknown default:
            preconditionFailure("A new status code was added that was not handled")
        }
    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (isGranted) in
            guard isGranted else {
                preconditionFailure("Access not granted")
            }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
	
	private func showCamera() {
		performSegue(withIdentifier: "ShowCamera", sender: self)
	}
}
