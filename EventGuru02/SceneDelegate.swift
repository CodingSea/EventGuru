import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create a new UIWindow for the windowScene
        window = UIWindow(windowScene: windowScene)

        // Load the AdminDash storyboard
        let storyboard = UIStoryboard(name: "AdminDash", bundle: nil)

        // Instantiate the AdminRegisterViewController from the storyboard
        if let adminRegisterVC = storyboard.instantiateViewController(withIdentifier: "AdminRegisterViewController") as? AdminRegisterViewController {
            // Embed in a navigation controller (optional)
            let navigationController = UINavigationController(rootViewController: adminRegisterVC)
            window?.rootViewController = navigationController
        } else {
            print("Error: AdminRegisterViewController could not be found in AdminDash storyboard.")
        }

        // Make the window key and visible
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
