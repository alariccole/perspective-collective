//
//  CoverFlowLayout.m
//  IntroducingCollectionViews
//
//  Created by Mark Pospesel on 10/7/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//


//UIInterpolatingMotionEffect *mx = [[UIInterpolatingMotionEffect alloc]
//								   initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
//mx.maximumRelativeValue = @-39.0;
//mx.minimumRelativeValue = @39.0;
//
//UIInterpolatingMotionEffect *mx2 = [[UIInterpolatingMotionEffect alloc]
//									initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
//mx2.maximumRelativeValue = @-39.0;
//mx2.minimumRelativeValue = @39.0;
//
////Make sure yourView's bounds are beyond the canvas viewport - because it's being moved by values.
//
//[yourView addMotionEffect:mx];
//[yourView addMotionEffect:mx2];


#import "PerspectiveLayout.h"
//#import "ConferenceLayoutAttributes.h"

@implementation PerspectiveLayout

#define ACTIVE_DISTANCE 100
#define TRANSLATE_DISTANCE 100
#define ZOOM_FACTOR 0.001
#define FLOW_OFFSET 40
//-(void)awakeFromNib
//{
//
//	BOOL iPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
//	self.scrollDirection = UICollectionViewScrollDirectionVertical;
//	self.itemSize = (CGSize){300, 300};
//	self.sectionInset = UIEdgeInsetsMake(iPad? 225 : 0, 35, iPad? 225 : 0, 35);
//	self.minimumLineSpacing = -220.0;
//
//}
//-(void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
//{
//	[super setMinimumLineSpacing:-100];
//}
//- (id)init
//{
//    self = [super init];
//    if (self)
//    {
//        BOOL iPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
//        self.scrollDirection = UICollectionViewScrollDirectionVertical;
//        //self.itemSize = (CGSize){300, 300};
//		// self.sectionInset = UIEdgeInsetsMake(iPad? 225 : 0, 35, iPad? 225 : 0, 35);
//        self.minimumLineSpacing = -5050.0;
//		//self.minimumInteritemSpacing = 200;
//        //self.headerReferenceSize = iPad? (CGSize){50, 50} : (CGSize){43, 43};
//    }
//    return self;
//}

-(UIDynamicAnimator*)dynamicAnimator{

	if (!_dynamicAnimator) {
		_dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
	}
	return _dynamicAnimator;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = self.collectionView;
    CGFloat scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y;
    CGPoint touchLocation = [scrollView.panGestureRecognizer locationInView:scrollView];

    for (UIAttachmentBehavior *spring in self.dynamicAnimator.behaviors)
    {
        CGPoint anchorPoint = spring.anchorPoint;
        CGFloat distanceFromTouch = fabsf(touchLocation.y - anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 500 / 5; // higher scrollResistance -> bouncier

        UICollectionViewLayoutAttributes *item = [spring.items firstObject];
        CGPoint center = item.center;
        //center.y += scrollDelta * scrollResistance;//MAX(scrollDelta, scrollDelta * scrollResistance);
		if (scrollDelta > 0)
			center.y += MIN(scrollDelta, scrollDelta * scrollResistance);
		else
			center.y -= MIN(-scrollDelta, -scrollDelta * scrollResistance);
        item.center = center;

		//		if (item.representedElementCategory == UICollectionElementCategorySupplementaryView)
		//		{
		//			item.frame = CGRectOffset(item.frame, 0., (65+ 15)/2.	 - 40);
		//
		//
		//		}


        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }

    return NO;
}


//+ (Class)layoutAttributesClass
//{
//    return [ConferenceLayoutAttributes class];
//}

-(void)prepareLayout
{
	[super prepareLayout];


	CGSize contentSize = [super collectionViewContentSize];
	//this could get slow
	NSArray *items = [super layoutAttributesForElementsInRect:CGRectMake(0, 0, contentSize.width, contentSize.height)];


	// Compare items to behaviors count
	NSUInteger behaviorsCount =self.dynamicAnimator.behaviors.count;
	if (items.count != behaviorsCount)
	{
		// Clear the existing behaviors
		[self.dynamicAnimator removeAllBehaviors];
		for (UICollectionViewLayoutAttributes *item in items)
        {
			//if (item.representedElementCategory == UICollectionElementCategoryCell) {

			//if (item.representedElementCategory == UICollectionElementCategorySupplementaryView)
			{
				///item.frame = CGRectOffset(item.frame, 0., (65+ 15)/2.	-40 );//

				item.zIndex = 1024;


				UIAttachmentBehavior *spring =

				[[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center ];

				//[[UIAttachmentBehavior alloc] initWithItem:item offsetFromCenter:UIOffsetMake(0, 0) attachedToAnchor:item.center];


				spring.length = 0;//nonzero value seems to get rid of oscillation when holding
				spring.damping = 10.;//less means  more bouncing back and forth
				spring.frequency = 0.;//less means slower to move

				spring.length = 1;
				spring.damping = 1;
				spring.frequency = 3;

				spring.length = 1;
				spring.damping = 0.8;
				spring.frequency = 1.8;

				[self.dynamicAnimator addBehavior:spring];
			}

//			else
//			{
//
//
//				UIAttachmentBehavior *spring = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
//
//				//			spring.length = 0;
//				//            spring.damping = 0.5;
//				//            spring.frequency = 0.8;
//				spring.length = 1;//nonzero value seems to get rid of oscillation when holding
//				spring.damping = 1.;//less means  more bouncing back and forth
//				spring.frequency = 3.;//less means slower to move
//
//				[self.dynamicAnimator addBehavior:spring];
//
//				//item.zIndex = 1;
//				//}
//				
//			}

			
        }
		
	}
	
	
	
	
	
	
	
	//}
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSArray* array =[self.dynamicAnimator itemsInRect:rect];

	//return attributes;


	// NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;

	
    for (UICollectionViewLayoutAttributes* attributes in array) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell)
        {
            if (CGRectIntersectsRect(attributes.frame, rect)) {
                [self setCellAttributes:attributes forVisibleRect:visibleRect];
            }
        }
        else if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
        {
            [self setHeaderAttributes:attributes];
        }
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *attributes =  [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];

	return attributes;

	// UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    [self setCellAttributes:attributes forVisibleRect:visibleRect];
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    
    [self setHeaderAttributes:attributes];
    
    return attributes;
}




- (void)setHeaderAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
    attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);

}


