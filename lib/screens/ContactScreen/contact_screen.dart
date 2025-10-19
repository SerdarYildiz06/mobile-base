import 'package:cleaner_app/screens/ContactScreen/all_contacts_screen.dart';
import 'package:cleaner_app/screens/ContactScreen/duplicate_contacts_screen.dart';
import 'package:cleaner_app/screens/ContactScreen/missing_info_contacts_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getContacts();
    });
  }

  List<Contact> contacts = [];
  List<List<Contact>> duplicateGroups = [];
  List<Contact> missingInfoContacts = [];

  Future<void> getContacts() async {
    bool isGranted = await FlutterContacts.requestPermission();
    print('isGranted: $isGranted');
    if (isGranted) {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      final duplicates = _findDuplicates(contacts);
      final missingInfo = _findMissingInfo(contacts);
      setState(() {
        this.contacts = contacts;
        duplicateGroups = duplicates;
        missingInfoContacts = missingInfo;
      });
    }
  }

  List<List<Contact>> _findDuplicates(List<Contact> contacts) {
    Map<String, List<Contact>> grouped = {};

    for (var contact in contacts) {
      String key = contact.displayName.trim().toLowerCase();
      if (key.isEmpty) continue;

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(contact);
    }

    return grouped.values.where((group) => group.length > 1).toList();
  }

  List<Contact> _findMissingInfo(List<Contact> contacts) {
    return contacts.where((contact) {
      // Sadece telefon numarası olmayanları listele
      return contact.phones.isEmpty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Contacts'),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildListDelegate([
                  // All Videos
                  _buildCategoryCard(
                    title: 'All Contacts',
                    size: '${contacts.length} contacts',
                    subtitle: '${contacts.length} contacts',
                    icon: CupertinoIcons.person_2_fill,
                    gradientColors: [
                      const Color(0xFF8B7355),
                      const Color(0xFF6B5544),
                    ],
                    isLoading: false,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const AllContactsScreen(),
                        ),
                      );
                    },
                  ),
                  // Duplicate Contacts
                  _buildCategoryCard(
                    title: 'Duplicate Contacts',
                    size:
                        '${duplicateGroups.fold(0, (sum, group) => sum + group.length - 1)} duplicates',
                    subtitle: '${duplicateGroups.length} groups',
                    icon: CupertinoIcons.person_2_square_stack,
                    gradientColors: [
                      const Color(0xFFFF6B6B),
                      const Color(0xFFEE5A6F),
                    ],
                    isLoading: false,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const DuplicateContactsScreen(),
                        ),
                      );
                    },
                  ),
                  // Missing Information Contacts
                  _buildCategoryCard(
                    title: 'No Phone Number',
                    size: '${missingInfoContacts.length} contacts',
                    subtitle: '${missingInfoContacts.length} contacts',
                    icon: CupertinoIcons.phone_badge_plus,
                    gradientColors: [
                      const Color(0xFFFFA726),
                      const Color(0xFFFF8A00),
                    ],
                    isLoading: false,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => MissingInfoContactsScreen(
                            contacts: missingInfoContacts,
                            onContactsDeleted: () {
                              getContacts();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String size,
    required String? subtitle,
    required IconData? icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient overlay

            // Size badge (sol üst)
            if (icon != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: gradientColors.first),
                ),
              ),

            // Title ve icon (alt kısım)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (subtitle != null) ...[
                          isLoading
                              ? const CupertinoActivityIndicator(
                                  radius: 6,
                                  color: CupertinoColors.white,
                                )
                              : Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
