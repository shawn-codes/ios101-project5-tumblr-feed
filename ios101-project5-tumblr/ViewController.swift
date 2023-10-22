//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows for the table.
        print("🍏 numberOfRowsInSection called with tumblr Posts count: \(tumblrPosts.count)")
        return tumblrPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Create the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        // Get the tumblr-associated table view row
        let tumblrPost = tumblrPosts[indexPath.row]
        
        if let photo = tumblrPost.photos.first {
            let url = photo.originalSize.url
            Nuke.loadImage(with: url, into: cell.posterImageView)
            
        }
           
        
        // Configure the cell (i.e. update UI elements like lables, image views, etc.)
        // cell.captionLabel?.text = tumblrPost.caption
        cell.summaryLabel?.text = tumblrPost.summary
        
        // Return the cell for use in the respective table view row
        print("🍏 cellForRowAt called for row: \(indexPath.row)")
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    private var tumblrPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        fetchPosts()
    }



    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in
                    

                    let posts = blog.response.posts
                    
                    self?.tumblrPosts = posts
                    self?.tableView.reloadData()
                    
                    print("🍏 Fetched and stored \(posts.count) tumblr posts")

                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
