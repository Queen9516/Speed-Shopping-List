//
//  Utils.swift
//  BinguUser
//
//  Created by User on 16/08/17.
//  Copyright © 2017 Ajayy. All rights reserved.
//


import Foundation
import UIKit
import CoreLocation
import CryptoKit
class Utils {
    class func randomBool() -> Bool {
        return arc4random_uniform(2) == 0 ? true: false
    }
}

extension String {
    
    var commaSaparatedComponents: [String] {
        return self.components(separatedBy: ",")
    }
    var url: URL? {
        return URL(string: self)
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var gender: Bool {
        return (self == "male") ? (true) : (false)
    }
    
    var reverseDomain:String {
        return self.components(separatedBy: ".").reversed().joined(separator: ".")
    }
    
    var isAlphabaticalString: Bool {
        let charSet = NSMutableCharacterSet.letter()
        charSet.addCharacters(in: " ")
        if  (self.rangeOfCharacter(from: charSet as CharacterSet) != nil) || self == ""{
            return true
        }
        else {
            return false
        }
    }
    
    var validateMobileNumber: Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    var isNumber: Bool {
        return Int64(self) != nil
    }
    
    var integerValue: Int {
        return  Int(self) ?? 0
    }
    
}

extension Utils {
    static let announcmentAlertTitle = "Smart Food"
    static let AppCurencySign = "Kz"
    class func fontFamilyNames() {
        for family: String in UIFont.familyNames{
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family){
                print("== \(names)")
            }
        }
    }
    
