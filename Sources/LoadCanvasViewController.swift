//
//  LoadCanvasViewController.swift
//  Canvas
//
//  Created by Sam Soffes on 5/31/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasCore
import CanvasKit

final class LoadCanvasViewController: UIViewController, Accountable {

	// MARK: - Properties

	var account: Account
	let canvasID: String

	private var fetching = false
	private let activityIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.startAnimating()
		return view
	}()


	// MARK: - Initializers

	init(account: Account, canvasID: String) {
		self.account = account
		self.canvasID = canvasID

		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = Swatch.white
		view.addSubview(activityIndicator)

		navigationItem.hidesBackButton = true

		NSLayoutConstraint.activateConstraints([
			activityIndicator.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor),
			activityIndicator.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor),
		])
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		fetch()
	}


	// MARK: - Private

	private func fetch() {
		if fetching {
			return
		}

		fetching = true

		APIClient(account: account).showCanvas(canvasID: canvasID) { result in
			dispatch_async(dispatch_get_main_queue()) { [weak self] in
				switch result {
				case .Success(let canvas): self?.showEditor(canvas: canvas)
				case .Failure(let message): self?.showError(message: message)
				}
			}
		}
	}

	private func showEditor(canvas canvas: Canvas) {
		guard let navigationController = navigationController else { return }

		let viewController = EditorViewController(account: account, canvas: canvas)
		viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizedString.CloseCommand.string, style: .Plain, target: viewController, action: #selector(EditorViewController.closeNavigationControllerModal))

		var viewControllers = navigationController.viewControllers
		viewControllers[viewControllers.count - 1] = viewController
		navigationController.setViewControllers(viewControllers, animated: false)
	}

	private func showError(message message: String) {
		let alert = UIAlertController(title: LocalizedString.Error.string, message: message, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: LocalizedString.Okay.string, style: .Cancel, handler: { [weak self] _ in
			// TODO: We currently assume this is a modal
			self?.navigationController?.dismissViewControllerAnimated(true, completion: nil)
		}))

		presentViewController(alert, animated: true, completion: nil)
	}
}
