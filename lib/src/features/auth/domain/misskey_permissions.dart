/// Misskey API 权限常量定义
///
/// 完整权限列表参考: https://misskey-hub.net/cn/docs/for-developers/api/permission/
class MisskeyPermissions {
  MisskeyPermissions._();

  // ======================== 账户 ========================
  static const readAccount = 'read:account';
  static const writeAccount = 'write:account';

  // ======================== 屏蔽 ========================
  static const readBlocks = 'read:blocks';
  static const writeBlocks = 'write:blocks';

  // ======================== 网盘 ========================
  static const readDrive = 'read:drive';
  static const writeDrive = 'write:drive';

  // ======================== 收藏夹 ========================
  static const readFavorites = 'read:favorites';
  static const writeFavorites = 'write:favorites';

  // ======================== 关注 ========================
  static const readFollowing = 'read:following';
  static const writeFollowing = 'write:following';

  // ======================== 消息 ========================
  static const readMessaging = 'read:messaging';
  static const writeMessaging = 'write:messaging';

  // ======================== 静音 ========================
  static const readMutes = 'read:mutes';
  static const writeMutes = 'write:mutes';

  // ======================== 帖子 ========================
  static const writeNotes = 'write:notes';

  // ======================== 通知 ========================
  static const readNotifications = 'read:notifications';
  static const writeNotifications = 'write:notifications';

  // ======================== 回应 ========================
  static const readReactions = 'read:reactions';
  static const writeReactions = 'write:reactions';

  // ======================== 投票 ========================
  static const writeVotes = 'write:votes';

  // ======================== 页面 ========================
  static const readPages = 'read:pages';
  static const writePages = 'write:pages';
  static const readPageLikes = 'read:page-likes';
  static const writePageLikes = 'write:page-likes';

  // ======================== 用户组 ========================
  static const readUserGroups = 'read:user-groups';
  static const writeUserGroups = 'write:user-groups';

  // ======================== 频道 ========================
  static const readChannels = 'read:channels';
  static const writeChannels = 'write:channels';

  // ======================== 图库 ========================
  static const readGallery = 'read:gallery';
  static const writeGallery = 'write:gallery';
  static const readGalleryLikes = 'read:gallery-likes';
  static const writeGalleryLikes = 'write:gallery-likes';

  // ======================== Play ========================
  static const readFlash = 'read:flash';
  static const writeFlash = 'write:flash';
  static const readFlashLikes = 'read:flash-likes';
  static const writeFlashLikes = 'write:flash-likes';

  // ======================== 邀请码 ========================
  static const readInviteCodes = 'read:invite-codes';
  static const writeInviteCodes = 'write:invite-codes';

  // ======================== 便签收藏 ========================
  static const readClipFavorite = 'read:clip-favorite';
  static const writeClipFavorite = 'write:clip-favorite';

  // ======================== 联邦 ========================
  static const readFederation = 'read:federation';

  // ======================== 举报 ========================
  static const writeReportAbuse = 'write:report-abuse';

  // ======================== 聊天 ========================
  static const readChat = 'read:chat';
  static const writeChat = 'write:chat';

