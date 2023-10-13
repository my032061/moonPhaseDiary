//
//  SunMoon.swift
//  moonPhaseDiary2
//
//  Created by Masahiro Yamashita on 2023/10/13.
//

import Foundation


class SunMoon {
    //  # 標準子午線経度JP
    private let  JST_LON:Double = 135
    // 方位角・高度算出用小数点以下桁数
    private let  DIGITS:Double = 2
    //1日の秒数
    private let  ADAY:Double = 86400
    // 逐次近似計算収束判定値
    private let  CONVERGE:Double = 0.00005
    // 大気差
    private let ASTRO_REFRACT:Double = 0.585556
    // （角度の）度からラジアンに変換する係数の定義
    private let PI_180:Double = 0.017453292519943295
    
    
    //地平線伏角
    private func dip(height: Double) -> Double {
        return 0.0353333 * sqrt(height)
    }
    
    //自転遅れ補正値(日)
    private func rotateRev ( year: Double) -> Double {
        return ((57 + 0.8 * (year - 1990)) / ADAY);
    }

    // 角度の正規化を行う。すなわち引数の範囲を 0≦θ＜360 にする。
    // 引数   .... ang : 角度
    // 戻り値 .... 角度 ( 度 )
    private func normalizeAngle(ang: Double) -> Double {
        return ang - 360.0 * trunc(ang / 360.0)
    }
    
    // 観測地点の恒星時Θ(度)の計算
    // 引数   .... hash
    //             .. jy : 経過ユリウス年
    //             .. t  : 時刻 ( 0.xxxx日 )
    // 戻り値 .... 観測地点の恒星時Θ(度)
    private func calcTimeSidereal( jy:Double, t: Double, longitude: Double) -> Double {
        
        var val: Double  = 325.4606
        val += 360.007700536 * jy
        val += 0.00000003879 * jy * jy
        val += 360.0 * t
        val += longitude
        
        return normalizeAngle(ang: val);
    }
    
    
    private func adjustmentCalc(ary: [[Double]], jy: Double) -> Double {
        var reslt:Double = 0.0
        for item in 0..<ary.count {
            if item == 0 {
                reslt = ary[item][0] * sin(PI_180 * normalizeAngle(ang: ary[item][1] + ary[item][2] * jy))
            }
            else {
                reslt += ary[item][0] * sin(PI_180 * normalizeAngle(ang: ary[item][1] + ary[item][2] * jy))
            }
        }
        
        return reslt
    }
    
    // 月の視差計算
    // 引数   .... jy : 経過ユリウス年
    // 戻り値 .... 出入時刻 ( 0.xxxx日 )
    func calcDifMoon(jy:Double)-> Double {
        let ary:[[Double]] = [
            [0.0003, 227.0, 4412],
            [0.0004, 194.0, 3773.4],
            [0.0005, 329.0, 8545.4],
            [0.0009, 100.0, 13677.3],
            [0.0028, 0.0, 9543.98],
            [0.0078, 325.7, 8905.34 ],
            [0.0095, 190.7, 4133.35 ],
            [0.0518, 224.98, 4771.989]]
        
        var p_moon:Double = adjustmentCalc(ary: ary, jy: jy)
        p_moon += 0.9507 * sin(PI_180 * normalizeAngle(ang: 90.0))
        return p_moon
    }
    
    // 経過ユリウス年(日)計算
    // 引数   .... t : 時刻 ( 0.xxxx日 )
    // 戻り値 .... 2000.0(2000年1月1日力学時正午)からの経過年数 (年)
    func calcJy(t: Double, dayProgress: Double, yr: Double) -> Double {
        return (dayProgress + t + rotateRev(year: yr)) / 365.25
    }
    
