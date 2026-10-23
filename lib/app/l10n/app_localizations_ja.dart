// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Nyachi';

  @override
  String get loading => '読み込み中…';

  @override
  String get retry => '再試行';

  @override
  String get cancel => 'キャンセル';

  @override
  String get close => '閉じる';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get remove => '削除';

  @override
  String get switchLabel => '切り替え';

  @override
  String get add => '追加';

  @override
  String get search => '検索';

  @override
  String get ok => 'OK';

  @override
  String get done => '完了';

  @override
  String get copied => 'コピーしました';

  @override
  String get notFound => 'ページが見つかりません';

  @override
  String get errorGeneric => '問題が発生しました';

  @override
  String get errorAuth => 'セッションの有効期限が切れました';

  @override
  String get errorRateLimit => 'リクエストが多すぎます。しばらく待って再試行してください。';

  @override
  String get errorServer => 'サーバーがリクエストを完了できませんでした';

  @override
  String get errorNetwork => 'インスタンスに接続できません。ネットワークを確認して再試行してください。';

  @override
  String get errorStorage => '安全なストレージを利用できません';

  @override
  String get loginTitle => 'Misskey にサインイン';

  @override
  String get loginSubtitle => 'MiAuth またはアクセストークンを使用します。';

  @override
  String get instanceHost => 'インスタンスのホスト';

  @override
  String get instanceHostHint => 'misskey.io';

  @override
  String get miAuthLogin => 'MiAuth で続ける';

  @override
  String get manualToken => 'アクセストークンを使用';

  @override
  String get token => 'アクセストークン';

  @override
  String get openBrowser => 'ブラウザーを開く';

  @override
  String get copyLink => 'リンクをコピー';

  @override
  String get waitingApproval => '承認を待っています…';

  @override
  String get cancelLogin => 'サインインを中止';

  @override
  String get loginFailed => 'サインインに失敗しました';

  @override
  String get hostRequired => 'インスタンスのホストを入力してください';

  @override
  String get tokenRequired => 'アクセストークンを入力してください';

  @override
  String get addAccount => 'アカウントを追加';

  @override
  String get sessionExpired => 'セッションの有効期限が切れました。再度サインインしてください。';

  @override
  String get relogin => '再度サインイン';

  @override
  String get home => 'ホーム';

  @override
  String get local => 'ローカル';

  @override
  String get hybrid => 'ハイブリッド';

  @override
  String get global => 'グローバル';

  @override
  String get notifications => '通知';

  @override
  String get explore => '探索';

  @override
  String get chat => 'チャット';

  @override
  String get profile => 'プロフィール';

  @override
  String get compose => '投稿';

  @override
  String get settings => '設定';

  @override
  String get emptyTimeline => '投稿はまだありません';

  @override
  String get emptyNotifications => '通知はまだありません';

  @override
  String get loadFailed => 'フィードを読み込めませんでした';

  @override
  String get usingCache => 'キャッシュを表示中';

  @override
  String get liveReconnecting => '再接続中…';

  @override
  String get liveOffline => 'ライブ更新は停止中';

  @override
  String get sensitiveContent => 'センシティブな内容';

  @override
  String get showContent => '表示';

  @override
  String get reply => '返信';

  @override
  String get renote => 'リノート';

  @override
  String get reaction => 'リアクション';

  @override
  String get reactions => 'リアクション';

  @override
  String get react => 'リアクションする';

  @override
  String get removeReaction => 'リアクションを削除';

  @override
  String get renoted => 'リノートしました';

  @override
  String get replySent => '返信を投稿しました';

  @override
  String get videoUnavailable => '動画を利用できません';

  @override
  String get openExternal => 'ブラウザーで開く';

  @override
  String get attachment => '添付ファイル';

  @override
  String get followers => 'フォロワー';

  @override
  String get following => 'フォロー中';

  @override
  String get noteCount => '投稿';

  @override
  String get message => 'メッセージ';

  @override
  String get accountSwitch => 'アカウントを切り替え';

  @override
  String get noNotes => '投稿はまだありません';

  @override
  String get userNotFound => 'ユーザーが見つかりません';

  @override
  String get markAllRead => 'すべて既読にする';

  @override
  String get allRead => 'すべての通知を既読にしました';

  @override
  String get notificationNote => '投稿しました';

  @override
  String get notificationMention => 'あなたをメンションしました';

  @override
  String get notificationReply => 'あなたに返信しました';

  @override
  String get notificationRenote => 'あなたの投稿をリノートしました';

  @override
  String get notificationQuote => 'あなたの投稿を引用しました';

  @override
  String get notificationReaction => 'あなたの投稿にリアクションしました';

  @override
  String get notificationPollEnded => '投票が終了しました';

  @override
  String get notificationFollow => 'あなたをフォローしました';

  @override
  String get notificationReceiveFollowRequest => 'フォローリクエストを送信しました';

  @override
  String get notificationFollowRequestAccepted => 'フォローリクエストを承認しました';

  @override
  String get notificationRoleAssigned => 'ロールを割り当てました';

  @override
  String get notificationChatRoomInvitation => 'チャットルームに招待しました';

  @override
  String get notificationAchievement => '実績を獲得しました';

  @override
  String get notificationExportCompleted => 'エクスポートが完了しました';

  @override
  String get notificationLogin => '新しいサインイン';

  @override
  String get notificationCreateToken => 'アクセストークンを作成しました';

  @override
  String get notificationApp => 'アプリからの通知';

  @override
  String get notificationGroupedReaction => 'あなたの投稿にリアクションしました';

  @override
  String get notificationGroupedRenote => 'あなたの投稿をリノートしました';

  @override
  String get notificationGeneric => '通知';

  @override
  String get trends => 'トレンド';

  @override
  String get searchHint => '投稿とユーザーを検索';

  @override
  String get notesTab => '投稿';

  @override
  String get usersTab => 'ユーザー';

  @override
  String get noTrends => 'トレンドはありません';

  @override
  String get noUsers => 'ユーザーが見つかりません';

  @override
  String get noSearchResults => '結果がありません';

  @override
  String get newNote => '新しい投稿';

  @override
  String get replyTo => '返信';

  @override
  String get contentWarning => '内容の警告';

  @override
  String get contentWarningHint => '任意の警告';

  @override
  String get visibility => '公開範囲';

  @override
  String get visibilityPublic => '公開';

  @override
  String get visibilityHome => 'ホーム';

  @override
  String get visibilityFollowers => 'フォロワー';

  @override
  String get localOnly => 'ローカルのみ';

  @override
  String get post => '投稿';

  @override
  String get posting => '投稿中…';

  @override
  String get draftRestored => '下書きを復元しました';

  @override
  String get deleteDraft => '下書きを削除';

  @override
  String get draftDeleted => '下書きを削除しました';

  @override
  String get postFailed => '投稿できませんでした';

  @override
  String get overLimit => '投稿が長すぎます';

  @override
  String get emptyContent => '内容を入力してください';

  @override
  String get direct => 'ダイレクト';

  @override
  String get rooms => 'ルーム';

  @override
  String get noConversations => '会話はまだありません';

  @override
  String get noRooms => 'ルームはまだありません';

  @override
  String get send => '送信';

  @override
  String get messageHint => 'メッセージを入力';

  @override
  String get attach => '添付';

  @override
  String get uploadFailed => 'アップロードに失敗しました';

  @override
  String get sendFailed => '送信できませんでした';

  @override
  String get noMessages => 'メッセージはまだありません';

  @override
  String get loadOlder => '過去のメッセージを読み込む';

  @override
  String get roomOwner => 'オーナー';

  @override
  String get accounts => 'アカウント';

  @override
  String get navigation => 'ナビゲーション';

  @override
  String get appearance => '外観';

  @override
  String get theme => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get visibleTabs => '表示するタブ';

  @override
  String get tabOrder => 'タブの順序';

  @override
  String get homeLocked => 'ホームは非表示にできません';

  @override
  String get removeAccountConfirm => 'このアカウントとローカルデータを削除しますか？';

  @override
  String get activeAccount => '使用中';

  @override
  String get about => 'このアプリについて';

  @override
  String get appVersion => 'バージョン 0.1.0+1';

  @override
  String get noAccounts => 'アカウントがありません';

  @override
  String get confirm => '確認';

  @override
  String get externalLinkFailed => 'リンクを開けませんでした';

  @override
  String get copyFailed => 'リンクをコピーできませんでした';

  @override
  String get searchSubmit => '検索';

  @override
  String get clear => 'クリア';

  @override
  String characterCount(int count) {
    return '$count 文字';
  }

  @override
  String get loadMore => 'さらに読み込む';

  @override
  String get serverNameFallback => 'Misskey';

  @override
  String get chatRoom => 'ルーム';

  @override
  String get chatWith => 'チャット';

  @override
  String get fileTooLarge => 'ファイルが大きすぎます';

  @override
  String get noFile => 'ファイルが選択されていません';

  @override
  String get removeAttachment => '添付を削除';

  @override
  String get selectFile => 'ファイルを選択';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int count) {
    return '$count 分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 時間前';
  }

  @override
  String daysAgo(int count) {
    return '$count 日前';
  }

  @override
  String get noteDetail => '投稿';

  @override
  String get removeAccount => 'アカウントを削除';
}
