//
//  WCViewController.m
//  WeatherCast
//
//  Created by Jonyzfu on 8/3/14.
//  Copyright (c) 2014 Jonyzfu. All rights reserved.
//

#import "WCViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WCManager.h"

@interface WCViewController ()

@property(nonatomic, strong) UIImageView *backgroundImageView;
@property(nonatomic, strong) UIImageView *blurredImageView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, assign) CGFloat screenHeight;
@property(nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property(nonatomic, strong) NSDateFormatter *dailyFormatter;

@end

@implementation WCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


// Placing them in -init you’ll ensure they’re initialized only once by your view controller.
- (id)init
{
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Get and store the screen height.
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    // Create a static image background and add it to the view.
    UIImage *background = [UIImage imageNamed:@"bg"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // Create a blurred background image using LBBlurredImage, and set the alpha to 0 initially so that backgroundImageView is visible at first.
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    // Create a tableview that will handle all the data presentation.
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    
    // Set the header of your table to be the same size of your screen.
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    
    // Create an inset (or padding) variable so that all your labels are evenly spaced and centered.
    CGFloat inset = 20;
    
    // Create and initialize the height variables for your various views.
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    // Create frames for your labels and icon view based on the constant and inset variables.
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    CGRect temperatureFrame = CGRectMake(inset,
                                  headerFrame.size.height - (temperatureHeight + hiloHeight),
                                  headerFrame.size.width - (2 * inset),
                                  temperatureHeight);
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    
    // Copy the icon frame, adjust it so the text has some room to expand, and move it to the right of the icon.
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    // Set the current-conditions view as your table header.
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // Build each required label to display weather data.
    // bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0º";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0º / 0º";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28];
    [header addSubview:hiloLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionLabel.backgroundColor = [UIColor clearColor];
    conditionLabel.textColor = [UIColor whiteColor];
    conditionLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
    [header addSubview:conditionLabel];
    
    // Add an image view for a weather icon.
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:iconView];
    
    
    // The returned value from the signal is assigned to the text key of the hiloLabel object.
    RAC(hiloLabel, text) = [[RACSignal combineLatest: @[
                            // Observe the high and low temperatures of the currentCondition key.
                            // Combine the signals and use the latest values for both.
                            RACObserve([WCManager sharedManager], currentCondition.tempHigh),
                            RACObserve([WCManager sharedManager], currentCondition.tempLow)]
                            
                            // Reduce the values from your combined signals into a single value.
                            reduce:^(NSNumber *hi, NSNumber *low) {
                                return [NSString stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
                            }]
                            // Deliver everything on the main thread.
                            deliverOn:RACScheduler.mainThreadScheduler];
    
    
    // Observes the currentCondition key on the WCManager singleton.
    [[RACObserve([WCManager sharedManager], currentCondition)
      // Delivers any changes on the main thread since you’re updating the UI.
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WCCondition *newCondition) {
         
         // Updates the text labels with weather data; using newCondition for the text and not the singleton.
         temperatureLabel.text = [NSString stringWithFormat:@"%.0fº", [[newCondition temperature] floatValue]];
         conditionLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         
         // Uses the mapped image file name to create an image and sets it as the icon for the view.
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    
    [[RACObserve([WCManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([WCManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    
    [[WCManager sharedManager] findCurrentLocation];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

// Pragma marks are a great way to help organize your code.
#pragma mark - UITableViewDataSource

// Your table view has two sections, one for hourly forecasts and one for daily.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


// The table view is set up with paging enabled and sticky-scrolling behavior would look odd in this context.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // The first section is for the hourly forecast.
    if (section == 0) {
        return MIN([[WCManager sharedManager].hourlyForecast count], 6) + 1;
    }
    
    // The next section is for daily forecasts.
    return MIN([[WCManager sharedManager].dailyForecast count], 6) + 1;
}


// This divides the screen height by the number of cells in each section so the total height of all cells equals the height of the screen.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Forecast cells shouldn’t be selectable.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        // The first row of each section is the header cell.
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        } else {
            // Get the hourly weather and configure the cell using custom configure methods.
            WCCondition *weather = [WCManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather: weather];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        } else {
            // Get the daily weather and configure the cell using another custom configure method.
            WCCondition *weather = [WCManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather: weather];
        }
    }
    return cell;
}

// Configures and adds text to the cell used as the section header.
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

// Formats the cell for an hourly forecast.
- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WCCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

// Formats the cell for a daily forecast.
- (void)configureDailyCell:(UITableViewCell *)cell weather:(WCCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",
                                 weather.tempHigh.floatValue,
                                 weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}




-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

#pragma mark - UIScrollViewDelegate

// The blur should fill in dynamically as you scroll past the first page of forecast.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get the height of the scroll view and the content offset.
    // Cap the offset at 0 so attempting to scroll past the start of the table won’t affect blurring.
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    
    // Divide the offset by the height with a maximum of 1 so that your offset is capped at 100%.
    CGFloat percent = MIN(position / height, 1.0);
    
    // Assign the resulting value to the blur image’s alpha property to change how much of the blurred image you’ll see as you scroll.
    self.blurredImageView.alpha = percent;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
