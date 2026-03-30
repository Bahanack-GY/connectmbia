import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../consultation/consultation_screen.dart';
import '../notifications/notifications_screen.dart';
import 'service_detail_screen.dart';
import '../../core/theme/app_theme.dart';


// ─── Home Screen ────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      extendBodyBehindAppBar: true,
      appBar: const HomeGlassAppBar(),
      body: const HomeBody(),
    );
  }
}

// ─── Glass App Bar (public — used by MainScreen for home tab) ────────────────
class HomeGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeGlassAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppTheme.obsidian.withValues(alpha: 0.55),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo ring
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.gold, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withValues(alpha: 0.25),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/img2.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Brand name
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect Mbia',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'CONSULTING',
                          style: GoogleFonts.inter(
                            color: AppTheme.gold,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.5,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Notification button
                    _IconBtn(
                      icon: Icons.notifications_outlined,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white70, size: 24),
    );
  }
}

// ─── Home Body ───────────────────────────────────────────────────────────────
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _slides = [
    {
      'image': 'assets/img1.jpeg',
      'title': 'Expertise &\nExcellence',
      'features': ['Conseil Stratégique', 'Réseau International'],
    },
    {
      'image': 'assets/img2.jpeg',
      'title': 'Vision &\nPerformance',
      'features': ['Mentorat Sportif', 'Gestion de Carrière'],
    },
    {
      'image': 'assets/img3.jpeg',
      'title': 'Engagement &\nAvenir',
      'features': ['Investissement BTP', 'Philanthropie'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            const SizedBox(height: 28),
            _buildTrustBand(),
            const SizedBox(height: 36),
            _buildExpertiseGrid(context),
            const SizedBox(height: 16),
            _buildCtaCard(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── Hero Slider ────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.62,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, i) => _buildSlide(_slides[i]),
          ),
          // Bottom fade
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.obsidian],
                ),
              ),
            ),
          ),
          // Slide indicators
          Positioned(
            bottom: 26,
            left: 0,
            right: 0,
            child: _buildIndicators(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(Map<String, dynamic> item) {
    final features = item['features'] as List<String>;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo
        Image.asset(
          item['image'] as String,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
        // Gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 0.75, 1.0],
              colors: [
                Color(0x00000000),
                Color(0x33000000),
                Color(0xBB000000),
                Color(0xFF080C18),
              ],
            ),
          ),
        ),
        // Content
        Positioned(
          bottom: 60,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Headline
              Text(
                item['title'] as String,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Gold divider
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.gold, Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 14),
              // Features
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        f,
                        style: GoogleFonts.inter(
                          color: const Color(0xCCFFFFFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 28 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppTheme.gold : AppTheme.textMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // ── Trust & Authority Band ──────────────────────────────────────────────────
  Widget _buildTrustBand() {
    final metrics = [
      {'value': '3', 'label': 'Continents\nActifs'},
      {'value': '20+', 'label': 'Ans\nd\'Expertise'},
      {'value': '50K+', 'label': 'Vies\nImpactées'},
      {'value': '15+', 'label': 'Clubs\nPartenaires'},
      {'value': '8', 'label': 'Pays\nAfricains'},
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: metrics.length,
        separatorBuilder: (_, _) => Container(
          width: 1,
          margin: const EdgeInsets.symmetric(vertical: 16),
          color: AppTheme.dividerDark,
        ),
        itemBuilder: (_, i) {
          final m = metrics[i];
          return Container(
            width: 96,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  m['value']!,
                  style: GoogleFonts.playfairDisplay(
                    color: AppTheme.gold,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  m['label']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Core Expertise Grid ─────────────────────────────────────────────────────
  Widget _buildExpertiseGrid(BuildContext context) {
    final cards = [
      {
        'title': 'Affaires Publiques\n& Lobbying',
        'image': 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?auto=format&fit=crop&q=80&w=600',
        'accent': const Color(0xFF3B82F6),
        'tag': '01',
        'detail': ServiceDetailScreen(
          title: 'Affaires Publiques & Lobbying',
          subtitle: 'Diplomatie & Influence',
          description:
              'Naviguez les sphères du pouvoir avec expertise. Nous vous représentons auprès des institutions internationales, gouvernements et organismes de régulation pour faire valoir vos intérêts stratégiques.',
          imageUrl:
              'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?auto=format&fit=crop&q=80&w=400',
          color: Color(0xFFEFF6FF),
          iconColor: Color(0xFF3B82F6),
          serviceId: 'business',
        ),
      },
      {
        'title': 'Infrastructure\n& BTP',
        'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=600',
        'accent': AppTheme.gold,
        'tag': '02',
        'detail': ServiceDetailScreen(
          title: 'Infrastructure & BTP',
          subtitle: 'Construction & Développement',
          description:
              'Développez des projets d\'infrastructure de grande envergure. De la conception à la livraison, nous gérons vos projets de construction avec excellence et rigueur.',
          imageUrl:
              'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=400',
          color: Color(0xFFFFF8E1),
          iconColor: Color(0xFFD4AF37),
          serviceId: 'real_estate',
        ),
      },
      {
        'title': 'Capital-Risque\n& Entrepreneuriat',
        'image': 'https://images.unsplash.com/photo-1559136555-9303baea8ebd?auto=format&fit=crop&q=80&w=600',
        'accent': const Color(0xFF10B981),
        'tag': '03',
        'detail': ServiceDetailScreen(
          title: 'Capital-Risque & Entrepreneuriat',
          subtitle: 'Innovation & Croissance',
          description:
              'Identifiez et financez les startups africaines à fort potentiel. Nous structurons vos investissements en capital-risque et accompagnons les entrepreneurs dans leur développement.',
          imageUrl:
              'https://images.unsplash.com/photo-1559136555-9303baea8ebd?auto=format&fit=crop&q=80&w=400',
          color: Color(0xFFECFDF5),
          iconColor: Color(0xFF10B981),
          serviceId: 'business',
        ),
      },
      {
        'title': 'Conseil\nExécutif',
        'image': 'https://images.unsplash.com/photo-1553877522-43269d4ea984?auto=format&fit=crop&q=80&w=600',
        'accent': const Color(0xFFAB47BC),
        'tag': '04',
        'detail': ServiceDetailScreen(
          title: 'Conseil Exécutif',
          subtitle: 'Stratégie & Leadership',
          description:
              'Bénéficiez d\'un accès direct à l\'expertise de Stéphane Mbia pour vos décisions stratégiques de haut niveau. Un accompagnement exclusif pour dirigeants et organisations d\'élite.',
          imageUrl:
              'https://images.unsplash.com/photo-1553877522-43269d4ea984?auto=format&fit=crop&q=80&w=400',
          color: Color(0xFFF3E5F5),
          iconColor: Color(0xFF9C27B0),
          serviceId: 'business',
        ),
      },
      {
        'title': 'Gestion Patrimoine\nSportif',
        'image': 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=600',
        'accent': const Color(0xFFF59E0B),
        'tag': '05',
        'detail': ServiceDetailScreen(
          title: 'Gestion Patrimoine Sportif',
          subtitle: 'Protection & Valorisation',
          description:
              'Sécurisez et faites fructifier le patrimoine généré par votre carrière sportive. Planification financière, diversification des actifs et protection du capital sur le long terme.',
          imageUrl:
              'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=400',
          color: Color(0xFFFFF8E1),
          iconColor: Color(0xFFF59E0B),
          serviceId: 'foot',
        ),
      },
      {
        'title': 'Fondation\n& Philanthropie',
        'image': 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?auto=format&fit=crop&q=80&w=600',
        'accent': const Color(0xFF34D399),
        'tag': '06',
        'detail': ServiceDetailScreen(
          title: 'Fondation & Philanthropie',
          subtitle: 'Impact & Héritage',
          description:
              'Construisez un héritage durable. Nous structurons et gérons votre fondation pour maximiser l\'impact de vos actions philanthropiques en Afrique et dans le monde.',
          imageUrl:
              'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?auto=format&fit=crop&q=80&w=400',
          color: Color(0xFFECFDF5),
          iconColor: Color(0xFF34D399),
          serviceId: 'charity',
        ),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                'Domaines\nd\'Excellence',
                style: GoogleFonts.playfairDisplay(
                  color: AppTheme.gold,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.92,
            ),
            itemCount: cards.length,
            itemBuilder: (ctx, i) => _buildExpertiseCard(
              context: ctx,
              card: cards[i],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpertiseCard({
    required BuildContext context,
    required Map<String, dynamic> card,
  }) {
    final accent = card['accent'] as Color;
    final detail = card['detail'] as ServiceDetailScreen;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => detail),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              card['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppTheme.surface),
            ),
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            // Accent color tint at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      accent.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  // Title
                  Text(
                    card['title'] as String,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  // Bottom arrow line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: accent == AppTheme.gold ? AppTheme.goldLight : accent,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CTA Card ────────────────────────────────────────────────────────────────
  Widget _buildCtaCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2540), Color(0xFF0F1525)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gold.withValues(alpha: 0.06),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONSULTATION',
                    style: GoogleFonts.inter(
                      color: AppTheme.gold.withValues(alpha: 0.85),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prenez rendez-vous\navec Stéphane',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConsultationScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Réserver',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF080C18),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Color(0xFF080C18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Avatar stack
            SizedBox(
              width: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildAvatarRing('assets/img3.jpeg', 0),
                  Positioned(
                    top: -10,
                    left: 16,
                    child: _buildAvatarRing('assets/img1.jpeg', 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarRing(String asset, int z) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: z == 0 ? AppTheme.gold : AppTheme.obsidian,
          width: z == 0 ? 1.5 : 2.5,
        ),
      ),
      child: ClipOval(
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
