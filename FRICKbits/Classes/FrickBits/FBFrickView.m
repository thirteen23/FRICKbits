//
//  FBFrickView.m
//  FrickBits
//
//  Created by Matthew McGlincy on 2/20/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <MTGeometry/MTGeometry.h>
#import "FBClusterBitLayer.h"
#import "FBColorPaletteManager.h"
#import "FBCoordinateQuadTree.h"
#import "FBFillerBitLayer.h"
#import "FBFrickBitLayer.h"
#import "FBFrickView.h"
#import "FBJoinery.h"
#import "FBUtils.h"
#import "NSMutableArray+T23Queue.h"
#import "T23ConcurrentMutableMap.h"
#import "T23ConcurrentMutableSet.h"

static const NSUInteger FBChanceOfSplitBit = 10;
static const NSUInteger FBMinimumConnectionsForSegmentedBit = 2;

// CALayer.zPosition
static const CGFloat ZPositionClusterBit = 3.0;
static const CGFloat ZPositionFrickBit = 0.0;
static const CGFloat ZPositionJoineryBit = 2.0;
static const CGFloat ZPositionSegmentedBit = 1.0;
static const CGFloat ZPositionSplitBit = 0.0;

// how long between each connection bit for a single joinery bit
static CGFloat const FBFrickBitPostSchedulingSleep = 0.170;

// bit animation duration
static CGFloat const FBFrickBitAnimationBaseDuration = 0.510;
static CGFloat const FBFrickbitAnimationDepthSpeedup = 0.06;
static CGFloat const FBFrickBitAnimationMinDuration = 0.1;

#pragma mark - FBBFVNode for breadth-first visitation

@interface FBBFVNode : NSObject
@property(nonatomic, strong) FBMapGridCell *cell;
@property(nonatomic) NSUInteger depth;
@property(nonatomic) NSTimeInterval delay;
@property(nonatomic) NSOperation *previousOp;
@end

@implementation FBBFVNode
+ (FBBFVNode *)nodeWithCell:(FBMapGridCell *)cell depth:(NSUInteger)depth delay:(NSTimeInterval)delay {
  FBBFVNode *node = [[FBBFVNode alloc] init];
  node.cell = cell;
  node.depth = depth;
  node.delay = delay;
  return node;
}

+ (FBBFVNode *)nodeWithCell:(FBMapGridCell *)cell depth:(NSUInteger)depth previousOp:(NSOperation *)previousOp {
  FBBFVNode *node = [[FBBFVNode alloc] init];
  node.cell = cell;
  node.depth = depth;
  node.previousOp = previousOp;
  return node;
}
@end

#pragma mark - FBFrickView

@interface FBFrickView ()

// queue of animation operations
@property(nonatomic, strong) NSOperationQueue *animationQueue;

// keep track of visited cells, nodes, and connections to avoid repeats
@property(nonatomic, strong) T23ConcurrentMutableSet *visitedCells;
@property(nonatomic, strong) T23ConcurrentMutableMap *nodeOps;
@property(nonatomic, strong) T23ConcurrentMutableSet *visitedConns;

@property(nonatomic) BOOL isFirstConn;

@end

@implementation FBFrickView

#pragma mark - init

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.recipeFactory = [[FBRecipeFactory alloc] init];
    self.recipeFactory.colorPalette = [FBColorPaletteManager sharedInstance].colorPalette;
    self.backgroundColor = [UIColor clearColor];
    self.animationQueue = [[NSOperationQueue alloc] init];
    self.animationQueue.name = @"FBFrickViewAnimationQueue";
  }
  return self;
}

#pragma mark - op queue

- (void)pauseAnimating {
  [self.animationQueue setSuspended:YES];
}

- (void)resumeAnimating {
  [self.animationQueue setSuspended:NO];
}

- (void)cancelAnimating {
  [self.animationQueue cancelAllOperations];
}

#pragma mark - update 

- (void)clear {
  self.layer.sublayers = nil;
}