    //太陽の黄経 λsun(jy) を計算する
    // 引数   .... jy : 経過ユリウス年
    // 戻り値 .... 黄経
    func calcLngSun(jy: Double) -> Double {
        let ary:[[Double]] = [
            [0.0003, 329.7, 44.43],
            [0.0003, 352.5, 1079.97],
            [0.0004, 21.1, 720.02],
            [0.0004, 157.3, 299.30],
            [0.0004, 234.9, 315.56],
            [0.0005, 291.2 , 22.81],
            [0.0005, 207.4,  1.50],
            [0.0006, 29.8, 337.18],
            [0.0007, 206.8 , 30.35],
            [0.0007, 153.3,  90.38],
            [0.0008, 132.5, 659.29],
            [0.0013, 81.4,  225.18],
            [0.0015, 343.2 , 450.37],
            [0.0018, 251.3,  0.20],
            [0.0018, 297.8, 4452.67],
            [0.0020, 247.1 , 329.64],
            [0.0048, 234.95, 19.341],
            [0.0200, 355.05, 719.981]]
        
        var rm_sun:Double = adjustmentCalc(ary: ary, jy: jy)
        rm_sun += (1.9146 - 0.00005 * jy) * sin(PI_180 * normalizeAngle(ang: 357.538 + 359.991 * jy))
        rm_sun += normalizeAngle(ang: 280.4603 + 360.00769 * jy)
        
        return rm_sun
    }
    
    // 太陽の距離 r(jy) を計算する
    // 引数   .... jy : 経過ユリウス年
    // 戻り値 .... 距離
    func calcDistSun(jy: Double) -> Double {
        var r_sun = 0.0
        r_sun  = 0.000007 * sin(PI_180 * normalizeAngle(ang: 156.0 +  329.6  * jy))
        r_sun += 0.000007 * sin(PI_180 * normalizeAngle(ang: 254.0 +  450.4  * jy))
        r_sun += 0.000013 * sin(PI_180 * normalizeAngle(ang: 27.8 + 4452.67 * jy))
        r_sun += 0.000030 * sin(PI_180 * normalizeAngle(ang: 90.0))
        r_sun += 0.000091 * sin(PI_180 * normalizeAngle(ang: 265.1 +  719.98 * jy))
        r_sun += (0.007256 - 0.0000002 * jy) * sin(PI_180 * normalizeAngle(ang: 267.54 + 359.991 * jy))
        return pow(10.0, r_sun);
    }
    
    //月の黄経 λmoon(jy) を計算する
    //引数   .... jy : 経過ユリウス年
    //戻り値 .... 黄経
    func calcLngMoon(jy: Double) -> Double {
        let am_array:[[Double]] = [
            [0.0006, 54.0, 19.3],
            [0.0006, 71.0, 0.2],
            [0.0020, 55.0, 19.34],
            [0.0040, 119.5, 1.33]]
        
        let rm_array:[[Double]] = [
            [0.0003, 280.0, 23221.3],
            [0.0003, 161.0,   40.7],
            [0.0003, 311.0, 5492.0],
            [0.0003, 147.0, 18089.3],
            [0.0003,  66.0, 3494.7],
            [0.0003, 83.0, 3814.0],
            [0.0004, 20.0, 720.0],
            [0.0004, 71.0, 9584.7],
            [0.0004, 278.0, 120.1],
            [0.0004, 313.0, 398.7 ],
            [0.0005, 332.0, 5091.3],
            [0.0005, 114.0, 17450.7],
            [0.0005, 181.0, 19088.0],
            [0.0005, 247.0, 22582.7],
            [0.0006, 128.0, 1118.7],
            [0.0007, 216.0, 278.6],
            [0.0007, 275.0, 4853.3],
            [0.0007, 140.0, 4052.0],
            [0.0008, 204.0, 7906.7],
            [0.0008, 188.0, 14037.3],
            [0.0009, 218.0,  8586.0],
            [0.0011, 276.5, 19208.02],
            [0.0012, 339.0, 12678.71],
            [0.0016, 242.2, 18569.38],
            [0.0018,   4.1,  4013.29],
            [0.0020,  55.0,    19.34],
            [0.0021, 105.6,  3413.37],
            [0.0021, 175.1,   719.98],
            [0.0021,  87.5,  9903.97],
            [0.0022, 240.6,  8185.36],
            [0.0024, 252.8,  9224.66],
            [0.0024, 211.9,   988.63],
            [0.0026, 107.2, 13797.39],
            [0.0027, 272.5,  9183.99],
            [0.0037, 349.1,  5410.62],
            [0.0039, 111.3, 17810.68],
            [0.0040, 119.5,     1.33],
            [0.0040, 145.6, 18449.32],
            [0.0040,  13.2, 13317.34],
            [0.0048, 235.0,    19.34],
            [0.0050, 295.4,  4812.66],
            [0.0052, 197.2,   319.32],
            [0.0068,  53.2,  9265.33],
            [0.0079, 278.2,     4493.34],
            [0.0085, 201.5,     8266.71],
            [0.0100,  44.89,   14315.966],
            [0.0107, 336.44,   13038.696],
            [0.0110, 231.59,    4892.052],
            [0.0125, 141.51,   14436.029],
            [0.0153, 130.84,     758.698],
            [0.0305, 312.49,    5131.979],
            [0.0348, 117.84,    4452.671],
            [0.0410, 137.43,    4411.998],
            [0.0459, 238.18,    8545.352],
            [0.0533,  10.66,   13677.331],
            [0.0572, 103.21,    3773.363],
            [0.0588, 214.22,     638.635],
            [0.1143,   6.546,   9664.0404],
            [0.1856, 177.525,    359.9905],
            [0.2136, 269.926,   9543.9773],
            [0.6583, 235.700,   8905.3422],
            [1.2740, 100.738,   4133.3536]]
        
        let am:Double = adjustmentCalc(ary: am_array, jy: jy)
        var rm_moon:Double = adjustmentCalc(ary: rm_array, jy: jy)
        rm_moon += 6.2887 * sin(PI_180 * normalizeAngle(ang: 134.961 +  4771.9886 * jy + am))
        rm_moon += normalizeAngle(ang: 218.3161 + 4812.67881 * jy)
        return rm_moon
    }
    
