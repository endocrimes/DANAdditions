//
//  NSDate+DANAdditions.m
//
//  Copyright (c) 2014 Daniel Tomlinson. All rights reserved.
//

#import "NSDate+DANAdditions.h"

const NSInteger kISO8601MaxLength = 25;
const NSInteger kISO8601TimestampLength = 19;
const NSInteger kISO8601TimezoneLength = 6;
const char * kISO8601DefaultTimestamp = "+0000";
const char * kISO8601FormatString = "%FT%T%z";

@implementation NSDate (DANAdditions)

# pragma mark Public Methods
# pragma mark -

# pragma mark Basic Methods

- (NSDate *)dateByModifyingSeconds:(NSInteger)seconds {
	NSDateComponents *components = [self dateComponents];
	components.second = seconds;
	
	return [NSDate dateWithDateComponents:components];
}

- (NSDate *)dateByModifyingMinute:(NSInteger)minute {
	NSDateComponents *components = [self dateComponents];
	components.minute = minute;
	
	return [NSDate dateWithDateComponents:components];
}

- (NSDate *)dateByModifyingHour:(NSInteger)hour {
	NSDateComponents *components = [self dateComponents];
	components.hour = hour;
	
	return [NSDate dateWithDateComponents:components];
}

- (NSDate *)dateByModifyingDay:(NSInteger)day {
	NSDateComponents *components = [self dateComponents];
	components.day = day;
	
	return [NSDate dateWithDateComponents:components];
}

- (NSDate *)dateByModifyingMonth:(NSInteger)month {
	NSDateComponents *components = [self dateComponents];
	components.month = month;
	
	return [NSDate dateWithDateComponents:components];
}

- (NSDate *)dateByModifyingYear:(NSInteger)year {
	NSDateComponents *components = [self dateComponents];
	components.year = year;
	
	return [NSDate dateWithDateComponents:components];
}

+ (NSDate *)dateFromYear:(NSInteger)year andMonth:(NSInteger)month andDay:(NSInteger)day
				 andHour:(NSInteger)hour andMinute:(NSInteger)minute andSecond:(NSInteger)second {
	
	NSDateComponents *components = [[NSDate date] dateComponents];
	components.year = year;
	components.month = month;
	components.day = day;
	components.hour = hour;
	components.minute = minute;
	components.second = second;
	
	return [NSDate dateWithDateComponents:components];
}

+ (NSDate *)dateWithDay:(NSInteger)day andMonth:(NSInteger)month andYear:(NSInteger)year {
	return [NSDate dateFromYear:year
					   andMonth:month
						 andDay:day
						andHour:0
					  andMinute:0
					  andSecond:0];
}

+ (NSDate *)dateWithHour:(NSInteger)hour andMinute:(NSInteger)minute onReferenceDate:(NSDate *)date {
	NSDateComponents *components = [date dateComponents];
	components.hour = hour;
	components.minute = minute;
	components.second = 0;
	
	return [NSDate dateWithDateComponents:components];
}


- (NSArray *)timeAsArrayComponents {
	NSArray *components = [[self timeStringWithSeperator:@""] componentsSeparatedByString:@""];
	
	return components;
}

- (NSString *)timeStringWithSeperator:(NSString *)seperator {
	NSDateComponents *components = [self dateComponents];
	
	NSString *hourString = (components.hour >= 10 ? [NSString stringWithFormat:@"%d", components.hour] : [NSString stringWithFormat:@"0%d", components.hour]);
	
	NSString *minuteString = (components.minute >= 10 ? [NSString stringWithFormat:@"%d", components.minute] : [NSString stringWithFormat:@"0%d", components.minute]);
	
	return [NSString stringWithFormat:@"%@%@%@", hourString, seperator, minuteString];
}

+ (NSDate *)dateFromString:(NSString *)dateString {
	return [self dateFromString:dateString withFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
}

+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)formatString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
	
	return [dateFormatter dateFromString:dateString];
}

- (NSDate *)yesterday {
    return [self calculateDateWithOffset:-1];
}

- (NSDate *)tomorrow {
    return [self calculateDateWithOffset:1];
}

