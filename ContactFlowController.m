//
//  ContactFlowController.m
//  ContactFlow
//
//  Created by Zero on 11/8/07.
//  Copyright 2007 Zero's Studio. All rights reserved.
//

#import "ContactFlowController.h"
#import <Quartz/Quartz.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABImageLoading.h>
#import <AddressBook/ABTypedefs.h>
#import <AddressBook/ABRecord.h>

@interface ContactItem : NSObject
{
	NSImage *_image;
	NSString *_imageID;
	NSString *_personUID;
	NSString *_imageSubTitle;
}

- (id)initWithImage:(NSImage*)image imageID:(NSString*)imageID andImageSubTitle:(NSString*) subTitle andPersonUID:(NSString*) pUID;
- (NSString *) imageUID;
- (NSString *) personUID;
- (NSString *) imageRepresentationType;
- (void) setImageSubTitle:(NSString*)imageTitle;
- (id) imageRepresentation;

@end;

@implementation ContactItem

- (id)initWithImage:(NSImage*)image imageID:(NSString*)imageID andImageSubTitle:(NSString*) subTitle andPersonUID:(NSString*) pUID
{
	if (self = [super init]) {
		_image = [image copy];
		_imageID = [imageID copy];
		_imageSubTitle = [subTitle copy];
		_personUID = [pUID copy];
	}
	return self;
}

- (NSString *) imageUID
{
	return _imageID;
}

- (NSString *) personUID
{
	return _personUID;
}

- (NSString *) imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}

- (id) imageRepresentation
{
	return _image;
}

- (NSString*) imageTitle
{
	return _imageID;
}

- (NSString*) imageSubtitle
{
	return _imageSubTitle;
}

- (void) setImageSubTitle:(NSString*) title
{
	_imageSubTitle = [title copy];
}

@end

@implementation ContactFlowController

- (void)awakeFromNib
{
	_imageArray = [NSMutableArray new];	
	
	[self find:nil];
		
	[_imageBrowser setDataSource:self];
	[_imageBrowser setDelegate:self];
	[_imageBrowser reloadData];
}

- (void)find:(id) sender
{
	[_imageArray removeAllObjects];
	
	ABAddressBook* ab = [ABAddressBook sharedAddressBook];
	NSArray* abPeople;
	if ([[_searchField stringValue] isEqualToString:@""])
		abPeople = [ab people];
	else
	{
        ABSearchElement *lastNameIsFromField = [ABPerson searchElementForProperty:kABLastNameProperty
                                                                           label:nil
                                                                             key:nil
                                                                           value:[_searchField stringValue]
                                                                      comparison:kABContainsSubStringCaseInsensitive];

        ABSearchElement *firstNameIsFromField = [ABPerson searchElementForProperty:kABFirstNameProperty
                                                                            label:nil
                                                                              key:nil
                                                                            value:[_searchField stringValue]
                                                                       comparison:kABContainsSubStringCaseInsensitive];

        ABSearchElement *companyIsFromField = [ABPerson searchElementForProperty:kABOrganizationProperty
                                                                           label:nil
                                                                             key:nil
                                                                           value:[_searchField stringValue]
                                                                      comparison:kABContainsSubStringCaseInsensitive];

        ABSearchElement *wholeQuery =[ABSearchElement searchElementForConjunction:kABSearchOr
                                                                         children:[NSArray arrayWithObjects: lastNameIsFromField, firstNameIsFromField, companyIsFromField, nil]];

        abPeople = [ab recordsMatchingSearchElement:wholeQuery];
	}
	
	
	for (ABPerson* person in abPeople)
	{
		NSImage *image;
		if ([person imageData] != nil)
			image = [[NSImage alloc] initWithData:[person imageData]];
		else
		{
			image = nil;
		}
		NSString* lastName = [[person valueForProperty: kABLastNameProperty] copy];
		NSString* firstName = [[person valueForProperty: kABFirstNameProperty] copy];
		NSString* name = [[NSString stringWithFormat:@"%@%@", lastName, firstName] stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
		ContactItem *item = [[ContactItem alloc] initWithImage:image imageID:name andImageSubTitle:[person valueForProperty: kABOrganizationProperty] andPersonUID: [person uniqueId]];
		[_imageArray addObject:item];
	}
	
	[_imageBrowser reloadData];
}

- (NSUInteger)numberOfItemsInImageFlow:(IKImageBrowserView *) aBrowser
{
	return [_imageArray count];
}

- (id) imageFlow:(id)aFlowLayer itemAtIndex:(int)index
{
	return [_imageArray objectAtIndex:index];
}

- (void) imageFlow:(id)aFlowLayer cellWasDoubleClickedAtIndex:(int) index
{
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"addressbook://%@",[[_imageArray objectAtIndex:index] personUID]]];
	[[NSWorkspace sharedWorkspace] openURL: url];
}

- (void) imageFlowSelectionDidChange:(id) aBrowser
{
	NSLog(@"Selected %@", [aBrowser selectionIndexes]);
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [self find:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication
{
	return true;
}

@end