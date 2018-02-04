import CanvasCore
import UIKit

final class SplitViewController: UISplitViewController {

    // MARK: - Properties

	private var lastSize: CGSize?
    // MARK: - Initializers

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		preferredDisplayMode = .allVisible
		delegate = self
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    // MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = Swatch.lightGray
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// Work around wrong automatic primary column calculatations by UISplitViewController
		guard let window = view.window, lastSize != window.bounds.size else { return }

		lastSize = window.bounds.size

		let screen = window.screen
		let width: CGFloat

		if window.bounds.width < screen.bounds.width {
			width = 258
		} else {
			width = window.bounds.width > 1024 ? 375 : 320
		}

		minimumPrimaryColumnWidth = width
		maximumPrimaryColumnWidth = width
	}

	override func show(_ viewController: UIViewController, sender: Any?) {
		// Prevent weird animation *sigh*
		UIView.performWithoutAnimation {
			super.show(viewController, sender: sender)
			self.view.layoutIfNeeded()
			viewController.view.layoutIfNeeded()
		}
	}

    // MARK: - Private

	@objc private func toggleSidebar() {
		let mode: UISplitViewControllerDisplayMode = displayMode == .allVisible ? .primaryHidden : .allVisible

		UIView.animate(withDuration: 0.2) {
			self.preferredDisplayMode = mode
		}
	}
}

extension SplitViewController: UISplitViewControllerDelegate {
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
		if !isEmpty(secondaryViewController: secondaryViewController) {
			var target = secondaryViewController
			if let top = (secondaryViewController as? UINavigationController)?.topViewController {
				target = top
			}

			target.navigationItem.leftBarButtonItem = nil
			return false
		}

		return true
	}

	func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
		guard let primaryViewController = primaryViewController as? UINavigationController else { return nil }

		var viewControllers = [UIViewController]()

		for viewController in primaryViewController.viewControllers {
			if let navigationController = viewController as? UINavigationController {
				viewControllers += navigationController.viewControllers
			} else {
				viewControllers.append(viewController)
			}
		}

		let detailViewController: UIViewController

		if let last = viewControllers.last, last is EditorViewController || last is PlaceholderViewController {
			detailViewController = viewControllers.popLast() ?? PlaceholderViewController()
		} else {
			detailViewController = PlaceholderViewController()
		}

		primaryViewController.setViewControllers(viewControllers, animated: false)

		if !(detailViewController is PlaceholderViewController) {
			detailViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "SidebarLeft"), style: .plain, target: self, action: #selector(toggleSidebar))
		}

		return NavigationController(rootViewController: detailViewController)
	}

	func splitViewController(splitViewController: UISplitViewController, showDetailViewController viewController: UIViewController, sender: Any?) -> Bool {
		var detail = viewController
		if let top = (detail as? UINavigationController)?.topViewController {
			detail = top
		}

		let isPlaceholder = detail is PlaceholderViewController
		if !isPlaceholder && !isCollapsed {
			detail.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "SidebarLeft"), style: .plain, target: self, action: #selector(toggleSidebar))
		}

		UIView.animate(withDuration: 0.2) {
			splitViewController.preferredDisplayMode = isPlaceholder ? .allVisible : .automatic
		}

		return false
	}

	func targetDisplayModeForActionInSplitViewController(splitViewController: UISplitViewController) -> UISplitViewControllerDisplayMode {
		switch splitViewController.displayMode {
		case .primaryOverlay, .primaryHidden: return .allVisible
		default: return .primaryHidden
		}
	}

	private func isEmpty(secondaryViewController: UIViewController? = nil) -> Bool {
		let viewController = secondaryViewController ?? detailViewController
		if let secondaryNavigationController = viewController as? UINavigationController {
			return secondaryNavigationController.topViewController is PlaceholderViewController
		}

		return false
	}
}
