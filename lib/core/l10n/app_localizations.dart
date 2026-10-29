import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nyachi'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @switchLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFound;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired'**
  String get errorAuth;

  /// No description provided for @errorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment and try again.'**
  String get errorRateLimit;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'The server could not complete the request'**
  String get errorServer;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the instance. Check your connection and try again.'**
  String get errorNetwork;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'Secure storage is unavailable'**
  String get errorStorage;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Misskey'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use MiAuth or an access token.'**
  String get loginSubtitle;

  /// No description provided for @instanceHost.
  ///
  /// In en, this message translates to:
  /// **'Instance host'**
  String get instanceHost;

  /// No description provided for @instanceHostHint.
  ///
  /// In en, this message translates to:
  /// **'misskey.io'**
  String get instanceHostHint;

  /// No description provided for @miAuthLogin.
  ///
  /// In en, this message translates to:
  /// **'Continue with MiAuth'**
  String get miAuthLogin;

  /// No description provided for @manualToken.
  ///
  /// In en, this message translates to:
  /// **'Use an access token'**
  String get manualToken;

  /// No description provided for @token.
  ///
  /// In en, this message translates to:
  /// **'Access token'**
  String get token;

  /// No description provided for @openBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open browser'**
  String get openBrowser;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @waitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval…'**
  String get waitingApproval;

  /// No description provided for @cancelLogin.
  ///
  /// In en, this message translates to:
  /// **'Cancel sign-in'**
  String get cancelLogin;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed'**
  String get loginFailed;

  /// No description provided for @hostRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an instance host'**
  String get hostRequired;

  /// No description provided for @tokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an access token'**
  String get tokenRequired;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get sessionExpired;

  /// No description provided for @relogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get relogin;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @global.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @compose.
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get compose;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @noReplies.
  ///
  /// In en, this message translates to:
  /// **'No replies yet'**
  String get noReplies;

  /// No description provided for @emptyTimeline.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get emptyTimeline;

  /// No description provided for @emptyNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get emptyNotifications;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this feed'**
  String get loadFailed;

  /// No description provided for @usingCache.
  ///
  /// In en, this message translates to:
  /// **'Showing cached content'**
  String get usingCache;

  /// No description provided for @liveReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get liveReconnecting;

  /// No description provided for @liveOffline.
  ///
  /// In en, this message translates to:
  /// **'Live updates paused'**
  String get liveOffline;

  /// No description provided for @sensitiveContent.
  ///
  /// In en, this message translates to:
  /// **'Sensitive content'**
  String get sensitiveContent;

  /// No description provided for @showContent.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showContent;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @renote.
  ///
  /// In en, this message translates to:
  /// **'Renote'**
  String get renote;

  /// No description provided for @reaction.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get reaction;

  /// No description provided for @reactions.
  ///
  /// In en, this message translates to:
  /// **'Reactions'**
  String get reactions;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloadSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to'**
  String get downloadSaved;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @react.
  ///
  /// In en, this message translates to:
  /// **'React'**
  String get react;

  /// No description provided for @renoted.
  ///
  /// In en, this message translates to:
  /// **'Renoted'**
  String get renoted;

  /// No description provided for @replySent.
  ///
  /// In en, this message translates to:
  /// **'Reply posted'**
  String get replySent;

  /// No description provided for @videoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get videoUnavailable;

  /// No description provided for @openExternal.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openExternal;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @noteCount.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get noteCount;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @accountSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get accountSwitch;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotes;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @allRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allRead;

  /// No description provided for @notificationNote.
  ///
  /// In en, this message translates to:
  /// **'posted a note'**
  String get notificationNote;

  /// No description provided for @notificationMention.
  ///
  /// In en, this message translates to:
  /// **'mentioned you'**
  String get notificationMention;

  /// No description provided for @notificationReply.
  ///
  /// In en, this message translates to:
  /// **'replied to you'**
  String get notificationReply;

  /// No description provided for @notificationRenote.
  ///
  /// In en, this message translates to:
  /// **'renoted your note'**
  String get notificationRenote;

  /// No description provided for @notificationQuote.
  ///
  /// In en, this message translates to:
  /// **'quoted your note'**
  String get notificationQuote;

  /// No description provided for @notificationReaction.
  ///
  /// In en, this message translates to:
  /// **'reacted to your note'**
  String get notificationReaction;

  /// No description provided for @notificationPollEnded.
  ///
  /// In en, this message translates to:
  /// **'a poll ended'**
  String get notificationPollEnded;

  /// No description provided for @notificationFollow.
  ///
  /// In en, this message translates to:
  /// **'followed you'**
  String get notificationFollow;

  /// No description provided for @notificationReceiveFollowRequest.
  ///
  /// In en, this message translates to:
  /// **'sent a follow request'**
  String get notificationReceiveFollowRequest;

  /// No description provided for @notificationFollowRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'accepted your follow request'**
  String get notificationFollowRequestAccepted;

  /// No description provided for @notificationRoleAssigned.
  ///
  /// In en, this message translates to:
  /// **'assigned you a role'**
  String get notificationRoleAssigned;

  /// No description provided for @notificationChatRoomInvitation.
  ///
  /// In en, this message translates to:
  /// **'invited you to a chat room'**
  String get notificationChatRoomInvitation;

  /// No description provided for @notificationAchievement.
  ///
  /// In en, this message translates to:
  /// **'earned an achievement'**
  String get notificationAchievement;

  /// No description provided for @notificationExportCompleted.
  ///
  /// In en, this message translates to:
  /// **'export completed'**
  String get notificationExportCompleted;

  /// No description provided for @notificationLogin.
  ///
  /// In en, this message translates to:
  /// **'new sign-in'**
  String get notificationLogin;

  /// No description provided for @notificationCreateToken.
  ///
  /// In en, this message translates to:
  /// **'access token created'**
  String get notificationCreateToken;

  /// No description provided for @notificationApp.
  ///
  /// In en, this message translates to:
  /// **'app notification'**
  String get notificationApp;

  /// No description provided for @notificationGroupedReaction.
  ///
  /// In en, this message translates to:
  /// **'reacted to your note'**
  String get notificationGroupedReaction;

  /// No description provided for @notificationGroupedRenote.
  ///
  /// In en, this message translates to:
  /// **'renoted your note'**
  String get notificationGroupedRenote;

  /// No description provided for @notificationGeneric.
  ///
  /// In en, this message translates to:
  /// **'notification'**
  String get notificationGeneric;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes and users'**
  String get searchHint;

  /// No description provided for @notesTab.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTab;

  /// No description provided for @usersTab.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTab;

  /// No description provided for @noTrends.
  ///
  /// In en, this message translates to:
  /// **'No trends right now'**
  String get noTrends;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsers;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noSearchResults;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @replyTo.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyTo;

  /// No description provided for @contentWarning.
  ///
  /// In en, this message translates to:
  /// **'Content warning'**
  String get contentWarning;

  /// No description provided for @contentWarningHint.
  ///
  /// In en, this message translates to:
  /// **'Optional warning'**
  String get contentWarningHint;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// No description provided for @visibilityHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get visibilityHome;

  /// No description provided for @visibilityFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get visibilityFollowers;

  /// No description provided for @localOnly.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get localOnly;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @posting.
  ///
  /// In en, this message translates to:
  /// **'Posting…'**
  String get posting;

  /// No description provided for @draftRestored.
  ///
  /// In en, this message translates to:
  /// **'Draft restored'**
  String get draftRestored;

  /// No description provided for @deleteDraft.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get deleteDraft;

  /// No description provided for @draftDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted'**
  String get draftDeleted;

  /// No description provided for @postFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not post'**
  String get postFailed;

  /// No description provided for @overLimit.
  ///
  /// In en, this message translates to:
  /// **'This note is too long'**
  String get overLimit;

  /// No description provided for @emptyContent.
  ///
  /// In en, this message translates to:
  /// **'Write something first'**
  String get emptyContent;

  /// No description provided for @direct.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @noRooms.
  ///
  /// In en, this message translates to:
  /// **'No rooms yet'**
  String get noRooms;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message'**
  String get messageHint;

  /// No description provided for @attach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send'**
  String get sendFailed;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @loadOlder.
  ///
  /// In en, this message translates to:
  /// **'Load older'**
  String get loadOlder;

  /// No description provided for @roomOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roomOwner;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageChinese;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @visibleTabs.
  ///
  /// In en, this message translates to:
  /// **'Visible tabs'**
  String get visibleTabs;

  /// No description provided for @tabOrder.
  ///
  /// In en, this message translates to:
  /// **'Tab order'**
  String get tabOrder;

  /// No description provided for @homeLocked.
  ///
  /// In en, this message translates to:
  /// **'Home cannot be hidden'**
  String get homeLocked;

  /// No description provided for @removeAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this account and its local data?'**
  String get removeAccountConfirm;

  /// No description provided for @activeAccount.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeAccount;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 0.1.0+1'**
  String get appVersion;

  /// No description provided for @noAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts'**
  String get noAccounts;

  /// No description provided for @externalLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get externalLinkFailed;

  /// No description provided for @copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not copy the link'**
  String get copyFailed;

  /// No description provided for @searchSubmit.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchSubmit;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String characterCount(int count);

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @serverNameFallback.
  ///
  /// In en, this message translates to:
  /// **'Misskey'**
  String get serverNameFallback;

  /// No description provided for @chatRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get chatRoom;

  /// No description provided for @chatWith.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatWith;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large'**
  String get fileTooLarge;

  /// No description provided for @noFile.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFile;

  /// No description provided for @removeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get removeAttachment;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @noteDetail.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteDetail;

  /// No description provided for @removeAccount.
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get removeAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColor;

  /// No description provided for @instanceColor.
  ///
  /// In en, this message translates to:
  /// **'Instance color'**
  String get instanceColor;

  /// No description provided for @colorIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @detailBreakpoint.
  ///
  /// In en, this message translates to:
  /// **'Details panel breakpoint'**
  String get detailBreakpoint;

  /// No description provided for @removeReaction.
  ///
  /// In en, this message translates to:
  /// **'Remove reaction'**
  String get removeReaction;

  /// No description provided for @removeReactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove your response {reaction}?'**
  String removeReactionConfirm(String reaction);

  /// No description provided for @changeReactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'React with {reaction}?'**
  String changeReactionConfirm(String reaction);

  /// No description provided for @contributors.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributors;

  /// No description provided for @contributorsBody.
  ///
  /// In en, this message translates to:
  /// **'Nyachi is developed by SakuraCake and community contributors.'**
  String get contributorsBody;

  /// No description provided for @flutterTrademark.
  ///
  /// In en, this message translates to:
  /// **'Flutter is a trademark of Google LLC. Nyachi is not affiliated with or endorsed by Google.'**
  String get flutterTrademark;

  /// No description provided for @viewLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get viewLicenses;

  /// No description provided for @licensesBody.
  ///
  /// In en, this message translates to:
  /// **'{count} packages bundled with this app.'**
  String licensesBody(int count);

  /// No description provided for @drive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get drive;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @noFiles.
  ///
  /// In en, this message translates to:
  /// **'No files yet'**
  String get noFiles;

  /// No description provided for @deleteFileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteFileConfirm(String name);

  /// No description provided for @driveUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get driveUsage;

  /// No description provided for @thirdPartyNotices.
  ///
  /// In en, this message translates to:
  /// **'Third-party notices'**
  String get thirdPartyNotices;

  /// No description provided for @bundledPackages.
  ///
  /// In en, this message translates to:
  /// **'Bundled packages'**
  String get bundledPackages;

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalNotice;

  /// No description provided for @renoteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Renote'**
  String get renoteConfirmTitle;

  /// No description provided for @renoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Renote this post?'**
  String get renoteConfirm;

  /// No description provided for @centerContent.
  ///
  /// In en, this message translates to:
  /// **'Center content'**
  String get centerContent;

  /// No description provided for @centerContentHint.
  ///
  /// In en, this message translates to:
  /// **'Keep the reading column centered on wide screens'**
  String get centerContentHint;

  /// No description provided for @openFullComposer.
  ///
  /// In en, this message translates to:
  /// **'Open full composer'**
  String get openFullComposer;

  /// No description provided for @attachFiles.
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get attachFiles;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// No description provided for @noAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments'**
  String get noAttachments;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @driveSpace.
  ///
  /// In en, this message translates to:
  /// **'Drive space'**
  String get driveSpace;

  /// No description provided for @driveSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected {count}'**
  String driveSelectedCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deleteItemsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} items?'**
  String deleteItemsConfirm(int count);

  /// No description provided for @composerHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get composerHint;

  /// No description provided for @attachMedia.
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get attachMedia;

  /// No description provided for @poll.
  ///
  /// In en, this message translates to:
  /// **'Poll'**
  String get poll;

  /// No description provided for @pollChoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Choice {n}'**
  String pollChoiceHint(int n);

  /// No description provided for @addChoice.
  ///
  /// In en, this message translates to:
  /// **'Add choice'**
  String get addChoice;

  /// No description provided for @pollMultipleVotes.
  ///
  /// In en, this message translates to:
  /// **'Allow multiple answers'**
  String get pollMultipleVotes;

  /// No description provided for @pollDuration.
  ///
  /// In en, this message translates to:
  /// **'Poll duration'**
  String get pollDuration;

  /// No description provided for @pollNoExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry'**
  String get pollNoExpiry;

  /// No description provided for @pollMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String pollMinutes(int n);

  /// No description provided for @pollHours.
  ///
  /// In en, this message translates to:
  /// **'{n} hours'**
  String pollHours(int n);

  /// No description provided for @pollDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String pollDays(int n);

  /// No description provided for @reactionAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Reaction acceptance'**
  String get reactionAcceptance;

  /// No description provided for @acceptanceAny.
  ///
  /// In en, this message translates to:
  /// **'Any reactions'**
  String get acceptanceAny;

  /// No description provided for @acceptanceLikeOnly.
  ///
  /// In en, this message translates to:
  /// **'Likes only'**
  String get acceptanceLikeOnly;

  /// No description provided for @acceptanceNonSensitive.
  ///
  /// In en, this message translates to:
  /// **'Non-sensitive only'**
  String get acceptanceNonSensitive;

  /// No description provided for @acceptanceNonSensitiveLocalLike.
  ///
  /// In en, this message translates to:
  /// **'Non-sensitive; remote likes only'**
  String get acceptanceNonSensitiveLocalLike;

  /// No description provided for @saveDraftNow.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraftNow;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @resetDraft.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetDraft;

  /// No description provided for @insertHashtag.
  ///
  /// In en, this message translates to:
  /// **'Hashtag'**
  String get insertHashtag;

  /// No description provided for @insertMention.
  ///
  /// In en, this message translates to:
  /// **'Mention'**
  String get insertMention;

  /// No description provided for @insertEmoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get insertEmoji;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @scheduleRemove.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get scheduleRemove;

  /// No description provided for @schedulePick.
  ///
  /// In en, this message translates to:
  /// **'Pick date and time'**
  String get schedulePick;

  /// No description provided for @scheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {time}'**
  String scheduledFor(String time);

  /// No description provided for @visibilitySpecified.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get visibilitySpecified;

  /// No description provided for @selectRecipients.
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get selectRecipients;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsers;

  /// No description provided for @pollNeedsTwoChoices.
  ///
  /// In en, this message translates to:
  /// **'A poll needs at least two choices'**
  String get pollNeedsTwoChoices;

  /// No description provided for @charLimit.
  ///
  /// In en, this message translates to:
  /// **'{used} / {limit}'**
  String charLimit(int used, int limit);

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements'**
  String get noAnnouncements;

  /// No description provided for @agreeAppTerms.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the app terms and privacy policy'**
  String get agreeAppTerms;

  /// No description provided for @agreeInstanceTos.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to this instance\'s terms of service'**
  String get agreeInstanceTos;

  /// No description provided for @viewDocument.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewDocument;

  /// No description provided for @complianceRequired.
  ///
  /// In en, this message translates to:
  /// **'Accept the terms above to continue'**
  String get complianceRequired;

  /// No description provided for @complianceTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get complianceTermsTitle;

  /// No description provided for @compliancePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get compliancePrivacyTitle;

  /// No description provided for @complianceDocsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Terms and Privacy Policy'**
  String get complianceDocsTitle;

  /// No description provided for @impressum.
  ///
  /// In en, this message translates to:
  /// **'Impressum'**
  String get impressum;

  /// No description provided for @instanceRules.
  ///
  /// In en, this message translates to:
  /// **'Server rules'**
  String get instanceRules;

  /// No description provided for @instanceLinks.
  ///
  /// In en, this message translates to:
  /// **'Instance links'**
  String get instanceLinks;

  /// No description provided for @metaLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load instance information'**
  String get metaLoadFailed;

  /// No description provided for @noServerRules.
  ///
  /// In en, this message translates to:
  /// **'This instance has not published server rules'**
  String get noServerRules;

  /// No description provided for @oobeLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get oobeLanguageTitle;

  /// No description provided for @oobeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nyachi'**
  String get oobeWelcomeTitle;

  /// No description provided for @oobeWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Nyachi is a Misskey client. A few quick steps and you are ready to go.'**
  String get oobeWelcomeBody;

  /// No description provided for @oobeLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your instance'**
  String get oobeLoginTitle;

  /// No description provided for @oobeLoginDone.
  ///
  /// In en, this message translates to:
  /// **'Signed in — continue'**
  String get oobeLoginDone;

  /// No description provided for @oobeAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get oobeAppearanceTitle;

  /// No description provided for @oobeDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You are all set'**
  String get oobeDoneTitle;

  /// No description provided for @oobeDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Initial setup is complete. Enjoy Nyachi!'**
  String get oobeDoneBody;

  /// No description provided for @oobeEnterApp.
  ///
  /// In en, this message translates to:
  /// **'Enter Nyachi'**
  String get oobeEnterApp;

  /// No description provided for @oobeBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get oobeBack;

  /// No description provided for @oobeNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get oobeNext;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
