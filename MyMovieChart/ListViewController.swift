import UIKit

class ListViewController: UITableViewController {
    var page: Int = 1
    lazy var list: [MovieVO] = {
        var datalist = [MovieVO]()
        return datalist
    }()
    @IBOutlet var moreBtn: UIButton!
    
    override func viewDidLoad() {
        self.callMovieAPI()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.list[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MovieCell
        
        cell.title.text = row.title
        cell.desc.text = row.description
        cell.opendate.text = row.opendate
        cell.rating.text = "\(row.rating!)"
        
        DispatchQueue.main.async {
            cell.thumbnail.image = self.getThumbnailImage(indexPath.row)
        }
       
        
        return cell
    }
    
    override func tableView(_ tableView0: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    
    @IBAction func more(_ sender: Any) {
        self.page += 1
        
        self.callMovieAPI()
        self.tableView.reloadData()
    }
    
    func getThumbnailImage(_ index: Int) -> UIImage {
        let mvo = self.list[index]
        
        if let savedImage = mvo.thumbnailImage {
            return savedImage
        } else { 
            let url: URL! = URL(string: mvo.thumbnail!)
            let imageData = try! Data(contentsOf: url)
            mvo.thumbnailImage = UIImage(data: imageData)
            return mvo.thumbnailImage!
        }
    }
    
    func callMovieAPI() {
        let url = "http://swiftapi.rubypaper.co.kr:2029/hoppin/movies?version=1&page=\(self.page)&count=30&genreId=&order=releasedateasc"
        let apiURI: URL! = URL(string: url)
        
        do {
            let apidata = try Data(contentsOf: apiURI)
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            let hoppin = apiDictionary["hoppin"] as! NSDictionary
            let movies = hoppin["movies"] as! NSDictionary
            let movie = movies["movie"] as! NSArray
            let totalCount = (hoppin["totalCount"] as? NSString)!.integerValue
            
            for row in movie {
                let r = row as! NSDictionary
                let mvo = MovieVO()
                
                mvo.title = r["title"] as? String
                mvo.description = r["genreNames"] as? String
                mvo.thumbnail = r["thumbnailImage"] as? String
                mvo.detail = r["linkUrl"] as? String
                mvo.rating = ((r["ratingAverage"] as! NSString).doubleValue)
                
                let url: URL! = URL(string: mvo.thumbnail!)
                let imageData = try! Data(contentsOf: url)
                mvo.thumbnailImage = UIImage(data: imageData)
                
                self.list.append(mvo)
            }
            
            if self.list.count >= totalCount {
                self.moreBtn.isHidden = true
            }
        } catch {
            NSLog("오류 발생!")
        }
    }
}

extension ListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_detail" {
            let cell = sender as! MovieCell
            let path = self.tableView.indexPath(for: cell)
            let movieInfo = self.list[path!.row]
            let detailVC = segue.destination as? DetailViewController
            detailVC?.mvo = movieInfo
        }
    }
}
