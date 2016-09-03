//
//  JSDateChooserView.m
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import "JSDateChooserView.h"
#import "JSDateNavigationBar.h"
#import "JSDateComponentView.h"
#import "JSDateIndicatorView.h"
#import "JSDateUntils.h"


@interface JSDateChooserView ()
{
    NSUInteger _visibleYear;
    NSUInteger _visibleMonth;
    NSUInteger _currentVisbleRow;
    NSArray *_eventsInVisibleMonth;
}

@property (strong, nonatomic) JSDateNavigationBar *navigationBar;
@property (strong, nonatomic) UIStackView *weekHeaderView;
@property (strong, nonatomic) UIView *contentWrapperView;
@property (strong, nonatomic) UIStackView *contentView;
@property (strong, nonatomic) JSDateIndicatorView *selectedIndicatorView;
@property (strong, nonatomic) JSDateIndicatorView *todayIndicatorView;
@property (strong, nonatomic) NSMutableArray<JSDateComponentView*> *componentViews;

@property (readonly, copy) NSString *navigationBarTitle;

@property (strong, nonatomic) EKEventStore *eventStore;

@end

@implementation JSDateChooserView

#pragma mark - Initialized method

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.clipsToBounds = YES;

    /* Set visible viewport to one contains today by default */
    NSDate *todayDate = [NSDate date];
    NSDateComponents *comps = [JSDateUntils dateComponentsFromDate:todayDate];
    self->_visibleYear = comps.year;
    self->_visibleMonth = comps.month;

    [self defaultAppearanceSetting];
    [self createNavigationBar];
    [self createWeekendHeaderView];
    [self createContentWrapperView];
    [self createContentView];

    self.componentViews = [NSMutableArray array];
    [self makeUIElements];
}

#pragma mark - Setter method

- (void)setSigleRowMode:(BOOL)sigleRowMode {
    if (self->_sigleRowMode != sigleRowMode) {
        self->_sigleRowMode = sigleRowMode;
        [self updateCurrentVisibleRow];
    }
}

- (void)setSelectPassDateVisible:(BOOL)selectPassDateVisible {
    if (self->_selectPassDateVisible != selectPassDateVisible) {
        self->_selectPassDateVisible = selectPassDateVisible;
        [self configureContentView];
    }
}

- (void)setShowUserEvents:(BOOL)showUserEvents {
    if (showUserEvents && !self.eventStore && !self.showUserEvents) {
        self.eventStore = [[EKEventStore alloc] init];
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                self->_showUserEvents = showUserEvents;
                [self performSelectorOnMainThread:@selector(reloadViewAnimated:) withObject:@YES waitUntilDone:nil];
            }
        }];
    }
    else {
        self->_showUserEvents = showUserEvents;
        [self reloadViewAnimated:YES];
    }
}

- (void)setSeletedDate:(NSDate *)seletedDate {
    NSDateComponents *comps = [JSDateUntils dateComponentsFromDate:seletedDate];
    int64_t delayTime = 0;
    if (self->_visibleMonth != comps.month || self->_visibleYear != comps.year) {
        [self jumpToMonth:comps.month year:comps.year];
        delayTime = 400;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self componentDidTap:[self componentViewForDateComponents:comps]];
        [self updateCurrentVisibleRow];
    });
}

#pragma mark - Getter method

- (NSString *)navigationBarTitle {
    NSString *stringOfMonth = [JSDateUntils stringOfMonthInChinese:self->_visibleMonth];
    return [NSString stringWithFormat:@"%@ %lu", stringOfMonth, (unsigned long) self->_visibleYear];
}

#pragma mark - Custom views

- (void)defaultAppearanceSetting {

    /* Initialize default appearance settings. */
    self.weekdayHeaderTextColor = [UIColor colorWithRed:0.40f green:0.40f blue:0.40f alpha:1.0f];
    self.weekdayHeaderWeekendTextColor = [UIColor colorWithRed:0.75f green:0.25f blue:0.25f alpha:1.0f];
    self.componentTextColor = [UIColor darkGrayColor];
    self.highlightedComponentTextColor = [UIColor whiteColor];
    self.selectedIndicatorColor = [UIColor colorWithRed:0.74f green:0.18f blue:0.06f alpha:1.0f];
    self.todayIndicatorColor = [UIColor colorWithRed:0.93f green:0.93f blue:0.93f alpha:1.0f];
    self.indicatorRadius = 20.0f;
    self.blodPrimaryComponentText = YES;
    self.passDateTextColor = [UIColor colorWithRed:0.802 green:0.506 blue:1.000 alpha:1.000];
}