- (void)updateWithMapView:(MKMapView *)mapView
                  mapGrid:(FBSparseMapGrid *)mapGrid
                  mapRect:(MKMapRect)mapRect
                 quadTree:(FBCoordinateQuadTree *)quadTree {
  [FBTimeManager sharedInstance].updateWithMapViewStartTime = [NSDate date];
  self.isFirstConn = YES;
  
  self.frame = mapView.bounds;
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    // remove all current sublayers
    [self clear];
  });

  // make sure we're using the latest color palette
  // TODO: should we just remove recipeFactory's colorPalette instance and have it use the shared manager?
  self.recipeFactory.colorPalette = [FBColorPaletteManager sharedInstance].colorPalette;

  // create all our join nodes
  [self updateCellJoinNodesWithMapView:mapView mapGrid:mapGrid mapRect:mapRect factory:self.recipeFactory];
  
  // create all connecting bits
  [self updateConnectionFrickBitsWithMapView:mapView mapGrid:mapGrid
                                     mapRect:mapRect factory:self.recipeFactory
                             cellJoineryBits:self.cellJoinNodes];
  
  [FBTimeManager sharedInstance].updateCalcFinishedTime = [NSDate date];
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    // show all our joinery bits, initially as dots
    for (id key in _cellJoinNodes) {
      FBJoineryBitLayer *joineryBit = [_cellJoinNodes objectForKey:key];
      [joineryBit forceRedraw];
    }
  });
  
  // sort cells by location count descending
  NSMutableArray *cells = [NSMutableArray array];
  for (id key in self.cellJoinNodes) {
    [cells addObject:key];
  }
  NSArray *sortedCells =
  [cells sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSUInteger count1 = [[(FBMapGridCell *) a locations] count];
    NSUInteger count2 = [[(FBMapGridCell *) b locations] count];
    if (count1 > count2) {
      return (NSComparisonResult) NSOrderedAscending;
    } else if (count1 < count2) {
      return (NSComparisonResult) NSOrderedDescending;
    } else {
      return (NSComparisonResult) NSOrderedSame;
    }
  }];
  
  // Visit all the cells in breadth-first order,
  // starting the iteration with the highest-location count (i.e., the first in our sorted array.
  // We iterate over all the cells in the array, to make sure all cells on the screen have been walked/checked.
  _visitedCells = [[T23ConcurrentMutableSet alloc] init];
  _visitedConns = [[T23ConcurrentMutableSet alloc] init];
  _nodeOps = [[T23ConcurrentMutableMap alloc] init];
  for (FBMapGridCell *cell in sortedCells) {
    if ([_visitedCells containsObject:cell]) {
      // already visited
      continue;
    }
    
    [self breadthFirstVisitCell1:cell];
    //[self breadthFirstVisitCell2:cell];
    //[self breadthFirstVisitCell3:cell];
    
    // Wait for all the visited bits to finish animating
    // before we start a new cell/connection walk.
    [self.animationQueue waitUntilAllOperationsAreFinished];

    //XXXX to break out after one visit cycle
    //break;
  }
}

// max breadth-first depth
// set to -1 for no limit
static const NSInteger kMaxDepthPerIteration = -1;

// max connections/leaves to process by BFV node visit
// set to -1 for no limit
static const NSInteger kMaxWidthPerNode = -1;

// breadth-first
- (void)breadthFirstVisitCell1:(FBMapGridCell *)startingCell {
  NSMutableArray *queue = [NSMutableArray array];
  FBBFVNode *startingNode = [FBBFVNode nodeWithCell:startingCell depth:0 delay:0];
  [queue enqueue:startingNode];
  
  while (queue.count > 0) {
    FBBFVNode *node = [queue dequeue];
    
    if (![_visitedCells addObjectIfAbsent:node.cell]) {
      // already handled this cell
      continue;
    }
    
    // handle this cell
    CALayer<FBJoinNode> *joinNode = [self.cellJoinNodes objectForKey:node.cell];
    if (!joinNode) {
      continue;
    }
    
    NSTimeInterval joinNodeDelay = 0;
    if (node.delay > 0) {
      // we want to start the join node animation so it finishes when the previous incoming bit arrives
      joinNodeDelay = node.delay - [joinNode animationInDuration];
    }
    
    NSOperation *joinNodeOp = [FBFrickView animateOpForJoinNode:joinNode];
    if ([_nodeOps setObject:joinNodeOp forKeyIfAbsent:joinNode]) {
      [self scheduleOperation:joinNodeOp withDelay:joinNodeDelay];
    } else {
      joinNodeOp = [_nodeOps objectForKey:joinNode];
    }
    
    if (kMaxDepthPerIteration > -1 && node.depth >= kMaxDepthPerIteration) {
      // reached max depth, so don't process connections or enqueue more BFV nodes for visiting
      continue;
    }
    
    // start by delaying the first bit
    // or should this be joinNodeDelay + FBJoineryBitPostSchedulingSleep???
    NSTimeInterval bitDelay = joinNodeDelay + [joinNode animationInDuration];
    
    // possible add connections, and queue up more cells
    NSUInteger connCount = 0;
    for (FBMapGridCellConnection *conn in node.cell.connections) {
      if (![_visitedConns addObjectIfAbsent:conn]) {
        // already handled this connection
        continue;
      }
      
      FBFrickBitLayer *bit = [self.connectionFrickBits objectForKey:conn];
      if (!bit) {
        // no connection bit to show
        continue;
      }
      
      connCount++;
      if (kMaxWidthPerNode > -1 && connCount > kMaxWidthPerNode) {
        continue;
      }
      
      // speed up the animation for deeper iterations
      CGFloat bitAnimationDuration = MAX(FBFrickBitAnimationMinDuration,
                                         FBFrickBitAnimationBaseDuration - FBFrickbitAnimationDepthSpeedup * node.depth);
      //XXXX
      //bitAnimationDuration = 2.0;
      
      // use a weak reference to avoid self->opQueue->op->self cycle
      __weak FBFrickView *weakSelf = self;
      NSOperation *bitOp =
      [FBFrickView animateOpForFrickBit:bit fromJoinNode:joinNode
                               duration:bitAnimationDuration
                             addToLayer:weakSelf.layer];
      [self scheduleOperation:bitOp withDelay:bitDelay];
      
      if (self.isFirstConn) {
        self.isFirstConn = NO;
        [FBTimeManager sharedInstance].firstBitOpTime = [NSDate date];
        [[FBTimeManager sharedInstance] printTimes];
      }
      
      // add the connection's "other" cell to the queue to continue BF iteration
      FBMapGridCell *toCell = [node.cell isEqualToMapGridCell:conn.cell1] ? conn.cell2 : conn.cell1;
      // the delay should be for when the incoming bit visually arrives (i.e., finishes its animation)
      NSTimeInterval nextNodeDelay = bitDelay + bitAnimationDuration;
      FBBFVNode *nextNode = [FBBFVNode nodeWithCell:toCell depth:(node.depth + 1) delay:nextNodeDelay];
      [queue enqueue:nextNode];
      
      // delay the next bit's animation a little more
      bitDelay += FBFrickBitPostSchedulingSleep;
    }
  }
}

