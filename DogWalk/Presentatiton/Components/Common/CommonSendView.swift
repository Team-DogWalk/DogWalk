//
//  CommonSendView.swift
//  DogWalk
//
//  Created by 박성민 on 11/1/24.
//

import SwiftUI
import Combine
import Photos
import AVKit
enum LibraryStatus {
    case denied
    case approved
    case limited
}
struct Asset: Identifiable {
    var id = UUID().uuidString
    var asset: PHAsset
    var image: UIImage
}

class ImagePickerVM: NSObject,ObservableObject {
    static let size = CGSize(width: 300, height: 300)
    @Published var showImagePicker = false
    @Published var librayStatus = LibraryStatus.denied
    @Published var fetchedPhotos: [Asset] = []
    @Published var allPhotos: PHFetchResult<PHAsset>!
    @Published var showPreview = false
    @Published var selectedImage: UIImage! //선택한 이미지
    
    private var currentIndex = 0
    private let fetchLimit = 50
    private var isFetching = false
    private let fetchTrigger = PassthroughSubject<Void, Never>()
    func openImagePicker() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) //키보드 내림
        if fetchedPhotos.isEmpty { //이미지 빈 경우 불러오기~
            fetchPhotos()
        }
        withAnimation {showImagePicker.toggle()}
        if !showImagePicker { //이미지 선택 해제 시 선택한 이미지 초기화
            selectedImage = nil
        }
    }
    deinit {
        //옵저버 해제
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    func setUp() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .denied: self.librayStatus = .denied
                case .authorized: self.librayStatus = .approved
                case .limited: self.librayStatus = .limited
                default: self.librayStatus = .denied
                }
            }
            
        }
        PHPhotoLibrary.shared().register(self)
    }
    // 사용자 사진 불러오기
    private func fetchPhotos() {
        guard !isFetching else { return } //페이지네이션 안해도 되면 리턴
        isFetching = true
        
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        options.includeHiddenAssets = false // 비동기 처리
        allPhotos = PHAsset.fetchAssets(with: options)
        let fetchRange = NSMakeRange(currentIndex, min(fetchLimit, allPhotos.count - currentIndex))
        guard fetchRange.location < allPhotos.count else {
            isFetching = false
            return
        } //이미 모든 사진가져왔으면 페이징 false
        let paginatedFetchResults = allPhotos.objects(at: IndexSet(integersIn: fetchRange.location..<fetchRange.location + fetchRange.length))
        
        paginatedFetchResults.forEach { asset in
            if asset.mediaType == .image {
                self.getImageFromAsset(asset: asset, size: Self.size) { image in
                    self.fetchedPhotos.append(Asset(asset: asset, image: image))
                }
            }
        }
        currentIndex += fetchLimit
        isFetching = false
    }
    
    private func getImageFromAsset(asset: PHAsset, size: CGSize, completion: @escaping (UIImage) -> ()) {
        let imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = true
        let imageOptions = PHImageRequestOptions()
        imageOptions.deliveryMode = .highQualityFormat
        // TODO: 이미지 캐싱 구현 시 캐싱 해주기
        imageOptions.isSynchronous = true //이미지 캐싱 로직 작성해주기~
        
        imageManager.requestImage(
            for: asset,
            targetSize: Self.size,
            contentMode: .aspectFill,
            options: imageOptions) { image, _ in
                guard let resizedImage = image else { return }
                completion(resizedImage)
            }
    }
    //이미지 배열에 넣기
    func extractPreviewData(asset: PHAsset) {
        if asset.mediaType == .image {
            getImageFromAsset(asset: asset, size: PHImageManagerMaximumSize) { image in
                DispatchQueue.main.async {
                    self.selectedImage = image
                }
            }
        }
    }
    //페이지네이션
    func loadMorePhotosIfNeeded(currentItem item: Asset?) {
        guard let item = item else { return }
        let thresholdIndex = fetchedPhotos.index(fetchedPhotos.endIndex, offsetBy: -5)
        if fetchedPhotos.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            fetchPhotos()
        }
    }
}
// MARK: - 갤러리 업데이트 관찰
extension ImagePickerVM: PHPhotoLibraryChangeObserver {
    //갱신된 이미지 업데이트
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let _ = allPhotos else { return }
        if let updates = changeInstance.changeDetails(for: allPhotos) {
            let updatedPhotos = updates.fetchResultAfterChanges
            updatedPhotos.enumerateObjects { [self] asset, index, _ in
                if !allPhotos.contains(asset) {
                    getImageFromAsset(asset: asset, size: Self.size) { image in
                        DispatchQueue.main.async {
                            self.fetchedPhotos.append(Asset(asset: asset, image: image))
                        }
                    }
                } //if 끝
            }
            
            
            allPhotos.enumerateObjects { asset, index, _ in
                if !updatedPhotos.contains(asset) {
                    DispatchQueue.main.async {
                        self.fetchedPhotos.removeAll { (result) -> Bool in
                            return result.asset == asset
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.allPhotos = updatedPhotos
            }
        }
    }
    
}
struct CommonSendView: View {
    private static let width = UIScreen.main.bounds.width
    private static var height = UIScreen.main.bounds.height
    var proxy: GeometryProxy
    @Binding var yOffset: CGFloat //키보드 높이 측정
    @Binding var showKeyboard: Bool //키보드 여부
    var showImageSelectButton: Bool = true // 사진 보내기 버튼 보이기 숨기기
    @StateObject var imagePicker = ImagePickerVM()
    @State private var text = "" //키보드 입력값
    @State private var bottomPadding: CGFloat = 0.0
    @State private var sendHeigh: CGFloat = 36.0
    @State private var isSendable = false // 보내기 버튼 활성화 여부
    
    @FocusState private var isKeyboardFocused: Bool //키보드 포커스 상태
    @State private var rotationAngle: Double = 0 // +버튼 각도 변수
    
    private let tfHeight: CGFloat = 36.0
    private var size: CGSize {
        return proxy.size
    }
    private var bottomSafeArea: CGFloat {
        return UIApplication.shared.bottomPadding
    }
    private var bottomSheetHegiht: CGFloat { // 바텀 시트 사이즈
        return Self.height * 0.33
    }
    
    var completionSendText: ((String) -> ())? //텍스트 전달
    var completionSendImage: ((UIImage) -> ())? //이미지 전달
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 10.0) {
                if showImageSelectButton {
                    cameraButton()
                }
                textField()
                sendButton()
            }
            imageScrollView()
        }
        .padding([.top, .leading, .trailing], 10.0)
        .padding(.bottom, bottomSafeArea + bottomPadding + 10)
        .background(Color.primaryWhite)
        .clipShape(.rect(
            topLeadingRadius: 20.0,
            topTrailingRadius: 20.0)
        )
        .shadow(radius: 1.0, y: -1.0)
        .offset(y: size.height - yOffset)
        .onReceive(NotificationCenter.default.publisher(for: .keyboardWillShow), perform: { notif in
            //keyboard 높이에 따른 bottom 높이 조절
            if let keyboardHeight = (notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height,
               let duration = (notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            {
                withAnimation(.snappy(duration: duration)) {
                    bottomPadding = keyboardHeight
                    showKeyboard = true
                    self.updateYOffset()
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: .keyboardWillHide), perform: { notif in
            if let duration = (notif.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            {
                withAnimation(.snappy(duration: duration)) {
                    bottomPadding = 0.0
                    showKeyboard = false
                    self.updateYOffset()
                }
            }
        })
        .onChange(of: imagePicker.showImagePicker, { oldValue, newValue in
            defer {
                withAnimation(.spring) {
                        rotationAngle += 45 // showImagePicker 상태 변할 때마다 각도 45도 추가해주기
                    }
            }
            if newValue {
                withAnimation(.snappy(duration: 0.2)) {
                    bottomPadding = bottomSheetHegiht
                    self.updateYOffset()
                }
            } else {
                imagePicker.selectedImage = nil //이미지 선택 종료 시 선택 이미지 초기화
                withAnimation(.snappy(duration: 0.2)) {
                    bottomPadding = 0
                    self.updateYOffset()
                }
                
            }
        })
        .onChange(of: isKeyboardFocused, { oldValue, newValue in
            //키보드 상태와 이미지 피커 상태를 통해 이미지 피커가 ture인데 키보드가 올라올 경우
            // 이미지 피커 상태를 false로 변경해주는 로직
            if newValue && imagePicker.showImagePicker {
                withAnimation {imagePicker.showImagePicker.toggle()}
            }
        })
        // MARK: - 이미지 자세히 보기 구현시 필요
//        .sheet(isPresented: $imagePicker.showPreview, onDismiss: {
//            imagePicker.selectedImage = nil
//        }, content: {
//            PreviewView()
//                .environmentObject(imagePicker)
//        })
        .onAppear {
            self.updateYOffset()
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
}
private extension CommonSendView {
    func updateYOffset() {
        yOffset = (bottomSafeArea + bottomPadding + sendHeigh - (bottomPadding == 0 ? -20 : 14))
    }
}
// MARK: - 텍스트 부분
private extension CommonSendView {
    @ViewBuilder
    func textField() -> some View {
        HStack {
            TextField(
                "메세지를 입력하세요",
                text: $text,
                axis: .vertical
            )
            .font(.pretendardRegular16)
            .lineLimit(showKeyboard ? 4 : 1)
            .tint(.primaryBlack)
            .focused($isKeyboardFocused) //입력 감지
            .onChange(of: text) { oldValue, newValue in
                //엔터만 누를경우 보내기 막기
                if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text = newValue
                } else {
                    text = ""
                }
                isSendable = !text.isEmpty
            }
            //이미지 선택 시 보내기 기능 활성화
            .onChange(of: imagePicker.selectedImage) { oldValue, newValue in
                if newValue != nil {
                    isSendable = true
                } else {
                    isSendable = !text.isEmpty
                }
            }
        } //:HSTACK
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(minHeight: tfHeight)
        .background(
            GeometryReader {
                Color.gray.opacity(0.1)
                    .preference(key: TextFieldSize.self, value: $0.size)
                    .onPreferenceChange(TextFieldSize.self, perform: { value in
                        sendHeigh = value.height
                        self.updateYOffset()
                    })
            }
            
        )
        .clipShape(.rect(cornerRadius: tfHeight / 2))
        .animation(.easeInOut(duration: 0.2), value: showKeyboard)
    }
}
// MARK: - 카메라 부분
private extension CommonSendView {
    @ViewBuilder
    func cameraButton() -> some View {
        Button {
            imagePicker.setUp()
            imagePicker.openImagePicker()
        } label: {
            Image.asPlus
                .resizable()
                .aspectRatio(contentMode: .fit)
                .aspectRatio(0.5, contentMode: .fit)
                .rotationEffect(Angle(degrees: rotationAngle))
        }
        .buttonStyle(.plain)
        .frame(width: tfHeight, height: tfHeight)
    }
}
// MARK: - 보내기 버튼 부분
private extension CommonSendView {
    @ViewBuilder
    func sendButton() -> some View {
        Button {
            if isSendable {
                //보내는게 이미지일 경우
                if imagePicker.selectedImage != nil {
                    self.completionSendImage?(imagePicker.selectedImage)
                    self.imagePicker.selectedImage = nil
                    self.imagePicker.showImagePicker.toggle()
                } else { //텍스트인 경우
                    self.completionSendText?(text)
                    self.text = ""
                }
            }
        } label: {
            Image(systemName: "paperplane")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .aspectRatio(0.65, contentMode: .fit)
                .foregroundStyle(isSendable ? Color.green : Color.primaryGray)
        }
        .buttonStyle(.plain)
        .frame(width: tfHeight, height: tfHeight)
        .offset(x: -4)
    }
}
// MARK: - 이미지
private extension CommonSendView {
    //이미지 스크롤 부분
    @ViewBuilder
    func imageScrollView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(imagePicker.fetchedPhotos) { photo in
                    imageCell(photo)
                    // TODO: 이미지 클릭 시 해당 이미지만 보여주는 뷰를 띄울지 정하기
                    //                        .onTapGesture {
                    //                            imagePicker.extractPreviewData(asset: photo.asset)
                    //                            imagePicker.showPreview.toggle()
                    //                        }
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                imagePicker.loadMorePhotosIfNeeded(currentItem: photo)
                            }
                        }
                        ) //페이지네이션 기능 구현
                }
                //Image
                // MARK: - 권한이 없는 경우
                if imagePicker.librayStatus == .denied || imagePicker.librayStatus == .limited {
                    VStack {
                        Text(imagePicker.librayStatus == .denied ? "사진 접근 권한 허용 하기" : "더 많은 사진 선택하기")
                            .foregroundStyle(Color.primaryGray)
                        Button {
                            UIApplication.shared.open(URL(
                                string: UIApplication.openSettingsURLString)!,
                                                      options: [:],
                                                      completionHandler: nil
                            )
                            
                        } label: {
                            Text(imagePicker.librayStatus == .denied ? "허용하기" : "사진 선택하기")
                                .foregroundStyle(Color.primaryWhite)
                                .font(.pretendardBold16)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .background(Color.primaryGreen)
                                .cornerRadius(5)
                        }
                        .frame(width: 150)
                    } //:VSTACK
                }
            } //:HSTACK
            .padding()
        } //:SCROLL
        .frame(height: imagePicker.showImagePicker ? bottomSheetHegiht : 0) //플러스 버튼 누를경우 나옴
        .background(Color.primaryWhite.ignoresSafeArea(.all, edges: .bottom))
        .opacity(imagePicker.showImagePicker ? 1 : 0)
    }
    @ViewBuilder
    func imageCell(_ photo: Asset) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 180, height: bottomSheetHegiht - 20)
                .cornerRadius(5)
                .padding(.bottom)
            // MARK: - 이미지 선택하기 원
            Circle()
                .foregroundStyle(
                    imagePicker.selectedImage == photo.image ?
                    Color.primaryOrange.opacity(0.8) :
                        Color.primaryGray.opacity(0.6)
                )
                .frame(width: 30, height: 30)
                .vTop()
                .hTrailing()
                .padding(10)
                .wrapToButton {
                    imagePicker.selectedImage = photo.image
                }
                
        }
    }
}

// MARK: - 이미지 보는 뷰
//struct PreviewView: View {
//    @EnvironmentObject var imagePicker: ImagePickerVM
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if imagePicker.selectedImage != nil {
//                    Image(uiImage: imagePicker.selectedImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                }
//            } //:ZSTACK
//            .ignoresSafeArea(.all, edges: .bottom)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar(content: {
//                ToolbarItem(placement: .navigationBarTrailing, content: {
//                    Button {
//                        // Action
//                        
//                    } label: {
//                        Text("Send")
//                    }
//                })
//            })
//        }
//    }
//}

extension Notification.Name {
    static let keyboardWillShow = UIResponder.keyboardWillShowNotification
    static let keyboardWillHide = UIResponder.keyboardWillHideNotification
}
// MARK: - 키보드 감지 부분
@MainActor
extension UIApplication {
    var KeyWindow: UIWindow {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene}
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
        ??
        UIWindow()
    }
    
    var topPadding: CGFloat {
        return UIApplication.shared.KeyWindow.safeAreaInsets.top
    }
    var bottomPadding: CGFloat {
        return UIApplication.shared.KeyWindow.safeAreaInsets.bottom
    }
}

struct TextFieldSize: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
