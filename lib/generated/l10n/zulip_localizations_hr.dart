// TODO(upstream) drop once gen-l10n stops using the deprecated members:
//   https://github.com/flutter/flutter/issues/191072
// ignore_for_file: deprecated_member_use

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'zulip_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class ZulipLocalizationsHr extends ZulipLocalizations {
  ZulipLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get aboutPageTitle => 'O aplikaciji Kloki Chat';

  @override
  String get aboutPageAppVersion => 'Verzija aplikacije';

  @override
  String get aboutPageAppVersionUnknown =>
      'Podaci o verziji aplikacije nisu pronađeni.';

  @override
  String get aboutPageReleaseNotes => 'Release notes';

  @override
  String get aboutPageOpenSourceLicenses => 'Licence otvorenog koda';

  @override
  String get chooseAccountPageTitle => 'Odaberite račun';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get switchAccountButtonTooltip => 'Switch account';

  @override
  String tryAnotherAccountMessage(Object url) {
    return 'Your account at $url is taking a while to load.';
  }

  @override
  String get tryAnotherAccountButton => 'Try another account';

  @override
  String get chooseAccountPageLogOutButton => 'Odjava';

  @override
  String get logOutConfirmationDialogTitle => 'Log out?';

  @override
  String get logOutConfirmationDialogMessage =>
      'To use this account in the future, you will have to re-enter the URL for your organization and your account information.';

  @override
  String get logOutConfirmationDialogConfirmButton => 'Log out';

  @override
  String get chooseAccountButtonAddAnAccount => 'Dodaj račun';

  @override
  String get navButtonAllChannels => 'Svi kanali';

  @override
  String get allChannelsPageTitle => 'Svi kanali';

  @override
  String get allChannelsEmptyPlaceholderHeader =>
      'U ovoj organizaciji nema kanala koje možete vidjeti.';

  @override
  String get profileButtonSendDirectMessage => 'Send direct message';

  @override
  String get errorCouldNotShowUserProfile => 'Could not show user profile.';

  @override
  String get permissionsNeededTitle => 'Potrebna dopuštenja';

  @override
  String get permissionsNeededOpenSettings => 'Otvori postavke';

  @override
  String get permissionsDeniedCameraAccess =>
      'Za slanje slike dopustite aplikaciji Kloki Chat dodatna dopuštenja u Postavkama.';

  @override
  String get actionSheetOptionSubscribe => 'Subscribe';

  @override
  String get subscribeFailedTitle => 'Failed to subscribe';

  @override
  String get actionSheetOptionMarkChannelAsRead => 'Mark channel as read';

  @override
  String get actionSheetOptionCopyChannelLink => 'Copy link to channel';

  @override
  String get actionSheetOptionListOfTopics => 'List of topics';

  @override
  String get actionSheetOptionChannelFeed => 'Channel feed';

  @override
  String get actionSheetOptionUnsubscribe => 'Unsubscribe';

  @override
  String unsubscribeConfirmationDialogTitle(String channelName) {
    return 'Unsubscribe from $channelName?';
  }

  @override
  String get unsubscribeConfirmationDialogMessageCannotResubscribe =>
      'Once you leave this channel, you will not be able to rejoin.';

  @override
  String get unsubscribeConfirmationDialogConfirmButton => 'Unsubscribe';

  @override
  String get unsubscribeFailedTitle => 'Failed to unsubscribe';

  @override
  String get actionSheetOptionPinChannel => 'Pin to top';

  @override
  String get actionSheetOptionUnpinChannel => 'Unpin from top';

  @override
  String get errorPinChannelFailedTitle => 'Failed to pin channel';

  @override
  String get errorUnpinChannelFailedTitle => 'Failed to unpin channel';

  @override
  String get actionSheetOptionMuteTopic => 'Mute topic';

  @override
  String get actionSheetOptionUnmuteTopic => 'Unmute topic';

  @override
  String get actionSheetOptionFollowTopic => 'Follow topic';

  @override
  String get actionSheetOptionUnfollowTopic => 'Unfollow topic';

  @override
  String get actionSheetOptionResolveTopic => 'Mark as resolved';

  @override
  String get actionSheetOptionUnresolveTopic => 'Mark as unresolved';

  @override
  String get errorResolveTopicFailedTitle => 'Failed to mark topic as resolved';

  @override
  String get errorUnresolveTopicFailedTitle =>
      'Failed to mark topic as unresolved';

  @override
  String get actionSheetOptionSeeWhoReacted => 'See who reacted';

  @override
  String get seeWhoReactedSheetNoReactions => 'This message has no reactions.';

  @override
  String seeWhoReactedSheetHeaderLabel(int num) {
    return 'Emoji reactions ($num total)';
  }

  @override
  String seeWhoReactedSheetEmojiNameWithVoteCount(String emojiName, int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num votes',
      one: '1 vote',
    );
    return '$emojiName: $_temp0';
  }

  @override
  String seeWhoReactedSheetUserListLabel(String emojiName, int num) {
    return 'Votes for $emojiName ($num)';
  }

  @override
  String get actionSheetOptionViewReadReceipts => 'View read receipts';

  @override
  String get actionSheetReadReceipts => 'Read receipts';

  @override
  String actionSheetReadReceiptsReadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This message has been <z-link>read</z-link> by $count people:',
      one: 'This message has been <z-link>read</z-link> by $count person:',
    );
    return '$_temp0';
  }

  @override
  String get actionSheetReadReceiptsZeroReadCount =>
      'No one has read this message yet.';

  @override
  String get actionSheetReadReceiptsErrorReadCount =>
      'Failed to load read receipts.';

  @override
  String get actionSheetOptionCopyMessageText => 'Copy message text';

  @override
  String get actionSheetOptionCopyMessageLink => 'Copy link to message';

  @override
  String get actionSheetOptionMarkAsUnread => 'Mark as unread from here';

  @override
  String get actionSheetOptionHideMutedMessage => 'Hide muted message again';

  @override
  String get actionSheetOptionHideLinkPreviews => 'Hide link previews';

  @override
  String get actionSheetOptionShowLinkPreviews => 'Show link previews';

  @override
  String get actionSheetOptionShare => 'Share';

  @override
  String get actionSheetOptionQuoteMessage => 'Quote message';

  @override
  String get actionSheetOptionStarMessage => 'Star message';

  @override
  String get actionSheetOptionUnstarMessage => 'Unstar message';

  @override
  String get actionSheetOptionEditMessage => 'Edit message';

  @override
  String get actionSheetOptionDeleteMessage => 'Delete message';

  @override
  String get deleteMessageConfirmationDialogTitle => 'Delete message?';

  @override
  String get deleteMessageConfirmationDialogMessage =>
      'Deleting a message permanently removes it for everyone.';

  @override
  String get deleteMessageConfirmationDialogConfirmButton => 'Delete';

  @override
  String get errorDeleteMessageFailedTitle => 'Failed to delete message';

  @override
  String get actionSheetOptionReportMessage => 'Report message';

  @override
  String get reportMessageDialogTitle => 'Report message';

  @override
  String get reportMessageDescription =>
      'Your report will be sent to the private moderation requests channel for this organization.';

  @override
  String get messageReportTypeSpam => 'Spam';

  @override
  String get messageReportTypeHarassment => 'Harassment';

  @override
  String get messageReportTypeInappropriate => 'Inappropriate content';

  @override
  String get messageReportTypeNorms => 'Violates community norms';

  @override
  String get messageReportTypeOther => 'Other reason';

  @override
  String get reportMessageReasonLabel =>
      'What’s the problem with this message?';

  @override
  String get reportMessageDescriptionLabel => 'Can you provide more details?';

  @override
  String get reportMessageDescriptionRequired => 'Please provide details.';

  @override
  String get reportMessageSubmitButton => 'Submit';

  @override
  String get reportMessageSuccess => 'Message reported';

  @override
  String get errorReportMessageFailedTitle => 'Failed to report message';

  @override
  String get actionSheetOptionMarkTopicAsRead => 'Mark topic as read';

  @override
  String get actionSheetOptionCopyTopicLink => 'Copy link to topic';

  @override
  String actionSheetTitleDm(String user) {
    return 'DMs with $user';
  }

  @override
  String get actionSheetTitleSelfDm => 'DMs with yourself';

  @override
  String get actionSheetTitleGroupDm => 'Group DM';

  @override
  String get actionSheetOptionViewProfile => 'View profile';

  @override
  String get actionSheetOptionMarkDmConversationAsRead =>
      'Mark conversation as read';

  @override
  String get errorWebAuthOperationalErrorTitle => 'Something went wrong';

  @override
  String get errorWebAuthOperationalError => 'An unexpected error occurred.';

  @override
  String get errorAccountLoggedInTitle => 'Account already logged in';

  @override
  String errorAccountLoggedIn(String email, String server) {
    return 'The account $email at $server is already in your list of accounts.';
  }

  @override
  String get errorCouldNotFetchMessageSource =>
      'Could not fetch message source.';

  @override
  String get errorCouldNotAccessUploadedFileTitle =>
      'Could not access uploaded file';

  @override
  String get errorCopyingFailed => 'Copying failed';

  @override
  String errorFailedToUploadFileTitle(String filename) {
    return 'Failed to upload file: $filename';
  }

  @override
  String filenameAndSizeInMiB(String filename, String size) {
    return '$filename: $size MiB';
  }

  @override
  String errorFilesTooLarge(
    int num,
    int maxFileUploadSizeMib,
    String listMessage,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num files are',
      one: 'File is',
    );
    return '$_temp0 larger than the server\'s limit of $maxFileUploadSizeMib MiB and will not be uploaded:\n\n$listMessage';
  }

  @override
  String errorFilesTooLargeTitle(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'Files',
      one: 'File',
    );
    return '$_temp0 too large';
  }

  @override
  String get errorCouldNotLoadSelectedFiles =>
      'The selected files could not be loaded.';

  @override
  String errorCouldNotReadFile(String filename) {
    return 'Could not read file: $filename';
  }

  @override
  String get errorLoginInvalidInputTitle => 'Invalid input';

  @override
  String get errorLoginFailedTitle => 'Login failed';

  @override
  String get errorMessageNotSent => 'Message not sent';

  @override
  String get errorMessageEditNotSaved => 'Message not saved';

  @override
  String errorLoginCouldNotConnect(String url) {
    return 'Failed to connect to server:\n$url';
  }

  @override
  String get errorCouldNotConnectTitle => 'Could not connect';

  @override
  String get errorMessageDoesNotSeemToExist =>
      'That message does not seem to exist.';

  @override
  String get errorQuotationFailed => 'Quotation failed';

  @override
  String errorServerMessage(String message) {
    return 'The server said:\n\n$message';
  }

  @override
  String get errorConnectingToServerShort =>
      'Error connecting to the chat server. Retrying…';

  @override
  String errorConnectingToServerDetails(String serverUrl, String error) {
    return 'Error connecting to the chat server at $serverUrl. Will retry:\n\n$error';
  }

  @override
  String get errorHandlingEventTitle =>
      'Error handling a Zulip event. Retrying connection…';

  @override
  String errorHandlingEventDetails(
    String serverUrl,
    String error,
    String event,
  ) {
    return 'Error handling a Zulip event from $serverUrl; will retry.\n\nError: $error\n\nEvent: $event';
  }

  @override
  String get errorCouldNotOpenLinkTitle => 'Unable to open link';

  @override
  String errorCouldNotOpenLink(String url) {
    return 'Link could not be opened: $url';
  }

  @override
  String get errorMuteTopicFailed => 'Failed to mute topic';

  @override
  String get errorUnmuteTopicFailed => 'Failed to unmute topic';

  @override
  String get errorFollowTopicFailed => 'Failed to follow topic';

  @override
  String get errorUnfollowTopicFailed => 'Failed to unfollow topic';

  @override
  String get errorSharingFailed => 'Sharing failed';

  @override
  String get errorStarMessageFailedTitle => 'Failed to star message';

  @override
  String get errorUnstarMessageFailedTitle => 'Failed to unstar message';

  @override
  String get errorHideLinkPreviewsFailedTitle => 'Failed to hide link previews';

  @override
  String get errorShowLinkPreviewsFailedTitle => 'Failed to show link previews';

  @override
  String get errorCouldNotEditMessageTitle => 'Could not edit message';

  @override
  String get successAppVersionCopied => 'App version copied';

  @override
  String get successLinkCopied => 'Link copied';

  @override
  String get successMessageTextCopied => 'Message text copied';

  @override
  String get successMessageLinkCopied => 'Message link copied';

  @override
  String get successTopicLinkCopied => 'Topic link copied';

  @override
  String get successChannelLinkCopied => 'Channel link copied';

  @override
  String get composeBoxBannerLabelDeactivatedDmRecipient =>
      'Ne možete slati poruke deaktiviranim korisnicima.';

  @override
  String get composeBoxBannerLabelUnknownDmRecipient =>
      'Ne možete slati poruke nepoznatim korisnicima.';

  @override
  String get composeBoxBannerLabelCannotSendUnspecifiedReason =>
      'Ovdje ne možete slati poruke.';

  @override
  String get composeBoxBannerLabelCannotSendInChannel =>
      'Nemate dopuštenje za pisanje u ovom kanalu.';

  @override
  String get composeBoxBannerLabelUnsubscribed =>
      'Odgovori na vaše poruke neće se pojavljivati automatski.';

  @override
  String get composeBoxBannerLabelUnsubscribedWhenCannotSend =>
      'Nove poruke neće se pojavljivati automatski.';

  @override
  String get composeBoxBannerButtonRefresh => 'Osvježi';

  @override
  String get composeBoxBannerButtonSubscribe => 'Pretplati se';

  @override
  String get composeBoxBannerLabelEditMessage => 'Uređivanje poruke';

  @override
  String get composeBoxBannerButtonCancel => 'Odustani';

  @override
  String get composeBoxBannerButtonSave => 'Spremi';

  @override
  String get editAlreadyInProgressTitle => 'Poruku nije moguće urediti';

  @override
  String get editAlreadyInProgressMessage =>
      'Uređivanje je već u tijeku. Pričekajte da završi.';

  @override
  String get savingMessageEditLabel => 'SPREMANJE IZMJENE…';

  @override
  String get savingMessageEditFailedLabel => 'IZMJENA NIJE SPREMLJENA';

  @override
  String get discardDraftConfirmationDialogTitle =>
      'Odbaciti poruku koju pišete?';

  @override
  String get discardDraftForEditConfirmationDialogMessage =>
      'Kad uređujete poruku, sadržaj koji je bio u polju za poruku se odbacuje.';

  @override
  String get discardDraftForOutboxConfirmationDialogMessage =>
      'Kad vratite neposlanu poruku, sadržaj koji je bio u polju za poruku se odbacuje.';

  @override
  String get discardDraftConfirmationDialogConfirmButton => 'Odbaci';

  @override
  String get composeBoxAttachFilesTooltip => 'Priloži datoteke';

  @override
  String get composeBoxAttachMediaTooltip => 'Priloži slike ili videozapise';

  @override
  String get composeBoxAttachFromCameraTooltip => 'Snimi fotografiju';

  @override
  String get composeBoxGenericContentHint => 'Napišite poruku';

  @override
  String get newDmSheetComposeButtonLabel => 'Napiši';

  @override
  String get newDmSheetScreenTitle => 'Nova poruka';

  @override
  String get newDmFabButtonLabel => 'Nova poruka';

  @override
  String get newDmSheetSearchHintEmpty => 'Dodajte jednog ili više korisnika';

  @override
  String get newDmSheetSearchHintSomeSelected =>
      'Dodajte još jednog korisnika…';

  @override
  String get newDmSheetNoUsersFound => 'Nema pronađenih korisnika';

  @override
  String composeBoxDmContentHint(String user) {
    return 'Poruka za @$user';
  }

  @override
  String get composeBoxGroupDmContentHint => 'Poruka grupi';

  @override
  String get composeBoxSelfDmContentHint => 'Napišite si bilješku';

  @override
  String composeBoxChannelContentHint(String destination) {
    return 'Poruka za $destination';
  }

  @override
  String get preparingEditMessageContentInput => 'Priprema…';

  @override
  String get composeBoxSendTooltip => 'Pošalji';

  @override
  String get unknownChannelName => '(unknown channel)';

  @override
  String get composeBoxTopicHintText => 'Tema';

  @override
  String composeBoxEnterTopicOrSkipHintText(String defaultTopicName) {
    return 'Upišite temu (ili preskočite za „$defaultTopicName”)';
  }

  @override
  String composeBoxUploadingFilename(String filename) {
    return 'Učitavanje $filename…';
  }

  @override
  String composeBoxLoadingMessage(int messageId) {
    return '(učitavanje poruke $messageId)';
  }

  @override
  String get unknownUserName => '(unknown user)';

  @override
  String get dmsWithYourselfPageTitle => 'Poruke sa sobom';

  @override
  String messageListGroupYouAndOthers(String others) {
    return 'You and $others';
  }

  @override
  String dmsWithOthersPageTitle(String others) {
    return 'Poruke s: $others';
  }

  @override
  String get emptyMessageList => 'Ovdje nema poruka.';

  @override
  String get emptyMessageListCombinedFeed => 'U vašem feedu nema poruka.';

  @override
  String get emptyMessageListChannelWithoutContentAccess =>
      'Nemate <z-link>pristup sadržaju</z-link> ovog kanala.';

  @override
  String get emptyMessageListChannelUnavailable =>
      'Ovaj kanal ne postoji ili ga ne smijete vidjeti.';

  @override
  String get emptyMessageListSelfDmHeader =>
      'Još niste sami sebi poslali nijednu poruku!';

  @override
  String get emptyMessageListSelfDmMessage =>
      'Koristite ovaj prostor za osobne bilješke ili za isprobavanje mogućnosti Kloki Chata.';

  @override
  String emptyMessageListDm(String person) {
    return 'Još nemate privatnih poruka s korisnikom $person.';
  }

  @override
  String emptyMessageListDmDeactivatedUser(String person) {
    return 'Nemate privatnih poruka s korisnikom $person.';
  }

  @override
  String get emptyMessageListDmUnknownUser =>
      'Nemate privatnih poruka s ovim korisnikom.';

  @override
  String get emptyMessageListGroupDm =>
      'Još nemate privatnih poruka s ovim korisnicima.';

  @override
  String get emptyMessageListGroupDmDeactivatedUser =>
      'Nemate privatnih poruka s ovim korisnicima.';

  @override
  String get emptyMessageListDmStartConversation =>
      'Zašto ne biste započeli razgovor?';

  @override
  String get emptyMessageListMentionsHeader =>
      'Ovdje će se prikazivati poruke u kojima ste <z-link>spomenuti</z-link>.';

  @override
  String get emptyMessageListMentionsMessage =>
      'Da biste nekome skrenuli pažnju na poruku, možete spomenuti korisnika, grupu, sudionike teme ili sve pretplatnike kanala. Upišite @ u polje za poruku i odaberite koga želite spomenuti s popisa prijedloga.';

  @override
  String get emptyMessageListStarredHeader =>
      'Nemate poruka označenih zvjezdicom.';

  @override
  String emptyMessageListStarredMessage(String button) {
    return '<z-link>Označavanje zvjezdicom</z-link> dobar je način da pratite važne poruke, poput zadataka kojima se trebate vratiti ili korisnih informacija. Da biste označili poruku, dugo je pritisnite i dodirnite „$button”.';
  }

  @override
  String get emptyMessageListSearch => 'Nema rezultata pretrage.';

  @override
  String get messageListGroupYouWithYourself => 'Messages with yourself';

  @override
  String get contentValidationErrorTooLong =>
      'Message length shouldn\'t be greater than 10000 characters.';

  @override
  String get contentValidationErrorEmpty => 'You have nothing to send!';

  @override
  String get contentValidationErrorQuoteAndReplyInProgress =>
      'Please wait for the quotation to complete.';

  @override
  String get contentValidationErrorUploadInProgress =>
      'Please wait for the upload to complete.';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogContinue => 'Continue';

  @override
  String get dialogClose => 'Close';

  @override
  String get errorDialogLearnMore => 'Learn more';

  @override
  String get errorDialogContinue => 'OK';

  @override
  String get errorDialogTitle => 'Error';

  @override
  String get snackBarDetails => 'Details';

  @override
  String get lightboxCopyLinkTooltip => 'Copy link';

  @override
  String get lightboxVideoCurrentPosition => 'Current position';

  @override
  String get lightboxVideoDuration => 'Video duration';

  @override
  String get loginPageTitle => 'Log in';

  @override
  String get loginFormSubmitLabel => 'Log in';

  @override
  String get loginMethodDivider => 'OR';

  @override
  String get loginMethodDividerSemanticLabel => 'Log-in alternatives';

  @override
  String signInWithFoo(String method) {
    return 'Sign in with $method';
  }

  @override
  String get loginAddAnAccountPageTitle => 'Add an account';

  @override
  String get loginRealmUrlLabel => 'Your organization URL';

  @override
  String get loginRealmUrlHelperText =>
      'This is the address you would use to open the chat in a browser.';

  @override
  String get loginRealmUrlHelpButton => 'Help';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginErrorMissingEmail => 'Please enter your email.';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginErrorMissingPassword => 'Please enter your password.';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginErrorMissingUsername => 'Please enter your username.';

  @override
  String topicValidationErrorTooLong(int maxLength) {
    String _temp0 = intl.Intl.pluralLogic(
      maxLength,
      locale: localeName,
      other: '$maxLength characters',
      one: '1 character',
    );
    return 'Topic length shouldn\'t be greater than $_temp0.';
  }

  @override
  String get topicValidationErrorMandatoryButEmpty =>
      'Topics are required in this channel.';

  @override
  String get errorContentNotInsertedTitle => 'Content not inserted';

  @override
  String get errorContentToInsertIsEmpty =>
      'The file to be inserted is empty or cannot be accessed.';

  @override
  String errorServerVersionNotAllowedMessage(
    String url,
    String zulipVersion,
    String minAllowedZulipVersion,
  ) {
    return '$url is running Zulip Server $zulipVersion, which is unsupported. The minimum supported version is Zulip Server $minAllowedZulipVersion.';
  }

  @override
  String serverCompatBannerAdminMessage(String url, String zulipVersion) {
    return '$url is running Zulip Server $zulipVersion, which is unsupported. Please upgrade your server as soon as possible.';
  }

  @override
  String serverCompatBannerUserMessage(String url, String zulipVersion) {
    return '$url is running Zulip Server $zulipVersion, which is unsupported. Please contact your server administrator about upgrading.';
  }

  @override
  String get serverCompatBannerDismissLabel => 'Dismiss';

  @override
  String get serverCompatBannerLearnMoreLabel => 'Learn more';

  @override
  String errorInvalidApiKeyMessage(String url) {
    return 'Your account at $url could not be authenticated. Please try logging in again or use another account.';
  }

  @override
  String get errorInvalidResponse => 'The server sent an invalid response.';

  @override
  String get errorNetworkRequestFailed => 'Network request failed';

  @override
  String errorMalformedResponse(int httpStatus) {
    return 'Server gave malformed response; HTTP status $httpStatus';
  }

  @override
  String errorMalformedResponseWithCause(int httpStatus, String details) {
    return 'Server gave malformed response; HTTP status $httpStatus; $details';
  }

  @override
  String errorRequestFailed(int httpStatus) {
    return 'Network request failed: HTTP status $httpStatus';
  }

  @override
  String get errorVideoPlayerFailed => 'Unable to play the video.';

  @override
  String get errorVideoPlayerFailedTryBrowser =>
      'Try opening it in your browser instead.';

  @override
  String get dialogOpenInBrowser => 'Open in browser';

  @override
  String get serverUrlValidationErrorEmpty => 'Please enter a URL.';

  @override
  String get serverUrlValidationErrorInvalidUrl => 'Please enter a valid URL.';

  @override
  String get serverUrlValidationErrorNoUseEmail =>
      'Please enter the server URL, not your email.';

  @override
  String get serverUrlValidationErrorUnsupportedScheme =>
      'The server URL must start with http:// or https://.';

  @override
  String get spoilerDefaultHeaderText => 'Spoiler';

  @override
  String get markAllAsReadLabel => 'Mark all messages as read';

  @override
  String markAsReadComplete(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num messages',
      one: '1 message',
    );
    return 'Marked $_temp0 as read.';
  }

  @override
  String get markAsReadInProgress => 'Marking messages as read…';

  @override
  String get errorMarkAsReadFailedTitle => 'Mark as read failed';

  @override
  String markAsUnreadComplete(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num messages',
      one: '1 message',
    );
    return 'Marked $_temp0 as unread.';
  }

  @override
  String get markAsUnreadInProgress => 'Marking messages as unread…';

  @override
  String get errorMarkAsUnreadFailedTitle => 'Mark as unread failed';

  @override
  String markAllAsReadConfirmationDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mark $count+ messages as read?',
      one: 'Mark $count+ messages as read?',
    );
    return '$_temp0';
  }

  @override
  String get markAllAsReadConfirmationDialogTitleNoCount =>
      'Mark messages as read?';

  @override
  String get markAllAsReadConfirmationDialogMessage =>
      'Messages in multiple conversations may be affected.';

  @override
  String get markAllAsReadConfirmationDialogConfirmButton => 'Mark as read';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get userActiveNow => 'Active now';

  @override
  String get userIdle => 'Idle';

  @override
  String userActiveMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Active $_temp0 ago';
  }

  @override
  String userActiveHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return 'Active $_temp0 ago';
  }

  @override
  String get userActiveYesterday => 'Active yesterday';

  @override
  String userActiveDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Active $_temp0 ago';
  }

  @override
  String userActiveDate(String date) {
    return 'Active $date';
  }

  @override
  String get userNotActiveInYear => 'Not active in the last year';

  @override
  String get invisibleMode => 'Invisible mode';

  @override
  String get turnOnInvisibleModeErrorTitle =>
      'Error turning on invisible mode. Please try again.';

  @override
  String get turnOffInvisibleModeErrorTitle =>
      'Error turning off invisible mode. Please try again.';

  @override
  String get userRoleOwner => 'Owner';

  @override
  String get userRoleAdministrator => 'Administrator';

  @override
  String get userRoleModerator => 'Moderator';

  @override
  String get userRoleMember => 'Member';

  @override
  String get userRoleGuest => 'Guest';

  @override
  String get userRoleUnknown => 'Unknown';

  @override
  String get statusButtonLabelStatusSet => 'Status';

  @override
  String get statusButtonLabelStatusUnset => 'Set status';

  @override
  String get noStatusText => 'No status text';

  @override
  String get setStatusPageTitle => 'Set status';

  @override
  String get statusClearButtonLabel => 'Clear';

  @override
  String get statusSaveButtonLabel => 'Save';

  @override
  String get statusTextHint => 'Your status';

  @override
  String get userStatusBusy => 'Busy';

  @override
  String get userStatusInAMeeting => 'In a meeting';

  @override
  String get userStatusCommuting => 'Commuting';

  @override
  String get userStatusOutSick => 'Out sick';

  @override
  String get userStatusVacationing => 'Vacationing';

  @override
  String get userStatusWorkingRemotely => 'Working remotely';

  @override
  String get userStatusAtTheOffice => 'At the office';

  @override
  String get updateStatusErrorTitle =>
      'Error updating user status. Please try again.';

  @override
  String get searchMessagesPageTitle => 'Pretraga';

  @override
  String get searchMessagesHintText => 'Pretraži';

  @override
  String get searchMessagesClearButtonTooltip => 'Očisti';

  @override
  String get inboxPageTitle => 'Inbox';

  @override
  String get inboxEmptyPlaceholderHeader =>
      'U vašem inboxu nema nepročitanih poruka.';

  @override
  String get inboxEmptyPlaceholderMessage =>
      'Koristite gumbe ispod za prikaz feeda ili popisa kanala.';

  @override
  String get pinnedChannelsFolderName => 'Prikvačeni kanali';

  @override
  String get otherChannelsFolderName => 'Other channels';

  @override
  String get recentDmConversationsPageTitle => 'Privatne poruke';

  @override
  String get recentDmConversationsPageShortLabel => 'Poruke';

  @override
  String get recentDmConversationsSectionHeader => 'Privatne poruke';

  @override
  String get recentDmConversationsEmptyPlaceholderHeader =>
      'Još nemate privatnih poruka!';

  @override
  String get recentDmConversationsEmptyPlaceholderMessage =>
      'Zašto ne biste započeli razgovor?';

  @override
  String get combinedFeedPageTitle => 'Feed';

  @override
  String get mentionsPageTitle => 'Spominjanja';

  @override
  String get starredMessagesPageTitle => 'Poruke sa zvjezdicom';

  @override
  String get channelsPageTitle => 'Kanali';

  @override
  String get channelsEmptyPlaceholderHeader =>
      'Još niste pretplaćeni ni na jedan kanal.';

  @override
  String channelsEmptyPlaceholderMessage(String allChannelsPageTitle) {
    return 'Otvorite <z-link>$allChannelsPageTitle</z-link> i pridružite se nekima od njih.';
  }

  @override
  String get shareChooseAccountModalTitle => 'Choose an account';

  @override
  String get mainMenuMyProfile => 'Moj profil';

  @override
  String get topicsButtonTooltip => 'Teme';

  @override
  String get channelFeedButtonTooltip => 'Feed kanala';

  @override
  String notifGroupDmConversationLabel(String senderFullName, int numOthers) {
    String _temp0 = intl.Intl.pluralLogic(
      numOthers,
      locale: localeName,
      other: '$numOthers others',
      one: '1 other',
    );
    return '$senderFullName to you and $_temp0';
  }

  @override
  String get pinnedSubscriptionsLabel => 'Prikvačeni';

  @override
  String get unpinnedSubscriptionsLabel => 'Ostali';

  @override
  String get notifSelfUser => 'You';

  @override
  String get reactedEmojiSelfUser => 'You';

  @override
  String get reactionChipsLabel => 'Reactions';

  @override
  String reactionChipLabel(String emojiName, String votes) {
    return '$emojiName: $votes';
  }

  @override
  String reactionChipVotesYouAndOthers(int otherUsersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      otherUsersCount,
      locale: localeName,
      other: 'You and $otherUsersCount others',
      one: 'You and 1 other',
    );
    return '$_temp0';
  }

  @override
  String onePersonTyping(String typist) {
    return '$typist is typing…';
  }

  @override
  String twoPeopleTyping(String typist, String otherTypist) {
    return '$typist and $otherTypist are typing…';
  }

  @override
  String get manyPeopleTyping => 'Several people are typing…';

  @override
  String get wildcardMentionAll => 'all';

  @override
  String get wildcardMentionEveryone => 'everyone';

  @override
  String get wildcardMentionChannel => 'channel';

  @override
  String get wildcardMentionStream => 'stream';

  @override
  String get wildcardMentionTopic => 'topic';

  @override
  String get wildcardMentionChannelDescription => 'Notify channel';

  @override
  String get wildcardMentionStreamDescription => 'Notify stream';

  @override
  String get wildcardMentionAllDmDescription => 'Notify recipients';

  @override
  String get wildcardMentionTopicDescription => 'Notify topic';

  @override
  String get systemGroupNameEveryoneOnInternet => 'Everyone on the internet';

  @override
  String get systemGroupNameEveryone => 'Everyone including guests';

  @override
  String get systemGroupNameMembers => 'Everyone except guests';

  @override
  String get systemGroupNameFullMembers => 'Full members';

  @override
  String get systemGroupNameModerators => 'Moderators';

  @override
  String get systemGroupNameAdministrators => 'Administrators';

  @override
  String get systemGroupNameOwners => 'Owners';

  @override
  String get systemGroupNameNobody => 'Nobody';

  @override
  String get navBarFeedLabel => 'Feed';

  @override
  String get navBarMenuLabel => 'Izbornik';

  @override
  String get messageIsEditedLabel => 'EDITED';

  @override
  String get messageIsMovedLabel => 'MOVED';

  @override
  String get messageNotSentLabel => 'MESSAGE NOT SENT';

  @override
  String pollVoterNames(String voterNames) {
    return '($voterNames)';
  }

  @override
  String get themeSettingTitle => 'THEME';

  @override
  String get themeSettingDark => 'Dark';

  @override
  String get themeSettingLight => 'Light';

  @override
  String get themeSettingSystem => 'System';

  @override
  String get openLinksWithInAppBrowser => 'Open links with in-app browser';

  @override
  String get pollWidgetQuestionMissing => 'No question.';

  @override
  String get pollWidgetOptionsMissing => 'This poll has no options yet.';

  @override
  String get initialAnchorSettingTitle => 'Open message feeds at';

  @override
  String get initialAnchorSettingDescription =>
      'You can choose whether message feeds open at your first unread message or at the newest messages.';

  @override
  String get initialAnchorSettingFirstUnreadAlways => 'First unread message';

  @override
  String get initialAnchorSettingFirstUnreadConversations =>
      'First unread message in conversation views, newest message elsewhere';

  @override
  String get initialAnchorSettingNewestAlways => 'Newest message';

  @override
  String get markReadOnScrollSettingTitle => 'Mark messages as read on scroll';

  @override
  String get markReadOnScrollSettingDescription =>
      'When scrolling through messages, should they automatically be marked as read?';

  @override
  String get markReadOnScrollSettingAlways => 'Always';

  @override
  String get markReadOnScrollSettingNever => 'Never';

  @override
  String get markReadOnScrollSettingConversations =>
      'Only in conversation views';

  @override
  String get markReadOnScrollSettingConversationsDescription =>
      'Messages will be automatically marked as read only when viewing a single topic or direct message conversation.';

  @override
  String get experimentalFeatureSettingsPageTitle => 'Experimental features';

  @override
  String get experimentalFeatureSettingsWarning =>
      'These options enable features which are still under development and not ready. They may not work, and may cause issues in other areas of the app.\n\nThe purpose of these settings is for experimentation by people working on developing Zulip.';

  @override
  String get errorNotificationOpenTitle => 'Failed to open notification';

  @override
  String get errorNotificationOpenAccountNotFound =>
      'The account associated with this notification could not be found.';

  @override
  String get errorReactionAddingFailedTitle => 'Adding reaction failed';

  @override
  String get errorReactionRemovingFailedTitle => 'Removing reaction failed';

  @override
  String get errorSharingTitle => 'Failed to share content';

  @override
  String get errorSharingAccountNotLoggedIn =>
      'There is no account logged in. Please log in to an account and try again.';

  @override
  String get emojiReactionsMore => 'more';

  @override
  String get emojiPickerSearchEmoji => 'Search emoji';

  @override
  String get noEarlierMessages => 'No earlier messages';

  @override
  String get revealButtonLabel => 'Reveal message';

  @override
  String get mutedUser => 'Muted user';

  @override
  String get scrollToBottomTooltip => 'Scroll to bottom';

  @override
  String get zulipAppTitle => 'Kloki Chat';

  @override
  String get topicListEmptyPlaceholderHeader => 'There are no topics here yet.';

  @override
  String get klokiSignInTitle => 'Prijava u chat ide kroz Kloki';

  @override
  String get klokiSignInDescription =>
      'Prijavite se istom prijavom kao u Kloki. Računi u chatu dolaze iz Klokija i nemaju vlastitu lozinku.';

  @override
  String get klokiSignInButton => 'Prijavi se kroz Kloki';

  @override
  String get klokiGuestSignIn => 'Prijava za goste';

  @override
  String get klokiGuestSignInDescription =>
      'Za goste koje je tvrtka pozvala u svoj chat. Svi s računom u Klokiju prijavljuju se kroz Kloki.';

  @override
  String get klokiBackToKlokiSignIn => 'Natrag na prijavu kroz Kloki';

  @override
  String get klokiOtherServer => 'Prijava na drugi server';

  @override
  String get klokiWelcomeTitle => 'Chat cijelog tima';

  @override
  String get klokiWelcomeDescription =>
      'Kanali, privatne poruke i grupe za cijeli tim. Prijavite se svojim Kloki računom, bez posebne lozinke.';
}
