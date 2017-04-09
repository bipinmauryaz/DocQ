#import <Foundation/Foundation.h>
#import "SBJsonBase.h"

/**
  @brief Options for the parser class.
 
 This exists so the SBJSON facade can implement the options in the parser without having to re-declare them.
 */
@protocol SBJsonParser

- (id)objectWithString:(NSString *)repr;

@end


@interface SBJsonParser : SBJsonBase <SBJsonParser> {
    
@private
    const char *c;
}

@end

// don't use - exists for backwards compatibility with 2.1.x only. Will be removed in 2.3.
@interface SBJsonParser (Private)
- (id)fragmentWithString:(id)repr;
@end