  // ======================== 管理员权限 ========================
  static const readAdminAbuseUserReports = 'read:admin:abuse-user-reports';
  static const writeAdminDeleteAccount = 'write:admin:delete-account';
  static const writeAdminDeleteAllFilesOfAUser =
      'write:admin:delete-all-files-of-a-user';
  static const readAdminIndexStats = 'read:admin:index-stats';
  static const readAdminTableStats = 'read:admin:table-stats';
  static const readAdminUserIps = 'read:admin:user-ips';
  static const readAdminMeta = 'read:admin:meta';
  static const writeAdminResetPassword = 'write:admin:reset-password';
  static const writeAdminResolveAbuseUserReport =
      'write:admin:resolve-abuse-user-report';
  static const writeAdminSendEmail = 'write:admin:send-email';
  static const readAdminServerInfo = 'read:admin:server-info';
  static const readAdminShowModerationLog = 'read:admin:show-moderation-log';
  static const readAdminShowUser = 'read:admin:show-user';
  static const writeAdminSuspendUser = 'write:admin:suspend-user';
  static const writeAdminUnsetUserAvatar = 'write:admin:unset-user-avatar';
  static const writeAdminUnsetUserBanner = 'write:admin:unset-user-banner';
  static const writeAdminUnsuspendUser = 'write:admin:unsuspend-user';
  static const writeAdminMeta = 'write:admin:meta';
  static const writeAdminUserNote = 'write:admin:user-note';
  static const writeAdminRoles = 'write:admin:roles';
  static const readAdminRoles = 'read:admin:roles';
  static const writeAdminRelays = 'write:admin:relays';
  static const readAdminRelays = 'read:admin:relays';
  static const writeAdminInviteCodes = 'write:admin:invite-codes';
  static const readAdminInviteCodes = 'read:admin:invite-codes';
  static const writeAdminAnnouncements = 'write:admin:announcements';
  static const readAdminAnnouncements = 'read:admin:announcements';
  static const writeAdminAvatarDecorations = 'write:admin:avatar-decorations';
  static const readAdminAvatarDecorations = 'read:admin:avatar-decorations';
  static const writeAdminFederation = 'write:admin:federation';
  static const writeAdminAccount = 'write:admin:account';
  static const readAdminAccount = 'read:admin:account';
  static const writeAdminEmoji = 'write:admin:emoji';
  static const readAdminEmoji = 'read:admin:emoji';
  static const writeAdminQueue = 'write:admin:queue';
  static const readAdminQueue = 'read:admin:queue';
  static const writeAdminPromo = 'write:admin:promo';
  static const writeAdminDrive = 'write:admin:drive';
  static const readAdminDrive = 'read:admin:drive';
  static const writeAdminAd = 'write:admin:ad';
  static const readAdminAd = 'read:admin:ad';

  /// Nyachi 登录时请求的所有权限
  static const List<String> defaultScopes = [
    readAccount,
    writeAccount,
    readNotes,
    writeNotes,
    readBlocks,
    writeBlocks,
    readDrive,
    writeDrive,
    readFavorites,
    writeFavorites,
    readFollowing,
    writeFollowing,
    readMessaging,
    writeMessaging,
    readMutes,
    writeMutes,
    readNotifications,
    writeNotifications,
    readReactions,
    writeReactions,
    writeVotes,
    readPages,
    writePages,
    readGallery,
    writeGallery,
    readFlash,
    writeFlash,
    readChat,
    writeChat,
    readChannels,
    writeChannels,
    readUserGroups,
    writeUserGroups,
    readClipFavorite,
    writeClipFavorite,
    readFederation,
    writeReportAbuse,
    readInviteCodes,
    writeInviteCodes,
  ];

  /// 将权限列表转换为 MiAuth 所需的逗号分隔字符串
  static String toMiAuthString([List<String>? scopes]) {
    return (scopes ?? defaultScopes).join(',');
  }

