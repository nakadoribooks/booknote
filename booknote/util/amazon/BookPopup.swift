//
//  BookPopup.swift
//  booknote
//
//  Created by 河瀬悠 on 2017/10/09.
//  Copyright © 2017年 nakadoribooks. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import AlamofireImage

typealias BookPopupCallback = (_ book:Book?)->()

class BookPopup: NSObject {
    
    let closed:Variable<Bool> = Variable(false)
    let commitBook:Variable<Book?> = Variable(nil)
    
    private let view = UIView(frame: windowFrame())
    private let overlay = UIView(frame: windowFrame())
    private let contentView = UIView()
    private let cancelButton = UIButton()
    private let commitButton = UIButton()
    private let parentView:UIView
    private let isbn:String
    
    private let bookView = UIView()
    private let bookImageView = UIImageView()
    private let bookTitleLabel = UILabel()
    private let bookAuthorLabel = UILabel()
    private let bookPublisherLabel = UILabel()
    
    private let loadingView = UIView()
    private let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var book:Book? = nil
    
    private init(isbn:String, parentView:UIView) {
        self.isbn = isbn
        self.parentView = parentView
        super.init()
        
        parentView.addSubview(view)
        
        setupOverlay()
        setupContentView()
        setupCancelButton()
    }
    
    private func setupOverlay(){
        view.addSubview(overlay)
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0
    }
    
    private func setupContentView(){
        view.addSubview(contentView)
        
        contentView.frame = CGRect(x: UI.marginLarge, y: 0, width: windowWidth() - (UI.marginLarge * 2.0), height: 200)
        contentView.frame.origin.y = (windowHeight() - contentView.frame.size.height) / 2.0
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        contentView.alpha = 0
        
        commitButton.frame = CGRect(x: 0, y: 200-54, width: contentView.frame.size.width, height: 54)
        commitButton.backgroundColor = UIColor.gray
        commitButton.setTitle("OK", for: .normal)
        commitButton.setTitle("検索中", for: .disabled)
        commitButton.addTarget(self, action: #selector(BookPopup.tapCommit), for: .touchUpInside)
        commitButton.isEnabled = false
        contentView.addSubview(commitButton)
        
        // loading
        loadingView.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height - commitButton.frame.size.height)
        indicator.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height - commitButton.frame.size.height)
        loadingView.addSubview(indicator)
        contentView.addSubview(loadingView)
        
        // book
        contentView.addSubview(bookView)
        bookView.addSubview(bookImageView)
        bookView.addSubview(bookTitleLabel)
        bookView.addSubview(bookAuthorLabel)
        bookView.addSubview(bookPublisherLabel)
        
        bookImageView.frame = CGRect(x: UI.margin, y: UI.margin, width: 60, height: 88) // 1.47
        bookImageView.backgroundColor = UIColor.gray
        bookImageView.contentMode = .scaleAspectFill
        bookImageView.clipsToBounds = true
        
        let textX:CGFloat = UI.margin + bookImageView.frame.size.width + UI.margin
        let textWidth = contentView.frame.size.width - textX - UI.margin
        bookTitleLabel.frame = CGRect(x: textX, y: UI.margin, width: textWidth, height: 30)
        bookTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        bookAuthorLabel.frame = CGRect(x: textX, y: UI.margin + 30, width: textWidth, height: 30)
        bookAuthorLabel.font = UIFont.systemFont(ofSize: 16.0)
        bookPublisherLabel.frame = CGRect(x: textX, y: UI.margin + 30 + 30, width: textWidth, height: 30)
        bookPublisherLabel.font = UIFont.systemFont(ofSize: 14.0)
        bookPublisherLabel.textColor = UIColor.gray
        
