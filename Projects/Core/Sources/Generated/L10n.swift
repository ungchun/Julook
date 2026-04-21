// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum App {
    public enum Update {
      /// 업데이트
      public static let button = L10n.tr("Localizable", "app.update.button", fallback: "업데이트")
      /// 더 나은 서비스를 위해 주룩이 수정되었어요!
      public static let message = L10n.tr("Localizable", "app.update.message", fallback: "더 나은 서비스를 위해 주룩이 수정되었어요!")
      /// MARK: app.update — RootView 업데이트 알림
      public static let title = L10n.tr("Localizable", "app.update.title", fallback: "업데이트가 필요합니다")
    }
  }
  public enum Common {
    public enum Alert {
      /// MARK: common.alert — 공용 알림
      public static let notice = L10n.tr("Localizable", "common.alert.notice", fallback: "알림")
    }
    public enum Button {
      /// 취소
      public static let cancel = L10n.tr("Localizable", "common.button.cancel", fallback: "취소")
      /// 지우기
      public static let clear = L10n.tr("Localizable", "common.button.clear", fallback: "지우기")
      /// MARK: common.button — 공용 액션 버튼
      public static let confirm = L10n.tr("Localizable", "common.button.confirm", fallback: "확인")
      /// 저장
      public static let save = L10n.tr("Localizable", "common.button.save", fallback: "저장")
    }
    public enum Error {
      /// 찜 상태 변경에 실패했습니다.
      public static let favoriteToggleFailed = L10n.tr("Localizable", "common.error.favoriteToggleFailed", fallback: "찜 상태 변경에 실패했습니다.")
      /// 막걸리 정보를 불러오지 못했습니다.
      public static let fetchMakgeolliFailed = L10n.tr("Localizable", "common.error.fetchMakgeolliFailed", fallback: "막걸리 정보를 불러오지 못했습니다.")
      /// 이미지를 불러오지 못했습니다.
      public static let imageFetchFailed = L10n.tr("Localizable", "common.error.imageFetchFailed", fallback: "이미지를 불러오지 못했습니다.")
      /// MARK: common.error — 공용 에러 메시지
      public static let imageLoadFailed = L10n.tr("Localizable", "common.error.imageLoadFailed", fallback: "이미지 로딩에 실패했습니다.")
    }
    public enum Format {
      /// %@도
      public static func alcoholOnly(_ p1: Any) -> String {
        return L10n.tr("Localizable", "common.format.alcoholOnly", String(describing: p1), fallback: "%@도")
      }
      /// MARK: common.format — 포맷 문자열 (%@: 문자 / %lld: 정수)
      public static func breweryAlcohol(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "common.format.breweryAlcohol", String(describing: p1), String(describing: p2), fallback: "%@ ･ %@도")
      }
      /// M월 d일
      public static let dateMD = L10n.tr("Localizable", "common.format.dateMD", fallback: "M월 d일")
      /// yyyy년 M월 d일
      public static let dateYMD = L10n.tr("Localizable", "common.format.dateYMD", fallback: "yyyy년 M월 d일")
    }
    public enum Reaction {
      /// 아쉬워요
      public static let dislike = L10n.tr("Localizable", "common.reaction.dislike", fallback: "아쉬워요")
      /// MARK: common.reaction — 반응 공용 라벨
      public static let like = L10n.tr("Localizable", "common.reaction.like", fallback: "좋았어요")
    }
    public enum Taste {
      /// 탄산
      public static let carbonation = L10n.tr("Localizable", "common.taste.carbonation", fallback: "탄산")
      /// 탄
      public static let carbonationShort = L10n.tr("Localizable", "common.taste.carbonationShort", fallback: "탄")
      /// 신맛
      public static let sourness = L10n.tr("Localizable", "common.taste.sourness", fallback: "신맛")
      /// 신
      public static let sournessShort = L10n.tr("Localizable", "common.taste.sournessShort", fallback: "신")
      /// MARK: common.taste — 맛 공용 라벨 (전체 + 축약)
      public static let sweetness = L10n.tr("Localizable", "common.taste.sweetness", fallback: "단맛")
      /// 단
      public static let sweetnessShort = L10n.tr("Localizable", "common.taste.sweetnessShort", fallback: "단")
      /// 걸쭉
      public static let thickness = L10n.tr("Localizable", "common.taste.thickness", fallback: "걸쭉")
      /// 걸
      public static let thicknessShort = L10n.tr("Localizable", "common.taste.thicknessShort", fallback: "걸")
    }
  }
  public enum Filter {
    public enum Sort {
      /// 높은 도수순
      public static let highAlcohol = L10n.tr("Localizable", "filter.sort.highAlcohol", fallback: "높은 도수순")
      /// 낮은 도수순
      public static let lowAlcohol = L10n.tr("Localizable", "filter.sort.lowAlcohol", fallback: "낮은 도수순")
      /// MARK: filter.sort — SortOption enum displayName
      public static let recommended = L10n.tr("Localizable", "filter.sort.recommended", fallback: "추천순")
    }
    public enum `Type` {
      /// 탄산감 많은
      public static let carbonated = L10n.tr("Localizable", "filter.type.carbonated", fallback: "탄산감 많은")
      /// 감미료 없는
      public static let noSweetener = L10n.tr("Localizable", "filter.type.noSweetener", fallback: "감미료 없는")
      /// 시큼한
      public static let sour = L10n.tr("Localizable", "filter.type.sour", fallback: "시큼한")
      /// 달달한
      public static let sweet = L10n.tr("Localizable", "filter.type.sweet", fallback: "달달한")
      /// MARK: filter.type — FilterType enum displayName
      public static let thick = L10n.tr("Localizable", "filter.type.thick", fallback: "걸쭉한")
    }
  }
  public enum Home {
    public enum CommentList {
      /// MARK: home.commentList
      public static let empty = L10n.tr("Localizable", "home.commentList.empty", fallback: "아직 코멘트가 없어요")
    }
    public enum Error {
      /// MARK: home.error
      public static let connectFailed = L10n.tr("Localizable", "home.error.connectFailed", fallback: "서비스 연결에 실패했습니다.")
      /// 수상 정보를 불러오지 못했습니다.
      public static let fetchAwardFailed = L10n.tr("Localizable", "home.error.fetchAwardFailed", fallback: "수상 정보를 불러오지 못했습니다.")
      /// 코멘트 목록을 불러오지 못했습니다.
      public static let fetchCommentListFailed = L10n.tr("Localizable", "home.error.fetchCommentListFailed", fallback: "코멘트 목록을 불러오지 못했습니다.")
      /// 새로운 막걸리 정보를 불러오지 못했습니다.
      public static let fetchNewReleasesFailed = L10n.tr("Localizable", "home.error.fetchNewReleasesFailed", fallback: "새로운 막걸리 정보를 불러오지 못했습니다.")
      /// 인기 막걸리 정보를 불러오지 못했습니다.
      public static let fetchPopularFailed = L10n.tr("Localizable", "home.error.fetchPopularFailed", fallback: "인기 막걸리 정보를 불러오지 못했습니다.")
      /// 최근 코멘트를 불러오지 못했습니다.
      public static let fetchRecentCommentsFailed = L10n.tr("Localizable", "home.error.fetchRecentCommentsFailed", fallback: "최근 코멘트를 불러오지 못했습니다.")
      /// 추천 막걸리 정보를 불러오지 못했습니다.
      public static let fetchRecommendFailed = L10n.tr("Localizable", "home.error.fetchRecommendFailed", fallback: "추천 막걸리 정보를 불러오지 못했습니다.")
      /// 번역 정보를 불러오지 못했습니다.
      public static let fetchTranslationFailed = L10n.tr("Localizable", "home.error.fetchTranslationFailed", fallback: "번역 정보를 불러오지 못했습니다.")
    }
    public enum Header {
      /// MARK: home.header
      public static let title = L10n.tr("Localizable", "home.header.title", fallback: "모아보기")
    }
    public enum Section {
      /// MARK: home.section — 홈 섹션 타이틀
      public static let filterByFeature = L10n.tr("Localizable", "home.section.filterByFeature", fallback: "특징으로 찾기")
      /// 주제로 찾기
      public static let filterByTopic = L10n.tr("Localizable", "home.section.filterByTopic", fallback: "주제로 찾기")
      /// 새로 나왔어요
      public static let newReleases = L10n.tr("Localizable", "home.section.newReleases", fallback: "새로 나왔어요")
      /// 인기 막걸리
      public static let popular = L10n.tr("Localizable", "home.section.popular", fallback: "인기 막걸리")
      /// 이 막걸리는 어때요?
      public static let random = L10n.tr("Localizable", "home.section.random", fallback: "이 막걸리는 어때요?")
      /// 코멘트가 달렸어요
      public static let recentComments = L10n.tr("Localizable", "home.section.recentComments", fallback: "코멘트가 달렸어요")
    }
    public enum Settings {
      /// MARK: home.settings — 설정 시트
      public static let contact = L10n.tr("Localizable", "home.settings.contact", fallback: "문의하기")
      /// 개인정보처리방침
      public static let privacy = L10n.tr("Localizable", "home.settings.privacy", fallback: "개인정보처리방침")
      /// 리뷰 남기기
      public static let review = L10n.tr("Localizable", "home.settings.review", fallback: "리뷰 남기기")
      /// 이용약관
      public static let terms = L10n.tr("Localizable", "home.settings.terms", fallback: "이용약관")
      /// 버전 정보
      public static let version = L10n.tr("Localizable", "home.settings.version", fallback: "버전 정보")
    }
    public enum Sort {
      /// MARK: home.sort — 정렬 옵션
      public static let questionLabel = L10n.tr("Localizable", "home.sort.questionLabel", fallback: "어떤 순서로 정렬되나요")
      public enum InfoAlert {
        /// 최근에 나온 막걸리일수록 리스트 상단에 정렬돼요.
        public static let message = L10n.tr("Localizable", "home.sort.infoAlert.message", fallback: "최근에 나온 막걸리일수록 리스트 상단에 정렬돼요.")
        /// 추천순으로 정렬
        public static let title = L10n.tr("Localizable", "home.sort.infoAlert.title", fallback: "추천순으로 정렬")
      }
    }
  }
  public enum Information {
    public enum AllComments {
      /// MARK: information.allComments
      public static let empty = L10n.tr("Localizable", "information.allComments.empty", fallback: "공개된 코멘트가 없어요")
      /// 코멘트
      public static let title = L10n.tr("Localizable", "information.allComments.title", fallback: "코멘트")
    }
    public enum Brewery {
      /// MARK: information.brewery
      public static let link = L10n.tr("Localizable", "information.brewery.link", fallback: "양조장 링크")
    }
    public enum Comment {
      /// 취소하기
      public static let cancelAction = L10n.tr("Localizable", "information.comment.cancelAction", fallback: "취소하기")
      /// 삭제하기
      public static let deleteAction = L10n.tr("Localizable", "information.comment.deleteAction", fallback: "삭제하기")
      /// 수정
      public static let edit = L10n.tr("Localizable", "information.comment.edit", fallback: "수정")
      /// 수정하기
      public static let editAction = L10n.tr("Localizable", "information.comment.editAction", fallback: "수정하기")
      /// 터치해서 코멘트를 남겨보세요!
      public static let emptyPrompt = L10n.tr("Localizable", "information.comment.emptyPrompt", fallback: "터치해서 코멘트를 남겨보세요!")
      /// 내 코멘트
      public static let myComment = L10n.tr("Localizable", "information.comment.myComment", fallback: "내 코멘트")
      public enum DeleteAlert {
        /// 코멘트를 삭제하시겠어요?
        public static let message = L10n.tr("Localizable", "information.comment.deleteAlert.message", fallback: "코멘트를 삭제하시겠어요?")
        /// MARK: information.comment — 내 코멘트 관련 액션
        public static let title = L10n.tr("Localizable", "information.comment.deleteAlert.title", fallback: "코멘트 삭제")
      }
      public enum Visibility {
        /// 비공개
        public static let `private` = L10n.tr("Localizable", "information.comment.visibility.private", fallback: "비공개")
        /// 전체공개
        public static let `public` = L10n.tr("Localizable", "information.comment.visibility.public", fallback: "전체공개")
      }
    }
    public enum CommentSheet {
      /// 막걸리에 대한 생각을 자유롭게 적어주세요.
      public static let placeholder = L10n.tr("Localizable", "information.commentSheet.placeholder", fallback: "막걸리에 대한 생각을 자유롭게 적어주세요.")
      public enum Title {
        /// 코멘트 남기기
        public static let create = L10n.tr("Localizable", "information.commentSheet.title.create", fallback: "코멘트 남기기")
        /// MARK: information.commentSheet
        public static let edit = L10n.tr("Localizable", "information.commentSheet.title.edit", fallback: "코멘트 수정")
      }
    }
    public enum Comments {
      /// MARK: information.comments
      public static let empty = L10n.tr("Localizable", "information.comments.empty", fallback: "공개된 코멘트가 없어요.")
    }
    public enum Error {
      /// 코멘트 삭제에 실패했습니다.
      public static let commentDeleteFailed = L10n.tr("Localizable", "information.error.commentDeleteFailed", fallback: "코멘트 삭제에 실패했습니다.")
      /// 코멘트 저장에 실패했습니다.
      public static let commentSaveFailed = L10n.tr("Localizable", "information.error.commentSaveFailed", fallback: "코멘트 저장에 실패했습니다.")
      /// MARK: information.error
      public static let favoriteStatusFailed = L10n.tr("Localizable", "information.error.favoriteStatusFailed", fallback: "찜 상태를 확인하지 못했습니다.")
      /// 내 코멘트를 불러오지 못했습니다.
      public static let myCommentFetchFailed = L10n.tr("Localizable", "information.error.myCommentFetchFailed", fallback: "내 코멘트를 불러오지 못했습니다.")
      /// 다른 유저의 코멘트를 불러오지 못했습니다.
      public static let otherUsersCommentFetchFailed = L10n.tr("Localizable", "information.error.otherUsersCommentFetchFailed", fallback: "다른 유저의 코멘트를 불러오지 못했습니다.")
      /// 반응 정보를 불러오지 못했습니다.
      public static let reactionFetchFailed = L10n.tr("Localizable", "information.error.reactionFetchFailed", fallback: "반응 정보를 불러오지 못했습니다.")
      /// 반응 저장에 실패했습니다.
      public static let reactionSaveFailed = L10n.tr("Localizable", "information.error.reactionSaveFailed", fallback: "반응 저장에 실패했습니다.")
      /// 평가 통계를 불러오지 못했습니다.
      public static let statsFetchFailed = L10n.tr("Localizable", "information.error.statsFetchFailed", fallback: "평가 통계를 불러오지 못했습니다.")
    }
    public enum Evaluation {
      /// 아쉬워요 (%lld)
      public static func dislikeCount(_ p1: Int) -> String {
        return L10n.tr("Localizable", "information.evaluation.dislikeCount", p1, fallback: "아쉬워요 (%lld)")
      }
      /// 좋았어요 (%lld)
      public static func likeCount(_ p1: Int) -> String {
        return L10n.tr("Localizable", "information.evaluation.likeCount", p1, fallback: "좋았어요 (%lld)")
      }
      /// MARK: information.evaluation
      public static let title = L10n.tr("Localizable", "information.evaluation.title", fallback: "평가 및 코멘트")
    }
    public enum Ingredients {
      /// 정보출처: 식품안전나라
      public static let source = L10n.tr("Localizable", "information.ingredients.source", fallback: "정보출처: 식품안전나라")
      /// MARK: information.ingredients
      public static let title = L10n.tr("Localizable", "information.ingredients.title", fallback: "원재료")
    }
  }
  public enum LabelScan {
    public enum Error {
      /// 분석 중 오류가 발생했습니다.
      /// 다시 시도해주세요.
      public static let analysisErrorRetry = L10n.tr("Localizable", "labelScan.error.analysisErrorRetry", fallback: "분석 중 오류가 발생했습니다.\n다시 시도해주세요.")
      /// MARK: labelScan.error
      public static let analysisFailed = L10n.tr("Localizable", "labelScan.error.analysisFailed", fallback: "분석에 실패했습니다. 다시 시도해주세요.")
      /// 이미지 변환에 실패했습니다.
      public static let imageConversionFailed = L10n.tr("Localizable", "labelScan.error.imageConversionFailed", fallback: "이미지 변환에 실패했습니다.")
      /// 막걸리 라벨을 인식하지 못했습니다.
      /// 다시 촬영해주세요.
      public static let labelNotRecognized = L10n.tr("Localizable", "labelScan.error.labelNotRecognized", fallback: "막걸리 라벨을 인식하지 못했습니다.\n다시 촬영해주세요.")
      /// '%@' 막걸리를 찾지 못했습니다.
      /// 아직 등록되지 않은 막걸리일 수 있습니다.
      public static func notFoundFormat(_ p1: Any) -> String {
        return L10n.tr("Localizable", "labelScan.error.notFoundFormat", String(describing: p1), fallback: "'%@' 막걸리를 찾지 못했습니다.\n아직 등록되지 않은 막걸리일 수 있습니다.")
      }
      /// 알 수 없는
      public static let unknownLabel = L10n.tr("Localizable", "labelScan.error.unknownLabel", fallback: "알 수 없는")
    }
    public enum Guide {
      /// MARK: labelScan.guide
      public static let prompt = L10n.tr("Localizable", "labelScan.guide.prompt", fallback: "막걸리 라벨을 찍어주세요")
    }
  }
  public enum MyMakgeolli {
    /// MARK: myMakgeolli — MyMakgeolli Scene
    public static let title = L10n.tr("Localizable", "myMakgeolli.title", fallback: "내 막걸리")
    public enum Empty {
      /// 비어있어요
      public static let title = L10n.tr("Localizable", "myMakgeolli.empty.title", fallback: "비어있어요")
    }
    public enum Error {
      /// MARK: myMakgeolli.error
      public static let fetchFavoritesFailed = L10n.tr("Localizable", "myMakgeolli.error.fetchFavoritesFailed", fallback: "찜한 막걸리 목록을 불러오지 못했습니다.")
      /// 반응 데이터를 불러오지 못했습니다.
      public static let fetchReactionsFailed = L10n.tr("Localizable", "myMakgeolli.error.fetchReactionsFailed", fallback: "반응 데이터를 불러오지 못했습니다.")
      /// 해당 막걸리를 찾을 수 없습니다.
      public static let makgeolliNotFound = L10n.tr("Localizable", "myMakgeolli.error.makgeolliNotFound", fallback: "해당 막걸리를 찾을 수 없습니다.")
    }
    public enum Reset {
      /// 초기화
      public static let button = L10n.tr("Localizable", "myMakgeolli.reset.button", fallback: "초기화")
    }
    public enum Tab {
      /// MARK: myMakgeolli.tab — MyMakgeolliFilterTab displayName
      public static let all = L10n.tr("Localizable", "myMakgeolli.tab.all", fallback: "전체")
      /// 코멘트
      public static let comment = L10n.tr("Localizable", "myMakgeolli.tab.comment", fallback: "코멘트")
      /// 찜
      public static let favorite = L10n.tr("Localizable", "myMakgeolli.tab.favorite", fallback: "찜")
    }
  }
  public enum Search {
    public enum EmptyState {
      /// MARK: search.emptyState
      public static let prompt = L10n.tr("Localizable", "search.emptyState.prompt", fallback: "막걸리 이름으로 검색해보세요!")
    }
    public enum Error {
      /// MARK: search.error
      public static let searchFailed = L10n.tr("Localizable", "search.error.searchFailed", fallback: "검색에 실패했습니다.")
    }
    public enum Input {
      /// MARK: search.input — 검색 입력
      public static let placeholder = L10n.tr("Localizable", "search.input.placeholder", fallback: "막걸리 이름, 양조장 ...")
    }
    public enum Recent {
      /// MARK: search.recent — 최근 검색어
      public static let title = L10n.tr("Localizable", "search.recent.title", fallback: "최근 검색어")
      public enum ClearAlert {
        /// 검색한 기록을 모두 지울까요?
        public static let message = L10n.tr("Localizable", "search.recent.clearAlert.message", fallback: "검색한 기록을 모두 지울까요?")
        /// 최근 검색어 지우기
        public static let title = L10n.tr("Localizable", "search.recent.clearAlert.title", fallback: "최근 검색어 지우기")
      }
    }
    public enum Results {
      /// MARK: search.results — 검색 결과
      public static let empty = L10n.tr("Localizable", "search.results.empty", fallback: "검색 결과가 없어요.")
      /// 등록 요청하기
      public static let requestRegister = L10n.tr("Localizable", "search.results.requestRegister", fallback: "등록 요청하기")
      public enum RequestComplete {
        /// 빠른 시일내에 추가할게요!
        public static let message = L10n.tr("Localizable", "search.results.requestComplete.message", fallback: "빠른 시일내에 추가할게요!")
        /// 등록 요청 완료
        public static let title = L10n.tr("Localizable", "search.results.requestComplete.title", fallback: "등록 요청 완료")
      }
    }
  }
  public enum Tabs {
    /// MARK: tabs — 바텀 탭 라벨
    public static let home = L10n.tr("Localizable", "tabs.home", fallback: "모아보기")
    /// 라벨스캔
    public static let labelScan = L10n.tr("Localizable", "tabs.labelScan", fallback: "라벨스캔")
    /// 내 막걸리
    public static let myMakgeolli = L10n.tr("Localizable", "tabs.myMakgeolli", fallback: "내 막걸리")
    /// 검색
    public static let search = L10n.tr("Localizable", "tabs.search", fallback: "검색")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