- (void)setCellAttributes:(UICollectionViewLayoutAttributes *)attributes forVisibleRect:(CGRect)visibleRect
{
    CGFloat distance = CGRectGetMidY(visibleRect) - attributes.center.y;
    CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
	//DLog(@"dist %f", distance);
    //BOOL isLeft = distance > 0;
    CATransform3D transform = CATransform3DIdentity;
	//parallax
	//id< UICollectionViewDelegateFlowLayout> del =self.collectionView.delegate ;
	//CGSize size = [del sizefor ]
	CGSize itemsize = attributes.size;
    //transform.m34 = -1/(2.6777 * itemsize.height);


	//transform = CATransform3DMakeRotation(RADIANS(90.0f), 1.0, 0.0, 0.0);

	//gives the skinny at the bottom look
	transform = CATransform3DMakePerspective(0., 0.001);

	//transform = CATransform3DTranslate(transform, 0, FLOW_OFFSET, 0);



	//CGFloat percentOfHeight = attributes.center.y /
	//CGFloat percentDistance = distance/CGRectGetMaxY(visibleRect);

	
	//transform = CATransform3DRotate(transform, -1 * (normalizedDistance * 45) * M_PI / 180, 1, 0, 0);
	//movement of flipping backwards as if going to the back of a rolodex
	transform = CATransform3DRotate(transform, -1 * (1. * 45) * M_PI / 180, 1, 0, 0);
	
    //if (distance > ACTIVE_DISTANCE)
    {
//        if (ABS(distance) < TRANSLATE_DISTANCE)
//        {
//            transform = CATransform3DTranslate(CATransform3DIdentity,  0, (isLeft? - FLOW_OFFSET : FLOW_OFFSET)*ABS(distance/TRANSLATE_DISTANCE),(1 - ABS(normalizedDistance)) * 40000 + (isLeft? 200 : 0));
//        }
//        else
//        {
//            transform = CATransform3DTranslate(CATransform3DIdentity, 0,
//											   (isLeft? - FLOW_OFFSET : FLOW_OFFSET),
//											   (1 - ABS(normalizedDistance)) * 40000 + (isLeft? 200 : 0));
//        }
		// transform.m34 = -1/(4.6777 * self.itemSize.height );

		transform = CATransform3DTranslate(transform, 0,

										   distance/3.,//affects distance between items. greater is further apart
										   1);//(1 - distance) * 4 +0);

		CGFloat zoom = .8 + ZOOM_FACTOR*(1 - normalizedDistance);

		transform = CATransform3DScale(transform, zoom, zoom, 1);

		

		
		// transform = CATransform3DRotate(transform, (isLeft? 1 : -1) * ABS(normalizedDistance) * 45 * M_PI / 180, 0, 1, 0);
		// transform = CATransform3DScale(transform, zoom, zoom, 1);
        //attributes.zIndex = 1;//ABS(ACTIVE_DISTANCE - ABS(distance)) + 1;
    }
//    else
//    {
//        
//
////		        attributes.zIndex = 0;
//    }

	CGFloat z = attributes.center.y;
	attributes.zIndex =z; //the lower, the higher on teh stack
    attributes.transform3D = transform;
	//attributes.alpha = .95;
}

//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
//{
//    CGFloat offsetAdjustment = MAXFLOAT;
//    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
//    
//    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
//    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
//    
//    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
//        if (layoutAttributes.representedElementCategory != UICollectionElementCategoryCell)
//            continue; // skip headers
//        
//        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
//        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
//            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
//        }
//    }
//    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
//}

@end
