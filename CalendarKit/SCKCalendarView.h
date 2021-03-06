/*****************************************************************************
 *
 * FILE:	SCKCalendarView.h
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
 * $Id: SCKCalendarView.h,v 1.2 2013/01/22 15:23:51 kouichi Exp $
 *
 *****************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class	SCKCalendarView;

@protocol SCKCalendarViewDelegate <NSObject>
@optional
-(void)calendarView:(SCKCalendarView *)calendarView didSetYear:(NSInteger)year month:(NSInteger)month;
-(void)calendarView:(SCKCalendarView *)calendarView didSelectDate:(NSDate *)date;
@end

@interface SCKCalendarView : UIView

@property (nonatomic,weak) id <SCKCalendarViewDelegate>	delegate;
@property (nonatomic,readonly,getter=isJapanese) BOOL	japanese;
@property (nonatomic,assign,readonly) NSInteger		year;
@property (nonatomic,assign,readonly) NSInteger		month;
@property (nonatomic,assign) BOOL /* 今日が目立つ */	showsToday;
@property (nonatomic,assign) BOOL /* 透過型"月"表示 */	showsMonth;
@property (nonatomic,assign) BOOL /* 和暦の月名称 */	prefersWareki;
@property (nonatomic,assign,getter=isTitleHidden) BOOL	titleHidden;
@property (nonatomic,strong) UIColor * /* 休日祝祭日*/	sundayColor;
@property (nonatomic,strong) UIColor *			saturdayColor;
@property (nonatomic,strong) UIColor *			weekdayColor;
@property (nonatomic,strong) UIColor *			todayColor;
@property (nonatomic,strong) UIColor * /* 年月領域 */	titleColor;

-(void)showsThisMonth;
-(void)showsPreviousMonth;
-(void)showsNextMonth;

-(void)showsYear:(NSInteger)year month:(NSInteger)month;
-(void)update;
-(void)reload;

@end
