import UIKit
import ApiAI
import AVFoundation

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

class ChatViewController: UIViewController {
    let speechSynthesizer = AVSpeechSynthesizer()

    var chatCollectionVc: ChatCollectionViewController!

    func speechAndText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {}, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(true, notification: notification)
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(false, notification: notification)
    }

    func adjustingHeight(_ show:Bool, notification:NSNotification) {
        // 1
        var userInfo = notification.userInfo!
        // 2
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        // 3
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        // 4
        let changeInHeight = (keyboardFrame.height + 0) * (show ? 1 : -1)
        //5
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
        })

    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    struct Variables {
        static var name = ""
        static var age = ""
        static var userID = "0000"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chatCollectionVc = segue.destination as? ChatCollectionViewController {
            self.chatCollectionVc = chatCollectionVc
        }
    }

    @IBOutlet weak var chatCollectionView: UIView!

    @IBOutlet weak var messageInput: UITextField!

    @IBAction func onSendClick(_ sender: Any) {
        let requestAI = ApiAI.shared().textRequest()

        if let text = self.messageInput.text, text != "" {
            requestAI?.query = text
            let now = Date()
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let time = formatter.string(from: now)
            var url = URL(string: "http://172.20.206.155:8081/server/user/updateUserChatBotMessages")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            var postString = "userID=" + Variables.userID + "&message=" + text + "&token=0"
            postString += "&time=" + time
            request.httpBody = postString.data(using: .utf8)
            var task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    return
                }

                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }

                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
            }
            task.resume()

            chatCollectionVc.chatRecords.append((text, true))
            chatCollectionVc.collectionView?.reloadData()
            chatCollectionVc.collectionView?.scrollToItem(at: IndexPath(row: chatCollectionVc.chatRecords.count - 1, section: 0), at: .top, animated: false)

            let nameArr = text.components(separatedBy: "My name is ")
            let ageArr = text.components(separatedBy: "years old")
            let isName : Bool = (nameArr.count-1 > 0 ) ? true : false
            let isAge : Bool = (ageArr.count-1 > 0) ? true : false

            if(isName){
                Variables.name = nameArr.last!
            }
            if (isAge){
                Variables.age = ageArr.first!.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
            }
            requestAI?.setMappedCompletionBlockSuccess({ (requestAI, response) in
                let response = response as! AIResponse
                if var textResponse = response.result.fulfillment.speech {
                    url = URL(string: "http://172.20.206.155:8081/server/user/updateUser")!
                    request = URLRequest(url: url)
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    if(isName){
                        textResponse = textResponse.replace(target: "yy", withString:nameArr.last!)
                    }
                    if (isAge){
                        textResponse = textResponse.replace(target: "xx", withString:ageArr.first!.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted))
                    }
                    self.speechAndText(text: textResponse)
                    postString = "userID=" + Variables.userID + "&name=" + Variables.name + "&age=" + Variables.age + "&interests=test"
                    request.httpBody = postString.data(using: .utf8)
                    task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {                                                 // check for fundamental networking error
                            print("error=\(String(describing: error))")
                            return
                        }

                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                            print("statusCode should be 200, but is \(httpStatus.statusCode)")
                            print("response = \(String(describing: response))")
                        }

                        let responseString = String(data: data, encoding: .utf8)
                        print("responseString = \(String(describing: responseString))")
                    }
                    task.resume()
                    self.chatCollectionVc.chatRecords.append((textResponse, false))
                    self.chatCollectionVc.collectionView?.reloadData()
                    self.chatCollectionVc.collectionView?.scrollToItem(at: IndexPath(row: self.chatCollectionVc.chatRecords.count - 1, section: 0), at: .top, animated: false)

                    url = URL(string: "http://172.20.206.155:8081/server/user/updateUserChatBotMessages")!
                    request = URLRequest(url: url)
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    var postString = "userID=" + Variables.userID + "&message=" + textResponse + "&token=1"
                    postString += "&time=" + time
                    request.httpBody = postString.data(using: .utf8)
                    task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {                                                 // check for fundamental networking error
                            print("error=\(String(describing: error))")
                            return
                        }

                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                            print("statusCode should be 200, but is \(httpStatus.statusCode)")
                            print("response = \(String(describing: response))")
                        }

                        let responseString = String(data: data, encoding: .utf8)
                        print("responseString = \(String(describing: responseString))")
                    }
                    task.resume()
                }
            }, failure: { (requestAI, error) in
                print(error!)
            })
            ApiAI.shared().enqueue(requestAI)

            self.messageInput.text = ""

        } else {
            return
        }
    }
}