  /// 权限分组信息，用于 UI 展示
  static const Map<String, List<PermissionEntry>> permissionGroups = {
    'account': [
      PermissionEntry(readAccount, '查看账户信息', isAdmin: false),
      PermissionEntry(writeAccount, '更改帐户信息', isAdmin: false),
    ],
    'blocks': [
      PermissionEntry(readBlocks, '查看黑名单', isAdmin: false),
      PermissionEntry(writeBlocks, '编辑黑名单', isAdmin: false),
    ],
    'drive': [
      PermissionEntry(readDrive, '查看网盘', isAdmin: false),
      PermissionEntry(writeDrive, '管理网盘文件', isAdmin: false),
    ],
    'favorites': [
      PermissionEntry(readFavorites, '查看收藏夹', isAdmin: false),
      PermissionEntry(writeFavorites, '编辑收藏夹', isAdmin: false),
    ],
    'following': [
      PermissionEntry(readFollowing, '查看关注信息', isAdmin: false),
      PermissionEntry(writeFollowing, '关注/取消关注', isAdmin: false),
    ],
    'messaging': [
      PermissionEntry(readMessaging, '查看消息', isAdmin: false),
      PermissionEntry(writeMessaging, '编写或删除消息', isAdmin: false),
    ],
    'mutes': [
      PermissionEntry(readMutes, '查看屏蔽列表', isAdmin: false),
      PermissionEntry(writeMutes, '编辑屏蔽列表', isAdmin: false),
    ],
    'notes': [
      PermissionEntry(writeNotes, '编写或删除帖子', isAdmin: false),
    ],
    'notifications': [
      PermissionEntry(readNotifications, '查看通知', isAdmin: false),
      PermissionEntry(writeNotifications, '管理通知', isAdmin: false),
    ],
    'reactions': [
      PermissionEntry(readReactions, '查看回应', isAdmin: false),
      PermissionEntry(writeReactions, '编辑回应', isAdmin: false),
    ],
    'votes': [
      PermissionEntry(writeVotes, '投票', isAdmin: false),
    ],
    'pages': [
      PermissionEntry(readPages, '查看页面', isAdmin: false),
      PermissionEntry(writePages, '编辑自己的页面', isAdmin: false),
      PermissionEntry(readPageLikes, '查看点赞列表', isAdmin: false),
      PermissionEntry(writePageLikes, '管理点赞列表', isAdmin: false),
    ],
    'user-groups': [
      PermissionEntry(readUserGroups, '查看用户组', isAdmin: false),
      PermissionEntry(writeUserGroups, '管理用户组', isAdmin: false),
    ],
    'channels': [
      PermissionEntry(readChannels, '查看频道', isAdmin: false),
      PermissionEntry(writeChannels, '管理频道', isAdmin: false),
    ],
    'gallery': [
      PermissionEntry(readGallery, '查看图库', isAdmin: false),
      PermissionEntry(writeGallery, '编辑图库', isAdmin: false),
      PermissionEntry(readGalleryLikes, '查看赞过的图片', isAdmin: false),
      PermissionEntry(writeGalleryLikes, '管理赞过的图片', isAdmin: false),
    ],
    'flash': [
      PermissionEntry(readFlash, '查看 Play', isAdmin: false),
      PermissionEntry(writeFlash, '编辑 Play', isAdmin: false),
      PermissionEntry(readFlashLikes, '查看 Play 的点赞', isAdmin: false),
      PermissionEntry(writeFlashLikes, '编辑 Play 的点赞列表', isAdmin: false),
    ],
    'invite-codes': [
      PermissionEntry(readInviteCodes, '获取邀请码', isAdmin: false),
      PermissionEntry(writeInviteCodes, '生成邀请码', isAdmin: false),
    ],
    'clip-favorite': [
      PermissionEntry(readClipFavorite, '查看喜欢的便签', isAdmin: false),
      PermissionEntry(writeClipFavorite, '管理喜欢的便签', isAdmin: false),
    ],
    'federation': [
      PermissionEntry(readFederation, '查看联邦相关信息', isAdmin: false),
    ],
    'report-abuse': [
      PermissionEntry(writeReportAbuse, '举报用户', isAdmin: false),
    ],
    'chat': [
      PermissionEntry(readChat, '浏览聊天', isAdmin: false),
      PermissionEntry(writeChat, '操作聊天', isAdmin: false),
    ],
    'admin': [
      PermissionEntry(readAdminAbuseUserReports, '查看来自其他用户的举报',
          isAdmin: true),
      PermissionEntry(writeAdminDeleteAccount, '删除用户账户', isAdmin: true),
      PermissionEntry(writeAdminDeleteAllFilesOfAUser, '删除用户所有的文件',
          isAdmin: true),
      PermissionEntry(readAdminIndexStats, '查看数据库索引信息', isAdmin: true),
      PermissionEntry(readAdminTableStats, '查看数据库表格信息', isAdmin: true),
      PermissionEntry(readAdminUserIps, '查看用户 IP', isAdmin: true),
      PermissionEntry(readAdminMeta, '查看实例资料', isAdmin: true),
      PermissionEntry(writeAdminResetPassword, '重置用户密码', isAdmin: true),
      PermissionEntry(writeAdminResolveAbuseUserReport, '解决来自用户的举报',
          isAdmin: true),
      PermissionEntry(writeAdminSendEmail, '发送邮件', isAdmin: true),
      PermissionEntry(readAdminServerInfo, '查看服务器信息', isAdmin: true),
      PermissionEntry(readAdminShowModerationLog, '查看管理日志', isAdmin: true),
      PermissionEntry(readAdminShowUser, '查看用户隐私信息', isAdmin: true),
      PermissionEntry(writeAdminSuspendUser, '冻结用户', isAdmin: true),
      PermissionEntry(writeAdminUnsetUserAvatar, '删除用户头像', isAdmin: true),
      PermissionEntry(writeAdminUnsetUserBanner, '删除用户横幅', isAdmin: true),
      PermissionEntry(writeAdminUnsuspendUser, '解除用户冻结', isAdmin: true),
      PermissionEntry(writeAdminMeta, '编辑实例信息', isAdmin: true),
      PermissionEntry(writeAdminUserNote, '编辑管理笔记', isAdmin: true),
      PermissionEntry(writeAdminRoles, '编辑角色', isAdmin: true),
      PermissionEntry(readAdminRoles, '查看角色', isAdmin: true),
      PermissionEntry(writeAdminRelays, '编辑中继', isAdmin: true),
      PermissionEntry(readAdminRelays, '查看中继', isAdmin: true),
      PermissionEntry(writeAdminInviteCodes, '编辑邀请码', isAdmin: true),
      PermissionEntry(readAdminInviteCodes, '查看邀请码', isAdmin: true),
      PermissionEntry(writeAdminAnnouncements, '编辑公告', isAdmin: true),
      PermissionEntry(readAdminAnnouncements, '查看公告', isAdmin: true),
      PermissionEntry(writeAdminAvatarDecorations, '编辑头像挂件', isAdmin: true),
      PermissionEntry(readAdminAvatarDecorations, '查看头像挂件', isAdmin: true),
      PermissionEntry(writeAdminFederation, '编辑联邦信息', isAdmin: true),
      PermissionEntry(writeAdminAccount, '编辑用户账户', isAdmin: true),
      PermissionEntry(readAdminAccount, '查看用户信息', isAdmin: true),
      PermissionEntry(writeAdminEmoji, '管理表情', isAdmin: true),
      PermissionEntry(readAdminEmoji, '查看表情', isAdmin: true),
      PermissionEntry(writeAdminQueue, '管理作业队列', isAdmin: true),
      PermissionEntry(readAdminQueue, '查看作业队列', isAdmin: true),
      PermissionEntry(writeAdminPromo, '管理推广帖子', isAdmin: true),
      PermissionEntry(writeAdminDrive, '编辑用户网盘', isAdmin: true),
      PermissionEntry(readAdminDrive, '查看用户网盘信息', isAdmin: true),
      PermissionEntry(writeAdminAd, '管理广告', isAdmin: true),
      PermissionEntry(readAdminAd, '查看广告', isAdmin: true),
    ],
  };

  /// 不在 defaultScopes 中的额外权限（用于展示完整列表）
  static const List<String> additionalScopes = [
    readNotes,
    readAntennas,
    writeAntennas,
    readClips,
    writeClips,
  ];
}

/// 单个权限条目
class PermissionEntry {
  final String scope;
  final String description;
  final bool isAdmin;

  const PermissionEntry(this.scope, this.description, {this.isAdmin = false});
}

/// 常量补充 (read:notes, antennas, clips 在原文档中存在但未在权限表中单独列出)
const readNotes = 'read:notes';
const readAntennas = 'read:antennas';
const writeAntennas = 'write:antennas';
const readClips = 'read:clips';
const writeClips = 'write:clips';