- (NSDate *)calculateDateWithOffset:(int)daysOffset {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:daysOffset];
    
    return [[NSDate calendar] dateByAddingComponents:components toDate:self options:0];
}

- (BOOL)isWeekend {
	int dayOfWeek = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:self] weekday];
    if (dayOfWeek == Saturday || dayOfWeek == Sunday) {
        return YES;
    }
    
    return NO;
}

- (NSString *)weekdayName {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[NSLocale preferredLanguages][0]]];
    return [dateFormatter stringFromDate:self];
}

- (BOOL)isEarlierThan:(NSDate*)otherDate {
    return [self compare:otherDate] == NSOrderedAscending;
}

- (BOOL)isLaterThan:(NSDate*)otherDate {
    return [self compare:otherDate] == NSOrderedDescending;
}

#pragma mark - ISO8601 Support
/**
 *  | Supported Formats |
 * - 2014-06-19T12:03:00Z
 * - 2014-06-19T12:03:00.000Z
 * - 2014-06-19T12:03:00+01:00
 * - 2014-06-19T12:03:00.000+01:00
 * 
 * If the timezone is omitted or Z is used then
 * a +00:00 timezone will be used.
 *
 */
+ (NSDate *)dateFromISO8601String:(NSString *)iso8601String {
    
    // Early return if nil
    if (!iso8601String) {
        return nil;
    }
    
    const char *inputStr = [iso8601String cStringUsingEncoding:NSUTF8StringEncoding];
    size_t length = strlen(inputStr);
    
    // Return nil if the string is shorter than the timestamp length
    if (length < kISO8601TimestampLength) {
        return nil;
    }
    
    char parsedStr[kISO8601MaxLength] = "";
    BOOL hasTimezone = NO;
    
    switch (length) {
        case 20: // '2014-06-19T12:03:00Z'
        case 24: // '2014-06-19T12:03:00.000Z'
            strncpy(parsedStr, inputStr, kISO8601TimestampLength);
            break;
        case 25: // '2014-06-19T12:03:00+01:00'
        case 29: // '2014-06-19T12:03:00.000+01:00'
            strncpy(parsedStr, inputStr, kISO8601TimestampLength);
            hasTimezone = YES;
            break;
        default: // Badly formatted timezone.
            strncpy(parsedStr, inputStr, (length > 24 ? 24 : length));
            break;
    }
    
    // Append timezone
    size_t timestampLength = strlen(parsedStr);
    if (hasTimezone) {
        // Append the timezone without the `:`
        
        // Copy first three characters of the timezone, i.e if we had +01:00, it will take +01
        strncpy(parsedStr + timestampLength, inputStr + length - kISO8601TimezoneLength, 3);
        
        // Copy the last two characters of the timezone, i.e if we had +01:00, it will take 00
        strncpy(parsedStr + timestampLength + 3, inputStr + length - 2, 2);
    }
    else
    {
        // If we don't have a user defined timestamp, use the standard (GMT +0)
        strncpy(parsedStr + timestampLength, kISO8601DefaultTimestamp, strlen(kISO8601DefaultTimestamp));
    }
    
    // Append null terminator
    parsedStr[sizeof(parsedStr) - 1] = 0;
    
    // Create time from string
    struct tm timeStruct;
    
    char *strpResult = strptime(parsedStr, kISO8601FormatString, &timeStruct);
    if (strpResult == NULL) {
        return nil;
    }
    
    time_t time;
    time = mktime(&timeStruct);
    
    return [NSDate dateWithTimeIntervalSince1970:time];
}

# pragma mark -
# pragma mark Private Methods
# pragma mark -

+ (NSCalendar *)calendar {
	return [NSCalendar currentCalendar];
//	return [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
}

- (NSDateComponents *)dateComponents {
	NSDateComponents *components = [[NSDate calendar] components:(NSSecondCalendarUnit|
																  NSMinuteCalendarUnit|
																  NSHourCalendarUnit  |
																  NSDayCalendarUnit   |
																  NSMonthCalendarUnit |
																  NSYearCalendarUnit)
																 fromDate:self];
	return components;
}

+ (NSDate *)dateWithDateComponents:(NSDateComponents *)components {
	return [[self calendar] dateFromComponents:components];
}


#pragma mark -
@end
