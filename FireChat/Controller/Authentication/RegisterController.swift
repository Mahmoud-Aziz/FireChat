
import UIKit
import Firebase

class RegisterController: UIViewController {
    
    //MARK:- Properties
    
    private var viewModel = RegisterViewModel()
    private var profileImage: UIImage?
    
    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.isEnabled = false 
        button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
       let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [.font:UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccountButton), for: .touchUpInside)
       return button
    }()
    
    private lazy var emailContainerView: inputContainerView = {
        return inputContainerView(image: UIImage(systemName: "envelope"), textField: emailTextField)
    }()
    private lazy var passwordContainerView: inputContainerView = {
        return inputContainerView(image: UIImage(systemName: "lock"), textField: passwordTextField)
    }()
    private lazy var fullNameContainerView: inputContainerView = {
        return inputContainerView(image: UIImage(named: "ic_person_outline_white_2x"), textField: fullNameTextField)
    }()
    private lazy var userNameContainerView: inputContainerView = {
        return inputContainerView(image: UIImage(named: "ic_person_outline_white_2x"), textField: userNameTextField)
    }()
    
    private let emailTextField: CustomTextField = CustomTextField(placeholder: "Email")
    private let fullNameTextField: CustomTextField = CustomTextField(placeholder: "Full Name")
    private let userNameTextField: CustomTextField = CustomTextField(placeholder: "Username")
    private let passwordTextField: CustomTextField = {
       let textField = CustomTextField(placeholder: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    //MARK: - Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK:- Selectors
    
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleSignUp() {
        guard let fullname = fullNameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let username = userNameTextField.text?.lowercased() else { return }
        guard let profileImage = profileImage else { return }
        
        let hud = AuthService.hud
        hud.style = .dark
        hud.textLabel.text = "Creating User"
        hud.show(in: view)
        
        let credentials = RegistrationCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
       
        AuthService.shared.createUser(credentials: credentials) { error in
                    
            if let error = error {
                print("error creating user: \(error.localizedDescription)")
                hud.dismiss()
                return
            }
            
            hud.dismiss()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleAlreadyHaveAccountButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == fullNameTextField {
            viewModel.fullName = sender.text
        } else if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else if sender == userNameTextField {
            viewModel.userName = sender.text
        }
        checkFormStatus()
    }
    
    @objc func keyboardWillShow() {
        if view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 88
        }
    }
    
    @objc func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //MARK:- Helpers
    
    func configureUI() {
        configureGradientLayer()
        configureNotificationObservers()
        
        view.addSubview(addPhotoButton)
        addPhotoButton.centerX(inView: view)
        addPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        addPhotoButton.setDimensions(height: 200, width: 200)
        
        let stack = UIStackView(arrangedSubviews: [fullNameContainerView,emailContainerView,passwordContainerView,userNameContainerView,signUpButton])
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.anchor(top: addPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left:view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
    }
    
    func configureNotificationObservers() {
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        userNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK:- UIImagePickerControllerDelegate

extension RegisterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as? UIImage
        profileImage = image
        addPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        addPhotoButton.layer.borderColor = UIColor(white: 1, alpha: 0.7).cgColor
        addPhotoButton.layer.borderWidth = 3.0
        addPhotoButton.layer.cornerRadius = 200 / 2
        dismiss(animated: true, completion: nil)
    }
}

extension RegisterController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if viewModel.formIsValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        }
    }
}
