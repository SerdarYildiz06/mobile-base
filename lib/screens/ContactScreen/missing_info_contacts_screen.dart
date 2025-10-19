import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class MissingInfoContactsScreen extends StatefulWidget {
  final List<Contact> contacts;
  final VoidCallback onContactsDeleted;

  const MissingInfoContactsScreen({
    super.key,
    required this.contacts,
    required this.onContactsDeleted,
  });

  @override
  State<MissingInfoContactsScreen> createState() =>
      _MissingInfoContactsScreenState();
}

class _MissingInfoContactsScreenState extends State<MissingInfoContactsScreen> {
  Set<String> _selectedContactIds = {};
  bool _selectAll = false;

  String _getMissingInfoText(Contact contact) {
    // Sadece telefon numarası eksikliğini göster
    return 'No phone number';
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      if (_selectAll) {
        _selectedContactIds = widget.contacts.map((c) => c.id).toSet();
      } else {
        _selectedContactIds.clear();
      }
    });
  }

  void _toggleContactSelection(String contactId) {
    setState(() {
      if (_selectedContactIds.contains(contactId)) {
        _selectedContactIds.remove(contactId);
        _selectAll = false;
      } else {
        _selectedContactIds.add(contactId);
        if (_selectedContactIds.length == widget.contacts.length) {
          _selectAll = true;
        }
      }
    });
  }

  Future<void> _deleteSelectedContacts() async {
    if (_selectedContactIds.isEmpty) return;

    // Show confirmation dialog
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text(
          'Delete Contacts',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        message: Text(
          'Are you sure you want to delete ${_selectedContactIds.length} contact${_selectedContactIds.length > 1 ? 's' : ''}? This action cannot be undone.',
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
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

    try {
      // Delete selected contacts
      for (var contact in widget.contacts) {
        if (_selectedContactIds.contains(contact.id)) {
          await contact.delete();
        }
      }

      if (mounted) {
        // Show success message
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
            content: Text(
              '${_selectedContactIds.length} contact${_selectedContactIds.length > 1 ? 's' : ''} deleted successfully.',
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

        // Call callback and go back
        widget.onContactsDeleted();
        Navigator.pop(context);
      }
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
            content: const Text(
              'Failed to delete contacts. Please try again.',
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
    }
  }

  String _getInitials(String displayName) {
    if (displayName.trim().isEmpty) return '?';
    final names = displayName.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  Color _getAvatarColor(String displayName) {
    final colors = [
      CupertinoColors.systemOrange,
      CupertinoColors.systemYellow,
      CupertinoColors.systemRed,
      CupertinoColors.systemPink,
    ];

    return colors[displayName.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('No Phone Number'),
        backgroundColor: CupertinoColors.systemBackground,
        trailing: _selectedContactIds.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _deleteSelectedContacts,
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
      ),
      child: widget.contacts.isEmpty
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
                    'Contacts with No Phone Number',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All your contacts have at least one phone number.',
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
                  // Select All Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CupertinoListTile(
                          onTap: _toggleSelectAll,
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectAll
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.systemGrey3,
                                width: 2,
                              ),
                              color: _selectAll
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.white,
                            ),
                            child: _selectAll
                                ? const Icon(
                                    CupertinoIcons.check_mark,
                                    size: 16,
                                    color: CupertinoColors.white,
                                  )
                                : null,
                          ),
                          title: const Text(
                            'Select All',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${_selectedContactIds.length} of ${widget.contacts.length} selected',
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Contact List
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final contact = widget.contacts[index];
                          final isSelected =
                              _selectedContactIds.contains(contact.id);
                          final displayName = contact.displayName.isEmpty
                              ? 'No Name'
                              : contact.displayName;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemBackground,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    _toggleContactSelection(contact.id),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      // Checkbox
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? CupertinoColors.activeBlue
                                                : CupertinoColors.systemGrey3,
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? CupertinoColors.activeBlue
                                              : CupertinoColors.white,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                CupertinoIcons.check_mark,
                                                size: 16,
                                                color: CupertinoColors.white,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      // Avatar
                                      contact.photo != null &&
                                              contact.photo!.isNotEmpty
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundImage:
                                                  MemoryImage(contact.photo!),
                                            )
                                          : CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  _getAvatarColor(displayName),
                                              child: Text(
                                                _getInitials(displayName),
                                                style: const TextStyle(
                                                  color: CupertinoColors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                      const SizedBox(width: 12),
                                      // Contact Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              displayName,
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w400,
                                                color: contact
                                                        .displayName.isEmpty
                                                    ? CupertinoColors.systemGrey
                                                    : CupertinoColors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _getMissingInfoText(contact),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: CupertinoColors
                                                    .systemOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Warning Icon
                                      const Icon(
                                        CupertinoIcons
                                            .exclamationmark_triangle_fill,
                                        color: CupertinoColors.systemOrange,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: widget.contacts.length,
                      ),
                    ),
                  ),

                  // Bottom Spacing
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                ],
              ),
            ),
    );
  }
}
