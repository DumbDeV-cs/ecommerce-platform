import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const RaptiNurseryApp());
}

// ==================== CONSTANTS & GLOBAL STATE ====================
const Color kGreen = Color(0xFF2D5A27);
const Color kDeepGreen = Color(0xFF1E3F1D);
const Color kBrown = Color(0xFF8B5A2B);
const Color kCream = Color(0xFFF9F6EE);
const String kWhatsapp = '9779847831731';
const String kAdminEmail = 'swetaacharya73@gmail.com';
const String kAdminPass = 'prabeshhh';
const List<String> kCategories = ['Fruit Saplings', 'Indoor Plants', 'Seeds', 'Flowering', 'Succulents'];

/// Cart badge + scroll position are shared so any screen can react to them.
final ValueNotifier<int> cartCount = ValueNotifier<int>(0);
final ValueNotifier<double> scrollTick = ValueNotifier<double>(0);
bool adminLoggedIn = false;

String rs(num v) => 'Rs. ${v.toStringAsFixed(0)}';

// ==================== APP ====================
class WebScrollBehavior extends MaterialScrollBehavior {
  const WebScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class RaptiNurseryApp extends StatelessWidget {
  const RaptiNurseryApp({super.key});

  // Real URLs: "/", "/plant/<id>", "/admin", "/admin/dashboard"
  Route<dynamic> _route(RouteSettings s) {
    final seg = Uri.parse(s.name ?? '/').pathSegments;
    Widget page = const StorefrontScreen();
    if (seg.length == 2 && seg[0] == 'plant') {
      final m = globalProducts.where((p) => p.id == seg[1]);
      if (m.isNotEmpty) page = DetailsScreen(plant: m.first);
    } else if (seg.isNotEmpty && seg[0] == 'admin') {
      page = (seg.length > 1 && seg[1] == 'dashboard' && adminLoggedIn)
          ? const AdminDashboardScreen()
          : const AdminLoginScreen();
    }
    return PageRouteBuilder(
      settings: s,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(c),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapti Nursery Tatha Banaspati Uddhan',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const WebScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kGreen,
          primary: kGreen,
          secondary: kBrown,
          surface: kCream,
        ),
        scaffoldBackgroundColor: kCream,
      ),
      onGenerateRoute: _route,
    );
  }
}

// ==================== MODELS ====================
class PlantProduct {
  String id;
  String name;
  String category;
  double priceNpr;
  int stock;
  String careNote;
  String imageUrl;
  Uint8List? imageBytes;
  String longDescription;

  PlantProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.priceNpr,
    required this.stock,
    required this.careNote,
    required this.imageUrl,
    this.imageBytes,
    this.longDescription =
        'Nurtured organically with rich soil and expert care at Rapti Nursery, Dang. Perfect for Nepali climate and soil conditions.',
  });
}

