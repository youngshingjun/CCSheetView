//
//  CCSheetCellComponent.m
//  
//
//  Created by Cocos on 2020/2/28.
//  Copyright © 2020 Cocos. All rights reserved.
//

#import "CCSheetCellComponent.h"
#import "CCSheetViewColumnCell.h"

#import "Masonry.h"

NSString* const CCSheetCellComponentReuseIdentifier = @"CCSheetCellComponentReuseIdentifier";

@interface CCSheetCellComponent ()

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation CCSheetCellComponent
@synthesize contentItems = _contentItems;
@synthesize columnWidths = _columnWidths;
@synthesize disableScrollNotify = _disableScrollNotify;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.disableScrollNotify = NO;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0.f;
        layout.minimumLineSpacing = 0.f;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        // UICollectionView会在展示的时候自动把背景颜色设置成白色, 但是如果刚从屏幕外创建并且进入屏幕里的话, 会有瞬间是灰色的, 影响体验, 所以一律创建的时候就是白色.
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.allowsSelection = YES;
        [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"Cell"];

    }
    return _collectionView;
}


- (UIScrollView *)scrollView {
    return self.collectionView;
}

- (void)componentReloadData {
    [self.collectionView reloadData];
}

#pragma mark - UIScrollViewDelegate
// 封装ScrollView的滚动事件, 表示成滚动的状态(开始, 进行, 停止)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.disableScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingOffset:withState:)]) {
        [self.notificationDelegate sheetCell:self scrollingOffset:scrollView.contentOffset withState:UIGestureRecognizerStateBegan];
    }
    
    if (!self.disableHeaderScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingForHeaderOffset:withState:)]) {
        [self.notificationDelegate sheetCell:self scrollingForHeaderOffset:scrollView.contentOffset withState:UIGestureRecognizerStateBegan];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (!self.disableScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingOffset:withState:)]) {
        [self.notificationDelegate sheetCell:self scrollingOffset:scrollView.contentOffset withState:UIGestureRecognizerStateEnded];
    }
    
    if (!self.disableHeaderScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingForHeaderOffset:withState:)]) {
        [self.notificationDelegate sheetCell:self scrollingForHeaderOffset:scrollView.contentOffset withState:UIGestureRecognizerStateEnded];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!self.disableScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingOffset:withState:)]) {
        if (decelerate) {
            [self.notificationDelegate sheetCell:self scrollingOffset:scrollView.contentOffset withState:UIGestureRecognizerStateChanged];
        }else {
            [self.notificationDelegate sheetCell:self scrollingOffset:scrollView.contentOffset withState:UIGestureRecognizerStateEnded];
        }
    }
    
    if (!self.disableHeaderScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingForHeaderOffset:withState:)]) {
        if (decelerate) {
            [self.notificationDelegate sheetCell:self scrollingForHeaderOffset:scrollView.contentOffset withState:UIGestureRecognizerStateChanged];
        }else {
            [self.notificationDelegate sheetCell:self scrollingForHeaderOffset:scrollView.contentOffset withState:UIGestureRecognizerStateEnded];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.disableScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingOffset:withState:)]) {
        [self.notificationDelegate sheetCell:self scrollingOffset:scrollView.contentOffset withState:UIGestureRecognizerStateEnded];
    }
    
    if (!self.disableHeaderScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingForHeaderOffset:withState:)]) {
        [self.notificationDelegate sheetCell:self scrollingForHeaderOffset:scrollView.contentOffset withState:UIGestureRecognizerStateEnded];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.disableScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingOffset:withState:)]) {
        [self.notificationDelegate sheetCell:self scrollingOffset:scrollView.contentOffset withState:UIGestureRecognizerStateChanged];
    }
    
    if (!self.disableHeaderScrollNotify && [self.notificationDelegate respondsToSelector:@selector(sheetCell:scrollingForHeaderOffset:withState:)]) {
        [self.notificationDelegate sheetCell:self scrollingForHeaderOffset:scrollView.contentOffset withState:UIGestureRecognizerStateChanged];
    }
}


#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:(arc4random() % 256) / 255.0 green:(arc4random() % 256) / 255.0 blue:(arc4random() % 256) / 255.0 alpha:1];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.columnWidths.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 实现一下流式布局自带的代理, 可以细化到具体某一个item的属性
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 高度-1是为了确保cell的高度不要超过collectionView
    return CGSizeMake(self.columnWidths[indexPath.item].doubleValue, self.frame.size.height - 1);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectedBlock) {
        self.didSelectedBlock(self.belongIndexPath);
    }
}

@end