// breadth-first, starting with join node animation
- (void)breadthFirstVisitCell2:(FBMapGridCell *)startingCell {
  NSMutableArray *visitationOps = [NSMutableArray array];
  
  // use a queue for breadth-first
  NSMutableArray *queue = [NSMutableArray array];
  FBBFVNode *startingNode = [FBBFVNode nodeWithCell:startingCell depth:0 previousOp:nil];
  [queue enqueue:startingNode];
  
  while (queue.count > 0) {
    FBBFVNode *node = [queue dequeue];
    
    if (![_visitedCells addObjectIfAbsent:node.cell]) {
      // already visited this cell
      continue;
    }
    
    CALayer<FBJoinNode> *joinNode = [self.cellJoinNodes objectForKey:node.cell];
    if (!joinNode) {
      // no join node, so bail
      continue;
    }

    // acculumate animation operations for this node/cell
    NSMutableArray *animationOps = [NSMutableArray array];
    
    NSOperation *joinNodeOp = [FBFrickView animateOpForJoinNode:joinNode];
    if ([_nodeOps setObject:joinNodeOp forKeyIfAbsent:joinNode]) {
      [animationOps addObject:joinNodeOp];
      if (node.previousOp) {
        [joinNodeOp addDependency:node.previousOp];
      }
    } else {
      joinNodeOp = [_nodeOps objectForKey:joinNode];
    }
      
    // add connections and queue up more cells
    for (FBMapGridCellConnection *conn in node.cell.connections) {
      if (![_visitedConns addObjectIfAbsent:conn]) {
        // already handled this connection
        continue;
      }
        
      FBFrickBitLayer *bit = [self.connectionFrickBits objectForKey:conn];
      if (!bit) {
        // no connection bit to show
        continue;
      }
        
      // speed up the animation for deeper iterations
      CGFloat bitAnimationDuration = MAX(FBFrickBitAnimationMinDuration,
                                         FBFrickBitAnimationBaseDuration - FBFrickbitAnimationDepthSpeedup * node.depth);

      // use a weak reference to avoid self->opQueue->op->self cycle
      __weak FBFrickView *weakSelf = self;
      NSOperation *bitOp =
      [FBFrickView animateOpForFrickBit:bit fromJoinNode:joinNode
                               duration:bitAnimationDuration
                             addToLayer:weakSelf.layer];
      [bitOp addDependency:joinNodeOp];
      [animationOps addObject:bitOp];
        
      if (self.isFirstConn) {
        self.isFirstConn = NO;
        [FBTimeManager sharedInstance].firstBitOpTime = [NSDate date];
        [[FBTimeManager sharedInstance] printTimes];
      }
        
      // add the connection's "other" cell to the queue to continue BF iteration
      // the delay should be for when the incoming bit visually arrives (i.e., finishes its animation)
      // node.cell is our "from" cell; so figure out our "to cell"
      FBMapGridCell *toCell = [node.cell isEqualToMapGridCell:conn.cell1] ? conn.cell2 : conn.cell1;
      FBBFVNode *nextNode = [FBBFVNode nodeWithCell:toCell depth:(node.depth + 1) previousOp:bitOp];
      [queue enqueue:nextNode];
    }

    // queue up the actual animation-enqueuing for this node
    NSBlockOperation *visitOp = [NSBlockOperation blockOperationWithBlock:^{
      // our visitation op will last as long as all the animation ops
      [self.animationQueue addOperations:animationOps waitUntilFinished:YES];
    }];
    
    [visitationOps addObject:visitOp];
  }
  
  // use another op queue so we can limit how many concurrent nodes we allow concurrent visitation/animation of
  NSOperationQueue *visitationQueue = [[NSOperationQueue alloc] init];
  visitationQueue.maxConcurrentOperationCount = 1;
  // wait for all our visitations to finish before
  // we return and allow another BFV to start from a different root node
  [visitationQueue addOperations:visitationOps waitUntilFinished:YES];
}

