//
//  ViewController.m
//  JSDateChooserDemo
//
//  Created by sxq on 16/9/3.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import "ViewController.h"
#import "JSDateChooser.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet JSDateChooserView *dateChooserView;
@property (weak, nonatomic) IBOutlet UILabel *selectedDateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *sigleModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *selectModelSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *userEventSwitch;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateConstraint;

@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd"];

    self.selectedDateLabel.text = [self.formatter stringFromDate:[NSDate date]];

    self.sigleModeSwitch.on = self.dateChooserView.sigleRowMode;

    self.selectModelSwitch.on = self.dateChooserView.selectPassDateVisible;

    self.userEventSwitch.on = self.dateChooserView.showUserEvents;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)dateChooserValueDidChange:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.selectedDateLabel.text = [self.formatter stringFromDate:self.dateChooserView.selectedDate];
    }];
}

- (IBAction)sigleModeValueDidChange:(UISwitch *)sender {
    self.dateConstraint.constant = sender.on ? 100 : 300;
    [UIView animateWithDuration:0.25 animations:^{
        [self.dateChooserView layoutIfNeeded];
        self.dateChooserView.sigleRowMode = sender.on;
    } completion:^(BOOL finished) {

    }];
}

- (IBAction)selecteModeValueDidChange:(UISwitch *)sender {
    self.dateChooserView.selectPassDateVisible = sender.on;
}

- (IBAction)showUserEventsModeValueDidChange:(UISwitch *)sender {
    self.dateChooserView.showUserEvents = sender.on;
}

@end
