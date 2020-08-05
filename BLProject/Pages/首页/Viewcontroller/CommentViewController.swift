//
//  CommentViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/21.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class CommentViewController: BaseViewController {
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var commentListBack: UIScrollView!
    
    @IBOutlet weak var scoreLb: UILabel!
    @IBOutlet weak var commentCountLb: UILabel!
    
    var commentInfo: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "商品评价", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        addCommentList()
        scoreLb.text = commentInfo!["dataObj"]["avgscore"].stringValue + "分"
        commentCountLb.text = "用户评价(\(commentInfo!["dataCount"].stringValue))"
    }
    
    func addCommentList() {
        let commentList = self.commentInfo!["dataList"].arrayValue
        var lastView: UIView?
        for (i,data) in commentList.enumerated() {
            let commentView = CommentView.init()
            commentListBack.addSubview(commentView)
            commentView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.width.equalTo(ScreenWidth)
                if lastView != nil {
                    make.top.equalTo(lastView!.snp.bottom).offset(20)
                }else{
                    make.top.equalToSuperview().offset(10)
                }
                if i == commentList.count - 1 {
                    make.bottom.lessThanOrEqualToSuperview().offset(-10)
                }
            }
            commentView.userIcon.kf.setImage(with: URL.init(string: data["icon"].string ?? ""))
            commentView.nameLb.text = data["nickname"].stringValue
            commentView.timeLb.text = data["evaltime"].stringValue
            commentView.contentLb.text = data["evalcontent"].stringValue
            commentView.starRatingView.value = CGFloat((data["score"].string ?? "0").floatValue)
            commentView.starRatingView.isUserInteractionEnabled = false
            lastView = commentView
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
