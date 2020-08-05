//
//  SelectLocationViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/23.
//  Copyright ? 2018年 xinliang. All rights reserved.
//

import UIKit
import CoreLocation

enum PageState {
    case selectMyAddress
    case changeCity
    case search
}

class SelectLocationViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, BMKPoiSearchDelegate {
    
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var regreshBt: UIButton!
    @IBOutlet weak var topCityLb: UILabel!
    
    @IBOutlet weak var topBackHeight: NSLayoutConstraint!
    @IBOutlet weak var currentLocationBack: UIView!
    @IBOutlet weak var searchBt: UIButton!
    @IBOutlet weak var changeCityBt: UIButton!
    @IBOutlet weak var myAddressCardBack: UIView!
    @IBOutlet weak var addAderessBt: UIButton!
    @IBOutlet weak var selectMyAddressBack: UIView!
    @IBOutlet weak var selectMyAddressCornerBack: UIView!
    @IBOutlet weak var currentLocationLb: UILabel!
    @IBOutlet weak var refreshLocationBt: UIButton!
    @IBOutlet weak var changeCityBack: UIView!
    @IBOutlet weak var changeCityCornerBack: UIView!
    
    @IBOutlet weak var letterBack: UIView!
    @IBOutlet weak var cityListTable: UITableView!
    @IBOutlet weak var searchResultTable: UITableView!
    @IBOutlet weak var searchTextTF: UITextField!
    @IBOutlet weak var locationCityLb: UILabel!
    var titleLb: UILabel!
    var selectAddressClosure :((Any) -> Void)?
    var isAddNewAddress = false
    var cardDataList: Array<Any> = []
    
    var cityListData : Array<[String:[String]]>! = []
    
    var searchResultList: Array<Any> = []
    
    @IBOutlet weak var searchResultBack: UIView!
    @IBOutlet weak var searchResultCornerBack: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSubviews()
        self.getLocationResult = { (location, state, error) in
            if error == nil {
                print(location?.rgcData?.city ?? "未定位出城市")
                let newCityString = location?.rgcData?.city ?? "未定位出城市"
                self.locationCityLb.text = newCityString
                self.topCityLb.text = newCityString
                self.currentLocationLb.text = (location?.rgcData?.poiList ?? []).first?.name
            }else{
                self.currentLocationLb.text = "定位失败"
                self.locationCityLb.text = "定位失败"
                self.topCityLb.text = "定位失败"
            }
        }
        getLocation()
    }
    