    // 月の黄緯 βmoon(jy) を計算する
    // 引数　 .... jy : 経過ユリウス年
    // 戻り値 .... 黄緯
    func calcLatMoon(jy: Double) -> Double {
        let bm_array:[[Double]] = [
            [0.0005, 307.0,   19.4],
            [0.0026,  55.0,  19.34],
            [0.0040, 119.5,    1.33],
            [0.0043, 322.1,   19.36],
            [0.0267, 234.95,  19.341]]
        let bt_array:[[Double]] = [
            [0.0003, 234.0, 19268.0],
            [0.0003, 146.0,  3353.3 ],
            [0.0003, 107.0, 18149.4  ],
            [0.0003, 205.0, 22642.7  ],
            [0.0004, 147.0, 14097.4  ],
            [0.0004, 13.0,  9325.4  ],
            [0.0004 , 81.0, 10242.6  ],
            [0.0004, 238.0, 23281.3  ],
            [0.0004, 311.0,  9483.9  ],
            [0.0005, 239.0,  4193.4  ],
            [0.0005, 280.0,  8485.3  ],
            [0.0006,  52.0, 13617.3  ],
            [0.0006, 224.0,  5590.7  ],
            [0.0007, 294.0, 13098.7  ],
            [0.0008, 326.0,  9724.1  ],
            [0.0008,  70.0, 17870.7  ],
            [0.0010,  18.0, 12978.66 ],
            [0.0011, 138.3, 19147.99 ],
            [0.0012, 148.2,  4851.36 ],
            [0.0012,  38.4,  4812.68 ],
            [0.0013, 155.4,   379.35 ],
            [0.0013,  95.8 , 4472.03 ],
            [0.0014, 219.2,   299.96 ],
            [0.0015,  45.8 , 9964.00 ],
            [0.0015, 211.1,  9284.69 ],
            [0.0016, 135.7,   420.02 ],
            [0.0017,  99.8, 14496.06 ],
            [0.0018, 270.8,  5192.01 ],
            [0.0018, 243.3,  8206.68 ],
            [0.0019, 230.7,  9244.02 ],
            [0.0021, 170.1,  1058.66 ],
            [0.0022, 331.4, 13377.37 ],
            [0.0025, 196.5 , 8605.38 ],
            [0.0034, 319.9,  4433.31 ],
            [0.0042, 103.9, 18509.35 ],
            [0.0043, 307.6,  5470.66 ],
            [0.0082, 144.9,  3713.33 ],
            [0.0088, 176.7,     4711.96],
            [0.0093, 277.4,     8845.31],
            [0.0172,   3.18,   14375.997],
            [0.0326, 328.96,   13737.362],
            [0.0463, 172.55,     698.667],
            [0.0554, 194.01,    8965.374 ],
            [0.1732, 142.427,   4073.3220],
            [0.2777, 138.311,     60.0316],
            [0.2806, 228.235,   9604.0088]]
        
        let bm:Double = adjustmentCalc(ary: bm_array, jy: jy)
        var bt_moon:Double = adjustmentCalc(ary: bt_array, jy: jy)
        bt_moon +=  5.1282 * sin(PI_180 * normalizeAngle( ang: 93.273 +  4832.0202 * jy + bm))

        return bt_moon
    }

