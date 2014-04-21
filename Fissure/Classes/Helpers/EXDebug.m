//
//  EXDebug.m
//

#import "EXDebug.h"

#ifndef EXDEBUGCOMPONENTS
#define EXDEBUGCOMPONENTS EXDBGCOMP_ANY
#endif 


#ifndef EXDEBUGLEVEL
#define EXDEBUGLEVEL EXDBGLVL_DBG
#endif


#ifdef EXDEBUGENABLED

static double s_start_time = 0;

void Timing_MarkStartTime() {	
	s_start_time = CFAbsoluteTimeGetCurrent();
}

double Timing_GetElapsedTime() {	
	return CFAbsoluteTimeGetCurrent() - s_start_time;
}


#endif


void preventBackupOfFile(NSString* filepath) {
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) return;
	
	NSURL *URL = [NSURL fileURLWithPath:filepath];
	
	NSError *error = nil;
	BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
								  forKey: NSURLIsExcludedFromBackupKey error: &error];
	if(!success){
		EXLog(ANY, ERR, @"Error excluding %@ from backup %@", [URL lastPathComponent], error);
	}
}

