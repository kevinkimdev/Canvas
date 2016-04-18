//
//  Configuration.swift
//  Canvas
//
//  Created by Sam Soffes on 12/2/15.
//  Copyright © 2015 Canvas Labs, Inc. All rights reserved.
//

import Foundation

// Obfuscated client secret
private let canvasClientSecretPart4 = "aef895c32"
private let canvasClientSecretPart2 = "f5bd59c7866e85"
private let canvasClientSecretPart1 = "60ff40c860274eb9afb6"
private let canvasClientSecretPart3 = "97bdcc48ae89946"

/// Application environment
private let env = Environment.Staging

struct Config {
	// MARK: - Canvas

	/// Canvas API base URL
	static let baseURL = env.baseURL

	/// Canvase realtime base URL
	static let realtimeURL = env.realtimeURL

	/// Canvas presence base URL
	static let presenceURL = env.presenceURL

	/// Canvas client ID
	static let canvasClientID = "5QdrPgUUYQs2yvGLIUT5PL"

	/// Canvas client secret
	static let canvasClientSecret = "\(canvasClientSecretPart1)fb\(canvasClientSecretPart2)2e\(canvasClientSecretPart3)75\(canvasClientSecretPart4)"


	// MARK: - Analytics & Crash Reporting

	/// Mixpanel token
	static let mixpanelToken = "447ae99e6cff699db67f168818c1dbf9"

	/// Hockey app identifier
	static let hockeyIdentifier = "0d558bb833514f31a4be3f9bfeafc43d"
}
