/*
 Copyright 2019 New Vector Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit
import Reusable

protocol SlidingModalContainerViewDelegate: class {
    func slidingModalContainerViewDidTapBackground(_ view: SlidingModalContainerView)
}

/// `SlidingModalContainerView` is a custom UIView used as a `UIViewControllerContextTransitioning.containerView` subview to embed a `SlidingModalPresentable` during presentation.
final class SlidingModalContainerView: UIView, Themable, NibLoadable {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 12.0
        static let dimmingColorAlpha: CGFloat = 0.7
    }
    
    private enum Sizing {
        static let view = SlidingModalContainerView.loadFromNib()
        static var widthConstraint: NSLayoutConstraint?
        static var heightConstraint: NSLayoutConstraint?
    }
    
    // MARK: - Properties
    
    // MARK: Outlets
    
    @IBOutlet private weak var dimmingView: UIView!
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var contentViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: Private
    
    private var dismissContentViewBottomConstant: CGFloat {
        let bottomSafeAreaHeight: CGFloat
        
        if #available(iOS 11.0, *) {
            bottomSafeAreaHeight = self.contentView.safeAreaInsets.bottom
        } else {
            bottomSafeAreaHeight = 0
        }
        
        return -(self.contentViewHeightConstraint.constant + bottomSafeAreaHeight)
    }
    
    // MARK: Public
    
    var contentViewFrame: CGRect {
        return self.contentView.frame
    }
    
    weak var delegate: SlidingModalContainerViewDelegate?
    
    // MARK: - Setup
    
    static func instantiate() -> SlidingModalContainerView {
        return SlidingModalContainerView.loadFromNib()
    }
        
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.masksToBounds = true
        self.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(Constants.dimmingColorAlpha)

        self.setupBackgroundTapGestureRecognizer()
        
        self.update(theme: ThemeService.shared().theme)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layer.cornerRadius = Constants.cornerRadius
    }
    
    // MARK: - Public
    
    func preparePresentAnimation() {
        self.contentViewBottomConstraint.constant = 0
    }
    
    func prepareDismissAnimation() {
        self.contentViewBottomConstraint.constant = self.dismissContentViewBottomConstant
    }
    
    func update(theme: Theme) {
        self.contentView.backgroundColor = theme.headerBackgroundColor
    }
    
    func updateContentViewMaxHeight(_ maxHeight: CGFloat) {
        self.contentViewHeightConstraint.constant = maxHeight
    }
    
    func updateContentViewLayout() {
        self.layoutIfNeeded()
    }
    
    func setContentView(_ contentView: UIView) {
        for subView in self.contentView.subviews {
            subView.removeFromSuperview()
        }
        self.contentView.vc_addSubViewMatchingParent(contentView)
    }
    
    func updateDimmingViewAlpha(_ alpha: CGFloat) {
        self.dimmingView.alpha = alpha
    }
    
    func contentViewWidthFittingSize(_ size: CGSize) -> CGFloat {
        let sizingView = SlidingModalContainerView.Sizing.view
        
        if let widthConstraint = SlidingModalContainerView.Sizing.widthConstraint {
            widthConstraint.constant = size.width
        } else {
            let widthConstraint = sizingView.widthAnchor.constraint(equalToConstant: size.width)
            widthConstraint.isActive = true
            SlidingModalContainerView.Sizing.widthConstraint = widthConstraint
        }
        
        if let heightConstraint = SlidingModalContainerView.Sizing.heightConstraint {
            heightConstraint.constant = size.height
        } else {
            let heightConstraint = sizingView.heightAnchor.constraint(equalToConstant: size.width)
            heightConstraint.isActive = true
            SlidingModalContainerView.Sizing.heightConstraint = heightConstraint
        }        
        
        sizingView.setNeedsLayout()
        sizingView.layoutIfNeeded()                
        
        return sizingView.contentViewFrame.width
    }
    
    // MARK: - Private
    
    private func setupBackgroundTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        self.dimmingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func handleBackgroundTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.delegate?.slidingModalContainerViewDidTapBackground(self)
    }
}
