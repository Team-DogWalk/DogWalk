//
//  UserRepository.swift
//  DogWalk
//
//  Created by 박성민 on 12/2/24.
//

import Foundation

protocol UserRepository {
    func emailLogin(id: String, pw: String) async -> Bool //이메일 로그인
    func appleLogin(id: String) async -> Bool // 애플 로그인
    func fetchProfile() async throws -> ProfileModel // 프로필 조회
    func fetchOtherProfile(id: String) async throws -> ProfileModel // 다른 유저 프로필 조회
    func updateProfile(nick: String, address: String, lon: String, lat: String, points: String, temperature: String) async throws // 프로필 수정
}
final class DefaultUserRepository: UserRepository {
    private let network = NetworkManager()
    private let userManger = UserManager.shared
    //이메일 로그인
    func emailLogin(id: String, pw: String) async -> Bool {
        do {
            let body = EmailLoginBody(email: id, password: pw)
            let domain = try await network.requestDTO(target: .user(.emailLogin(body: body)), of: OAuthLoginDTO.self).toDomain()
            UserManager.shared.userID = domain.userID
            UserManager.shared.userNick = domain.nick
            UserManager.shared.acess = domain.accessToken
            UserManager.shared.refresh = domain.refreshToken
            UserManager.shared.isUser = true
            return true
        } catch {
            return false
        }
    }
    //애플 로그인
    func appleLogin(id: String) async -> Bool{
        do {
            try await network.appleLogin(id: id)
            return true
        } catch {
            return false
        }
    }
    //내 프로필 조회
    func fetchProfile() async throws -> ProfileModel{
        let profile = try await network.requestDTO(target: .user(.myProfile), of: MyProfileDTO.self)
        return profile.toDomain()
    }
    //다른 유저 프로필 조회
    func fetchOtherProfile(id: String) async throws -> ProfileModel {
        // MARK: - 다른유저일 경우 DTO가 다르면 수정해주기~
        let profile = try await network.requestDTO(target: .user(.userProfile(userId: id)), of: MyProfileDTO.self)
        return profile.toDomain()
    }
    //프로필 수정
    func updateProfile(nick: String, address: String, lon: String, lat: String, points: String, temperature: String) async throws {
        let body = UpdateUserBody(nick: nick, info1: address, info2: lon, info3: lat, info4: points, info5: temperature)
        let result = try await network.requestDTO(target: .user(.updateMyProfile(body: body, boundary: UUID().uuidString)), of: MyProfileDTO.self)
        setProfile(profile: result.toDomain())
    }
    
}

private extension DefaultUserRepository {
    func setProfile(profile: ProfileModel) {
        userManger.userNick = profile.nick
        userManger.roadAddress = profile.address
        userManger.lon = profile.location.lon
        userManger.lat = profile.location.lat
        userManger.points = profile.point
    }
}
