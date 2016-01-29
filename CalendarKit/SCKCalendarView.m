/*****************************************************************************
 *
 * FILE:	SCKCalendarView.m
 * DESCRIPTION:	SimpleCalendarKit: Calendar View Class
 * DATE:	Thu, Jan 28 2016
 * UPDATED:	Fri, Jan 29 2016
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2016 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2016 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: SCKCalendarView.m,v 1.2 2013/01/22 15:23:51 kouichi Exp $
 *
 *****************************************************************************/

#import "SCKCalendarView.h"

@interface DayCollectionCell : UICollectionViewCell
@property (nonatomic,strong,readonly) UILabel * textLabel;
@end

@interface DayCollectionCell ()
@property (nonatomic,strong,readwrite) UILabel * textLabel;
@end

@implementation DayCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.autoresizesSubviews	= YES;
    self.autoresizingMask	= UIViewAutoresizingFlexibleWidth
				| UIViewAutoresizingFlexibleHeight
				| UIViewAutoresizingFlexibleLeftMargin
				| UIViewAutoresizingFlexibleRightMargin
				| UIViewAutoresizingFlexibleTopMargin
				| UIViewAutoresizingFlexibleBottomMargin;

    UILabel * textLabel;
    textLabel = [[UILabel alloc]
		  initWithFrame:CGRectInset(self.bounds, 2.0f, 2.0f)];
#if	0
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
#endif
    textLabel.textColor = [UIColor blackColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:textLabel];
    self.textLabel = textLabel;
  }
  return self;
}

-(void)prepareForReuse
{
  [super prepareForReuse];

  self.textLabel.text = nil;
  self.textLabel.textColor = [UIColor blackColor];
  self.textLabel.adjustsFontSizeToFitWidth = NO;
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  [self adjustFontSize];
}

-(void)adjustFontSize
{
  CGFloat width  = self.textLabel.frame.size.width;
  CGFloat height = self.textLabel.frame.size.height;
  CGFloat maxLineHeight = width < height ? width : height;
  /*
   * font.lineHeight = font.ascender + font.descender
   */
  CGFloat fontSize = 10.0f;	// start font size (= minimum font size)
  for ( ; ; fontSize += 0.5f) {
    UIFont * font = [UIFont systemFontOfSize:fontSize];
    CGFloat topPadding = font.ascender - font.capHeight;
    if (font.lineHeight >= maxLineHeight - topPadding) {
      self.textLabel.font = font;
      break;
    }
  }
}

@end


/*****************************************************************************/

enum {
  kSectionHeader,
  kSectionBody,
  kNumberOfSections
};

static NSString * const	kNameCellIdentifier = @"NameCollectionCellIdentifer";
static NSString * const	kDayCellIdentifier  = @"DayCollectionCellIdentifer";

@interface SCKCalendarView () <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView *	collectionView;
@property (nonatomic,strong) NSDateFormatter *	dateFormatter;
@property (nonatomic,strong) NSCalendar *	calendar;
@property (nonatomic,strong) NSDate *		selectedDate;
@property (nonatomic,strong) NSDate *		firstDateOfMonth;
@property (nonatomic,assign) NSRange		daysInMonth;
@property (nonatomic,assign) NSInteger		year;
@property (nonatomic,assign) NSInteger		month;
@property (nonatomic,assign) NSInteger		day;
@property (nonatomic,getter=isJapanese) BOOL	japanese;
@property (nonatomic,strong) NSArray *		namesOfDayOfWeek;
@end

@implementation SCKCalendarView

