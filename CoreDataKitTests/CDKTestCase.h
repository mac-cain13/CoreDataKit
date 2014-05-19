//
//  CDKTestCase.h
//  CoreDataKit
//
//  Created by Mathijs Kadijk on 19-05-14.
//  Copyright (c) 2014 Mathijs Kadijk. All rights reserved.
//

#import <Foundation/Foundation.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import <XCTestAsync/XCTestAsync.h>

@class CoreDataKit;

@interface CDKTestCase : XCTestCase

@property (nonatomic, strong) CoreDataKit *coreDataKit;

@end
