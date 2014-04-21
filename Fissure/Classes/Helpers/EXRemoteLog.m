//
//  EXRemoteLog.m
//

#import "EXRemoteLog.h"
//#import "EXUtils.h"

#include <sys/types.h>
#include <netdb.h>
#include <unistd.h>

#ifndef REMOTELOGHOST
#define REMOTELOGHOST @"localhost"
#endif

#ifndef REMOTELOGPORT
#define REMOTELOGPORT 23456
#endif


BOOL init_sockaddr(struct sockaddr_in *name, const char *hostname, unsigned short int port);
BOOL init_sockaddr(struct sockaddr_in *name, const char *hostname, unsigned short int port) {
	struct hostent *hostinfo;
	
	name->sin_family = AF_INET;
	name->sin_port = htons (port);
	hostinfo = gethostbyname (hostname);
	if (hostinfo == NULL) {
		return NO;
    }
	name->sin_addr = *(struct in_addr *) hostinfo->h_addr;
	return YES;
}


@implementation EXRemoteLog
@synthesize connectionFailed;

+ (EXRemoteLog*) sharedInstance {
	static EXRemoteLog *singleton_instance = nil;
	if (!singleton_instance) {
		singleton_instance = [[EXRemoteLog alloc] init];
		[singleton_instance performSelectorInBackground:@selector(establishConnection) withObject:nil];
	}
	return singleton_instance;
}

- (id) init {
	if (self = [super init]) {
		logBuffer = [[NSMutableArray alloc] init];
		
		/* Create socket */
		sock = socket (PF_INET, SOCK_STREAM, 0);
		if (sock < 0) {
			connectionFailed = YES;
			return self;
		}
		
	}
	return self;
}


- (BOOL) writeString:(NSString*)string {
	if (connectionFailed) return NO;
	
	@autoreleasepool {
		
		/* OtherwEXe transmit */
		const char *utf8string = [string UTF8String];
		long len = [string length];
		
		@synchronized (self) {
			long charsSent;
			long lenLeft = len;
			while ((charsSent = write(sock, utf8string, lenLeft))) {
				if (charsSent < 0) {
					connectionFailed = YES;
					return NO;
				}
				
				lenLeft -= charsSent;
				utf8string += charsSent;
				
				if (lenLeft < 0) break;
			}
			
			if (lenLeft > 0) {
				connectionFailed = YES;
				return NO;
			}
		}
		
	}
	return YES;
}


- (BOOL) logString:(NSString *)stringToSend {
	if (connectionFailed) return NO;
	
	NSString *string = [NSString stringWithFormat:@"%@\n", stringToSend];
	
	/* Put it in the buffer if we're not connected yet */
	@synchronized (self) {
		if (!connectionEstablished) {		
			[logBuffer addObject:string];
			return YES;
		}
	}
	
	/* Otherwise transmit */
	[self performSelectorInBackground:@selector(writeString:) withObject:string];
	
	return YES;
}


- (void) establishConnection {
	if (connectionFailed) return;
	
	@autoreleasepool {
		
		/* init sockaddr */
		BOOL initSuccess = init_sockaddr (&servername, [REMOTELOGHOST UTF8String], REMOTELOGPORT);
		
		if (!initSuccess || (0 > connect (sock, (struct sockaddr *) &servername, sizeof (servername)))) {
			connectionFailed = YES;
			return;
		}
		
		connectionEstablished = YES;
		
		/* Header */
		[self writeString:[NSString stringWithFormat:@"n:%@;i:%@;v:%@;u\n",
						   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],
						   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"],
						   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
		
		while ([logBuffer count]) {
			NSString *nextToSend;
			@synchronized (self) {
				nextToSend = [logBuffer objectAtIndex:0];
				[self writeString:nextToSend];
				[logBuffer removeObjectAtIndex:0];
			}
		}
		
		logBuffer = nil;
	}
}


@end
