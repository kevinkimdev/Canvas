//
//  AnyCache.swift
//  Canvas
//
//  Created by Sam Soffes on 5/6/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

struct AnyCache<T>: Cache {
	
	// MARK: - Properties
	
	private let _get: (String, T? -> Void) -> ()
	private let _set: (String, T, (() -> Void)?) -> ()
	private let _remove: (String, (() -> Void)?) -> ()
	private let _removeAll: ((() -> Void)?) -> ()
	
	
	// MARK: - Initializers
	
	init<C: Cache where T == C.Element>(_ cache: C) {
		_get = { cache.get(key: $0, completion: $1) }
		_set = { cache.set(key: $0, value: $1, completion: $2) }
		_remove = { cache.remove(key: $0, completion: $1) }
		_removeAll = { cache.removeAll(completion: $0) }
	}
	
	
	// MARK: - Cache
	
	func get(key key: String, completion: (T? -> Void)) {
		_get(key, completion)
	}
	
	func set(key key: String, value: T, completion: (() -> Void)?) {
		_set(key, value, completion)
	}
	
	func remove(key key: String, completion: (() -> Void)?) {
		_remove(key, completion)
	}
	
	func removeAll(completion completion: (() -> Void)?) {
		_removeAll(completion)
	}
}