    class func storyBoard(withName name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: Bundle.main)
    }
    
    class func mainStoryBoard()-> UIStoryboard {
        return self.storyBoard(withName: "Main")
    }
    
    class func getController(fromStroyBoard storyBoard:UIStoryboard, identifier: String) -> UIViewController{
        return storyBoard.instantiateViewController(withIdentifier: identifier)
    }
    
    class func getMainStoryBoardViewControllerByIdentifier(_ identifier: String) -> UIViewController{
        return self.mainStoryBoard().instantiateViewController(withIdentifier: identifier)
    }
    
    class func deviceType()-> String {
        return "iOS"
    }
    
    class func deviceID()-> String {
        if UIDevice.isSimulator{
            return (UIDevice.current.identifierForVendor!.uuidString)
            
        }else{
            return "123"//SharedPreference.deviceToken()
        }
    }
    
   
    
    class func getDataFromImage(_ image: UIImage, compressionQuality: CGFloat) -> Data{
        return  UIImageJPEGRepresentation(image, compressionQuality)!
    }
    
    class func saveFileData(_ data: Data, withExtension fileExtension: String) -> URL?{
        
        let name = String(Utils.getCurrentTimeInterval())
        
        
        let fileName =  name + fileExtension
        let fileURL = Utils.getAppDocumentDirectory().appendingPathComponent(fileName)
        
        do {
            
            try data.write(to: fileURL, options: .atomicWrite)
            if let newURL =  URL(string: Utils.getAppDocumentDirectory().absoluteString + fileName){
                return newURL
            }
        }catch {
            print(error)
        }
        return nil
    }
    
    class func getAmPmDateFormate() -> DateFormatter {
        let dateFormatter = DateFormatter()
        //if some one want 12AM,5PM then use "hh mm a"
        //if some one want 00AM,17PM then use "HH mm a"
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }
    
    class func getDateFormate() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "IST")!
        return dateFormatter
    }
    
    class func getUserDateFormate() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "IST")!
        return dateFormatter
    }
    
    class func getTodaysDate() -> Date {
        var localTimeZoneAbbreviation: String { return  NSTimeZone.local.abbreviation(for: Date())! }
        return Date()
    }
    
    class func getDateWithUserFormate(serverDate:String) -> String{
        let dateFormatter = Utils.serverFormateWithCP()
        if serverDate != "yyyy-MM-dd hh:mm:ss" {
            let servDate = dateFormatter.date(from: serverDate)
            let usrDate = Utils.getUserDateFormate().string(from: servDate!)
            print("sending To user \(usrDate)")
            return usrDate
        }else{
            return ""
        }
    }
    // class func getDateFromString(serverDate:String) -> String{
    //
    //    let dateAsString = serverDate
    //    let dateFormatter = DateFormatter()
    //    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:Z"
    //    let date = dateFormatter.date(from:dateAsString )
    //
    //    dateFormatter.dateFormat = "HH:mm"
    //    let date24 = dateFormatter.string(from: date!)
    //
    //    return date24
    //    }
    
    
    class func chatDateFormate() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, H:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        return dateFormatter
    }
    class func serverFormate()->DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        return dateFormatter
    }
    
    class func serverFormateWithCP()->DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "IST")!
        return dateFormatter
    }
    
    class func fromStringtoDate(serverDate:String) -> Date{
        let dateFormatter = Utils.serverFormateWithCP()
        let servDate = dateFormatter.date(from: serverDate)
        return servDate!
    }
    
    
    class func getDateWithCPFormate(serverDate:String) -> String{
        let dateFormatter = Utils.serverFormateWithCP()
        if serverDate != "yyyy-mm-dd" {
            let servDate = dateFormatter.date(from: serverDate)
            let usrDate = Utils.getUserDateFormate().string(from: servDate!)
            print("setting for user \(usrDate)")
            return usrDate
        }else{
            return ""
        }
    }
    
    //    class func getDateWithString(serverDate:String) -> String{
    //
    //        var myDate = serverDate
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    //        let date = dateFormatter.date(from:myDate)!
    //        dateFormatter.dateFormat = "HH:mm"
    //        let dateString = dateFormatter.string(from:date)
    //
    //    return dateString
    //        }
    //
    class func userDayTimeFormatter()->DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        return dateFormatter
    }
    
    //    func get_Date_time_from_UTC_time(string : String) -> String {
    //
    //        let dateformattor = DateFormatter()
    //        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss"
    //        dateformattor.timeZone = NSTimeZone.local
    //        let dt = string
    //        let dt1 = dateformattor.date(from: dt as String)
    //        dateformattor.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    //        dateformattor.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
    //        return dateformattor.string(from: dt1!)
    //    }
    
    
    class func userTimeFormatter()->DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        dateFormatter.timeZone = TimeZone.init(abbreviation: "IST") as TimeZone!
        
        return dateFormatter
    }
    
    class  func userHoursFormatter()-> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE- HH:mm a"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")!
        return dateFormatter
    }
    
    class func userTime(date:Date)-> Date{
        let dateFormatter = Utils.userTimeFormatter()
        let new = dateFormatter.string(from: date)
        let date = dateFormatter.date(from:new )
        //  let servDate = Utils.getDateFormate().string(from: new)
        return date!
    }
    class func userTimeForHours(date:Date)->String {
        let dateFormatter = Utils.userTimeFormatter()
        let new = dateFormatter.string(from: date)
        return new
    }
    class func userHours(date:Date)->String{
        let dateFormatter = Utils.serverFormateWithCP()
        let new = dateFormatter.string(from: date);
        return new
    }
    class func OnlyDate(date:Date) -> String {
        let dateFormatter = Utils.getDateFormate()
        let new = dateFormatter.string(from:date)
        return new
    }
    
    class func OnlyTime(date:Date) -> String {
        let dateFormatter = Utils.userTimeFormatter()
        let new = dateFormatter.string(from:date)
        return new
    }
    
    class func dateFromString(str:String) -> Date {
        let dateFormatter = Utils.getDateFormate()
        let new = dateFormatter.date(from: str)
        return new!
    }
    class func userDate(date:Date)->String{
        let dateFormatter = Utils.userHoursFormatter()
        let new = dateFormatter.string(from: date)
        
        return new
    }
    class func setDateForChat(serverdate:String)-> Date{
        let dateFormatter = Utils.chatDateFormate()
        let new = dateFormatter.date(from: serverdate)
        let servDate = Utils.chatDateFormate().string(from: new!)
        print("sending To server \(servDate)")
        return new!
    }
    class func setDateWithServerFormate(date:String) -> String {
        let dateFormatter = Utils.getUserDateFormate()
        let new = dateFormatter.date(from: date)
        let servDate = Utils.getDateFormate().string(from: new!)
        print("sending To server \(servDate)")
        return servDate
    }
    
    class func getCountryCallingCode() -> [String] {
        let prefix:[String: [String]] =  ["AF": ["Afghanistan","93"],
                                          "AX": ["Aland Islands","358"],
                                          "AL": ["Albania","355"],
                                          "DZ": ["Algeria","213"],
                                          "AS": ["American Samoa","1"],
                                          "AD": ["Andorra","376"],
                                          "AO": ["Angola","244"],
                                          "AI": ["Anguilla","1"],
                                          "AQ": ["Antarctica","672"],
                                          "AG": ["Antigua and Barbuda","1"],
                                          "AR": ["Argentina","54"],
                                          "AM": ["Armenia","374"],
                                          "AW": ["Aruba","297"],
                                          "AU": ["Australia","61"],
                                          "AT": ["Austria","43"],
                                          "AZ": ["Azerbaijan","994"],
                                          "BS": ["Bahamas","1"],
                                          "BH": ["Bahrain","973"],
                                          "BD": ["Bangladesh","880"],
                                          "BB": ["Barbados","1"],
                                          "BY": ["Belarus","375"],
                                          "BE": ["Belgium","32"],
                                          "BZ": ["Belize","501"],
                                          "BJ": ["Benin","229"],
                                          "BM": ["Bermuda","1"],
                                          "BT": ["Bhutan","975"],
                                          "BO": ["Bolivia","591"],
                                          "BA": ["Bosnia and Herzegovina","387"],
                                          "BW": ["Botswana","267"],
                                          "BV": ["Bouvet Island","47"],
                                          "BQ": ["BQ","599"],
                                          "BR": ["Brazil","55"],
                                          "IO": ["British Indian Ocean Territory","246"],
                                          "VG": ["British Virgin Islands","1"],
                                          "BN": ["Brunei Darussalam","673"],
                                          "BG": ["Bulgaria","359"],
                                          "BF": ["Burkina Faso","226"],
                                          "BI": ["Burundi","257"],
                                          "KH": ["Cambodia","855"],
                                          "CM": ["Cameroon","237"],
                                          "CA": ["Canada","1"],
                                          "CV": ["Cape Verde","238"],
                                          "KY": ["Cayman Islands","345"],
                                          "CF": ["Central African Republic","236"],
                                          "TD": ["Chad","235"],
                                          "CL": ["Chile","56"],
                                          "CN": ["China","86"],
                                          "CX": ["Christmas Island","61"],
                                          "CC": ["Cocos (Keeling) Islands","61"],
                                          "CO": ["Colombia","57"],
                                          "KM": ["Comoros","269"],
                                          "CG": ["Congo (Brazzaville)","242"],
                                          "CD": ["Congo, Democratic Republic of the","243"],
                                          "CK": ["Cook Islands","682"],
                                          "CR": ["Costa Rica","506"],
                                          "CI": ["Côte d'Ivoire","225"],
                                          "HR": ["Croatia","385"],
                                          "CU": ["Cuba","53"],
                                          "CW": ["Curacao","599"],
                                          "CY": ["Cyprus","537"],
                                          "CZ": ["Czech Republic","420"],
                                          "DK": ["Denmark","45"],
                                          "DJ": ["Djibouti","253"],
                                          "DM": ["Dominica","1"],
                                          "DO": ["Dominican Republic","1"],
                                          "EC": ["Ecuador","593"],
                                          "EG": ["Egypt","20"],
                                          "SV": ["El Salvador","503"],
                                          "GQ": ["Equatorial Guinea","240"],
                                          "ER": ["Eritrea","291"],
                                          "EE": ["Estonia","372"],
                                          "ET": ["Ethiopia","251"],
                                          "FK": ["Falkland Islands (Malvinas)","500"],
                                          "FO": ["Faroe Islands","298"],
                                          "FJ": ["Fiji","679"],
                                          "FI": ["Finland","358"],
                                          "FR": ["France","33"],
                                          "GF": ["French Guiana","594"],
                                          "PF": ["French Polynesia","689"],
                                          "TF": ["French Southern Territories","689"],
                                          "GA": ["Gabon","241"],
                                          "GM": ["Gambia","220"],
                                          "GE": ["Georgia","995"],
                                          "DE": ["Germany","49"],
                                          "GH": ["Ghana","233"],
                                          "GI": ["Gibraltar","350"],
                                          "GR": ["Greece","30"],
                                          "GL": ["Greenland","299"],
                                          "GD": ["Grenada","1"],
                                          "GP": ["Guadeloupe","590"],
                                          "GU": ["Guam","1"],
                                          "GT": ["Guatemala","502"],
                                          "GG": ["Guernsey","44"],
                                          "GN": ["Guinea","224"],
                                          "GW": ["Guinea-Bissau","245"],
                                          "GY": ["Guyana","595"],
                                          "HT": ["Haiti","509"],
                                          "VA": ["Holy See (Vatican City State)","379"],
                                          "HN": ["Honduras","504"],
                                          "HK": ["Hong Kong, Special Administrative Region of China","852"],
                                          "HU": ["Hungary","36"],
                                          "IS": ["Iceland","354"],
                                          "IN": ["India","91"],
                                          "ID": ["Indonesia","62"],
                                          "IR": ["Iran, Islamic Republic of","98"],
                                          "IQ": ["Iraq","964"],
                                          "IE": ["Ireland","353"],
                                          "IM": ["Isle of Man","44"],
                                          "IL": ["Israel","972"],
                                          "IT": ["Italy","39"],
                                          "JM": ["Jamaica","1"],
                                          "JP": ["Japan","81"],
                                          "JE": ["Jersey","44"],
                                          "JO": ["Jordan","962"],
                                          "KZ": ["Kazakhstan","77"],
                                          "KE": ["Kenya","254"],
                                          "KI": ["Kiribati","686"],
                                          "KP": ["Korea, Democratic People's Republic of","850"],
                                          "KR": ["Korea, Republic of","82"],
                                          "KW": ["Kuwait","965"],
                                          "KG": ["Kyrgyzstan","996"],
                                          "LA": ["Lao PDR","856"],
                                          "LV": ["Latvia","371"],
                                          "LB": ["Lebanon","961"],
                                          "LS": ["Lesotho","266"],
                                          "LR": ["Liberia","231"],
                                          "LY": ["Libya","218"],
                                          "LI": ["Liechtenstein","423"],
                                          "LT": ["Lithuania","370"],
                                          "LU": ["Luxembourg","352"],
                                          "MO": ["Macao, Special Administrative Region of China","853"],
                                          "MK": ["Macedonia, Republic of","389"],
                                          "MG": ["Madagascar","261"],
                                          "MW": ["Malawi","265"],
                                          "MY": ["Malaysia","60"],
                                          "MV": ["Maldives","960"],
                                          "ML": ["Mali","223"],
                                          "MT": ["Malta","356"],
                                          "MH": ["Marshall Islands","692"],
                                          "MQ": ["Martinique","596"],
                                          "MR": ["Mauritania","222"],
                                          "MU": ["Mauritius","230"],
                                          "YT": ["Mayotte","262"],
                                          "MX": ["Mexico","52"],
                                          "FM": ["Micronesia, Federated States of","691"],
                                          "MD": ["Moldova","373"],
                                          "MC": ["Monaco","377"],
                                          "MN": ["Mongolia","976"],
                                          "ME": ["Montenegro","382"],
                                          "MS": ["Montserrat","1"],
                                          "MA": ["Morocco","212"],
                                          "MZ": ["Mozambique","258"],
                                          "MM": ["Myanmar","95"],
                                          "NA": ["Namibia","264"],
                                          "NR": ["Nauru","674"],
                                          "NP": ["Nepal","977"],
                                          "NL": ["Netherlands","31"],
                                          "AN": ["Netherlands Antilles","599"],
                                          "NC": ["New Caledonia","687"],
                                          "NZ": ["New Zealand","64"],
                                          "NI": ["Nicaragua","505"],
                                          "NE": ["Niger","227"],
                                          "NG": ["Nigeria","234"],
                                          "NU": ["Niue","683"],
                                          "NF": ["Norfolk Island","672"],
                                          "MP": ["Northern Mariana Islands","1"],
                                          "NO": ["Norway","47"],
                                          "OM": ["Oman","968"],
                                          "PK": ["Pakistan","92"],
                                          "PW": ["Palau","680"],
                                          "PS": ["Palestinian Territory, Occupied","970"],
                                          "PA": ["Panama","507"],
                                          "PG": ["Papua New Guinea","675"],
                                          "PY": ["Paraguay","595"],
                                          "PE": ["Peru","51"],
                                          "PH": ["Philippines","63"],
                                          "PN": ["Pitcairn","872"],
                                          "PL": ["Poland","48"],
                                          "PT": ["Portugal","351"],
                                          "PR": ["Puerto Rico","1"],
                                          "QA": ["Qatar","974"],
                                          "RE": ["Réunion","262"],
                                          "RO": ["Romania","40"],
                                          "RU": ["Russian Federation","7"],
                                          "RW": ["Rwanda","250"],
                                          "SH": ["Saint Helena","290"],
                                          "KN": ["Saint Kitts and Nevis","1"],
                                          "LC": ["Saint Lucia","1"],
                                          "PM": ["Saint Pierre and Miquelon","508"],
                                          "VC": ["Saint Vincent and Grenadines","1"],
                                          "BL": ["Saint-Barthélemy","590"],
                                          "MF": ["Saint-Martin (French part)","590"],
                                          "WS": ["Samoa","685"],
                                          "SM": ["San Marino","378"],
                                          "ST": ["Sao Tome and Principe","239"],
                                          "SA": ["Saudi Arabia","966"],
                                          "SN": ["Senegal","221"],
                                          "RS": ["Serbia","381"],
                                          "SC": ["Seychelles","248"],
                                          "SL": ["Sierra Leone","232"],
                                          "SG": ["Singapore","65"],
                                          "SX": ["Sint Maarten","1"],
                                          "SK": ["Slovakia","421"],
                                          "SI": ["Slovenia","386"],
                                          "SB": ["Solomon Islands","677"],
                                          "SO": ["Somalia","252"],
                                          "ZA": ["South Africa","27"],
                                          "GS": ["South Georgia and the South Sandwich Islands","500"],
                                          "SS​": ["South Sudan","211"],
                                          "ES": ["Spain","34"],
                                          "LK": ["Sri Lanka","94"],
                                          "SD": ["Sudan","249"],
                                          "SR": ["Suriname","597"],
                                          "SJ": ["Svalbard and Jan Mayen Islands","47"],
                                          "SZ": ["Swaziland","268"],
                                          "SE": ["Sweden","46"],
                                          "CH": ["Switzerland","41"],
                                          "SY": ["Syrian Arab Republic (Syria)","963"],
                                          "TW": ["Taiwan, Republic of China","886"],
                                          "TJ": ["Tajikistan","992"],
                                          "TZ": ["Tanzania, United Republic of","255"],
                                          "TH": ["Thailand","66"],
                                          "TL": ["Timor-Leste","670"],
                                          "TG": ["Togo","228"],
                                          "TK": ["Tokelau","690"],
                                          "TO": ["Tonga","676"],
                                          "TT": ["Trinidad and Tobago","1"],
                                          "TN": ["Tunisia","216"],
                                          "TR": ["Turkey","90"],
                                          "TM": ["Turkmenistan","993"],
                                          "TC": ["Turks and Caicos Islands","1"],
                                          "TV": ["Tuvalu","688"],
                                          "UG": ["Uganda","256"],
                                          "UA": ["Ukraine","380"],
                                          "AE": ["United Arab Emirates","971"],
                                          "GB": ["United Kingdom","44"],
                                          "US": ["United States of America","1"],
                                          "UY": ["Uruguay","598"],
                                          "UZ": ["Uzbekistan","998"],
                                          "VU": ["Vanuatu","678"],
                                          "VE": ["Venezuela (Bolivarian Republic of)","58"],
                                          "VN": ["Viet Nam","84"],
                                          "VI": ["Virgin Islands, US","1"],
                                          "WF": ["Wallis and Futuna Islands","681"],
                                          "EH": ["Western Sahara","212"],
                                          "YE": ["Yemen","967"],
                                          "ZM": ["Zambia","260"],
                                          "ZW": ["Zimbabwe","263"]]
        
        var  countryArray: [String] = []
        //  let suffCodes = [String](prefix.keys)
        for allkeys in prefix.keys {
            if let names = prefix[allkeys]{
                let countryCode =  String(format:"%@-%@",names[0] ,names[1])
                countryArray.append(countryCode)
            }
        }
        // airportCodes is ["YYZ", "LHR"]
        
        //        let names = [[String]](prefix.values)
        //
        //        for (index,element) in prefix.enumerated() {
        //
        //    let valu =  prefix[element]
        //        let countryCode =  String(format:"%@-%@-%@",suffCodes[index], names[0] ,names[1])
        //          countryArray.append(countryCode)
        //        }
        return countryArray
        //        let countryDialingCode = prefix[countryRegionCode]
        //        return countryDialingCode!
    }
    
    
    class func getAllCOuntryName()-> NSDictionary? {
        if let url = Bundle.main.url(forResource: "countryList", withExtension: "json") {
            if let data = NSData(contentsOf: url) {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? NSDictionary
                    
                    return dictionary
                } catch {
                    print("Error!! Unable to parse json")
                }
            }
            print("Error!! Unable to load .json")
        }
        return nil
    }
}
extension Utils{
    class func getCurrentTimeInterval() -> Int32  {
        return  Int32(Date().timeIntervalSince1970)
    }
    
