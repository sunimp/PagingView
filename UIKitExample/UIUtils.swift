//
//  UIUtils.swift
//  Example
//
//  Created by Sun on 2024/7/26.
//

import UIKit

public enum UIUtils {
    
    public static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarHeight
    }
    
    public static let navigationBarHeight: CGFloat = {
        return 44.0
    }()
    
    public static var topBarHeight: CGFloat {
        return statusBarHeight + navigationBarHeight
    }
    
    public static var screenWidth: CGFloat {
        guard let screen = UIApplication.shared.activeScreen else {
            return UIScreen.main.bounds.width
        }
        return screen.bounds.width
    }
    
    public static var screenHeight: CGFloat {
        guard let screen = UIApplication.shared.activeScreen else {
            return UIScreen.main.bounds.height
        }
        return screen.bounds.height
    }
    
    public static var safeAreaInsets: UIEdgeInsets {
        return UIApplication.shared.safeAreaInsets
    }
}

extension UIApplication {
    
    /// Active windowScene
    public var activeWindowScene: UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive })
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })
    }
    
    /// Active window
    public var activeWindow: UIWindow? {
        return self.activeWindowScene?.windows.first(where: \.isKeyWindow)
    }
    
    /// Active screen
    public var activeScreen: UIScreen? {
        return self.activeWindow?.screen
    }
    
    public var statusBarHeight: CGFloat {
        return self.activeWindowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
    public var safeAreaInsets: UIEdgeInsets {
        return self.activeWindow?.safeAreaInsets ?? .zero
    }
}
