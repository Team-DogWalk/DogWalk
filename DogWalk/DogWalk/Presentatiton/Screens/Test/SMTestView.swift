//
//  SMTestView.swift
//  DogWalk
//
//  Created by 박성민 on 11/11/24.
//

import SwiftUI

struct SMTestView: View {
    let url = "/uploads/posts/스크린샷 2024-11-05 오후 5.53.51_1731327907583.png"
    var body: some View {
        Image.asDownChevron
        asImageView(url: url)
            .frame(width: 300, height: 300)
            .onAppear {
                UserManager.shared.acess = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzFmN2UyMmNjZWQzMDgwNTYwZmM1NiIsImlhdCI6MTczMTMyODgxOCwiZXhwIjoxNzMxMzI5MTE4LCJpc3MiOiJzZXNhY18zIn0.KJwMJOiGyexO49p8HuCwcFhOhk3AhwBAOQlffPmIz08"
                UserManager.shared.refresh = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzFmN2UyMmNjZWQzMDgwNTYwZmM1NiIsImlhdCI6MTczMTMyODgxOCwiZXhwIjoxNzM0OTI4ODE4LCJpc3MiOiJzZXNhY18zIn0.H2GBTxAkNptH9FR2cg9HCTGmCNVEYyXc4dYrZZcInD0"
            }
    }
}

#Preview {
    SMTestView()
}
