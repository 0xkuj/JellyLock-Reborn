

#import "jellylock.h"

@implementation JellylockView
float origPos = 10;
int currentlySelected = 0;
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.app1 = [[NSString alloc] init];
    self.app2 = [[NSString alloc] init];
    self.app3 = [[NSString alloc] init];
    self.app4 = [[NSString alloc] init];
    self.app5 = [[NSString alloc] init];
    if (self) {
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews {
    UIColor *draggercolour = [self colorWithHexString:draggerColor alpha:1];
    UIColor *circlecolour = [self colorWithHexString:circlecolor alpha:1];
    self.blurView = [[UIView alloc] init];
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    self.blurView.backgroundColor = [UIColor clearColor];
    if (blurEnabled) {
        self.blurView =  [objc_getClass("MTMaterialView") materialViewWithRecipe:6 configuration:1 initialWeighting:1];
    }
    
    self.blurView.frame = CGRectMake(0,-200,[[UIScreen mainScreen] bounds].size.width,500);
    [self.blurView setUserInteractionEnabled:NO];
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.blurView.bounds;
    
    if (blurEnabled) {
        l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor],(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8] CGColor],(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor],(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
        l.startPoint = CGPointMake(0.5, 0.0);
        l.endPoint = CGPointMake(0.5, 1.0);
        self.blurView.layer.mask = l;
    }
    
    self.blurView.hidden = YES;
    [self insertSubview:self.blurView atIndex:0];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.blurView.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:100],
        [self.blurView.centerXAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerXAnchor],
        [self.blurView.widthAnchor constraintEqualToConstant:[[UIScreen mainScreen] bounds].size.width],
        [self.blurView.heightAnchor constraintEqualToConstant:300],
    ]];
    
    self.jellycontainer = [self setupContainersWithRadius:0 isHidden:YES];
    [self addSubview:self.jellycontainer];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.jellycontainer.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:35],
        [self.jellycontainer.centerXAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerXAnchor],
        [self.jellycontainer.widthAnchor constraintEqualToConstant:[[UIScreen mainScreen] bounds].size.width],
        [self.jellycontainer.heightAnchor constraintEqualToConstant:280],
    ]];
    
    self.jellyBackDrop = [self setupContainersWithRadius:170 isHidden:YES];
    [self.jellycontainer insertSubview:self.jellyBackDrop atIndex:0];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.jellyBackDrop.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:120],
        [self.jellyBackDrop.centerXAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerXAnchor],
        [self.jellyBackDrop.widthAnchor constraintEqualToConstant:300],
        [self.jellyBackDrop.heightAnchor constraintEqualToConstant:350],
    ]];
    
    self.bigCircle = [self setupCircleWithRadius:160 
                                        borderColor:circlecolour 
                                        borderWidth:1.0f 
                                        shadowRadius:1.0
                                            isHidden:YES];
    [self.blurView insertSubview:self.bigCircle atIndex:0];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.bigCircle.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:120],
        [self.bigCircle.centerXAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerXAnchor],
        [self.bigCircle.widthAnchor constraintEqualToConstant:305],
        [self.bigCircle.heightAnchor constraintEqualToConstant:305],
    ]];
    
    self.returnJelly = [self setupContainersWithRadius:150 isHidden:NO];
    [self.jellyBackDrop insertSubview:self.returnJelly atIndex:2];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.returnJelly.bottomAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.bottomAnchor constant:100],
        [self.returnJelly.centerXAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerXAnchor],
        [self.returnJelly.widthAnchor constraintEqualToConstant:300],
        [self.returnJelly.heightAnchor constraintEqualToConstant:300],
    ]];

    self.jellyApps = [NSMutableArray array];
    // Since we have only 7 apps limit..
    for (int i = 0; i < 7; i++) {
        [self setupJellyAppsViewsAndConstraints:i];
    }

    if (leftshortcut != 0) {
        [self.jellyBackDrop insertSubview:self.jellyApps[5] atIndex:2];
    }

    self.Usercircle = [self setupCircleWithRadius:circleSize / 2
                                       borderColor:draggercolour
                                       borderWidth:1.5f 
                                      shadowRadius:1.0
                                        isHidden:NO];

    self.MoveCircleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self  action:@selector(movedCircle:)];
    [self.Usercircle addGestureRecognizer:_MoveCircleGesture];
    [self addSubview:self.Usercircle];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.Usercircle.bottomAnchor constraintEqualToAnchor:self.jellycontainer.bottomAnchor constant:-50],
        [self.Usercircle.centerXAnchor constraintEqualToAnchor:self.jellycontainer.centerXAnchor],
        [self.Usercircle.widthAnchor constraintEqualToConstant:circleSize],
        [self.Usercircle.heightAnchor constraintEqualToConstant:circleSize],
    ]];
}

