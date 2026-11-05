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
  String get aboutPageReleaseNotes => 'Bilješke o izdanju';

  @override
  String get aboutPageOpenSourceLicenses => 'Licence otvorenog koda';

  @override
  String get chooseAccountPageTitle => 'Odaberite račun';

  @override
  String get settingsPageTitle => 'Postavke';

  @override
  String get switchAccountButtonTooltip => 'Promijeni račun';

  @override
  String tryAnotherAccountMessage(Object url) {
    return 'Vaš račun na $url se dugo učitava.';
  }

  @override
  String get tryAnotherAccountButton => 'Pokušaj s drugim računom';

  @override
  String get chooseAccountPageLogOutButton => 'Odjava';

  @override
  String get logOutConfirmationDialogTitle => 'Odjaviti se?';

  @override
  String get logOutConfirmationDialogMessage =>
      'Da biste ubuduće koristili ovaj račun, morat ćete ponovno upisati adresu organizacije i podatke računa.';

  @override
  String get logOutConfirmationDialogConfirmButton => 'Odjava';

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
  String get profileButtonSendDirectMessage => 'Pošalji privatnu poruku';

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
  String get actionSheetOptionSubscribe => 'Pretplati se';

  @override
  String get subscribeFailedTitle => 'Failed to subscribe';

  @override
  String get actionSheetOptionMarkChannelAsRead => 'Označi kanal kao pročitan';

  @override
  String get actionSheetOptionCopyChannelLink => 'Kopiraj poveznicu na kanal';

  @override
  String get actionSheetOptionListOfTopics => 'Popis tema';

  @override
  String get actionSheetOptionChannelFeed => 'Feed kanala';

  @override
  String get actionSheetOptionUnsubscribe => 'Otkaži pretplatu';

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
  String get actionSheetOptionPinChannel => 'Prikvači na vrh';

  @override
  String get actionSheetOptionUnpinChannel => 'Otkvači s vrha';

  @override
  String get errorPinChannelFailedTitle => 'Failed to pin channel';

  @override
  String get errorUnpinChannelFailedTitle => 'Failed to unpin channel';

  @override
  String get actionSheetOptionMuteTopic => 'Utišaj temu';

  @override
  String get actionSheetOptionUnmuteTopic => 'Uključi zvuk teme';

  @override
  String get actionSheetOptionFollowTopic => 'Prati temu';

  @override
  String get actionSheetOptionUnfollowTopic => 'Prestani pratiti temu';

  @override
  String get actionSheetOptionResolveTopic => 'Označi kao riješeno';

  @override
  String get actionSheetOptionUnresolveTopic => 'Označi kao neriješeno';

  @override
  String get errorResolveTopicFailedTitle => 'Failed to mark topic as resolved';

  @override
  String get errorUnresolveTopicFailedTitle =>
      'Failed to mark topic as unresolved';

  @override
  String get actionSheetOptionSeeWhoReacted => 'Tko je reagirao';

  @override
  String get seeWhoReactedSheetNoReactions => 'Ova poruka nema reakcija.';

  @override
  String seeWhoReactedSheetHeaderLabel(int num) {
    return 'Emoji reakcije (ukupno $num)';
  }

  @override
  String seeWhoReactedSheetEmojiNameWithVoteCount(String emojiName, int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num glasova',
      few: '$num glasa',
      one: '$num glas',
    );
    return '$emojiName: $_temp0';
  }

  @override
  String seeWhoReactedSheetUserListLabel(String emojiName, int num) {
    return 'Glasovi za $emojiName ($num)';
  }

  @override
  String get actionSheetOptionViewReadReceipts => 'Tko je pročitao';

  @override
  String get actionSheetReadReceipts => 'Potvrde čitanja';

  @override
  String actionSheetReadReceiptsReadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ovu poruku je <z-link>pročitalo</z-link> $count osoba:',
      few: 'Ovu poruku su <z-link>pročitale</z-link> $count osobe:',
      one: 'Ovu poruku je <z-link>pročitala</z-link> $count osoba:',
    );
    return '$_temp0';
  }

  @override
  String get actionSheetReadReceiptsZeroReadCount =>
      'Ovu poruku još nitko nije pročitao.';

  @override
  String get actionSheetReadReceiptsErrorReadCount =>
      'Učitavanje potvrda čitanja nije uspjelo.';

  @override
  String get actionSheetOptionCopyMessageText => 'Kopiraj tekst poruke';

  @override
  String get actionSheetOptionCopyMessageLink => 'Kopiraj poveznicu na poruku';

  @override
  String get actionSheetOptionMarkAsUnread => 'Označi kao nepročitano odavde';

  @override
  String get actionSheetOptionHideMutedMessage =>
      'Ponovno sakrij utišanu poruku';

  @override
  String get actionSheetOptionHideLinkPreviews => 'Sakrij preglede poveznica';

  @override
  String get actionSheetOptionShowLinkPreviews => 'Prikaži preglede poveznica';

  @override
  String get actionSheetOptionShare => 'Podijeli';

  @override
  String get actionSheetOptionQuoteMessage => 'Citiraj poruku';

  @override
  String get actionSheetOptionStarMessage => 'Označi zvjezdicom';

  @override
  String get actionSheetOptionUnstarMessage => 'Ukloni zvjezdicu';

  @override
  String get actionSheetOptionEditMessage => 'Uredi poruku';

  @override
  String get actionSheetOptionDeleteMessage => 'Izbriši poruku';

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
  String get actionSheetOptionReportMessage => 'Prijavi poruku';

  @override
  String get reportMessageDialogTitle => 'Report message';

  @override
  String get reportMessageDescription =>
      'Your report will be sent to the private moderation requests channel for this organization.';

  @override
  String get messageReportTypeSpam => 'Spam';

  @override
  String get messageReportTypeHarassment => 'Uznemiravanje';

  @override
  String get messageReportTypeInappropriate => 'Neprikladan sadržaj';

  @override
  String get messageReportTypeNorms => 'Krši pravila zajednice';

  @override
  String get messageReportTypeOther => 'Drugi razlog';

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
  String get actionSheetOptionMarkTopicAsRead => 'Označi temu kao pročitanu';

  @override
  String get actionSheetOptionCopyTopicLink => 'Kopiraj poveznicu na temu';

  @override
  String actionSheetTitleDm(String user) {
    return 'Poruke s: $user';
  }

  @override
  String get actionSheetTitleSelfDm => 'Poruke sa sobom';

  @override
  String get actionSheetTitleGroupDm => 'Grupne poruke';

  @override
  String get actionSheetOptionViewProfile => 'Prikaži profil';

  @override
  String get actionSheetOptionMarkDmConversationAsRead =>
      'Označi razgovor kao pročitan';

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
  String get successAppVersionCopied => 'Verzija aplikacije kopirana';

  @override
  String get successLinkCopied => 'Poveznica kopirana';

  @override
  String get successMessageTextCopied => 'Tekst poruke kopiran';

  @override
  String get successMessageLinkCopied => 'Poveznica na poruku kopirana';

  @override
  String get successTopicLinkCopied => 'Poveznica na temu kopirana';

  @override
  String get successChannelLinkCopied => 'Poveznica na kanal kopirana';

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
  String get unknownChannelName => '(nepoznat kanal)';

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
  String get unknownUserName => '(nepoznat korisnik)';

  @override
  String get dmsWithYourselfPageTitle => 'Poruke sa sobom';

  @override
  String messageListGroupYouAndOthers(String others) {
    return 'Vi i $others';
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
  String get messageListGroupYouWithYourself => 'Poruke sa sobom';

  @override
  String get contentValidationErrorTooLong =>
      'Poruka ne smije biti dulja od 10000 znakova.';

  @override
  String get contentValidationErrorEmpty => 'Nemate što poslati!';

  @override
  String get contentValidationErrorQuoteAndReplyInProgress =>
      'Pričekajte da se citat učita.';

  @override
  String get contentValidationErrorUploadInProgress =>
      'Pričekajte da se učitavanje završi.';

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
  String get snackBarDetails => 'Detalji';

  @override
  String get lightboxCopyLinkTooltip => 'Kopiraj poveznicu';

  @override
  String get lightboxVideoCurrentPosition => 'Trenutni položaj';

  @override
  String get lightboxVideoDuration => 'Trajanje videozapisa';

  @override
  String get loginPageTitle => 'Prijava';

  @override
  String get loginFormSubmitLabel => 'Prijavi se';

  @override
  String get loginMethodDivider => 'ILI';

  @override
  String get loginMethodDividerSemanticLabel => 'Drugi načini prijave';

  @override
  String signInWithFoo(String method) {
    return 'Prijava putem: $method';
  }

  @override
  String get loginAddAnAccountPageTitle => 'Dodaj račun';

  @override
  String get loginRealmUrlLabel => 'Adresa vaše organizacije';

  @override
  String get loginRealmUrlHelperText =>
      'To je adresa na kojoj biste chat otvorili u pregledniku.';

  @override
  String get loginRealmUrlHelpButton => 'Pomoć';

  @override
  String get loginHidePassword => 'Sakrij lozinku';

  @override
  String get loginEmailLabel => 'E-mail adresa';

  @override
  String get loginErrorMissingEmail => 'Upišite svoj e-mail.';

  @override
  String get loginPasswordLabel => 'Lozinka';

  @override
  String get loginErrorMissingPassword => 'Upišite svoju lozinku.';

  @override
  String get loginUsernameLabel => 'Korisničko ime';

  @override
  String get loginErrorMissingUsername => 'Upišite svoje korisničko ime.';

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
    return '$url koristi Zulip Server $zulipVersion, koji više nije podržan. Nadogradite server što prije.';
  }

  @override
  String serverCompatBannerUserMessage(String url, String zulipVersion) {
    return '$url koristi Zulip Server $zulipVersion, koji više nije podržan. Javite se administratoru servera zbog nadogradnje.';
  }

  @override
  String get serverCompatBannerDismissLabel => 'Zatvori';

  @override
  String get serverCompatBannerLearnMoreLabel => 'Saznaj više';

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
  String get serverUrlValidationErrorEmpty => 'Upišite adresu.';

  @override
  String get serverUrlValidationErrorInvalidUrl => 'Upišite ispravnu adresu.';

  @override
  String get serverUrlValidationErrorNoUseEmail =>
      'Upišite adresu servera, a ne svoj e-mail.';

  @override
  String get serverUrlValidationErrorUnsupportedScheme =>
      'Adresa servera mora počinjati s http:// ili https://.';

  @override
  String get spoilerDefaultHeaderText => 'Spoiler';

  @override
  String get markAllAsReadLabel => 'Označi sve poruke kao pročitane';

  @override
  String markAsReadComplete(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num poruka označeno je kao pročitano.',
      few: '$num poruke označene su kao pročitane.',
      one: '$num poruka označena je kao pročitana.',
    );
    return '$_temp0';
  }

  @override
  String get markAsReadInProgress => 'Označavanje poruka kao pročitanih…';

  @override
  String get errorMarkAsReadFailedTitle => 'Mark as read failed';

  @override
  String markAsUnreadComplete(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: '$num poruka označeno je kao nepročitano.',
      few: '$num poruke označene su kao nepročitane.',
      one: '$num poruka označena je kao nepročitana.',
    );
    return '$_temp0';
  }

  @override
  String get markAsUnreadInProgress => 'Označavanje poruka kao nepročitanih…';

  @override
  String get errorMarkAsUnreadFailedTitle => 'Mark as unread failed';

  @override
  String markAllAsReadConfirmationDialogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Označiti $count+ poruka kao pročitane?',
      few: 'Označiti $count+ poruke kao pročitane?',
      one: 'Označiti $count+ poruku kao pročitanu?',
    );
    return '$_temp0';
  }

  @override
  String get markAllAsReadConfirmationDialogTitleNoCount =>
      'Označiti poruke kao pročitane?';

  @override
  String get markAllAsReadConfirmationDialogMessage =>
      'To može obuhvatiti poruke u više razgovora.';

  @override
  String get markAllAsReadConfirmationDialogConfirmButton =>
      'Označi kao pročitano';

  @override
  String get today => 'Danas';

  @override
  String get yesterday => 'Jučer';

  @override
  String get userActiveNow => 'Trenutno aktivan';

  @override
  String get userIdle => 'Neaktivan';

  @override
  String userActiveMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minuta',
      few: '$minutes minute',
      one: '$minutes minutu',
    );
    return 'Aktivan prije $_temp0';
  }

  @override
  String userActiveHoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours sati',
      few: '$hours sata',
      one: '$hours sat',
    );
    return 'Aktivan prije $_temp0';
  }

  @override
  String get userActiveYesterday => 'Aktivan jučer';

  @override
  String userActiveDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dana',
      few: '$days dana',
      one: '$days dan',
    );
    return 'Aktivan prije $_temp0';
  }

  @override
  String userActiveDate(String date) {
    return 'Aktivan $date';
  }

  @override
  String get userNotActiveInYear => 'Nije aktivan u posljednjih godinu dana';

  @override
  String get invisibleMode => 'Nevidljivi način';

  @override
  String get turnOnInvisibleModeErrorTitle =>
      'Uključivanje nevidljivog načina nije uspjelo. Pokušajte ponovno.';

  @override
  String get turnOffInvisibleModeErrorTitle =>
      'Isključivanje nevidljivog načina nije uspjelo. Pokušajte ponovno.';

  @override
  String get userRoleOwner => 'Vlasnik';

  @override
  String get userRoleAdministrator => 'Administrator';

  @override
  String get userRoleModerator => 'Moderator';

  @override
  String get userRoleMember => 'Član';

  @override
  String get userRoleGuest => 'Gost';

  @override
  String get userRoleUnknown => 'Nepoznato';

  @override
  String get statusButtonLabelStatusSet => 'Status';

  @override
  String get statusButtonLabelStatusUnset => 'Postavi status';

  @override
  String get noStatusText => 'Nema teksta statusa';

  @override
  String get setStatusPageTitle => 'Postavi status';

  @override
  String get statusClearButtonLabel => 'Očisti';

  @override
  String get statusSaveButtonLabel => 'Spremi';

  @override
  String get statusTextHint => 'Vaš status';

  @override
  String get userStatusBusy => 'Zauzet';

  @override
  String get userStatusInAMeeting => 'Na sastanku';

  @override
  String get userStatusCommuting => 'Na putu';

  @override
  String get userStatusOutSick => 'Na bolovanju';

  @override
  String get userStatusVacationing => 'Na godišnjem';

  @override
  String get userStatusWorkingRemotely => 'Radim od kuće';

  @override
  String get userStatusAtTheOffice => 'U uredu';

  @override
  String get updateStatusErrorTitle =>
      'Ažuriranje statusa nije uspjelo. Pokušajte ponovno.';

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
  String get otherChannelsFolderName => 'Ostali kanali';

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
  String get shareChooseAccountModalTitle => 'Odaberite račun';

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
      other: 'još $numOthers osoba',
      few: 'još $numOthers osobe',
      one: 'još $numOthers osobi',
    );
    return '$senderFullName vama i $_temp0';
  }

  @override
  String get pinnedSubscriptionsLabel => 'Prikvačeni';

  @override
  String get unpinnedSubscriptionsLabel => 'Ostali';

  @override
  String get notifSelfUser => 'Vi';

  @override
  String get reactedEmojiSelfUser => 'Vi';

  @override
  String get reactionChipsLabel => 'Reakcije';

  @override
  String reactionChipLabel(String emojiName, String votes) {
    return '$emojiName: $votes';
  }

  @override
  String reactionChipVotesYouAndOthers(int otherUsersCount) {
    String _temp0 = intl.Intl.pluralLogic(
      otherUsersCount,
      locale: localeName,
      other: 'Vi i još $otherUsersCount osoba',
      few: 'Vi i još $otherUsersCount osobe',
      one: 'Vi i još $otherUsersCount osoba',
    );
    return '$_temp0';
  }

  @override
  String onePersonTyping(String typist) {
    return '$typist piše…';
  }

  @override
  String twoPeopleTyping(String typist, String otherTypist) {
    return '$typist i $otherTypist pišu…';
  }

  @override
  String get manyPeopleTyping => 'Nekoliko osoba piše…';

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
  String get wildcardMentionChannelDescription => 'Obavijesti kanal';

  @override
  String get wildcardMentionStreamDescription => 'Obavijesti kanal';

  @override
  String get wildcardMentionAllDmDescription => 'Obavijesti primatelje';

  @override
  String get wildcardMentionTopicDescription => 'Obavijesti temu';

  @override
  String get systemGroupNameEveryoneOnInternet => 'Svi na internetu';

  @override
  String get systemGroupNameEveryone => 'Svi, uključujući goste';

  @override
  String get systemGroupNameMembers => 'Svi osim gostiju';

  @override
  String get systemGroupNameFullMembers => 'Punopravni članovi';

  @override
  String get systemGroupNameModerators => 'Moderatori';

  @override
  String get systemGroupNameAdministrators => 'Administratori';

  @override
  String get systemGroupNameOwners => 'Vlasnici';

  @override
  String get systemGroupNameNobody => 'Nitko';

  @override
  String get navBarFeedLabel => 'Feed';

  @override
  String get navBarMenuLabel => 'Izbornik';

  @override
  String get messageIsEditedLabel => 'UREĐENO';

  @override
  String get messageIsMovedLabel => 'PREMJEŠTENO';

  @override
  String get messageNotSentLabel => 'PORUKA NIJE POSLANA';

  @override
  String pollVoterNames(String voterNames) {
    return '($voterNames)';
  }

  @override
  String get themeSettingTitle => 'TEMA';

  @override
  String get themeSettingDark => 'Tamna';

  @override
  String get themeSettingLight => 'Svijetla';

  @override
  String get themeSettingSystem => 'Sustavna';

  @override
  String get openLinksWithInAppBrowser =>
      'Otvaraj poveznice u pregledniku aplikacije';

  @override
  String get pollWidgetQuestionMissing => 'Nema pitanja.';

  @override
  String get pollWidgetOptionsMissing => 'Ova anketa još nema odgovora.';

  @override
  String get initialAnchorSettingTitle => 'Otvaraj feedove poruka na';

  @override
  String get initialAnchorSettingDescription =>
      'Možete odabrati otvaraju li se feedovi poruka na prvoj nepročitanoj ili na najnovijim porukama.';

  @override
  String get initialAnchorSettingFirstUnreadAlways =>
      'Prvoj nepročitanoj poruci';

  @override
  String get initialAnchorSettingFirstUnreadConversations =>
      'Prvoj nepročitanoj u razgovorima, inače na najnovijoj';

  @override
  String get initialAnchorSettingNewestAlways => 'Najnovijoj poruci';

  @override
  String get markReadOnScrollSettingTitle =>
      'Označi poruke kao pročitane pri pomicanju';

  @override
  String get markReadOnScrollSettingDescription =>
      'Trebaju li se poruke automatski označiti kao pročitane dok ih pomičete?';

  @override
  String get markReadOnScrollSettingAlways => 'Uvijek';

  @override
  String get markReadOnScrollSettingNever => 'Nikad';

  @override
  String get markReadOnScrollSettingConversations => 'Samo u prikazu razgovora';

  @override
  String get markReadOnScrollSettingConversationsDescription =>
      'Poruke će se automatski označiti kao pročitane samo kad gledate jednu temu ili privatni razgovor.';

  @override
  String get experimentalFeatureSettingsPageTitle => 'Eksperimentalne značajke';

  @override
  String get experimentalFeatureSettingsWarning =>
      'Ove opcije uključuju značajke koje su još u razvoju i nisu spremne. Možda neće raditi i mogu uzrokovati probleme u drugim dijelovima aplikacije.\n\nOve postavke služe za isprobavanje onima koji razvijaju aplikaciju.';

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
  String get emojiReactionsMore => 'više';

  @override
  String get emojiPickerSearchEmoji => 'Pretraži emojije';

  @override
  String get noEarlierMessages => 'Nema ranijih poruka';

  @override
  String get revealButtonLabel => 'Prikaži poruku';

  @override
  String get mutedUser => 'Utišani korisnik';

  @override
  String get scrollToBottomTooltip => 'Pomakni na dno';

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
