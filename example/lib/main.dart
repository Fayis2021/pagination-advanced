
import 'package:flutter/material.dart';
import 'package:pagination_advanced/pagination_advanced.dart';

void main() {
  runApp(const PaginationDemoApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// Mock data model
// ─────────────────────────────────────────────────────────────────────────────

class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final Color color;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.color,
  });
}

const _categories = ['Electronics', 'Clothing', 'Books', 'Home', 'Sports'];
final _colors = [
  const Color(0xFF6C63FF),
  const Color(0xFFFF6584),
  const Color(0xFF43C6AC),
  const Color(0xFFF8B500),
  const Color(0xFFFF7043),
];

List<Product> _generateProducts(int page, {String search = '', String category = ''}) {
  final all = List.generate(20, (i) {
    final id = (page - 1) * 20 + i + 1;
    return Product(
      id: id,
      name: 'Product #$id',
      category: _categories[id % _categories.length],
      price: (id * 7.99) % 200 + 9.99,
      color: _colors[id % _colors.length],
    );
  });

  var filtered = all;
  if (search.isNotEmpty) {
    filtered = filtered
        .where((p) => p.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }
  if (category.isNotEmpty) {
    filtered = filtered.where((p) => p.category == category).toList();
  }
  return filtered;
}

// ─────────────────────────────────────────────────────────────────────────────
// App root
// ─────────────────────────────────────────────────────────────────────────────

class PaginationDemoApp extends StatelessWidget {
  const PaginationDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Advanced Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home / tab switcher
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _tabs = const [
    _Tab(label: 'List Shimmer', icon: Icons.list_alt_rounded),
    _Tab(label: 'Grid Skeleton', icon: Icons.grid_view_rounded),
    _Tab(label: 'Search', icon: Icons.search_rounded),
    _Tab(label: 'Error Retry', icon: Icons.warning_amber_rounded),
  ];

  final _pages = const [
    ListShimmerDemo(),
    GridSkeletonDemo(),
    SearchFilterDemo(),
    ErrorRetryDemo(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  const _Tab({required this.label, required this.icon});
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 – List with shimmer loading + pull-to-refresh + end-of-list message
// ─────────────────────────────────────────────────────────────────────────────

class ListShimmerDemo extends StatelessWidget {
  const ListShimmerDemo({super.key});

  Future<PaginationResult<Product>> _fetch(PaginationQuery query) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final page = query.page ?? 1;
    return PaginationResult(
      items: _generateProducts(page),
      hasMore: page < 5,
      totalCount: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List + Shimmer'),
        centerTitle: true,
      ),
      body: PaginatedListView<Product>(
        fetch: _fetch,
        // ── Loading type ──────────────────────────────────────────────
        loadingType: PaginationLoadingType.shimmer,
        // ── Colors ───────────────────────────────────────────────────
        shimmerBaseColor: Colors.grey.shade300,
        shimmerHighlightColor: Colors.grey.shade100,
        // ── Refresh ───────────────────────────────────────────────────
        enableRefresh: true,
        refreshIndicatorColor: const Color(0xFF6C63FF),
        // ── Layout ───────────────────────────────────────────────────
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        // ── End of list ───────────────────────────────────────────────
        endOfListBuilder: (context) => const _EndOfListBanner(),
        // ── Item ─────────────────────────────────────────────────────
        itemBuilder: (context, product) => _ProductListTile(product: product),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 – Grid with skeleton loading + custom loadingMoreBuilder
// ─────────────────────────────────────────────────────────────────────────────

class GridSkeletonDemo extends StatelessWidget {
  const GridSkeletonDemo({super.key});

  Future<PaginationResult<Product>> _fetch(PaginationQuery query) async {
    await Future.delayed(const Duration(milliseconds: 1800));
    final page = query.page ?? 1;
    return PaginationResult(
      items: _generateProducts(page),
      hasMore: page < 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid + Skeleton'),
        centerTitle: true,
      ),
      body: PaginatedGridView<Product>(
        fetch: _fetch,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        // ── Loading type ──────────────────────────────────────────────
        loadingType: PaginationLoadingType.shimmer,
        shimmerBaseColor: Colors.grey.shade300,
        shimmerHighlightColor: Colors.grey.shade100,
        // ── Layout ───────────────────────────────────────────────────
        padding: const EdgeInsets.all(16),
        // ── Custom "loading more" footer ──────────────────────────────
        loadingMoreBuilder: (context) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading more products…'),
              ],
            ),
          ),
        ),
        // ── End of list ───────────────────────────────────────────────
        endOfListBuilder: (context) => const _EndOfListBanner(),
        // ── Item ─────────────────────────────────────────────────────
        itemBuilder: (context, product) => _ProductGridCard(product: product),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 – Search + filter + linear loading type
// ─────────────────────────────────────────────────────────────────────────────

class SearchFilterDemo extends StatefulWidget {
  const SearchFilterDemo({super.key});

  @override
  State<SearchFilterDemo> createState() => _SearchFilterDemoState();
}

class _SearchFilterDemoState extends State<SearchFilterDemo> {
  late final PaginationController<Product> _controller;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _controller = PaginationController<Product>(fetch: _fetch);
  }

  Future<PaginationResult<Product>> _fetch(PaginationQuery query) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final page = query.page ?? 1;
    final search = query.searchQuery ?? '';
    final category = (query.filters?['category'] as String?) ?? '';
    final items = _generateProducts(page, search: search, category: category);
    return PaginationResult(items: items, hasMore: page < 5, totalCount: 100);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search + Filter'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products…',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _controller.search('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) {
                    setState(() {});
                    _controller.search(v);
                  },
                ),
                const SizedBox(height: 8),
                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _selectedCategory.isEmpty,
                        onTap: () {
                          setState(() => _selectedCategory = '');
                          _controller.applyFilter({'category': ''});
                        },
                      ),
                      ..._categories.map((c) => _FilterChip(
                            label: c,
                            selected: _selectedCategory == c,
                            onTap: () {
                              setState(() => _selectedCategory = c);
                              _controller.applyFilter({'category': c});
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PaginatedListView<Product>(
        controller: _controller,
        // ── Loading ───────────────────────────────────────────────────
        loadingType: PaginationLoadingType.linear,
        // ── Theme ─────────────────────────────────────────────────────
        theme: PaginationTheme(
          emptyLabel: 'No products match your search.',
          endOfListLabel: '✓ All results loaded',
          retryLabel: 'Try Again',
        ),
        enableRefresh: true,
        refreshIndicatorColor: cs.primary,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        endOfListBuilder: (context) => const _EndOfListBanner(),
        itemBuilder: (context, product) => _ProductListTile(product: product),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4 – Error + retry demonstration
// ─────────────────────────────────────────────────────────────────────────────

class ErrorRetryDemo extends StatefulWidget {
  const ErrorRetryDemo({super.key});

  @override
  State<ErrorRetryDemo> createState() => _ErrorRetryDemoState();
}

class _ErrorRetryDemoState extends State<ErrorRetryDemo> {
  late final PaginationController<Product> _controller;
  int _attemptCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = PaginationController<Product>(fetch: _fetch);
  }

  Future<PaginationResult<Product>> _fetch(PaginationQuery query) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    _attemptCount++;
    // Fail the first 2 attempts so the user can experience retry
    if (_attemptCount <= 2) {
      throw Exception('Network error (attempt $_attemptCount/2). Please retry.');
    }
    final page = query.page ?? 1;
    return PaginationResult(
      items: _generateProducts(page),
      hasMore: page < 3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error + Retry'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () {
              _attemptCount = 0;
              _controller.refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ),
      body: PaginatedListView<Product>(
        controller: _controller,
        loadingType: PaginationLoadingType.shimmer,
        shimmerBaseColor: Colors.grey.shade300,
        shimmerHighlightColor: Colors.grey.shade100,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        // ── Custom error UI ───────────────────────────────────────────
        errorBuilder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded,
                    size: 72, color: cs.error.withValues(alpha: 0.7)),
                const SizedBox(height: 16),
                Text(
                  'Connection Failed',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Could not load products. This demo will succeed after 2 retries.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _controller.retry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry Now'),
                ),
              ],
            ),
          ),
        ),
        // ── Theme for inline retry (load more errors) ─────────────────
        theme: PaginationTheme(
          retryLabel: 'Retry',
          endOfListLabel: '✓ All loaded',
        ),
        itemBuilder: (context, product) => _ProductListTile(product: product),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI components
// ─────────────────────────────────────────────────────────────────────────────

class _ProductListTile extends StatelessWidget {
  final Product product;
  const _ProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: product.color.withValues(alpha: 0.15),
          child: Text(
            product.name[0],
            style: TextStyle(
              color: product.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          product.category,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: product.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: product.color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Product product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: product.color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    product.color.withValues(alpha: 0.8),
                    product.color,
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Text(
                  '#${product.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.category,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: product.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EndOfListBanner extends StatelessWidget {
  const _EndOfListBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: Colors.green.shade400, size: 28),
          const SizedBox(height: 6),
          Text(
            "You've seen it all!",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? cs.primary : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? cs.onPrimary : cs.onSurface,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
