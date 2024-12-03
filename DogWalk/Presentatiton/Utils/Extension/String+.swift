//
//  String+.swift
//  DogWalk
//
//  Created by junehee on 11/4/24.
//

import SwiftUI

extension String {
    //TODO: 원하는 형태의 포맷 타입으로 설정 후 팀원에게 공유해주세요 ^_^
    enum DateFormatType: String {
        case dot = "yyyy. MM. dd"
        case month = "MM월 dd일"
        case time = "HH:mm"
    }

    // String -> URL
    func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw NetworkError.InvalidURL }
        return url
    }
    
    // String -> Date -> String
    /// 원하는 형식의 문자열로 포맷팅
    func getFormattedDateString(_ formatType: DateFormatType = .dot) -> String {
        // String -> Date
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC 시간
        
        guard let date = inputFormatter.date(from: self) else { return self }
        
        // Date -> String
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = formatType.rawValue
        outputFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간

        return outputFormatter.string(from: date)
    }
    
    // String -> Date -> String
    /// 오늘 날짜와 비교 진행 (오늘이면 시간, 올해면 월-일, 그 외는 연-월-일)
    func getFormattedDateStringWithToday() -> String {
        // String -> Date
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC 시간
        
        guard let date = inputFormatter.date(from: self) else { return self }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Date -> String
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간
        
        if calendar.isDate(date, inSameDayAs: today) {
            outputFormatter.dateFormat = DateFormatType.time.rawValue
            return outputFormatter.string(from: date)
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: today) {
            outputFormatter.dateFormat = DateFormatType.month.rawValue
            return outputFormatter.string(from: date)
        } else {
            outputFormatter.dateFormat = DateFormatType.dot.rawValue
            return outputFormatter.string(from: date)
        }
    }
    
    // 채팅 텍스트에 따른 크기 조절
    func estimatedTextRect(width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGRect {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let option: NSStringDrawingOptions = [
            .usesLineFragmentOrigin
        ]
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16.0, weight: .regular)
        ]
        return NSString(string: self).boundingRect(
            with: size,
            options: option,
            attributes: attributes,
            context: nil
        )
    }
}
