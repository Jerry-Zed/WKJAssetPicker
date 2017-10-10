//
//  WKJAssetsPicker.m
//  WKJAssetPickerDemo
//
//  Created by 王恺靖 on 15/12/16.
//  Copyright © 2015年 王恺靖. All rights reserved.
//

#import "WKJAssetsPicker.h"
#import "WKJAssetsPickCell.h"

#import "MBProgressHUD.h"

#define ThumbnailLength             ([UIScreen mainScreen].bounds.size.width-2)/3
#define ThumbnailSize               CGSizeMake(ThumbnailLength, ThumbnailLength)
#define PickerContentSize           [UIScreen mainScreen].bounds.size

#define AssetsViewCellIdentifier    @"AssetsViewCellIdentifier"
#define AssetsPhotoCellIdentifier   @"AssetsPhotoCellIdentifier"

#define SelectedBackColor    [UIColor colorWithRed:207/255.0 green:6/255.0 blue:6/255.0 alpha:1]
#define UnSelectedBackColor  [UIColor lightGrayColor]

@interface WKJAssetsPicker ()<UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WKJAssetsPickCellDelegate>

@property (nonatomic, strong) NSMutableArray *assets;

@property (nonatomic, assign) NSInteger numberOfPhotos;

@property (nonatomic, strong) NSMutableArray *selectedAssets;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation WKJAssetsPicker

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maxmumNumber = NSIntegerMax;
        self.selectedAssets = [[NSMutableArray alloc] init];
        self.assets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupViews];
    [self checkStatus];
}

#pragma mark UI

- (void)setupNavigationBar
{
    self.title = @"请选择照片";
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor blackColor]};
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"WKJAssetsPickerBack"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(backItemAction)];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.clipsToBounds = YES;
    rightBtn.layer.cornerRadius = 5.f;
    rightBtn.bounds = CGRectMake(0, 0, 40, 25);
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    rightBtn.backgroundColor = UnSelectedBackColor;
    
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setBackgroundColor:UnSelectedBackColor];
    [rightBtn addTarget:self action:@selector(rightItemAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.rightBtn = rightBtn;
}

- (void)setupViews
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = ThumbnailSize;
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    
    CGFloat margen = 64.f;
    
    if (PickerContentSize.height >= 812 && PickerContentSize.width <= 375) {
        margen = margen + 34.f + 24.f;
    }
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, PickerContentSize.width, PickerContentSize.height - margen) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[WKJAssetsPickCell class] forCellWithReuseIdentifier:AssetsViewCellIdentifier];
    
    [self.view addSubview:_collectionView];
}

- (void)updateTitle
{
    if (self.selectedAssets.count == 0) {
        self.rightBtn.backgroundColor = UnSelectedBackColor;
        self.title = @"请选择照片";
    }
    else {
        self.rightBtn.backgroundColor = SelectedBackColor;
        self.title = [NSString stringWithFormat:@"已选 %ld 张",self.selectedAssets.count];
    }    
}

- (void)showAlertViewWithMessage:(NSString*)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = message;
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:1.5];
}

- (MBProgressHUD*)getNormalHUD
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"正在从iCloud同步照片";
    return hud;
}

#pragma mark setup data

- (void)checkStatus
{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {

            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (status == PHAuthorizationStatusAuthorized) {
                    [self getAssets];
                }
                else {
                    [self showAlertViewWithMessage:@"授权失败"];
                }
            });
        }];
    }
    else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        [self getAssets];
    }
    else {
        [self showAlertViewWithMessage:@"相册未授权"];
    }
}

- (void)getAssets
{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        options.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    }
    
    PHAssetCollection *cameraRoll = [[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:options] lastObject];
    
    if (cameraRoll == nil) {
        [self showAlertViewWithMessage:@"您当前暂无任何照片哦"];
        return;
    }
    
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
    
    for (PHAsset *asset in result) {
        WKJAsset *wkj_asset = [WKJAsset new];
        wkj_asset.asset = asset;
        wkj_asset.selected = NO;
        [self.assets addObject:wkj_asset];
    }
    
    [self.collectionView reloadData];
}