class CartItem {
  final PlantProduct product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

List<PlantProduct> globalProducts = [
  PlantProduct(
    id: 'mango1',
    name: 'Grafted Mango Plant (कलम आम)',
    category: 'Fruit Saplings',
    priceNpr: 450,
    stock: 15,
    careNote: 'Full sunlight, water moderately',
    imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?q=80&w=800',
    longDescription:
        'Healthy, high-yielding grafted mango sapling in nursery polybag. Starts fruiting earlier. Ideal for Terai and hill regions of Nepal.',
  ),
  PlantProduct(
    id: 'litchi1',
    name: 'Grafted Litchi Plant (कलम लिची)',
    category: 'Fruit Saplings',
    priceNpr: 550,
    stock: 10,
    careNote: 'Rich moist soil, partial shade when young',
    imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d691a4bf5?q=80&w=800',
    longDescription: 'Superior quality grafted litchi sapling known for sweet, juicy fruits and strong rootstock.',
  ),
  PlantProduct(
    id: 'lemon1',
    name: 'Lemon Plant (तामा कागती)',
    category: 'Fruit Saplings',
    priceNpr: 300,
    stock: 20,
    careNote: 'High sunlight, regular watering',
    imageUrl: 'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?q=80&w=800',
    longDescription: 'Fresh citrus lemon plant bearing aromatic fruits throughout the season.',
  ),
  PlantProduct(
    id: 'rose1',
    name: 'Red/Pink Rose (गुलाबको बिरुवा)',
    category: 'Flowering',
    priceNpr: 150,
    stock: 25,
    careNote: 'Morning sun, well-drained soil',
    imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=800',
    longDescription: 'Vibrant blooming rose plant adding elegance, color, and fragrance to your home garden.',
  ),
  PlantProduct(
    id: 'snake1',
    name: 'Snake Plant (सपाइ प्लान्ट)',
    category: 'Indoor Plants',
    priceNpr: 250,
    stock: 30,
    careNote: 'Low maintenance, water every 10 days',
    imageUrl: 'https://images.unsplash.com/photo-1599598425949-6f5954a7c06d?q=80&w=800',
    longDescription: 'Top air-purifying indoor plant that thrives in low light and minimal water.',
  ),
  PlantProduct(
    id: 'money1',
    name: 'Money Plant (मनी प्लान्ट)',
    category: 'Indoor Plants',
    priceNpr: 180,
    stock: 40,
    careNote: 'Indirect light, thrives in water or soil',
    imageUrl: 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?q=80&w=800',
    longDescription: 'Classic auspicious indoor foliage plant, extremely easy to maintain.',
  ),
  PlantProduct(
    id: 'seed1',
    name: 'Organic Seasonal Flower Seeds Mix',
    category: 'Seeds',
    priceNpr: 90,
    stock: 50,
    careNote: 'Sow in loose compost soil, keep moist',
    imageUrl: 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?q=80&w=800',
    longDescription: 'A premium mix of vibrant seasonal flower seeds curated for home balconies and gardens.',
  ),
  PlantProduct(
    id: 'aloe1',
    name: 'Aloe Vera (घ्यूकुमारी)',
    category: 'Succulents',
    priceNpr: 120,
    stock: 35,
    careNote: 'Minimal water, bright sunny spot',
    imageUrl: 'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?q=80&w=800',
    longDescription: 'Medicinal succulent known for soothing gel and extremely low water requirements.',
  ),
];

List<CartItem> globalCart = [];

// ==================== HELPERS ====================
void syncCart() => cartCount.value = globalCart.fold(0, (s, i) => s + i.quantity);

/// Returns an error message, or null when the item was added.
String? addToCart(PlantProduct p, {int qty = 1}) {
  if (p.stock <= 0) return '${p.name} is out of stock';
  final i = globalCart.indexWhere((c) => c.product.id == p.id);
  final current = i >= 0 ? globalCart[i].quantity : 0;
  if (current + qty > p.stock) return 'Only ${p.stock} available in stock';
  if (i >= 0) {
    globalCart[i].quantity += qty;
  } else {
    globalCart.add(CartItem(product: p, quantity: qty));
  }
  syncCart();
  return null;
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red.shade700 : kGreen,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
}

Future<void> launchExternalUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    debugPrint('Could not launch $urlString');
  }
}

void openCart(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 1000),
    builder: (_) => const CartCheckoutModal(),
  );
}

void goBack(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    Navigator.of(context).pushReplacementNamed('/');
  }
}

Widget centered(Widget child, {double max = 1200}) =>
    Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: max), child: child));

Widget buildLogoAvatar({double radius = 18}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: kGreen,
    child: ClipOval(
      child: Image.asset(
        'assets/logo.jpeg',
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.eco, color: Colors.lightGreenAccent, size: radius * 1.1),
      ),
    ),
  );
}

Widget plantImage(PlantProduct p, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  if (p.imageBytes != null) {
    return Image.memory(p.imageBytes!, width: width, height: height, fit: fit);
  }
  return Image.network(
    p.imageUrl,
    width: width,
    height: height,
    fit: fit,
    frameBuilder: (ctx, child, frame, sync) => sync
        ? child
        : AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: const Duration(milliseconds: 500), child: child),
    loadingBuilder: (ctx, child, prog) => prog == null
        ? child
        : Container(
            width: width,
            height: height,
            color: const Color(0xFFE3EDDF),
            child: const Center(
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: kGreen)),
            ),
          ),
    errorBuilder: (ctx, e, s) => Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.eco, size: 40, color: Colors.grey),
    ),
  );
}

// ==================== BOTANICAL GRAPHICS ====================
void _drawLeaf(Canvas c, Offset pos, double angle, double s, Color col) {
  c.save();
  c.translate(pos.dx, pos.dy);
  c.rotate(angle);
  final path = Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(s * 0.5, -s * 0.45, s, 0)
    ..quadraticBezierTo(s * 0.5, s * 0.45, 0, 0);
  c.drawPath(path, Paint()..color = col);
  c.drawLine(
    Offset.zero,
    Offset(s * 0.9, 0),
    Paint()
      ..color = Colors.white24
      ..strokeWidth = 1,
  );
  c.restore();
}

void _drawFlower(Canvas c, Offset p, double r, Color petal) {
  final paint = Paint()..color = petal;
  for (int i = 0; i < 5; i++) {
    final a = i * 2 * math.pi / 5;
    c.drawCircle(p + Offset(math.cos(a), math.sin(a)) * r * 0.9, r * 0.7, paint);
  }
  c.drawCircle(p, r * 0.55, Paint()..color = const Color(0xFFFFC107));
}

/// Swaying branches with leaves and blossoms for the hero corners.
class BranchPainter extends CustomPainter {
  final Animation<double> anim;
  final bool mirror;
  BranchPainter(this.anim, {this.mirror = false}) : super(repaint: anim);
  int _n = 0;

