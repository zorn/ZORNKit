#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ZORNCoreDataTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;

// Allows the user to assign a predicate that will be used during the creation of the main FRC. Due note, the setter here will nil out the FRC, so you should really only assign a predicate here before the FRC is being asked for during display.
@property (nonatomic, strong) NSPredicate *fetchedResultsControllerPredicate;

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;

// sometime a managedObjectContext might be swapped out during the runtime as we load a new readonly store. Using this method you can reset the FCRs so they will be rebuilt when needed.
- (void)resetFetchResultsController;

@end
