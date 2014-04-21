//
//  EXDebug.h
//

#include "EXRemoteLog.h"


typedef enum EXDebugComponent {
	
	/* General protocol */
	EXDBGCOMP_MODEL                      = 0x00000001,
	EXDBGCOMP_RENDER                     = 0x00000002,
	EXDBGCOMP_PURCHASE                   = 0x00000004,
	EXDBGCOMP_HELPER                     = 0x00000008,
	EXDBGCOMP_OPENGL                     = 0x00000010,
	EXDBGCOMP_COMM                       = 0x00000020,
	
	/* Performance */
	EXDBGCOMP_PERFORM                    = 0x40000000,
	
	/* Any */
	EXDBGCOMP_ANY                        = 0x7FFFFFFF,
	
} EXDebugComponent_t;

#define EXDBGCOMP_STR_MODEL              "MODEL"
#define EXDBGCOMP_STR_RENDER             "RENDER"
#define EXDBGCOMP_STR_PURCHASE           "PURCHASE"
#define EXDBGCOMP_STR_HELPER             "HELPER"
#define EXDBGCOMP_STR_OPENGL             "OPENGL"
#define EXDBGCOMP_STR_COMM               "COMM"

#define EXDBGCOMP_STR_PERFORM            "PERFORM"
#define EXDBGCOMP_STR_ANY                "ANY"

typedef enum EXDebugLevel {
	
	EXDBGLVL_EMERG    = 0,
	EXDBGLVL_ALERT    = 1,
	EXDBGLVL_CRIT     = 2,
	EXDBGLVL_ERR      = 3,
	EXDBGLVL_WARN     = 4,
	EXDBGLVL_NOTICE   = 5,
	EXDBGLVL_INFO     = 6,
	EXDBGLVL_DBG      = 7,
	
} EXDebugLevel_t;

#define EXDBGLVL_STR_EMERG               "EMERG"
#define EXDBGLVL_STR_ALERT               "ALERT"
#define EXDBGLVL_STR_CRIT                "CRIT"
#define EXDBGLVL_STR_ERR                 "ERR"
#define EXDBGLVL_STR_WARN                "WARN"
#define EXDBGLVL_STR_NOTICE              "NOTICE"
#define EXDBGLVL_STR_INFO                "INFO"
#define EXDBGLVL_STR_DBG                 "DEBUG"


/* The global debug flags */
#ifndef EXDEBUGCOMPONENTS
#define EXDEBUGCOMPONENTS EXDBGCOMP_ANY
#endif 


#ifndef EXDEBUGLEVEL
#define EXDEBUGLEVEL EXDBGLVL_DBG
#endif


#ifndef EXDEBUGENABLED
#define EXLog( _component, _level, _fmt, _fmtargs... )
#define EXDebuggingComponent( _component )             NO
#define EXDebuggingLevel( _level )                     NO
#define EXDebugging( _component , _level )             NO
#define Timing_MarkStartTime() 
#define Timing_GetElapsedTime() (0.0)
#else

#define EXLog( _component, _level, _fmt, _fmtargs... )  do { \
if (!(EXDEBUGCOMPONENTS | EXDBGCOMP_##_component)) break;             \
if (EXDBGLVL_##_level > EXDEBUGLEVEL) break;                         \
NSString *parsedString = [NSString stringWithFormat: _fmt, ##_fmtargs ];     \
NSString *fullLog = [NSString stringWithFormat:@"[ %9s : %6s : %3.3lf ] %@", EXDBGCOMP_STR_##_component , EXDBGLVL_STR_##_level , Timing_GetElapsedTime() ,  parsedString];  \
/*NSLog(@"%@", fullLog); */                                                      \
@autoreleasepool { \
const char *foo = [fullLog UTF8String]; \
printf("%s\n", foo); \
}\
[[EXRemoteLog sharedInstance] logString:fullLog];                            \
} while (0)

#define EXDebuggingComponent  ( _c ) ( EXDEBUGCOMPONENTS | EXDBGCOMP_##_c )
#define EXDebuggingLevel      ( _l ) ( EXDBGLVL_##_l <= EXDEBUGLEVEL )
#define EXDebugging  ( _comp, _lvl ) ( EXDebuggingComponent( _comp ) && EXDebuggingLevel ( _lvl ) )

void Timing_MarkStartTime(void);
double Timing_GetElapsedTime(void);

#endif



#define WARN_NIL( _class , _var ) { if ( _var == nil ) { EXLog( _class, WARN, @"%s is nil", #_var ); } }

void preventBackupOfFile(NSString* filepath);