  @override
  void paint(Canvas canvas, Size size) {
    _n = 0;
    canvas.save();
    if (mirror) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final sway = math.sin(anim.value * 2 * math.pi * 10) * 0.045;
    _branch(canvas, Offset(-12, size.height * 0.04), 0.62, size.height * 0.36, 5, sway);
    _branch(canvas, Offset(-12, size.height * 0.34), 0.30, size.height * 0.30, 4, sway * 1.3);
    canvas.restore();
  }

  void _branch(Canvas c, Offset o, double ang, double len, int depth, double sway) {
    final a = ang + sway * (6 - depth);
    final e = o + Offset(math.cos(a), math.sin(a)) * len;
    c.drawLine(
      o,
      e,
      Paint()
        ..color = const Color(0xFF6D4C41)
        ..strokeWidth = depth * 1.5 + 0.8
        ..strokeCap = StrokeCap.round,
    );
    _n++;
    if (depth <= 3) {
      final col = _n.isEven ? const Color(0xFF7CB342) : const Color(0xFF558B2F);
      _drawLeaf(c, e, a + 0.9, len * 0.55 + 8, col);
      _drawLeaf(c, e, a - 0.9, len * 0.5 + 8, col.withOpacity(0.9));
    }
    if (depth == 1 && _n % 3 == 0) {
      const petals = [Color(0xFFF48FB1), Color(0xFFFFFFFF), Color(0xFFFFCC80)];
      _drawFlower(c, e, 9, petals[_n % 3 == 0 ? (_n ~/ 3) % 3 : 0]);
    }
    if (depth > 1) {
      _branch(c, e, a - 0.5, len * 0.74, depth - 1, sway);
      _branch(c, e, a + 0.45, len * 0.7, depth - 1, sway);
    }
  }

  @override
  bool shouldRepaint(covariant BranchPainter old) => old.mirror != mirror;
}

class _Particle {
  final double x, offset, phase, amp, loops, swayN, rotN, size;
  final bool leaf;
  final Color color;
  _Particle({
    required this.x,
    required this.offset,
    required this.phase,
    required this.amp,
    required this.loops,
    required this.swayN,
    required this.rotN,
    required this.size,
    required this.leaf,
    required this.color,
  });
}

final List<_Particle> _particles = List.generate(18, (i) {
  final r = math.Random(i * 11 + 5);
  const colors = [
    Color(0xFF6FBF5E),
    Color(0xFF3E8E41),
    Color(0xFFF48FB1),
    Color(0xFFFFC107),
    Color(0xFF9CCC65),
  ];
  return _Particle(
    x: r.nextDouble(),
    offset: r.nextDouble(),
    phase: r.nextDouble(),
    amp: 20 + r.nextDouble() * 40,
    loops: (1 + r.nextInt(3)).toDouble(),
    swayN: (5 + r.nextInt(5)).toDouble(),
    rotN: (2 + r.nextInt(4)).toDouble(),
    size: 8 + r.nextDouble() * 9,
    leaf: i % 3 != 0,
    color: colors[r.nextInt(colors.length)],
  );
});

/// Gently drifting leaves and petals over the whole page.
class FallingPainter extends CustomPainter {
  final Animation<double> anim;
  FallingPainter(this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    for (final p in _particles) {
      final prog = (p.offset + t * p.loops) % 1.0;
      final y = -30 + prog * (size.height + 60);
      final x = p.x * size.width + math.sin(2 * math.pi * (t * p.swayN + p.phase)) * p.amp;
      final rot = 2 * math.pi * (t * p.rotN + p.phase);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final col = p.color.withOpacity(0.4);
      if (p.leaf) {
        _drawLeaf(canvas, Offset(-p.size * 0.8, 0), 0, p.size * 1.6, col);
      } else {
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), Paint()..color = col);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant FallingPainter old) => false;
}

class WavePainter extends CustomPainter {
  final Color color;
  WavePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    for (double x = 0; x <= size.width; x += 6) {
      path.lineTo(x, size.height * 0.5 + math.sin(x / size.width * 4 * math.pi) * size.height * 0.28);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant WavePainter old) => old.color != color;
}

