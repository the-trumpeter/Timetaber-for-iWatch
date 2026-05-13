//
//  Timetable_sharing.swift
//  Timetaber
//
//  Created by Gill Palmer on 17/10/2025.
//

import Foundation

//TODO: This UUID buisness is messy, need to come up with better way to format (again)
///Gill's 2026 timetable, used for testing/debugging
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
	let travelID = 			UUID()
	let gdgID = 			UUID()
	let uniID = 			UUID()

	let courses = [
		checkInID: Course2("Check In",    icon: "face.smiling",                rooms: ["HG1"],                 colour: "Graphite"),
		englishID: Course2("English",         icon: "book.closed",                 rooms: ["BT4", "BT2"],            colour: "Lemon"),
		hsieID: Course2("HSIE",            icon: "building.columns",                 rooms: ["BG8"],                 colour: "Rees1"),
		juniorCBID: Course2("Junior C.B.", icon: "music.note",                                                 colour: "Cherry"),
		jrStageID: Course2("Jr Stage",        icon: "music.note",                 rooms: ["BT1"],                 colour: "Graphite"),
		lunchID: Course2("Lunch",         icon: "fork.knife",                                                 colour: "Graphite"),
		mathsID: Course2("Maths",        icon: "number",                     rooms: ["FT2", "FT8"],                 colour: "Rose"),
		musicLessonID: Course2("Music Lesson", icon: "music.note",                                             colour: "Graphite"),
		multimediaID: Course2("Multimedia",     icon: "movieclapper",                rooms: ["GG2"],                 colour: "Blueberry"),
		marchingBandID: Course2("Marching Band",icon: "flag.filled.and.flag.crossed",                                 colour: "Cherry"),
		crixID: Course2("Creative Ind.",     icon: "theatermasks",                    rooms: ["GG3"],    colour: "Blueberry"),
		pdhpeID: Course2("PDHPE",         icon: "figure.run",                 rooms: ["PRAC", "THEORY"],        colour: "Lime"),
		recessID: Course2("Recess",         icon: "fork.knife",                                                 colour: "Graphite"),
		seniorCBID: Course2("Senior C.B.",     icon: "music.note",                                                 colour: "Cherry"),
		scienceID: Course2("Science",         icon: "flask",                         rooms: ["FG5"],                 colour: "Ice"),
		stageBandID: Course2("Stage Band",    icon: "music.note",                                                 colour: "Cherry"),
		iStemID: Course2("iSTEM",             icon: "cpu",                     rooms: ["GG2"],                 colour: "Blueberry"),
		theatreCrewID: Course2("Theatre Crew", icon: "headset",                                                 colour: "Peach"),
		yearAssemblyID: Course2("Year Assembly",icon: "megaphone",                                                 colour: "Graphite"),	
		travelID: Course2("Travel", 				icon: "bus.fill", colour: "graphite"),
		gdgID: Course2("GDGs", 				icon: "book.closed", rooms: [], colour: "graphite"),
		uniID: Course2("Law @ UoN", 				icon: "graduationcap", rooms: ["X502"], colour: "black")
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

	// Variant: Monday (ML, GDGs)
	let mon_CheckIn = UUID()
	let mon_P1a = UUID()
	let mon_ML = UUID()
	let mon_P1b = UUID()
	let mon_P2 = UUID()
	let mon_Recess = UUID()
	let mon_P3 = UUID()
	let mon_P4 = UUID()
	let mon_Lunch = UUID()
	let mon_P5 = UUID()
	let mon_GDG = UUID()

	// Variant: Tuesday (SSB)
	let tue_CheckIn = UUID()
	let tue_P1 = UUID()
	let tue_P2 = UUID()
	let tue_Recess = UUID()
	let tue_P3 = UUID()
	let tue_P4 = UUID()
	let tue_Lunch = UUID()
	let tue_P5 = UUID()
	let tue_SBU = UUID()

	// Variant: Wednesday (Full variation + MSB)
//	let wed_CheckIn = UUID()
	let wed_P1 = UUID()
	let wed_P2 = UUID()
	let wed_YA = UUID()
	let wed_Recess = UUID()
	let wed_P3 = UUID()
	let wed_P4 = UUID()
	let wed_Lunch = UUID()
	let wed_Sport = UUID()
	let wed_SBU = UUID()

	// Variant: Thu (JCB)
	let thu_CheckIn = UUID()
	let thu_P1 = UUID()
	let thu_P2 = UUID()
	let thu_Recess = UUID()
	let thu_P3 = UUID()
	let thu_P4 = UUID()
	let thu_Lunch = UUID()
	let thu_P5 = UUID()
	let thu_SBU = UUID()

	// Variant: Fri (University)
	let fri_CheckIn = UUID()
	let fri_P1 = UUID()
	let fri_P2 = UUID()
	let fri_Recess = UUID()
	let fri_P3 = UUID()
	let fri_P4 = UUID()
	let fri_Lunch = UUID()
	let fri_P5 = UUID()
	let fri_travel = UUID()
	let fri_uni = UUID()

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
				   mon_CheckIn: Times.Period ("Check In",startTime: 0900,	duration: 10),
				   mon_P1a: Times.Period ("1",		startTime: 0910,	duration: 35),
				   mon_ML: Times.Period ("ML",		startTime: 945,		duration: 30),
				   mon_P2: Times.Period ("2",		startTime: 1015,	duration: 55),
				   mon_Recess: Times.Period ("Recess",startTime: 1110,	duration: 20),
				   mon_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
				   mon_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
				   mon_Lunch: Times.Period ("Lunch",startTime: 1330,	duration: 40),
				   mon_P5: Times.Period ("5",		startTime: 1410,	duration: 60),
				   mon_GDG: Times.Period("GDGs", startTime: 1510,		duration: 145)
			   ]),
			   UUID():	Times.Variant("tue", 		variant: [
				   tue_CheckIn: Times.Period ("Check In",startTime: 0900,	duration: 10),
				   tue_P1: Times.Period ("1",		startTime: 0910,	duration: 60),
				   tue_P2: Times.Period ("2",		startTime: 1010,	duration: 60),
				   tue_Recess: Times.Period ("Recess",startTime: 1110,	duration: 20),
				   tue_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
				   tue_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
				   tue_Lunch: Times.Period ("Lunch",startTime: 1330,	duration: 40),
				   tue_P5: Times.Period ("5",		startTime: 1410,	duration: 60),
				   tue_SBU: Times.Period ("SBU",	startTime: 1510,	duration:110)
			   ]),
			   UUID():	Times.Variant("wed",		variant: [
				   wed_P1: Times.Period ("1",		startTime: 0900,	duration: 60),
				   wed_P2: Times.Period ("2",		startTime: 1000,	duration: 50),
				   wed_YA: Times.Period("YA",		startTime: 1050,	duration: 10),// fix below
				   wed_Recess: Times.Period ("Recess",startTime: 1100,	duration: 20),
				   wed_P3: Times.Period ("3",		startTime: 1120,	duration: 50),
				   wed_P4: Times.Period ("4",		startTime: 1210,	duration: 50),
				   wed_Lunch: Times.Period ("Lunch",startTime: 1300,	duration: 30),
				   wed_Sport: Times.Period ("Sport",		startTime: 1330,	duration: 50+50),
				   wed_SBU: Times.Period ("SBU",	startTime: 1510,	duration: 140)
			   ]),
			   UUID():	Times.Variant("thu",		variant: [
				   thu_CheckIn: Times.Period ("Check In",startTime: 0900,	duration: 10),
				   thu_P1: Times.Period ("1",		startTime: 0910,	duration: 60),
				   thu_P2: Times.Period ("2",		startTime: 1010,	duration: 60),
				   thu_Recess: Times.Period ("Recess",startTime: 1110,	duration: 20),
				   thu_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
				   thu_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
				   thu_Lunch: Times.Period ("Lunch",startTime: 1330,	duration: 40),
				   thu_P5: Times.Period ("5",		startTime: 1410,	duration: 60),
				   thu_SBU: Times.Period ("SBU",	startTime: 1510,	duration: 80)
			   ]),
			   UUID(): Times.Variant("fri",		variant: [
					fri_CheckIn: Times.Period ("Check In",	startTime: 0900,	duration: 10),
					fri_P1: Times.Period ("1",		startTime: 0910,	duration: 60),
					fri_P2: Times.Period ("2",		startTime: 1010,	duration: 60),
					fri_Recess: Times.Period ("Recess",	startTime: 1110,	duration: 20),
					fri_P3: Times.Period ("3",		startTime: 1130,	duration: 60),
					fri_P4: Times.Period ("4",		startTime: 1230,	duration: 60),
					fri_Lunch: Times.Period ("Lunch",	startTime: 1330,	duration: 40),
					fri_P5: Times.Period ("5",		startTime: 1410,	duration: 10),
					fri_travel: Times.Period ("",			startTime: 1420,	duration: 40),//travel
					fri_uni: Times.Period ("",			startTime: 1500,	duration: 120),//uni
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
					mon_CheckIn: Contents(courseID: checkInID,	roomIndex: 0),
					mon_P1a: Contents(courseID: multimediaID,	roomIndex: 0),
					mon_ML: Contents(courseID: musicLessonID,	roomIndex: 0),
					mon_P2: Contents(courseID: scienceID,		roomIndex: 0),
					mon_Recess: Contents(courseID: recessID,	roomIndex: 0),
					mon_P3: Contents(courseID: englishID,		roomIndex: 0),
					mon_P4: Contents(courseID: pdhpeID,		roomIndex: 0),
					mon_Lunch: Contents(courseID: jrStageID,	roomIndex: 0),
					mon_P5: Contents(courseID: iStemID,		roomIndex: 0),
					mon_GDG: Contents(courseID: gdgID, 		roomIndex: 0)
					//UUID(): Contents(course: 21, variant: 0)
				],
				tuesday: [
					tue_CheckIn: Contents(courseID: checkInID,	roomIndex: 0),
					tue_P1: Contents(courseID: scienceID,		roomIndex: 0),
					tue_P2: Contents(courseID: hsieID,			roomIndex: 0),
					tue_Recess: Contents(courseID: recessID,	roomIndex: 0),
					tue_P3: Contents(courseID: englishID,		roomIndex: 0),
					tue_P4: Contents(courseID: mathsID,		roomIndex: 0),
					tue_Lunch: Contents(courseID: lunchID,		roomIndex: 0),
					tue_P5: Contents(courseID: multimediaID,	roomIndex: 0),
					tue_SBU: Contents(courseID: stageBandID,	roomIndex: 0),
					//UUID(): Contents(course: 21, variant: 0)
				],
				wednesday: [
					//wed_CheckIn: Contents(courseID: iStemID, roomIndex: 0),
					wed_P1: Contents(courseID: iStemID, roomIndex: 0),
					wed_P2: Contents(courseID: mathsID, roomIndex: 0),
					wed_YA: Contents(courseID: yearAssemblyID, roomIndex: 0),
					wed_Recess: Contents(courseID: recessID, roomIndex: 0),
					wed_P3: Contents(courseID: crixID, roomIndex: 0),
					wed_P4: Contents(courseID: hsieID, roomIndex: 0),
					wed_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					wed_Sport: Contents(courseID: theatreCrewID, roomIndex: -1),
					wed_SBU: Contents(courseID: marchingBandID, roomIndex: -1),
					//UUID(): Contents(course: 21, variant: 0)
				],//.compactMapValues { $0 },
				thursday: [
					thu_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					thu_P1: Contents(courseID: englishID, roomIndex: 1),
					thu_P2: Contents(courseID: pdhpeID, roomIndex: 1),
					thu_Recess: Contents(courseID: recessID, roomIndex: 0),
					thu_P3: Contents(courseID: hsieID, roomIndex: 0),
					thu_P4: Contents(courseID: scienceID, roomIndex: 0),
					thu_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					thu_P5: Contents(courseID: crixID, roomIndex: 0),
					thu_SBU: Contents(courseID: juniorCBID, roomIndex: -1)
				],
				friday: [
					fri_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					fri_P1: Contents(courseID: hsieID, roomIndex: 0),
					fri_P2: Contents(courseID: scienceID, roomIndex: 0),
					fri_Recess: Contents(courseID: recessID, roomIndex: 0),
					fri_P3: Contents(courseID: mathsID, roomIndex: 0),
					fri_P4: Contents(courseID: crixID, roomIndex: 0),
					fri_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					fri_P5: Contents(courseID: englishID, roomIndex: 0),
					fri_travel: Contents(courseID: travelID, roomIndex: -1),
					fri_uni: Contents(courseID: uniID, roomIndex: 0)
					//UUID(): Contents(course: 21, variant: 0)
				]
			),

			// Week B (key 2): Mon..Fri (from previous 6..10)
			Timetable.TimetabledWeek(
				monday: [
					mon_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					mon_P1a: Contents(courseID: multimediaID, 	roomIndex: 0),
					mon_ML: Contents(courseID: musicLessonID, 	roomIndex: 0),
					mon_P2: Contents(courseID: mathsID, 		roomIndex: 1),
					mon_Recess: Contents(courseID: recessID, 	roomIndex: 0),
					mon_P3: Contents(courseID: iStemID, 		roomIndex: 0),
					mon_P4: Contents(courseID: crixID, 		roomIndex: 0),
					mon_Lunch: Contents(courseID: jrStageID, 	roomIndex: 0),
					mon_P5: Contents(courseID: pdhpeID, 		roomIndex: 1),
					mon_GDG: Contents(courseID: gdgID, 		roomIndex: 0)
					//UUID(): Contents(course: 21, variant: 0)x
				],
				tuesday: [
					tue_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					tue_P1: Contents(courseID: scienceID, roomIndex: 0),
					tue_P2: Contents(courseID: hsieID, roomIndex: 0),
					tue_Recess: Contents(courseID: recessID, roomIndex: 0),
					tue_P3: Contents(courseID: mathsID, roomIndex: 0),
					tue_P4: Contents(courseID: multimediaID, roomIndex: 0),
					tue_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					tue_P5: Contents(courseID: englishID, roomIndex: 0),
					tue_SBU: Contents(courseID: stageBandID, roomIndex: 0),
					//UUID(): Contents(course: 21, variant: 0)
				],
				wednesday: [
					wed_P1: Contents(courseID: hsieID, roomIndex: 0),
					wed_P2: Contents(courseID: mathsID, roomIndex: 0),
					wed_YA: Contents(courseID: yearAssemblyID, roomIndex: 0),
					wed_Recess: Contents(courseID: recessID, roomIndex: 0),
					wed_P3: Contents(courseID: visualArtsID, roomIndex: 0),
					wed_P4: Contents(courseID: scienceID, roomIndex: 0),
					wed_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					wed_Sport: Contents(courseID: seniorCBID, roomIndex: 0),
					wed_SBU: Contents(courseID: marchingBandID, roomIndex: 0),
					//UUID(): Contents(course: 21, variant: 0)
				],
				thursday: [
					thu_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					thu_P1: Contents(courseID: hsieID, roomIndex: 0),
					thu_P2: Contents(courseID: pdhpeID, roomIndex: 0),
					thu_Recess: Contents(courseID: recessID, roomIndex: 0),
					thu_P3: Contents(courseID: englishID, roomIndex: 0),
					thu_P4: Contents(courseID: scienceID, roomIndex: 0),
					thu_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					thu_P5: Contents(courseID: crixID, roomIndex: 0),
					thu_SBU: Contents(courseID: juniorCBID, roomIndex: -1),
					//UUID(): Contents(course: 21, variant: 0)
				],
				friday: [
					fri_CheckIn: Contents(courseID: checkInID, roomIndex: 0),
					fri_P1: Contents(courseID: crixID, roomIndex: 0),
					fri_P2: Contents(courseID: englishID, roomIndex: 0),
					fri_Recess: Contents(courseID: recessID, roomIndex: 0),
					fri_P3: Contents(courseID: iStemID, roomIndex: 0),
					fri_P4: Contents(courseID: mathsID, roomIndex: 0),
					fri_Lunch: Contents(courseID: lunchID, roomIndex: 0),
					fri_P5: Contents(courseID: multimediaID, roomIndex: 0),
					fri_travel: Contents(courseID: travelID, roomIndex: -1),
					fri_uni: Contents(courseID: uniID, roomIndex: 0)
					//UUID(): Contents(course: 21, variant: 0)
				]
			)
		]
	)
}()