// breadth-first, animating the join node as soon as the connection bit reaches it
- (void)breadthFirstVisitCell3:(FBMapGridCell *)startingCell {
  NSMutableArray *visitationOps = [NSMutableArray array];
  
  // use a queue for breadth-first
  NSMutableArray *queue = [NSMutableArray array];
  FBBFVNode *startingNode = [FBBFVNode nodeWithCell:startingCell depth:0 previousOp:nil];
  [queue enqueue:startingNode];
  
  while (queue.count > 0) {
    FBBFVNode *node = [queue dequeue];
    
    if (![_visitedCells addObjectIfAbsent:node.cell]) {
      // already visited this cell
      continue;
    }
    
    CALayer<FBJoinNode> *joinNode = [self.cellJoinNodes objectForKey:node.cell];
    if (!joinNode) {
      continue;
    }
    
    // animation operations for this node
    NSMutableArray *animationOps = [NSMutableArray array];
    
    NSOperation *joinNodeOp = [_nodeOps objectForKey:joinNode];
    if (!joinNodeOp) {
      // animate-in the join node if it hasn't been animated already
      // (such as the first/root iteration)
      joinNodeOp = [FBFrickView animateOpForJoinNode:joinNode];
      [_nodeOps setObject:joinNodeOp forKey:joinNode];
      [animationOps addObject:joinNodeOp];
    }
    
    // add connections and queue up more cells
    for (FBMapGridCellConnection *conn in node.cell.connections) {
      if (![_visitedConns addObjectIfAbsent:conn]) {
        // already handled this connection
        continue;
      }
      
      FBFrickBitLayer *bit = [self.connectionFrickBits objectForKey:conn];
      if (!bit) {
        // no connection bit to show
        continue;
      }
      
      // speed up the animation for deeper iterations
      CGFloat bitAnimationDuration = MAX(FBFrickBitAnimationMinDuration,
                                         FBFrickBitAnimationBaseDuration - FBFrickbitAnimationDepthSpeedup * node.depth);
      // use a weak reference to avoid self->opQueue->op->self cycle
      __weak FBFrickView *weakSelf = self;
      NSOperation *bitOp =
      [FBFrickView animateOpForFrickBit:bit fromJoinNode:joinNode
                               duration:bitAnimationDuration
                             addToLayer:weakSelf.layer];
      [bitOp addDependency:joinNodeOp];
      //XXX[self scheduleOperation:bitOp withDelay:bitDelay];
      [animationOps addObject:bitOp];
      
      if (self.isFirstConn) {
        self.isFirstConn = NO;
        [FBTimeManager sharedInstance].firstBitOpTime = [NSDate date];
        [[FBTimeManager sharedInstance] printTimes];
      }
      
      // add the connection's "other" cell to the queue to continue BF iteration
      // the delay should be for when the incoming bit visually arrives (i.e., finishes its animation)
      // node.cell is our "from" cell; so figure out our "to cell"
      FBMapGridCell *toCell = [node.cell isEqualToMapGridCell:conn.cell1] ? conn.cell2 : conn.cell1;
      CALayer<FBJoinNode> *toJoinNode = [self.cellJoinNodes objectForKey:toCell];
      NSOperation *toJoinNodeOp = [FBFrickView animateOpForJoinNode:toJoinNode];
      if ([_nodeOps setObject:toJoinNodeOp forKeyIfAbsent:toJoinNode]) {
        //XXX[self scheduleOperation:joinNodeOp withDelay:joinNodeDelay];
        [toJoinNodeOp addDependency:bitOp];
        [animationOps addObject:toJoinNodeOp];
      } else {
        toJoinNodeOp = [_nodeOps objectForKey:toJoinNode];
      }
      
      //NSTimeInterval nextNodeDelay = bitDelay + bitAnimationDuration;
      FBBFVNode *nextNode = [FBBFVNode nodeWithCell:toCell depth:(node.depth + 1) previousOp:toJoinNodeOp];
      [queue enqueue:nextNode];
    }
    
    // queue up the actual animation-enqueuing for this node
    NSBlockOperation *visitOp = [NSBlockOperation blockOperationWithBlock:^{
      // our visitation op will last as long as all the animation ops
      [self.animationQueue addOperations:animationOps waitUntilFinished:YES];
    }];
    
    [visitationOps addObject:visitOp];
  }
  
  // use another op queue so we can limit how many concurrent nodes we allow concurrent visitation/animation of
  NSOperationQueue *visitationQueue = [[NSOperationQueue alloc] init];
  visitationQueue.maxConcurrentOperationCount = 1;
  // wait for all our visitations to finish before
  // we return and allow another BFV to start from a different root node
  [visitationQueue addOperations:visitationOps waitUntilFinished:YES];
}

#pragma mark - animation ops

