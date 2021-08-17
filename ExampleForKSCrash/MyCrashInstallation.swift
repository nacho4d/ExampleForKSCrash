//
//  MyCrashInstallation.swift
//  MyCrashInstallation
//
//  Created by Guillermo Ignacio Enriquez Gutierrez on 2021/08/18.
//

import Foundation
import KSCrash_Installations
import KSCrash_Recording

class MyCrashInstallation: KSCrashInstallation {
    static var shared = MyCrashInstallation()

    var appleReportStyle: KSAppleReportStyle = KSAppleReportStyleUnsymbolicated

    override init() {
        super.init(requiredProperties: nil)
        self.appleReportStyle = KSAppleReportStyleUnsymbolicated
    }

    override func sink() -> KSCrashReportFilter! {
        let filterCombine = MyCrashReportFilterCombined()
        filterCombine.appleReportStyle = appleReportStyle
        return filterCombine
    }
}

class MyCrashReportFilterCombined: NSObject, KSCrashReportFilter {

    var appleReportStyle: KSAppleReportStyle = KSAppleReportStyleUnsymbolicated

    func filterReports(_ reports: [Any]!, onCompletion: KSCrashReportFilterCompletion!) {

        let appleFormatFilter = KSCrashReportFilterAppleFmt.filter(with: appleReportStyle)
        appleFormatFilter?.filterReports(reports) { (filteredReports, success, error) in

            var rawReports = reports as? [[String: Any]] ?? []
            let appleReports = filteredReports as? [String] ?? []

            if rawReports.count != appleReports.count {
                // Fill empty raw reports in rare case count does not match.
                // This should not happen, it would mean a bug in KSCrashReportFilterAppleFmt
                rawReports = rawReports.map { _ in [:] }
            }

            let newReports = zip(rawReports, appleReports).map { pair -> [String: Any] in
                let rawReport = pair.0
                let appleReport = pair.1
                return [
                    "reportInAppleFormat": appleReport,
                    "user": rawReport["user"] ?? [:],
                    "system": rawReport["system"] ?? [:]
                ]
            }
            onCompletion(newReports, success, error)
        }
    }
}
