
import UIKit
import Firebase

protocol AuthenticationControllerProtocol { func checkFormStatus() }

class LoginController: UIViewController {
    
    //MARK:- Properties
    
    private var viewModel = LoginViewModel()
    
    private let iconImage:UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.right")
        iv.tintColor = .white
        return iv
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setHeight(height: 50)
        button.layer.cornerRadius = 5
        button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let signUpButton: UIButton = {
       let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [.font:UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.white])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [.font:UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
       return button
    }()
    
    private lazy var emailContainerView: inputContainerView = {
        return inputContainerView(image: UIImage(named: "ic_mail_outline_white_2x"), textField: emailTextField)
    }()
    
    private lazy var passwordContainerView: inputContainerView = {
        return inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
    }()
    
    private var emailTextField: CustomTextField = CustomTextField(placeholder: "Email")
        
    private var passwordTextField: CustomTextField = {
       let textField = CustomTextField(placeholder: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    //MARK:- Lifcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK:- Selectors
    
    @objc func handleShowSignUp() {
        let vc = RegisterController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        checkFormStatus()
    }
    
    @objc func handleLogIn() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        let hud = AuthService.hud
        hud.style = .dark
        hud.textLabel.text = "Logging In"
        hud.show(in: view)
        
        AuthService.shared.logUserIn(email: email, password: password) { result, error in
            if let error = error {
                print("error log in: \(error.localizedDescription)")
                hud.dismiss()
                return
            }
            
            hud.dismiss()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:- Helpers
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        view.backgroundColor = .systemPurple
        
        configureGradientLayer()
        configureNotificationObservers()
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        iconImage.setDimensions(height: 120, width: 120)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,passwordContainerView,loginButton])
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(left:view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
    }
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

extension LoginController: AuthenticationControllerProtocol {
    func checkFormStatus() {
        if viewModel.formIsValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        }
    }
}