    class func getDocumentURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    class func AppName() -> String{
        return "Speed Shopping List"
    }
    
    class func directoryPathForLocalImages() -> URL {
        let documentsDirectory = self.getDocumentURL()
        let dataPath = documentsDirectory.appendingPathComponent("Nashamah")
        
        if (!FileManager.default.fileExists(atPath: dataPath.path)){
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
                return dataPath
            }catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return dataPath
    }
    
    class func getAppDocumentDirectory() -> URL {
        let documentDirectory = self.getDocumentURL()
        let appDirectory = documentDirectory.appendingPathComponent(self.AppName())
        // If the folder with the given path doesn't exist already, create it
        do {
            try FileManager.default.createDirectory(atPath: appDirectory.path, withIntermediateDirectories: true, attributes: nil)
            return appDirectory
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        return appDirectory
    }
    class func removeDirectory(_ path:String) throws {
        do {
            try FileManager.default.removeItem(atPath: path)
        }catch let error as NSError {
            throw error
        }
    }
    
    class func
    tokenString(fromData deviceToken: Data) -> String{
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        return tokenString;
    }
    
    class func alterControllerWithActions(_ title: String, message: String, style: UIAlertControllerStyle, actions: UIAlertAction...) -> UIAlertController{
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach {
            controller.addAction($0)
        }
        