- (void)scheduleOperation:(NSOperation *)op withDelay:(NSTimeInterval)delay {
  if (delay > 0) {
    // use a separate delay operation, so our "real" op is cancellable in the queue
    NSOperation *delayOp = [FBFrickView delayOperationWithTimeInterval:delay];
    [op addDependency:delayOp];
    [self.animationQueue addOperation:delayOp];
  }
  [self.animationQueue addOperation:op];

  // TODO: testing using dispatch_after instead of delay op / dependency
  // this has repercussions with waitUntilAllOperationsFinished on the opQueue,
  // since the queue can be empty, even though we have a shitload of dispatch_afters in flight.
//  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    [self.opQueue addOperation:op];
//  });
}

// Create an operation that just sleeps, useful for a "delay dependency".
+ (NSOperation *)delayOperationWithTimeInterval:(NSTimeInterval)timeInterval {
  NSBlockOperation *op = [[NSBlockOperation alloc] init];
  [op addExecutionBlock:^{
    [NSThread sleepForTimeInterval:timeInterval];
  }];
  return op;
}

+ (NSOperation *)animateOpForJoinNode:(CALayer<FBJoinNode> *)joinNode {
  NSBlockOperation *op = [[NSBlockOperation alloc] init];
  [op addExecutionBlock:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [joinNode animateIn];
    });
    // let the animation finish
    // [NSThread sleepForTimeInterval:FBJoineryBitPostSchedulingSleep];
    
    // XXX testing leaving the animate op in queue for the duration of the animation
    [NSThread sleepForTimeInterval:[joinNode animationInDuration]];
  }];
  return op;
}

+ (NSOperation *)animateOpForFrickBit:(FBAbstractBitLayer *)bit
                         fromJoinNode:(CALayer<FBJoinNode> *)joinNode
                             duration:(CGFloat)duration
                           addToLayer:(CALayer *)addToLayer {
  NSBlockOperation *op = [[NSBlockOperation alloc] init];
  [op addExecutionBlock:^{
    dispatch_async(dispatch_get_main_queue(), ^{
      [bit forceRedraw];
      [bit show];
      
      // We sometimes get frickBits whose fromPoint is cell2
      // (usually toPoint == cell1 and fromPoint == cell2).
      // To work around this, we check distance vs. the joinery bit for deciding
      // "what direction" an animation should be.
      CGFloat fromDist = DistanceBetweenPoints(joinNode.centerInParent, bit.fromPointInParent);
      CGFloat toDist = DistanceBetweenPoints(joinNode.centerInParent, bit.toPointInParent);
      if (fromDist <= toDist) {
        [bit animateFromToWithDuration:duration];
      } else {
        [bit animateToFromWithDuration:duration];
      }
    });
    // let the animation finish
    //[NSThread sleepForTimeInterval:FBFrickBitPostSchedulingSleep];
    
    // XXX testing leaving the animate op in queue for the duration of the animation
    [NSThread sleepForTimeInterval:duration];
  }];
  return op;
}

#pragma mark - update join nodes

