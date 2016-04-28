/*****************************************************************************
 *
 * FILE:	SCKCalendarView.m
 * DESCRIPTION:	SimpleCalendarKit: Calendar View Class
 * DATE:	Thu, Jan 28 2016
 * UPDATED:	Thu, Apr 28 2016
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

@interface SCKCollectionHeaderView : UICollectionReusableView
@property (nonatomic,strong,readonly) UILabel * textLabel;
@end

@interface SCKDayCollectionCell : UICollectionViewCell
@property (nonatomic,strong,readonly) UILabel * textLabel;
@end

/*****************************************************************************/

enum {
  kSectionHeader,
  kSectionBody,
  kNumberOfSections
};

static NSString * const	kNameCellIdentifier = @"NameCollectionCellIdentifer";
static NSString * const	kDayCellIdentifier  = @"DayCollectionCellIdentifer";
static NSString * const	kHeaderIdentifier   = @"CollectionHeaderIdentifer";

@interface SCKCalendarView () <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,readwrite,getter=isJapanese) BOOL	japanese;
@property (nonatomic,assign,readwrite) NSInteger	year;
@property (nonatomic,assign,readwrite) NSInteger	month;
@property (nonatomic,strong) UICollectionView *	collectionView;
@property (nonatomic,strong) NSDateFormatter *	dateFormatter;
@property (nonatomic,strong) NSCalendar *	calendar;
@property (nonatomic,strong) NSDate *		selectedDate;
@property (nonatomic,strong) NSDate *		firstDateOfMonth;
@property (nonatomic,strong) NSDate *		dateOfToday;
@property (nonatomic,assign) NSRange		daysInMonth;
@property (nonatomic,assign) CGFloat		titleHeight;
@property (nonatomic,assign) CGFloat		wdayHeight;
@property (nonatomic,assign) CGFloat		mdayHeight;
@property (nonatomic,strong) NSArray *		nameOfDayOfWeek;
@property (nonatomic,strong) NSArray *		nameOfMonth;
@property (nonatomic,strong) CATextLayer *	textLayer;
@end

@implementation SCKCalendarView

-(instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.autoresizesSubviews	= YES;
    self.autoresizingMask	= UIViewAutoresizingFlexibleWidth
				| UIViewAutoresizingFlexibleHeight;

    UICollectionViewFlowLayout * layout;
    layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 0.0f;
    layout.minimumInteritemSpacing = 0.0f;

    UICollectionView * collectionView;
    collectionView = [[UICollectionView alloc]
		      initWithFrame:self.bounds
		      collectionViewLayout:layout];
    [collectionView registerClass:[SCKDayCollectionCell class]
		    forCellWithReuseIdentifier:kDayCellIdentifier];
    [collectionView registerClass:[SCKDayCollectionCell class]
		    forCellWithReuseIdentifier:kNameCellIdentifier];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollEnabled = NO;
    [self addSubview:collectionView];
    self.collectionView = collectionView;

    [collectionView registerClass:[SCKCollectionHeaderView class]
		    forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
		    withReuseIdentifier:kHeaderIdentifier];

    [self prepareForCalendar];
  }
  return self;
}

-(void)didMoveToSuperview
{
  [super didMoveToSuperview];

  self.dateOfToday = [NSDate date];
  [self showsThisMonth];
}

-(void)layoutSubviews
{
  [super layoutSubviews];

  self.collectionView.frame = self.bounds;

  CGFloat height = self.collectionView.frame.size.height;
  if (_titleHidden) {
    _titleHeight = 0.0f;
    // XXX: 曜日名は日にちの高さの半分 (height = 6h + 0.5h)
    _wdayHeight  = floorf(height / 13.0f);
    _mdayHeight  = floorf(2.0f * height / 13.0f);
  }
  else {
    // XXX: "年月"と"曜日"の高さの合計が日付の一つの高さに同じ
    CGFloat    h = floorf(height / 7.0f);
    _titleHeight = floorf(h * 0.5f);
    _wdayHeight  = floorf(h * 0.5f);
    _mdayHeight  = h;
  }
}

/*****************************************************************************/

