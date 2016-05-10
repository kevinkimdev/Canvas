//
//  Cache.swift
//  Canvas
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

protocol Cache {
	associatedtype Element
	
	func get(key key: String, completion: (Element? -> Void))
	func set(key key: String, value: Element, completion: (() -> Void)?)
	func remove(key key: String, completion: (() -> Void)?)
	func removeAll(completion completion: (() -> Void)?)
}