// Figure out what joinery bits we need.
// Returns a map of cell => joinery bit.
- (void)updateCellJoinNodesWithMapView:(MKMapView *)mapView
    mapGrid:(FBSparseMapGrid *)mapGrid mapRect:(MKMapRect)mapRect
    factory:(FBRecipeFactory *)factory {
  
  // TODO: do we need to clear out previous map and remove bits/layers?
  self.cellJoinNodes = [NSMapTable
                          mapTableWithKeyOptions:NSMapTableStrongMemory
                          valueOptions:NSMapTableStrongMemory];
  // get the upper-left and lower-right rowCol for our sparse grid
  MKMapPoint ulMapPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMinY(mapRect));
  MKMapPoint lrMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect));
  RowCol ulRowCol = [mapGrid rowColForMapPoint:ulMapPoint];
  RowCol lrRowCol = [mapGrid rowColForMapPoint:lrMapPoint];

  // decide which cells exist and need join nodes
  NSMutableArray *cellsNeedingNodes = [NSMutableArray array];
  for (NSUInteger row = ulRowCol.row; row <= lrRowCol.row; row++) {
    for (NSUInteger col = ulRowCol.col; col <= lrRowCol.col; col++) {
      FBMapGridCell *cell = [mapGrid cellAtRow:row col:col];
      // cell might not exist in sparse grid
      if (!cell) {
        continue;
      }
      if ([FBFrickView cellShouldBeClusterBit:cell averageLocationCount:mapGrid.averageLocationCount] ||
          [FBFrickView cellShouldBeJoineryBit:cell]) {
        [cellsNeedingNodes addObject:cell];
      }
    }
  }
  
  // sort cells by location count descending
  NSArray *sortedCells = [cellsNeedingNodes sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
    NSUInteger count1 = [(FBMapGridCell *)a locations].count;
    NSUInteger count2 = [(FBMapGridCell *)b locations].count;
    if (count1 > count2) {
      return NSOrderedAscending;
    }
    if (count1 < count2) {
      return NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
  
  // walk down our ordered list of cells, deciding what kind of join node to add.
  NSMutableArray *clusters = [NSMutableArray array];
  NSMutableArray *cellsWithJoineryBits = [NSMutableArray array];
  for (FBMapGridCell *cell in sortedCells) {
    CLLocationCoordinate2D coord = cell.averageCoordinate;
    CGPoint centerPoint = [mapView convertCoordinate:coord toPointToView:mapView];

    CALayer<FBJoinNode> *joinNode;
    if ([FBFrickView cellShouldBeClusterBit:cell averageLocationCount:mapGrid.averageLocationCount]) {
      // cluster
      FBClusterSize clusterSize = [FBFrickView clusterSizeWithCell:cell];
      CGFloat radius = [FBClusterBitLayer radiusWithClusterSize:clusterSize];
      
      // See if this new cluster would overlap with clusters we've added thus far.
      // Since we're iterating through cells in location-count-descending order, this also means
      // previously-added clusters are bigger clusters.
      CGFloat overlap = 0;
      for (FBClusterBitLayer *cluster in clusters) {
        overlap = cluster.radius + radius - DistanceBetweenPoints(cluster.centerInParent, centerPoint);
        if (overlap > 0) {
          // possibly down-size because of overlap.
          clusterSize = [FBClusterBitLayer downgradedClusterSize:clusterSize overlap:overlap];
          break;
        }
      }

      if (clusterSize == FBClusterSizeExtraSmall) {
        // we take "extra small" to mean "just make a joinery bit"
        joinNode = [FBFrickView joineryBitWithFactory:factory centerPoint:centerPoint];
      } else {
        FBClusterDensity clusterDensity = [FBFrickView clusterDensityWithCell:cell];
        joinNode = [FBFrickView clusterBitWithFactory:factory centerPoint:centerPoint
                                          clusterSize:clusterSize clusterDensity:clusterDensity];
      }
    } else {
      // normal joinery bit
      joinNode = [FBFrickView joineryBitWithFactory:factory centerPoint:centerPoint];
    }

    // update our temp collections
    if ([joinNode isKindOfClass:[FBClusterBitLayer class]]) {
      [clusters addObject:joinNode];
    } else {
      [cellsWithJoineryBits addObject:cell];
    }

    [self.cellJoinNodes setObject:joinNode forKey:cell];
  }
  
  // elimination pass to "eat" joinery bits overlapping with clusters
  NSMutableArray *eatenCells = [NSMutableArray array];
  for (FBMapGridCell *cell in cellsWithJoineryBits) {
    // check for overlap with any cluster
    CGFloat overlap = 0;
    CALayer<FBJoinNode> *joinNode = [self.cellJoinNodes objectForKey:cell];
    for (FBClusterBitLayer *cluster in clusters) {
      overlap = cluster.radius + joinNode.radius - DistanceBetweenPoints(cluster.centerInParent, joinNode.centerInParent);
      if (overlap > 0) {
        // make the cluster the joinNode for this cell
        [self.cellJoinNodes setObject:cluster forKey:cell];
        [eatenCells addObject:cell];
        break;
      }
    }
  }
  [cellsWithJoineryBits removeObjectsInArray:eatenCells];
  
  // elimination pass to "eat" joinery bits overlapping with other joinery bits
  // cellsWithJoineryBits is in cell-size-descending order
  // start at idx 1 since nothing can eat the 0th / biggest joinNode
  for (int i = 1; i < cellsWithJoineryBits.count; i++) {
    FBMapGridCell *cell = cellsWithJoineryBits[i];
    FBJoineryBitLayer *joineryBit = (FBJoineryBitLayer *)[self.cellJoinNodes objectForKey:cell];
    // look at any previous (aka larger) joinery bits, to see if they overlap with this bit
    for (int j = 0; j < i; j++) {
      FBMapGridCell *biggerCell = cellsWithJoineryBits[j];
      FBJoineryBitLayer *biggerBit = (FBJoineryBitLayer *)[self.cellJoinNodes objectForKey:biggerCell];
      if (joineryBit == biggerBit) {
        // TODO: do we actually need this check?
        continue;
      }
      CGFloat overlap = 14 - DistanceBetweenPoints(joineryBit.centerInParent, biggerBit.centerInParent);
      if (overlap > 0) {
        // and if so, eliminate this bit in favor of the bigger overlapper
        [self.cellJoinNodes setObject:biggerBit forKey:cell];
        break;
      }
    }
  }
  
  // actually add the layers
  NSMutableSet *addedNodes = [NSMutableSet set];
  for (FBMapGridCell *cell in sortedCells) {
    CALayer<FBJoinNode> *joinNode = [self.cellJoinNodes objectForKey:cell];
    
    // since multiple cells can point to the same joinNode, make sure we only add any joinNode once
    if (![addedNodes containsObject:joinNode]) {
      [addedNodes addObject:joinNode];
      
      // add the layer on the main thread
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.layer addSublayer:joinNode];
        [joinNode forceRedraw];
      });
    }
  }
}

+ (FBJoineryBitLayer *)joineryBitWithFactory:(FBRecipeFactory *)factory centerPoint:(CGPoint)centerPoint {
  FBJoineryBitLayer *joineryBit = [[FBJoineryBitLayer alloc] initWithFactory:factory centerInParent:centerPoint];
  joineryBit.zPosition = ZPositionJoineryBit;
  [joineryBit showDotOnly];
  return joineryBit;
}