    //タイムゾーンとグリニッジ標準時との間隔
    func hourFromGMT() -> Int {
        return TimeZone.current.secondsFromGMT() / 3600
    }
    
    //2000年1月1日力学時正午からの経過日数計算
    // 戻り値 .... 2000.0(2000年1月1日力学時正午)からの経過日数 (日)
    func calcTimeProgress(date: Date) -> Double {
        // 年月日取得
        var time_progress: Double = 0
        let df = DateFormatter()
        df.dateFormat  = "yyyy/MM/dd"
        let strDate: String = df.string(from: date)
        var year: Double = atof(strDate.substring(start: 0, length: 4))
        year -= 2000
        var month: Double = atof(strDate.substring(start: 5, length: 2))//substringEasily(5, end:7))
        let day: Double = atof(strDate.substring(start: 8, length: 2))//substringEasily(8, end:10))
        // 1月,2月は前年の13月,14月とする
        if month < 3 {
            year -= 1
            month += 12
        }
        let utc = Double(hourFromGMT())
        time_progress = 365 * year + 30 * month + day - 33.5 -  utc / 24.0
        time_progress += trunc(3 * (month + 1) / 5.0)
        time_progress += trunc(year / 4.0)
        return time_progress
    }
    
    // 出入点(k)の時角(tk)と天体の時角(t)との差(dt=tk-t)を計算する
    // 引数   .... hash
    //             .. sekkei        : 天体の赤経 ( α(T)(度) )
    //             .. sekii         : 天体の赤緯 ( δ(T)(度) )
    //             .. time_sidereal : 恒星時Θ(度)
    //             .. height        : 観測地点の出没高度(度)
    //             .. flag          : 出入フラグ ( 0 : 出, 1 : 入, 2 : 南中 )
    // 戻り値 .... 時角の差　dt
    func calcHourAngDif(sekkei: Double, sekii: Double, time_sidereal: Double, height: Double, latitude: Double, flag: Int) -> Double {
        var dt: Double = 0, tk: Double = 0
        if (flag == 2) {
            tk = 0;
        }
        else {
            tk  = sin(PI_180 * height);
            tk -= sin(PI_180 * sekii) * sin(PI_180 * latitude);
            tk /= cos(PI_180 * sekii) * cos(PI_180 * latitude);
            // 出没点の時角
            tk  = acos(tk) / PI_180;
            // tkは出のときマイナス、入のときプラス
            if (flag == 0 && tk > 0) {tk = -tk}
            //if (flag == 1 && tk < 0) {tk = -tk}
            
        }
        // 天体の時角
        let t = time_sidereal - sekkei
        dt = tk - t
        // dtの絶対値を180°以下に調整
        if (dt >  180) {
            while (dt >  180) {
                dt -= 360
            }
        }
        if (dt < -180){
            while (dt < -180) {
                dt += 360
            }
        }
        
        return dt
    }
    // 時刻(t)における赤経、赤緯(α(jy),δ(jy))(度)の天体の方位角(ang)計算
    // 引数   .... hash
    //             .. sekkei : 天体の赤経( α(jy)(度) )
    //             .. sekii  : 天体の赤緯( δ(jy)(度) )
    //             .. jy     : 経過ユリウス年
    //             .. t      : 時刻 ( 0.xxxx日 )
    // 戻り値 .... 角度(xx.x度)
    func calcAngE(sekkei: Double, sekii: Double, jy: Double, t: Double, latitude: Double, longitude: Double) -> Double {
        let time_sidereal: Double = calcTimeSidereal(jy: jy, t: t, longitude: longitude)
        // 天体の時角
        let hour_ang = time_sidereal - sekkei
        // 天体の方位角
        let a_0  = -1.0 * cos(PI_180 * sekii) * sin(PI_180 * hour_ang)
        var a_1  = sin(PI_180 * sekii) * cos(PI_180 * latitude);
        a_1 -= cos(PI_180 * sekii) * sin(PI_180 * latitude) * cos(PI_180 * hour_ang)
        var ang  = atan(a_0 / a_1) / PI_180
        
        // 分母がプラスのときは -90°< ang < 90°
        if (a_1 > 0.0 && ang < 0.0) {
            ang += 360.0
        }
        // 分母がマイナスのときは 90°< ang < 270° → 180°加算する
        if (a_1 < 0.0) {
            ang += 180.0
        }
        ang = round(ang * pow(10, DIGITS)) / pow(10, DIGITS)
        
        return ang
    }
    