-(instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.autoresizesSubviews	= YES;
    self.autoresizingMask	= UIViewAutoresizingFlexibleWidth
				| UIViewAutoresizingFlexibleHeight
				| UIViewAutoresizingFlexibleLeftMargin
				| UIViewAutoresizingFlexibleRightMargin
				| UIViewAutoresizingFlexibleTopMargin
				| UIViewAutoresizingFlexibleBottomMargin;

    UICollectionViewFlowLayout * layout;
    layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 0.0f;
    layout.minimumInteritemSpacing = 0.0f;

    UICollectionView * collectionView;
    collectionView = [[UICollectionView alloc]
		      initWithFrame:self.bounds
		      collectionViewLayout:layout];
    [collectionView registerClass:[DayCollectionCell class]
		    forCellWithReuseIdentifier:kDayCellIdentifier];
    [collectionView registerClass:[DayCollectionCell class]
		    forCellWithReuseIdentifier:kNameCellIdentifier];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollEnabled = NO;
    [self addSubview:collectionView];
    self.collectionView = collectionView;

    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"d";
    self.dateFormatter = dateFormatter;

    self.calendar = [NSCalendar currentCalendar];

    NSString * lang = [[NSLocale preferredLanguages][0] substringToIndex:2];
    self.japanese   = [lang isEqualToString:@"ja"];
    if (self.isJapanese) {
      self.namesOfDayOfWeek = @[ @"日", @"月", @"火", @"水", @"木", @"金", @"土" ];
    }
    else {
      self.namesOfDayOfWeek = @[ @"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat" ];
    }
  }
  return self;
}

-(void)didMoveToSuperview
{
  [super didMoveToSuperview];

  self.selectedDate = [NSDate date];
}

/*****************************************************************************/

#pragma mark - override setter
-(void)setSelectedDate:(NSDate *)selectedDate
{
  if (![_selectedDate isEqualToDate:selectedDate]) {
    _selectedDate = selectedDate;

    NSCalendarUnit unitFlags = NSCalendarUnitYear
			     | NSCalendarUnitMonth
			     | NSCalendarUnitDay;
    NSDateComponents * dateComponents;
    dateComponents = [self.calendar components:unitFlags fromDate:selectedDate];

    _year  = dateComponents.year;
    _month = dateComponents.month;
    _day   = dateComponents.day;

    dateComponents.day = 1;
    self.firstDateOfMonth = [self.calendar dateFromComponents:dateComponents];

    // The number of days will be set in NSRange.length
    self.daysInMonth = [self.calendar rangeOfUnit:NSCalendarUnitDay
				      inUnit:NSCalendarUnitMonth
				      forDate:selectedDate];

    [self.collectionView reloadData];

    if ([_delegate respondsToSelector:@selector(calendarView:didSetYear:month:)]) {
      [_delegate calendarView:self didSetYear:_year month:_month];
    }
  }
}

/*****************************************************************************/

#pragma mark - public method
-(void)showThisMonth
{
  self.selectedDate = [NSDate date];
}

-(NSDate *)dateOfPreviousMonth
{
  NSDateComponents * dateComponents = [NSDateComponents new];
  dateComponents.month = -1;
  return [self.calendar dateByAddingComponents:dateComponents
			toDate:self.firstDateOfMonth
			options:0];
}

#pragma mark - public method
-(void)showPreviousMonth
{
  self.selectedDate = [self dateOfPreviousMonth];
}

-(NSDate *)dateOfNextMonth
{
  NSDateComponents * dateComponents = [NSDateComponents new];
  dateComponents.month = 1;
  return [self.calendar dateByAddingComponents:dateComponents
			toDate:self.firstDateOfMonth
			options:0];
}

#pragma mark - public method
-(void)showNextMonth
{
  self.selectedDate = [self dateOfNextMonth];
}

/*****************************************************************************/

-(NSDateComponents *)dateComponentsForCellAtIndexPath:(NSIndexPath *)indexPath
{
  // calculate the oridinal number of first day ( 1:Sunday - 7:Saturday )
  NSInteger ordinalityOfFirstDay;
  ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSCalendarUnitDay
					inUnit:NSCalendarUnitWeekOfMonth
					forDate:self.firstDateOfMonth];

  /*
   * calculate the difference between "day number of cell at indexpath"
   * and "day number of first day"
   * XXX: day of today is 0 in components.
   */
  NSDateComponents * dateComponents = [NSDateComponents new];
  dateComponents.day = indexPath.item - (ordinalityOfFirstDay - 1);

  return dateComponents;
}

-(NSDate *)dateWithDateComponents:(NSDateComponents *)dateComponents
{
  NSDate * date;
  date = [self.calendar dateByAddingComponents:dateComponents
			toDate:self.firstDateOfMonth
			options:0];

  return date;
}