+ (FBClusterBitLayer *)clusterBitWithFactory:(FBRecipeFactory *)factory
                                 centerPoint:(CGPoint)centerPoint
                                 clusterSize:(FBClusterSize)clusterSize
                              clusterDensity:(FBClusterDensity)clusterDensity {
  FBClusterBitLayer *clusterBit = [[FBClusterBitLayer alloc] initWithFactory:factory centerInParent:centerPoint
                                   clusterSize:clusterSize clusterDensity:clusterDensity];
  clusterBit.zPosition = ZPositionClusterBit;
  [clusterBit showDotOnly];
  return clusterBit;
}

+ (FBClusterSize)clusterSizeWithCell:(FBMapGridCell *)cell {
  // TODO: write a better scaling function
  CGFloat scaledValue = cell.locations.count;
  if (scaledValue >= 225) {
    return FBClusterSizeLarge;
  } else if (scaledValue >= 100) {
    return FBClusterSizeMedium;
  } else {
    return FBClusterSizeSmall;
  }
}

+ (FBClusterDensity)clusterDensityWithCell:(FBMapGridCell *)cell {
  CGFloat scaledValue = cell.locations.count;
  if (scaledValue >= 500) {
    // large+high
    return FBClusterDensityHigh;
  } else if (scaledValue >= 340) {
    // large+medium
    return FBClusterDensityMedium;
  } else if (scaledValue >= 225) {
    // large+high
    return FBClusterDensityLow;
  } else if (scaledValue >= 180) {
    // medium+high
    return FBClusterDensityMedium;
  } else if (scaledValue >= 140) {
    // medium+medium
    return FBClusterDensityMedium;
  } else if (scaledValue >= 100) {
    // medium+low
    return FBClusterDensityLow;
  } else if (scaledValue >= 70) {
    // small+high
    return FBClusterDensityHigh;
  } else if (scaledValue >= 40) {
    // small+medium
    return FBClusterDensityMedium;
  } else {
    // small + low
    return FBClusterDensityLow;
  }
}

+ (BOOL)cellShouldBeClusterBit:(FBMapGridCell *)cell averageLocationCount:(CGFloat)averageLocationCount {
  CGFloat countRatio = (CGFloat)cell.locations.count / averageLocationCount;
  return countRatio > 10.0;
}

+ (BOOL)cellShouldBeJoineryBit:(FBMapGridCell *)cell {
  return cell.locations.count > 0;
}

#pragma mark - update connection bits

