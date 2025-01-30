//
//  ViewController.swift
//  DragDropStackView
//
//  Created by SEKNY YIM on 29/1/25.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    private var data: [ProductModel] = []
    private let scrollView = UIScrollView()
    private lazy var stackView: DragDropStackView = {
        let view = DragDropStackView(config: DragDropConfig(dargViewScale: 1, otherViewsScale: 1))
        view.axis = .vertical
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        stackView.dargDropDelegate = self
        loadData()
    }
}


// MARK: - Priavte Method
private extension ViewController {
    func setup() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        stackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
    }
    
    func randomColor() -> UIColor{
        UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
    
    private func setupData() {
        DispatchQueue.main.async {
            self.data.map({ model in
                let view = ProductCardView()
                view.tag = model.sequence ?? 0
                view.snp.makeConstraints {
                    $0.height.equalTo(100)
                }
                view.set(model)
                
                return view
            }).forEach(self.stackView.addArrangedSubview)
        }
        
    }
}

// MARK: - Request Data
private extension ViewController {
    func loadData() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.fetchProducts { result in
                switch result {
                    case .success(var products):
                        
                        // Sort products by title (case insensitive)
                        products.sort { ($0.title ?? "").localizedCaseInsensitiveCompare($1.title ?? "") == .orderedAscending }
                        
                        // Assign order numbers this is also for using to define index of data when drag/drop
                        for (index, _) in products.enumerated() {
                            products[index].sequence = index + 1
                        }
                        self.data = products
                        self.setupData()
                    case .failure(let error):
                        print("error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchProducts(completion: @escaping (Result<[ProductModel], Error>) -> Void) {
        let urlString = "https://api.escuelajs.co/api/v1/products"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -2, userInfo: nil)))
                return
            }
            
            do {
                let products = try JSONDecoder().decode([ProductModel].self, from: data)
                completion(.success(products))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

// MARK: - ViewController + DragDropDelegate
extension ViewController: DragDropStackViewDelegate {
    func didBeginDrag() {

    }
    
    func dargging(inUpDirection up: Bool, maxY: CGFloat, minY: CGFloat) {

    }
    
    func didEndDrop() {
        let views = stackView.arrangedSubviews
        views.forEach { item in
            print(item.tag)
        }
        print("end")
    }
}
