// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:demo_ads/ad_service/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> data = [
    {
      "is_background": false,
      "background_img":
          "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
      "ads_click": 2,
      "back_click": 1,
      "is_open_interstitial": false,
      "open_interstitial_ads": "ads",
      "native_ads": "ads",
      "banner_ads": "ads",
      "reward_video_ads": "ads"
    }
  ];

  BannerAd? _bannerAd;

  bool _isAdLoaded = false;

  _initBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: BannerAd.testAdUnitId,
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          log("error=====>>>$error");
        }),
        request: AdRequest());

    _bannerAd!.load();
  }

  InterstitialAd? _interstitialAd;

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _createInterstitialAd();
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
    }
  }

  @override
  void initState() {
    _initBannerAd();
    _createInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 35,
            ),
            Stack(
              overflow: Overflow.visible,
              children: [
                Column(
                  children: List.generate(
                    1,
                    (index) => Visibility(
                      visible: data[index]['is_background'],
                      child: Image.network(
                        "${data[index]['background_img']}",
                        height: 600,
                        width: 500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      _showInterstitialAd();
                    },
                    child: Text("Show Interstitial Ad"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isAdLoaded
          ? Container(
              height: _bannerAd!.size.height.toDouble(),
              width: _bannerAd!.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : SizedBox(),
    );
  }
}
