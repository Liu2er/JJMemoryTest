//
//  ViewController.m
//  JJMemoryTest
//
//  Created by Liu on 2019/1/11.
//  Copyright © 2019年 Liu. All rights reserved.
//

#import "ViewController.h"
#import <sys/types.h>
#import <sys/sysctl.h>

#define CRASH_MEMORY_FILE_NAME @"CrashMemory.dat"
#define MEMORY_WARNINGS_FILE_NAME @"_memoryWarnings.dat"

@interface ViewController () {
    
    NSTimer *_timer;
    
    int _allocatedMB;
    Byte *_p[10000];
    uint64_t _physicalMemorySize;
    uint64_t _userMemorySize;
    
    NSMutableArray *_infoLabels;
    NSMutableArray *_memoryWarnings;
    
    BOOL _initialLayoutFinished;
    BOOL _firstMemoryWarningReceived;
}

@property (weak, nonatomic) IBOutlet UIView *progressBarBG;
@property (weak, nonatomic) IBOutlet UIView *alocatedMemoryBar;
@property (weak, nonatomic) IBOutlet UIView *kernelMemoryBar;
@property (weak, nonatomic) IBOutlet UILabel *userMemoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalMemoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation ViewController

#pragma mark - Helpers

- (void)refreshUI {
    uint64_t physicalMemorySizeMB = _physicalMemorySize / 1048576;
    uint64_t userMemorySizeMB = _userMemorySize / 1048576;
    
    self.userMemoryLabel.text = [NSString stringWithFormat:@"User Memory %llu MB -", userMemorySizeMB];
    self.totalMemoryLabel.text = [NSString stringWithFormat:@"Total Memory %llu MB -", physicalMemorySizeMB];
    
    CGRect rect;
    
    CGFloat userMemoryProgressLength = self.progressBarBG.bounds.size.height *  (userMemorySizeMB / (float)physicalMemorySizeMB);
    
    rect = self.userMemoryLabel.frame;
    rect.origin.y = roundf((self.progressBarBG.bounds.size.height - userMemoryProgressLength) - self.userMemoryLabel.bounds.size.height * 0.5f + self.progressBarBG.frame.origin.y - 3);
    self.userMemoryLabel.frame = rect;
    
    rect = self.kernelMemoryBar.frame;
    rect.size.height = roundf(self.progressBarBG.bounds.size.height - userMemoryProgressLength);
    self.kernelMemoryBar.frame = rect;
    
    rect = self.alocatedMemoryBar.frame;
    rect.size.height = roundf(self.progressBarBG.bounds.size.height * (_allocatedMB / (float)physicalMemorySizeMB));
    rect.origin.y = self.progressBarBG.bounds.size.height - rect.size.height;
    self.alocatedMemoryBar.frame = rect;
}

- (void)refreshMemoryInfo {
    // Get memory info
    int mib[2];
    size_t length;
    mib[0] = CTL_HW;
    
    mib[1] = HW_MEMSIZE;
    length = sizeof(int64_t);
    sysctl(mib, 2, &_physicalMemorySize, &length, NULL, 0);
    
    mib[1] = HW_USERMEM;
    length = sizeof(int64_t);
    sysctl(mib, 2, &_userMemorySize, &length, NULL, 0);
}

- (void)allocateMemory {
    _p[_allocatedMB] = malloc(1048576);
    memset(_p[_allocatedMB], 0, 1048576);
    _allocatedMB += 1;
    
    [self refreshMemoryInfo];
    [self refreshUI];
    
    if (_firstMemoryWarningReceived) {
        [[NSUserDefaults standardUserDefaults] setInteger:_allocatedMB forKey:CRASH_MEMORY_FILE_NAME];
    }
}

- (void)clearAll {
    for (int i = 0; i < _allocatedMB; i++) {
        free(_p[i]);
    }
    
    _allocatedMB = 0;
    
    [_infoLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_infoLabels removeAllObjects];
    
    [_memoryWarnings removeAllObjects];
}

- (void)addLabelAtMemoryProgress:(int)memory text:(NSString*)text color:(UIColor*)color {
    CGFloat length = self.progressBarBG.bounds.size.height * (1.0f - memory / (float)(_physicalMemorySize / 1048576));
    
    CGRect rect;
    rect.origin.x = 20;
    rect.size.width = self.progressBarBG.frame.origin.x - rect.origin.x - 8;
    rect.size.height = 20;
    rect.origin.y = roundf(self.progressBarBG.frame.origin.y + length - rect.size.height * 0.5f);
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.textAlignment = NSTextAlignmentRight;
    label.text = [NSString stringWithFormat:@"%@ %d MB -", text, memory];
    label.font = self.totalMemoryLabel.font;
    label.textColor = color;
    
    [_infoLabels addObject:label];
    [self.view addSubview:label];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _infoLabels = [[NSMutableArray alloc] init];
    _memoryWarnings = [[NSMutableArray alloc] init];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!_initialLayoutFinished) {
        
        [self refreshMemoryInfo];
        [self refreshUI];
        
        NSInteger crashMemory = [[NSUserDefaults standardUserDefaults] integerForKey:CRASH_MEMORY_FILE_NAME];
        if (crashMemory > 0) {
            [self addLabelAtMemoryProgress:(int)crashMemory text:@"Crash" color:[UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0]];
        }
        
        NSArray *last_memoryWarnings = [[NSUserDefaults standardUserDefaults] objectForKey:MEMORY_WARNINGS_FILE_NAME];
        if (last_memoryWarnings) {
            for (NSNumber *number in last_memoryWarnings) {
                [self addLabelAtMemoryProgress:[number intValue] text:@"Memory Warning" color:[UIColor colorWithWhite:0.6 alpha:1.0]];
            }
        }
        
        _initialLayoutFinished = YES;
    }
}

- (void)dealloc {
    [_timer invalidate];
    [self clearAll];
    
    _infoLabels = nil;
    _memoryWarnings = nil;
    
    _initialLayoutFinished = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    _firstMemoryWarningReceived = YES;
    
    [self addLabelAtMemoryProgress:_allocatedMB text:@"Memory Warning" color:[UIColor colorWithWhite:0.6 alpha:1.0]];
    
    [_memoryWarnings addObject:@(_allocatedMB)];
    [[NSUserDefaults standardUserDefaults] setObject:_memoryWarnings forKey:MEMORY_WARNINGS_FILE_NAME];
}

#pragma mark - Actions

- (IBAction)startButtonPressed:(id)sender {
    [self clearAll];
    
    _firstMemoryWarningReceived = NO;
    
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(allocateMemory) userInfo:nil repeats:YES];
}

@end