/// A vine that grows across the screen with leaves and blossoms.
class VinePainter extends CustomPainter {
  final double progress;
  VinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;
    final maxX = size.width * progress;
    final stem = Path()..moveTo(0, midY);
    for (double x = 0; x <= maxX; x += 4) {
      stem.lineTo(x, midY + math.sin(x / 38) * 10);
    }
    canvas.drawPath(
      stem,
      Paint()
        ..color = const Color(0xFF558B2F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    int i = 0;
    for (double x = 30; x < maxX; x += 34) {
      final y = midY + math.sin(x / 38) * 10;
      final grow = ((maxX - x) / 60).clamp(0.0, 1.0);
      final up = i.isEven;
      _drawLeaf(canvas, Offset(x, y), up ? -0.9 : 0.9, 20 * grow,
          i % 2 == 0 ? const Color(0xFF7CB342) : const Color(0xFF558B2F));
      if (i % 5 == 4 && grow > 0.5) {
        _drawFlower(canvas, Offset(x, y + (up ? -22 : 22)), 7 * grow, const Color(0xFFF48FB1));
      }
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant VinePainter old) => old.progress != progress;
}

// ==================== SCROLL-REVEAL ANIMATIONS ====================
class RevealBuilder extends StatefulWidget {
  final int delayMs;
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext, double) builder;

  const RevealBuilder({
    super.key,
    this.delayMs = 0,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    required this.builder,
  });

  @override
  State<RevealBuilder> createState() => _RevealBuilderState();
}

class _RevealBuilderState extends State<RevealBuilder> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    scrollTick.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_shown || !mounted) return;
    final ro = context.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return;
    final top = ro.localToGlobal(Offset.zero).dy;
    if (top < MediaQuery.of(context).size.height * 0.95) {
      _shown = true;
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    scrollTick.removeListener(_check);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (ctx, _) => widget.builder(ctx, widget.curve.transform(_c.value)),
    );
  }
}

class Reveal extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final Offset offset;
  const Reveal({super.key, required this.child, this.delayMs = 0, this.offset = const Offset(0, 30)});

  @override
  Widget build(BuildContext context) {
    return RevealBuilder(
      delayMs: delayMs,
      builder: (ctx, v) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(offset.dx * (1 - v), offset.dy * (1 - v)), child: child),
      ),
    );
  }
}

class GrowingVine extends StatelessWidget {
  const GrowingVine({super.key});
  @override
  Widget build(BuildContext context) {
    return RevealBuilder(
      duration: const Duration(milliseconds: 2400),
      builder: (ctx, p) => SizedBox(
        height: 60,
        width: double.infinity,
        child: CustomPaint(painter: VinePainter(p)),
      ),
    );
  }
}