-(NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
  NSDateComponents * dateComponents;
  dateComponents = [self dateComponentsForCellAtIndexPath:indexPath];

  return [self dateWithDateComponents:dateComponents];
}

/*****************************************************************************/

#pragma mark - UICollectionViewDataSource (optional)
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return kNumberOfSections;
}

#pragma mark - UICollectionViewDataSource (required)
-(NSInteger)collectionView:(UICollectionView *)collectionView
	numberOfItemsInSection:(NSInteger)section
{
  switch (section) {
    case kSectionHeader: return 7;
    case kSectionBody:	 return 7 * 6;
  }
  return 0;
}


#pragma mark - UICollectionViewDataSource (required)
// The cell that is returned must be retrieved from a call to
// -dequeueReusableCellWithReuseIdentifier:forIndexPath:
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
	cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger section = indexPath.section;
  NSInteger item    = indexPath.item;

  UIColor * textColor = [UIColor blackColor];
  switch (item % 7) {
     case 0: textColor = [UIColor redColor];   break; // Sunday
     case 6: textColor = [UIColor blueColor];  break; // Saturday
    default: textColor = [UIColor blackColor]; break; // Weekday
  }

  DayCollectionCell * cell;
  switch (section) {
    case kSectionHeader: {
	cell = (DayCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kNameCellIdentifier forIndexPath:indexPath];
	if (!self.isJapanese) {
	  cell.textLabel.adjustsFontSizeToFitWidth = YES;
	}
	cell.textLabel.text = self.namesOfDayOfWeek[item];
      }
      break;
    case kSectionBody: {
	cell = (DayCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kDayCellIdentifier forIndexPath:indexPath];

	NSDateComponents * dateComponents;
	dateComponents = [self dateComponentsForCellAtIndexPath:indexPath];
	NSDate *  date = [self dateWithDateComponents:dateComponents];
	cell.textLabel.text = [self.dateFormatter stringFromDate:date];

	NSInteger    day = dateComponents.day + 1;
	NSInteger endDay = self.daysInMonth.length;
	BOOL inThisMonth = (day > 0 && day <= endDay);
	if (!inThisMonth) {
	  textColor = [textColor colorWithAlphaComponent:0.3f];
	}
      }
      break;
  }

  cell.textLabel.textColor = textColor;

  return cell;
}

#if	0
#pragma mark - UICollectionViewDataSource (optional)
// The view that is returned must be retrieved from a call to
// -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
	viewForSupplementaryElementOfKind:(NSString *)kind
	atIndexPath:(NSIndexPath *)indexPath
{
}
#endif

#pragma mark - UICollectionViewDelegate (optional)
-(void)collectionView:(UICollectionView *)collectionView
	didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];

  if (indexPath.section == kSectionHeader) { return; }

  if ([_delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
    NSDate * date = [self dateForCellAtIndexPath:indexPath];
    [_delegate calendarView:self didSelectDate:date];
  }
}


#pragma mark - UICollectionViewDelegateFlowLayout (optional)
-(CGSize)collectionView:(UICollectionView *)collectionView
	layout:(UICollectionViewLayout*)collectionViewLayout
	sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
#if	1
  CGFloat width  = collectionView.bounds.size.width;
  CGFloat height = collectionView.bounds.size.height;

  CGFloat w = floorf(width  / 7.0f);
  CGFloat h = floorf(height / 6.0f);	// XXX: 曜日名なしの場合の計算

  // XXX: 曜日名は日にちの高さの半分 (height = 6h + 0.5h)
  NSInteger section = indexPath.section;
  switch (section) {
    case kSectionHeader:
      h = floorf(height / 13.0f);
      break;
    case kSectionBody:
      h = floorf(2.0f * height / 13.0f);
      break;
  }
  return CGSizeMake(w, h);
#else
  CGFloat width  = collectionView.bounds.size.width;
  CGFloat height = collectionView.bounds.size.height;
  CGFloat w = floorf(width  / 7.0f);
  CGFloat h = floorf(height / 6.0f);
  return CGSizeMake(w, h);
#endif
}

@end
