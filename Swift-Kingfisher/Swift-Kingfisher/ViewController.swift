//
//  ViewController.swift
//  Swift-Kingfisher
//
//  Created by Alan Yen on 2017/6/3.
//  Copyright © 2017年 Alan-App. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UICollectionViewController {
    
    let demoTypeCount = 12

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Kingfisher"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearCache(sender: AnyObject) {
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }
    
    @IBAction func reload(sender: AnyObject) {
        collectionView?.reloadData()
    }
    
    func urlByIndexPath(_ indexPath: IndexPath?) -> URL {
    
        if let indexPath = indexPath {
            let url = URL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-\(indexPath.item + 1).jpg")!
            return url
        }
        return URL(string: "")!
    }
}

extension ViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return demoTypeCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.cellImageView.kf.indicatorType = .activity
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let url = urlByIndexPath(indexPath)
        let imageView = (cell as! CollectionViewCell).cellImageView!
        if indexPath.item % demoTypeCount == 0 {
            configCellImage_type00(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 1 {
            configCellImage_type01(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 2 {
            configCellImage_type02(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 3 {
            configCellImage_type03(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 4 {
            configCellImage_type04(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 5 {
            configCellImage_type05(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 6 {
            configCellImage_type06(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 7 {
            configCellImage_type07(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 8 {
            configCellImage_type08(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 9 {
            configCellImage_type09(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 10 {
            configCellImage_type10(imageView, forImageUrl: url)
        }
        else if indexPath.item % demoTypeCount == 11 {
            configCellImage_type11(imageView, forImageUrl: url)
        }

        
//
//        let url = URL(string: "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-\(indexPath.item + 1).jpg")!
//        
//        let collectionViewCell = cell as! CollectionViewCell
//        _ = collectionViewCell
//            .cellImageView
//            .kf.setImage(with: url,
//                         placeholder: nil,
//                         options: [.transition(ImageTransition.fade(1))],
//                         progressBlock: { receivedSize, totalSize in
//                            print("\(indexPath.item + 1): \(receivedSize)/\(totalSize)")
//            },
//                         completionHandler: { image, error, cacheType, imageURL in
//                            print("\(indexPath.item + 1): Finished")
//            })
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // This will cancel all unfinished downloading task when the cell disappearing.
        (cell as! CollectionViewCell).cellImageView.kf.cancelDownloadTask()
    }
}

extension ViewController {

    func configCellImage_type00(_ imageView: UIImageView, forImageUrl url: URL) {
        
        // Simply set an image from url to an image view
        
        _ = imageView.kf.setImage(with: url)
    }
    
    func configCellImage_type01(_ imageView: UIImageView, forImageUrl url: URL) {
        
        // Use a specified key other than the url for cache

        let resource = ImageResource.init(downloadURL: url, cacheKey: url.absoluteString.lowercased())
        _ = imageView.kf.setImage(with: resource)
    }
    
    func configCellImage_type02(_ imageView: UIImageView, forImageUrl url: URL) {
        
        // With a placeholder image while downloading
        
        let image = UIImage(named: "Placeholder.png")
        _ = imageView.kf.setImage(with: url, placeholder: image)
    }
    
    func configCellImage_type03(_ imageView: UIImageView, forImageUrl url: URL) {
    
        // With a completion handler
        
        _ = imageView.kf.setImage(with: url, completionHandler: {
                (image, error, cacheType, imageUrl) in
                if let image = image {
                    print("image.size => \(image.size)")
                }
                // image: Image? `nil` means failed
                // error: NSError? non-`nil` means failed
                // cacheType: CacheType
                //                  .none - Just downloaded
                //                  .memory - Got from memory cache
                //                  .disk - Got from disk cache
                // imageUrl: URL of the image
        })
    }
    
    func configCellImage_type04(_ imageView: UIImageView, forImageUrl url: URL) {
    
        // With a loading indicator while downloading
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url)
    }
    
    func configCellImage_type05(_ imageView: UIImageView, forImageUrl url: URL) {
        
        // Use your own GIF file or any image as the indicator image while downloading
        
        let p = Bundle.main.path(forResource: "loader", ofType: "gif")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: p))
        
        imageView.kf.indicatorType = .image(imageData: data)
        imageView.kf.setImage(with: url)
    }
    
    func configCellImage_type06(_ imageView: UIImageView, forImageUrl url: URL) {

        // Customize the indicator with any view you want
    
        struct MyIndicator: Indicator {
            let view: UIView = UIView()
            
            func startAnimatingView() { view.isHidden = false }
            func stopAnimatingView() { view.isHidden = true }
            
            init() {
                view.backgroundColor = .red
            }
        }
        
        let i = MyIndicator()
        imageView.kf.indicatorType = .custom(indicator: i)
        imageView.kf.setImage(with: url)
    }
    
    func configCellImage_type07(_ imageView: UIImageView, forImageUrl url: URL) {
        
        // Add a fade transition when setting image after downloaded
        
        // imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        imageView.kf.setImage(with: url, options: [.transition(.flipFromLeft(1.0))])
    }
    
    func configCellImage_type08(_ imageView: UIImageView, forImageUrl url: URL) {
    
        // Transform downloaded image to round corner before displaying and caching
        
        let processor = RoundCornerImageProcessor(cornerRadius: 20)
        imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
    }
    
    func configCellImage_type09(_ imageView: UIImageView, forImageUrl url: URL) {
    
        // Apply multiple processor before setting the image
        
        let processor = BlurImageProcessor(blurRadius: 4) >> RoundCornerImageProcessor(cornerRadius: 20)
        imageView.kf.setImage(with: url, placeholder: nil, options: [.processor(processor)])
    }
    
    func configCellImage_type10(_ imageView: UIImageView, forImageUrl url: URL) {
        
        // Skip cache searching, force downloading image again
        
        imageView.kf.setImage(with: url, options: [.forceRefresh])
    }
    
    func configCellImage_type11(_ imageView: UIImageView, forImageUrl url: URL) {
        
        // Only search cache for the image, do not download if not existing
        
        imageView.kf.setImage(with: url, options: [.onlyFromCache])
    }
}
