//
//  Imgix.swift
//  CanvasCore
//
//  Created by Sam Soffes on 5/5/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import Foundation
import Crypto

public struct Imgix {
	
	// MARK: - Properties
	
	public let host: String
	public let secret: String
	public let defaultParameters: [NSURLQueryItem]?
	
	
	// MARK: - Initializers
	
	public init(host: String, secret: String, defaultParameters: [NSURLQueryItem]? = nil) {
		self.host = host
		self.secret = secret
		self.defaultParameters = defaultParameters
	}
	
	
	// MARK: - Building URLs
	
	public func sign(path input: String) -> NSURL? {
		// Get components
		let path = (input.hasPrefix("/") ? "" : "/") + input
		guard let components = NSURLComponents(string: "https://\(host + path)") else { return nil }
		
		// Apply default query items
		var queryItems = components.queryItems ?? []
		if let defaultParameters = defaultParameters where !defaultParameters.isEmpty {
			queryItems += defaultParameters
			components.queryItems = queryItems
		}
		
		// Calculate signature
		var base = secret + path
		if let query = components.query where !query.isEmpty {
			base += "?\(query)"
		}
		
		guard let signature = base.MD5 else { return nil }
		
		// Apply signature
		queryItems.append(NSURLQueryItem(name: "s", value: signature))
		components.queryItems = queryItems
		
		// Return signed URL
		return components.URL
	}
}
