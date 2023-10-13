//
//  MoonPhase.swift
//  moonPhaseDiary2
//
//  Created by Masahiro Yamashita on 2023/10/13.
//

import Foundation

class MoonPhase {

    private let K: Double = 0.017453292519943295

    func dateToString(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat  = "yyyy/MM/dd HH:mm:ss"
        return df.string(from: date)
    }

 
    func gcToJd(date: Date) -> Double {
        var jd = 0.0
        let strDate: String = dateToString(date: date)
        var year = atof(strDate.substring(start: 0, length: 4))
        var month = atof(strDate.substring(start: 5, length: 2))
        let day = atof(strDate.substring(start: 8, length: 2))
        // 1月,2月は前年の13月,14月とする
        if (month < 3) {
            year -= 1
            month += 12
        }
        jd = trunc(365.25 * year)
        jd += trunc(year / 400.0)
        jd -= trunc(year / 100.0)
        jd += trunc(30.59 * (month - 2))
        jd += day
        jd += 1721088
        
        var time: Double = atof(strDate.substring(start: 11, length: 2)) / 3600
        //t += @min / 60.0
        time += atof(strDate.substring(start: 14, length: 2)) / 60
        time += atof(strDate.substring(start: 17, length: 2))
        time = time / 24
        return jd + time

    }
    
    func normalizeAngle2(angle: Double) -> Double {
        var angle1 = 0.0
        if (angle < 0) {
            angle1  = angle * (-1)
            let angle2: Double  = trunc(angle1 / 360.0)
            angle1 -= 360 * angle2
            angle1  = 360 - angle1
        }
        else {
            angle1  = trunc(angle / 360.0)
            angle1  = angle - 360.0 * angle1
        }
        return angle1
    }

}
