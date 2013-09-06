//
//  QueryCollectionViewController.m
//  Imagist 2
//
//  Created by Alaric Cole on 8/26/13.
//  Copyright (c) 2013 Alaric. All rights reserved.
//

#import "QueryCollectionViewController.h"

@interface QueryCollectionViewController ()

@end

@implementation QueryCollectionViewController
-(void)dealloc
{
	[_query cancel];
}
-(NSUInteger)objectsPerPage
{
	return 10;
}

-(PFQuery*)query
{
	if (!_query) {
        _query = [self.class storedQuery];
		//_query.cachePolicy = kPFCachePolicyCacheElseNetwork;//doing this here overwrites it
		_query.limit = self.objectsPerPage;

    }


//	if (self.objects.count == 0) {
//_query.cachePolicy = kPFCachePolicyCacheThenNetwork;//kPFCachePolicyNetworkElseCache is default
//	}

	return _query;
	
}

+(PFQuery*)storedQuery
{
	PFQuery * query = [PFQuery queryWithClassName:@"Collection"];
	//[query whereKeyExists:@"composite"];
	[query whereKeyExists:@"thumbnail"];

	query.cachePolicy = kPFCachePolicyNetworkElseCache;
	int daysInSeconds = 60 * 60 * 24;

	query.maxCacheAge = daysInSeconds * 1;//a week?
										  //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
										  //query.cachePolicy = kPFCachePolicyNetworkElseCache;

    [query orderByAscending:@"createdAt"];


	[query whereKeyDoesNotExist:@"video"];

	return query;

}
-(BOOL)useSections
{
	return YES;
}
-(void)checkForPagingAtIndexPath:(NSIndexPath*)indexPath
{
	if (!self.pagingEnabled) {
		return;
	}

	NSInteger beginPagingThisManyItemsBeforeEnd = 1;

	NSInteger spot = self.useSections? indexPath.section : indexPath.item;

	BOOL showMore = spot >= (self.objects.count ) - beginPagingThisManyItemsBeforeEnd ;

	if (showMore) {
		[self showMore];
		//[self performSelector:@selector(showMore) withObject:nil afterDelay:.0];

	}
	

}


#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	//	if (!self.objects.count) {
	//		return 1;
	//	}
	if (self.useSections) {
		return self.objects.count;

	}



	return 1;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
	//	if (!self.objects.count) {
	//		return 2;
	//	}
	//return 10;
	if (self.useSections) {
		return 1;


	}

	return self.objects.count;
}


-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self checkForPagingAtIndexPath:indexPath];


	Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];


  	PFObject* collection;


	if (self.useSections) {
		collection = self.objects[indexPath.section];

	}

	else
	{
		collection = self.objects[indexPath.item];


	}

	PFFile * image = collection[@"thumbnail"];



	[image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {

		cell.imageView.image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];

	}];



	

		return cell;
}
-(void)showMore
{

    if (self.isLoading || self.endReached || (self.objects.count >= self.maximum))
    {
        return;
    }


	self.isLoading = YES;


    DLog(@"LOADING MORE AT %d", self.objects.count);
//	if (self.objects.count > 50) {
//
//		self.query.limit = 100;
//	}
//	else
//	{
//		self.query.limit = 50;
//	}

    self.query.skip = self.objects.count;

	//  [activityIndicator startAnimating];



    [self.query findObjectsInBackgroundWithBlock:self.resultBlock];





}

//forces refresh not from cache
-(void)refresh:(UIRefreshControl*)refreshControl
{
	[self.query clearCachedResult];
	//self.query.cachePolicy = kPFCachePolicyNetworkElseCache;
	[self refresh];
//	CGImageDestinationCopyImageSource
//	CGImageMetadataCopyStringValueWithPath
}


-(NSMutableArray*)objects
{

	if (!_objects) {
		_objects = [NSMutableArray array];

	}
	return _objects;
}

