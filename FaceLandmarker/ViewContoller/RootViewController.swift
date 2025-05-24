// Copyright 2023 The MediaPipe Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

protocol InferenceResultDeliveryDelegate: AnyObject {
  func didPerformInference(result: ResultBundle?)
}

protocol InterfaceUpdatesDelegate: AnyObject {
  func shouldClicksBeEnabled(_ isEnabled: Bool)
}

/** The view controller is responsible for presenting and handling the tabbed controls for switching between the live camera feed and
  * media library view controllers. It also handles the presentation of the inferenceVC
  */
class RootViewController: UIViewController {

  // MARK: Storyboards Connections
  @IBOutlet weak var tabBarContainerView: UIView!
  @IBOutlet weak var bottomSheetViewBottomSpace: NSLayoutConstraint!
  @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
  
  // MARK: Constants
  private struct Constants {
    static let inferenceBottomHeight = 304.0
    static let expandButtonHeight = 41.0
    static let expandButtonTopSpace = 10.0
    static let cameraViewControllerStoryBoardId = "CAMERA_VIEW_CONTROLLER"
    static let storyBoardName = "Main"
    static let inferenceVCEmbedSegueName = "EMBED"
    static let tabBarItemsCount = 2
  }
  
  // MARK: Controllers that manage functionality
  private var inferenceViewController: BottomSheetViewController?
  private var cameraViewController: CameraViewController?
  
  // MARK: Private Instance Variables
  private var totalBottomSheetHeight: CGFloat {
    guard let isOpen = inferenceViewController?.toggleBottomSheetButton.isSelected else {
      return 0.0
    }
    
    return isOpen ? Constants.inferenceBottomHeight - self.view.safeAreaInsets.bottom
      : Constants.expandButtonHeight + Constants.expandButtonTopSpace
  }

  // MARK: View Handling Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    // Create face landmarker helper
    
    inferenceViewController?.isUIEnabled = true
    instantiateCameraViewController()
    switchTo(childViewController: cameraViewController, fromViewController: nil)
  }
    func switchTo(
      childViewController: UIViewController?,
      fromViewController: UIViewController?) {
      fromViewController?.willMove(toParent: nil)
      fromViewController?.view.removeFromSuperview()
      fromViewController?.removeFromParent()
      
      guard let childViewController = childViewController else {
        return
      }
        
      addChild(childViewController)
      childViewController.view.translatesAutoresizingMaskIntoConstraints = false
      tabBarContainerView.addSubview(childViewController.view)
      NSLayoutConstraint.activate(
        [
          childViewController.view.leadingAnchor.constraint(
            equalTo: tabBarContainerView.leadingAnchor,
            constant: 0.0),
          childViewController.view.trailingAnchor.constraint(
            equalTo: tabBarContainerView.trailingAnchor,
            constant: 0.0),
          childViewController.view.topAnchor.constraint(
            equalTo: tabBarContainerView.topAnchor,
            constant: 0.0),
          childViewController.view.bottomAnchor.constraint(
            equalTo: tabBarContainerView.bottomAnchor,
            constant: 0.0)
        ]
      )
      childViewController.didMove(toParent: self)
    }
    
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    guard inferenceViewController?.toggleBottomSheetButton.isSelected == true else {
      bottomSheetViewBottomSpace.constant = -Constants.inferenceBottomHeight
      + Constants.expandButtonHeight
      + self.view.safeAreaInsets.bottom
      + Constants.expandButtonTopSpace
      return
    }
    
    bottomSheetViewBottomSpace.constant = 0.0
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: Storyboard Segue Handlers
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if segue.identifier == Constants.inferenceVCEmbedSegueName {
      inferenceViewController = segue.destination as? BottomSheetViewController
      inferenceViewController?.delegate = self
      bottomViewHeightConstraint.constant = Constants.inferenceBottomHeight
      view.layoutSubviews()
    }
  }
  
  // MARK: Private Methods
  private func instantiateCameraViewController() {
    guard cameraViewController == nil else {
      return
    }
    
    guard let viewController = UIStoryboard(
      name: Constants.storyBoardName, bundle: .main)
      .instantiateViewController(
        withIdentifier: Constants.cameraViewControllerStoryBoardId) as? CameraViewController else {
      return
    }
  
    cameraViewController = viewController
  }
  

}


// MARK: InferenceResultDeliveryDelegate Methods
extension RootViewController: InferenceResultDeliveryDelegate {
  func didPerformInference(result: ResultBundle?) {
    var inferenceTimeString = ""
    
    if let inferenceTime = result?.inferenceTime {
      inferenceTimeString = String(format: "%.2fms", inferenceTime)
    }
    inferenceViewController?.update(inferenceTimeString: inferenceTimeString)
  }
}

// MARK: InterfaceUpdatesDelegate Methods
extension RootViewController: InterfaceUpdatesDelegate {
  func shouldClicksBeEnabled(_ isEnabled: Bool) {
    inferenceViewController?.isUIEnabled = isEnabled
  }
}

// MARK: InferenceViewControllerDelegate Methods
extension RootViewController: BottomSheetViewControllerDelegate {
  func viewController(
    _ viewController: BottomSheetViewController,
    didSwitchBottomSheetViewState isOpen: Bool) {
      if isOpen == true {
        bottomSheetViewBottomSpace.constant = 0.0
      }
      else {
        bottomSheetViewBottomSpace.constant = -Constants.inferenceBottomHeight
        + Constants.expandButtonHeight
        + self.view.safeAreaInsets.bottom
        + Constants.expandButtonTopSpace
      }
      
      UIView.animate(withDuration: 0.3) {[weak self] in
        guard let weakSelf = self else {
          return
        }
        weakSelf.view.layoutSubviews()
      }
    }
}