- (void)createNavigationBar {

    self.navigationBar = [[JSDateNavigationBar alloc] init];
    self.navigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.navigationBar.textLabel.text = self.navigationBarTitle;
    [self.navigationBar addTarget:self action:@selector(navigationBarButtonDidTap:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.navigationBar];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self addConstraints:@[top, width, centerX]];

    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.navigationBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f];
    [self.navigationBar addConstraint:height];
}

- (void)createWeekendHeaderView {

    self.weekHeaderView = [[UIStackView alloc] init];
    self.weekHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.weekHeaderView.axis = UILayoutConstraintAxisHorizontal;
    self.weekHeaderView.distribution = UIStackViewDistributionFillEqually;
    self.weekHeaderView.alignment = UIStackViewAlignmentCenter;
    [self addSubview:self.weekHeaderView];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.weekHeaderView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.navigationBar attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.weekHeaderView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-self.indicatorRadius / 2];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.weekHeaderView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self addConstraints:@[top, width, centerX]];

    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.weekHeaderView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:20.0f];
    [self.weekHeaderView addConstraint:height];
}

- (void)createContentWrapperView {

    self.contentWrapperView = [[UIView alloc] init];
    self.contentWrapperView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentWrapperView];

    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.contentWrapperView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.weekHeaderView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.contentWrapperView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-self.indicatorRadius / 2];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.contentWrapperView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0f constant:-self.indicatorRadius / 2];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.contentWrapperView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self addConstraints:@[top, bottom, width, centerX]];
}

- (void)createContentView {

    self.contentView = [[UIStackView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.axis = UILayoutConstraintAxisVertical;
    self.contentView.distribution = UIStackViewDistributionFillEqually;
    self.contentView.alignment = UIStackViewAlignmentFill;
    [self.contentWrapperView addSubview:self.contentView];

    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentWrapperView attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentWrapperView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentWrapperView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentWrapperView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self.contentWrapperView addConstraints:@[width, height, centerX, centerY]];
}

- (void)makeUIElements {

    // Make Indicator views:
    self.selectedIndicatorView = [[JSDateIndicatorView alloc] init];
    self.selectedIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectedIndicatorView.hidden = YES;
    self.todayIndicatorView = [[JSDateIndicatorView alloc] init];
    self.todayIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.todayIndicatorView.hidden = YES;
    [self.contentWrapperView insertSubview:self.todayIndicatorView belowSubview:self.contentView];
    [self.contentWrapperView insertSubview:self.selectedIndicatorView belowSubview:self.contentView];

    // Make weekday header view:
    for (int i = 1; i <= 7; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] init];
        [self.weekHeaderView addArrangedSubview:weekdayLabel];
    }

    // Make content view:
    __block int currentColumn = 0;
    __block UIStackView *currentRowView;

    void (^makeRow)() = ^{
        currentRowView = [[UIStackView alloc] init];
        currentRowView.axis = UILayoutConstraintAxisHorizontal;
        currentRowView.distribution = UIStackViewDistributionFillEqually;
        currentRowView.alignment = UIStackViewAlignmentFill;
    };

    void (^submitRowIfNecessary)() = ^{
        if (currentColumn >= 7) {
            [self.contentView addArrangedSubview:currentRowView];
            currentColumn = 0;
            makeRow();
        }
    };

    void (^submitCell)(UIView*) = ^(UIView *cellView) {
        [currentRowView addArrangedSubview:cellView];
        [self.componentViews addObject:(id) cellView];
        currentColumn += 1;
        submitRowIfNecessary();
    };

    makeRow();

    for (int i = 0; i < 42; i++) {
        JSDateComponentView *componentView = [[JSDateComponentView alloc] init];
        componentView.textLabel.textAlignment = NSTextAlignmentCenter;
        [componentView addTarget:self action:@selector(componentDidTap:) forControlEvents:UIControlEventTouchUpInside];
        submitCell(componentView);
    }
}