    func calcAngleKodo(jy: Double) -> Double {
        return (23.439291 - 0.000130042 * jy) * PI_180
    }
    
    // 黄道座標 -> 赤道座標変換
    // 引数
    //             .. kokei : 黄経( λ(jy)(度) )
    //             .. koi   : 黄緯( β(jy)(度) )
    //             .. jy    : 経過ユリウス年
    // 戻り値 .... hash
    //             .. sekkei : 赤経( α(jy)(度) )
    //             .. sekii  : 赤緯( δ(jy)(度) )
    func calcKou2sekiSekkei(kokei: Double, koi: Double, jy: Double) -> Double {
        // 黄道傾角
        let angle_kodo = calcAngleKodo(jy: jy);
        
        let rambda = kokei * PI_180;
        let beta   = koi   * PI_180;
        let a = cos(beta) * cos(rambda);
        var b = -1 * sin(beta) * sin(angle_kodo);
        b += cos(beta) * sin(rambda) * cos(angle_kodo);
        var sekkei  = b / a;
        sekkei  = atan(sekkei) / PI_180;
        
        if (a < 0) {
            sekkei += 180
        }  // aがマイナスのときは 90°< α < 270° → 180°加算する。
        
        return sekkei
    }
    
    func calcKou2sekiSekii(kokei: Double, koi: Double, jy: Double) -> Double {
        
        // 黄道傾角
        let angle_kodo = calcAngleKodo(jy: jy)
        
        let rambda = kokei * PI_180
        let beta = koi * PI_180
        var c = sin(beta) * cos(angle_kodo )
        c += cos(beta) * sin(rambda) * sin(angle_kodo)
        return asin(c) / PI_180
    }
    
    // 時刻(t)における黄経、黄緯(λ(jy),β(jy))の天体の方位角(ang)計算
    // 引数   .... hash
    //             .. kokei : 天体の黄経( λ(T)(度) )
    //             .. koi   : 天体の黄緯( β(T)(度) )
    //             .. jy    : 経過ユリウス年
    //             .. t     : 時刻 ( 0.xxxx日 )
    // 戻り値 ....  角度(xx.x度)
    func calcAng( kokei: Double, koi: Double, jy: Double, t: Double, latitude: Double, longitude: Double) -> Double {
        // 黄道 -> 赤道変換
        let sekkei = calcKou2sekiSekkei(kokei: kokei, koi: koi, jy: jy)
        let sekii  = calcKou2sekiSekii(kokei: kokei, koi: koi, jy: jy)
        return calcAngE(sekkei: sekkei, sekii: sekii , jy: jy, t: t, latitude: latitude, longitude: longitude)
    }
    
