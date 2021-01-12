#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ALiAssetReader.h"
#import "ALiAssetWriter.h"
#import "ALiVideoRecorder.h"

FOUNDATION_EXPORT double ALiVideoRecorderVersionNumber;
FOUNDATION_EXPORT const unsigned char ALiVideoRecorderVersionString[];