#pragma mark - Configure views

- (void)reloadViewAnimated:(BOOL)animated {

    [self configureIndicatorViews];
    [self configureWeekdayHeaderView];
    [self configureContentView];

    if (animated) {
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:nil];
    }
}


- (void)updateCurrentVisibleRow {
    [self.contentView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.sigleRowMode) {
            obj.hidden = self->_currentVisbleRow != idx;
            obj.alpha = obj.hidden ? 0 : 1;
        }
        else {
            obj.hidden = NO;
            obj.alpha = 1.0f;
        }
    }];

    self.todayIndicatorView.alpha = self.todayIndicatorView.attachingView.superview.hidden ? 0 : 1;
    self.selectedIndicatorView.alpha = self.selectedIndicatorView.attachingView.superview.hidden ? 0 : 1;
}

- (void)configureIndicatorViews {
    self.selectedIndicatorView.color = self.selectedIndicatorColor;
    self.todayIndicatorView.color = self.todayIndicatorColor;
}

- (void)configureWeekdayHeaderView {
    BOOL canUseLocalizedStrings = self.localizedStringsOfWeekday && self.localizedStringsOfWeekday.count == 7;

    [self.weekHeaderView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *weekdayLabel = (id) obj;
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.font = [UIFont systemFontOfSize:12];
        weekdayLabel.textColor = (idx == 0 || idx == 6) ? self.weekdayHeaderWeekendTextColor : self.weekdayHeaderTextColor;
        if (canUseLocalizedStrings) {
            weekdayLabel.text = self.localizedStringsOfWeekday[idx];
        }
        else {
            weekdayLabel.text = [JSDateUntils stringOfWeekdayInChinese:idx + 1];
        }
    }];
}

- (void)configureComponentView:(JSDateComponentView *)view withDay:(NSUInteger)day month:(NSUInteger)month year:(NSUInteger)year {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = day;
    comps.month = month;
    comps.year = year;

    if ([JSDateUntils isDateTodayWithDateComponents:comps]) {
        if (self.todayIndicatorView.hidden) {
            self.todayIndicatorView.hidden = NO;
            self.todayIndicatorView.transform = CGAffineTransformMakeScale(0, 0);
            [UIView animateWithDuration:0.3 animations:^{
                self.todayIndicatorView.transform = CGAffineTransformIdentity;
            }];
        }
        self.todayIndicatorView.attachingView = view;
        [self addConstraintToCenterIndicatorView:self.todayIndicatorView toView:view];
    }

    view.containingEvent = nil;
    if (self.showUserEvents) {
        [self->_eventsInVisibleMonth enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EKEvent *event = obj;
            if ([[JSDateUntils dateFromDateComponents:comps] isEqualToDate:event.startDate]) {
                view.containingEvent = event;
                *stop = YES;
                return;
            }
        }];
    }

    view.representedObject = comps;

    if (self.selectedIndicatorView && self.selectedIndicatorView.attachingView == view) {
        [view setSelected:YES];
    }
    else {
        [view setSelected:NO];
    }
    view.textColor = self.componentTextColor;
    view.highlightTextColor = self.highlightedComponentTextColor;
    view.textLabel.alpha = self->_visibleMonth == month ? 1.0 : 0.5;
    if (!self.selectPassDateVisible) {
        view.textLabel.textColor = [JSDateUntils isDatePassWithDateComponents:comps] ? self.passDateTextColor : self.componentTextColor;
    }
    if (self->_visibleMonth == month && self.blodPrimaryComponentText) {
        view.textLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    else {
        view.textLabel.font = [UIFont systemFontOfSize:16];
    }
    view.textLabel.text = [NSString stringWithFormat:@"%d", (int) day];
}

