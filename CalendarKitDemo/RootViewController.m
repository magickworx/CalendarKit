/*****************************************************************************
 *
 * FILE:	RootViewController.m
 * DESCRIPTION:	CalendarKitDemo: Application Root View Controller
 * DATE:	Thu, Jan 28 2016
 * UPDATED:	Mon, Apr 25 2016
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
 * $Id: RootViewController.m,v 1.1 2016/01/28 12:40:37 kouichi Exp $
 *
 *****************************************************************************/

#import <CalendarKit/CalendarKit.h>
#import "RootViewController.h"

@interface RootViewController () <SCKCalendarViewDelegate>
@property (nonatomic,strong) SCKCalendarView *	calendarView;	// 今月
@property (nonatomic,strong) SCKCalendarView *	prevCalView;	// 先月
@property (nonatomic,strong) SCKCalendarView *	nextCalView;	// 来月
@property (nonatomic,strong) UIButton *		titleButton;
@end

@implementation RootViewController

-(id)init
{
  self = [super init];
  if (self) {
    self.title = NSLocalizedString(@"CalendarKitDemo", @"");
  }
  return self;
}

-(void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)loadView
{
  [super loadView];

  CGFloat width  = self.view.bounds.size.width;
  CGFloat height = self.view.bounds.size.height;

  CGFloat w = floorf(width * 0.5f) - 8.0f;
  CGFloat h = w;
  CGFloat x = width - (w + 4.0f);
  CGFloat y = height - h - 22.0f;

  SCKCalendarView * calendarView;
  calendarView = [[SCKCalendarView alloc] initWithFrame:CGRectMake(x, y, w, h)];
  calendarView.showsMonth = YES;
  calendarView.prefersWareki = YES;
  [self.view addSubview:calendarView];
  [calendarView showsNextMonth];
  self.nextCalView = calendarView;

  x = 4.0f;
  calendarView = [[SCKCalendarView alloc] initWithFrame:CGRectMake(x, y, w, h)];
  calendarView.showsMonth = YES;
  calendarView.prefersWareki = YES;
  [self.view addSubview:calendarView];
  [calendarView showsPreviousMonth];
  self.prevCalView = calendarView;

  x = 0.0f;
  y = 0.0f;
  h = height - h - 44.0f;
  w = width;
  calendarView = [[SCKCalendarView alloc] initWithFrame:CGRectMake(x, y, w, h)];
  calendarView.delegate = self;
  calendarView.showsToday = YES;
  calendarView.titleHidden = YES;
  [self.view addSubview:calendarView];
  self.calendarView = calendarView;

  // UINavigationBar のタイトルをタップでアクションさせる
  x = 0.0f;
  y = 0.0f;
  w = floorf(width * 0.625f);
  h = 44.0f;
  UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
  [button setFrame:CGRectMake(x, y, w, h)];
  [button setTitle:self.title forState:UIControlStateNormal];
  [button setTitleColor:[UIColor lightGrayColor]
	  forState:UIControlStateHighlighted];
  [button addTarget:self
  	  action:@selector(titleButtonAction:)
  	  forControlEvents:UIControlEventTouchUpInside];
  button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  button.showsTouchWhenHighlighted = YES;
  button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
  button.titleLabel.adjustsFontSizeToFitWidth = YES;
  self.titleButton = button;
  self.navigationItem.titleView = button;
}

-(void)viewDidLoad
{
  [super viewDidLoad];

  UIBarButtonItem * prevItem;
  prevItem = [[UIBarButtonItem alloc]
	      initWithTitle:@"前月"
	      style:UIBarButtonItemStylePlain
	      target:self
	      action:@selector(prevAction:)];
  self.navigationItem.leftBarButtonItem = prevItem;

  UIBarButtonItem * nextItem;
  nextItem = [[UIBarButtonItem alloc]
	      initWithTitle:@"翌月"
	      style:UIBarButtonItemStylePlain
	      target:self
	      action:@selector(nextAction:)];
  self.navigationItem.rightBarButtonItem = nextItem;
}

/*****************************************************************************/

#pragma mark - UIBarButtonItem action
-(void)prevAction:(id)sender
{
  [self.calendarView showsPreviousMonth];
  [self.prevCalView showsPreviousMonth];
  [self.nextCalView showsPreviousMonth];
}

#pragma mark - UIBarButtonItem action
-(void)nextAction:(id)sender
{
  [self.calendarView showsNextMonth];
  [self.prevCalView showsNextMonth];
  [self.nextCalView showsNextMonth];
}

#pragma mark - UIButton action
-(void)titleButtonAction:(UIButton *)button
{
  [self.calendarView showsThisMonth];

  [self.prevCalView showsThisMonth];
  [self.prevCalView showsPreviousMonth];

  [self.nextCalView showsThisMonth];
  [self.nextCalView showsNextMonth];
}

/*****************************************************************************/

#pragma mark - SCKCalendarViewDelegate (optional)
-(void)calendarView:(SCKCalendarView *)calendarView
	didSetYear:(NSInteger)year month:(NSInteger)month
{
  self.title = [NSString stringWithFormat:@"%zd年 %zd月", year, month];
  [self.titleButton setTitle:self.title forState:UIControlStateNormal];
}

#pragma mark - SCKCalendarViewDelegate (optional)
-(void)calendarView:(SCKCalendarView *)calendarView didSelectDate:(NSDate *)date{
  @autoreleasepool {
    NSString * message = [NSDateFormatter localizedStringFromDate:date
					  dateStyle:NSDateFormatterFullStyle
					  timeStyle:NSDateFormatterNoStyle];
    UIAlertController *	alertController =
      [UIAlertController alertControllerWithTitle:@"日付"
			 message:message
			 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction * closeAction =
      [UIAlertAction actionWithTitle:@"OK"
		     style:UIAlertActionStyleDefault
		     handler:nil];
    [alertController addAction:closeAction];

    [self presentViewController:alertController animated:YES completion:nil];
  }
}

@end