        bookView.alpha = 0
    }
    
    private func setupCancelButton(){
        cancelButton.frame = CGRect(x: 0, y: windowHeight() - 64 - 20 - 64, width: windowWidth(), height: 64)
        cancelButton.setTitle("キャンセル", for: .normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cancelButton.addTarget(self, action: #selector(BookPopup.tapCancel), for: .touchUpInside)
        view.addSubview(cancelButton)
    }
    
    @objc private dynamic func tapCommit(){
        BookPopup.hide(book: book)
    }
    
    @objc private dynamic func tapCancel(){
        BookPopup.hide(book: nil)
    }
    
    private func show(){
        indicator.startAnimating()
        
        contentView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        AloeChain().add(0.2, ease: .Ease) { (val) in
            self.overlay.alpha = 0.8 * val
            self.contentView.alpha = val
        }.execute()
        
        AloeChain().add(0.3, ease: .outBack) { (val) in
            let scale:CGFloat = 0.6 + (0.4 * val)
            self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }.execute()
        
        Amazon.sharedInstance.findBook(isbn: isbn) { (book) in
            self.loadedBook(book: book)
        }
    }
    
    private func loadedBook(book:Book){
        self.book = book
        
        print("isValid", book.isValid())
        
        let textX:CGFloat = UI.margin + self.bookImageView.frame.size.width + UI.margin
        let textWidth = self.contentView.frame.size.width - textX - UI.margin
        bookTitleLabel.frame.size = CGSize(width: textWidth, height: 100)
        bookTitleLabel.numberOfLines = 2
        bookTitleLabel.text = book.title
        bookTitleLabel.sizeToFit()
        
        let y:CGFloat = self.bookTitleLabel.frame.origin.y + self.bookTitleLabel.frame.size.height
        bookAuthorLabel.frame.origin.y = y
        bookPublisherLabel.frame.origin.y = y + self.bookAuthorLabel.frame.size.height
        bookAuthorLabel.text = book.author
        bookPublisherLabel.text = "\(book.publisher) (\(book.releaseDate))"
        
        commitButton.isEnabled = true
        commitButton.backgroundColor = UIColor.blue
        
        AloeChain().add(0.2, ease: .Ease, progress: { (val) in
            let reverse = 1.0 - val
            self.loadingView.alpha = reverse
            self.loadingView.transform = CGAffineTransform(translationX: 0, y: -20*val)
        }).add(0.2, ease: .Ease, progress: { (val) in
            let reverse = 1.0 - val
            self.bookView.transform = CGAffineTransform(translationX: 0, y: 20 * reverse)
            self.bookView.alpha = val
        }).execute()
        
        guard let imageUrl = book.mediumImageUrl else{
            return;
        }
        
        let imageIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        imageIndicator.frame.size = bookImageView.frame.size
        bookImageView.addSubview(imageIndicator)
        imageIndicator.startAnimating()
        
        Alamofire.request(imageUrl).responseImage { response in
            imageIndicator.stopAnimating()
            guard let image = response.result.value else {
                return;
            }
            self.bookImageView.image = image
        }

    }
    
    private func hide(){
        AloeChain().add(0.2, ease: .Ease) { (val) in
            let reverse:CGFloat = 1.0 - val
            let ty:CGFloat = -20 * val
            
            self.overlay.alpha = 0.8 * reverse
            self.contentView.alpha = reverse
            self.contentView.transform = CGAffineTransform(translationX: 0, y: ty)
        }.call {
            self.view.removeFromSuperview()
        }.execute()
    }
    
    // MARK static
    
    private static var popup:BookPopup? = nil
    private static var callback:BookPopupCallback? = nil
    
    static func show(isbn:String, parentView:UIView, callback:@escaping BookPopupCallback){
        let popup = BookPopup(isbn: isbn, parentView: parentView)
        popup.show()
        
        self.popup = popup
        self.callback = callback
    }
    
    private static func hide(book:Book?){
        if let popup = self.popup{
            popup.hide()
        }
        callback?(book)
        
        self.callback = nil
        self.popup = nil
    }
    
}
