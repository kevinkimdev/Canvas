//
//  OAuthClient+Canvas.swift
//  CanvasCore
//
//  Created by Sam Soffes on 8/12/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasKit

extension OAuthClient {
	public init() {
		self.init(clientID: config.canvasClientID, clientSecret: config.canvasClientSecret, baseURL: config.environment.apiURL)
	}
}