class CartButton extends StatelessWidget {
  final Color color;
  const CartButton({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: cartCount,
      builder: (context, n, _) => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'View Cart',
            icon: Icon(Icons.shopping_bag_outlined, color: color),
            onPressed: () => openCart(context),
          ),
          if (n > 0)
            Positioned(
              right: 2,
              top: 2,
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                  child: Container(
                    key: ValueKey(n),
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                    child: Text('$n',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== STOREFRONT ====================
class StorefrontScreen extends StatefulWidget {
  const StorefrontScreen({super.key});

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final GlobalKey _shopKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  String _category = 'All';
  String _query = '';
  bool _solidNav = false;
  bool _showTop = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final o = _scroll.offset;
    scrollTick.value = o;
    final solid = o > 40;
    final top = o > 600;
    if (solid != _solidNav || top != _showTop) {
      setState(() {
        _solidNav = solid;
        _showTop = top;
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _goTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic);
    }
  }

  void _goTop() =>
      _scroll.animateTo(0, duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final wide = w >= 860;
    final narrow = w < 600;

    return Scaffold(
      backgroundColor: kCream,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedScale(
            scale: _showTop ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: FloatingActionButton.small(
              heroTag: 'top',
              backgroundColor: kBrown,
              foregroundColor: Colors.white,
              tooltip: 'Back to top',
              onPressed: _goTop,
              child: const Icon(Icons.keyboard_arrow_up),
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'wa',
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            tooltip: 'Chat on WhatsApp',
            onPressed: () => launchExternalUrl(
                'https://wa.me/$kWhatsapp?text=Hello%20Rapti%20Nursery,%20I%20would%20like%20to%20visit%20or%20order%20plants.'),
            child: const Icon(Icons.chat),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                _hero(w, narrow),
                _shopSection(narrow),
                const GrowingVine(),
                _aboutSection(narrow),
                const SizedBox(height: 30),
                _footer(narrow),
              ],
            ),
          ),
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: FallingPainter(_anim)))),
          Positioned(top: 0, left: 0, right: 0, child: _navBar(w, wide, narrow)),
        ],
      ),
    );
  }

  // ---------- Navigation bar ----------
  Widget _navLink(String label, VoidCallback onTap) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        child: Text(label),
      );

  Widget _navBar(double w, bool wide, bool narrow) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _solidNav ? kGreen.withOpacity(0.97) : Colors.transparent,
        boxShadow: _solidNav ? const [BoxShadow(color: Colors.black26, blurRadius: 12)] : const [],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: narrow ? 8 : 28, vertical: 8),
          child: Row(
            children: [
              Flexible(
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: _goTop,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildLogoAvatar(radius: 17),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          w >= 700 ? 'Rapti Nursery Tatha Banaspati Uddhan' : 'Rapti Nursery',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (wide) ...[
                _navLink('Home', _goTop),
                _navLink('Shop', () => _goTo(_shopKey)),
                _navLink('About', () => _goTo(_aboutKey)),
                _navLink('Contact', () => _goTo(_contactKey)),
                const SizedBox(width: 8),
              ] else
                PopupMenuButton<int>(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  tooltip: 'Menu',
                  onSelected: (v) {
                    if (v == 0) _goTop();
                    if (v == 1) _goTo(_shopKey);
                    if (v == 2) _goTo(_aboutKey);
                    if (v == 3) _goTo(_contactKey);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 0, child: Text('Home')),
                    PopupMenuItem(value: 1, child: Text('Shop')),
                    PopupMenuItem(value: 2, child: Text('About')),
                    PopupMenuItem(value: 3, child: Text('Contact')),
                  ],
                ),
              const CartButton(),
              if (wide)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white60),
                    color: Colors.black26,
                  ),
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/admin'),
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.lightGreenAccent, size: 16),
                    label: const Text('Owner Portal', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                )
              else
                IconButton(
                  tooltip: 'Owner Portal',
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.lightGreenAccent),
                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Hero ----------
  Widget _hero(double w, bool narrow) {
    final bw = math.min(w * 0.55, 460.0);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: narrow ? 580 : 660),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kDeepGreen, kGreen, Color(0xFF4A8F3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              width: bw,
              height: bw * 0.9,
              child: IgnorePointer(child: CustomPaint(painter: BranchPainter(_anim)))),
          Positioned(
              top: 0,
              right: 0,
              width: bw,
              height: bw * 0.9,
              child: IgnorePointer(child: CustomPaint(painter: BranchPainter(_anim, mirror: true)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
            child: centered(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Reveal(
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, child) =>
                          Transform.translate(offset: Offset(0, math.sin(_anim.value * 2 * math.pi * 10) * 7), child: child),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.lightGreenAccent.withOpacity(0.35), blurRadius: 40)],
                        ),
                        child: buildLogoAvatar(radius: 52),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Reveal(
                    delayMs: 150,
                    child: Text(
                      'Grow Green, Live Serene 🌿',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: narrow ? 30 : 46,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Reveal(
                    delayMs: 300,
                    child: Text(
                      'Authentic Saplings, Indoor Plants & Seeds from Dang, Nepal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: narrow ? 15 : 18, color: Colors.white70, fontWeight: FontWeight.w300),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Reveal(
                    delayMs: 450,
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _goTo(_shopKey),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: kGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          icon: const Icon(Icons.local_florist),
                          label: const Text('Shop Plants'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _goTo(_contactKey),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          icon: const Icon(Icons.location_on_outlined),
                          label: const Text('Visit Us'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: 56,
            child: CustomPaint(painter: WavePainter(kCream)),
          ),
        ],
      ),
    );
  }

  // ---------- Shop ----------
  Widget _shopSection(bool narrow) {
    final q = _query.trim().toLowerCase();
    final list = globalProducts
        .where((p) => (_category == 'All' || p.category == _category) && (q.isEmpty || p.name.toLowerCase().contains(q)))
        .toList();
    final pad = narrow ? 16.0 : 32.0;
    final cats = ['All', ...kCategories];

    return Container(
      key: _shopKey,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(pad, 70, pad, 30),
      child: centered(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Reveal(
              child: const Row(
                children: [
                  Icon(Icons.local_florist, color: kBrown),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text('Explore Plant Categories',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kGreen)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Reveal(
              delayMs: 100,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search plants…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Reveal(
              delayMs: 180,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: cats.map((cat) {
                    final sel = _category == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: sel,
                        showCheckmark: false,
                        selectedColor: kGreen,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                        onSelected: (_) => setState(() => _category = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text('$_category (${list.length})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kBrown)),
            const SizedBox(height: 4),
            const Text('Tap a plant for details & quick buy', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 56, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No plants found. Try a different search or category.',
                          style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 390,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) => Reveal(
                  key: ValueKey(list[i].id),
                  delayMs: (i % 4) * 90,
                  offset: const Offset(0, 40),
                  child: PlantCard(plant: list[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- About ----------
  Widget _aboutSection(bool narrow) {
    Widget card(IconData icon, String title, String text, int delay) => Reveal(
          delayMs: delay,
          child: Container(
            width: 330,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 26, backgroundColor: kGreen.withOpacity(0.12), child: Icon(icon, color: kGreen)),
                const SizedBox(height: 14),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kGreen)),
                const SizedBox(height: 8),
                Text(text, style: const TextStyle(color: Colors.black87, height: 1.5)),
              ],
            ),
          ),
        );

    return Container(
      key: _aboutKey,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(narrow ? 16 : 32, 30, narrow ? 16 : 32, 20),
      child: centered(
        Column(
          children: [
            const Reveal(
              child: Text('Why Rapti Nursery',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: kBrown), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                card(Icons.eco, 'Grown in Dang', 'Saplings, indoor plants and seeds nurtured with care for Nepali climate and soil.', 0),
                card(Icons.wb_sunny_outlined, 'Care guidance', 'Every plant comes with expert care notes so you know how to help it thrive.', 120),
                card(Icons.chat_bubble_outline, 'Order on WhatsApp', 'Build your cart, add your delivery details and confirm your order in one tap.', 240),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Footer / Contact ----------
  Widget _footer(bool narrow) {
    final tileW = math.min(310.0, MediaQuery.of(context).size.width - 80);
    return Container(
      key: _contactKey,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(narrow ? 20 : 40, 44, narrow ? 20 : 40, 24),
      decoration: const BoxDecoration(
        color: kGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: centered(
        Reveal(
          child: Column(
            children: [
              buildLogoAvatar(radius: 30),
              const SizedBox(height: 15),
              const Text('Rapti Nursery Tatha Banaspati Uddhan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              const Text(
                'Visit our physical nursery or reach out for bulk orders, landscaping consultation, and plant care advice.',
                style: TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _InfoTile(width: tileW, icon: Icons.location_on, title: 'Location', subtitle: 'Dang, Nepal'),
                  _InfoTile(width: tileW, icon: Icons.phone_callback, title: 'Direct Line', subtitle: '+977 9847831731'),
                  _InfoTile(width: tileW, icon: Icons.schedule, title: 'Opening Hours', subtitle: 'Sun - Sat: 7:00 AM - 6:00 PM'),
                ],
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => launchExternalUrl(
                        'https://wa.me/$kWhatsapp?text=Hello%20Rapti%20Nursery,%20I%20would%20like%20to%20visit%20or%20order%20plants.'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: kGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp Chat'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => launchExternalUrl('https://www.tiktok.com/@raptinursery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.video_library),
                    label: const Text('TikTok @raptinursery'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              const Text('© Rapti Nursery Tatha Banaspati Uddhan',
                  style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double width;

  const _InfoTile({required this.icon, required this.title, required this.subtitle, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.lightGreenAccent, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PLANT CARD ====================
class PlantCard extends StatefulWidget {
  final PlantProduct plant;
  const PlantCard({super.key, required this.plant});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  bool _hover = false;
  bool _added = false;

  void _add() {
    final err = addToCart(widget.plant);
    if (err != null) {
      showSnack(context, err, error: true);
      return;
    }
    setState(() => _added = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _added = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plant;
    final out = p.stock <= 0;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/plant/${p.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
          transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hover ? 0.18 : 0.08),
                blurRadius: _hover ? 22 : 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'plant_hero_${p.id}',
                        child: AnimatedScale(
                          scale: _hover ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          child: plantImage(p),
                        ),
                      ),
                      if (out)
                        Container(
                          color: Colors.black54,
                          alignment: Alignment.center,
                          child: const Text('OUT OF STOCK',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        )
                      else if (p.stock <= 5)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.shade700, borderRadius: BorderRadius.circular(12)),
                            child: Text('Only ${p.stock} left',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.category.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: kBrown, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(p.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(rs(p.priceNpr),
                        style: const TextStyle(fontSize: 17, color: kGreen, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: out ? null : _add,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _added ? Colors.green.shade700 : kGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Row(
                            key: ValueKey('$_added$out'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_added ? Icons.check : Icons.add_shopping_cart, size: 15),
                              const SizedBox(width: 6),
                              Text(out ? 'Out of stock' : (_added ? 'Added' : 'Add to Cart')),
                            ],
                          ),
                        ),
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
  }
}

// ==================== CART & CHECKOUT MODAL ====================
class CartCheckoutModal extends StatefulWidget {
  const CartCheckoutModal({super.key});

  @override
  State<CartCheckoutModal> createState() => _CartCheckoutModalState();
}

class _CartCheckoutModalState extends State<CartCheckoutModal> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _total => globalCart.fold(0, (s, i) => s + i.product.priceNpr * i.quantity);

  void _checkoutWhatsApp() {
    if (globalCart.isEmpty) return;
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in your name, delivery address, and phone number!'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    String message = '🌿 *New Order - Rapti Nursery* 🌿\n\n';
    message += '👤 *Customer:* ${_nameController.text.trim()}\n';
    message += '📍 *Address:* ${_addressController.text.trim()}\n';
    message += '📞 *Phone:* ${_phoneController.text.trim()}\n\n';
    message += '🛒 *Order Items:*\n';
    for (var item in globalCart) {
      message += '• ${item.product.name} (x${item.quantity}) - ${rs(item.product.priceNpr * item.quantity)}\n';
    }
    message += '\n💰 *Total Amount:* ${rs(_total)}\n';
    message += '🙏 Please confirm my order!';
    launchExternalUrl('https://wa.me/$kWhatsapp?text=${Uri.encodeComponent(message)}');
  }

  List<Widget> _items() {
    return List.generate(globalCart.length, (index) {
      final item = globalCart[index];
      final p = item.product;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: plantImage(p, width: 56, height: 56)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${rs(p.priceNpr)} x ${item.quantity} = ${rs(p.priceNpr * item.quantity)}',
                      style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.remove_circle_outline, size: 22),
              onPressed: () {
                setState(() {
                  if (item.quantity > 1) {
                    item.quantity--;
                  } else {
                    globalCart.removeAt(index);
                  }
                });
                syncCart();
              },
            ),
            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline, size: 22),
              onPressed: item.quantity < p.stock
                  ? () {
                      setState(() => item.quantity++);
                      syncCart();
                    }
                  : null,
            ),
          ],
        ),
      );
    });
  }

  Widget _panel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Delivery Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kBrown)),
          const SizedBox(height: 15),
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Delivery Address (City / Area)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(rs(_total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kGreen)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _checkoutWhatsApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.chat),
              label: const Text('Confirm Order via WhatsApp'),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                setState(() => globalCart.clear());
                syncCart();
              },
              child: const Text('Clear cart', style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 720;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        padding: EdgeInsets.all(narrow ? 16 : 24),
        decoration: const BoxDecoration(
          color: kCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text('Your Plant Cart & Checkout',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kGreen)),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: globalCart.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Your cart is empty. Add plants to begin checkout!',
                              style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : narrow
                      ? ListView(children: [..._items(), const SizedBox(height: 8), _panel()])
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: ListView(children: _items())),
                            const SizedBox(width: 24),
                            Expanded(flex: 2, child: SingleChildScrollView(child: _panel())),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DETAILS SCREEN ====================
class DetailsScreen extends StatefulWidget {
  final PlantProduct plant;
  const DetailsScreen({super.key, required this.plant});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();
  final ScrollController _scroll = ScrollController();
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => scrollTick.value = _scroll.offset);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _anim.dispose();
    super.dispose();
  }

  Widget _circleButton(Widget child) =>
      Material(color: Colors.black45, shape: const CircleBorder(), clipBehavior: Clip.antiAlias, child: child);

  Widget _qtyControl(PlantProduct p) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
          ),
          SizedBox(
            width: 28,
            child: Text('$_qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _qty < p.stock ? () => setState(() => _qty++) : null,
          ),
        ],
      ),
    );
  }

  Widget _info(bool wide) {
    final p = widget.plant;
    final out = p.stock <= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          child: Text(p.category.toUpperCase(),
              style: const TextStyle(fontSize: 12, color: kBrown, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 10),
        Reveal(
          delayMs: 80,
          child: Text(p.name, style: TextStyle(fontSize: wide ? 38 : 30, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        Reveal(
          delayMs: 160,
          child: Row(
            children: [
              Text(rs(p.priceNpr), style: const TextStyle(fontSize: 30, color: kGreen, fontWeight: FontWeight.w900)),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: (out ? Colors.red : Colors.green).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(out ? 'Out of stock' : (p.stock <= 5 ? 'Only ${p.stock} left' : 'In stock'),
                    style: TextStyle(
                        color: out ? Colors.red.shade700 : Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Divider(),
        const SizedBox(height: 14),
        Reveal(
          delayMs: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('About this Plant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(p.longDescription, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Reveal(
          delayMs: 320,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightGreenAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.lightGreen),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: kGreen),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expert Care Instructions', style: TextStyle(fontWeight: FontWeight.bold, color: kGreen)),
                      const SizedBox(height: 4),
                      Text(p.careNote, style: const TextStyle(color: Colors.black87, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        if (!out)
          Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _qtyControl(p),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final err = addToCart(p, qty: _qty);
                    showSnack(context, err ?? 'Added $_qty × ${p.name} to cart 🌿', error: err != null);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: out
                ? null
                : () {
                    final message =
                        '🌿 *Direct Order - Rapti Nursery* 🌿\n\n• Plant: ${p.name}\n• Quantity: $_qty\n• Total: ${rs(p.priceNpr * _qty)}\n\nPlease confirm my order!';
                    launchExternalUrl('https://wa.me/$kWhatsapp?text=${Uri.encodeComponent(message)}');
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: kGreen,
              side: const BorderSide(color: kGreen, width: 1.5),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            icon: const Icon(Icons.chat),
            label: const Text('Order Instantly via WhatsApp'),
          ),
        ),
      ],
    );
  }

  Widget _related(double pad) {
    final p = widget.plant;
    final list = globalProducts.where((x) => x.category == p.category && x.id != p.id).toList();
    if (list.isEmpty) return const SizedBox.shrink();
    return centered(
      Padding(
        padding: EdgeInsets.fromLTRB(pad, 40, pad, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Reveal(
              child: Text('You may also like',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kBrown)),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, i) {
                  final x = list[i];
                  return Reveal(
                    delayMs: i * 90,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pushReplacementNamed(context, '/plant/${x.id}'),
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: plantImage(x),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(x.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(rs(x.priceNpr), style: const TextStyle(color: kGreen, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plant;
    final w = MediaQuery.of(context).size.width;
    final wide = w >= 900;
    final pad = wide ? 40.0 : 20.0;

    final Widget body = wide
        ? centered(
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 100, pad, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'plant_hero_${p.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: AspectRatio(aspectRatio: 1, child: plantImage(p)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(child: _info(true)),
                ],
              ),
            ),
          )
        : Column(
            children: [
              SizedBox(height: 400, width: double.infinity, child: Hero(tag: 'plant_hero_${p.id}', child: plantImage(p))),
              Transform.translate(
                offset: const Offset(0, -36),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(pad),
                  decoration: const BoxDecoration(
                    color: kCream,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: _info(false),
                ),
              ),
            ],
          );

    return Scaffold(
      backgroundColor: kCream,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                body,
                _related(pad),
                const SizedBox(height: 60),
              ],
            ),
          ),
          Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: FallingPainter(_anim)))),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _circleButton(IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => goBack(context),
                    )),
                    _circleButton(const CartButton()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ADMIN LOGIN ====================
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_emailController.text.trim() == kAdminEmail && _passwordController.text.trim() == kAdminPass) {
      adminLoggedIn = true;
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
    } else {
      setState(() => _errorMessage = 'Invalid credentials!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Portal'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => goBack(context)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Reveal(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildLogoAvatar(radius: 35),
                  const SizedBox(height: 15),
                  const Text('Rapti Nursery Owner Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Admin Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ],
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreen,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => goBack(context),
                    child: const Text('Back to Storefront', style: TextStyle(color: kBrown)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ADMIN DASHBOARD ====================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  void _addNewProductDialog() {
    final nameCtrl = TextEditingController();
    String categoryVal = kCategories.first;
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final careCtrl = TextEditingController();
    final longDescCtrl = TextEditingController();
    Uint8List? pickedImageBytes;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Plant Listing'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Plant Name', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: categoryVal,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: kCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => categoryVal = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                            controller: priceCtrl,
                            decoration: const InputDecoration(labelText: 'Price (NPR)', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                            controller: stockCtrl,
                            decoration: const InputDecoration(labelText: 'Stock Qty', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                      controller: careCtrl,
                      decoration: const InputDecoration(labelText: 'Care Notes', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(
                      controller: longDescCtrl,
                      decoration: const InputDecoration(labelText: 'Long Description', border: OutlineInputBorder()),
                      maxLines: 2),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 15,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setDialogState(() => pickedImageBytes = bytes);
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text('Select Image from Device'),
                      ),
                      if (pickedImageBytes != null)
                        const Text('Image Selected! ✅', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                      else
                        const Text('No image chosen', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) {
                  showSnack(context, 'Please enter a plant name.', error: true);
                  return;
                }
                setState(() {
                  globalProducts.add(PlantProduct(
                    id: 'new_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    category: categoryVal,
                    priceNpr: double.tryParse(priceCtrl.text) ?? 100,
                    stock: int.tryParse(stockCtrl.text) ?? 10,
                    careNote: careCtrl.text.trim().isEmpty ? 'Water regularly and keep in good light' : careCtrl.text.trim(),
                    imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?q=80&w=800',
                    imageBytes: pickedImageBytes,
                    longDescription: longDescCtrl.text.trim().isNotEmpty
                        ? longDescCtrl.text.trim()
                        : 'A healthy plant ready for your garden.',
                  ));
                });
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.white),
              child: const Text('Save Plant'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(int index) async {
    final plant = globalProducts[index];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('Remove "${plant.name}" from the store?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        globalCart.removeWhere((c) => c.product.id == plant.id);
        globalProducts.removeAt(index);
      });
      syncCart();
    }
  }

  Widget _stat(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final totalStock = globalProducts.fold(0, (sum, p) => sum + p.stock);
    final narrow = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        title: const Text('Owner Dashboard - Rapti Nursery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              adminLoggedIn = false;
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewProductDialog,
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add New Plant'),
      ),
      body: centered(
        Padding(
          padding: EdgeInsets.all(narrow ? 16 : 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _stat('Total Varieties', '${globalProducts.length}', kGreen),
                  const SizedBox(width: 16),
                  _stat('Total Stock Units', '$totalStock', kBrown),
                ],
              ),
              const SizedBox(height: 26),
              const Text('Manage Store Inventory',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kBrown)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90),
                  itemCount: globalProducts.length,
                  itemBuilder: (context, index) {
                    final plant = globalProducts[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: plantImage(plant, width: 64, height: 64)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('${plant.category} | ${rs(plant.priceNpr)}',
                                      style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text('Stock:', style: TextStyle(fontSize: 13)),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                                        onPressed: plant.stock > 0 ? () => setState(() => plant.stock--) : null,
                                      ),
                                      Text('${plant.stock}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        onPressed: () => setState(() => plant.stock++),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () => _confirmDelete(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}