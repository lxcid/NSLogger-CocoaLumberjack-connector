//
//  DDNSLoggerLogger.m
//  Created by Peter Steinberger on 26.10.10.
//

#import "DDNSLoggerLogger.h"

// NSLogger is needed: http://github.com/fpillet/NSLogger
#import "LoggerClient.h"

@interface DDNSLoggerLogger ()

@property (nonatomic, assign) BOOL running;

@end

@implementation DDNSLoggerLogger

static DDNSLoggerLogger *sharedInstance;

+ (DDNSLoggerLogger *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DDNSLoggerLogger alloc] init];
    });
    return sharedInstance;
}

- (void)start {
    if (self.running) {
        return;
    }
    LoggerStart(NULL);
    self.running = YES;
}

- (void)stop {
    if (!self.running) {
        return;
    }
    LoggerStop(NULL);
    self.running = NO;
}

- (void)setupWithBonjourServiceName:(NSString *)serviceName {
    BOOL running = self.running;
    [self stop];
    LoggerSetupBonjour(NULL, NULL, (__bridge CFStringRef)serviceName);
    if (running) {
        [self start];
    }
}

- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *logMsg = logMessage->logMsg;

    if (formatter) {
        // formatting is supported but not encouraged!
        logMsg = [formatter formatLogMessage:logMessage];
    }

    if (logMsg) {
        int nsloggerLogLevel;
        switch (logMessage->logFlag) {
                // NSLogger log levels start a 0, the bigger the number,
                // the more specific / detailed the trace is meant to be
            case LOG_FLAG_ERROR: nsloggerLogLevel = 0; break;
            case LOG_FLAG_WARN: nsloggerLogLevel  = 1; break;
            case LOG_FLAG_INFO: nsloggerLogLevel  = 2; break;
            default: nsloggerLogLevel             = 3; break;
        }

        LogMessageF(logMessage->file, logMessage->lineNumber, logMessage->function, [logMessage fileName],
                    nsloggerLogLevel, @"%@", logMsg);
    }
}

- (NSString *)loggerName {
    return @"cocoa.lumberjack.NSLogger";
}

@end