- (UIView *)setupContainersWithRadius:(CGFloat)cornerRadius isHidden:(BOOL)isHidden {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.layer.cornerRadius = cornerRadius;
    view.hidden = isHidden;
    return view;
}

- (UIView *)setupCircleWithRadius:(CGFloat)cornerRadius borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth shadowRadius:(CGFloat)shadowRadius isHidden:(BOOL)isHidden {
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = [UIColor clearColor];
    view.layer.cornerRadius = cornerRadius;
    view.layer.borderColor = borderColor.CGColor;
    view.layer.borderWidth = borderWidth;
    view.layer.shadowColor = borderColor.CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = shadowRadius;
    view.layer.shadowOpacity = 1.0;
    view.hidden = isHidden;
    return view;
}

- (void)setupJellyAppsViewsAndConstraints:(int)index {
    NSArray *bottomConstants = @[@70, @95, @95, @155, @155, @230, @230];
    NSArray *centerXConstants = @[@0, @80, @-80, @135, @-135, @145, @-145];
    UIView *jellyApp = [[UIView alloc] init];
    jellyApp.backgroundColor = [UIColor clearColor];
    jellyApp.layer.cornerRadius = 0;
    jellyApp.translatesAutoresizingMaskIntoConstraints = NO;
    jellyApp.layer.masksToBounds = YES;

    [self.jellyApps addObject:jellyApp];
    [self.jellyBackDrop insertSubview:[self.jellyApps lastObject] atIndex:2];   

    CGFloat bottomConstant = [bottomConstants[index] floatValue];
    CGFloat centerXConstant = [centerXConstants[index] floatValue]; 
    [NSLayoutConstraint activateConstraints:@[
        [jellyApp.bottomAnchor constraintEqualToAnchor:self.jellyBackDrop.topAnchor constant:bottomConstant],
        [jellyApp.centerXAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.centerXAnchor constant:centerXConstant],
        [jellyApp.widthAnchor constraintEqualToConstant:52],
        [jellyApp.heightAnchor constraintEqualToConstant:52],
    ]];
}

