
import UIKit

private let reuseID = "MessageCell"

class ChatController: UICollectionViewController {
    
    //MARK:- Properties
    
    private let user: User
    private var messages = [Message]()
    var fromCurrentUser = false
    
    lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()
    
    //MARK:- Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages() 
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK:- API
    
    func fetchMessages() {
        Service.fetchMessages(forUser: user, completion: { messages in
            self.messages = messages
            self.collectionView.reloadData()
        })
    }
    
    //MARK:- Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .white
        configureNavigationBar(title: user.username, prefersLargeTitle: false)
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseID)
        collectionView.alwaysBounceVertical = true
    }
}

extension ChatController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! MessageCell
        cell.message = messages[indexPath.row]
        cell.message?.user = user
        return cell
    }
}

extension ChatController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 60, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension ChatController: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        Service.uploadMessage(message, to: user) { error in
            if let  error = error {
                print("error uploading messages: \( error.localizedDescription))")
                return
            }
            
            inputView.clearMessageText()
        }
        
    }
}