-(PFArrayResultBlock)resultBlock
{

	return  ^(NSArray *objects, NSError *error) {



        if (!error) {

			if (objects.count<1) {
				//no error, but no objects means we're out of data
				_endReached = YES;
				[self refreshFinishedAndNeedsReload:NO];
				return;
			}

//			BOOL animated = YES;
//			if (!animated) {
//				[self.objects addObjectsFromArray:objects];
//				[self refreshFinishedAndNeedsReload:YES];
//				return ;
//			}


			//better animated way without reloaddata
            NSMutableArray * indexPaths = [NSMutableArray new];
			NSMutableIndexSet* indexSet = [NSMutableIndexSet new];

			[self.collectionView performBatchUpdates:^{


				for (int i = 0; i<objects.count; i++) {



					NSIndexPath * path;

					NSUInteger index =self.objects.count+i;

					if (self.useSections) {
						[indexSet addIndex:index];

					}
					else
					{
						path =[NSIndexPath indexPathForItem:index inSection:0];
					}


					if (path) {
						[indexPaths addObject:path];
						//
						//						PFObject* parseObject = objects[i];
						//
						//						[self.objects addObject:parseObject];
					}



				}


				[self.objects addObjectsFromArray:objects];

				if (self.useSections)
				{

					//causes a scrollview offset problem
					[self.collectionView insertSections:indexSet];
					//[self.collectionView insertItemsAtIndexPaths:indexPaths];

				}
				else
				{
					[self.collectionView insertItemsAtIndexPaths:indexPaths];
					
				}
					
					
					

			} completion:^(BOOL finished) {
				[self refreshFinishedAndNeedsReload:NO];
			}];



		}

		else//error?
		{
			if(error.code == kPFErrorConnectionFailed || error.code == kPFErrorInternalServer || error.code == kPFErrorTimeout)


			{

				

			}


			[self refreshFinishedAndNeedsReload:NO];
			
		}



	};


}

-(void)refresh
{
		self.isLoading = YES;

	if(!self.objects.count)
	{
		if (!self.refreshControl.refreshing && !self.query.hasCachedResult && self.shouldShowRefresh) {
			[self.refreshControl beginRefreshing];
		}
	}


	[self.query findObjectsInBackgroundWithBlock:self.resultBlock];


}

-(void)refreshFinishedAndNeedsReload:(BOOL)needsReload
{

	if (needsReload) {
		
		[self.collectionView reloadData];
		//[self.collectionViewLayout invalidateLayout];


	}
	self.isLoading = NO;

	if (self.refreshControl.refreshing) {
		[self.refreshControl endRefreshing];


	}

	if (!self.refreshControlEnabled ) {
		[self.refreshControl removeFromSuperview];//get rid of it if we don't allow user to use this control
	}
	//self.title = [NSString stringWithFormat:@"objects: %d", self.objects.count];

//	if (self.objects.count < 1) {
//		[self showNothingLabel];
//	}
//	else
//		[self hideNothingLabel];


}


- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)openStoreForAppID:(NSUInteger)appId
{
	SKStoreProductViewController *productController = [[SKStoreProductViewController alloc] init];
	productController.delegate = (id<SKStoreProductViewControllerDelegate>)self;

	//load product details
	NSDictionary *productParameters = @{SKStoreProductParameterITunesItemIdentifier: [@(appId) description]};
	[productController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {

		if (result)
		{
			[self presentViewController:productController animated:YES completion:^{

			}];

		}

	}];
	

}
-(BOOL)shouldShowRefresh
{
	return NO;
}
-(BOOL)refreshControlEnabled
{
	return NO;
}


//-(void)loadView
//{
//	[super loadView];
//	[self refresh];
//}
- (void)viewDidLoad
{

    [super viewDidLoad];





	///[self.collectionViewLayout registerNib:[UINib nibWithNibName:@"DecorationView" bundle:nil] forDecorationViewOfKind:LogoDecorationKind];

	
	//[self openStoreForAppID:679906792];



	self.maximum = 1000;


	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
//
	if (self.shouldShowRefresh) {
		[self.collectionView addSubview:self.refreshControl];
	}

	//self.refreshControl.hidden = !self.refreshControlEnabled;

	//make sure this is after refreshcontrol creation
	[self refresh];


}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	//return CGSizeMake(320, 320);
	//	Collection* set = self.objects[indexPath.item];
	//
	//
	//    return CGSizeMake (set.compositeWidth, set.compositeHeight);

	PFObject* collection;


	if (self.useSections) {
		collection = self.objects[indexPath.section];

	}

	else
	{
		collection = self.objects[indexPath.item];


	}
	return CGSizeMake(320, [collection[@"height"] floatValue]);
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
