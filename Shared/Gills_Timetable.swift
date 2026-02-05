//
//  Timetable_sharing.swift
//  Timetaber
//
//  Created by Gill Palmer on 17/10/2025.
//

import Foundation

//TODO: This UUID buisness is messy, need to come up with better way to format (again)
///Gill's 2024 timetable, used for testing/debugging
///
///This might also be used for things like intuivity testing, and may/may-not be a template at some point.
var chaos: Timetable = {
	typealias Contents = Times.Period.Contents
	let checkInID = 		UUID()
	let englishID = 		UUID()
	let hsieID = 			UUID()
	let juniorCBID = 		UUID()
	let jrStageID = 		UUID()
	let lunchID = 			UUID()
	let mathsID = 			UUID()
	let musicLessonID = 	UUID()
	let multimediaID = 		UUID()
	let marchingBandID = 	UUID()
	let crixID = 			UUID()
	let pdhpeID = 			UUID()
	let recessID = 			UUID()
	let seniorCBID = 		UUID()
	let scienceID = 		UUID()
	let stageBandID = 		UUID()
	let iStemID = 			UUID()
	let theatreCrewID = 	UUID()
	let visualArtsID = 		UUID()
	let yearAssemblyID = 	UUID()
	let uniID = 			UUID()

	let courses = [
		checkInID: Course2("Check In",    icon: "face.smiling",                rooms: ["HG1"],                 colour: "Graphite",                                listIcon: "face.smiling.inverse"),
		englishID: Course2("English",         icon: "book.closed",                 rooms: ["BT4", "BT2"],            colour: "Lemon"),
		hsieID: Course2("HSIE",            icon: "building.columns",                 rooms: ["BG8"],                 colour: "Rees1"),
		juniorCBID: Course2("Junior C.B.", icon: "music.note",                                                 colour: "Cherry"),
		jrStageID: Course2("Jr Stage",        icon: "music.note",                 rooms: ["BT1"],                 colour: "Graphite",    listName:"Junior S.B."),
		lunchID: Course2("Lunch",         icon: "fork.knife",                                                 colour: "Graphite"),
		mathsID: Course2("Maths",        icon: "number",                     rooms: ["FT2", "FT8"],                 colour: "Rose"),
		musicLessonID: Course2("Music Lesson", icon: "music.note",                                             colour: "Graphite"),
		multimediaID: Course2("Multimedia",     icon: "movieclapper",                rooms: ["GG2"],                 colour: "Blueberry"),
		marchingBandID: Course2("Marching Band",icon: "flag.filled.and.flag.crossed",                                 colour: "Cherry",    listName:"Marching Bd.",    listIcon: "flag.2.crossed.circle.fill", iOSListIcon: "flag"),
		crixID: Course2("Creative Ind.",     icon: "theatremasks",                    rooms: ["GG3"],    colour: "Blueberry"),
		pdhpeID: Course2("PDHPE",         icon: "figure.run",                 rooms: ["PRAC", "THEORY"],        colour: "Lime"),
		recessID: Course2("Recess",         icon: "fork.knife",                                                 colour: "Graphite"),
		seniorCBID: Course2("Senior C.B.",     icon: "music.note",                                                 colour: "Cherry"),
		scienceID: Course2("Science",         icon: "flask",                         rooms: ["FT10"],                 colour: "Ice",                                    listIcon: "flame.circle.fill"),
		stageBandID: Course2("Stage Band",    icon: "music.note",                                                 colour: "Cherry",     listName: "Senior S.B."),
		iStemID: Course2("iSTEM",             icon: "cpu",                     rooms: ["FT4"],                 colour: "Blueberry"),
		theatreCrewID: Course2("Theatre Crew", icon: "headset",                                                 colour: "Peach"),
		yearAssemblyID: Course2("Year Assembly",icon: "megaphone",                                                 colour: "Graphite",    listName: "Assembly",        listIcon: "person.2.circle.fill"),
		uniID: Course2("UoN OOP", 				icon: "graduationcap", rooms: ["TBD", "Enroute"], colour: "graphite")
	]

	// Standard period IDs
	let pCheckInStd = UUID()
	let p1Std = UUID()
	let p2Std = UUID()
	let pRecessStd = UUID()
	let p3Std = UUID()
	let p4Std = UUID()
	let pLunchStd = UUID()
	let p5Std = UUID()

	// Variant: 9:30 Music lesson
	let v930_CheckIn = UUID()
	let v930_P1a = UUID()
	let v930_ML = UUID()
	let v930_P1b = UUID()
	let v930_P2 = UUID()
	let v930_Recess = UUID()
	let v930_P3 = UUID()
	let v930_P4 = UUID()
	let v930_Lunch = UUID()
	let v930_P5 = UUID()

	// Variant: Band til 5pm
	let v5pm_CheckIn = UUID()
	let v5pm_P1 = UUID()
	let v5pm_P2 = UUID()
	let v5pm_Recess = UUID()
	let v5pm_P3 = UUID()
	let v5pm_P4 = UUID()
	let v5pm_Lunch = UUID()
	let v5pm_P5 = UUID()
	let v5pm_SBU = UUID()

	// Variant: Band til 5:30
	let v530_CheckIn = UUID()
	let v530_P1 = UUID()
	let v530_P2 = UUID()
	let v530_Recess = UUID()
	let v530_P3 = UUID()
	let v530_P4 = UUID()
	let v530_Lunch = UUID()
	let v530_P5 = UUID()
	let v530_SBU = UUID()

	// Variant: Band til 4:30
	let v430_CheckIn = UUID()
	let v430_P1 = UUID()
	let v430_P2 = UUID()
	let v430_Recess = UUID()
	let v430_P3 = UUID()
	let v430_P4 = UUID()
	let v430_Lunch = UUID()
	let v430_P5 = UUID()
	let v430_SBU = UUID()

	let vFri_CheckIn = UUID()
	let vFri_P1 = UUID()
	let vFri_P2 = UUID()
	let vFri_Recess = UUID()
	let vFri_P3 = UUID()
	let vFri_P4 = UUID()
	let vFri_Lunch = UUID()
	let vFri_P5 = UUID()
	let vFri_travel = UUID()
	let vFri_uni = UUID()

	let times = Times(
		standard: [
			   pCheckInStd: Times.Period ("Check In",startTime: 0900,	duration: 10),
			   p1Std: Times.Period ("1",		startTime: 0910,	duration: 60),
			   p2Std: Times.Period ("2",		startTime: 1010,	duration: 60),
			   pRecessStd: Times.Period ("Recess",startTime: 1110,	duration: 20),
			   p3Std: Times.Period ("3",		startTime: 1130,	duration: 60),
			   p4Std: Times.Period ("4",		startTime: 1230,	duration: 60),
			   pLunchStd: Times.Period ("Lunch",startTime: 1330,	duration: 40),
			   p5Std: Times.Period ("5",		startTime: 1410,	duration: 60)
		   ],
		   variants: [
			   UUID():	Times.Variant("mon",	variant: [
				   v930_CheckIn: Times.Period ("Check In",startTime: 0900,	duration: 10),
				   v930_P1a: Times.Period ("1",		startTime: 0910,	duration: 50),
				   v930_ML: Times.Period ("ML",		startTime: 1000,	duration: 30),
				   v930_P2: Times.Period ("2",		startTime: 1020,	duration: 50),
				   v930_Recess: Times.Period ("Recess",startTime: 1110,	duration: 20),
				   v930_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
				   v930_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
				   v930_Lunch: Times.Period ("Lunch",startTime: 1330,	duration: 40),
				   v930_P5: Times.Period ("5",		startTime: 1410,	duration: 60)
			   ]),
			   UUID():	Times.Variant("tue", 		variant: [
				   v5pm_CheckIn: Times.Period ("Check In",startTime: 0900,	duration: 10),
				   v5pm_P1: Times.Period ("1",		startTime: 0910,	duration: 60),
				   v5pm_P2: Times.Period ("2",		startTime: 1010,	duration: 60),
				   v5pm_Recess: Times.Period ("Recess",startTime: 1110,	duration: 20),
				   v5pm_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
				   v5pm_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
				   v5pm_Lunch: Times.Period ("Lunch",startTime: 1330,	duration: 40),
				   v5pm_P5: Times.Period ("5",		startTime: 1410,	duration: 60),
				   v5pm_SBU: Times.Period ("SBU",	startTime: 1510,	duration:110)
			   ]),
			   UUID():	Times.Variant("wed",		variant: [
				   v530_CheckIn: Times.Period ("Check In",startTime: 0900,	duration: 10),
				   v530_P1: Times.Period ("1",		startTime: 0910,	duration: 60),
				   v530_P2: Times.Period ("2",		startTime: 1010,	duration: 60),//should there be YA here?
				   v530_Recess: Times.Period ("Recess",startTime: 1110,	duration: 20),
				   v530_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
				   v530_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
				   v530_Lunch: Times.Period ("Lunch",startTime: 1330,	duration: 40),
				   v530_P5: Times.Period ("5",		startTime: 1410,	duration: 60),
				   v530_SBU: Times.Period ("SBU",	startTime: 1510,	duration:140)
			   ]),
			   UUID():	Times.Variant("thu",		variant: [
				   v430_CheckIn: Times.Period ("Check In",startTime: 0900,	duration: 10),
				   v430_P1: Times.Period ("1",		startTime: 0910,	duration: 60),
				   v430_P2: Times.Period ("2",		startTime: 1010,	duration: 60),
				   v430_Recess: Times.Period ("Recess",startTime: 1110,	duration: 20),
				   v430_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
				   v430_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
				   v430_Lunch: Times.Period ("Lunch",startTime: 1330,	duration: 40),
				   v430_P5: Times.Period ("5",		startTime: 1410,	duration: 60),
				   v430_SBU: Times.Period ("SBU",	startTime: 1510,	duration: 80)
			   ]),
			   UUID(): Times.Variant("fri",		variant: [
					vFri_CheckIn: Times.Period ("Check In",	startTime: 0900,	duration: 10),
					vFri_P1: Times.Period ("1",		startTime: 0910,	duration: 60),
					vFri_P2: Times.Period ("2",		startTime: 1010,	duration: 60),
					vFri_Recess: Times.Period ("Recess",	startTime: 1110,	duration: 20),
					vFri_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
					vFri_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
					vFri_Lunch: Times.Period ("Lunch",	startTime: 1330,	duration: 40),
					vFri_P5: Times.Period ("5",		startTime: 1410,	duration: 10),
					vFri_travel: Times.Period ("",			startTime: 1420,	duration: 40),//travel
					vFri_uni: Times.Period ("",			startTime: 1500,	duration: 120),//uni
				]),
		   ],
		   mapping: [
			   2: "mon", //mon
			   3: "tue", //tue
			   4: "wed", //wed
			   5: "thu", //thu
			   6: "fri"  //fri
		   ]
	   )
	return Timetable(
		"Gill's Timetable",
		icon: "backpack",

		courses: courses,
		times: times,
		timetable: [
			// Week A (key 1): Mon..Fri (from previous 1..5)
			Timetable.TimetabledWeek(
				monday: [
					v930_CheckIn: Contents(courseID: checkInID,	roomIndex: 0),
					v930_P1a: Contents(courseID: multimediaID,	roomIndex: 0),
					v930_ML: Contents(courseID: musicLessonID,	roomIndex: 0),
					v930_P2: Contents(courseID: scienceID,		roomIndex: 0),
					v930_Recess: Contents(courseID: recessID,	roomIndex: 0),
					v930_P3: Contents(courseID: englishID,		roomIndex: 0),
					v930_P4: Contents(courseID: pdhpeID,		roomIndex: 0),
					v930_Lunch: Contents(courseID: jrStageID,	roomIndex: 0),
					v930_P5: Contents(courseID: iStemID,		roomIndex: 0),
					//UUID(): Contents(course: 21, variant: 0)
				],
				tuesday: [
					v5pm_CheckIn: Contents(courseID: checkInID,	roomIndex: 0),
					v5pm_P1: Contents(courseID: scienceID,		roomIndex: 0),
					v5pm_P2: Contents(courseID: hsieID,			roomIndex: 0),
					v5pm_Recess: Contents(courseID: recessID,	roomIndex: 0),
					v5pm_P3: Contents(courseID: englishID,		roomIndex: 0),
					v5pm_P4: Contents(courseID: mathsID,		roomIndex: 0),
					v5pm_Lunch: Contents(courseID: lunchID,		roomIndex: 0),
					v5pm_P5: Contents(courseID: multimediaID,	roomIndex: 0),
					v5pm_SBU: Contents(courseID: stageBandID,	roomIndex: 0),
					//UUID(): Contents(course: 21, variant: 0)
				],
				wednesday: [
					v530_CheckIn: Contents(courseID: iStemID, roomIndex: 0),
					v530_P1: Contents(courseID: mathsID, roomIndex: 0),
					v530_P2: Contents(courseID: recessID, roomIndex: 0),
					v530_Recess: Contents(courseID: recessID, roomIndex: 0),
					v530_P3: Contents(courseID: crixID, roomIndex: 0),
					v530_P4: Contents(courseID: hsieID, roomIndex: 0),
					v530_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					v530_P5: Contents(courseID: theatreCrewID, roomIndex: -1),
					v530_SBU: Contents(courseID: marchingBandID, roomIndex: -1),
					//UUID(): Contents(course: 21, variant: 0)
				],//.compactMapValues { $0 },
				thursday: [
					v430_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					v430_P1: Contents(courseID: englishID, roomIndex: 1),
					v430_P2: Contents(courseID: pdhpeID, roomIndex: 1),
					v430_Recess: Contents(courseID: recessID, roomIndex: 0),
					v430_P3: Contents(courseID: hsieID, roomIndex: 0),
					v430_P4: Contents(courseID: scienceID, roomIndex: 0),
					v430_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					v430_P5: Contents(courseID: crixID, roomIndex: 0),
					v430_SBU: Contents(courseID: juniorCBID, roomIndex: -1)
				],
				friday: [
					vFri_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					vFri_P1: Contents(courseID: hsieID, roomIndex: 0),
					vFri_P2: Contents(courseID: scienceID, roomIndex: 0),
					vFri_Recess: Contents(courseID: recessID, roomIndex: 0),
					vFri_P3: Contents(courseID: mathsID, roomIndex: 0),
					vFri_P4: Contents(courseID: crixID, roomIndex: 0),
					vFri_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					vFri_P4: Contents(courseID: englishID, roomIndex: 0),
					vFri_travel: Contents(courseID: uniID, roomIndex: 1),
					vFri_uni: Contents(courseID: uniID, roomIndex: 0)
					//UUID(): Contents(course: 21, variant: 0)
				]
			),

			// Week B (key 2): Mon..Fri (from previous 6..10)
			Timetable.TimetabledWeek(
				monday: [
					v930_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					v930_P1a: Contents(courseID: multimediaID, roomIndex: 0),
					v930_ML: Contents(courseID: musicLessonID, roomIndex: 0),
					v930_P2: Contents(courseID: mathsID, roomIndex: 1),
					v930_Recess: Contents(courseID: recessID, roomIndex: 0),
					v930_P3: Contents(courseID: iStemID, roomIndex: 0),
					v930_P4: Contents(courseID: jrStageID, roomIndex: 0),
					v930_Lunch: Contents(courseID: pdhpeID, roomIndex: 1),
					//UUID(): Contents(course: 21, variant: 0)
				],
				tuesday: [
					v5pm_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					v5pm_P1: Contents(courseID: scienceID, roomIndex: 0),
					v5pm_P2: Contents(courseID: hsieID, roomIndex: 0),
					v5pm_Recess: Contents(courseID: recessID, roomIndex: 0),
					v5pm_P3: Contents(courseID: mathsID, roomIndex: 0),
					v5pm_P4: Contents(courseID: multimediaID, roomIndex: 0),
					v5pm_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					v5pm_P5: Contents(courseID: englishID, roomIndex: 0),
					v5pm_SBU: Contents(courseID: stageBandID, roomIndex: 0),
					//UUID(): Contents(course: 21, variant: 0)
				],
				wednesday: [
					v530_CheckIn: Contents(courseID: hsieID, roomIndex: 0),
					v530_P1: Contents(courseID: mathsID, roomIndex: 0),
					v530_P2: Contents(courseID: yearAssemblyID, roomIndex: 0),
					v530_Recess: Contents(courseID: recessID, roomIndex: 0),
					v530_P3: Contents(courseID: visualArtsID, roomIndex: 0),
					v530_P4: Contents(courseID: scienceID, roomIndex: 0),
					v530_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					v530_P5: Contents(courseID: seniorCBID, roomIndex: 0),
					v530_SBU: Contents(courseID: marchingBandID, roomIndex: 0),
					//UUID(): Contents(course: 21, variant: 0)
				],
				thursday: [
					v430_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					v430_P1: Contents(courseID: hsieID, roomIndex: 0),
					v430_P2: Contents(courseID: pdhpeID, roomIndex: 0),
					v430_Recess: Contents(courseID: recessID, roomIndex: 0),
					v430_P3: Contents(courseID: englishID, roomIndex: 0),
					v430_P4: Contents(courseID: scienceID, roomIndex: 0),
					v430_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					v430_P5: Contents(courseID: crixID, roomIndex: 0),
					v430_SBU: Contents(courseID: juniorCBID, roomIndex: -1),
					//UUID(): Contents(course: 21, variant: 0)
				],
				friday: [
					vFri_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					vFri_P1: Contents(courseID: crixID, roomIndex: 0),
					vFri_P2: Contents(courseID: englishID, roomIndex: 0),
					vFri_Recess: Contents(courseID: recessID, roomIndex: 0),
					vFri_P3: Contents(courseID: iStemID, roomIndex: 0),
					vFri_P4: Contents(courseID: mathsID, roomIndex: 0),
					vFri_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					vFri_P5: Contents(courseID: multimediaID, roomIndex: 0),
					vFri_travel: Contents(courseID: uniID, roomIndex: 1),
					vFri_uni: Contents(courseID: uniID, roomIndex: 0)
					//UUID(): Contents(course: 21, variant: 0)
				]
			)
		]
	)
}()