func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        titleLb = self.addTitle(title: "选择收货地址", naviBackView: naviBack)
        self.addCustomCorner(with: selectMyAddressCornerBack, radius: 14)
        self.addCustomCorner(with: changeCityCornerBack, radius: 14)
        self.addCustomCorner(with: searchResultCornerBack, radius: 14)
        if isAddNewAddress {
            if titleLb != nil {
                titleLb.text = "选择地址"
            }
            self.showCurrentView(state: .search)
        }else{
            self.getAddressList()
        }
    refreshLocationBt.onTap {
        self.getLocation()
    }

        setChangeCityView()
        changeCityBt.onTap {
            self.showCurrentView(state: .changeCity)
        }
        searchBt.onTap {
            let city = self.topCityLb.text!
            if city == "定位失败" {
                self.view.makeToast("请手动选择城市")
                return
            }
            self.showCurrentView(state: .search)
        }
        addAderessBt.onTap {
            let pushedVC = AddAddressViewController.init(nibName: "AddAddressViewController", bundle: nil)
            pushedVC.addressListPage = self
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        setUpSearchResultView()
        searchTextTF.shouldEndEditing { () -> Bool in
            if self.searchTextTF.text?.length == 0 {
                self.searchTextTF.text = "输入关键词进行搜索"
            }
            return true
        }
        searchTextTF.onChange { (string) in
            self.getNewLocationList(with: string)
        }
    }

    func getAddressList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
        ] as [String : Any]
        NetworkManager.request(api: .addressList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.cardDataList = jsonObj["dataList"].arrayValue
                    self.addAddressCards(with: self.cardDataList)
                    self.showCurrentView(state: .selectMyAddress)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    let searcher = BMKPoiSearch.init()
    
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            self.searchResultList = poiResult.poiInfoList
            self.searchResultTable.reloadData()
        }
    }
    
    func getNewLocationList(with text: String) {
        searcher.delegate = self
        let citySearchOption = BMKPOICitySearchOption.init()
        citySearchOption.pageIndex = 0
        citySearchOption.pageSize = 20
        let city = self.topCityLb.text!
        if city == "定位失败" {
            self.view.makeToast("请手动选择城市")
            return
        }
        citySearchOption.city = city
        citySearchOption.keyword = text
        
        let relust = self.searcher.poiSearch(inCity: citySearchOption)
        
        if relust {
            print("检索发送失败")
        }
    }
    
    func showCurrentView(state: PageState) {
        switch state {
        case .selectMyAddress:
            changeCityBack.isHidden = true
            selectMyAddressBack.isHidden = false
            searchResultBack.isHidden = true
            topBackHeight.constant = 90
            currentLocationBack.isHidden = false
        case .changeCity:
            changeCityBack.isHidden = false
            selectMyAddressBack.isHidden = true
            searchResultBack.isHidden = true
            topBackHeight.constant = 60
            currentLocationBack.isHidden = true
            self.cityListTable.reloadData()
        case .search:
            changeCityBack.isHidden = true
            selectMyAddressBack.isHidden = true
            searchResultBack.isHidden = false
            topBackHeight.constant = 60
            currentLocationBack.isHidden = true
            searchResultList = []
            self.searchResultTable.reloadData()
            searchTextTF.becomeFirstResponder()
            searchTextTF.text = nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func addAddressCards(with list: [Any]) {
        var lastView: UIView?
        for (i, data) in list.enumerated() {
            let addressData = data as! JSON
            let addressCard = MyAddressView.init(frame: CGRect.zero)
           addressCard.nameLb.text = addressData["receivename"].string ?? " "
            addressCard.phoneLb.text = addressData["receivephone"].stringValue
            addressCard.addressLb.text = addressData["fullAddress"].stringValue
            myAddressCardBack.addSubview(addressCard)
            
            addressCard.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(15)
//                make.height.equalTo(43)
                if lastView != nil {
                    make.top.equalTo(lastView!.snp.bottom).offset(5)
                }else{
                    make.top.equalToSuperview()
                }
                if i == list.count - 1 {
                    make.bottom.equalToSuperview().offset(-15)
                }
            }
            lastView = addressCard
        }
    }
    
    func setUpSearchResultView() {
        searchResultTable.register(UINib.init(nibName: "SearchResultCell", bundle: nil), forCellReuseIdentifier: "SearchResultCell")
        searchResultTable.estimatedRowHeight = 50
        searchResultTable.tableFooterView = UIView.init()
    }
    
    func setChangeCityView() {
//        getCityName()
        locationCityLb.superview?.addTapGesture(handler: { (tapGesture) in
            if self.locationCityLb.text != "定位失败" {
                self.selectCity(name: self.locationCityLb.text!)
            }
        })
        var letterList = Array<String>.init()
        var newCityList = Array<Any>.init()
        DispatchQueue.global().async {
            let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "cityList", ofType: "json")!))
            let cityList = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String]
            
            
            var jsonDic = Dictionary<String, [String]>.init()
            for tempCity in cityList {
                let keyLetter = tempCity.transformToPinYin().substring(to: 1).uppercased()
                guard var array = jsonDic[keyLetter] else {
                    jsonDic[keyLetter] = [tempCity]
                    letterList.append(keyLetter)
                    continue
                }
                array.append(tempCity)
                jsonDic[keyLetter] = array
            }
            
            letterList.sort { (first, second) -> Bool in
                return first < second
            }
            
            for tempKey in letterList {
                newCityList.append([tempKey : jsonDic[tempKey]])
            }
            
            DispatchQueue.main.async {
                var lastView : UIView?
                for tempKey in letterList {
                    let letterLb = UILabel.init()
                    self.letterBack.addSubview(letterLb)
                    letterLb.snp.makeConstraints { (make) in
                        make.leading.trailing.equalToSuperview()
                        make.height.equalTo(15)
                        make.centerX.equalToSuperview()
                        if lastView != nil {
                            make.top.equalTo(lastView!.snp.bottom).offset(2)
                        }else{
                            make.top.equalToSuperview()
                        }
                        if tempKey == letterList.last {
                            make.bottom.equalToSuperview()
                        }
                    }
                    letterLb.text = tempKey
                    letterLb.textColor = #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.3294117647, alpha: 1)
                    letterLb.font = UIFont.systemFont(ofSize: 12)
                    letterLb.textAlignment = .center

                    lastView = letterLb
                }
                self.letterBack.backgroundColor = UIColor.clear

                self.cityListData = newCityList as! Array<[String : [String]]>
                
                self.cityListTable.reloadData()
                self.cityListTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
                
            }
        }
    }
    
    func getCityName() {
        self.locationCityLb.text = "正在定位..."
        _ = CLLocationManager.promise().then { location in
            return CLGeocoder().reverseGeocode(location: location.first!)
            }.done { (placeMark) in
                guard let cityString = placeMark.first?.addressDictionary?["City"] as? String else{
                    self.locationCityLb.text = "定位失败"
                    return
                }
                let newCityString = cityString.substring(to: cityString.length - 1)
                self.locationCityLb.text = newCityString
                self.topCityLb.text = newCityString
                debugPrint(self.locationCityLb.text as Any)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if changeCityBack.isHidden {
            return
        }
        let point = touches.first?.location(in: letterBack)
        makeCityListRightPosition(with: point!, needAnimated: true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if changeCityBack.isHidden {
            return
        }
        let point = touches.first?.location(in: letterBack)
        makeCityListRightPosition(with: point!, needAnimated: false)
    }
    
    func makeCityListRightPosition(with point: CGPoint, needAnimated: Bool) {
        if changeCityBack.isHidden {
            return
        }
        if point.x < 0 || point.y < 0 {
            return
        }
        var scrollIndex = 0
        for (index,tempView) in letterBack.subviews.enumerated() {
            if tempView.frame.contains(point) {
                scrollIndex = index
                if scrollIndex < 0 {
                    scrollIndex = 0
                }
                break
            }
        }
        
        cityListTable.scrollToRow(at: IndexPath.init(row: 0, section: scrollIndex), at: .top, animated: needAnimated)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == cityListTable {
            return 28
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView != cityListTable {
            return nil
        }
        return cityListData[section].keys.first!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == cityListTable {
            return cityListData.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cityListTable {
            return cityListData[section].values.first!.count
        }
        return searchResultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == cityListTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = cityListData[indexPath.section].values.first![indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        let tempAddress = searchResultList[indexPath.row] as! BMKPoiInfo
        cell.nameLb.text = tempAddress.name
        cell.addressLb.text = tempAddress.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cityListTable {
            self.selectCity(name: cityListData[indexPath.section].values.first![indexPath.row])
        }else{
            let tempAddress = searchResultList[indexPath.row] as! BMKPoiInfo
            self.selectAddressClosure?(tempAddress)
            self.popBack()
        }
    }
    
    func selectCity(name: String) {
        topCityLb.text = name
        if isAddNewAddress {
            self.showCurrentView(state: .search)
        }else{
            self.showCurrentView(state: .selectMyAddress)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class MyAddressView: BaseView {
    
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var addressLb: UILabel!
    
    func setupSubViews() {
        
    }
    
    //初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customLoadNibView()
        setupSubViews()
    }
    
    //初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customLoadNibView()
        setupSubViews()
    }
    
    @objc func injected() {
        //        setupSubViews()
        
    }
}

class SearchResultCell: BaseTableViewCell {
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var addressLb: UILabel!
    
}
