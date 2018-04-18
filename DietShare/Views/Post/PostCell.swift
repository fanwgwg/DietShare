//
//  PostCell.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak private var userPhoto: UIButton!
    @IBOutlet weak private var userName: UILabel!
    @IBOutlet weak private var postImage: UIImageView!
    @IBOutlet weak private var caption: UILabel!
    @IBOutlet weak private var likeCount: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak private var commentCount: UIButton!
    @IBOutlet weak private var time: UILabel!
    @IBOutlet weak private var restaurant: UIButton!
    @IBOutlet weak private var topics: UICollectionView!
    @IBOutlet weak var topicsLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var topicsHeight: NSLayoutConstraint!
    @IBOutlet weak var restaurantHeight: NSLayoutConstraint!
    
    private var post: Post!
    private var topicsData: [String] = []
    var cellDelegate: PostCellDelegate?
    let columnLayout = FlowLayout(
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    )
    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "TopicCell", bundle: nil)
        topics.register(nibName, forCellWithReuseIdentifier: "topicCell")
//        let layout = LeftAlignedCollectionViewFlowLayout()
//        layout.estimatedItemSize = CGSize(width: 100, height: 12)
        topics.collectionViewLayout = columnLayout
        if #available(iOS 11.0, *) {
            topics.contentInsetAdjustmentBehavior = .always
        } else {
            
        }
        //topicsLayout.estimatedItemSize = CGSize(width: 100, height: 12)
        topics.allowsSelection = true
        topics.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        userName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onNameClicked)))
        userName.isUserInteractionEnabled = true
    }
    @objc func tap(sender: UITapGestureRecognizer){
        
        if let indexPath = topics.indexPathForItem(at: sender.location(in: topics)) {
            print(indexPath.item)
            self.cellDelegate?.goToTopic(topicsData[indexPath.item])
        } else {
            print("collection view was tapped")
        }
    }
    func setUserPhoto(_ photo: UIImage) {
        userPhoto.setImage(photo, for: .normal)
        userPhoto.layer.cornerRadius = userPhoto.frame.height / 8
        userPhoto.clipsToBounds = true
    }
    func setUserName(_ name: String) {
        userName.text = name
    }
    func setPostImage(_ photo: UIImage) {
        postImage.image = photo
    }
    func setCaption(_ caption: String) {
        self.caption.text = caption
    }
    func setLikeCount(_ count: String) {
        likeCount.setTitle(count, for: .normal)
    }
    func setCommentCount(_ count: String) {
        commentCount.setTitle(count, for: .normal)
    }
    func setTime(_ time: String) {
        self.time.text = time
    }
    func setTopics(_ topics: [String]?) {
        guard let tps = topics else {
            self.topicsHeight.constant = 0.0
            return
        }
        topicsData = []
        for topic in tps {
            topicsData.append(topic)
        }
    }
    func setRestaurant(_ restaurant: String?) {
        guard let res = restaurant else {
            self.restaurantHeight.constant = 0.0
            return
        }
        guard let data = RestaurantsModelManager.shared.getRestaurantFromID(res) else {
            return
        }
        self.restaurant.setTitle(data.getName(), for: .normal)
    }
    func setContent(userPhoto: UIImage, userName: String, _ post: Post) {
        self.post = post
        setUserPhoto(userPhoto)
        setUserName(userName)
        setPostImage(post.getPhoto())
        setCaption(post.getCaption())
        setLikeCount(String(post.getLikesCount()))
        setCommentCount(String(post.getCommentsCount()))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        setTime(dateFormatter.string(from: post.getTime()))
        setTopics(post.getTopics())
        setRestaurant(post.getRestaurant())
//        let likes = PostManager.shared.getLikes(post.getPostId())
//        if let currentUser = UserModelManager.shared.getCurrentUser()?.getUserId() {
//            for lk in likes {
//                if lk.getUserId() == currentUser {
//                    likeButton.setImage(UIImage(named: "heart")!, for: .normal)
//                    likeButton.setTitle("liked", for: .normal)
//                    break
//                }
//            }
//        }
    }
    func setDelegate(_ cellDelegate: PostCellDelegate) {
        self.cellDelegate = cellDelegate
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicsData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topicCell", for: indexPath) as? TopicCell  else {
            fatalError("The dequeued cell is not an instance of TopicCell.")
        }

        cell.topicLabel.text = TopicsModelManager.shared.getTopicFromID(topicsData[indexPath.item])!.getName()
        //cell.topicLabel.sizeToFit()
        cell.layer.cornerRadius = 3
        cell.topicLabel.clipsToBounds = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(topicsData[indexPath.item])
        self.cellDelegate?.goToTopic(topicsData[indexPath.item])
    }
    @objc func onNameClicked(sender: UITapGestureRecognizer) {
        self.cellDelegate?.goToUser(post.getUserId())
    }
    @IBAction func onUserClicked(_ sender: Any) {
        self.cellDelegate?.goToUser(post.getUserId())
    }
    @IBAction func onCommentCountClicked(_ sender: Any) {
        self.cellDelegate?.goToDetail(post.getPostId(), 0)
    }
    @IBAction func onCommentClicked(_ sender: Any) {
        self.cellDelegate?.onCommentClicked(post.getPostId())
    }
    @IBAction func onLikeCountClicked(_ sender: Any) {
        self.cellDelegate?.goToDetail(post.getPostId(), 1)
    }
    @IBAction func onLikeClicked(_ sender: Any) {
        if likeButton.currentTitle == "unlike" {
            likeButton.setImage(UIImage(named: "heart")!, for: .normal)
            likeButton.setTitle("liked", for: .normal)
            PostManager.shared.postLike(Like(userId: UserModelManager.shared.getCurrentUser()!.getUserId(), postId: post.getPostId(), time: Date()))
            self.cellDelegate?.updateCell()
        } else {
            likeButton.setImage(UIImage(named: "like")!, for: .normal)
            likeButton.setTitle("unlike", for: .normal)
            PostManager.shared.deleteLike(Like(userId: UserModelManager.shared.getCurrentUser()!.getUserId(), postId: post.getPostId(), time: Date()))
            self.cellDelegate?.updateCell()
        }
    }
    
    @IBAction func onRestaurantClicked(_ sender: Any) {
         self.cellDelegate?.goToRestaurant(post.getRestaurant()!)
    }
    
    func getPost() -> Post{
        return post
    }
    func resizeTopics() {
        topicsHeight.constant = topics.contentSize.height
    }
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let attributes = super.layoutAttributesForElements(in: rect)
//
//        var leftMargin = sectionInset.left
//        var maxY: CGFloat = -1.0
//        attributes?.forEach { layoutAttribute in
//            if layoutAttribute.frame.origin.y >= maxY {
//                leftMargin = sectionInset.left
//            }
//
//            layoutAttribute.frame.origin.x = leftMargin
//
//            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
//            maxY = max(layoutAttribute.frame.maxY , maxY)
//        }
//
//        return attributes
//    }
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//
//        let layoutAttribute = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
//
//        // First in a row.
//        if layoutAttribute?.frame.origin.x == sectionInset.left {
//            return layoutAttribute
//        }
//
//        // We need to align it to the previous item.
//        let previousIndexPath = NSIndexPath(item: indexPath.item - 1, section: indexPath.section)
//        guard let previousLayoutAttribute = self.layoutAttributesForItem(at: previousIndexPath as IndexPath) else {
//            return layoutAttribute
//        }
//
//        layoutAttribute?.frame.origin.x = previousLayoutAttribute.frame.maxX + self.minimumInteritemSpacing
//
//        return layoutAttribute
//    }
}
class FlowLayout: UICollectionViewFlowLayout {
    
    required init(minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        super.init()
        
        estimatedItemSize = CGSize(width: 100, height: 12)
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        if #available(iOS 11.0, *) {
            sectionInsetReference = .fromSafeArea
        } else {
            // Fallback on earlier versions
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        guard scrollDirection == .vertical else { return layoutAttributes }
        
        // Filter attributes to compute only cell attributes
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })
        
        // Group cell attributes by row (cells with same vertical center) and loop on those groups
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 }) {
            // Set the initial left inset
            var leftInset = sectionInset.left
            
            // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }
        
        return layoutAttributes
    }
    
}