    // 時刻(t)における赤経、赤緯(α(jy),δ(jy))(度)の天体の高度(height)計算
    // 引数   .... hash
    //             .. sekkei : 天体の赤経α(jy)(度)
    //             .. sekii  : 天体の赤緯δ(jy)(度)
    //             .. jy     : 経過ユリウス年
    //             .. t      : 時刻 ( 0.xxxx日 )
    // 戻り値 .... 高度(xx.x度)
    func calcHeightE( sekkei: Double, sekii: Double, jy: Double, t: Double, latitude: Double, longitude: Double) -> Double {
        // 恒星時
        let time_sidereal = calcTimeSidereal(jy: jy, t: t, longitude: longitude)
        
        // 天体の時角
        let sidereal = time_sidereal - sekkei
        // 天体の高度
        var height  = sin(PI_180 * sekii) * sin(PI_180 * latitude)
        height += cos(PI_180 * sekii) * cos(PI_180 * latitude) * cos(PI_180 * sidereal)
        height  = asin(height) / PI_180
        /*
         # 大気差補正
         # [ 以下の内、3-2の計算式を採用 ]
         
         # # 1. 日月出没計算 by「菊池さん」による計算式
         # #   [ http://kikuchisan.net/ ]
         # h = 0.0167 / tan( PI_180 * ( height + 8.6 / ( height + 4.4 ) ) )
         
         # # 2. 中川用語集による計算式 ( 5度 - 85度用 )
         # #   [ http://www.es.ris.ac.jp/~nakagawa/term_collection/yogoshu/ll/ni.htm ]
         # h  = 58.1      / tan( height )
         # h -=  0.07     / tan( height ) ** 3
         # h +=  0.000086 / tan( height ) ** 5
         # h *= 1 / 3600.0
         
         # # 3-1. フランスの天文学者ラドー(R.Radau)の平均大気差と１秒程度の差で大気差を求めることが
         可能
         # # ( 標準的大気(気温10ﾟC，気圧1013.25hPa)の場合 )
         # # ( 視高度30ﾟ以上 )
         # h  = ( 58.294  / 3600.0 ) * tan( PI_180 * ( 90.0 - height ) )
         # h -= (  0.0668 / 3600.0 ) * tan( PI_180 * ( 90.0 - height ) ) ** 3
         
         # 3-2. フランスの天文学者ラドー(R.Radau)の平均大気差と１秒程度の差で大気差を求めることが可
         能
         # ( 標準的大気(気温10ﾟC，気圧1013.25hPa)の場合 )
         # ( 視高度 4ﾟ以上 )
         */
        var h  = 58.76   * tan(PI_180 * (90.0 - height))
        h -=  pow(0.406  * tan(PI_180 * (90.0 - height)) , 2)
        h -=  pow(0.0192 * tan(PI_180 * (90.0 - height)) , 3)
        h *= 1 / 3600.0;
        /*
         # # 3-3. さらに、上記の大気差(3-1,3-2)を気温、気圧を考慮する
         # # ( しかし、気温・気圧を考慮してもさほど変わりはない )
         */
        height += h;
        height  = round(pow(height * 10, DIGITS)) / pow(10, DIGITS);
        
        return height
    }
    
    // 時刻(t)における黄経、黄緯(λ(jy),β(jy))の天体の高度(height)計算
    // 引数   .... hash
    //             .. kokei : 天体の黄経( λ(T)(度) )
    //             .. koi   : 天体の黄緯( β(T)(度) )
    //             .. jy    : 経過ユリウス年
    //             .. t     : 時刻 ( 0.xxxx日 )
    // 戻り値 .... 高度(xx.x度)
    func calcHeight( kokei: Double, koi: Double, jy: Double, t: Double, latitude: Double, longitude: Double) -> Double {
        // 黄道 -> 赤道変換
        let sekkei = calcKou2sekiSekkei(kokei: kokei, koi: koi, jy: jy)
        let sekii  = calcKou2sekiSekii(kokei: kokei, koi: koi, jy: jy)
        let hight = calcHeightE(sekkei: sekkei, sekii: sekii , jy: jy, t: t, latitude: latitude, longitude: longitude)
        return hight;
        
    }
    
