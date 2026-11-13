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
  String get errorCouldNotShowUserProfile =>
      'Profil korisnika nije moguće prikazati.';

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
  String get subscribeFailedTitle => 'Pretplata nije uspjela';

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
    return 'Otkazati pretplatu na $channelName?';
  }

  @override
  String get unsubscribeConfirmationDialogMessageCannotResubscribe =>
      'Kad napustite ovaj kanal, nećete mu se moći ponovno pridružiti.';

  @override
  String get unsubscribeConfirmationDialogConfirmButton => 'Otkaži pretplatu';

  @override
  String get unsubscribeFailedTitle => 'Otkazivanje pretplate nije uspjelo';

  @override
  String get actionSheetOptionPinChannel => 'Prikvači na vrh';

  @override
  String get actionSheetOptionUnpinChannel => 'Otkvači s vrha';

  @override
  String get errorPinChannelFailedTitle => 'Prikvačivanje kanala nije uspjelo';

  @override
  String get errorUnpinChannelFailedTitle => 'Otkvačivanje kanala nije uspjelo';

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
  String get errorResolveTopicFailedTitle =>
      'Označavanje teme kao riješene nije uspjelo';

  @override
  String get errorUnresolveTopicFailedTitle =>
      'Označavanje teme kao neriješene nije uspjelo';

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
  String get deleteMessageConfirmationDialogTitle => 'Izbrisati poruku?';

  @override
  String get deleteMessageConfirmationDialogMessage =>
      'Brisanjem se poruka trajno uklanja za sve.';

  @override
  String get deleteMessageConfirmationDialogConfirmButton => 'Izbriši';

  @override
  String get errorDeleteMessageFailedTitle => 'Brisanje poruke nije uspjelo';

  @override
  String get actionSheetOptionReportMessage => 'Prijavi poruku';

  @override
  String get reportMessageDialogTitle => 'Prijavi poruku';

  @override
  String get reportMessageDescription =>
      'Vaša prijava bit će poslana u privatni kanal za moderaciju ove organizacije.';

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
  String get reportMessageReasonLabel => 'Što nije u redu s ovom porukom?';

  @override
  String get reportMessageDescriptionLabel => 'Možete li navesti više detalja?';

  @override
  String get reportMessageDescriptionRequired => 'Navedite detalje.';

  @override
  String get reportMessageSubmitButton => 'Pošalji';

  @override
  String get reportMessageSuccess => 'Poruka je prijavljena';

  @override
  String get errorReportMessageFailedTitle => 'Prijava poruke nije uspjela';

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
  String get errorWebAuthOperationalErrorTitle => 'Nešto je pošlo po zlu';

  @override
  String get errorWebAuthOperationalError =>
      'Došlo je do neočekivane pogreške.';

  @override
  String get errorAccountLoggedInTitle => 'Račun je već prijavljen';

  @override
  String errorAccountLoggedIn(String email, String server) {
    return 'Račun $email na $server već je na vašem popisu računa.';
  }

  @override
  String get errorCouldNotFetchMessageSource =>
      'Izvor poruke nije moguće dohvatiti.';

  @override
  String get errorCouldNotAccessUploadedFileTitle =>
      'Učitanoj datoteci nije moguće pristupiti';

  @override
  String get errorCopyingFailed => 'Kopiranje nije uspjelo';

  @override
  String errorFailedToUploadFileTitle(String filename) {
    return 'Učitavanje datoteke nije uspjelo: $filename';
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
      other: '$num datoteka je veće',
      few: '$num datoteke su veće',
      one: '$num datoteka je veća',
    );
    return '$_temp0 od ograničenja servera od $maxFileUploadSizeMib MiB i neće se učitati:\n\n$listMessage';
  }

  @override
  String errorFilesTooLargeTitle(int num) {
    String _temp0 = intl.Intl.pluralLogic(
      num,
      locale: localeName,
      other: 'Datoteke su prevelike',
      few: 'Datoteke su prevelike',
      one: 'Datoteka je prevelika',
    );
    return '$_temp0';
  }

  @override
  String get errorCouldNotLoadSelectedFiles =>
      'Odabrane datoteke nije moguće učitati.';

  @override
  String errorCouldNotReadFile(String filename) {
    return 'Datoteku nije moguće pročitati: $filename';
  }

  @override
  String get errorLoginInvalidInputTitle => 'Neispravan unos';

  @override
  String get errorLoginFailedTitle => 'Prijava nije uspjela';

  @override
  String get errorMessageNotSent => 'Poruka nije poslana';

  @override
  String get errorMessageEditNotSaved => 'Poruka nije spremljena';

  @override
  String errorLoginCouldNotConnect(String url) {
    return 'Povezivanje sa serverom nije uspjelo:\n$url';
  }

  @override
  String get errorCouldNotConnectTitle => 'Povezivanje nije uspjelo';

  @override
  String get errorLoginRealmNotFoundTitle => 'Organizacija ne postoji';

  @override
  String errorLoginRealmNotFound(String url) {
    return 'Na $url nema chata. Provjerite naziv organizacije.';
  }

  @override
  String get errorMessageDoesNotSeemToExist =>
      'Čini se da ta poruka ne postoji.';

  @override
  String get errorQuotationFailed => 'Citiranje nije uspjelo';

  @override
  String errorServerMessage(String message) {
    return 'Server je odgovorio:\n\n$message';
  }

  @override
  String get errorConnectingToServerShort =>
      'Pogreška pri povezivanju s chat serverom. Pokušavam ponovno…';

  @override
  String errorConnectingToServerDetails(String serverUrl, String error) {
    return 'Pogreška pri povezivanju s chat serverom na $serverUrl. Pokušat ću ponovno:\n\n$error';
  }

  @override
  String get errorHandlingEventTitle =>
      'Pogreška pri obradi događaja sa servera. Ponovno povezivanje…';

  @override
  String errorHandlingEventDetails(
    String serverUrl,
    String error,
    String event,
  ) {
    return 'Pogreška pri obradi događaja sa servera $serverUrl; pokušat ću ponovno.\n\nPogreška: $error\n\nDogađaj: $event';
  }

  @override
  String get errorCouldNotOpenLinkTitle => 'Poveznicu nije moguće otvoriti';

  @override
  String errorCouldNotOpenLink(String url) {
    return 'Poveznica se nije mogla otvoriti: $url';
  }

  @override
  String get errorMuteTopicFailed => 'Utišavanje teme nije uspjelo';

  @override
  String get errorUnmuteTopicFailed => 'Uključivanje zvuka teme nije uspjelo';

  @override
  String get errorFollowTopicFailed => 'Praćenje teme nije uspjelo';

  @override
  String get errorUnfollowTopicFailed => 'Prestanak praćenja teme nije uspio';

  @override
  String get errorSharingFailed => 'Dijeljenje nije uspjelo';

  @override
  String get errorStarMessageFailedTitle =>
      'Označavanje zvjezdicom nije uspjelo';

  @override
  String get errorUnstarMessageFailedTitle =>
      'Uklanjanje zvjezdice nije uspjelo';

  @override
  String get errorHideLinkPreviewsFailedTitle =>
      'Skrivanje pregleda poveznica nije uspjelo';

  @override
  String get errorShowLinkPreviewsFailedTitle =>
      'Prikaz pregleda poveznica nije uspio';

  @override
  String get errorCouldNotEditMessageTitle => 'Poruku nije moguće urediti';

  @override
  String get successAppVersionCopied => 'Verzija aplikacije kopirana';

  @override
  String get successPushTokenCopied => 'Push token kopiran';

  @override
  String get notificationsSettingsTitle => 'OBAVIJESTI';

  @override
  String get pushTokenSettingTitle => 'Push token';

  @override
  String get pushTokenSettingUnavailable => 'Token još nije dostupan';

  @override
  String get moveToNewAppTitle => 'Kloki Chat ima novu aplikaciju';

  @override
  String get moveToNewAppMessage =>
      'Instaliraj novu Kloki Chat aplikaciju iz App Storea i prijavi se istim računom. Sve poruke i kanali su tamo. Ova aplikacija više ne dobiva ažuriranja.';

  @override
  String get moveToNewAppOpenStoreButton => 'Otvori App Store';

  @override
  String get moveToNewAppLaterButton => 'Kasnije';

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
  String get dialogCancel => 'Odustani';

  @override
  String get dialogContinue => 'Nastavi';

  @override
  String get dialogClose => 'Zatvori';

  @override
  String get errorDialogLearnMore => 'Saznaj više';

  @override
  String get errorDialogContinue => 'U redu';

  @override
  String get errorDialogTitle => 'Pogreška';

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
      other: '$maxLength znakova',
      few: '$maxLength znaka',
      one: '$maxLength znaka',
    );
    return 'Tema ne smije biti dulja od $_temp0.';
  }

  @override
  String get topicValidationErrorMandatoryButEmpty =>
      'U ovom kanalu tema je obavezna.';

  @override
  String get errorContentNotInsertedTitle => 'Sadržaj nije umetnut';

  @override
  String get errorContentToInsertIsEmpty =>
      'Datoteka za umetanje je prazna ili joj nije moguće pristupiti.';

  @override
  String errorServerVersionNotAllowedMessage(
    String url,
    String zulipVersion,
    String minAllowedZulipVersion,
  ) {
    return '$url koristi Zulip Server $zulipVersion, koji nije podržan. Najniža podržana verzija je Zulip Server $minAllowedZulipVersion.';
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
    return 'Vaš račun na $url nije moguće potvrditi. Pokušajte se ponovno prijaviti ili koristite drugi račun.';
  }

  @override
  String get errorInvalidResponse => 'Server je poslao neispravan odgovor.';

  @override
  String get errorNetworkRequestFailed => 'Mrežni zahtjev nije uspio';

  @override
  String errorMalformedResponse(int httpStatus) {
    return 'Server je poslao neispravan odgovor; HTTP status $httpStatus';
  }

  @override
  String errorMalformedResponseWithCause(int httpStatus, String details) {
    return 'Server je poslao neispravan odgovor; HTTP status $httpStatus; $details';
  }

  @override
  String errorRequestFailed(int httpStatus) {
    return 'Mrežni zahtjev nije uspio: HTTP status $httpStatus';
  }

  @override
  String get errorVideoPlayerFailed => 'Videozapis nije moguće reproducirati.';

  @override
  String get errorVideoPlayerFailedTryBrowser =>
      'Pokušajte ga otvoriti u pregledniku.';

  @override
  String get dialogOpenInBrowser => 'Otvori u pregledniku';

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
  String get errorMarkAsReadFailedTitle =>
      'Označavanje kao pročitano nije uspjelo';

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
  String get errorMarkAsUnreadFailedTitle =>
      'Označavanje kao nepročitano nije uspjelo';

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
  String get errorNotificationOpenTitle => 'Otvaranje obavijesti nije uspjelo';

  @override
  String get errorNotificationOpenAccountNotFound =>
      'Račun povezan s ovom obavijesti nije pronađen.';

  @override
  String get errorReactionAddingFailedTitle =>
      'Dodavanje reakcije nije uspjelo';

  @override
  String get errorReactionRemovingFailedTitle =>
      'Uklanjanje reakcije nije uspjelo';

  @override
  String get errorSharingTitle => 'Dijeljenje sadržaja nije uspjelo';

  @override
  String get errorSharingAccountNotLoggedIn =>
      'Nijedan račun nije prijavljen. Prijavite se i pokušajte ponovno.';

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
  String get topicListEmptyPlaceholderHeader => 'Ovdje još nema tema.';

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
  String get klokiOrganizationLabel => 'Organizacija';

  @override
  String get klokiOrganizationHint => 'tvrtka';

  @override
  String get klokiOrganizationInvalid =>
      'Upišite naziv organizacije iz adrese chata (tvrtka u tvrtka.chat.kloki.app) ili zalijepite poveznicu iz chata.';

  @override
  String get klokiWelcomeTitle => 'Chat cijelog tima';

  @override
  String get klokiWelcomeDescription =>
      'Kanali, privatne poruke i grupe za cijeli tim. Prijavite se svojim Kloki računom, bez posebne lozinke.';

  @override
  String get klokiLinkSignInFailedTitle => 'Prijava iz Klokija nije uspjela';

  @override
  String get klokiLinkSignInFailedMessage =>
      'Poveznica je možda istekla. Vratite se u Kloki GO i ponovno otvorite chat ili se prijavite ovdje.';

  @override
  String get klokiLinkBackToKlokiGo => 'Natrag u Kloki GO';

  @override
  String get klokiLinkTryManually => 'Pokušaj ručno';

  @override
  String get klokiOrganizationsTitle => 'Organizacije';

  @override
  String get klokiOrganizationsSignInPrompt =>
      'Prijavite se kroz Kloki da biste ovdje prelazili između chatova svojih tvrtki.';

  @override
  String get klokiOrganizationsOnlyOne => 'U Klokiju ste samo u jednoj tvrtki.';

  @override
  String get klokiOrganizationsLoadFailed => 'Tvrtke se nisu mogle učitati.';

  @override
  String get klokiOrganizationsRetry => 'Pokušaj ponovno';

  @override
  String klokiOrganizationNoChat(String company) {
    return '$company nema chat u Klokiju.';
  }

  @override
  String get klokiOrganizationSwitchFailedTitle => 'Prelazak nije uspio';

  @override
  String klokiOrganizationSwitchFailed(String company) {
    return 'Prelazak na $company nije uspio. Pokušajte kasnije.';
  }
}
