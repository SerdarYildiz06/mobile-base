import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class AllContactsScreen extends StatefulWidget {
  const AllContactsScreen({super.key});

  @override
  State<AllContactsScreen> createState() => _AllContactsScreenState();
}

class _AllContactsScreenState extends State<AllContactsScreen> {
  List<Contact>? _contacts;
  bool _isLoading = true;
  Map<String, List<Contact>> groupedContacts = {};
  List<String> alphabetList = [];
  final scrollController = ScrollController();
  String? _selectedLetter;
  final ValueNotifier<Offset?> _dragOffset = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _dragOffset.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      setState(() {
        _contacts = contacts;
        _isLoading = false;
        _initializeContacts();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _initializeContacts() {
    if (_contacts == null || _contacts!.isEmpty) {
      groupedContacts = {};
      alphabetList = [];
      return;
    }

    // Group contacts by first letter
    groupedContacts = {};
    for (var contact in _contacts!) {
      if (contact.displayName.isEmpty) continue;

      String firstLetter = contact.displayName[0].toUpperCase();
      if (!groupedContacts.containsKey(firstLetter)) {
        groupedContacts[firstLetter] = [];
      }
      groupedContacts[firstLetter]!.add(contact);
    }

    // Sort contacts within each group
    for (var key in groupedContacts.keys) {
      groupedContacts[key]!.sort((a, b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    }

    // Sort the groups
    groupedContacts = Map.fromEntries(
      groupedContacts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    // Create alphabet list
    alphabetList = groupedContacts.keys.toList();
  }

  void _onVerticalDragUpdate(
      DragUpdateDetails details, BoxConstraints constraints) {
    _dragOffset.value = details.globalPosition;
    _updateSelectedLetterFromDrag(details.globalPosition, constraints);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _dragOffset.value = null;
    _selectedLetter = null;
  }

  void _updateSelectedLetterFromDrag(
      Offset position, BoxConstraints constraints) {
    if (alphabetList.isEmpty) return;

    final double topPadding = MediaQuery.of(context).padding.top;
    final double availableHeight =
        constraints.maxHeight - 16; // Account for padding
    final double letterHeight = availableHeight / alphabetList.length;

    // Adjust position relative to the safe area
    final adjustedY = position.dy - topPadding - 8; // 8 for top padding
    final int index =
        (adjustedY ~/ letterHeight).clamp(0, alphabetList.length - 1);

    if (index >= 0 && index < alphabetList.length) {
      final letter = alphabetList[index];
      if (_selectedLetter != letter) {
        _selectedLetter = letter;
        _scrollToLetter(letter);
      }
    }
  }

  void _scrollToLetter(String letter) {
    final keys = groupedContacts.keys.toList();
    final index = keys.indexOf(letter);
    if (index != -1) {
      final itemHeight = 80.0;
      final headerHeight = 40.0;
      final previousItemsCount = keys.sublist(0, index).fold<int>(
            0,
            (sum, key) => sum + groupedContacts[key]!.length,
          );
      final scrollPosition =
          (previousItemsCount * itemHeight) + (index * headerHeight);

      scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _getInitials(String displayName) {
    final names = displayName.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
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
        middle: Text('Contacts'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _contacts == null || _contacts!.isEmpty
              ? const Center(
                  child: Text(
                    'No contacts found or permission denied',
                    style: TextStyle(color: CupertinoColors.secondaryLabel),
                  ),
                )
              : alphabetList.isEmpty
                  ? const Center(
                      child: Text(
                        'No contacts to display',
                        style: TextStyle(color: CupertinoColors.secondaryLabel),
                      ),
                    )
                  : Stack(
                      children: [
                        CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            SliverSafeArea(
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final letter = alphabetList[index];
                                    final contactsInSection =
                                        groupedContacts[letter]!;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          color: CupertinoColors
                                              .systemGroupedBackground,
                                          child: Text(
                                            letter,
                                            style: const TextStyle(
                                              color: CupertinoColors.activeBlue,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        ...contactsInSection.map((contact) {
                                          final phones =
                                              contact.phones.isNotEmpty
                                                  ? contact.phones.first.number
                                                  : 'No phone number';

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: CupertinoColors
                                                  .systemBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: CupertinoColors
                                                      .systemGrey
                                                      .withOpacity(0.1),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                // Handle contact tap
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                child: Row(
                                                  children: [
                                                    contact.photo != null
                                                        ? Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image:
                                                                  DecorationImage(
                                                                image: MemoryImage(
                                                                    contact
                                                                        .photo!),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: _getAvatarColor(
                                                                  contact
                                                                      .displayName),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                _getInitials(contact
                                                                    .displayName),
                                                                style:
                                                                    const TextStyle(
                                                                  color:
                                                                      CupertinoColors
                                                                          .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            contact.displayName,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  CupertinoColors
                                                                      .label,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            phones,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              color: CupertinoColors
                                                                  .secondaryLabel,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  },
                                  childCount: alphabetList.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // iOS style index bar
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: SafeArea(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return GestureDetector(
                                  onVerticalDragUpdate: (details) =>
                                      _onVerticalDragUpdate(
                                          details, constraints),
                                  onVerticalDragEnd: _onVerticalDragEnd,
                                  child: ValueListenableBuilder<Offset?>(
                                    valueListenable: _dragOffset,
                                    builder: (context, dragOffset, _) {
                                      return Container(
                                        width: 20,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: alphabetList.map((letter) {
                                            final availableHeight =
                                                constraints.maxHeight -
                                                    16; // Account for padding
                                            final itemHeight = availableHeight /
                                                alphabetList.length;
                                            return SizedBox(
                                              height: itemHeight,
                                              child: Center(
                                                child: Text(
                                                  letter,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        letter ==
                                                                _selectedLetter
                                                            ? CupertinoColors
                                                                .activeBlue
                                                            : CupertinoColors
                                                                .secondaryLabel,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Selected letter indicator
                        ValueListenableBuilder<Offset?>(
                          valueListenable: _dragOffset,
                          builder: (context, dragOffset, _) {
                            if (dragOffset == null || _selectedLetter == null) {
                              return const SizedBox.shrink();
                            }

                            return LayoutBuilder(
                              builder: (context, constraints) {
                                // Get screen size to ensure indicator stays within bounds
                                final screenWidth =
                                    MediaQuery.of(context).size.width;
                                final screenHeight =
                                    MediaQuery.of(context).size.height;
                                final topPadding =
                                    MediaQuery.of(context).padding.top;
                                final bottomPadding =
                                    MediaQuery.of(context).padding.bottom;

                                // Calculate position with constraints
                                const indicatorWidth = 80.0;
                                const indicatorHeight = 80.0;

                                // Ensure left position stays within screen bounds
                                // Center the indicator horizontally on screen
                                final left =
                                    ((screenWidth - indicatorWidth) / 2).clamp(
                                  20.0,
                                  screenWidth - indicatorWidth - 20,
                                );

                                // Ensure top position stays within screen bounds
                                final rawTop =
                                    dragOffset.dy - (indicatorHeight / 2);
                                final top = rawTop.clamp(
                                  topPadding + 20,
                                  screenHeight -
                                      indicatorHeight -
                                      bottomPadding -
                                      20,
                                );

                                return Positioned(
                                  left: left,
                                  top: top,
                                  child: IgnorePointer(
                                    child: Container(
                                      width: indicatorWidth,
                                      height: indicatorHeight,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey
                                            .withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _selectedLetter!,
                                          style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
    );
  }
}
