//
//  Singleton.h
//
//  Copyright (c) 2012 Jason Fieldman. All rights reserved.
//

#ifndef ___Singleton_h___
#define ___Singleton_h___

#define SINGLETON_INTR( _name ) + ( _name *) sharedInstance;

#define SINGLETON_IMPL( _name ) \
+ ( _name *) sharedInstance { \
    __strong static _name * _sharedInstance = nil; \
    static dispatch_once_t oncePredicate = 0; \
    dispatch_once( &oncePredicate, ^{_sharedInstance = [[ _name alloc] init];} ); \
    return _sharedInstance; \
}



#endif
