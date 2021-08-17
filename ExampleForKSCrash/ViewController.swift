//
//  ViewController.swift
//  ExampleForKSCrash
//
//  Created by Guillermo Ignacio Enriquez Gutierrez on 2021/08/18.
//

import UIKit
import KSCrash_Installations
import KSCrash_Recording



class ViewController: UIViewController {

    private var installation: KSCrashInstallation?

    @IBAction func install() {
        KSCrash.sharedInstance().deleteBehaviorAfterSendAll = KSCDeleteNever
        KSCrash.sharedInstance()?.maxReportCount = 1
        let i = MyCrashInstallation.shared
        i.appleReportStyle = KSAppleReportStyleUnsymbolicated
        i.install()
        installation = i

        installation?.onCrash = { writer in
            /// Use "0000000000" as default contract number, and same as Android logic, used for 'user not login' state.
            let userId:String = "0000000000"
            let now = "20210831"
            writer?.pointee.addStringElement(writer, "my_key_userid", "\(userId)")
            writer?.pointee.addStringElement(writer, "my_error_date", "\(now)")
        }
    }

    @IBAction func sendOutstandingReports() {
        installation?.sendAllReports { (reports, completed, maybeError) in

            /// The type of reports depends on the filter inside KSCrash.
            /// Since filters are plugable. We assert expected type here.
            let crashReports = reports as? [[String: Any]] ?? []

            for r in crashReports {
                guard let reportInAppleFormat = r["reportInAppleFormat"] as? String,
                      let customInformation = r["user"] as? [String: Any]
//                        ,
//                      let userID = customInformation["my_key_userid"] as? String,
//                      let errorDate = customInformation["my_error_date"] as? String,
//                      let systemInformation = r["system"] as? [String: Any]
                else {
                    NSLog("CrashReporter: skipping (bad report info)")
                    return
                }

                NSLog("customInformation: \(customInformation)")


                let vc = UIActivityViewController(activityItems: [reportInAppleFormat], applicationActivities: nil)
                self.present(vc, animated: true, completion: nil)

            }
            KSCrash.sharedInstance().deleteAllReports()
        }
    }

    @IBAction func crash() {
        let arr = [1,2,3]
        let ten = arr[10]
        NSLog("\(ten)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.









    }


}