    // 年月日(グレゴリオ暦)からユリウス日(JD)を計算する
    //   フリーゲルの公式を使用する
    //   [ JD ] = ( 365.25 × year )
    //          + ( year / 400 )
    //          - ( year / 100 )
    //          + ( 30.59 ( month - 2 ) )
    //          + day
    //          + 1721088
    func gcToJd(year: Double, month: Double, day: Double) -> Double {
        var y = year, m = month
        // 1月,2月は前年の13月,14月とする
        if (month < 3) {
            y -= 1
            m += 12
        }
        // 日付(整数)部分計算
        var jd: Double  = trunc(365.25 * y)
        jd += trunc(y / 400.0)
        jd -= trunc(y / 100.0)
        jd += trunc(30.59 * (m - 2))
        jd += day
        jd += 1721088;
        return jd
    }

    // 元旦からの経過日数計算
    // 引数
    //             .. date_y : 年
    //             .. date_m : 月
    //             .. date_d : 日
    // 戻り値 .... 経過日数(日)
    func calcPassed(year: Double, month: Double, day: Double) -> Double {
        // 前年12月31日のJD
        let jd_0 = gcToJd(year: year - 1, month: 12, day: 31)
        
        // 該当日のJD
        let jd_1 = gcToJd(year: year, month: month, day: day)
        
        // 元旦からの経過日数
        let days = jd_1 - jd_0;
        
        return days;
        
    }

    // 時間：数値->時間：時分変換(xx.xxxx -> hh:mm)
    // 引数   .... num : 時刻 ( xx.xxxx日 )
    // 戻り値 .... 時刻(hh:mm:ss)
    func convertTime(num: Double) -> String {
        // 整数部(時)
        let num_h = trunc(num)
        // 小数部
        let num_2 = num - num_h;
        // (分)計算
        let num_m = trunc(num_2 * 60);
        // (秒)計算
        let num_3 = num_2 - (num_m / 60.0);
        let num_s = round(num_3 * 60 * 60);
        
        let time_jifun: String = String(format:"%02d:%02d:%02d", Int(num_h), Int(num_m), Int(num_s))
        
        return time_jifun;
    }
    
    //NSDate -> year
    func date2year(date: Date) -> Double {
        let df = DateFormatter()
        df.dateFormat  = "yyyy/MM/dd";
        let strDate = df.string(from: date)
        let year = atof(strDate.substring(start: 0, length: 4))//substringEasily(0, end: 4))
        return year
    }

    func nsdate2jy(date: Date) -> Double {
        let year = date2year(date: date)
        let progDate = calcTimeProgress(date: date)
        let jy = calcJy(t: 0, dayProgress: progDate, yr: year)
        
        return jy;
    }

    func lngsun(date: Date) -> Double {
        let jy = nsdate2jy(date: date)
        return calcLngSun(jy: jy) // 黄経（太陽・月）計算
    }
    
    func lngmoon(date: Date) -> Double {
        let jy = nsdate2jy(date: date)
        return calcLngMoon(jy: jy) // 黄経（太陽・月）計算
    }