        return controller
    }
    class func action(_ title: String, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        
        return UIAlertAction(title: title, style: style, handler: handler)
    }
}
extension Utils{
    
    class func setToServerFormate() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        return dateFormatter
    }
    
    class func getGreetingDateFormate() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")!
        return dateFormatter
    }
    
    class func getMonthDateFromString(calD:String) -> String{
        let dateFormatter = Utils.setToServerFormate()
        let date = dateFormatter.date(from: calD)
        let usrDate = Utils.getGreetingDateFormate().string(from: date!)
        return usrDate
    }
    
    class func calculateDisatnceBetweenTwoLocations(_ source:CLLocation,destination:CLLocation) -> Double{
        print("source " + String(source.coordinate.latitude) + "\n" +  String(source.coordinate.longitude))
        
        print("destination " + String(destination.coordinate.latitude) + "\n" +  String(destination.coordinate.longitude))
        
        let distanceMeters = source.distance(from: destination)
        
        
        return distanceMeters
    }
    
    class func getDistanceString(_ distance: Double) -> String{
        print("distance " + String(distance))
        let greeting = "Distance-is"
        let kmUnit = "KM"
        let mUnit = "Meter"
        
        var distanceMeters =  distance
        
        if distanceMeters > 100 {
            var distanceKM = distanceMeters/1000
            let roundedTwoDigit = distanceKM.roundedTwoDigit
            return greeting + " " + String(Int(roundedTwoDigit)) + " " + kmUnit
        }else {
            return greeting + " " + String(distanceMeters.roundedTwoDigit) + " " + mUnit
        }
        
    }
    
    class func getCommaCombinedString(_ list: [String]) -> String {
        var string = "";
        
        list.forEach{
            string += $0
            string += ","
        }
        string = self.removeLastCommaFromString(string)
        return string
    }
    class func removeLastCommaFromString(_ str: String) -> String {
        var rawString = str;
        
        if !rawString.isEmpty {
            let endIndex = rawString.count - 1
            let range = rawString.index(rawString.startIndex, offsetBy: 0)..<rawString.index(rawString.startIndex, offsetBy: endIndex)
            
            rawString = rawString.substring(with: range)
        }
        
        return rawString
    }
    
    
}
extension Double{
    
