import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/case_card.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart'; // NEW

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // NEW: dynamic analytics state
  final math.Random _rand = math.Random();
  double _gaugeProgress = 0.76; // 76%
  int _timeSpentHours = 2;
  late List<double> _learningBars = List<double>.generate(
    12,
    (_) => 20 + _rand.nextInt(40).toDouble(),
  );

  // Chip state (for the horizontal filters under the header)
  final List<String> _chips = const [
    'criminal law',
    'civil law',
    'business law',
    'human rights',
    'taxation law',
  ];
  int _selectedChip = 2;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      // Home content redesigned
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: greeting + profile
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title area
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hello, Willy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                // Profile button (keeps existing navigation)
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  borderRadius: BorderRadius.circular(24),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppTheme.primary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search with filter button
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56, // increased height to match the look
                    child: CustomSearchBar(placeholder: 'Search'),
                  ),
                ),
                const SizedBox(width: 10),
                Ink(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: const CircleBorder(),
                  ),
                  child: SizedBox.square(
                    dimension: 56, // match search height
                    child: IconButton(
                      onPressed: () {
                        // TODO: hook up a filter screen if you have one
                        // Navigator.pushNamed(context, '/filters');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // keep size at 56x56
                      icon: Icon(
                        Icons.tune,
                        color: AppTheme.primary,
                        size: 22, // comfortable icon size for 56dp button
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              ' Explore topics',
              // Adapt the text if you want: e.g. 'Select your next topic'
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            // Horizontal chips (scrollable)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final selected = index == _selectedChip;
                  return ChoiceChip(
                    label: Text(_chips[index]),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedChip = index);
                    },
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.accent,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: selected ? AppTheme.accent : Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Big stacked cards placeholder (carousel)
            _CardStackPlaceholder(
              images: const [
                'assets/gavel.png',
                'assets/civil.png',
                'assets/criminal.png',
                'assets/pi.png',
                'assets/taxation.png',
                'assets/business.png',
              ],
            ),

            // Optional: keep your small cards row if you like (below the big stack)
            const SizedBox(height: 18),
            const Text(
              'Topics for you',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 12),
                itemCount: 12, // reduced count to show variety
                itemBuilder: (context, index) {
                  // Define topics with their corresponding images and titles
                  final topics = [
                    {'image': 'assets/criminal.png', 'title': 'Criminal'},
                    {'image': 'assets/civil.png', 'title': 'Civil'},
                    {'image': 'assets/business.png', 'title': 'Business'},
                    {'image': 'assets/taxation.png', 'title': 'Taxation'},
                    {'image': 'assets/pi.png', 'title': 'Personal Injury'},
                    {'image': 'assets/gavel.png', 'title': 'General Law'},
                  ];

                  final topicIndex = index % topics.length;
                  final topic = topics[topicIndex];

                  return CaseCard(
                    imagePath: topic['image'],
                    title: topic['title'],
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 12),
              ),
            ),

            // Spacer for the floating nav bar
            SizedBox(height: 120),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      // Analytics tab redesigned as dashboard
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: title + action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // NEW: tap to refresh charts
                InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _refreshDashboard,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.accent,
                    child: const Icon(Icons.sync, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Greeting + semicircle gauge card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Hello, Willy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your total legal knowledge status is going right now',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SemiCircleGauge(
                          progress: _gaugeProgress, // was fixed
                          backgroundColor: Colors.grey.shade300,
                          gradient: SweepGradient(
                            startAngle: math.pi,
                            endAngle: 2 * math.pi,
                            colors: [
                              Colors.green.shade300,
                              Colors.green,
                              Colors.yellow.shade600,
                              Colors.orange,
                            ],
                            stops: const [0.0, 0.35, 0.7, 1.0],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${(_gaugeProgress * 100).round()}%', // dynamic
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Total Knowledge Score',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Number of deal won card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time spent on learning',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${_timeSpentHours}hrs', // dynamic
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.arrow_upward,
                              size: 14,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '20%',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 56,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(12, (i) {
                        final h = _learningBars[i]; // dynamic
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3.0,
                            ),
                            child: Container(
                              height: h + 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppTheme.accent,
                                    Colors.greenAccent.shade200,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Recent deals header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent topics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    _circleIcon(Icons.search),
                    const SizedBox(width: 8),
                    _circleIcon(Icons.tune),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent deals list card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  _DealRow(letter: 'c', company: 'criminal law', manager: 'me'),
                  _DividerLine(),
                  _DealRow(letter: 't', company: 'taxation', manager: 'me'),
                  _DividerLine(),
                  _DealRow(letter: 'C', company: 'civil', manager: 'me'),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      );
    } else if (_selectedIndex == 2) {
      // Knowledge tab
      final media = MediaQuery.of(context);
      final halfScreen = media.size.height * 0.5;
      final viewportHeight =
          media.size.height - media.padding.top - media.padding.bottom;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: ConstrainedBox(
          // Ensure the content area is at least a full screen high
          constraints: BoxConstraints(minHeight: viewportHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // NEW: Rwanda laws link card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.gavel, color: Colors.black87),
                  title: const Text(
                    'Rwanda laws',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Open external legal resource',
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: const Icon(
                    Icons.open_in_new,
                    color: Colors.black54,
                  ),
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://rwandalii.org/akn/rw/act/law/2018/68/eng@2018-09-27',
                    );
                    final ok = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open link')),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Existing FAQ list (unchanged)
              SizedBox(
                height: halfScreen,
                child: _FaqListCard(
                  faqs: const [
                    _Faq(
                      'How do I search for a law or article?',
                      'Use the search bar on the Home tab. Type keywords like “business registration” or an article number.',
                    ),
                    _Faq(
                      'Can I filter results by category?',
                      'Yes. Use the topic chips (criminal, civil, business, etc.) to narrow your results.',
                    ),
                    _Faq(
                      'How do I chat with the legal assistant?',
                      'Tap the chat bubble in the bottom-right corner and ask your question.',
                    ),
                    _Faq(
                      'Why am I not seeing responses from the chatbot?',
                      'Ensure your API is running and the app points to the correct base URL (Android emulator uses 10.0.2.2).',
                    ),
                    _Faq(
                      'Can I save or bookmark a result?',
                      'Tap the heart icon on cards to save them for quick access later.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _refreshDashboard() {
    setState(() {
      _gaugeProgress = 0.3 + _rand.nextDouble() * 0.6; // 0.3..0.9
      _timeSpentHours = 1 + _rand.nextInt(5); // 1..5 hrs
      _learningBars = List<double>.generate(
        12,
        (_) => 16 + _rand.nextInt(44).toDouble(),
      );
    });
  }

  Widget _floatingNavBar(BuildContext context) {
    final items = const [
      (Icons.home, 'Home'),
      (Icons.bar_chart, 'Analytics'),
      (Icons.lightbulb, 'Help'),
    ];

    Color selectedColor = AppTheme.accent;
    Color unselectedColor = Colors.black54;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final (icon, label) = items[i];
            final isSelected = _selectedIndex == i;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => _onItemTapped(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? selectedColor : unselectedColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? selectedColor : unselectedColor,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false, // keep bottom bar down and fixed
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          SafeArea(child: _buildBody()),

          // Floating chat bubble (keeps existing navigation)
          Positioned(
            right: 16,
            bottom: 96 + bottomInset, // sits above the floating nav bar
            child: FloatingActionButton(
              backgroundColor: AppTheme.accent,
              onPressed: () => Navigator.pushNamed(context, '/chatbot'),
              child: const Icon(Icons.chat, color: Colors.white),
            ),
          ),

          // Floating, pill-shaped bottom navigation
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: _floatingNavBar(context),
          ),
        ],
      ),
    );
  }
}

// A placeholder carousel mimicking the big stacked cards.
// Replace its internal content with your real data later.
class _CardStackPlaceholder extends StatefulWidget {
  // NEW: optional images for the cards (asset paths or URLs)
  final List<String> images;
  const _CardStackPlaceholder({this.images = const []});

  @override
  State<_CardStackPlaceholder> createState() => _CardStackPlaceholderState();
}

class _CardStackPlaceholderState extends State<_CardStackPlaceholder> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Helper: asset or network image with safe fallback
  Widget _cardImage(String src) {
    final border = BorderRadius.circular(24);
    if (src.startsWith('http')) {
      return ClipRRect(
        borderRadius: border,
        child: Image.network(
          src,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: border,
        child: Image.asset(
          src,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images; // keep empty to use plain white cards
    final itemCount = imgs.isNotEmpty ? imgs.length : 4;

    return SizedBox(
      height: 340,
      child: PageView.builder(
        controller: _controller,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Stack(
              children: [
                // Shadow/backdrop (unchanged)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade300.withOpacity(0.25),
                          Colors.black.withOpacity(0.15),
                        ],
                      ),
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                // Foreground card with optional image
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imgs.isNotEmpty) _cardImage(imgs[index]),
                        if (imgs.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.black.withOpacity(
                                0.12,
                              ), // light tint
                            ),
                          ),
                        // Heart/favorite (unchanged)
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white70,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        // Bottom info + See more (unchanged)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'civil',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Legal',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'views',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Bottom action: See more only (removed title/subtitle/reviews)
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('See more'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Small circular icon used in the section header
Widget _circleIcon(IconData icon) {
  return Container(
    width: 36,
    height: 36,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Colors.black87, size: 20),
  );
}

// Simple divider line for list inside white cards
class _DividerLine extends StatelessWidget {
  const _DividerLine();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0x11000000));
  }
}

// Recent deal row (company + manager)
class _DealRow extends StatelessWidget {
  final String letter;
  final String company;
  final String manager;
  const _DealRow({
    required this.letter,
    required this.company,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: Text(letter, style: const TextStyle(color: Colors.black87)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              company,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  manager.isNotEmpty ? manager[0] : '?',
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(manager, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}

// Semicircle gauge as in the mock
class SemiCircleGauge extends StatelessWidget {
  final double progress; // 0..1
  final Color backgroundColor;
  final Gradient gradient;
  const SemiCircleGauge({
    super.key,
    required this.progress,
    required this.backgroundColor,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SemiCirclePainter(
        progress: progress.clamp(0.0, 1.0),
        backgroundColor: backgroundColor,
        gradient: gradient,
      ),
      size: const Size(double.infinity, 160),
    );
  }
}

class _SemiCirclePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Gradient gradient;

  _SemiCirclePainter({
    required this.progress,
    required this.backgroundColor,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 18.0;
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2 - 16, size.height - 16);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round;

    const start = math.pi;
    const totalSweep = math.pi;

    // background arc
    canvas.drawArc(rect, start, totalSweep, false, bg);
    // progress arc
    canvas.drawArc(rect, start, totalSweep * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _SemiCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gradient != gradient;
  }
}

// ExploreCardsFromAssets widget to load card data from assets
class ExploreCardsFromAssets extends StatefulWidget {
  // default dir now points to root assets/
  const ExploreCardsFromAssets({super.key, this.assetsDir = 'assets/'});
  final String assetsDir;

  @override
  State<ExploreCardsFromAssets> createState() => _ExploreCardsFromAssetsState();
}

class _ExploreCardsFromAssetsState extends State<ExploreCardsFromAssets> {
  late Future<List<String>> _cardImagesFuture;

  @override
  void initState() {
    super.initState();
    _cardImagesFuture = _loadCardImages();
  }

  Future<List<String>> _loadCardImages() async {
    // Load the JSON file from the assets
    final jsonString = await rootBundle.loadString(
      '${widget.assetsDir}cards.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);

    // Extract image URLs or asset paths
    return jsonList.map((e) => e['image'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _cardImagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final images = snapshot.data!;
          return _CardStackPlaceholder(images: images);
        }
      },
    );
  }
}

// FAQ list card widget
class _FaqListCard extends StatelessWidget {
  final List<_Faq> faqs;
  const _FaqListCard({required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // card on dark background
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        itemCount: faqs.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
        itemBuilder: (context, i) {
          final item = faqs[i];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                item.q,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconColor: Colors.black54,
              collapsedIconColor: Colors.black45,
              children: [
                Text(
                  item.a,
                  style: const TextStyle(color: Colors.black54, height: 1.35),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Faq {
  final String q;
  final String a;
  const _Faq(this.q, this.a);
}
