//
//  AVSFields.m
//  Commerce Sample
//
//  Created by Vora, Chintan R on 5/15/15.
//  Copyright (c) 2015 Elavon. All rights reserved.
//

#import "AVSFields.h"

@interface AVSFields() {
    BOOL cityRequired;
    BOOL stateRequired;
    BOOL firstNameRequired;
    BOOL lastNameRequired;
    BOOL emailRequired;
    BOOL countryRequied;
    BOOL cityComplete;
    BOOL stateComplete;
    BOOL firstNameComplete;
    BOOL lastNameComplete;
    BOOL emailComplete;
    BOOL countryComplete;
}

@end

@implementation AVSFields

-(BOOL)isCityRequired {
    return cityRequired && !cityComplete;
}
-(BOOL)isStateRequired {
    return stateRequired && !stateComplete;
}
-(BOOL)isFirstNameRequired {
    return firstNameRequired && !firstNameComplete;
}
-(BOOL)isLastNameRequired {
    return lastNameRequired && !lastNameComplete;
}
-(BOOL)isEmailRequired {
    return emailRequired && !emailComplete;
}
-(BOOL)isCountryRequired {
    return countryRequied && !countryComplete;
}

-(void)resetAVSFieldValues {
    cityComplete = NO;
    lastNameComplete = NO;
    firstNameComplete = NO;
    lastNameComplete = NO;
    stateComplete = NO;
    emailComplete = NO;
    countryComplete = NO;
}

-(void) setCitySwitchValue:(BOOL)value {
    cityRequired = value;
}

-(void) setStateSwitchValue:(BOOL)value {
    stateRequired = value;
}

-(void) setFirstNameSwitchValue:(BOOL)value {
    firstNameRequired = value;
}

-(void) setLastNameSwitchValue:(BOOL)value{
    lastNameRequired = value;
}

-(void) setEmailSwitchValue:(BOOL)value {
    emailRequired = value;
}

-(void) setCountrySwitchValue:(BOOL)value {
    countryRequied = value;
}

-(BOOL) getCitySwitchValue {
    return cityRequired;
}

-(BOOL) getStateSwitchValue {
    return stateRequired;
}

-(BOOL) getFirstNameSwitchValue {
    return firstNameRequired ;
}

-(BOOL) getLastNameSwitchValue {
    return lastNameRequired;
}

-(BOOL) getEmailSwitchValue {
    return emailRequired;
}

-(BOOL) getCountrySwitchValue {
    return countryRequied;
}

-(void) setCityRequirementComplete {
    cityComplete = YES;
}

-(void) setStateRequirementComplete {
    stateComplete = YES;
}

-(void) setFirstNameRequirementComplete {
    firstNameComplete = YES;
}

-(void) setLastNameRequirementComplete {
    lastNameComplete = YES;
}

-(void) setEmailRequirementComplete {
    emailComplete = YES;
}

-(void) setCountryRequirementComplete {
    countryComplete = YES;
}

@end
