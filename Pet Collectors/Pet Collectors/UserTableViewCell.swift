//
//  UserTableViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "userCell"
    
    let userImageView = UIImageView()
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        let image = UIImage(named: "Blank_Profile")

        self.addSubview(userImageView)
        self.addSubview(nameLabel)
        self.addSubview(descriptionLabel)
        
        userImageView.image = image
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Name"
        nameLabel.font = .boldSystemFont(ofSize: 22)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Description"
        descriptionLabel.font = .systemFont(ofSize: 11)
        
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 50),
            userImageView.heightAnchor.constraint(equalToConstant: 50),
            userImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            nameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 20),
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with user: User) {
        userImageView.image = user.image
        nameLabel.text = user.userName
        descriptionLabel.text = user.details
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

