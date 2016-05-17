//
//  Annotation.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

public enum AnnotationPlacement {
	case FirstLeadingGutter
	case ExpandedLeadingGutter
	case ExpandedBackground

	public var isExpanded: Bool {
		switch self {
		case .ExpandedLeadingGutter, .ExpandedBackground: return true
		default: return false
		}
	}
}

public protocol Annotation: class {
	var block: Annotatable { get set }
	var theme: Theme { get set }
	var view: View { get }
	var placement: AnnotationPlacement { get }

	var horizontalSizeClass: UserInterfaceSizeClass { get set }

	init?(block: Annotatable, theme: Theme)
}


extension Annotation where Self: View {
	public var view: View {
		return self
	}

	public var placement: AnnotationPlacement {
		return .FirstLeadingGutter
	}
}