    var roundedTwoDigit:Int32{
        let val = self
        
        return Int32(Darwin.round(100*val)/100)
        
    }
}
extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height/2
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func imageWithImage(_ newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}



extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    static func randomColor() -> UIColor {
        // If you wanted a random alpha, just create another
        // random number for that too.
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

//MARK: - Date formatter
extension Date {
    
    static func serverFormateWithCP()->DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "IST")!
        return dateFormatter
    }
    
    
    static func fromStringtoDate(serverDate:String) -> Date{
        let dateFormatter = Utils.serverFormateWithCP()
        let servDate = dateFormatter.date(from: serverDate)
        return servDate!
    }
    
    static func getDateComponentsFromDate(_ date:Date) -> DateComponents{
        return (Calendar.current as NSCalendar).components([.year,  .month, .day, .hour, .minute, .second], from:date)
    }
    func yearsFrom(fromDate date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    
    func monthsFrom(fromDate date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(fromDate date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(fromDate date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(fromDate date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(fromDate date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(fromDate date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(fromDate: date)   > 0 { return "\(yearsFrom(fromDate: date))y"   }
        if monthsFrom(fromDate: date)  > 0 { return "\(monthsFrom(fromDate:date))M"  }
        if weeksFrom(fromDate: date)   > 0 { return "\(weeksFrom(fromDate: date))w"   }
        if daysFrom(fromDate: date)    > 0 { return "\(daysFrom(fromDate: date))d"    }
        if hoursFrom(fromDate: date)   > 0 { return "\(hoursFrom(fromDate: date))h"   }
        if minutesFrom(fromDate: date) > 0 { return "\(minutesFrom(fromDate: date))m" }
        if secondsFrom(fromDate: date) > 0 { return "\(secondsFrom(fromDate: date))s" }
        return ""
    }
    
}

//func > (lhs: Date, rhs: Date) -> Bool {
//    return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
//}
//
//func < (lhs: Date, rhs: Date) -> Bool {
//    return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
//}

//extension Utils {
//    static fileprivate func layoutForLanguage(_ stackViews: [UIStackView]) -> AppLanguage{
//        var language: AppLanguage = .arabic
//        let stack = stackViews[0]
//        if stack.arrangedSubviews[0] is UIButton {
//            language = .english
//        }
//        return language
//    }
//
//    static fileprivate func layoutForArabic(_ stackViews: [UIStackView]) {
//        guard self.layoutForLanguage(stackViews) != .arabic else {return}
//
//        DispatchQueue.main.async(execute: {
//            stackViews.forEach { stackView in
//                stackView.arrangedSubviews.forEach {
//                    if $0 is UIButton {
//                        stackView.insertArrangedSubview($0, at: 2)
//                    } else if $0 is UITextField {
//                        stackView.insertArrangedSubview($0, at: 0)
//                        ($0 as! UITextField).textAlignment = .right
//                    }else {
//                        stackView.insertArrangedSubview($0, at: 1)
//                    }
//                }
//                stackView.layoutIfNeeded()
//            }
//        })
//    }
//
//    static fileprivate func layoutForEnglish(_ stackViews: [UIStackView]) {
//        guard self.layoutForLanguage(stackViews) != .english else {return}
//
//        DispatchQueue.main.async(execute: {
//            stackViews.forEach { stackView in
//                stackView.arrangedSubviews.forEach {
//                    if $0 is UIButton {
//                        stackView.insertArrangedSubview($0, at: 0)
//                    } else if $0 is UITextField {
//                        stackView.insertArrangedSubview($0, at: 2)
//                        ($0 as! UITextField).textAlignment = .left
//                    }else {
//                        stackView.insertArrangedSubview($0, at: 1)
//                    }
//                }
//                stackView.layoutIfNeeded()
//            }
//        })
//    }
//
//    static fileprivate func layoutSetupForLanguage(_ language: AppLanguage, stackViews: [UIStackView]) {
//        if language == .english{
//            self.layoutForEnglish(stackViews)
//        }else if language == .arabic{
//            self.layoutForArabic(stackViews)
//        }
//    }
//
//    static func localizationLayoutSetup(_ stackView: [UIStackView]) {
//        layoutSetupForLanguage( AppPreferences.currentLanguage, stackViews: stackView)
//    }
//}

extension URL {
    var isRemoteFileURL: Bool {
        return self.absoluteString.contains("http")
    }
}

extension Sequence where Self.Iterator.Element == String  {
    var commaString: String {
        var string = "";
        
        self.forEach{
            string += $0
            string += ","
        }
        string = removeLastCommaFromString(string)
        return string
    }
    
    fileprivate func removeLastCommaFromString(_ str: String) -> String {
        var rawString = str;
        
        if !rawString.isEmpty {
            let endIndex = rawString.characters.count - 1
            let range = rawString.characters.index(rawString.startIndex, offsetBy: 0)..<rawString.characters.index(rawString.startIndex, offsetBy: endIndex)
            
            rawString = rawString.substring(with: range)
        }
        
        return rawString
    }
}

extension Int {
    var boolValue: Bool {
        return self == 0 ? false : true
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "problem in loading")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}

//extension UITextField {
//    public func alignTextField() {
//        if UIApplication.isRTL()  {
//            self.textAlignment = .right
//            return
//        } else {
//            self.textAlignment = .left
//            return
//        }
//    }
//
//}

extension UIDevice {
    static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}


//MARK: - Activity Indicator
protocol Activity {
    func stopActivity()
    func startActivity()
}


class JPIndicatorView:UIView, Activity{
    let indicatorView:UIView = UIView()
    fileprivate let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func layoutSubviews() {
        indicatorView.frame = self.superview!.frame
    }
    
    func startActivity(){
        self.activityIndicator.startAnimating()
    }
    
    func stopActivity(){
        self.activityIndicator.stopAnimating()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.indicatorView)
        self.indicatorView.addSubview(activityIndicator)
        self.setUpActivitiIndicator()
    }
    
    fileprivate func setUpActivitiIndicator(){
        self.activityIndicator.hidesWhenStopped = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK: - Activity Indicator HUD View

class JPHUD: UIView{
    fileprivate let keyWindow = UIApplication.shared.keyWindow
    //  fileprivate let keyWindow = AppDelegate.sharedInstance.window
    fileprivate(set) var visiblity:Bool
    
    fileprivate let activityIndicatorView =  JPIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    override init(frame: CGRect) {
        self.visiblity = true
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.activityIndicatorView.center = self.center
        self.addSubview(activityIndicatorView)
    }
    class func show() {
        DispatchQueue.main.async { () -> Void in
            self.sharedInstance.startActivity()
        }
        
    }
    class func hide() {DispatchQueue.main.async { () -> Void in
        self.sharedInstance.stopActivity()
        }
    }
    fileprivate func stopActivity() {
        self.activityIndicatorView.stopActivity()
        self.removeFromSuperview()
    }
    
    fileprivate func startActivity() {
        self.keyWindow?.addSubview(self)
        self.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startActivity()
    }
    
    fileprivate class var sharedInstance:JPHUD {
        struct singleton {
            static let instance = JPHUD(frame: UIScreen.main.bounds, visiblity: true)
        }
        return singleton.instance
    }
    
    fileprivate init(frame: CGRect, visiblity:Bool) {
        self.visiblity = visiblity
        
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.activityIndicatorView.center = self.center
        self.addSubview(activityIndicatorView)
    }
    var isVisible:Bool {
        set {
            if newValue {
                self.visiblity = true
                self.isHidden = false
            } else {
                self.visiblity = false
                self.isHidden = true
            }
        }
        get{
            return self.visiblity
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.visiblity = false
        super.init(coder: aDecoder)
        self.addSubview(activityIndicatorView)
    }
}


extension UIView {
    public func reset() {
        let windows = UIApplication.shared.windows as [UIWindow]
        for window in windows {
            let subviews = window.subviews as [UIView]
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
}

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
func RANDOM_NONCE_STRING(length: Int = 32) -> String {
  precondition(length > 0)
  let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
  var result = ""
  var remainingLength = length

  while remainingLength > 0 {
    let randoms: [UInt8] = (0 ..< 16).map { _ in
      var random: UInt8 = 0
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
      if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
      }
      return random
    }

    randoms.forEach { random in
      if remainingLength == 0 {
        return
      }

      if random < charset.count {
        result.append(charset[Int(random)])
        remainingLength -= 1
      }
    }
  }

  return result
}
