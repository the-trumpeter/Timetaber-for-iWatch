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
    0900: CheckInClass, 0910: PDHPETheo, 1000: MLClass, 1030: LanguageClass,
    1110: RecessClass, 1130: MusicClassBT, 1230: EnglishClass,
    1330: JSBClass, 1410: MathsClass, 1510: noSchool
]

let tueA: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: TAS_H, 1010: ScienceClass,
    1110: RecessClass, 1130: HSIERees, 1230: MathsClass,
    1330: LunchClass, 1410: MusicClassBG, 1510: noSchool
]

let wedA: Dictionary<Int, Course> = [
    0900: MathsClass, 1000: Science2Class, 1050: yearAssemblyClass,
    1100: RecessClass, 1120: EnglishClass, 1210: PAClassBT,
    1300: LunchClass, 1330: TCClass, 1510: MSBClass, 1730: noSchool
]

let thuA: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: MathsClass, 1010: LanguageClass,
    1110: RecessClass, 1130: PAClassBT, 1230: TAS_G,
    1330: LunchClass, 1410: CBClass, 1630: noSchool
]

let friA: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: HSIERees, 1010: PDHPETheo,
    1110: RecessClass, 1130: ScienceClass, 1230: MusicClassBG,
    1330: LunchClass, 1410: EnglishClass, 1510: noSchool
]

let monB: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: MathsClass, 1000: MLClass, 1030: EnglishClass,
    1110: RecessClass, 1130: PAClassC1, 1230: ScienceClass,
    1330: JSBClass, 1410: TAS_G, 1510: noSchool
]

let tueB: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: LanguageClass, 1010: HSIERees,
    1110: RecessClass, 1130: PAClassC1, 1230: ScienceClass,
    1330: LunchClass, 1410: TAS_G, 1510: noSchool
]

let wedB: Dictionary<Int, Course> = [
    0900: MathsClass, 1000: PDHPEPrac, 1050: yearAssemblyClass,
    1100: RecessClass, 1120: HSIEAnder, 1210: PAClassBG,
    1300: LunchClass, 1330: TCClass, 1510: MSBClass, 1730: noSchool
]

let thuB: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: TAS_H, 1010: MusicClassC2,
    1110: RecessClass, 1130: EnglishClass, 1230: LanguageClass,
    1330: LunchClass, 1410: CBClass, 1630: noSchool
]

let friB: Dictionary<Int, Course> = [
    0900: CheckInClass, 0910: PDHPETheo, 1010: EnglishClass,
    1110: RecessClass, 1130: HSIEAnder, 1230: ScienceClass,
    1330: LunchClass, 1410: LanguageClass, 1510: noSchool
]