- (void)configureContentView {
    NSUInteger pointer = 0;

    NSUInteger totalDays = [JSDateUntils daysInMonth:self->_visibleMonth ofYear:self->_visibleYear];
    NSUInteger paddingDays = [JSDateUntils firstWeekdayInMonth:self->_visibleMonth ofYear:self->_visibleYear] - 1;

    // Handle user events displaying.
    if (self.showUserEvents) {
        NSDateComponents *startComps = [[NSDateComponents alloc] init];
        startComps.year = self->_visibleYear;
        startComps.month = self->_visibleMonth;
        startComps.day = 1;

        NSDateComponents *endComps = [[NSDateComponents alloc] init];
        endComps.year = self->_visibleYear;
        endComps.month = self->_visibleMonth;
        endComps.day = totalDays;

        NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:[JSDateUntils dateFromDateComponents:startComps]
                                                                          endDate:[JSDateUntils dateFromDateComponents:endComps]
                                                                        calendars:nil];
        self->_eventsInVisibleMonth = [self.eventStore eventsMatchingPredicate:predicate];
    }
    else {
        self->_eventsInVisibleMonth = nil;
    }

    // Make padding days.
    NSUInteger paddingYear = self->_visibleMonth == 1 ? self->_visibleYear - 1 : self->_visibleYear;
    NSUInteger paddingMonth = self->_visibleMonth == 1 ? 12 : self->_visibleMonth - 1;
    NSUInteger totalDaysInLastMonth = [JSDateUntils daysInMonth:paddingMonth ofYear:paddingYear];

    for (int j = (int) paddingDays - 1; j >= 0; j--) {
        [self configureComponentView:self.componentViews[pointer++] withDay:totalDaysInLastMonth - j month:paddingMonth year:paddingYear];
    }

    // Make days in current month.
    for (int j = 0; j < totalDays; j++) {
        [self configureComponentView:self.componentViews[pointer++] withDay:j + 1 month:self->_visibleMonth year:self->_visibleYear];
    }

    // Make days in next month to fill the remain cells.
    NSUInteger reserveYear = self->_visibleMonth == 12 ? self->_visibleYear + 1 : self->_visibleYear;
    NSUInteger reserveMonth = self->_visibleMonth == 12 ? 1 : self->_visibleMonth + 1;

    for (int j = 0; self.componentViews.count - pointer > 0; j++) {
        [self configureComponentView:self.componentViews[pointer++] withDay:j + 1 month:reserveMonth year:reserveYear];
    }
}

- (void)addConstraintToCenterIndicatorView:(UIView *)view toView:(UIView *)toView {
    [[self.contentWrapperView.constraints copy] enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.firstItem == view) {
            [self.contentWrapperView removeConstraint:obj];
        }
    }];

    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:toView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self.contentWrapperView addConstraints:@[centerX, centerY]];

    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.indicatorRadius * 2];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.indicatorRadius * 2];
    [view addConstraints:@[width, height]];
}

#pragma mark - Actions

- (void)navigationBarButtonDidTap:(id)sender {
    switch (self.navigationBar.lastCommand) {
        case JSDateNavigationBarCommandPrevious: {
            [self jumpToPreviousMonth];
            break;
        }
        case JSDateNavigationBarCommandNext: {
            [self jumpToNextMonth];
            break;
        }
        default:
            break;
    }
}

- (void)componentDidTap:(JSDateComponentView *)sender {
    NSDateComponents *comps = sender.representedObject;

    if (comps.year != self->_visibleYear || comps.month != self->_visibleMonth) {
        [self jumpToMonth:comps.month year:comps.year];
        return;
    }

    if (!self.selectPassDateVisible && [JSDateUntils isDatePassWithDateComponents:comps]) {
        return;
    }

    if (self.selectedIndicatorView.hidden) {
        self.selectedIndicatorView.hidden = NO;
        self.selectedIndicatorView.transform = CGAffineTransformMakeScale(0, 0);
        self.selectedIndicatorView.attachingView = sender;
        [self addConstraintToCenterIndicatorView:self.selectedIndicatorView toView:sender];

        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:kNilOptions animations:^{
            self.selectedIndicatorView.transform = CGAffineTransformIdentity;
            [sender setSelected:YES];
        } completion:nil];
    }
    else {
        [self addConstraintToCenterIndicatorView:self.selectedIndicatorView toView:sender];

        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:kNilOptions animations:^{
            [self.contentWrapperView layoutIfNeeded];

            [((JSDateComponentView *) self.selectedIndicatorView.attachingView) setSelected:NO];
            [sender setSelected:YES];
        } completion:nil];

        self.selectedIndicatorView.attachingView = sender;
    }
    self->_selectedDate = [JSDateUntils dateFromDateComponents:comps];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (JSDateComponentView *)componentViewForDateComponents:(NSDateComponents *)comps {
    __block JSDateComponentView *view = nil;
    [self.componentViews enumerateObjectsUsingBlock:^(JSDateComponentView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDateComponents *_comps = obj.representedObject;
        if (comps.day == _comps.day && comps.month == _comps.month && comps.year == _comps.year) {
            view = obj;
            *stop = YES;
        }
    }];
    return view;
}

