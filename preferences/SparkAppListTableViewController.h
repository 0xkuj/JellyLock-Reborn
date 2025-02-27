@interface SparkAppListTableViewController : UITableViewController
- (id)initWithIdentifier:(NSString*)identifier andKey:(NSString*)key;
- (void)addCustomExclusion:(NSString*)bundleIdentifier;
@property (nonatomic, retain) NSArray* appList;
@property (nonatomic, retain) NSString* preferencesIdentifier;
@property (nonatomic, retain) NSString* preferencesKey;
@property (nonatomic, retain) NSMutableArray* preferencesAppList;
@property (nonatomic, assign) BOOL showBundleIdentifierOnTap;
@property (nonatomic, assign) int maxEnabled;
@end