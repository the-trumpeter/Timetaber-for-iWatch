//
//  Timetable.swift
//  Timetaber for iWatch
//
//  Created by Gill Palmer on 5/11/2024


let normTimes = [0900, 0910, 1010, 1110, 1130, 1230, 1330, 1410, 1510]

let monTimes = [0900, 0910, 1000, 1030, 1110, 1130, 1230, 1330, 1410, 1510]
let wedTimes = [0900, 1000, 1050, 1100, 1120, 1210, 1300, 1330, 1510, 1730]
let thuTimes = [0900, 0910, 1010, 1110, 1130, 1230, 1330, 1410, 1630]




let monA: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: English9, 1000: MLClass, 1030: PAClassBG,
    1110: RecessClass, 1130: PDHPE3, 1230: ScienceClass,
    1330: JSBClass, 1410: VisualArtsClass, 1510: noSchool
]//

let tueA: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: VisualArtsClass, 1010: PAClassC1,
    1110: RecessClass, 1130: PDHPE1, 1230: English9,
    1330: LunchClass, 1410: MathsClass, 1510: noSchool
]

let wedA: Dictionary<Int, Course> = [
    0900: TAS, 1000: TAS, 1050: yearAssemblyClass,
    1100: RecessClass, 1120: ScienceClass, 1210: MathsClass,
    1300: LunchClass, 1330: TCClass, 1510: MSBClass, 1730: noSchool
]

let thuA: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: ScienceClass, 1010: MultimediaClass,
    1110: RecessClass, 1130: HSIE, 1230: English6,
    1330: LunchClass, 1410: JCBClass, 1630: noSchool
]

let friA: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: TAS, 1010: PDHPE1,
    1110: RecessClass, 1130: ScienceClass, 1230: English9,
    1330: LunchClass, 1410: MultimediaClass, 1510: noSchool
]

let monB: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: English9, 1000: MLClass, 1030: VisualArtsClass,
    1110: RecessClass, 1130: HSIE, 1230: MathsClass,
    1330: JSBClass, 1410: PDHPE3, 1510: noSchool
]

let tueB: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: MultimediaClass, 1010: MathsClass,
    1110: RecessClass, 1130: PAClassBT, 1230: English9,
    1330: LunchClass, 1410: TAS, 1510: noSchool
]

let wedB: Dictionary<Int, Course> = [
    0900: HSIE, 1000: MathsClass, 1050: yearAssemblyClass,
    1100: RecessClass, 1120: VisualArtsClass, 1210: ScienceClass,
    1300: LunchClass, 1330: TCClass, 1510: MSBClass, 1730: noSchool
]

let thuB: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: VisualArtsClass, 1010: ScienceClass,
    1110: RecessClass, 1130: English9, 1230: MathsClass,
    1330: LunchClass, 1410: JCBClass, 1630: noSchool
]

let friB: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: MathsClass, 1010: HSIE,
    1110: RecessClass, 1130: TAS, 1230: ScienceClass,
    1330: LunchClass, 1410: PAClassC1, 1510: noSchool
]
