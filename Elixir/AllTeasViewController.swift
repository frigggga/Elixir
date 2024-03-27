//
//  AllTeasViewController.swift
//  Elixir
//
//  Created by Jack Stark on 2/19/23.
//

import UIKit

class AllTeasViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    let margin: CGFloat = 20
    var herbs: [Herb] = ElixirModel.shared.loadHerbs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElixirModel.shared.herbs = ElixirModel.shared.loadHerbs()
        collectionView.dataSource = self
        collectionView.delegate = self
        configureSpacing()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AllTeasViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        herbs.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeaCollectionViewCell.identifier, for: indexPath) as! TeaCollectionViewCell
        let data = herbs[indexPath.row]
        cell.updateUI(with: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2   //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let width = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        let height = Int(1.4 * Double(width))
        
        return CGSize(width: width, height: height)
    }
    
    private func configureSpacing() {
        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
}
