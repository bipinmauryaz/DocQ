/*============================================================================
 PROJECT: Docquity
 FILE:    Server.h
 AUTHOR:  Copyright (c) 2015 Docquity Services Pvt. Ltd. All rights reserved.
 DATE:    Created by Docquity Docquity Services Pvt. Ltd. on 04/08/15.
 =============================================================================*/


/*============================================================================
 IMPORT FRAMEWORK
 =============================================================================*/
#import <Foundation/Foundation.h>
#import "DefineAndConstants.h"
@class Server;

/*============================================================================
 PROTOCOL
 =============================================================================*/
@protocol ServerRequestFinishedProtocol <NSObject>
- (void) requestFinished:(NSDictionary * )responseData;
- (void) requestError;

@end

/*============================================================================
 Interface:   Server
 =============================================================================*/
@interface Server : NSObject
{
    NSMutableArray		    *daataArray;
    ServerRequestType1		currentRequestType;
    NSMutableData           *receivedData;
}

@property (nonatomic, retain) id <ServerRequestFinishedProtocol> delegate;
- (void) sendRequestToServer:(NSDictionary*)userInfo withDataDic:(NSDictionary*)datadic;
- (NSMutableArray*)getResults;

@end
