//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "QBindingEvaluator.h"
#import "QSectionToolbar.h"

@implementation QSection {
@private
    NSDictionary *_elementTemplate;
    NSMutableArray *_afterTemplateElements;
    NSMutableArray *_beforeTemplateElements;
}
@synthesize title;
@synthesize footer;
@synthesize elements;
@synthesize rootElement = _rootElement;
@synthesize key = _key;
@synthesize bind = _bind;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;
@synthesize entryPosition = _entryPosition;
@synthesize headerItems = _headerItems;
@synthesize footerItems = _footerItems;
@synthesize elementTemplate = _elementTemplate;
@synthesize afterTemplateElements = _afterTemplateElements;
@synthesize beforeTemplateElements = _beforeTemplateElements;

@synthesize hidden = _hidden;
@dynamic visibleIndex;

- (QElement *)getVisibleElementForIndex:(NSInteger)index
{
    for (QElement * q in self.elements)
    {
        if (!q.hidden && index-- == 0)
            return q;
    }
    return nil;
}
- (NSInteger)visibleNumberOfElements
{
    NSUInteger c = 0;
    for (QElement * q in self.elements)
    {
        if (!q.hidden)
            c++;
    }
    return c;
}

- (NSUInteger)getVisibleIndexForElement:(QElement*)element
{
    NSUInteger c = 0;
    for (QElement * q in self.elements)
    {
        if (q == element)
            return c;
        if (!q.hidden)
            ++c;
    }
    return NSNotFound;
}

- (NSUInteger) visibleIndex
{
    return [self.rootElement getVisibleIndexForSection:self];
}

- (BOOL)needsEditing {
    return NO;
}

- (QSection *)initWithTitle:(NSString *)sectionTitle {
    self = [super init];
    if (self) {
        self.title = sectionTitle;
    }
    return self;
}

- (void)addElement:(QElement *)element
{
    if (self.elements == nil) {
        self.elements = [NSMutableArray array];
    }
    
    element.parentSection = self;
    [self.elements addObject:element];
}

- (void)insertElement:(QElement *)element atIndex:(NSUInteger)index
{
    if (self.elements == nil) {
        self.elements = [NSMutableArray array];
    }
    
    element.parentSection = self;
    [self.elements insertObject:element atIndex:index];
}

- (void)removeElementAtIndex:(NSUInteger)index
{
    if (self.elements == nil) {
        return;
    }

    QElement *element = [self.elements objectAtIndex:index];
    [self.elements removeObjectAtIndex:index];
    element.parentSection = nil;
}

- (void)removeElement:(QElement *)element
{
    if (self.elements == nil) {
        return;
    }
    
    element.parentSection = nil;
    [self.elements removeObject:element];
}

- (void)removeElementsInRange:(NSRange)range
{
    if (self.elements == nil) {
        return;
    }
    
    for (int i = 0; i < range.length; i++) {
        QElement *element = [self.elements objectAtIndex:range.location];
        [self.elements removeObjectAtIndex:range.location];
        element.parentSection = nil;
    }
}

- (void)removeAllElements
{
    if (self.elements == nil) {
        return;
    }
    
    for (QElement * element in self.elements) {
        element.parentSection = nil;
    }
    [self.elements removeAllObjects];
}

- (NSUInteger)indexOfElement:(QElement *)element
{
    if (self.elements) {
        return [self.elements indexOfObject:element];
    }
    return NSNotFound;
}


- (UIView*) getHeaderViewForTable:(QuickDialogTableView*)tableView controller:(QuickDialogController*)controller
{
    if (_headerView)
        return _headerView;
    if (_headerItems)
        return [[QSectionToolbar alloc] initWithElements:_headerItems controller:controller];

    return nil;
}
- (UIView*) getFooterViewForTable:(QuickDialogTableView*)tableView controller:(QuickDialogController*)controller
{
    if (_footerView)
        return _footerView;
    if (_footerItems)
        return [[QSectionToolbar alloc] initWithElements:_footerItems controller:controller];

    return nil;
}

- (void)fetchValueIntoObject:(id)obj {
    for (QElement *el in elements){
        [el fetchValueIntoObject:obj];
    }
}

- (void)dealloc {
    for (QElement * element in self.elements) {
        element.parentSection = nil;
    }
}

- (void)bindToObject:(id)data {
    if ([self.bind length]==0 || [self.bind rangeOfString:@"iterate"].location == NSNotFound)  {
            for (QElement *el in self.elements) {
                [el bindToObject:data];
            }
        } else {
            [self.elements removeAllObjects];
        }

        [[QBindingEvaluator new] bindObject:self toData:data];

}

- (void)fetchValueUsingBindingsIntoObject:(id)data {
    if ([self.bind length]==0 || [self.bind rangeOfString:@"iterate"].location == NSNotFound) {
        for (QElement *el in self.elements) {
            [el fetchValueUsingBindingsIntoObject:data];
        }
    } else {
        [[QBindingEvaluator new] fetchValueFromSection:self toData:data];
    }

}
@end