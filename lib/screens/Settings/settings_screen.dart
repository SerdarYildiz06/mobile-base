import 'package:cleaner_app/screens/Subscription/subscription_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int tappedIndex = 0;
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () {
              return Future.value();
            },
          ),
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Settings'),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                CupertinoFormSection.insetGrouped(
                  header: const Text('SUBSCRIPTION'),
                  children: [
                    CupertinoListTile(
                      title: const Text('Subscription'),
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(builder: (context) => const SubscriptionsScreen()));
                      },
                    ),
                  ],
                ),
                // CupertinoFormSection.insetGrouped(
                //   header: const Text('APP SETTINGS'),
                //   children: [
                //     CupertinoListTile(
                //       title: const Text('Appearance'),
                //       onTap: () {},
                //       leading: const Icon(CupertinoIcons.moon),
                //       trailing: const CupertinoListTileChevron(),
                //     ),
                //     // CupertinoListTile(
                //     //   title: const Text('Language'),
                //     //   onTap: () {},
                //     //   leading: const Icon(CupertinoIcons.globe),
                //     //   trailing: const CupertinoListTileChevron(),
                //     // ),
                //   ],
                // ),
                CupertinoFormSection.insetGrouped(
                  header: const Text('SUPPORT APP'),
                  children: [
                    CupertinoListTile(
                      title: const Text('Rate Us'),
                      onTap: () {
                        _inAppReview.openStoreListing(
                          appStoreId: '6752960691',
                        );
                      },
                      leading: const Icon(CupertinoIcons.star),
                      trailing: const CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      title: const Text('Share with Friends'),
                      onTap: () {
                        Share.share('I found a great app — take a look: https://apps.apple.com/app/id6753590137');
                      },
                      leading: const Icon(CupertinoIcons.share),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text('CONTACT'),
                  children: [
                    CupertinoListTile(
                      title: const Text('Fedback'),
                      onTap: () async {
                        String mail = 'mirsaidefendi@gmail.com';
                        String query = 'mailto:$mail?subject=Feedback&body=Hello, I have a feedback for your app.';

                        final Uri emailUri = Uri.parse(query);
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                      leading: const Icon(CupertinoIcons.mail),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text('PRIVACY'),
                  children: [
                    CupertinoListTile(
                      title: const Text('Privacy Policy'),
                      onTap: () async {
                        final Uri uri = Uri.parse('https://www.freeprivacypolicy.com/live/1d1202d8-7c4f-4c68-8a99-787465bec8ca');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      leading: const Icon(CupertinoIcons.lock),
                      trailing: const CupertinoListTileChevron(),
                    ),
                    CupertinoListTile(
                      title: const Text('EULA'),
                      onTap: () async {
                        final Uri uri = Uri.parse('https://www.apple.com/legal/internet-services/itunes/dev/stdeula/');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      leading: const Icon(CupertinoIcons.doc),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  ],
                ),
                CupertinoFormSection.insetGrouped(
                  header: const Text('ABOUT'),
                  children: [
                    CupertinoListTile(
                      title: const Text('Version'),
                      onTap: () {
                        tappedIndex++;
                        if (tappedIndex > 10) {
                          tappedIndex = 0;
                          // Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(builder: (context) => const TempCreatePage()));
                        }
                      },
                      leading: const Icon(CupertinoIcons.info),
                      trailing: const Text('1.0.0'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
