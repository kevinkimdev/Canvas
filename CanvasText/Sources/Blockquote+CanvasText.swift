//
//  Blockquote+CanvasText.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/8/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import CanvasNative

extension Blockquote: Annotatable {
	public func annotation(theme: Theme) -> Annotation? {
		return BlockquoteBorderView(block: self, theme: theme)
	}
}
