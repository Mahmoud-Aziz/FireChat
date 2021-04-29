
import Foundation

struct RegisterViewModel: AuthenticationProtocol {
    
    var email:String?
    var password:String?
    var fullName:String?
    var userName:String?
    
    var formIsValid: Bool {
        return fullName?.isEmpty == false
            && email?.isEmpty == false
            && password?.isEmpty == false
            && userName?.isEmpty == false
    }
}
