//
//  FBAbstractBitLayer.h
//  FrickBits
//
//  Created by Matt McGlincy on 3/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBJoin.h"
#import "FBJoinNode.h"
#import "FBFrickBitRecipe.h"
#import "FBRecipeFactory.h"
#import "FBQuad.h"

@interface FBAbstractBitLayer : CALayer

@property(nonatomic) CGPoint fromPointInParent;
@property(nonatomic) CGPoint toPointInParent;
@property(nonatomic, readonly) FBQuad quadInParent;
@property(nonatomic, readonly) CGPoint centerInParent;

@property(nonatomic) CGPoint fromPointInSelf;
@property(nonatomic) CGPoint toPointInSelf;
@property(nonatomic) FBQuad quadInSelf;
@property(nonatomic, readonly) CGPoint centerInSelf;

@property(nonatomic, strong) FBFrickBitRecipe *recipe;
@property(nonatomic, strong) FBRecipeFactory *factory;

- (UIBezierPath *)fillPath;
- (void)forceRedraw;

- (void)animateIn;
- (void)animateInWithCompletion:(void (^)(BOOL finished))completion;
- (void)animateInWithDuration:(CGFloat)duration;
- (void)animateInWithDuration:(CGFloat)duration
                   completion:(void (^)(BOOL finished))completion;

- (void)animateFromToWithDuration:(CGFloat)duration;
- (void)animateFromToWithDuration:(CGFloat)duration
                   completion:(void (^)(BOOL finished))completion;

- (void)animateToFromWithDuration:(CGFloat)duration;
- (void)animateToFromWithDuration:(CGFloat)duration
                   completion:(void (^)(BOOL finished))completion;

- (void)animateFromCenterWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion;

- (void)maybeJoinToJoinNode1:(CALayer<FBJoinNode> *)joinNode1 joinNode2:(CALayer<FBJoinNode> *)joinNode2;
- (void)endJoinToJoinNode1:(CALayer<FBJoinNode> *)joinNode1 joinNode2:(CALayer<FBJoinNode> *)joinNode2;
- (void)endJoinToJoinNode:(CALayer<FBJoinNode> *)joinNode;
- (void)endJoinToJoinNode:(CALayer<FBJoinNode> *)joinNode side:(FBJoinSide)side;
- (FBJoinSide)sideToJoinWithJoinNode:(CALayer<FBJoinNode> *)joinNode;
- (CGPoint)endPointInSelfToJoinWithJoinNode:(CALayer<FBJoinNode> *)joinNode;

- (void)hide;
- (void)show;

- (CGFloat)angle;
- (CGFloat)bitLength;
- (CGFloat)bitWidth;

@end
