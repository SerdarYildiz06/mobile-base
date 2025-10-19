import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class DuplicateContactsScreen extends StatefulWidget {
  const DuplicateContactsScreen({super.key});

  @override
  State<DuplicateContactsScreen> createState() =>
      _DuplicateContactsScreenState();
}

class _DuplicateContactsScreenState extends State<DuplicateContactsScreen> {
  List<List<Contact>> _duplicateGroups = [];
  bool _isLoading = true;
  int _totalDuplicates = 0;

  @override
  void initState() {
    super.initState();
    _loadDuplicateContacts();
  }

  Future<void> _loadDuplicateContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: false)) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // Find duplicates
      final duplicateGroups = _findDuplicates(contacts);

      setState(() {
        _duplicateGroups = duplicateGroups;
        _totalDuplicates =
            duplicateGroups.fold(0, (sum, group) => sum + group.length - 1);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<List<Contact>> _findDuplicates(List<Contact> contacts) {
    Map<String, List<Contact>> grouped = {};

    for (var contact in contacts) {
      // Group by name (case insensitive)
      String key = contact.displayName.trim().toLowerCase();

      if (key.isEmpty) continue;

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(contact);
    }

    // Filter only groups with more than one contact
    return grouped.values.where((group) => group.length > 1).toList();
  }

  Future<void> _mergeContacts(List<Contact> contacts) async {
    if (contacts.isEmpty) return;

    try {
      // Show confirmation dialog - iOS Action Sheet Style
      final confirmed = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text(
            'Merge Contacts',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          message: Text(
            'This will merge ${contacts.length} duplicate contacts into one. All phone numbers, emails, and other information will be combined.',
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Merge Contacts'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
        ),
      );

      if (confirmed != true) return;

      // Create merged contact with combined data
      Contact mergedContact = Contact();

      // Use the first contact as base
      Contact baseContact = contacts.first;
      mergedContact.name = baseContact.name;
      mergedContact.displayName = baseContact.displayName;

      // Collect all unique phone numbers
      Set<String> phoneNumbers = {};
      for (var contact in contacts) {
        for (var phone in contact.phones) {
          phoneNumbers.add(phone.number);
        }
      }
      mergedContact.phones =
          phoneNumbers.map((number) => Phone(number)).toList();

      // Collect all unique emails
      Set<String> emails = {};
      for (var contact in contacts) {
        for (var email in contact.emails) {
          emails.add(email.address);
        }
      }
      mergedContact.emails = emails.map((email) => Email(email)).toList();

      // Collect all unique addresses
      List<Address> addresses = [];
      for (var contact in contacts) {
        addresses.addAll(contact.addresses);
      }
      mergedContact.addresses = addresses;

      // Use photo from first contact that has one
      for (var contact in contacts) {
        if (contact.photo != null && contact.photo!.isNotEmpty) {
          mergedContact.photo = contact.photo;
          break;
        }
      }

      // Insert the merged contact
      await mergedContact.insert();

      // Delete the original contacts
      for (var contact in contacts) {
        await contact.delete();
      }

      // Show success message - iOS Alert Style
      if (mounted) {
        await showCupertinoDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => CupertinoAlertDialog(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: CupertinoColors.systemGreen,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text('Success'),
              ],
            ),
            content: const Text(
              'Contacts have been merged successfully.',
              style: TextStyle(fontSize: 13),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }

      // Reload the list
      await _loadDuplicateContacts();
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => CupertinoAlertDialog(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: CupertinoColors.systemRed,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text('Error'),
              ],
            ),
            content: Text(
              'Failed to merge contacts. Please try again.',
              style: const TextStyle(fontSize: 13),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  String _getInitials(String displayName) {
    final names = displayName.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  Color _getAvatarColor(String displayName) {
    final colors = [
      CupertinoColors.activeBlue,
      CupertinoColors.activeGreen,
      CupertinoColors.activeOrange,
      CupertinoColors.systemPink,
      CupertinoColors.systemPurple,
      CupertinoColors.systemTeal,
    ];

    return colors[displayName.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Duplicate Contacts'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _duplicateGroups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        CupertinoIcons.person_crop_circle_badge_exclam,
                        size: 64,
                        color: CupertinoColors.systemGrey3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Duplicate Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You have no duplicate contacts in your address book.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey2,
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      // Summary Header - iOS Inset Style
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemYellow
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.info_circle_fill,
                                  color: CupertinoColors.systemYellow,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${_duplicateGroups.length} ${_duplicateGroups.length == 1 ? 'group' : 'groups'} • $_totalDuplicates ${_totalDuplicates == 1 ? 'duplicate' : 'duplicates'} found',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Duplicate Groups List - iOS Grouped Style
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final group = _duplicateGroups[index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                index == 0 ? 0 : 8,
                                16,
                                index == _duplicateGroups.length - 1 ? 20 : 0,
                              ),
                              child: _buildDuplicateGroupCard(
                                  context, group, index),
                            );
                          },
                          childCount: _duplicateGroups.length,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDuplicateGroupCard(
      BuildContext context, List<Contact> group, int groupIndex) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with merge button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.person_2_fill,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${group.length} ${group.length == 1 ? 'Contact' : 'Contacts'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                      letterSpacing: -0.08,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  //color: CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(6),
                  minSize: 0,
                  onPressed: () => _mergeContacts(group),
                  child: const Text(
                    'Merge',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.black,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.08,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contact list items
          ...List.generate(group.length, (index) {
            final contact = group[index];
            final isLast = index == group.length - 1;
            return _buildContactRow(context, contact, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, Contact contact, bool isLast) {
    final hasPhoto = contact.photo != null && contact.photo!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey6,
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          // Avatar - iOS Style
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasPhoto ? null : _getAvatarColor(contact.displayName),
              shape: BoxShape.circle,
              image: hasPhoto
                  ? DecorationImage(
                      image: MemoryImage(contact.photo!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasPhoto
                ? null
                : Center(
                    child: Text(
                      _getInitials(contact.displayName),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.41,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Contact Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.41,
                    color: CupertinoColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (contact.phones.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    contact.phones.first.number,
                    style: TextStyle(
                      fontSize: 15,
                      letterSpacing: -0.24,
                      color: CupertinoColors.systemGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (contact.emails.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    contact.emails.first.address,
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: -0.08,
                      color: CupertinoColors.systemGrey2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Chevron indicator
          const Icon(
            CupertinoIcons.chevron_right,
            size: 14,
            color: CupertinoColors.systemGrey3,
          ),
        ],
      ),
    );
  }
}
