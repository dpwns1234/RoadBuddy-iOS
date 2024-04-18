//
//  SearchDataServiceDelegate.swift
//  RoadBuddy
//
//  Created by 김예준 on 3/29/24.
//

import Foundation

protocol SearchDataServiceDelegate: AnyObject {
    func searchDataService(_ service: SearchDataService, didDownload data: [Address])
}