// Figure out what connection FrickBits we need.
- (void)updateConnectionFrickBitsWithMapView:(MKMapView *)mapView
                                     mapGrid:(FBSparseMapGrid *)mapGrid mapRect:(MKMapRect)mapRect
                                     factory:(FBRecipeFactory *)factory
                             cellJoineryBits:(NSMapTable *)cellJoineryBits {
  // TODO: do we need to nuke/clear previous connectionFrickBits map?
  // what about removing previous layers?
  self.connectionFrickBits = [NSMapTable
                              mapTableWithKeyOptions:NSMapTableStrongMemory
                              valueOptions:NSMapTableStrongMemory];
  
  MKMapPoint ulMapPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMinY(mapRect));
  MKMapPoint lrMapPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect));
  RowCol ulRowCol = [mapGrid rowColForMapPoint:ulMapPoint];
  RowCol lrRowCol = [mapGrid rowColForMapPoint:lrMapPoint];

  for (FBMapGridCellConnection *conn in mapGrid.cellConnections) {
    CLLocationCoordinate2D fromCoord = conn.cell1.averageCoordinate;
    CLLocationCoordinate2D toCoord = conn.cell2.averageCoordinate;
    RowCol fromRowCol = [mapGrid rowColForMapPoint:MKMapPointForCoordinate(fromCoord)];
    RowCol toRowCol = [mapGrid rowColForMapPoint:MKMapPointForCoordinate(toCoord)];
    if (!((fromRowCol.row >= ulRowCol.row && fromRowCol.row <= lrRowCol.row &&
           fromRowCol.col >= ulRowCol.col && fromRowCol.col <= lrRowCol.col) ||
          (toRowCol.row >= ulRowCol.row && toRowCol.row <= lrRowCol.row &&
           toRowCol.col >= ulRowCol.col && toRowCol.col <= lrRowCol.col))) {
      // both rowCols are offscreen, so skip this connection
      continue;
    }

    CALayer<FBJoinNode> *joinNode1 = [cellJoineryBits objectForKey:conn.cell1];
    CALayer<FBJoinNode> *joinNode2 = [cellJoineryBits objectForKey:conn.cell2];
    if (joinNode1 == joinNode2) {
      // same join node for both cells, so no connection bit needed
      continue;
    }
    
    // Shorten from/to points for any joinery.
    CGPoint fromPoint = [mapView convertCoordinate:fromCoord toPointToView:mapView];
    CGPoint toPoint = [mapView convertCoordinate:toCoord toPointToView:mapView];
    if (joinNode1 && joinNode2) {
      // pick the 2 closest sides/anchors
      FBJoinSidePair sides = [FBJoinery closestSidesBetweenJoinNode1:joinNode1 joinNode2:joinNode2];
      fromPoint = [joinNode1 anchorInParentForSide:sides.side1];
      toPoint = [joinNode2 anchorInParentForSide:sides.side2];
    } else if (joinNode1) {
      fromPoint = [joinNode1 closestAnchorToPointInParent:toPoint];
    } else if (joinNode2) {
      toPoint = [joinNode2 closestAnchorToPointInParent:fromPoint];
    }
    
    // Truncate any offscreen points.
    // This prevents us from possibly trying to make a 50000-pixel-wide bit :P
    // We choose a replacement point "just a little bit offscreen", to
    // give the illusion the bit keeps going.
    BOOL fromPointOnscreen = CGRectContainsPoint(mapView.bounds, fromPoint);
    BOOL toPointOnscreen = CGRectContainsPoint(mapView.bounds, toPoint);
    if (fromPointOnscreen && !toPointOnscreen) {
      CGLine line = CGLineMake(fromPoint, toPoint);
      CGPoint screenBorderIntersection = CGLineIntersectsRectAtPoint(mapView
          .bounds,
          line);
      CGFloat intersectDistance = DistanceBetweenPoints(line.point1,
          screenBorderIntersection);
      CGPoint slightlyOffscreen =
          CGPointAlongLine(line, intersectDistance + 10.0);
      toPoint = slightlyOffscreen;
    } else if (!fromPointOnscreen && toPointOnscreen) {
      CGLine line = CGLineMake(toPoint, fromPoint);
      CGPoint screenBorderIntersection = CGLineIntersectsRectAtPoint(mapView.bounds, line);
      CGFloat intersectDistance = DistanceBetweenPoints(line.point1,
          screenBorderIntersection);
      CGPoint slightlyOffscreen =
          CGPointAlongLine(line, intersectDistance + 10.0);
      fromPoint = slightlyOffscreen;
    }
    
    // make a connection bit for our from/to points
    NSUInteger connCount = [mapGrid.cellConnections countForObject:conn];
    FBAbstractBitLayer *connectionBit = [FBFrickView randomConnectionBitWithConnCount:connCount fromPoint:fromPoint
                                                                              toPoint:toPoint factory:factory];
    connectionBit.mask = [[CAShapeLayer alloc] init];
    [connectionBit hide];

    [self.connectionFrickBits setObject:connectionBit forKey:conn];
    
    // add the layer on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.layer addSublayer:connectionBit];
      // Only attempt joinery *after* bit is added,
      // so bits have a common parent for coordinate conversion.
      // Note that joining adjusts our quad points, but NOT our frame.
      [connectionBit maybeJoinToJoinNode1:joinNode1 joinNode2:joinNode2];
    });
  }
}

+ (FBAbstractBitLayer *)randomConnectionBitWithConnCount:(NSUInteger)connCount fromPoint:(CGPoint)fromPoint
                                                 toPoint:(CGPoint)toPoint factory:(FBRecipeFactory *)factory {
  
  // split bit
  if (RandChance(FBChanceOfSplitBit)) {
    FBSplitBitLayer *splitBit = [[FBSplitBitLayer alloc]
                                 initWithFactory:factory
                                 fromPointInParent:fromPoint toPointInParent:toPoint];
    splitBit.zPosition = ZPositionSplitBit;
    return splitBit;
  }
  
  // segmented bit
  if (connCount >= FBMinimumConnectionsForSegmentedBit) {
    // TODO: trying out filler bit in place of segmented bit
//    FBSegmentedBitLayer *segmentedBit = [[FBSegmentedBitLayer alloc]
//                                         initWithFactory:factory
//                                         fromPointInParent:fromPoint
//                                         toPointInParent:toPoint
//                                         numberOfSegments:numberOfSegments
//                                         restrictEndBitSizes:YES];
//    segmentedBit.zPosition = ZPositionSegmentedBit;
//    
//    segmentedBit.borderColor = [UIColor greenColor].CGColor;
//    segmentedBit.borderWidth = 1.0;
//    return segmentedBit;
    
    NSUInteger numberOfSegments = connCount * 2;
    
    FBFillerBitLayer *fillerBit = [[FBFillerBitLayer alloc] initWithFactory:factory fromPointInParent:fromPoint
                                                            toPointInParent:toPoint numberOfSegments:numberOfSegments];
    fillerBit.zPosition = ZPositionSegmentedBit;
    return fillerBit;
  }
  
  // default: normal single bit
  FBFrickBitRecipe *recipe = [factory makePerfectFrickBitRecipe];
  FBFrickBitLayer *frickBit = [[FBFrickBitLayer alloc] initWithRecipe:recipe
                                                    fromPointInParent:fromPoint toPointInParent:toPoint];
  frickBit.zPosition = ZPositionFrickBit;
  return frickBit;
}

@end
