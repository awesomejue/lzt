//
//  XGZLViewController.m
//  lzt
//
//  Created by hwq on 2017/12/6.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "XGZLViewController.h"
#import "XGZLCollectionViewCell.h"
#import "BigImage.h"
#import "UIImageView+WebCache.h"
#import "HUPhotoBrowser.h"
#import "UIImageView+HUWebImage.h"

@interface XGZLViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic)NSMutableArray *images;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NavHeight;
@end

@implementation XGZLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    [self createCollectionView];
    if (iPhoneX) {
        _NavHeight.constant += 20;
    }
    if (_dataSource.count == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
        
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, Screen_Height/4, Screen_Width, 50);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"没有相关资料!";
        label.font = [UIFont systemFontOfSize:20];
        [view addSubview:label];
        [self.collectionView addSubview:view];
        [self.collectionView bringSubviewToFront:view];
    }else {
        [self.collectionView reloadData];
    }
    _images = [[NSMutableArray alloc]init];
    for(int i = 0; i<_dataSource.count; i++){
        [_images addObject:_dataSource[i][@"url"]];
    }
   // [_images addObject:@"https://gss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/b812c8fcc3cec3fd84e2d8d4df88d43f869427b6.jpg"];
   // [_images addObject:@"https://gss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/b812c8fcc3cec3fd84e2d8d4df88d43f869427b6.jpg"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}
- (void)createCollectionView {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing      = 1;
    layout.minimumInteritemSpacing = 1;
    layout.scrollDirection         = UICollectionViewScrollDirectionVertical;
    
    [self.collectionView setCollectionViewLayout:layout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"XGZLCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _images.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XGZLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
   // NSString *image = _dataSource[indexPath.row][@"url"];
    NSString *image = _images[indexPath.row];
   // cell.s = UITableViewCellSelectionStyleNone;
    //  cell.MyimageView.image = [[UIImage alloc]initWithContentsOfFile:image];
    image = [FuncPublic imageEncode:image];
    //  cell.MyimageView.image = [UIImage imageWithData:[NSData
    //                               dataWithContentsOfURL:[NSURL URLWithString:image]]];
    // cell.MyimageView.image = [UIImage imageNamed:@"news.jpg"];
    [cell.imageVIEW sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:@""]];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //放大图片
    XGZLCollectionViewCell *cell = (XGZLCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
     [HUPhotoBrowser showFromImageView:cell.imageVIEW withURLStrings:_images placeholderImage:[UIImage imageNamed:@""] atIndex:indexPath.row dismiss:nil];
    //[HUPhotoBrowser showFromImageView:cell.imageVIEW withURLStrings:_images atIndex:indexPath.row];
    
//    [BigImage showImage:cell.imageVIEW];
//
//    // 1. 创建photoBroseView对象
//    PYPhotoBrowseView *photoBroseView = [[PYPhotoBrowseView alloc] init];
//    NSArray *imagetest = @[@"data_one.png",@"data_one.png"];
////    // 2.1 设置图片源(UIImageView)数组
//    photoBroseView.images = imagetest;
////    // 2.2 设置初始化图片下标（即当前点击第几张图片）
//    photoBroseView.currentIndex = indexPath.row;
////
////    // 3.显示(浏览)
//    [photoBroseView show];
//    // 2. 创建一个photosView
//    PYPhotosView *photosView = [PYPhotosView photosViewWithThumbnailUrls:imagetest originalUrls:imagetest];
    
    // 3. 添加photosView
   // [self.view addSubview:photosView];
    //[self.view bringSubviewToFront:photosView];
//    STPhotoBroswer * broser = [[STPhotoBroswer alloc]initWithImageArray:_images currentIndex:0];
//    [broser show];
}




//每行之间的最小间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1.0f;
}

//每个item(cell)的最小间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.5f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
     return  CGSizeMake(Screen_Width *0.33, Screen_Height * 0.15);
    //return  CGSizeMake(90, 90);
}



@end