- (void)requestAsset
{
    BOOL originalPhoto = NO;
    
    if ([self.delegate respondsToSelector:@selector(assetsPickerShouldReturnOriginalPhotos)]) {
        originalPhoto = [self.delegate assetsPickerShouldReturnOriginalPhotos];
    }
    
    MBProgressHUD *hud = [self getNormalHUD];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        
        for (WKJAsset *asset in self.selectedAssets) {
            
            [self requestAsset:asset.asset originalPhoto:originalPhoto complete:^(UIImage *image) {
                
                if (image) {
                    [photos addObject:image];
                }
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [hud hide:YES];
            
            if (photos.count != self.selectedAssets.count) {
                [self showAlertViewWithMessage:@"照片同步失败~"];
                return;
            }
            
            if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishedPickingPhotos:)]) {
                [self.delegate assetsPickerController:self didFinishedPickingPhotos:[photos copy]];
                [self backItemAction];
            }
        });
    });
}

#pragma mark WKJAssetsPickCellDelegate

- (void)didSelectAsset:(WKJAsset *)asset
{
    asset.selected = !asset.selected;
    
    if (!asset.selected) {
        [self.selectedAssets removeObject:asset];
        [self.collectionView reloadData];
        [self updateTitle];
        return;
    }
    
    if (self.selectedAssets.count + 1 > self.maxmumNumber) {
        asset.selected = NO;
        NSString *msg = [NSString stringWithFormat:@"最多只能选%ld张哦",(long)self.maxmumNumber];
        [self showAlertViewWithMessage:msg];
        return;
    }
    
    [self.selectedAssets addObject:asset];
    [self.collectionView reloadData];
    [self updateTitle];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count+1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = AssetsViewCellIdentifier;
    WKJAssetsPickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
        cell.takePhoto = YES;
    }
    else {
        cell.takePhoto = NO;
        cell.delegate = self;
        cell.asset = [self.assets objectAtIndex:self.assets.count-indexPath.row];
    }
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        [self checkCameraStatus];
    }
}

#pragma mark navigation action

- (void)backItemAction
{
    if (self.navigationController.presentingViewController && self.navigationController.childViewControllers.count <= 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightItemAction
{
    if (self.selectedAssets.count == 0) {
        [self showAlertViewWithMessage:@"还未选择相片呢"];
    }
    else {
        [self requestAsset];
    }
}

- (void)requestAsset:(PHAsset*)asset originalPhoto:(BOOL)originalPhoto complete:(void (^)(UIImage*))complete
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.networkAccessAllowed = ![self checkLocalPhoto:asset];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    CGSize th_size = CGSizeMake(300, 300);
    CGSize or_size = CGSizeMake(asset.pixelWidth/2.0, asset.pixelHeight/2.0);
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:originalPhoto?or_size:th_size
                                              contentMode:PHImageContentModeAspectFill
                                                  options:options
     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                
         complete(result);
    }];
}

- (BOOL)checkLocalPhoto:(PHAsset*)asset
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = NO;
    
    __block BOOL isLocalPhoto = NO;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                      options:options
     resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
         
         isLocalPhoto = imageData ? YES : NO;
     }];
    
    return isLocalPhoto;
}

- (void)checkCameraStatus
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (authStatus == AVAuthorizationStatusNotDetermined) {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (granted) {
                        [self takePhoto];
                    }
                    else {
                        [self showAlertViewWithMessage:@"相机未授权"];
                    }
                });
            }];
        }
        else if(authStatus == AVAuthorizationStatusAuthorized) {
            [self takePhoto];
        }
        else {
            [self showAlertViewWithMessage:@"相机未授权"];
        }
        
    }
    else {
        [self showAlertViewWithMessage:@"请检查您的相机！"];
    }
}

- (void)takePhoto
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.showsCameraControls = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark imagePickerDelegaet

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if ([_delegate respondsToSelector:@selector(assetsPickerController:didFinishedTakePhotos:)]) {
        [_delegate assetsPickerController:self didFinishedTakePhotos:image];
    }
    
    [self backItemAction];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
