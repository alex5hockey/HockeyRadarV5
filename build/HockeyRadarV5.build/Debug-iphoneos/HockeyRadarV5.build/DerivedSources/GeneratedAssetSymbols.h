#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "backgrounds" asset catalog image resource.
static NSString * const ACImageNameBackgrounds AC_SWIFT_PRIVATE = @"backgrounds";

/// The "calibrationNet" asset catalog image resource.
static NSString * const ACImageNameCalibrationNet AC_SWIFT_PRIVATE = @"calibrationNet";

/// The "dinkydiagram" asset catalog image resource.
static NSString * const ACImageNameDinkydiagram AC_SWIFT_PRIVATE = @"dinkydiagram";

/// The "dot" asset catalog image resource.
static NSString * const ACImageNameDot AC_SWIFT_PRIVATE = @"dot";

/// The "net2" asset catalog image resource.
static NSString * const ACImageNameNet2 AC_SWIFT_PRIVATE = @"net2";

/// The "nets" asset catalog image resource.
static NSString * const ACImageNameNets AC_SWIFT_PRIVATE = @"nets";

/// The "puck" asset catalog image resource.
static NSString * const ACImageNamePuck AC_SWIFT_PRIVATE = @"puck";

/// The "radar" asset catalog image resource.
static NSString * const ACImageNameRadar AC_SWIFT_PRIVATE = @"radar";

/// The "shootingandaccuracy" asset catalog image resource.
static NSString * const ACImageNameShootingandaccuracy AC_SWIFT_PRIVATE = @"shootingandaccuracy";

/// The "sticks" asset catalog image resource.
static NSString * const ACImageNameSticks AC_SWIFT_PRIVATE = @"sticks";

#undef AC_SWIFT_PRIVATE
