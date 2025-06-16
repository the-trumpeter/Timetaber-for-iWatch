//
//  Timetable.swift
//  Timetaber for iWatch
//  Variable definition script
//
//  Created by Gill Palmer on 5/11/2024


let wkA = [monA, tueA, wedA, thuA, friA]
let wkB = [monB, tueB, wedB, thuB, friB]

let monA: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: English9, 1000: MLPeriod, 1030: PACourseBG,
    1110: RecessPeriod, 1130: PDHPE3, 1230: ScienceCourse,
    1330: JSBCourse, 1410: VisualArtsCourse, 1510: noSchool(.afterClass)
]

let tueA: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: VisualArtsCourse, 1010: PACourseC1,
    1110: RecessPeriod, 1130: PDHPE1, 1230: English9,
    1330: LunchPeriod, 1410: MathsCourse, 1510: noSchool(.afterClass)
]

let wedA: Dictionary<Int, Course> = [
    0900: TAS, 1050: yearAssembly,
    1100: RecessPeriod, 1120: ScienceCourse, 1210: MathsCourse,
    1300: LunchPeriod, 1330: TCCourse, 1510: MSBCourse, 1730: noSchool(.afterClass)
]

let thuA: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: ScienceCourse, 1010: MultimediaCourse,
    1110: RecessPeriod, 1130: HSIECourse, 1230: English6,
    1330: LunchPeriod, 1410: JCBCourse, 1530: GreaseOrchCourse, 1700: noSchool(.afterClass)
]

let friA: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: TAS, 1010: PDHPE1,
    1110: RecessPeriod, 1130: ScienceCourse, 1230: English9,
    1330: LunchPeriod, 1410: MultimediaCourse, 1510: noSchool(.afterClass)
]



let monB: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: English9, 1000: MLPeriod, 1030: VisualArtsCourse,
    1110: RecessPeriod, 1130: HSIECourse, 1230: MathsCourse,
     1330: JSBCourse, 1410: PDHPE3, 1510: noSchool(.afterClass)
]

let tueB: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: MultimediaCourse, 1010: MathsCourse,
    1110: RecessPeriod, 1130: PACourseBT, 1230: English9,
    1330: LunchPeriod, 1410: TAS, 1510: noSchool(.afterClass)
]

let wedB: Dictionary<Int, Course> = [
    0900: HSIECourse, 1000: MathsCourse, 1050: yearAssembly,
    1100: RecessPeriod, 1120: VisualArtsCourse, 1210: ScienceCourse,
    1300: LunchPeriod, 1330: TCCourse, 1510: MSBCourse, 1730: noSchool(.afterClass)
]

let thuB: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: VisualArtsCourse, 1010: ScienceCourse,
    1110: RecessPeriod, 1130: English9, 1230: MathsCourse,
    1330: LunchPeriod, 1410: JCBCourse, 1530: GreaseOrchCourse, 1700: noSchool(.afterClass)
]

let friB: Dictionary<Int, Course> = [
    0900: CheckInCourse, 0910: MathsCourse, 1010: HSIECourse,
    1110: RecessPeriod, 1130: TAS, 1230: ScienceCourse,
    1330: LunchPeriod, 1410: PACourseC1, 1510: noSchool(.afterClass)
]