- (void)jumpToPreviousMonth {
    if (self.sigleRowMode) {
        if (self->_currentVisbleRow > 0) {
            self->_currentVisbleRow -= 1;
            [UIView transitionWithView:self.contentWrapperView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromBottom animations:nil completion:nil];
            [self updateCurrentVisibleRow];

            return;
        }
        else {
            self->_currentVisbleRow = 5;
        }
    }

    NSUInteger prevMonth;
    NSUInteger prevYear;

    if (self->_visibleMonth <= 1) {
        prevMonth = 12;
        prevYear = self->_visibleYear - 1;
    }
    else {
        prevMonth = self->_visibleMonth - 1;
        prevYear = self->_visibleYear;
    }
    [self jumpToMonth:prevMonth year:prevYear];
    if (self.sigleRowMode) {
        [self updateCurrentVisibleRow];
    }
}

- (void)jumpToNextMonth {
    if (self.sigleRowMode) {
        if (self->_currentVisbleRow < 5) {
            self->_currentVisbleRow += 1;
            [UIView transitionWithView:self.contentWrapperView duration:0.4 options:UIViewAnimationOptionTransitionFlipFromTop animations:nil completion:nil];
            [self updateCurrentVisibleRow];

            return;
        }
        else {
            self->_currentVisbleRow = 0;
        }
    }

    NSUInteger nextMonth;
    NSUInteger nextYear;

    if (self->_visibleMonth >= 12) {
        nextMonth = 1;
        nextYear = self->_visibleYear + 1;
    }
    else {
        nextMonth = self->_visibleMonth + 1;
        nextYear = self->_visibleYear;
    }
    [self jumpToMonth:nextMonth year:nextYear];
    if (self.sigleRowMode) {
        [self updateCurrentVisibleRow];
    }
}

- (void)jumpToMonth:(NSUInteger)month year:(NSUInteger)year {
    BOOL direction;
    if (self->_visibleYear == year) {
        direction = month > self->_visibleMonth;
    }
    else {
        direction = year > self->_visibleYear;
    }

    self->_visibleMonth = month;
    self->_visibleYear = year;
    self->_selectedDate = nil;

    // Deal with indicator views.
    self.todayIndicatorView.hidden = YES;
    self.todayIndicatorView.attachingView = nil;
    self.selectedIndicatorView.attachingView = nil;

    [UIView transitionWithView:self.navigationBar.textLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.navigationBar.textLabel.text = self.navigationBarTitle;
    } completion:nil];

    UIView *snapshotView = [self.contentWrapperView snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = self.contentWrapperView.frame;
    [self addSubview:snapshotView];

    [self configureContentView];

    self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.contentView.frame) / 3 * (direction ? 1 : -1));
    self.contentView.alpha = 0;

    [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.72 initialSpringVelocity:0 options:kNilOptions animations:^{
        snapshotView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight(self.contentView.frame) / 2 * (direction ? 1 : -1));
        snapshotView.alpha = 0;

        self.selectedIndicatorView.transform = CGAffineTransformMakeScale(0, 0);

        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
        [snapshotView removeFromSuperview];

        if (!self.selectedDate) {
            self.selectedIndicatorView.hidden = YES;
        }
    }];
}

#pragma mark -

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    [self reloadViewAnimated:NO];
}

@end