- (void)movedCircle:(UIPanGestureRecognizer*)recognizer {
    UIColor *draggercolour = [self colorWithHexString:draggerColor alpha:1];
    if(self.jellycontainer.hidden == YES){
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)hideCSQuickactionsFromJelly, nil, nil, true);
    }
    self.jellycontainer.hidden = NO;
    self.blurView.hidden = NO;
    UIButton *Circle = (UIButton *)recognizer.view;
    CGPoint translation = [recognizer translationInView:self.jellycontainer];
    float xPosition = Circle.center.x;
    float yPosition = Circle.center.y;
    float buttonCenter = Circle.frame.size.height/2;
    
    if (xPosition < buttonCenter) {
        xPosition = buttonCenter;
    } else if (xPosition > self.jellycontainer.frame.size.width - buttonCenter) {
        xPosition = self.jellycontainer.frame.size.width - buttonCenter;
    }
    
    if (yPosition < buttonCenter) {
        yPosition = buttonCenter;
    } else if (yPosition > self.jellycontainer.frame.size.height - buttonCenter) {
        yPosition = self.jellycontainer.frame.size.height - buttonCenter;
    }
    
    Circle.center = CGPointMake(xPosition + translation.x, yPosition + translation.y);
    [recognizer setTranslation:CGPointZero inView:self.jellycontainer];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.jellyBackDrop.hidden = NO;
        self.bigCircle.hidden = NO;
        origPos = Circle.center.y;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        //play with that..
        CGRect stam = CGRectMake(Circle.frame.origin.x, Circle.frame.origin.y, Circle.frame.size.width-30, Circle.frame.size.height);
        CGPoint adaptDistanceToCircleFromApp = CGPointMake(self.returnJelly.center.x+70, self.returnJelly.center.y);
        if (CGRectContainsPoint(Circle.frame, adaptDistanceToCircleFromApp)) {
            Circle.hidden = NO;
            currentlySelected = 0;
            self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
        }
        
        if (CGRectIntersectsRect(stam,self.jellyApps[0].frame)) {
            self.jellyApps[1].layer.cornerRadius = 0;
            self.jellyApps[2].layer.cornerRadius = 0;
            self.jellyApps[3].layer.cornerRadius = 0;
            self.jellyApps[4].layer.cornerRadius = 0;
            self.jellyApps[5].layer.cornerRadius = 26;
            if (currentlySelected != 1) {
                currentlySelected = 1;
                self.jellyApps[0].layer.cornerRadius = 26;
                AudioServicesPlaySystemSound(1520);
            }
            Circle.hidden = YES;
            
            self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[0].layer.borderColor = draggercolour.CGColor;
            self.jellyApps[0].layer.borderWidth = 2.5f; //make border 1px thick
            self.jellyApps[0].layer.shadowColor = draggercolour.CGColor;
            self.jellyApps[0].layer.shadowOffset = CGSizeZero;
            self.jellyApps[0].layer.shadowRadius = 10.0;
            self.jellyApps[0].layer.shadowOpacity = 1.0;
        }
        
        if (CGRectIntersectsRect(stam,self.jellyApps[1].frame))
        {
            self.jellyApps[0].layer.cornerRadius = 0;
            self.jellyApps[2].layer.cornerRadius = 0;
            self.jellyApps[3].layer.cornerRadius = 0;
            self.jellyApps[4].layer.cornerRadius = 0;
            self.jellyApps[5].layer.cornerRadius = 26;
            if(currentlySelected != 2){
                currentlySelected = 2;
                self.jellyApps[1].layer.cornerRadius = 26;
                AudioServicesPlaySystemSound(1520);
            }
            
            Circle.hidden = YES;
            self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[1].layer.borderColor = draggercolour.CGColor;
            self.jellyApps[1].layer.borderWidth = 2.5f; //make border 1px thick
            self.jellyApps[1].layer.shadowColor = draggercolour.CGColor;
            self.jellyApps[1].layer.shadowOffset = CGSizeZero;
            self.jellyApps[1].layer.shadowRadius = 10.0;
            self.jellyApps[1].layer.shadowOpacity = 1.0;
        }
        
        if (CGRectIntersectsRect(stam,self.jellyApps[2].frame)) {
            self.jellyApps[0].layer.cornerRadius = 0;
            self.jellyApps[1].layer.cornerRadius = 0;
            self.jellyApps[3].layer.cornerRadius = 0;
            self.jellyApps[4].layer.cornerRadius = 0;
            self.jellyApps[5].layer.cornerRadius = 26;
            
            if (currentlySelected != 3) {
                currentlySelected = 3;
                self.jellyApps[2].layer.cornerRadius = 26;
                AudioServicesPlaySystemSound(1520);
            }
            Circle.hidden = YES;
            
            self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[2].layer.borderColor = draggercolour.CGColor;
            self.jellyApps[2].layer.borderWidth = 2.5f; //make border 1px thick
            self.jellyApps[2].layer.shadowColor = draggercolour.CGColor;
            self.jellyApps[2].layer.shadowOffset = CGSizeZero;
            self.jellyApps[2].layer.shadowRadius = 100.0;
            self.jellyApps[2].layer.shadowOpacity = 1.0;
        }
        
        if (CGRectIntersectsRect(stam,self.jellyApps[3].frame)) {
            self.jellyApps[0].layer.cornerRadius = 0;
            self.jellyApps[1].layer.cornerRadius = 0;
            self.jellyApps[2].layer.cornerRadius = 0;
            self.jellyApps[4].layer.cornerRadius = 0;
            self.jellyApps[5].layer.cornerRadius = 25;
            
            if (currentlySelected != 4) {
                currentlySelected = 4;
                self.jellyApps[3].layer.cornerRadius = 26;
                AudioServicesPlaySystemSound(1520);
            }
            
            self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
            Circle.hidden = YES;
            self.jellyApps[3].layer.borderColor = draggercolour.CGColor;
            self.jellyApps[3].layer.borderWidth = 2.5f; //make border 1px thick
            self.jellyApps[3].layer.shadowColor = draggercolour.CGColor;
            self.jellyApps[3].layer.shadowOffset = CGSizeZero;
            self.jellyApps[3].layer.shadowRadius = 100.0;
            self.jellyApps[3].layer.shadowOpacity = 1.0;
        }
        
        if (CGRectIntersectsRect(stam,self.jellyApps[4].frame)) {
            
            self.jellyApps[0].layer.cornerRadius = 0;
            self.jellyApps[1].layer.cornerRadius = 0;
            self.jellyApps[2].layer.cornerRadius = 0;
            self.jellyApps[3].layer.cornerRadius = 0;
            self.jellyApps[5].layer.cornerRadius = 26;
            if (currentlySelected != 5) {
                currentlySelected = 5;
                self.jellyApps[4].layer.cornerRadius = 26;
                AudioServicesPlaySystemSound(1520);
            }
            
            self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
            Circle.hidden = YES;
            self.jellyApps[4].layer.borderColor = draggercolour.CGColor;
            self.jellyApps[4].layer.borderWidth = 2.5f; //make border 1px thick
            self.jellyApps[4].layer.shadowColor = draggercolour.CGColor;
            self.jellyApps[4].layer.shadowOffset = CGSizeZero;
            self.jellyApps[4].layer.shadowRadius = 100.0;
            self.jellyApps[4].layer.shadowOpacity = 1.0;
        }
        
        if (CGRectIntersectsRect(stam,self.jellyApps[5].frame)) {
            self.jellyApps[0].layer.cornerRadius = 0;
            self.jellyApps[1].layer.cornerRadius = 0;
            self.jellyApps[2].layer.cornerRadius = 0;
            self.jellyApps[3].layer.cornerRadius = 0;
            self.jellyApps[4].layer.cornerRadius = 0;
            if (currentlySelected != 6) {
                currentlySelected = 6;
                self.jellyApps[5].layer.cornerRadius = 26;
                AudioServicesPlaySystemSound(1520);
            }
            
            self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
            Circle.hidden = YES;
            self.jellyApps[5].layer.borderColor = draggercolour.CGColor;
            self.jellyApps[5].layer.borderWidth = 2.5f; //make border 1px thick
            self.jellyApps[5].layer.shadowColor = draggercolour.CGColor;
            self.jellyApps[5].layer.shadowOffset = CGSizeZero;
            self.jellyApps[5].layer.shadowRadius = 100.0;
            self.jellyApps[5].layer.shadowOpacity = 1.0;
        }
        
        if (CGRectIntersectsRect(stam,self.jellyApps[6].frame)) {
            self.jellyApps[0].layer.cornerRadius = 0;
            self.jellyApps[1].layer.cornerRadius = 0;
            self.jellyApps[2].layer.cornerRadius = 0;
            self.jellyApps[3].layer.cornerRadius = 0;
            self.jellyApps[4].layer.cornerRadius = 0;
            if(currentlySelected != 7){
                currentlySelected = 7;
                self.jellyApps[6].layer.cornerRadius = 26;
                AudioServicesPlaySystemSound(1520);
            }
            
            self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
            self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
            self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
            Circle.hidden = YES;
            self.jellyApps[6].layer.borderColor = draggercolour.CGColor;
            self.jellyApps[6].layer.borderWidth = 2.5f; //make border 1px thick
            self.jellyApps[6].layer.shadowColor = draggercolour.CGColor;
            self.jellyApps[6].layer.shadowOffset = CGSizeZero;
            self.jellyApps[6].layer.shadowRadius = 100.0;
            self.jellyApps[6].layer.shadowOpacity = 1.0;
        }
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        self.jellycontainer.hidden = YES;
        self.blurView.hidden = YES;
        self.jellyApps[0].layer.cornerRadius = 0;
        self.jellyApps[1].layer.cornerRadius = 0;
        self.jellyApps[2].layer.cornerRadius = 0;
        self.jellyApps[3].layer.cornerRadius = 0;
        self.jellyApps[4].layer.cornerRadius = 0;
        self.jellyApps[5].layer.cornerRadius = 26;
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)showCSQuickactionsFromJelly, nil, nil, true);
        if (currentlySelected == 1){
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:self.app1 suspended:FALSE];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
            openAppBundleid = self.app1;
            
        }
        
        if (currentlySelected == 2){
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:self.app2 suspended:FALSE];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
            openAppBundleid = self.app2;
        }
        
        if (currentlySelected == 3){
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:self.app3 suspended:FALSE];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
            openAppBundleid = self.app3;
        }
        
        if (currentlySelected == 4){
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:self.app4 suspended:FALSE];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
            openAppBundleid = self.app4;
        }
        
        if (currentlySelected == 5){
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:self.app5 suspended:FALSE];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
            openAppBundleid = self.app5;
        }
        
        if (currentlySelected == 6){
            switch ((int)leftshortcut) {
                case 1:
                    if([[objc_getClass("SBUIFlashlightController") sharedInstance] level] == 0){
                        [[objc_getClass("SBUIFlashlightController") sharedInstance] setLevel:4];
                    }else{
                        [[objc_getClass("SBUIFlashlightController") sharedInstance] setLevel:0];
                    }
                    break;
                case 2:
                    [[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.camera" suspended:FALSE];
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
                    openAppBundleid = @"com.apple.camera";
                    break;
                case 3:
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
                    break;
                case 4:
                    MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
                    break;
                case 5:
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)StartSentinel, nil, nil, true);
                    break;
            }
        }
        
        if (currentlySelected == 7) {
            switch ((int)rightshortcut) {
                case 1:
                    if([[objc_getClass("SBUIFlashlightController") sharedInstance] level] == 0){
                        [[objc_getClass("SBUIFlashlightController") sharedInstance] setLevel:4];
                    }else{
                        [[objc_getClass("SBUIFlashlightController") sharedInstance] setLevel:0];
                    }
                    break;
                case 2:
                    [[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.camera" suspended:FALSE];
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
                    openAppBundleid = @"com.apple.camera";
                    break;
                case 3:
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)OpenAppFromJelly, nil, nil, true);
                    break;
                case 4:
                    MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
                    break;
                case 5:
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)StartSentinel, nil, nil, true);
                    break;
            }
        }
        
        self.jellyBackDrop.hidden = YES;
        self.bigCircle.hidden = YES;
        currentlySelected = 0;
        Circle.hidden = NO;
        self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
        self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
        self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
        self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
        self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
        self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
        self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
        self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
        self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
        self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
        self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
        self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
        self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
        self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
        
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.Usercircle.center = CGPointMake(self.frame.size.width / 2,
                                                 self.jellycontainer.frame.size.height / 1.5);
        }
                         completion:nil];
    }
}

