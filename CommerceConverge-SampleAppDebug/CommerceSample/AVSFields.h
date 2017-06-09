//
//  AVSFields.h
//  Commerce Sample
//
//  Created by Vora, Chintan R on 5/15/15.
//  Copyright (c) 2015 Elavon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AVSFields : NSObject

-(BOOL) isCityRequired;
-(BOOL) isStateRequired;
-(BOOL) isFirstNameRequired;
-(BOOL) isLastNameRequired;
-(BOOL) isEmailRequired;
-(BOOL) isCountryRequired;

-(void) resetAVSFieldValues;

-(void) setCitySwitchValue:(BOOL)value;
-(void) setStateSwitchValue:(BOOL)value;
-(void) setFirstNameSwitchValue:(BOOL)value;
-(void) setLastNameSwitchValue:(BOOL)value;
-(void) setEmailSwitchValue:(BOOL)value;
-(void) setCountrySwitchValue:(BOOL) value;

-(BOOL) getCitySwitchValue;
-(BOOL) getStateSwitchValue;
-(BOOL) getFirstNameSwitchValue;
-(BOOL) getLastNameSwitchValue;
-(BOOL) getEmailSwitchValue;
-(BOOL) getCountrySwitchValue;

-(void) setCityRequirementComplete;
-(void) setStateRequirementComplete;
-(void) setFirstNameRequirementComplete;
-(void) setLastNameRequirementComplete;
-(void) setEmailRequirementComplete;
-(void) setCountryRequirementComplete;

@end
