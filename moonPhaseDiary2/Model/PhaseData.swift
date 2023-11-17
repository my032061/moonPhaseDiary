//
//  PhaseData.swift
//  moonPhaseDiary2
//
//  Created by Masahiro Yamashita on 2023/11/04.
//

import Foundation
import CoreLocation

struct Phase {
    
    let rise = 0
    let set  = 1
    
    struct PhaseData {
        var date: String
        var moonPhase: Int8
        var moonRise: String
        var moonSet: String
        var sunRise: String
        var sunSet: String
    }
    
    func getPhaseData(date: Date, place: CLLocation) -> PhaseData {
        let sunMoon = SunMoon()
        let df = DateFormatter()
        df.dateFormat = "M/d"
        let moonP = sunMoon.getMoonPhase(date: date)
        let moomRise = sunMoon.moonRizeSet(date: date,
                                           height: place.altitude,
                                           longitude: place.coordinate.longitude,
                                           latitude: place.coordinate.latitude,
                                           flag: rise)
        let moonSet = sunMoon.moonRizeSet(date: date,
                                          height: place.altitude,
                                          longitude: place.coordinate.longitude,
                                          latitude: place.coordinate.latitude,
                                          flag: set)
        let sunRise = sunMoon.sunRizeSet(date: date,
                                         height: place.altitude,
                                         longitude: place.coordinate.longitude,
                                         latitude: place.coordinate.latitude,
                                         flag: rise)
        let sunSet = sunMoon.sunRizeSet(date: date,
                                        height: place.altitude,
                                        longitude: place.coordinate.longitude,
                                        latitude: place.coordinate.latitude,
                                        flag: set)

        return PhaseData(date: df.string(from: date),
                         moonPhase: Int8(moonP),
                         moonRise: moomRise, moonSet: moonSet,
                         sunRise: sunRise, sunSet: sunSet)
    }
}
