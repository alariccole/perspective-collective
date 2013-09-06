//
//  QueryCollectionViewController.h
//  Imagist 2
//
//  Created by Alaric Cole on 8/26/13.
//  Copyright (c) 2013 Alaric. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CollectionViewFlowLayout.h"
#import "PerspectiveLayout.h"
#import "Cell.h"
@interface QueryCollectionViewController : UICollectionViewController

-(void)checkForPagingAtIndexPath:(NSIndexPath*)indexPath;
+(PFQuery*)storedQuery;
@property(nonatomic, strong)PFArrayResultBlock resultBlock;

@property (nonatomic) BOOL useSections;

@property (nonatomic,strong) NSMutableArray* objects;
@property (nonatomic,strong)PFQuery *query ;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL refreshControlEnabled;
@property (nonatomic) BOOL shouldShowRefresh;
-(void)refresh:(UIRefreshControl*)refreshControl;
- (void)refresh;
-(void)refreshFinishedAndNeedsReload:(BOOL)needsReload;
-(void)showMore;

@property (nonatomic) BOOL isLoading;

@property (nonatomic) BOOL pagingEnabled;
@property (nonatomic) BOOL infiniteScrollingEnabled;


@property (nonatomic)BOOL endReached;
@property (nonatomic) NSUInteger maximum;
@property (nonatomic) NSUInteger objectsPerPage;
@end