- (void)resetJelly {
    
    UIColor *draggercolour = [self colorWithHexString:draggerColor alpha:1];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)showCSQuickactionsFromJelly, nil, nil, true);
    self.jellycontainer.hidden = YES;
    self.jellyBackDrop.hidden = YES;
    self.blurView.hidden = YES;
    self.bigCircle.hidden = YES;
    currentlySelected = 0;
    self.Usercircle.hidden = NO;
    self.jellyApps[0].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
    self.jellyApps[0].layer.shadowColor = [UIColor clearColor].CGColor;
    self.jellyApps[1].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
    self.jellyApps[1].layer.shadowColor = [UIColor clearColor].CGColor;
    self.jellyApps[2].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
    self.jellyApps[2].layer.shadowColor = [UIColor clearColor].CGColor;
    self.jellyApps[3].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
    self.jellyApps[3].layer.shadowColor = [UIColor clearColor].CGColor;
    self.jellyApps[4].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
    self.jellyApps[4].layer.shadowColor = [UIColor clearColor].CGColor;
    self.jellyApps[5].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
    self.jellyApps[5].layer.shadowColor = [UIColor clearColor].CGColor;
    self.jellyApps[6].layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.0f].CGColor;
    self.jellyApps[6].layer.shadowColor = [UIColor clearColor].CGColor;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.Usercircle.center = CGPointMake(self.frame.size.width / 2,
                                             self.jellycontainer.frame.size.height / 1.5);
    }
                     completion:nil];
}