-(void)prepareForCalendar
{
  NSDateFormatter * dateFormatter = [NSDateFormatter new];
  dateFormatter.dateFormat = @"d";
  self.dateFormatter = dateFormatter;

  self.calendar = [NSCalendar currentCalendar];

  NSString * lang = [[NSLocale preferredLanguages][0] substringToIndex:2];
  self.japanese   = [lang isEqualToString:@"ja"];
  if (self.isJapanese) {
    self.nameOfDayOfWeek = @[ @"日", @"月", @"火", @"水", @"木", @"金", @"土" ];
    self.nameOfMonth = @[
	@"睦月", @"如月", @"弥生", @"卯月", @"皐月", @"水無月",
	@"文月", @"葉月", @"長月", @"神無月", @"霜月", @"師走"
    ];
  }
  else {
    self.nameOfDayOfWeek = @[ @"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat" ];
    self.nameOfMonth = @[
	@"January", @"February", @"March", @"April", @"May", @"June",
	@"July", @"August", @"September", @"October", @"November", @"December"
    ];
  }

  _showsToday    = NO;
  _showsMonth    = NO;
  _prefersWareki = NO;
  _titleHidden   = NO;

  self.sundayColor   = [UIColor redColor];
  self.saturdayColor = [UIColor blueColor];
  self.weekdayColor  = [UIColor blackColor];
  self.todayColor    = [UIColor colorWithRed:0.8f green:1.0f blue:0.6f
				alpha:1.0f];
  self.titleColor    = [UIColor blackColor];
}

#pragma mark - override setter
-(void)setShowsMonth:(BOOL)showsMonth
{
  if (showsMonth) {
    if (_textLayer == nil) {
      CATextLayer * textLayer = [CATextLayer new];
      CGRect   bounds = self.collectionView.bounds;
      CGFloat   width = bounds.size.width;
      CGFloat  height = bounds.size.height;
      CGFloat      dx = floorf(width * 0.1f);
      CGFloat      dy = floorf(height * 0.1f);
      textLayer.frame = CGRectInset(bounds, dx, dy);
      textLayer.fontSize = floorf(textLayer.frame.size.height * 0.8f);
      textLayer.opacity = 0.20f;
      textLayer.foregroundColor = [UIColor lightGrayColor].CGColor;
      textLayer.alignmentMode = kCAAlignmentCenter;
      textLayer.contentsScale = [UIScreen mainScreen].scale;
      textLayer.zPosition = -100.0;
      [self.collectionView.layer addSublayer:textLayer];
      self.textLayer = textLayer;
    }
    self.textLayer.string = [NSString stringWithFormat:@"%zd", _month];
  }
  self.textLayer.hidden = !showsMonth;

  _showsMonth = showsMonth;
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

    dateComponents.day = 1;
    self.firstDateOfMonth = [self.calendar dateFromComponents:dateComponents];

    // The number of days will be set in NSRange.length
    self.daysInMonth = [self.calendar rangeOfUnit:NSCalendarUnitDay
				      inUnit:NSCalendarUnitMonth
				      forDate:selectedDate];

    [self.collectionView reloadData];

    if (_showsMonth) {
      self.textLayer.string = [NSString stringWithFormat:@"%zd", _month];
    }

    if ([_delegate respondsToSelector:@selector(calendarView:didSetYear:month:)]) {
      [_delegate calendarView:self didSetYear:_year month:_month];
    }
  }
}

/*****************************************************************************/

#pragma mark - public method
-(void)showsThisMonth
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
-(void)showsPreviousMonth
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
-(void)showsNextMonth
{
  self.selectedDate = [self dateOfNextMonth];
}

#pragma mark - public method
-(void)showsYear:(NSInteger)year month:(NSInteger)month
{
  NSDateComponents * dateComponents = [NSDateComponents new];
  dateComponents.year  = year;
  dateComponents.month = month;
  dateComponents.day   = 1;
  self.selectedDate = [self.calendar dateFromComponents:dateComponents];
}

#pragma mark - public method
-(void)update
{
  self.dateOfToday = [NSDate date];

  [self.collectionView reloadData];
}

