//
//  String+.swift
//  moonPhaseDiary2
//
//  Created by Masahiro Yamashita on 2023/10/13.
//

import Foundation

extension String {
    /**
     **  sub String
     func substr(start: Int, length: Int) -> String!
     *** StringのStartからlength文字分を切り出し
     - parameters:     start: Int
     - parameters:     length: Int
     - returns:      String!
     - usage:        "12345".substr(start: 0, length: 3) // -> "123"
     */
    func substring(start: Int, length: Int) -> String {
        let ln = self.count
        // Startが範囲外
        guard ln >= start  else { return "" }
        //startの値がマイナスを指定された場合のバリデーション
        let startIndex = self.index(self.startIndex, offsetBy: start < 0 ? 0 :start)
        //endの値が文字列長を越えてる場合のバリデーション
        var endPoint = length > ln ? ln : length
        // 範囲外の調整
        endPoint = ln <= start + endPoint ? ln - start : endPoint
        let endIndex = self.index(startIndex, offsetBy: endPoint)
        return String(self[startIndex..<endIndex])
    }

}
