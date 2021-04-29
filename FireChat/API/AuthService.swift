
import UIKit
import Firebase
import JGProgressHUD

struct RegistrationCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    static let hud = JGProgressHUD()
    
    func logUserIn(email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func createUser(credentials: RegistrationCredentials, completion: ((Error?)-> Void)?) {
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let reference = Storage.storage().reference(withPath: "/profile_images/\(fileName)")
        
        reference.putData(imageData, metadata: nil, completion: { metadata, error in
            if let error = error {
                completion!(error)
                return
            }
            
            reference.downloadURL { (url, error) in
                guard let profileImageURL = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                    if let error = error {
                        completion!(error)
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
    
                    let data = ["email": credentials.email,
                                "fullName": credentials.fullname,
                                "profileImageURL": profileImageURL,
                                "uid": uid,
                                "username": credentials.username] as [String:Any]
                    
                    Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
                }
            }
        })
    }
}