-(void)loadIcons {
    UIColor *draggercolour = [self colorWithHexString:draggerColor alpha:1];
    self.Usercircle.layer.borderColor = draggercolour.CGColor;
    self.Usercircle.layer.borderWidth = 1.5f; //make border 1px thick
    self.Usercircle.layer.shadowColor = draggercolour.CGColor;
    self.Usercircle.layer.shadowOffset = CGSizeZero;
    self.Usercircle.layer.shadowRadius = 1.0;
    self.Usercircle.layer.shadowOpacity = 1.0;
    self.jellyApps[0].layer.contents = (__bridge id) [[UIImage _applicationIconImageForBundleIdentifier:self.app1
                                                                                              format:2 scale:3] CGImage];
    self.jellyApps[1].layer.contents = (__bridge id) [[UIImage _applicationIconImageForBundleIdentifier:self.app2
                                                                                              format:2 scale:3] CGImage];
    self.jellyApps[2].layer.contents = (__bridge id) [[UIImage _applicationIconImageForBundleIdentifier:self.app3
                                                                                              format:2 scale:3] CGImage];
    self.jellyApps[3].layer.contents = (__bridge id) [[UIImage _applicationIconImageForBundleIdentifier:self.app4
                                                                                              format:2 scale:3] CGImage];
    self.jellyApps[4].layer.contents = (__bridge id) [[UIImage _applicationIconImageForBundleIdentifier:self.app5
                                                                                              format:2 scale:3] CGImage];
    
    if([self.app5 length] == 0){
        [self.jellyApps[4] removeFromSuperview];
    }
    
    if([self.app4 length] == 0){
        [self.jellyApps[3] removeFromSuperview];
    }
    
    if([self.app3 length] == 0){
        [self.jellyApps[2] removeFromSuperview];
    }
    
    if([self.app2 length] == 0){
        [self.jellyApps[1] removeFromSuperview];
    }
    
    if([self.app1 length] == 0){
        [self.jellyApps[0] removeFromSuperview];
    }
    
    switch ((int)leftshortcut) {
        case 1:
            self.jellyApps[5].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/flashlight.png"] CGImage];
            break;
        case 2:
            self.jellyApps[5].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/camera.png"] CGImage];
            break;
        case 3:
            self.jellyApps[5].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/JellyLockLock@2x.png"] CGImage];
            break;
        case 4:
            self.jellyApps[5].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/playpause.png"] CGImage];
            break;
        case 5:
            self.jellyApps[5].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/sentinel@2x.png"] CGImage];
            break;
    }
    
    switch ((int)rightshortcut) {
        case 1 :
            self.jellyApps[6].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/flashlight.png"] CGImage];
            break;
        case 2 :
            self.jellyApps[6].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/camera.png"] CGImage];
            break;
        case 3 :
            self.jellyApps[6].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/JellyLockLock@2x.png"] CGImage];
            break;
        case 4 :
            self.jellyApps[6].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/playpause.png"] CGImage];
            break;
        case 5 :
            self.jellyApps[6].layer.contents = (__bridge id) [[UIImage imageWithContentsOfFile:@"Library/Application Support/JellyLockReborn/sentinel@2x.png"] CGImage];
            break;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

- (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range {
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha_range];
}
@end
