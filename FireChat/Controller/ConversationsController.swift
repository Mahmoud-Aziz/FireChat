
import UIKit
import Firebase

class ConversationsController: UIViewController {
    
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let reuseID = "ConveresationCell"
    private let newMessageButon: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemPurple
        button.tintColor = .white
        button.addTarget(self, action: #selector(showNewMessage), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cinfigureUI()
        authenticateUsr()
    }
    
    //MARK:- Selectors
    
    @objc func showProfile() {
        logOut()
    }
    
    @objc func showNewMessage() {
        let vc = NewMessageController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)

    }
    
    //MARK:- API
    
    func authenticateUsr() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginScreen()
        } else {
            print("user is logged in, configure controller")
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            presentLoginScreen()
        } catch {
            print("error signing out")
        }
    }
    
    //MARK: - Helpers
    
    func presentLoginScreen() {
        DispatchQueue.main.async {
            let vc = LoginController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false, completion: nil)
        }
    }
    
    func cinfigureUI() {
        view.backgroundColor = .white
        configureNavigationBar(title: "Messages", prefersLargeTitle: true)
        configureTableView()
        
        let image = UIImage(systemName: "person.circle.fill")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showProfile))
        view.addSubview(newMessageButon)
        newMessageButon.setDimensions(height: 56, width: 56)
        newMessageButon.layer.cornerRadius = 56 / 2
        newMessageButon.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 16, paddingRight: 24)
    }
    
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseID)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
}

//MARK:- TableView datasource

extension ConversationsController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        cell.textLabel?.text = "text cell"
        return cell
    }
}

//MARK:- TableView delegate 

extension ConversationsController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.row)
    }
}

//MARK:- NewMessageController Delegate

extension ConversationsController: NewMessageControllerDelegate {
    func controller(_ controller: NewMessageController, wantsToStartChatWith user: User) {
        controller.dismiss(animated: true, completion: nil)
        let vc = ChatController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}
