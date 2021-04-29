
import UIKit

protocol NewMessageControllerDelegate: class {
    func controller(_ controller: NewMessageController, wantsToStartChatWith user: User)
}

class NewMessageController: UITableViewController {
    
    //MARK:- Poperties
    
    private let reuseID = "userCell"
    private var users = [User]()
    weak var delegate: NewMessageControllerDelegate?
    
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
    }
    
    //MARK:- Selectors
    
    @objc func handleDismissing() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- API
    
    func fetchUsers() {
        Service.fetchUsers { user in
            self.users = user
            self.tableView.reloadData()
        }
    }
    
    //MARK:- Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar(title: "New Message", prefersLargeTitle: false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissing))
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseID)
        tableView.rowHeight = 80
    }
}

//MARK:- TableView Datasource

extension NewMessageController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        return cell
    }
}

//MARK:- TableView Delegate 

extension NewMessageController {
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.controller(self, wantsToStartChatWith: users[indexPath.row])    
    }
}
