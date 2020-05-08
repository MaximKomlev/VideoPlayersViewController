//
//  ViewController.swift
//  ZoomController
//
//  Created by Maxim Komlev on 4/24/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit

private let resolutions = [
    360: CGSize(width: 360, height: 360 * 9 / 16),
    560: CGSize(width: 560, height: 560 * 9 / 16)]

struct ViewModel {
    private var items = [VideoItem]()
    
    init() {
        items.append(VideoItem(resolution: resolutions[360]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                               title: "Big Buck Bunny",
                               description: "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org"))
        items.append(VideoItem(resolution: resolutions[360]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                               title: "Elephant Dream",
                               description: "The first Blender Open Movie from 2006"))
        items.append(VideoItem(resolution: resolutions[360]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                               title: "For Bigger Blazes",
                               description: "HBO GO now works with Chromecast -- the easiest way to enjoy online video on your TV. For when you want to settle into your Iron Throne to watch the latest episodes. For $35.\nLearn how to use Chromecast with HBO GO and more at google.com/chromecast."))
        items.append(VideoItem(resolution: resolutions[560]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                               title: "For Bigger Escape",
                               description: "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when Batman's escapes aren't quite big enough. For $35. Learn how to use Chromecast with Google Play Movies and more at google.com/chromecast."))
        items.append(VideoItem(resolution: resolutions[360]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                               title: "For Bigger Fun",
                               description: "Introducing Chromecast. The easiest way to enjoy online video and music on your TV. For $35.  Find out more at google.com/chromecast."))
        items.append(VideoItem(resolution: resolutions[560]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                               title: "For Bigger Joyrides",
                               description: "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for the times that call for bigger joyrides. For $35. Learn how to use Chromecast with YouTube and more at google.com/chromecast."))
        items.append(VideoItem(resolution: resolutions[360]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                               title: "For Bigger Meltdowns",
                               description: "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when you want to make Buster's big meltdowns even bigger. For $35. Learn how to use Chromecast with Netflix and more at google.com/chromecast."))
        items.append(VideoItem(resolution: resolutions[560]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                               title: "Sintel",
                               description: "Sintel is an independently produced short film, initiated by the Blender Foundation as a means to further improve and validate the free/open source 3D creation suite Blender. With initial funding provided by 1000s of donations via the internet community, it has again proven to be a viable development model for both open 3D technology as for independent animation film.\nThis 15 minute film has been realized in the studio of the Amsterdam Blender Institute, by an international team of artists and developers. In addition to that, several crucial technical and creative targets have been realized online, by developers and artists and teams all over the world.\nwww.sintel.org"))
        items.append(VideoItem(resolution: resolutions[560]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
                               title: "Subaru Outback On Street And Dirt",
                               description: "Smoking Tire takes the all-new Subaru Outback to the highest point we can find in hopes our customer-appreciation Balloon Launch will get some free T-shirts into the hands of our viewers."))
        items.append(VideoItem(resolution: resolutions[360]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
                               title: "Tears of Steel",
                               description: "Tears of Steel was realized with crowd-funding by users of the open source 3D creation tool Blender. Target was to improve and test a complete open and free pipeline for visual effects in film - and to make a compelling sci-fi film in Amsterdam, the Netherlands.  The film itself, and all raw material used for making it, have been released under the Creatieve Commons 3.0 Attribution license. Visit the tearsofsteel.org website to find out more about this, or to purchase the 4-DVD box with a lot of extras.  (CC) Blender Foundation - http://www.tearsofsteel.org"))
        items.append(VideoItem(resolution: resolutions[360]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
                               title: "Volkswagen GTI Review",
                               description: "The Smoking Tire heads out to Adams Motorsports Park in Riverside, CA to test the most requested car of 2010, the Volkswagen GTI. Will it beat the Mazdaspeed3's standard-setting lap time? Watch and see..."))
        items.append(VideoItem(resolution: resolutions[560]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
                               title: "We Are Going On Bullrun",
                               description: "The Smoking Tire is going on the 2010 Bullrun Live Rally in a 2011 Shelby GT500, and posting a video from the road every single day! The only place to watch them is by subscribing to The Smoking Tire or watching at BlackMagicShine.com"))
        items.append(VideoItem(resolution: resolutions[560]!,
                               videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4",
                               title: "What care can you get for a grand?",
                               description: "The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far $1,000 can go when looking for a car.The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far $1,000 can go when looking for a car."))
    }
    
    var itemsCount: Int {
        return items.count
    }
    
    subscript(index: Int) -> VideoItem? {
        if index >= 0 && index < items.count {
            return items[index]
        }
        return nil
    }
}

class ViewController: UIViewController {
    
    // MARK: Fields
    
    private let viewModel = ViewModel()
    private var layout: CollectionViewLayout!
    
    private let contentView = UIScrollView()
    
    // MARK: Initializers/Deinitializer
    
    required convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        layout = CollectionViewLayout(layoutDelegate: self)
        layout.boundaryMargin = ThemeManager.shared.currentTheme.contentMargin
        layout.itemSpace = ThemeManager.shared.currentTheme.contentItemSpace
                
        view.backgroundColor = .white
        view.addSubview(contentView)
                
        for i in 0..<viewModel.itemsCount {
            if let itemModel = viewModel[i] {
                let controller = PlayerWidgetViewController(model: itemModel)
                addChild(controller)
                controller.didMove(toParent: self)
                contentView.addSubview(controller.view)
            }
        }
        
        layoutContentView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutContentView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // adjust scroll content position after rotation

        layout.performLayout(size)

        let currentOffset = contentView.contentOffset

        var newOffsetY = currentOffset.y * (size.height / view.bounds.height)
        let newSize = layout.contentSize
        let newRect = CGRect(origin: CGPoint(x: currentOffset.x, y: -newOffsetY), size: newSize)
        let delta = size.height - newRect.maxY
        
        if delta > layout.boundaryMargin {
            newOffsetY -= delta
        }
        
        coordinator.animate(alongsideTransition: { (ctx) in
            self.contentView.setContentOffset(CGPoint(x: currentOffset.x, y: newOffsetY), animated: false)
        }, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: Helpers
    
    private func layoutContentView() {
        layout.performLayout(view.bounds.size)
        contentView.contentSize = layout.contentSize
        contentView.bounds = view.bounds
        contentView.center = view.center

        for i in 0..<contentView.subviews.count {
            let subview = contentView.subviews[i]
            let rect = layout.itemRect(for: i)
            subview.bounds.size = rect.size
            subview.center = rect.origin
        }
    }
}

extension ViewController: CollectionViewLayoutDelegate {
    var itemsCount: Int {
        return viewModel.itemsCount
    }
    
    func itemSize(index: Int, widthConstrained: CGFloat) -> CGSize {
        guard let child = children[index] as? PlayerWidgetViewControllerProtocol else {
            return CGSize.zero
        }
        return child.sizeConstrained(to: widthConstrained)
    }
}
