#import "ZORNCoreDataTableViewController.h"
#import "ZORNCoreDataStack.h"

@interface ZORNCoreDataTableViewController ()
{
    __strong NSFetchedResultsController *_fetchedResultsController;
    __strong NSFetchedResultsController *_searchFetchedResultsController;
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *searchFetchedResultsController;

// Techinally speaking there is no real reason for use to have create property. Once alloc/init-ed the searchDisplayController will be auto-assigned to: self.searchDisplayController per Apple's docs:
// http://developer.apple.com/library/ios/#documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html
// The problem is doing this programatically seems to have the effect that self.searchDisplayController isn't retaining things, so we'll have to. See bug:
// http://openradar.appspot.com/10254897
@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

@end

@implementation ZORNCoreDataTableViewController

- (void)loadView
{
    [super loadView];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)];
    searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tableView.tableHeaderView = searchBar;
    
    self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleZORNCoreDataStackStackIsComingDownNotification:) name:kZORNCoreDataStackStackIsComingDown object:nil];
    [notificationCenter addObserver:self selector:@selector(handleZORNCoreDataStackStackIsReadyNotification:) name:kZORNCoreDataStackStackIsReady object:nil];
}

- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:kZORNCoreDataStackStackIsComingDown object:nil];
    [notificationCenter removeObserver:self name:kZORNCoreDataStackStackIsReady object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self tableView] setSectionIndexBackgroundColor:[UIColor clearColor]];
    
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:self.savedSearchTerm];

        self.savedSearchTerm = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)didReceiveMemoryWarning
{
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    
    [super didReceiveMemoryWarning];
}

- (void)resetFetchResultsController
{
    [NSFetchedResultsController deleteCacheWithName:[self cacheName]];
    if (_fetchedResultsController) self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    if (_searchFetchedResultsController) self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (void)setFetchedResultsControllerPredicate:(NSPredicate *)fetchedResultsControllerPredicate
{
    _fetchedResultsControllerPredicate = fetchedResultsControllerPredicate;
    _fetchedResultsController = nil;
}

#pragma mark - ZORNCoreDataStack Notifications

- (void)handleZORNCoreDataStackStackIsComingDownNotification:(NSNotification *)note
{
    NSLog(@"note: %@", note);
    self.managedObjectContext = nil;
    [self resetFetchResultsController];
}

- (void)handleZORNCoreDataStackStackIsReadyNotification:(NSNotification *)note
{
    NSLog(@"note: %@", note);
    NSManagedObjectContext *newContext = (NSManagedObjectContext *)[[note userInfo] objectForKey:@"managedObjectContext"];
    // FIXME: Should I be worried this is being called during app launch?
    self.managedObjectContext = newContext;
    [self.tableView reloadData];
}

#pragma mark - Subclass overrides

- (NSString *)entityName
{
    NSAssert(NO, @"IMPLIMENTED BY SUBCLASS");
    return nil;
}

- (NSString *)sectionNameKeyPath
{
    return nil;
}

- (NSArray *)sortDescriptors
{
    NSAssert(NO, @"IMPLIMENTED BY SUBCLASS");
    return nil;
}

- (NSPredicate *)searchPredicateForSearchString:(NSString *)searchString
{
    NSAssert(NO, @"IMPLIMENTED BY SUBCLASS");
    return nil;
}

- (NSString *)cacheName
{
    return nil;
}

- (NSString *)reuseIdentifierForTableViewCell
{
    NSAssert(NO, @"IMPLIMENTED BY SUBCLASS");
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    NSAssert(NO, @"IMPLIMENTED BY SUBCLASS");
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsControllerForTableView:table] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [self.tableView dequeueReusableCellWithIdentifier:self.reuseIdentifierForTableViewCell];
    NSAssert(cell, @"???");
    [self configureCell:cell atIndexPath:indexPath forTableView:tableView];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView == self.tableView) {
        NSArray *arrayWithSearchIcon = [NSArray arrayWithObject:UITableViewIndexSearch];
        NSArray *arrayFromFRC = [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
        if ([arrayFromFRC count] > 0) {
            return [arrayWithSearchIcon arrayByAddingObjectsFromArray:arrayFromFRC];
        }
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger answer = 0;
    if (0 == index && tableView == self.tableView) {
        // If the user taps the search icon, scroll the table view to the top
        answer = -1;
        [tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    } else {
        NSInteger mainTableSearchAdjustment = 0;
        if (tableView == self.tableView) {
            mainTableSearchAdjustment = -1;
        }
        answer = [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index + mainTableSearchAdjustment];
    }
    return answer;
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSPredicate *filterPredicate = [self.fetchedResultsControllerPredicate copy];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    if(searchString.length)
    {
        // your search predicate(s) are added to this array
        [predicateArray addObject:[self searchPredicateForSearchString:searchString]];
        // finally add the filter predicate for this view
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:self.sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSString *cacheName = nil;
    if ([searchString length] <= 0) {
        cacheName = self.cacheName;
    }
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:cacheName];
    aFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error])
    {
        /*
         FIXME: Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    return _fetchedResultsController;
}

- (NSFetchedResultsController *)searchFetchedResultsController
{
    if (_searchFetchedResultsController != nil)
    {
        return _searchFetchedResultsController;
    }
    _searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.searchDisplayController.searchBar.text];
    return _searchFetchedResultsController;
}

#pragma mark - NSFetchResultsControllerDelegate

- (UITableView *)tableViewForFetchResultsController:(NSFetchedResultsController *)controller
{
    return controller == self.fetchedResultsController ? self.tableView : self.searchDisplayController.searchResultsTableView;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableViewForFetchResultsController:controller] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = [self tableViewForFetchResultsController:controller];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = [self tableViewForFetchResultsController:controller];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath forTableView:tableView];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableViewForFetchResultsController:controller] endUpdates];
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    self.savedScopeButtonIndex = scope;
}


#pragma mark -
#pragma mark Search Bar

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


@end
