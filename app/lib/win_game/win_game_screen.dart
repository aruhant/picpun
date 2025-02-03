import 'package:auto_size_text_plus/auto_size_text_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picpun/generated/locale_keys.g.dart';
import 'package:picpun/level_selection/levels.dart';
import 'package:picpun/player_progress/player_progress.dart';
import 'package:picpun/util/ads.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../game_internals/score.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class WinGameScreen extends StatelessWidget {
  final Score score;
  final GameLevel level;

  const WinGameScreen({super.key, required this.level, required this.score});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    const gap = SizedBox(height: 14);

    return Scaffold(
        backgroundColor: palette.backgroundPlaySession,
        body: ResponsiveScreen(
            squarishMainArea: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  gap,
                  Center(
                      child: AutoSizeText(winMessage(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 50))),
                  gap,
                  Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(5, 5))
                        ],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Image.asset(level.image,
                          width: 200, height: 200, fit: BoxFit.contain)),
                  gap,
                  Center(
                      child: AutoSizeText(level.answer,
                          maxLines: 2, style: TextStyle(fontSize: 30))),
                  gap,
                  Center(
                      child: Text(LocaleKeys.level.tr() + ': ${score.level}',
                          // 'Time: ${score.formattedTime}',
                          style: const TextStyle(
                              fontFamily: 'Baloo 2', fontSize: 20)))
                ]),
            rectangularMenuArea: Column(
              children: [
                buildAdbutton(
                    (credits) => addCreditsAndGoToNextLevel(context, credits),
                    adShownCredits: 25),
                gap,
                TextButton(
                    onPressed: () => addCreditsAndGoToNextLevel(context, 10),
                    child: Text('${LocaleKeys.next_level.tr()} +10 💎')),
                gap,
              ],
            )));
  }

  void addCreditsAndGoToNextLevel(BuildContext context, int credits) {
    PlayerProgress playerProgress = context.read<PlayerProgress>();
    playerProgress.addCredits(credits);
    GoRouter.of(context).go('/play/session/${score.level}');
  }

  String winMessage() {
    return LocaleKeys.win_message.tr();
    List<String> messages = [
      "क्या बात है! जीत आपकी ही तो है!",
      "ऐसा खेल, ऐसा तड़का!",
      "आप हैं असली जादूगर!",
      "आप तो सच्चे हीरो निकले!",
      "क्या बात है!",
      "आलौकिक शक्तियाँ हैं आपके अंदर!",
      "इस जीत के बाद तो आपका नाम गूंजेगा!",
      "वो कहते हैं ना, बहेतरीन खेल—बिलकुल वैसा!",
      "ऐसा खेल, ऐसा जलवा!",
      "आपका जादू चल पड़ा है!",
      "आप जो खेलते हो, वही जीतते हो!",
      "आप हो हमारी गेम के चैंपियन!",
      "आपकी जीत, आपकी पहचान!",
      "एक बार फिर से! आप ही जीतने वाले हैं!",
      "आप हैं इस गेम के असली बादशाह!",
      "अरे वाह, क्या शानदार जीत है!",
      "आप हैं गेम के सबसे बड़े खिलाड़ी!",
      "क्या जीत है! आप तो असली विजेता हैं!",
      "जीत के बाद आप तो खुद एक कहानी बन गए हैं!",
      "आपके खेल का कोई मुकाबला नहीं!",
      "बिलकुल लाजवाब, ऐसा खेल कहीं नहीं देखा!",
      "आपकी जीत को देखकर तो सभी हैरान हैं!",
      "आपकी जीत में कुछ खास है, पूरी दुनिया देखेगी!",
      "आपने तो जैसे जादू कर दिया इस खेल में!",
      "आपके जैसा खिलाड़ी कौन?",
      "यह जीत हर किसी के बस की बात नहीं!",
      "आपकी जीत अब तक की सबसे बेहतरीन है!",
      "दुनिया की सबसे बेहतरीन जीत, आपकी!",
      "आपकी जीत ने तो सबको चौंका दिया!",
      "आपकी जीत एक मिसाल है!",
      "शानदार! अब आपकी जीत का जश्न मनाइए!",
      "आपकी जीत ने तो सभी के होश उड़ा दिए!",
      "जितनी तेज़ी से आपने हल किया, उतनी ही चतुराई से!",
      "हर समस्या का हल था आपके दिमाग में पहले से!",
      "शानदार! ऐसा लगा जैसे आपको ये पहले से ही पता था!",
      "जब दिमागी खेल की बात हो, तो आप सबसे आगे हो!",
      "आपके दिमाग में ऐसा कुछ है, जो हर पहेली को आसान बना देता है!",
      "क्या तेज़ी से हल किया! ऐसे तो कोई भी नहीं कर सकता!",
      "आपने तो जैसे गेम को अपनी ऊँगलियों पर घुमाया!",
      "हर चुनौती को आपने चुटकियों में हल कर दिया!",
      "आपने तो इस पहेली को ऐसे सुलझाया जैसे कुछ भी नहीं था!",
      "सवाल चाहे जैसा भी हो, आपके पास जवाब हमेशा तैयार होता है!",
      "आपकी बुद्धि का कोई मुकाबला नहीं!",
      "आपकी सोच का स्तर इतना ऊँचा है, बाकी सब तो बस देख रहे हैं!",
      "शानदार! आप तो दिमागी खेल के असली मास्टर हो!",
      "आपने तो इसे जैसे अपनी समझ से हल कर लिया, कोई रोक नहीं सकता!",
      "क्या शानदार सोच है!",
      "सभी दिमागी खेलों में अब आपका नाम सबसे पहले आएगा!",
      "आपके दिमाग में हर सवाल का हल पहले से ही था!",
      "आपकी सटीकता और तेज़ी ने सबको चौंका दिया!",
      "आपकी सोच और समझ का कोई मुकाबला नहीं!",
      "इतनी मेहनत और समझ से हल किया, बेहतरीन!",
      "आपने पहेली को सुलझा दिया, ऐसा लग रहा है जैसे इसे पहले से जानते हो!",
      "इस खेल में जितना तेज़ और स्मार्ट आप हो, उतना कोई नहीं!",
      "आपके दिमाग में एक विजेता की झलक है, हर चुनौती को पार कर लेते हो!",
      "दिमागी खेल हो और उसमें आप न जीतें, ऐसा हो ही नहीं सकता!",
      "आपने ऐसा खेल दिखाया, जैसे पहेली खुद आपके लिए तैयार की गई हो!",
      "कभी हार मानने का नाम नहीं लिया! यही असली जीत है!",
      "तीव्र सोच!",
      "यह जीत साबित करती है कि आपके दिमाग का कोई मुकाबला नहीं!",
      "शानदार!",
      "जैसे आपको हर सवाल का जवाब पहले से पता था!",
      "इतनी समझदारी से खेला, अब ये खेल भी आसान लगता है!",
      "यह तो सिर्फ एक और जीत थी आपके नाम की!",
      "आपने यह खेल जीतने में इतनी चतुराई दिखाई, कि सब दंग रह गए!",
      "क्या गति है! यह खेल बहुत आसान लगने लगा!",
      "हर गेम को जीतने का तरीका - बेहतरीन!",
      "बिलकुल तेज़ और सटीक, जैसे सब कुछ आपके दिमाग में पहले से तैयार हो!",
      "आपने जितना शानदार खेला, उतना कोई और नहीं कर सकता!",
      "आपकी जीत ने साबित कर दिया कि दिमागी खेल में आप सबसे आगे हो!",
      "आपने तो इसे हल करके हर चुनौती को मात दे दी!"
    ];
    return messages.elementAt(DateTime.now().microsecond % messages.length);
  }
}