#pragma mark - public method
-(void)reload
{
  [self.collectionView reloadData];
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

  UIColor * textColor;
  switch (item % 7) {
     case 0: textColor = self.sundayColor;   break; // Sunday
     case 6: textColor = self.saturdayColor; break; // Saturday
    default: textColor = self.weekdayColor;  break; // Weekday
  }

  SCKDayCollectionCell * cell;
  switch (section) {
    case kSectionHeader: {
	cell = (SCKDayCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kNameCellIdentifier forIndexPath:indexPath];
	if (!self.isJapanese) {
	  cell.textLabel.adjustsFontSizeToFitWidth = YES;
	}
	cell.textLabel.text = self.nameOfDayOfWeek[item];
      }
      break;
    case kSectionBody: {
	cell = (SCKDayCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kDayCellIdentifier forIndexPath:indexPath];

	NSDateComponents * dateComponents;
	dateComponents = [self dateComponentsForCellAtIndexPath:indexPath];
	NSDate *  date = [self dateWithDateComponents:dateComponents];
	cell.textLabel.text = [self.dateFormatter stringFromDate:date];

	if (_showsToday) {
	  NSCalendarUnit unitFlags = NSCalendarUnitYear
				   | NSCalendarUnitMonth
				   | NSCalendarUnitDay;
	  NSComparisonResult result =
		[[NSCalendar currentCalendar]
		  compareDate:self.dateOfToday toDate:date
		  toUnitGranularity:unitFlags];
	  if (result == NSOrderedSame) {
	    cell.contentView.backgroundColor =
		[self.todayColor colorWithAlphaComponent:0.5f];
	  }
	}

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

#pragma mark - UICollectionViewDataSource (optional)
// The view that is returned must be retrieved from a call to
// -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
	viewForSupplementaryElementOfKind:(NSString *)kind
	atIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section != kSectionHeader ||
      ![kind isEqualToString:UICollectionElementKindSectionHeader]) {
    return nil;
  }

  SCKCollectionHeaderView * headerView =
	(SCKCollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
		withReuseIdentifier:kHeaderIdentifier
		forIndexPath:indexPath];
  if (headerView == nil) {
    headerView = [[SCKCollectionHeaderView alloc] initWithFrame:CGRectZero];
  }

  NSString * text;
  if (self.isJapanese) {
    if (_prefersWareki) {
      text = [NSString stringWithFormat:@"%zd年 %@",
		       _year, self.nameOfMonth[_month - 1]];
    }
    else {
      text = [NSString stringWithFormat:@"%zd年 %zd月", _year, _month];
    }
  }
  else {
    text = [NSString stringWithFormat:@"%@ %zd",
		     self.nameOfMonth[_month - 1], _year];
  }
  headerView.textLabel.text = text;
  headerView.textLabel.textColor = self.titleColor;

  return headerView;
}

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
  CGFloat width  = collectionView.bounds.size.width;
  CGFloat height = collectionView.bounds.size.height;

  CGFloat w = floorf(width  / 7.0f);
  CGFloat h = floorf(height / 6.0f);	// XXX: 曜日名なしの場合の計算

  NSInteger section = indexPath.section;
  switch (section) {
    case kSectionHeader: h = _wdayHeight; break;
    case kSectionBody:   h = _mdayHeight; break;
  }

  return CGSizeMake(w, h);
}

#pragma mark - UICollectionViewDelegateFlowLayout (optional)
-(CGSize)collectionView:(UICollectionView *)collectionView
	layout:(UICollectionViewLayout*)collectionViewLayout
	referenceSizeForHeaderInSection:(NSInteger)section
{
  if (section == kSectionHeader && !_titleHidden) {
    CGFloat w = collectionView.bounds.size.width;
    CGFloat h = _titleHeight;

    return CGSizeMake(w, h);
  }
  return CGSizeZero;
}

@end

/******************************************************************************
 *
 *	Custom UICollectionViewCell
 *
 *****************************************************************************/
@interface SCKDayCollectionCell ()
@property (nonatomic,strong,readwrite) UILabel * textLabel;
@end

@implementation SCKDayCollectionCell

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
    textLabel.textColor = [UIColor blackColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:textLabel];
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

  self.contentView.backgroundColor = nil;
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

/******************************************************************************
 *
 *	Custom UICollectionReusableView for Section Header
 *
 *****************************************************************************/
@interface SCKCollectionHeaderView ()
@property (nonatomic,strong,readwrite) UILabel * textLabel;
@end

@implementation SCKCollectionHeaderView

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
    textLabel = [[UILabel alloc] initWithFrame:self.bounds];
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
