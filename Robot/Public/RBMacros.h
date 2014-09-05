#import <Foundation/Foundation.h>

#define RB_EXPORT FOUNDATION_EXTERN
#define RB_EXPORT_OVERLOADED RB_EXPORT __attribute__((overloadable))
#define RB_INLINE FOUNDATION_STATIC_INLINE
#define RB_INLINE_OVERLOADED RB_INLINE __attribute__((overloadable))

// used simply the mark Robot APIs that trigger private iOS APIs
// You can predefine the macro if you want to audit private API usage
#ifndef RB_USES_PRIVATE_APIS
#define RB_USES_PRIVATE_APIS
#endif
