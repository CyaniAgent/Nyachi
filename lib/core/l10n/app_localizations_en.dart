// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nyachi';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get switchLabel => 'Switch';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String contributionsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions',
      one: '1 contribution',
    );
    return '$_temp0';
  }

  @override
  String get contributorsEmpty => 'No contributors yet';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get copied => 'Copied';

  @override
  String get notFound => 'Page not found';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorAuth => 'Your session has expired';

  @override
  String get errorRateLimit =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get errorServer => 'The server could not complete the request';

  @override
  String get errorNetwork =>
      'Could not reach the instance. Check your connection and try again.';

  @override
  String get errorStorage => 'Secure storage is unavailable';

  @override
  String get loginTitle => 'Sign in to Misskey';

  @override
  String get loginSubtitle => 'Use MiAuth or an access token.';

  @override
  String get instanceHost => 'Instance host';

  @override
  String get instanceHostHint => 'misskey.io';

  @override
  String get miAuthLogin => 'Continue with MiAuth';

  @override
  String get manualToken => 'Use an access token';

  @override
  String get token => 'Access token';

  @override
  String get openBrowser => 'Open browser';

  @override
  String get copyLink => 'Copy link';

  @override
  String get waitingApproval => 'Waiting for approval…';

  @override
  String get cancelLogin => 'Cancel sign-in';

  @override
  String get loginFailed => 'Sign-in failed';

  @override
  String get hostRequired => 'Enter an instance host';

  @override
  String get tokenRequired => 'Enter an access token';

  @override
  String get addAccount => 'Add account';

  @override
  String get sessionExpired => 'Your session has expired. Sign in again.';

  @override
  String get relogin => 'Sign in again';

  @override
  String get home => 'Home';

  @override
  String get local => 'Local';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get global => 'Global';

  @override
  String get notifications => 'Notifications';

  @override
  String get explore => 'Explore';

  @override
  String get chat => 'Chat';

  @override
  String get profile => 'Profile';

  @override
  String get compose => 'Compose';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get displayName => 'Display name';

  @override
  String get bio => 'Bio';

  @override
  String get location => 'Location';

  @override
  String get birthday => 'Birthday';

  @override
  String get accountTypeBot => 'This account is a bot';

  @override
  String get accountTypeCat => 'This account is a cat';

  @override
  String get profileFields => 'Profile fields';

  @override
  String get addField => 'Add field';

  @override
  String get fieldName => 'Label';

  @override
  String get fieldValue => 'Content';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get changeBanner => 'Change banner';

  @override
  String get saved => 'Saved';

  @override
  String get privacy => 'Privacy';

  @override
  String get newNoteDefaults => 'New note defaults';

  @override
  String get defaultLocalOnly => 'Local only by default';

  @override
  String get defaultLocalOnlyHint =>
      'New notes stay on this instance unless changed';

  @override
  String get mutedUsers => 'Muted users';

  @override
  String get noMutedUsers => 'No muted users';

  @override
  String get unmute => 'Unmute';

  @override
  String get blockedUsers => 'Blocked users';

  @override
  String get noBlockedUsers => 'No blocked users';

  @override
  String get unblock => 'Unblock';

  @override
  String get notificationSettings => 'Notifications';

  @override
  String get notifyAll => 'All';

  @override
  String get notifyNormal => 'Normal only';

  @override
  String get notifyNone => 'Off';

  @override
  String get notifyEventNote => 'New note';

  @override
  String get notifyEventFollow => 'New follower';

  @override
  String get notifyEventMention => 'Mention';

  @override
  String get notifyEventReply => 'Reply';

  @override
  String get notifyEventRenote => 'Renote';

  @override
  String get notifyEventQuote => 'Quote';

  @override
  String get notifyEventReaction => 'Reaction';

  @override
  String get notifyEventPollEnded => 'Poll ended';

  @override
  String get notifyEventReceiveFollowRequest => 'Follow request received';

  @override
  String get notifyEventFollowRequestAccepted => 'Follow request accepted';

  @override
  String get notifyEventRoleAssigned => 'Role assigned';

  @override
  String get notifyEventChatRoomInvitation => 'Chat room invitation';

  @override
  String get notifyEventAchievement => 'Achievement';

  @override
  String get notifyEventApp => 'App notification';

  @override
  String get emailSettings => 'Email';

  @override
  String get currentEmail => 'Current email';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailUnavailable => 'This address cannot be used';

  @override
  String get emailPasswordHint =>
      'Misskey asks for your current password to change the email.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm new password';

  @override
  String get passwordMismatch => 'The new passwords do not match';

  @override
  String get changePassword => 'Change password';

  @override
  String get security => 'Security';

  @override
  String get twoFactor => 'Two-factor authentication';

  @override
  String get twoFactorHint => 'Require a code from your authenticator app';

  @override
  String get twoFactorPasswordPrompt => 'Enter your password';

  @override
  String get twoFactorTokenPrompt => 'Enter the 6-digit code';

  @override
  String get twoFactorSecretHint =>
      'Add this secret to your authenticator app if you cannot scan it.';

  @override
  String get signinHistory => 'Sign-in history';

  @override
  String get noSigninHistory => 'No sign-in records';

  @override
  String get signinSuccess => 'Succeeded';

  @override
  String get signinFailed => 'Failed';

  @override
  String get copy => 'Copy';

  @override
  String get driveSpaceUnavailable => 'Storage usage is not available';

  @override
  String get openDrive => 'Open drive';

  @override
  String get settings => 'Settings';

  @override
  String get online => 'Online';

  @override
  String get me => 'Me';

  @override
  String get noReplies => 'No replies yet';

  @override
  String get emptyTimeline => 'No notes yet';

  @override
  String get emptyNotifications => 'No notifications yet';

  @override
  String get loadFailed => 'Could not load this feed';

  @override
  String get usingCache => 'Showing cached content';

  @override
  String get liveReconnecting => 'Reconnecting…';

  @override
  String get liveOffline => 'Live updates paused';

  @override
  String get sensitiveContent => 'Sensitive content';

  @override
  String get showContent => 'Show';

  @override
  String get reply => 'Reply';

  @override
  String get renote => 'Renote';

  @override
  String get reaction => 'Reaction';

  @override
  String get reactions => 'Reactions';

  @override
  String get download => 'Download';

  @override
  String get downloadSaved => 'Saved to';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get confirm => 'Confirm';

  @override
  String get react => 'React';

  @override
  String get renoted => 'Renoted';

  @override
  String get replySent => 'Reply posted';

  @override
  String get videoUnavailable => 'Video unavailable';

  @override
  String get openExternal => 'Open in browser';

  @override
  String get attachment => 'Attachment';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get noteCount => 'Notes';

  @override
  String get message => 'Message';

  @override
  String get accountSwitch => 'Switch account';

  @override
  String get noNotes => 'No notes yet';

  @override
  String get userNotFound => 'User not found';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get allRead => 'All notifications marked as read';

  @override
  String get notificationNote => 'posted a note';

  @override
  String get notificationMention => 'mentioned you';

  @override
  String get notificationReply => 'replied to you';

  @override
  String get notificationRenote => 'renoted your note';

  @override
  String get notificationQuote => 'quoted your note';

  @override
  String get notificationReaction => 'reacted to your note';

  @override
  String get notificationPollEnded => 'a poll ended';

  @override
  String get notificationFollow => 'followed you';

  @override
  String get notificationReceiveFollowRequest => 'sent a follow request';

  @override
  String get notificationFollowRequestAccepted =>
      'accepted your follow request';

  @override
  String get notificationRoleAssigned => 'assigned you a role';

  @override
  String get notificationChatRoomInvitation => 'invited you to a chat room';

  @override
  String get notificationAchievement => 'earned an achievement';

  @override
  String get notificationExportCompleted => 'export completed';

  @override
  String get notificationLogin => 'new sign-in';

  @override
  String get notificationCreateToken => 'access token created';

  @override
  String get notificationApp => 'app notification';

  @override
  String get notificationGroupedReaction => 'reacted to your note';

  @override
  String get notificationGroupedRenote => 'renoted your note';

  @override
  String get notificationGeneric => 'notification';

  @override
  String get trends => 'Trends';

  @override
  String get searchHint => 'Search notes and users';

  @override
  String get notesTab => 'Notes';

  @override
  String get usersTab => 'Users';

  @override
  String get noTrends => 'No trends right now';

  @override
  String get noUsers => 'No users found';

  @override
  String get noSearchResults => 'No results';

  @override
  String get newNote => 'New note';

  @override
  String get replyTo => 'Reply';

  @override
  String get contentWarning => 'Content warning';

  @override
  String get contentWarningHint => 'Optional warning';

  @override
  String get visibility => 'Visibility';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityHome => 'Home';

  @override
  String get visibilityFollowers => 'Followers';

  @override
  String get localOnly => 'Local only';

  @override
  String get post => 'Post';

  @override
  String get posting => 'Posting…';

  @override
  String get draftRestored => 'Draft restored';

  @override
  String get deleteDraft => 'Delete draft';

  @override
  String get draftDeleted => 'Draft deleted';

  @override
  String get postFailed => 'Could not post';

  @override
  String get overLimit => 'This note is too long';

  @override
  String get emptyContent => 'Write something first';

  @override
  String get direct => 'Direct';

  @override
  String get rooms => 'Rooms';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get noRooms => 'No rooms yet';

  @override
  String get send => 'Send';

  @override
  String get messageHint => 'Write a message';

  @override
  String get attach => 'Attach';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get sendFailed => 'Could not send';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get roomOwner => 'Owner';

  @override
  String get accounts => 'Accounts';

  @override
  String get navigation => 'Navigation';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get visibleTabs => 'Visible tabs';

  @override
  String get tabOrder => 'Tab order';

  @override
  String get homeLocked => 'Home cannot be hidden';

  @override
  String get removeAccountConfirm => 'Remove this account and its local data?';

  @override
  String get activeAccount => 'Active';

  @override
  String get about => 'About';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get noAccounts => 'No accounts';

  @override
  String get externalLinkFailed => 'Could not open the link';

  @override
  String get copyFailed => 'Could not copy the link';

  @override
  String get searchSubmit => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String characterCount(int count) {
    return '$count characters';
  }

  @override
  String get serverNameFallback => 'Misskey';

  @override
  String get chatRoom => 'Room';

  @override
  String get chatWith => 'Chat';

  @override
  String get fileTooLarge => 'File is too large';

  @override
  String get noFile => 'No file selected';

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String get selectFile => 'Select file';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get noteDetail => 'Note';

  @override
  String get removeAccount => 'Remove account';

  @override
  String get signIn => 'Sign in';

  @override
  String get refresh => 'Refresh';

  @override
  String get accentColor => 'Accent color';

  @override
  String get systemColor => 'System color';

  @override
  String get instanceColor => 'Instance color';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorOrange => 'Orange';

  @override
  String get detailBreakpoint => 'Details panel breakpoint';

  @override
  String get removeReaction => 'Remove reaction';

  @override
  String removeReactionConfirm(String reaction) {
    return 'Remove your response $reaction?';
  }

  @override
  String changeReactionConfirm(String reaction) {
    return 'React with $reaction?';
  }

  @override
  String get contributors => 'Contributors';

  @override
  String get contributorsBody =>
      'Nyachi is developed by SakuraCake and community contributors.';

  @override
  String get flutterTrademark =>
      'Flutter is a trademark of Google LLC. Nyachi is not affiliated with or endorsed by Google.';

  @override
  String get viewLicenses => 'Open-source licenses';

  @override
  String licensesBody(int count) {
    return '$count packages bundled with this app.';
  }

  @override
  String get drive => 'Drive';

  @override
  String get upload => 'Upload';

  @override
  String get noFiles => 'No files yet';

  @override
  String deleteFileConfirm(String name) {
    return 'Delete $name?';
  }

  @override
  String get driveUsage => 'Storage';

  @override
  String get thirdPartyNotices => 'Third-party notices';

  @override
  String get bundledPackages => 'Bundled packages';

  @override
  String get legalNotice => 'Legal';

  @override
  String get renoteConfirmTitle => 'Renote';

  @override
  String get renoteConfirm => 'Renote this post?';

  @override
  String get centerContent => 'Center content';

  @override
  String get centerContentHint =>
      'Keep the reading column centered on wide screens';

  @override
  String get openFullComposer => 'Open full composer';

  @override
  String get attachLocalFile => 'Choose a local file';

  @override
  String get uploading => 'Uploading…';

  @override
  String get noAttachments => 'No attachments';

  @override
  String get newFolder => 'New folder';

  @override
  String get folderName => 'Folder name';

  @override
  String get create => 'Create';

  @override
  String get driveSpace => 'Drive space';

  @override
  String driveSelectedCount(int count) {
    return 'Selected $count';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get driveEmpty => 'Nothing here yet';

  @override
  String deleteItemsConfirm(int count) {
    return 'Delete $count items?';
  }

  @override
  String get composerHint => 'What\'s on your mind?';

  @override
  String get attachFromDrive => 'Choose from drive';

  @override
  String get poll => 'Poll';

  @override
  String pollChoiceHint(int n) {
    return 'Choice $n';
  }

  @override
  String get addChoice => 'Add choice';

  @override
  String get pollMultipleVotes => 'Allow multiple answers';

  @override
  String get pollDuration => 'Poll duration';

  @override
  String get pollNoExpiry => 'No expiry';

  @override
  String pollMinutes(int n) {
    return '$n min';
  }

  @override
  String pollHours(int n) {
    return '$n hours';
  }

  @override
  String pollDays(int n) {
    return '$n days';
  }

  @override
  String get reactionAcceptance => 'Reaction acceptance';

  @override
  String get acceptanceAny => 'Any reactions';

  @override
  String get acceptanceLikeOnly => 'Likes only';

  @override
  String get acceptanceLikeOnlyForRemote => 'Likes only for remote';

  @override
  String get acceptanceNonSensitive => 'Non-sensitive only';

  @override
  String get acceptanceNonSensitiveLocalLike =>
      'Non-sensitive; remote likes only';

  @override
  String get saveDraftNow => 'Save draft';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get preview => 'Preview';

  @override
  String get editLabel => 'Edit';

  @override
  String get previewFootnote =>
      'The preview does not render attachments, polls or recipients.';

  @override
  String get previewNothing => 'Nothing to preview yet.';

  @override
  String get resetDraft => 'Reset';

  @override
  String get insertHashtag => 'Hashtag';

  @override
  String get insertMention => 'Mention';

  @override
  String get insertEmoji => 'Emoji';

  @override
  String get schedule => 'Schedule';

  @override
  String get scheduleRemove => 'Send now';

  @override
  String get schedulePick => 'Pick date and time';

  @override
  String scheduledFor(String time) {
    return 'Scheduled for $time';
  }

  @override
  String get visibilitySpecified => 'Direct';

  @override
  String get selectRecipients => 'Recipients';

  @override
  String get searchUsers => 'Search users';

  @override
  String get pollNeedsTwoChoices => 'A poll needs at least two choices';

  @override
  String charLimit(int used, int limit) {
    return '$used / $limit';
  }

  @override
  String get noResults => 'No results';

  @override
  String get announcements => 'Announcements';

  @override
  String get instanceAnnouncements => 'Instance announcements';

  @override
  String get noAnnouncements => 'No announcements';

  @override
  String get agreeAppTerms =>
      'I have read and agree to the app terms and privacy policy';

  @override
  String get agreeInstanceTos =>
      'I have read and agree to this instance\'s terms of service';

  @override
  String get viewDocument => 'View';

  @override
  String get complianceRequired => 'Accept the terms above to continue';

  @override
  String get complianceTermsTitle => 'Terms of Service';

  @override
  String get compliancePrivacyTitle => 'Privacy Policy';

  @override
  String get complianceDocsTitle => 'App Terms and Privacy Policy';

  @override
  String get impressum => 'Impressum';

  @override
  String get instanceRules => 'Server rules';

  @override
  String get instanceLinks => 'Instance links';

  @override
  String get metaLoadFailed => 'Could not load instance information';

  @override
  String get noServerRules => 'This instance has not published server rules';

  @override
  String get oobeLanguageTitle => 'Choose a language';

  @override
  String get oobeWelcomeTitle => 'Welcome to Nyachi';

  @override
  String get oobeWelcomeBody =>
      'Nyachi is a Misskey client. A few quick steps and you are ready to go.';

  @override
  String get oobeLoginTitle => 'Sign in to your instance';

  @override
  String get oobeLoginDone => 'Signed in — continue';

  @override
  String get oobeAppearanceTitle => 'Appearance';

  @override
  String get oobeDoneTitle => 'You are all set';

  @override
  String get oobeDoneBody => 'Initial setup is complete. Enjoy Nyachi!';

  @override
  String get oobeEnterApp => 'Enter Nyachi';

  @override
  String get oobeBack => 'Back';

  @override
  String get oobeNext => 'Next';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get updateOpen => 'Open release';

  @override
  String get updateFailed => 'Could not check for updates';

  @override
  String get cacheManagement => 'Cache management';

  @override
  String get cacheManagementSubtitle =>
      'Cached instance info, emoji catalogue, notifications and following list';

  @override
  String get cacheKindInstanceMeta => 'Instance info';

  @override
  String get cacheKindEmojiCatalog => 'Emoji catalogue';

  @override
  String get cacheKindNotifications => 'Notifications';

  @override
  String get cacheKindFollowings => 'Following list';

  @override
  String cacheEntryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get clearCache => 'Clear';

  @override
  String get clearAllCaches => 'Clear all caches';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get cacheClearConfirm =>
      'Clear this cache? It will be refetched when needed.';

  @override
  String get cacheClearAllConfirm =>
      'Clear all caches? They will be refetched when needed.';

  @override
  String get moreMenu => 'More';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get favorite => 'Favorite';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get userMemo => 'User memo';

  @override
  String get memoHint => 'Only visible to you';

  @override
  String get memoSaved => 'Memo saved';

  @override
  String get muteThread => 'Mute thread';

  @override
  String get unmuteThread => 'Unmute thread';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get deleteNoteConfirm =>
      'This note will be deleted. This cannot be undone.';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get report => 'Report';

  @override
  String get reportUser => 'Report user';

  @override
  String reportUserBody(String username) {
    return 'This reports the user @$username, not just this note.';
  }

  @override
  String get reportUserHint => 'Describe the reason (required)';

  @override
  String get reportSent => 'Report sent';

  @override
  String get emojiOther => 'Other';

  @override
  String get drafts => 'Drafts';

  @override
  String get noDrafts => 'No saved drafts';

  @override
  String get draftsLoadFailed => 'Could not load drafts';

  @override
  String get scheduledPosts => 'Scheduled posts';

  @override
  String get noScheduledPosts => 'No scheduled posts';
}
