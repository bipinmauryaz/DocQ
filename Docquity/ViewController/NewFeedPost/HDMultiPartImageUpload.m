//
//  HDMultiPartImageUpload.m
//  HDMultiPartImageUpload
//
//  Created by HarshDuggal on 13/08/14.
//  Copyright (c) 2014 Infoedge. All rights reserved.
//

#import "HDMultiPartImageUpload.h"
#import "AFNetworking.h"
#import "AFURLSessionManager.h"
#include <ifaddrs.h>
#include <net/if.h>

@interface HDMultiPartImageUpload ()
{
    int totalChunksTobeUploaded;
    int chunksUploadedSuccessfully;
    BOOL successfulUpload;
    BOOL APIExecuted;
}
-(void)uploadImageChunkToServerFullImageData:(NSData*)imageData withParam:(NSMutableDictionary*)param withOffset:(NSUInteger)offset;

@end
@implementation HDMultiPartImageUpload
@synthesize successfulUpload;

- (NSData*)getPostDataFromDictionary:(NSDictionary*)dict
{
    id boundary = BOUNDARY;
    NSArray* keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
    // add params (all params are strings)
    [result appendData:[[NSString stringWithFormat:@"\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    for (int i = 0; i < [keys count]; i++)
    {
        id tmpKey = [keys objectAtIndex:i];
        id tmpValue = [dict valueForKey: tmpKey];
        
        [result appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n \n%@", tmpKey,tmpValue] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Append boundary after every key-value
        [result appendData:[[NSString stringWithFormat:@"\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return result;
}

-(void)startUploadImagesToServer
{
    NSUInteger totalFileSize = [_videoData length];
    //    int totalChunks = ceil(totalFileSize/oneChunkSize);
    int totalChunks = round((totalFileSize/self.oneChunkSize)+0.5);//round-off to nearest  largest valua 1.01 is considered as 2
    
    // Start multipart upload chunk sequentially-
    NSUInteger offset = 0;
    totalChunksTobeUploaded = totalChunks;
    chunksUploadedSuccessfully = 1;
    [self uploadImageChunkToServerFullImageData:_videoData withParam:self.postParametersDict withOffset:offset];
  }

-(void)uploadImageChunkToServerFullImageData:(NSData*)imageData withParam:(NSMutableDictionary*)param withOffset:(NSUInteger)offset
{
    APIExecuted = NO;
    //NSData* myBlob = imageData;
    NSUInteger totalBlobLength = [imageData length];
    NSUInteger chunkSize = self.oneChunkSize;
    NSUInteger thisChunkSize = totalBlobLength - offset > chunkSize ? chunkSize : totalBlobLength - offset;
    NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[imageData bytes] + offset
                                         length:thisChunkSize
                                   freeWhenDone:NO];
    
    //  NSLog(@"Parameter = %@",param);
    //  NSLog(@"thisChunkSize = %lu",(unsigned long)thisChunkSize);
    
    NSMutableData* bufferToSend;
    bufferToSend = [[NSMutableData alloc] initWithCapacity:0];
    //http://stackoverflow.com/questions/13288969/uploading-a-large-video-from-iphone-to-web-server
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:self.uploadURLString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:chunk name:@"file" fileName:[NSString stringWithFormat:@"%@.mp4",[param valueForKey:@"uniqueFilename"]] mimeType:@"video/mp4"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        // This is not called back on the main queue.
        // You are responsible for dispatching to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
           // [progressView setProgress:uploadProgress.fractionCompleted];
        });
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            // NSLog(@"Enter in error");
            //NSLog(@"Error: %@", error);
            // Retry resending same chuck
            [self uploadImageChunkToServerFullImageData:imageData withParam:param withOffset:offset];
            return;
        } else {
            // NSLog(@"Enter in responseObject");
            // NSLog(@"%@ %@", response, responseObject);
            NSMutableDictionary *post =[responseObject valueForKey:@"posts"];
            successfulUpload = false;
            if([[post valueForKey:@"status"]isKindOfClass:[NSNumber class]]){
                if ([post valueForKey:@"status"]) {
                    successfulUpload = YES;
                    // NSLog(@"Enter in successfulUpload  and chunksUploadedSuccessfully = %d",chunksUploadedSuccessfully);
                    chunksUploadedSuccessfully += 1;
                    
                    //#warning update your post param dict if needed, accoording to server implementation
                    [param setObject:[NSString stringWithFormat:@"%d",chunksUploadedSuccessfully] forKey:@"num"];
                    // above line is example should altered according to the server key in needed
                    //#warning update your post param dict if needed, accoording to server implementation
                    
                    if ([[param valueForKey:@"num_chunks"]isEqualToString:[NSString stringWithFormat:@"%d",chunksUploadedSuccessfully]]) {
                        [param setObject:@"1"
                                  forKey:@"status"];
                    }
                    
                    NSUInteger thisChunkSize = totalBlobLength - offset > chunkSize ? chunkSize : totalBlobLength - offset;
                    NSUInteger newOffset= offset + thisChunkSize;
                    
                    // stop no more data to upload
                    if(offset >= totalBlobLength){
                        // NSLog(@"offset >= totalBlobLength");
                        return;
                    }
                    if (chunksUploadedSuccessfully > totalChunksTobeUploaded) {
                        // NSLog(@"chunk > chunks-1");
                        [self.delegate videoRequestFinished:post];
                        return;
                    }
                    // send next Chunck To server
                    [self uploadImageChunkToServerFullImageData:imageData withParam:param withOffset:newOffset];
                    
                }else{
                    successfulUpload = FALSE;
                    // Retry resending same chuck
                    // NSLog(@"Enter in successful Not Upload");
                    [self uploadImageChunkToServerFullImageData:imageData withParam:param withOffset:offset];
                    return;
                }
            }
        }
    }];
    [uploadTask resume];
}

- (NSData *)generatePostDataForData:(NSData *)uploadData
{
    // Generate the post header:
    NSString *post = [NSString stringWithCString:"--AaB03x\r\nContent-Disposition: form-data; name=\"upload[file]\"; filename=\"somefile\"\r\nContent-Type: application/octet-stream\r\nContent-Transfer-Encoding: binary\r\n\r\n" encoding:NSASCIIStringEncoding];
    
    // Get the post header int ASCII format:
    NSData *postHeaderData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Generate the mutable data variable:
    NSMutableData *postData = [[NSMutableData alloc] initWithLength:[postHeaderData length] ];
    [postData setData:postHeaderData];
    
    // Add the image:
    [postData appendData: uploadData];
    
    // Add the closing boundry:
    [postData appendData: [@"\r\n--AaB03x--" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    // Return the post data:
    return postData;
}

-(double)getRouterLinkSpeed
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    double linkSpeed = 0;
    NSString *name = [[NSString alloc] init];
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    linkSpeed = networkStatisc->ifi_baudrate;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
     return linkSpeed;
}

-(void)startUploadFilesToServer
{
    NSUInteger totalFileSize = [_fileData length];
    //    int totalChunks = ceil(totalFileSize/oneChunkSize);
    int totalChunks = round((totalFileSize/self.oneChunkSize)+0.5);//round-off to nearest  largest valua 1.01 is considered as 2
    // Start multipart upload chunk sequentially-
    NSUInteger offset = 0;
    totalChunksTobeUploaded = totalChunks;
    chunksUploadedSuccessfully = 1;
 //   [self uploadImageChunkToServerFullImageData:_videoData withParam:self.postParametersDict withOffset:offset];
    [self uploadFileChunkToServerFullFileData:_fileData withParam:self.postParametersDict withOffset:offset];
}

-(void)uploadFileChunkToServerFullFileData:(NSData*)FileData withParam:(NSMutableDictionary*)param withOffset:(NSUInteger)offset
{
    APIExecuted = NO;
    //NSData* myBlob = imageData;
    NSUInteger totalBlobLength = [FileData length];
    NSUInteger chunkSize = self.oneChunkSize;
    NSUInteger thisChunkSize = totalBlobLength - offset > chunkSize ? chunkSize : totalBlobLength - offset;
    NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[FileData bytes] + offset
                                         length:thisChunkSize
                                   freeWhenDone:NO];
    
   // NSLog(@"Parameter = %@",param);
   // NSLog(@"thisChunkSize = %lu",(unsigned long)thisChunkSize);
    
    NSMutableData* bufferToSend;
    bufferToSend = [[NSMutableData alloc] initWithCapacity:0];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:self.uploadURLString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:chunk name:@"file" fileName:[NSString stringWithFormat:@"%@.pdf",[param valueForKey:@"uniqueFilename"]] mimeType:@"application/pdf"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
   // NSProgress *progress = nil;
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        // This is not called back on the main queue.
        // You are responsible for dispatching to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            // [progressView setProgress:uploadProgress.fractionCompleted];
        });
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
           //  NSLog(@"Enter in error");
           // NSLog(@"Error: %@", error);
            // Retry resending same chuck
            [self uploadFileChunkToServerFullFileData:FileData withParam:param withOffset:offset];
            return;
        } else {
           //  NSLog(@"Enter in responseObject");
           //  NSLog(@"%@ %@", response, responseObject);
            NSMutableDictionary *post =[responseObject valueForKey:@"posts"];
            successfulUpload = false;
            if([[post valueForKey:@"status"]isKindOfClass:[NSNumber class]]){
                if ([post valueForKey:@"status"]) {
                    successfulUpload = YES;
                     //NSLog(@"Enter in successfulUpload  and chunksUploadedSuccessfully = %d",chunksUploadedSuccessfully);
                    chunksUploadedSuccessfully += 1;
                    
                      //#warning update your post param dict if needed, accoording to server implementation
                    [param setObject:[NSString stringWithFormat:@"%d",chunksUploadedSuccessfully] forKey:@"num"];
                    // above line is example should altered according to the server key in needed
                    //#warning update your post param dict if needed, accoording to server implementation
                    
                    if ([[param valueForKey:@"num_chunks"]isEqualToString:[NSString stringWithFormat:@"%d",chunksUploadedSuccessfully]]) {
                        [param setObject:@"1"
                                  forKey:@"status"];
                    }
                    NSUInteger thisChunkSize = totalBlobLength - offset > chunkSize ? chunkSize : totalBlobLength - offset;
                    NSUInteger newOffset= offset + thisChunkSize;
                    
                    // stop no more data to upload
                    if(offset >= totalBlobLength){
                        // NSLog(@"offset >= totalBlobLength");
                        return;
                    }
                    if (chunksUploadedSuccessfully > totalChunksTobeUploaded) {
                        // NSLog(@"chunk > chunks-1");
                        [self.delegate fileRequestFinished:post];
                        return;
                    }
                    // send next Chunck To server
                    [self uploadFileChunkToServerFullFileData:FileData withParam:param withOffset:newOffset];
                   }else{
                    successfulUpload = FALSE;
                    // Retry resending same chuck
                     // NSLog(@"Enter in successful Not Upload");
                    [self uploadFileChunkToServerFullFileData:_fileData withParam:param withOffset:offset];
                    return;
                }
            }
        }
    }];
    [uploadTask resume];
}
@end
