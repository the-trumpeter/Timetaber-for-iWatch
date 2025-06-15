//
//  Timetable.swift
//  Timetaber for iWatch
//  Variable definition script
//
//  Created by Gill Palmer on 5/11/2024


let normTimes = [0900, 0910, 1010, 1110, 1130, 1230, 1330, 1410, 1510]

let monTimes = [0900, 0910, 1000, 1030, 1110, 1130, 1230, 1330, 1410, 1510]
let wedTimes = [0900, 1000, 1050, 1100, 1120, 1210, 1300, 1330, 1510, 1730]
let thuTimes = [0900, 0910, 1010, 1110, 1130, 1230, 1330, 1410, 1630]




let monA: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: English9, 1000: MLPeriod, 1030: PACourseBG,
    1110: RecessPeriod, 1130: PDHPE3, 1230: ScienceCourse,
    1330: JSBCourse, 1410: VisualArtsCourse, 1510: noSchool()
]

let tueA: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: VisualArtsCourse, 1010: PACourseC1,
    1110: RecessPeriod, 1130: PDHPE1, 1230: English9,
    1330: LunchPeriod, 1410: MathsCourse, 1510: noSchool()
]

let wedA: Dictionary<Int, Course> = [
    0900: TAS, 1050: yearAssembly,
    1100: RecessPeriod, 1120: ScienceCourse, 1210: MathsCourse,
    1300: LunchPeriod, 1330: TCCourse, 1510: MSBCourse, 1730: noSchool()
]

let thuA: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: ScienceCourse, 1010: MultimediaCourse,
    1110: RecessPeriod, 1130: HSIECourse, 1230: English6,
    1330: LunchPeriod, 1410: JCBCourse, 1530: GreaseOrchCourse, 1700: noSchool()
]

let friA: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: TAS, 1010: PDHPE1,
    1110: RecessPeriod, 1130: ScienceCourse, 1230: English9,
    1330: LunchPeriod, 1410: MultimediaCourse, 1510: noSchool()
]



let monB: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: English9, 1000: MLPeriod, 1030: VisualArtsCourse,
    1110: RecessPeriod, 1130: HSIECourse, 1230: MathsCourse,
    1330: JSBCourse, 1410: PDHPE3, 1510: noSchool()
]

let tueB: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: MultimediaCourse, 1010: MathsCourse,
    1110: RecessPeriod, 1130: PACourseBT, 1230: English9,
    1330: LunchPeriod, 1410: TAS, 1510: noSchool()
]

let wedB: Dictionary<Int, Course> = [
    0900: HSIECourse, 1000: MathsCourse, 1050: yearAssembly,
    1100: RecessPeriod, 1120: VisualArtsCourse, 1210: ScienceCourse,
    1300: LunchPeriod, 1330: TCCourse, 1510: MSBCourse, 1730: noSchool()
]

let thuB: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: VisualArtsCourse, 1010: ScienceCourse,
    1110: RecessPeriod, 1130: English9, 1230: MathsCourse,
    1330: LunchPeriod, 1410: JCBCourse, 1530: GreaseOrchCourse, 1700: noSchool()
]

let friB: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: MathsCourse, 1010: HSIECourse,
    1110: RecessPeriod, 1130: TAS, 1230: ScienceCourse,
    1330: LunchPeriod, 1410: PACourseC1, 1510: noSchool()
]