    // 日の出/日の入/日の南中計算計算
    // 引数   .... flag : 出入フラグ ( 0 : 日の出, 1 : 日の入, 2 : 日の南中 )
    // 戻り値 .... 出入時刻 ( 0.xxxx日 )
    func calcTimeSun(day_progress: Double, rotate_rev: Double, height: Double, longitude: Double, latitude:Double, flag: Int) -> Double {
        // 補正値初期値
        var rev = 1.0
        // 逐次計算時刻(日)初期設定
        var time_loop = 0.5
        // 逐次計算
        while fabs(rev) > CONVERGE {
            // time_loopの経過ユリウス年
            let jy = (day_progress + time_loop + rotate_rev) / 365.25;
            // 太陽の黄経
            let kokei_sun = calcLngSun(jy: jy);
            // 太陽の距離
            let dist_sun  = calcDistSun(jy: jy);
            // 黄道 -> 赤道変換
            let koi: Double   = 0;
            let sekkei = calcKou2sekiSekkei(kokei: kokei_sun, koi: koi, jy: jy);
            let sekii  = calcKou2sekiSekii(kokei: kokei_sun, koi: koi, jy: jy);
            // 太陽の視半径
            let r_sun = 0.266994 / dist_sun;
            // 太陽の視差
            let dif_sun = 0.0024428 / dist_sun;
            // 太陽の出入高度
            let height_sun = -1 * r_sun - ASTRO_REFRACT - dip(height: height) + dif_sun;
            // 恒星時
            let time_sidereal = calcTimeSidereal(jy: jy, t: time_loop, longitude: longitude);
            // 時角差計算
            let hour_ang_dif = calcHourAngDif(sekkei: sekkei, sekii: sekii , time_sidereal: time_sidereal, height: height_sun, latitude: latitude, flag: flag);
            // 仮定時刻に対する補正値
            rev = hour_ang_dif / 360.0;
            time_loop = time_loop + rev;

        }
        return time_loop
    }
    // 月の出/月の入/月の南中計算
    // 引数   .... flag : 出入フラグ ( 0 : 月の出, 1 : 月の入, 2 : 月の南中 )
    // 戻り値 .... 出入時刻 ( 0.xxxx日 )
    func calcTimeMoon(day_progress: Double, rotate_rev: Double, height: Double,  longitude: Double, latitude: Double, flag :Int) -> Double {
        // 補正値初期値
        var rev: Double = 1.0;
        // 逐次計算時刻(日)初期設定
        var time_loop:Double = 0.5;
        //int i = 0;
        // 逐次計算
        while (fabs(rev) > CONVERGE) {
            // time_loopの経過ユリウス年
            let jy = (day_progress + time_loop + rotate_rev) / 365.25;
            // 月の黄経
            let kokei_moon = calcLngMoon(jy: jy);
            // 月の黄緯
            let koi_moon   = calcLatMoon(jy: jy);
            // 黄道 -> 赤道変換
            
            let sekkei = calcKou2sekiSekkei(kokei: kokei_moon, koi: koi_moon, jy: jy);
            let sekii  = calcKou2sekiSekii(kokei: kokei_moon, koi: koi_moon, jy: jy);
            var height_moon: Double = 0;
            
            if (flag != 2) {  // 南中のときは計算しない
                // 月の視差
                let dif_moon = calcDifMoon(jy: jy);
                // 月の出入高度
                height_moon = -1 * ASTRO_REFRACT - dip(height: height) + dif_moon;
            }
            
            // 恒星時
            let time_sidereal = calcTimeSidereal(jy: jy, t: time_loop, longitude: longitude);
            // 時角差計算
            let hour_ang_dif = calcHourAngDif(sekkei: sekkei, sekii:sekii , time_sidereal: time_sidereal, height: height_moon, latitude: latitude, flag: flag);
            // 仮定時刻に対する補正値
            rev = hour_ang_dif / 347.8;
            time_loop = time_loop + rev;
            
        }
        //月の出/月の入りがない場合は 0 とする
        if (time_loop < 0) || (time_loop >= 1) {
            time_loop = 0
        }
        
        return time_loop
    }
    
    func sunRizeSet(date: Date, height: Double, longitude: Double, latitude: Double, flag: Int) -> String
    {
        let day_progress = calcTimeProgress(date: date)
        let year = date2year(date: date)
        let drotate_rev = rotateRev(year: year)
        let dTime = calcTimeSun(day_progress: day_progress, rotate_rev: drotate_rev, height: height, longitude: longitude, latitude:latitude, flag: flag)
        return convertTime(num: dTime * 24)
    }
    
    func moonRizeSet(date: Date, height: Double, longitude: Double, latitude: Double, flag: Int) -> String
    {
        let day_progress = calcTimeProgress(date: date)
        let year = date2year(date: date)
        let drotate_rev = rotateRev(year: year)
        let dTime = calcTimeMoon(day_progress: day_progress, rotate_rev: drotate_rev, height: height, longitude: longitude, latitude:latitude, flag: flag)
        return convertTime(num: dTime * 24)
    }
    

}


