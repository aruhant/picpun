import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:picpun/flavors.dart';
import 'package:picpun/generated/locale_keys.g.dart';
import 'package:picpun/style/my_button.dart';
import 'package:picpun/util/logger.dart';

final ENABLE_ADS = !Platform.isMacOS;

RewardedAd? _rewardedAd;

enum AdState { loading, loaded, error, none, shown }

bool get isAdLoaded => _rewardedAd?.responseInfo?.responseId != null;

Future<void> showAd([Function(int)? inputCallback]) async {
  if (!ENABLE_ADS) {
    return inputCallback?.call(25);
  }
  Log.i('Showing ad ${_rewardedAd?.responseInfo?.responseId}');
  if (_rewardedAd?.responseInfo?.responseId == null) {
    Log.w('Warning: attempt to show rewarded before loaded');
    await loadAd();
    Log.w('Loaded now');
  }
  try {
    await _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      Log.i('ad earned reward: $rewardItem');
      inputCallback?.call(rewardItem.amount.toInt());
      Future.delayed(const Duration(seconds: 1), loadAd);
    });
  } catch (e) {
    Log.e(e);
    inputCallback?.call(0);
  }
}

Future<AdState> loadAd([void Function(AdState)? callback]) async {
  if (_rewardedAd?.responseInfo?.responseId != null) {
    Log.w('Warning: attempt to load rewarded when already loaded');
    callback?.call(AdState.loaded);
    return Future.value(AdState.loaded);
  }
  Log.i('Loading rewarded ad');
  callback?.call(AdState.loading);
  try {
    await RewardedAd.load(
        adUnitId: F.appFlavor!.adID,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdFailedToLoad: (LoadAdError error) {
            Log.e('RewardedAd failed to load: $error');
            callback?.call(AdState.error);
          },
          onAdLoaded: (ad) {
            Log.i('${ad.responseInfo?.responseId} loaded.');
            ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) =>
                    Log.i('$ad onAdShowedFullScreenContent.'),
                onAdImpression: (ad) => Log.i('$ad impression occurred.'),
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                  _rewardedAd = null;
                  callback?.call(AdState.error);
                  Log.e('$ad failed to show full screen content: $err');
                },
                onAdDismissedFullScreenContent: (ad) {
                  Log.i('$ad dismissed full screen content.');
                  ad.dispose();
                  _rewardedAd = null;
                  callback?.call(AdState.none);
                },
                onAdClicked: (ad) => Log.i('$ad clicked.'));
            _rewardedAd = ad;
            callback?.call((_rewardedAd?.responseInfo?.responseId != null)
                ? AdState.loaded
                : AdState.error);
          },
        ));
  } catch (e) {
    Log.e(e);
    callback?.call(AdState.error);
    return Future.value(AdState.error);
  }
  return Future.value(AdState.loading);
}

class AdWidget extends StatefulWidget {
  final Widget Function(VoidCallback) showAdBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function() onAdShownBuilder;
  final Widget Function(VoidCallback) errorBuilder;
  final Function(int) onAdShown;
  const AdWidget(
      {super.key,
      required this.showAdBuilder,
      required this.loadingBuilder,
      required this.errorBuilder,
      required this.onAdShownBuilder,
      required this.onAdShown});
  @override
  _AdWidgetState createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> {
  AdState _adState = AdState.none;
  @override
  void initState() {
    super.initState();
    tryLoading();
  }

  @override
  Widget build(BuildContext context) {
    if (!ENABLE_ADS) return Container();
    Log.i('Building ad widget $_adState');
    switch (_adState) {
      case AdState.loading:
        return widget.loadingBuilder();
      case AdState.error:
        return widget.errorBuilder(tryLoading);
      case AdState.loaded:
        return widget.showAdBuilder(() => onShowPressed());
      case AdState.shown:
        return widget.onAdShownBuilder();
      case AdState.none:
        return const Text('-');
    }
  }

  onShowPressed() async {
    showAd((result) {
      if (result == 0) {
        setState(() => _adState = AdState.error);
      } else {
        widget.onAdShown.call(result);
        setState(() => _adState = AdState.shown);
      }
    });
  }

  tryLoading() async {
    loadAd((AdState state) {
      setState(() {
        _adState = state;
      });
    }).then((value) => setState(() {
          _adState = value;
        }));
  }
}

Widget buildAdbutton(Function(int) callback, {required int adShownCredits}) {
  return AdWidget(
    showAdBuilder: (onShowPressed) => MyButton(
        onPressed: onShowPressed,
        label: ('${LocaleKeys.watch_video.tr()} +$adShownCredits 💎')),
    loadingBuilder: () => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14), color: Colors.white54),
        child: const CircularProgressIndicator()),
    errorBuilder: (onPressed) => TextButton(
        onPressed: onPressed, child: Text(LocaleKeys.retry_loading_ad.tr())),
    onAdShownBuilder: () => Container(),
    onAdShown: (c) => callback(c),
  );
}
