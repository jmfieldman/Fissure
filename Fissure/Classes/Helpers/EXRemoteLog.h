//
//  EXRemoteLog.h
//

#import <Foundation/Foundation.h>

#include <sys/socket.h>
#include <netinet/in.h>

@interface EXRemoteLog : NSObject {
	BOOL connectionEstablished;
	BOOL connectionFailed;
	
	/* Socket stuff */
	int sock;
	struct sockaddr_in servername;
	
	/* Log buffer */
	__strong NSMutableArray *logBuffer;
}

@property (nonatomic, readonly) BOOL connectionFailed;

+ (EXRemoteLog*) sharedInstance;

- (BOOL) logString:(NSString *)stringToSend;

@end
